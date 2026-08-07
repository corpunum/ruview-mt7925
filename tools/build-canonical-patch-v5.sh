#!/usr/bin/env bash
set -euo pipefail

# Reproducible Build Script for MT7925 Patch v5 (Two-Stage Testmode Sequence) on Ubuntu 7.0.0-28
CAN_SRC="/tmp/canonical_mt76_source/drivers/net/wireless/mediatek/mt76"
BUILD_DIR="/tmp/canonical_patch_v5_build"
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

echo "=== STEP 2: APPLYING PATCH V5 (TWO-STAGE TESTMODE SEQUENCE) ==="
cat << 'PYEOF' > /tmp/apply_patch_v5.py
with open("/tmp/canonical_patch_v5_build/mt7925/init.c", "r") as f:
    text = f.read()

sysfs_addition = """
#define MT7925_EVT_RSP_LEN 512

static ssize_t
mt7925_icap_trigger_store(struct device *dev,
			  struct device_attribute *attr,
			  const char *buf, size_t count)
{
	struct mt792x_phy *phy = dev_get_drvdata(dev);
	struct mt792x_dev *mdev;
	struct mt7925_rftest_cmd cmd;
	struct sk_buff *skb = NULL;
	unsigned long val;
	int ret;

	if (!phy || !phy->dev)
		return -ENODEV;

	mdev = phy->dev;

	if (kstrtoul(buf, 10, &val) || val != 1)
		return -EINVAL;

	mutex_lock(&mdev->mt76.mutex);

	/* Stage 1: Power Lock */
	mdev->pm.enable = false;
	cancel_delayed_work_sync(&mdev->pm.ps_work);
	cancel_work_sync(&mdev->pm.wake_work);
	dev_info(dev, "[RuView V5] Stage 1: Power Lock complete, PM disabled\\n");

	/* Stage 2: SWITCH_MODE_RF_TEST */
	memset(&cmd, 0, sizeof(cmd));
	cmd.ctrl.action = CMD_TEST_CTRL_ACT_SWITCH_MODE;
	cmd.ctrl.data.op_mode = cpu_to_le32(CMD_TEST_CTRL_ACT_SWITCH_MODE_RF_TEST);
	ret = mt76_mcu_send_msg(&mdev->mt76, MCU_UNI_CMD(TESTMODE_CTRL), &cmd, sizeof(cmd), false);
	if (ret) {
		dev_err(dev, "[RuView V5] Stage 2: SWITCH_MODE_RF_TEST failed: %d\\n", ret);
		goto out;
	}
	dev_info(dev, "[RuView V5] Stage 2: SWITCH_MODE_RF_TEST SUCCESS!\\n");

	/* Stage 3: SWITCH_MODE_ICAP */
	cmd.ctrl.data.op_mode = cpu_to_le32(CMD_TEST_CTRL_ACT_SWITCH_MODE_ICAP);
	ret = mt76_mcu_send_msg(&mdev->mt76, MCU_UNI_CMD(TESTMODE_CTRL), &cmd, sizeof(cmd), false);
	if (ret) {
		dev_err(dev, "[RuView V5] Stage 3: SWITCH_MODE_ICAP failed: %d\\n", ret);
		goto out;
	}
	dev_info(dev, "[RuView V5] Stage 3: SWITCH_MODE_ICAP SUCCESS!\\n");

	/* Stage 4: MCU_UNI_QUERY(TESTMODE_RX_STAT) */
	memset(&cmd, 0, sizeof(cmd));
	*((u16 *)cmd.padding) = MCU_UNI_CMD_TESTMODE_RX_STAT;
	ret = mt76_mcu_send_and_get_msg(&mdev->mt76, MCU_UNI_QUERY(TESTMODE_RX_STAT),
					&cmd, sizeof(cmd), true, &skb);
	if (ret) {
		dev_err(dev, "[RuView V5] Stage 4: TESTMODE_RX_STAT query failed: %d\\n", ret);
		goto out;
	}

	if (skb && skb->len >= 8) {
		dev_info(dev, "[RuView V5] Stage 4: TESTMODE_RX_STAT SUCCESS! Payload len=%d\\n", skb->len);
		print_hex_dump(KERN_INFO, "[RuView V5 RX_STAT] ", DUMP_PREFIX_OFFSET, 16, 1,
			       skb->data, skb->len, false);
		dev_kfree_skb(skb);
	} else if (skb) {
		dev_warn(dev, "[RuView V5] Stage 4: Short response len=%d\\n", skb->len);
		dev_kfree_skb(skb);
		ret = -EINVAL;
	}

out:
	/* Stage 5: Restore Power State */
	mdev->pm.enable = true;
	mutex_unlock(&mdev->mt76.mutex);
	return ret ? ret : count;
}

static DEVICE_ATTR_WO(mt7925_icap_trigger);
"""

last_inc = text.rfind("#include")
line_end = text.find("\n", last_inc)

text = text[:line_end+1] + sysfs_addition + "\n" + text[line_end+1:]

reg_pos = text.find("mt76_register_device(&dev->mt76")
line_end = text.find(";\n", reg_pos)

ins_str = '\n\tdev_set_drvdata(&dev->mt76.hw->wiphy->dev, &dev->phy);\n\tret = sysfs_create_file(&dev->mt76.hw->wiphy->dev.kobj, &dev_attr_mt7925_icap_trigger.attr);\n\tif (ret)\n\t\tdev_err(dev->mt76.dev, "[RuView] Failed to create sysfs icap_trigger\\n");'
text = text[:line_end+2] + ins_str + text[line_end+2:]

with open("/tmp/canonical_patch_v5_build/mt7925/init.c", "w") as f:
    f.write(text)

print("[+] Successfully applied Patch v5 two-stage testmode sequence to mt7925/init.c")
PYEOF

python3 /tmp/apply_patch_v5.py

echo "=== STEP 3: COMPILING CANONICAL MT7925 EXPERIMENTAL MODULES ==="
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

