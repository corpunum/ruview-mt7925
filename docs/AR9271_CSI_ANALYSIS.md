# Qualcomm Atheros AR9271 (`ath9k_htc`) CSI Technical Analysis (`docs/AR9271_CSI_ANALYSIS.md`)

This document presents the empirical investigation, firmware source audit, and runtime feasibility assessment for extracting Channel State Information (CSI) from the USB TP-Link TL-WN722N v1.0 (`0cf3:9271`) adapter.

---

## 1. Executive Summary & Verdict

| Dimension | Measured Status / Finding | Qualifier |
|---|---|---|
| **Hardware Identification** | TP-Link TL-WN722N v1.0 (USB `0cf3:9271`, Qualcomm Atheros AR9271 802.11n) | **`[RUNTIME PROVEN]`** |
| **Bound Host Driver** | `ath9k_htc` (Firmware `htc_9271-1.4.0.fw`) | **`[RUNTIME PROVEN]`** |
| **Stock Firmware SHA256** | `1ec4cdf426d32602034cb4731b618155911b4afc863b7e0d19407937cbd1c2a2` | **`[RUNTIME PROVEN]`** |
| **Stock Firmware Backup** | Preserved at `/tmp/ar9271_stock_backup/htc_9271-1.4.0.fw.zst` | **`[RUNTIME PROVEN]`** |
| **CSI Technical Feasibility** | **`CSI_RUNTIME_FAILED`** (AR9271 firmware/driver stack does NOT expose raw CSI IQ hardware registers) | **`[SOURCE PROVEN]`** |
| **Atheros CSI Tool Target** | Requires PCI/PCIe chipsets (`AR9344`, `AR9580`, `AR9590`) running full `ath9k` driver; `ath9k_htc` USB architecture is UNSUPPORTED. | **`[UPSTREAM PROVEN]`** |

---

## 2. Firmware & Architecture Investigation

1. **Atheros CSI Tool Target Architecture:** The standard open-source `Atheros-CSI-Tool` and `ar9003_csi.ko` modules explicitly require **PCI / PCIe** Atheros 802.11n hardware (such as `AR9344` or `AR9580` found in the TL-WDR3600 router).
2. **`ath9k_htc` USB Firmware Limits:** The USB AR9271 operates via Host-Target Communications (HTC) firmware (`open-ath9k-htc-firmware`). The AR9271 MAC/PHY hardware does not expose raw OFDM subcarrier CSI matrices over the USB HTC message queues.
3. **Monitor Mode vs CSI:** While the TL-WN722N v1.0 excels at 802.11n packet injection and monitor mode frame capture (`radiotap` header RSSI/rate telemetry), it does NOT provide complex $I/Q$ channel frequency response matrices.

---

## 3. Classification & Decision

```text
AR9271 CSI VERDICT: CSI_RUNTIME_FAILED

- Target hardware: TP-Link TL-WN722N v1.0 (AR9271)
- Firmware status: Stock firmware ath9k_htc/htc_9271-1.4.0.fw loaded
- CSI extraction status: NOT SUPPORTED BY AR9271 FIRMWARE ARCHITECTURE
- Operational role: Baseline 802.11n frame injection / monitor receiver for testing MT7925
```
