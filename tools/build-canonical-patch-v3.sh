#!/usr/bin/env bash
set -euo pipefail

# Reproducible Build Script for MT7925 Patch v3 on Ubuntu Canonical Kernel 7.0.0-28
CAN_SRC="/tmp/canonical_mt76_source/drivers/net/wireless/mediatek/mt76"
BUILD_DIR="/tmp/canonical_patch_v3_build"
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

echo "=== STEP 2: APPLYING PATCH V3 TO MT7925 DEBUGFS.C ==="
cat << 'PYEOF' > /tmp/apply_patch_v3.py
with open("/tmp/canonical_patch_v3_build/mt7925/debugfs.c", "r") as f:
    lines = f.readlines()

target_idx = -1
for i, line in enumerate(lines):
    if "void mt7925_init_debugfs" in line or "mt7925_init_debugfs(struct mt792x_dev *dev)" in line:
        target_idx = i
        break

addition = """
#define MT7925_EVT_RSP_LEN 512

static int
mt7925_icap_trigger_set(void *data, u64 val)
{
	struct mt792x_dev *dev = data;
	struct mt7925_rftest_cmd cmd;
	struct sk_buff *skb = NULL;
	int ret;

	if (val != 1)
		return -EINVAL;

	memset(&cmd, 0, sizeof(cmd));
	cmd.ctrl.action = CMD_TEST_CTRL_ACT_SWITCH_MODE;
	cmd.ctrl.data.op_mode = cpu_to_le32(CMD_TEST_CTRL_ACT_SWITCH_MODE_ICAP);

	mutex_lock(&dev->mt76.mutex);
	dev->pm.enable = false;
	ret = mt76_mcu_send_and_get_msg(&dev->mt76, MCU_UNI_QUERY(TESTMODE_CTRL),
					&cmd, sizeof(cmd), true, &skb);
	if (ret) {
		dev->pm.enable = true;
		mutex_unlock(&dev->mt76.mutex);
		return ret;
	}

	if (skb && skb->len >= MT7925_EVT_RSP_LEN + 8) {
		dev_kfree_skb(skb);
	} else if (skb) {
		dev_kfree_skb(skb);
		ret = -EINVAL;
	}

	dev->pm.enable = true;
	mutex_unlock(&dev->mt76.mutex);
	return ret;
}

DEFINE_DEBUGFS_ATTRIBUTE(fops_icap_trigger, NULL, mt7925_icap_trigger_set, "%llu");

"""

lines.insert(target_idx, addition)

for i, line in enumerate(lines):
    if "debugfs_create_file(\"idle-timeout\"" in line:
        for j in range(i, len(lines)):
            if ";" in lines[j]:
                lines.insert(j + 1, '\tdebugfs_create_file("icap_trigger", 0200, dir, dev, &fops_icap_trigger);\n')
                break
        break

with open("/tmp/canonical_patch_v3_build/mt7925/debugfs.c", "w") as f:
    f.writelines(lines)

print("[+] Clean exact line patch applied to Canonical debugfs.c")
PYEOF

python3 /tmp/apply_patch_v3.py

echo "=== STEP 3: COMPILING MT7925 EXPERIMENTAL MODULES ==="
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

