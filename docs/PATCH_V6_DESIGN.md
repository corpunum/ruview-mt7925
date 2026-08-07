# Patch v6 Minimum Implementation Design (`docs/PATCH_V6_DESIGN.md`)

This document presents the **proposed minimum design for Patch v6**, derived from Phase 1-5 source forensics.

---

## 1. Design Specification & Architectural Constraints

> [!WARNING]
> **PATCH V6 IS PROPOSED AS A SPECIFICATION DESIGN ONLY.**
> **NO KERNEL MODULE CODE SHALL BE COMPILED OR LOADED.**

### Minimum Components Required for Host-Side Capture
1. **Reuse Existing Netlink Testmode Handler:** Extend `mt7925_testmode_cmd()` in `mt7925/testmode.c`.
2. **Reuse Existing MAC RX Vector Path:** Capture per-packet OFDM PHY channel metrics (`MT_PRXV_RCPI0-3`, `MT_CRXV_SNR`, `MT_CRXV_FOE`) directly inside `mt7925_mac_fill_rx()` in `mac.c:510` without switching MCU to ICAP mode.

---

## 2. Proposed Patch v6 Code Specification (Design Only)

```c
/* Proposed Patch v6 Design: Passive RX-Vector RSSI/SNR Capture Hook */
/* Location: drivers/net/wireless/mediatek/mt76/mt7925/mac.c */

static inline void
mt7925_capture_rxv_metrics(struct mt792x_dev *dev, struct sk_buff *skb,
			   __le32 *rxv)
{
	struct mt76_rx_status *status = (struct mt76_rx_status *)skb->cb;
	u32 v1, v20;
	s8 rcpi[4], snr;

	if (!rxv)
		return;

	v1 = le32_to_cpu(rxv[1]);
	v20 = le32_to_cpu(rxv[20]);

	rcpi[0] = to_rssi(MT_PRXV_RCPI0, v1);
	rcpi[1] = to_rssi(MT_PRXV_RCPI1, v1);
	rcpi[2] = to_rssi(MT_PRXV_RCPI2, v1);
	rcpi[3] = to_rssi(MT_PRXV_RCPI3, v1);

	snr = FIELD_GET(MT_CRXV_SNR, v20) - 16;

	/* Log packet-level PHY channel metrics without MCU testmode switch */
	dev_dbg(dev->mt76.dev, "[RuView RXV] RCPI: %d %d %d %d, SNR: %d dB\n",
		rcpi[0], rcpi[1], rcpi[2], rcpi[3], snr);
}
```

---

## 3. Decision & Next Steps

- **Patch v6 Status:** PROPOSED DESIGN SPECIFICATION ONLY.
- **Execution Verdict:** **`NOT_EXECUTED`** (Prohibited per user directive).
