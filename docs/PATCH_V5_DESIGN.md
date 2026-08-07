# Patch v5 Design & Execution Alignment (`docs/PATCH_V5_DESIGN.md`)

This document records the design and runtime execution alignment for **Patch v5 — Two-Stage Testmode ICAP Sequence**.

---

## 1. Design vs Implementation Alignment

- **State Member Struct Access:** During compilation, `phy->mt76.test.state` was verified as unexposed in the MT7925 sub-phy layer (`CONFIG_NL80211_TESTMODE`). Stage 1 power control locking (`mdev->pm.enable = false`, `cancel_delayed_work_sync`) was executed directly without mutating unexposed testmode struct fields.
- **Stage Execution Results:**
  - Stage 1 (Power Lock): **`SUCCESS`**
  - Stage 2 (`SWITCH_MODE_RF_TEST`): **`SUCCESS`** (MCU acknowledged)
  - Stage 3 (`SWITCH_MODE_ICAP`): **`SUCCESS`** (MCU acknowledged)
  - Stage 4 (`MCU_UNI_QUERY(TESTMODE_RX_STAT)`): **`SUCCESS`** (MCU returned 8-byte status header `32 00 00 00 bb 00 00 c0`)
  - Stage 5 (Power Restore): **`SUCCESS`**

---

## 2. Implemented Patch v5 Code Reference

```c
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
	dev_info(dev, "[RuView V5] Stage 1: Power Lock complete, PM disabled\n");

	/* Stage 2: SWITCH_MODE_RF_TEST */
	memset(&cmd, 0, sizeof(cmd));
	cmd.ctrl.action = CMD_TEST_CTRL_ACT_SWITCH_MODE;
	cmd.ctrl.data.op_mode = cpu_to_le32(CMD_TEST_CTRL_ACT_SWITCH_MODE_RF_TEST);
	ret = mt76_mcu_send_msg(&mdev->mt76, MCU_UNI_CMD(TESTMODE_CTRL), &cmd, sizeof(cmd), false);
	if (ret) {
		dev_err(dev, "[RuView V5] Stage 2: SWITCH_MODE_RF_TEST failed: %d\n", ret);
		goto out;
	}
	dev_info(dev, "[RuView V5] Stage 2: SWITCH_MODE_RF_TEST SUCCESS!\n");

	/* Stage 3: SWITCH_MODE_ICAP */
	cmd.ctrl.data.op_mode = cpu_to_le32(CMD_TEST_CTRL_ACT_SWITCH_MODE_ICAP);
	ret = mt76_mcu_send_msg(&mdev->mt76, MCU_UNI_CMD(TESTMODE_CTRL), &cmd, sizeof(cmd), false);
	if (ret) {
		dev_err(dev, "[RuView V5] Stage 3: SWITCH_MODE_ICAP failed: %d\n", ret);
		goto out;
	}
	dev_info(dev, "[RuView V5] Stage 3: SWITCH_MODE_ICAP SUCCESS!\n");

	/* Stage 4: MCU_UNI_QUERY(TESTMODE_RX_STAT) */
	memset(&cmd, 0, sizeof(cmd));
	*((u16 *)cmd.padding) = MCU_UNI_CMD_TESTMODE_RX_STAT;
	ret = mt76_mcu_send_and_get_msg(&mdev->mt76, MCU_UNI_QUERY(TESTMODE_RX_STAT),
					&cmd, sizeof(cmd), true, &skb);
	if (ret) {
		dev_err(dev, "[RuView V5] Stage 4: TESTMODE_RX_STAT query failed: %d\n", ret);
		goto out;
	}

	if (skb && skb->len >= 8) {
		dev_info(dev, "[RuView V5] Stage 4: TESTMODE_RX_STAT SUCCESS! Payload len=%d\n", skb->len);
		print_hex_dump(KERN_INFO, "[RuView V5 RX_STAT] ", DUMP_PREFIX_OFFSET, 16, 1,
			       skb->data, skb->len, false);
		dev_kfree_skb(skb);
	} else if (skb) {
		dev_kfree_skb(skb);
		ret = -EINVAL;
	}

out:
	/* Stage 5: Restore State */
	mdev->pm.enable = true;
	mutex_unlock(&mdev->mt76.mutex);
	return ret ? ret : count;
}
```

---

## 3. Final Verdict

- **Execution Verdict:** **`STATUS_ONLY`** / **`CSI_NOT_PROVEN`**.
- **Empirical Proof:** All 4 MCU stages executed cleanly without errors, but the query returns a static 8-byte status response header.
