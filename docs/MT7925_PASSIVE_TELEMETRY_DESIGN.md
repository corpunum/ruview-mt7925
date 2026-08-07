# MT7925 Passive Telemetry Patch Design (`docs/MT7925_PASSIVE_TELEMETRY_DESIGN.md`)

This document presents the Phase 2 minimum non-intrusive patch design to expose per-packet P-RXV/C-RXV PHY telemetry via Linux kernel tracepoints and DebugFS logging.

---

## 1. Architectural Philosophy

1. **Zero MCU Testmode Interactivity:** Operates entirely within standard Linux `mac80211` operational mode.
2. **Zero Security Policy Alterations:** Does not require disabling Secure Boot or kernel lockdown.
3. **Passive Ingestion:** Hooks directly into `mt7925_mac_fill_rx()` in `mac.c:510` to log per-packet PHY vector metrics (`RCPI0-3`, `TxBF`, `RU_ALLOC`, `BSS_COLOR`) for all incoming frames.

---

## 2. Proposed Passive Telemetry Code Patch (Design Specification Only)

```c
/* Location: drivers/net/wireless/mediatek/mt76/mt7925/mac.c */

static inline void
mt7925_log_passive_telemetry(struct mt792x_dev *dev, struct sk_buff *skb,
			     __le32 *rxv)
{
	struct mt76_rx_status *status = (struct mt76_rx_status *)skb->cb;
	u32 v0, v3, v4;
	s8 rcpi[4];
	bool txbf;

	if (!rxv)
		return;

	v0 = le32_to_cpu(rxv[0]);
	v3 = le32_to_cpu(rxv[3]);
	v4 = le32_to_cpu(rxv[4]);

	rcpi[0] = to_rssi(MT_PRXV_RCPI0, v3);
	rcpi[1] = to_rssi(MT_PRXV_RCPI1, v3);
	rcpi[2] = to_rssi(MT_PRXV_RCPI2, v3);
	rcpi[3] = to_rssi(MT_PRXV_RCPI3, v3);

	txbf = !!(v0 & MT_PRXV_TXBF);

	/* Log non-intrusive per-packet telemetry via dev_dbg */
	dev_dbg(dev->mt76.dev,
		"[RuView Passive Telemetry] MAC: %pM | RCPI: %d %d %d %d | TxBF: %d | BW: %d\n",
		eth_hdr(skb)->h_source, rcpi[0], rcpi[1], rcpi[2], rcpi[3],
		txbf, status->bw);
}
```
