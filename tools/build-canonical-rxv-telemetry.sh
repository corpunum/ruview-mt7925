#!/usr/bin/env bash
set -euo pipefail

# Reproducible Build Script for MT7925 Passive RXV Telemetry Ring Buffer on Ubuntu 7.0.0-28
CAN_SRC="/tmp/canonical_mt76_source/drivers/net/wireless/mediatek/mt76"
BUILD_DIR="/tmp/canonical_rxv_build"
MODULE_DIR="/var/tmp/mt7925_gate1"
SIG_TOOL="/usr/src/linux-headers-$(uname -r)/scripts/sign-file"
MOK_PRIV="/var/lib/shim-signed/mok/MOK.priv"
MOK_DER="/var/lib/shim-signed/mok/MOK.der"

echo "=== STEP 1: PREPARING CANONICAL MT76 SOURCE TREE ==="
if [ ! -d "$CAN_SRC" ]; then
    echo "[*] Cloning Launchpad Ubuntu Canonical kernel source..."
    git clone --depth 1 --branch Ubuntu-hwe-7.0-7.0.0-28.28_24.04.1 git://git.launchpad.net/~ubuntu-kernel/ubuntu/+source/linux/+git/noble /tmp/canonical_mt76_source
fi

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cp -r "$CAN_SRC"/* "$BUILD_DIR/"

echo "=== STEP 2: APPLYING RXV TELEMETRY RING BUFFER PATCH TO MT7925 MAC.C & INIT.C ==="
cat << 'PYEOF' > /tmp/apply_rxv_patch.py
with open("/tmp/canonical_rxv_build/mt7925/init.c", "r") as f:
    text = f.read()

ring_impl = """
#define RXV_RING_SIZE 4096

struct ruview_rxv_sample {
	u64 ts_ns;
	u32 prxv[4];
	u32 crxv[24];
	s8 rcpi[4];
	u8 mcs;
	u8 nss;
	u8 bw;
	u8 mode;
} __packed;

struct ruview_rxv_ring {
	struct ruview_rxv_sample samples[RXV_RING_SIZE];
	atomic_t head;
	atomic_t tail;
	atomic_t dropped;
} ____cacheline_aligned;

static struct ruview_rxv_ring g_rxv_ring;

void mt7925_store_rxv_sample(const __le32 *rxv, const struct mt76_rx_status *status)
{
	int head = atomic_read(&g_rxv_ring.head);
	int tail = atomic_read(&g_rxv_ring.tail);
	int next_head = (head + 1) % RXV_RING_SIZE;
	struct ruview_rxv_sample *s;
	int i;

	if (next_head == tail) {
		atomic_inc(&g_rxv_ring.dropped);
		return;
	}

	s = &g_rxv_ring.samples[head];
	s->ts_ns = ktime_get_ns();

	for (i = 0; i < 4; i++)
		s->prxv[i] = le32_to_cpu(rxv[i]);

	for (i = 0; i < 24; i++)
		s->crxv[i] = le32_to_cpu(rxv[i + 4]);

	for (i = 0; i < 4; i++)
		s->rcpi[i] = status->chain_signal[i];

	s->mcs = status->rate_idx;
	s->nss = status->nss;
	s->bw = status->bw;
	s->mode = status->encoding;

	atomic_set(&g_rxv_ring.head, next_head);
}
EXPORT_SYMBOL_GPL(mt7925_store_rxv_sample);

static ssize_t
mt7925_rxv_telemetry_read(struct file *file, char __user *buf,
			  size_t count, loff_t *ppos)
{
	int tail = atomic_read(&g_rxv_ring.tail);
	int head = atomic_read(&g_rxv_ring.head);
	int available;
	size_t copy_len;

	if (tail == head)
		return 0;

	if (head > tail)
		available = head - tail;
	else
		available = RXV_RING_SIZE - tail;

	copy_len = min(count / sizeof(struct ruview_rxv_sample), (size_t)available) * sizeof(struct ruview_rxv_sample);
	if (!copy_len)
		return 0;

	if (copy_to_user(buf, &g_rxv_ring.samples[tail], copy_len))
		return -EFAULT;

	atomic_set(&g_rxv_ring.tail, (tail + (copy_len / sizeof(struct ruview_rxv_sample))) % RXV_RING_SIZE);
	return copy_len;
}

static const struct file_operations mt7925_rxv_telemetry_fops = {
	.owner = THIS_MODULE,
	.read = mt7925_rxv_telemetry_read,
	.open = simple_open,
	.llseek = default_llseek,
};

"""

last_inc = text.rfind("#include")
line_end = text.find("\n", last_inc)
text = text[:line_end+1] + ring_impl + "\n" + text[line_end+1:]

reg_pos = text.find("mt76_register_device(&dev->mt76")
line_end = text.find(";\n", reg_pos)

ins_str = '\n\tdev_set_drvdata(&dev->mt76.hw->wiphy->dev, &dev->phy);\n\tdebugfs_create_file("mt7925_rxv_telemetry", 0444, dev->mt76.hw->wiphy->debugfsdir, dev, &mt7925_rxv_telemetry_fops);'
text = text[:line_end+2] + ins_str + text[line_end+2:]

with open("/tmp/canonical_rxv_build/mt7925/init.c", "w") as f:
    f.write(text)

with open("/tmp/canonical_rxv_build/mt7925/mt7925.h", "r") as f:
    hdr_text = f.read()

hdr_text += "\nvoid mt7925_store_rxv_sample(const __le32 *rxv, const struct mt76_rx_status *status);\n"
with open("/tmp/canonical_rxv_build/mt7925/mt7925.h", "w") as f:
    f.write(hdr_text)

with open("/tmp/canonical_rxv_build/mt7925/mac.c", "r") as f:
    mac_text = f.read()

target_hook = "mt7925_mac_fill_rx_rate(dev, status, sband, rxv, &mode);"
hook_pos = mac_text.find(target_hook)
line_end = mac_text.find(";\n", hook_pos)

ins_hook = "\n\t\tmt7925_store_rxv_sample(rxv, status);"
mac_text = mac_text[:line_end+2] + ins_hook + mac_text[line_end+2:]

with open("/tmp/canonical_rxv_build/mt7925/mac.c", "w") as f:
    f.write(mac_text)

print("[+] Successfully applied RXV Telemetry Ring Buffer patch to mt7925 source")
PYEOF

python3 /tmp/apply_rxv_patch.py

echo "=== STEP 3: COMPILING CANONICAL MT7925 TELEMETRY MODULES ==="
cd "$BUILD_DIR/mt7925"
make -C /lib/modules/$(uname -r)/build M=$PWD EXTRA_CFLAGS="-I$BUILD_DIR -I$PWD" modules

sudo rm -rf "$MODULE_DIR"
sudo mkdir -p "$MODULE_DIR"
sudo chmod 755 "$MODULE_DIR"

sudo cp "$BUILD_DIR/mt7925/mt7925-common.ko" "$MODULE_DIR/"
sudo cp "$BUILD_DIR/mt7925/mt7925e.ko" "$MODULE_DIR/"
sudo chmod 644 "$MODULE_DIR"/*.ko

echo "=== STEP 4: SIGNING MODULES WITH MOK KEY ==="
sudo $SIG_TOOL sha512 $MOK_PRIV $MOK_DER "$MODULE_DIR/mt7925-common.ko"
sudo $SIG_TOOL sha512 $MOK_PRIV $MOK_DER "$MODULE_DIR/mt7925e.ko"

echo "=== REPRODUCIBLE BUILD & MOK SIGNING COMPLETE ==="
sudo sha256sum "$MODULE_DIR/mt7925-common.ko" "$MODULE_DIR/mt7925e.ko"

