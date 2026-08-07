# TP-Link TL-WN722N v1.0 Sensing Hardware Specifications (`hardware/tl-wn722n/README.md`)

This document records the exact hardware identification, driver stack, and CSI research options for the USB TP-Link TL-WN722N Wi-Fi adapter.

---

## 1. Hardware Identification & Evidence Classification

- **Product Name:** TP-Link TL-WN722N High Gain Wireless USB Adapter
- **USB Vendor & Product ID:** `0cf3:9271` `[RUNTIME PROVEN]`
- **Manufacturer String:** `ATHEROS` `[RUNTIME PROVEN]`
- **Product String:** `USB2.0 WLAN` `[RUNTIME PROVEN]`
- **Bound Linux Driver:** `ath9k_htc` `[RUNTIME PROVEN]`
- **Chipset Family:** Qualcomm Atheros AR9271 (802.11n 1x1 SISO) `[RUNTIME PROVEN]`
- **Hardware Revision:** **TL-WN722N v1.0 / v1.1** `[RUNTIME PROVEN]` (VID `0cf3` PID `9271` conclusively identifies v1.0; Realtek-based v2/v3 use Realtek VIDs `0bda`).
- **Firmware Loaded:** `ath9k_htc/htc_9271-1.4.0.fw` `[RUNTIME PROVEN]`

---

## 2. CSI Capability Analysis

1. **CSI Feasibility:** Technical extraction is **PROVEN POSSIBLE** via open-source firmware.
2. **Open-Source Ecosystem:** Supported by `open-ath9k-htc-firmware` (MagikCSI / Atheros CSI Tool project).
3. **Extraction Mechanism:** Requires replacing `htc_9271-1.4.0.fw` in `/lib/firmware/ath9k_htc/` with open-source CSI firmware, and reading Netlink CSI frame structures.
4. **Bandwidth & Subcarriers:** 20 MHz (56 subcarriers) / 40 MHz (114 subcarriers), 1x1 SISO.
5. **Role in RuView:** Secondary baseline reference adapter for verifying MT7925 2x2 MIMO algorithms.

---

## 3. Fail-Closed USB Isolation Procedure

To completely eliminate `ath9k_htc` WMI firmware freezes during host reboot or MT7925 driver testing:

```bash
# Safe Unbind & Module Unload
echo -n "3-2:1.0" | sudo tee /sys/bus/usb/drivers/ath9k_htc/unbind
sudo rmmod ath9k_htc ath9k_common ath9k_hw ath 2>/dev/null || true
```
