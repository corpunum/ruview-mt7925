# CSI Hardware Alternatives & Ecosystem Analysis (`docs/CSI_HARDWARE_ALTERNATIVES.md`)

This document provides Phase 4-5 information value comparison and documents Atheros PCIe chipsets that expose true subcarrier OFDM Channel State Information (CSI).

---

## 1. Information Value Comparison Matrix

| Sensing Capability | MT7925 RX-Vector Telemetry | True Subcarrier CSI | Useful for Sensing? |
|---|---|---|---|
| **Presence / Motion Detection** | **YES** (Per-chain RSSI/RCPI variance) | **YES** (Subcarrier phase/mag variance) | **YES** (Coarse motion) |
| **Coarse Localization** | **YES** (Multi-antenna RCPI trilateration) | **YES** (Subcarrier ToF & AoA) | **YES** (Zone-level) |
| **Device-Free Motion Sensing** | **LIMITED** (Per-chain RSSI fluctuations) | **YES** (Subcarrier Doppler shift) | **LIMITED** |
| **Subcarrier Fine Sensing** | **NO** (Only 4 scalar RSSI values) | **YES** (64-512 OFDM subcarrier matrices) | **NO** |
| **Gesture / Micro-Motion** | **NO** | **YES** (Subcarrier phase Doppler) | **NO** |

---

## 2. Proven Open-Source CSI Hardware Ecosystem (PCIe Targets)

For applications requiring true fine-grained OFDM subcarrier matrices, the following PCIe Wi-Fi chipsets possess mature open-source CSI tools:

### A. Atheros AR9300 / AR9580 / AR9590 (Atheros CSI Tool)
- **Interface:** PCI Express (PCIe).
- **Driver:** Linux `ath9k` (`drivers/net/wireless/ath/ath9k`).
- **CSI Resolution:** 56 subcarriers per 20MHz / 114 subcarriers per 40MHz for 3x3 MIMO.
- **Ecosystem:** `Atheros CSI Tool` (open-source kernel module `ar9003_csi.ko`).

### B. Intel 5300 / 6300 (Intel CSI Tool)
- **Interface:** PCIe Mini-Card.
- **Driver:** Linux `iwlwifi`.
- **CSI Resolution:** 30 subcarriers per 20MHz/40MHz for 3x3 MIMO.
- **Ecosystem:** `Linux 802.11n CSI Tool`.

---

## 3. Recommendation for RuView Sensing Architecture

1. **MT7925 (Onboard PCIe):** Utilize passive P-RXV telemetry (`RCPI0-3`, TxBF, MCS, BW) for coarse presence detection, RSSI fingerprinting, and link quality monitoring.
2. **PCIe Atheros Target (Future Hardware Expansion):** Deploy PCIe Atheros AR9580/AR9590 with `ath9k` for research requiring raw subcarrier CSI phase/amplitude matrices.
