# Patch v5 Design & Testmode State Machine Proposal (`docs/PATCH_V5_DESIGN.md`)

This document outlines the proposed design for **Patch v5 — Two-Stage Testmode ICAP Sequence**, derived from MT7915 testmode forensics and protocol analysis.

---

## 1. Evidence-Backed Hypothesis (V5A / V5B Hybrid)

- **Root Cause of Status-Only Return:** In Patch v4, writing `1` to `mt7925_icap_trigger` dispatched `CMD_TEST_CTRL_ACT_SWITCH_MODE_ICAP` directly while the driver remained in standard operational mode without setting `phy->test.state = MT76_TM_STATE_ON`, configuring the RX test filter, or querying `MCU_UNI_QUERY(TESTMODE_RX_STAT)`.
- **Proposed Patch v5 Sequence:**
  1. **Stage 1 (Testmode Enable & Power Lock):** Set `phy->test.state = MT76_TM_STATE_ON`, disable driver PM (`dev->pm.enable = false`), and send `CMD_TEST_CTRL_ACT_SWITCH_MODE_RF_TEST`.
  2. **Stage 2 (ICAP Mode Switch):** Send `CMD_TEST_CTRL_ACT_SWITCH_MODE_ICAP`.
  3. **Stage 3 (RX Stat / Capture Buffer Query):** Send `MCU_UNI_QUERY(TESTMODE_RX_STAT)` to fetch the 512-byte testmode capture/statistics payload.
  4. **Stage 4 (Controlled Cleanup & Normal Mode Restoration):** Restore `phy->test.state = MT76_TM_STATE_OFF` and `dev->pm.enable = true`.

---

## 2. Proposed Patch v5 Code Implementation (Design Only)

```c
/* Proposed Patch v5 Implementation for mt7925/init.c */
static ssize_t
mt7925_icap_trigger_store_v5(struct device *dev,
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

	/* Stage 1: Power Control Lock & Testmode State On */
	mdev->pm.enable = false;
	cancel_delayed_work_sync(&mdev->pm.ps_work);
	cancel_work_sync(&mdev->pm.wake_work);
	phy->mt76->test.state = MT76_TM_STATE_ON;

	/* Stage 2: Send RF_TEST Mode Switch */
	memset(&cmd, 0, sizeof(cmd));
	cmd.ctrl.action = CMD_TEST_CTRL_ACT_SWITCH_MODE;
	cmd.ctrl.data.op_mode = cpu_to_le32(CMD_TEST_CTRL_ACT_SWITCH_MODE_RF_TEST);
	ret = mt76_mcu_send_msg(&mdev->mt76, MCU_UNI_CMD(TESTMODE_CTRL), &cmd, sizeof(cmd), false);
	if (ret) {
		dev_err(dev, "[RuView V5] RF_TEST mode switch failed: %d\n", ret);
		goto out;
	}

	/* Stage 3: Send ICAP Mode Switch */
	cmd.ctrl.data.op_mode = cpu_to_le32(CMD_TEST_CTRL_ACT_SWITCH_MODE_ICAP);
	ret = mt76_mcu_send_msg(&mdev->mt76, MCU_UNI_CMD(TESTMODE_CTRL), &cmd, sizeof(cmd), false);
	if (ret) {
		dev_err(dev, "[RuView V5] ICAP mode switch failed: %d\n", ret);
		goto out;
	}

	/* Stage 4: Query TESTMODE_RX_STAT Buffer */
	memset(&cmd, 0, sizeof(cmd));
	*((u16 *)cmd.padding) = MCU_UNI_CMD_TESTMODE_RX_STAT;
	ret = mt76_mcu_send_and_get_msg(&mdev->mt76, MCU_UNI_QUERY(TESTMODE_RX_STAT),
					&cmd, sizeof(cmd), true, &skb);
	if (ret) {
		dev_err(dev, "[RuView V5] TESTMODE_RX_STAT query failed: %d\n", ret);
		goto out;
	}

	if (skb && skb->len >= 8) {
		dev_info(dev, "[RuView V5] TESTMODE_RX_STAT SUCCESS! Payload len=%d\n", skb->len);
		dev_kfree_skb(skb);
	} else if (skb) {
		dev_kfree_skb(skb);
	}

out:
	/* Stage 5: Restore Normal Mode State */
	phy->mt76->test.state = MT76_TM_STATE_OFF;
	mdev->pm.enable = true;
	mutex_unlock(&mdev->mt76.mutex);

	return ret ? ret : count;
}
```

---

## 3. Confidence & Readiness Declaration

- **Design Status:** PROPOSED DESIGN ONLY (Not compiled, not loaded, not executed).
- **Confidence Rating:** **HIGH** (Grounded in MT7915 `testmode.c` and MT7925 `mcu.h` source inspection).
- **Next Step:** Await explicit user authorization before compiling or executing Patch v5.
