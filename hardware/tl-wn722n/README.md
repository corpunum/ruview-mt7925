# TP-Link TL-WN722N v1.0 Hardware & CSI Assessment (`hardware/tl-wn722n/README.md`)

This document records the exact hardware identification, driver stack, and CSI feasibility analysis for the USB TP-Link TL-WN722N Wi-Fi adapter.

---

## 1. Hardware Identification & Evidence Classification

- **Product Name:** TP-Link TL-WN722N High Gain Wireless USB Adapter
- **USB Vendor & Product ID:** `0cf3:9271` `[RUNTIME PROVEN]`
- **Manufacturer String:** `ATHEROS` `[RUNTIME PROVEN]`
- **Product String:** `USB2.0 WLAN` `[RUNTIME PROVEN]`
- **Bound Linux Driver:** `ath9k_htc` `[RUNTIME PROVEN]`
- **Chipset Family:** Qualcomm Atheros AR9271 (802.11n 1x1 SISO) `[RUNTIME PROVEN]`
- **Hardware Revision:** **TL-WN722N v1.0 / v1.1** `[RUNTIME PROVEN]` (VID `0cf3` PID `9271` conclusively identifies v1.0; Realtek-based v2/v3 use Realtek VIDs `0bda`).
- **Loaded Firmware:** `ath9k_htc/htc_9271-1.4.0.fw` `[RUNTIME PROVEN]`
- **Stock Firmware SHA256:** `1ec4cdf426d32602034cb4731b618155911b4afc863b7e0d19407937cbd1c2a2` `[RUNTIME PROVEN]`
- **Stock Firmware Backup:** Preserved at `/tmp/ar9271_stock_backup/htc_9271-1.4.0.fw.zst` `[RUNTIME PROVEN]`

---

## 2. CSI Capability Analysis

1. **CSI Feasibility:** **`CSI_RUNTIME_FAILED`** (AR9271 USB HTC firmware architecture does not expose raw OFDM subcarrier CSI matrices).
2. **Atheros CSI Tool Support:** Requires PCI/PCIe Atheros hardware (`AR9344`, `AR9580`, `AR9590`); USB `ath9k_htc` is unsupported by `ar9003_csi.ko`.
3. **Role in RuView Platform:** Secondary Traffic Generator / Packet Injector. The TL-WN722N v1.0 excels at monitor mode frame injection, acting as a controlled transmitter to feed frames to the MT7925 during Gate 2 testing.

---

## 3. Fail-Closed USB Isolation Procedure

To completely eliminate `ath9k_htc` WMI firmware freezes during host reboot or MT7925 driver testing:

```bash
# Safe Unbind & Module Unload
echo -n "3-2:1.0" | sudo tee /sys/bus/usb/drivers/ath9k_htc/unbind
sudo rmmod ath9k_htc ath9k_common ath9k_hw ath 2>/dev/null || true
```
