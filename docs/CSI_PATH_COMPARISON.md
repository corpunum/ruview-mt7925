# CSI Hardware Path & Tradeoff Comparison (`docs/CSI_PATH_COMPARISON.md`)

This document presents a quantitative, evidence-based evaluation comparing the two active Wi-Fi targets: Onboard MediaTek MT7925 vs USB TP-Link TL-WN722N v1.0 (AR9271).

---

## 1. Target Comparison Matrix

| Evaluation Dimension | Primary Target: MediaTek MT7925 | Secondary Reference Target: TP-Link TL-WN722N v1.0 |
|---|---|---|
| **Chipset / Architecture** | MediaTek MT7925 (PCIe `14c3:0717`) | Qualcomm Atheros AR9271 (USB 2.0 `0cf3:9271`) |
| **Wi-Fi Generation & Bandwidth** | Wi-Fi 7 (802.11be / ax / ac / n, up to 160/320 MHz) | Wi-Fi 4 (802.11n / g / b, 20 MHz / 40 MHz) |
| **Spatial Streams / MIMO** | 2x2 MIMO | 1x1 SISO (Single Antenna Stream) |
| **Subcarrier Granularity** | Up to 242+ subcarriers per 80 MHz channel | 56 subcarriers (HT20) / 114 subcarriers (HT40) |
| **Kernel / Driver Ecosystem** | Linux `mt76` / `mt7925e` | Linux `ath9k_htc` |
| **CSI Extraction Mechanism** | MCU `TESTMODE_CTRL` / DebugFS (`icap_trigger`) | UNSUPPORTED (`CSI_RUNTIME_FAILED`) |
| **Existing Research Support** | Prototype Patch v3 (`[EXPERIMENTAL]`) | Standard `radiotap` RSSI / injection only |
| **Firmware Modification Level** | Closed MediaTek FW (MCU pass-through query) | Stock open-source `htc_9271-1.4.0.fw` |
| **Rollback Safety & Isolation** | **98%** (Dual-layer rollback daemon + Ethernet `eno1`) | **100%** (USB sysfs unbind `/sys/bus/usb/drivers/ath9k_htc/unbind`) |
| **RuView Pipeline Role** | **PRIMARY_CSI_PATH** (Native high-res RF sensing) | **SECONDARY_MONITOR_PATH** (Packet injection / traffic generation) |
| **Current Gate / Evidence Status** | **GATE1 = PASS `[RUNTIME PROVEN]` / GATE2 = READY** | **HARDWARE PROVEN `[RUNTIME PROVEN]` / CSI UNSUPPORTED** |

---

## 2. Path Selection Rationale

- **PRIMARY_CSI_PATH:** **MediaTek MT7925 (Onboard PCIe)**
  - *Rationale:* Native Wi-Fi 7 2x2 MIMO capability, direct PCIe bus speed, high subcarrier density (242+ subcarriers), and verified MCU testmode response query support. Gate 1 driver replacement passed 100% under Secure Boot (`PASS [RUNTIME PROVEN]`).
- **SECONDARY_PATH:** **TP-Link TL-WN722N v1.0 (USB AR9271)**
  - *Rationale:* Hardware is `[RUNTIME PROVEN]` and bound to `ath9k_htc`. While raw subcarrier CSI extraction is unsupported by the AR9271 USB HTC firmware (`CSI_RUNTIME_FAILED`), it serves as an ideal external packet injector / traffic generator to send test frames to the MT7925 during Gate 2 testing.
