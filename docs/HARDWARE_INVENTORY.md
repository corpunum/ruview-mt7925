# Hardware Inventory & Electronic Discovery Audit (`docs/HARDWARE_INVENTORY.md`)

This document records the electronic discovery, network enumeration, and hardware status of all physical and PCI/USB-attached Wi-Fi sensing devices.

---

## 1. Physical & Bus Hardware Inventory

| Hardware Target | System Interface | Bus / Connection | Chipset / SoC | Hardware Revision | CSI Extraction Mechanism | Operational Status | Runtime Tested? | Next Recommended Action |
|---|---|---|---|---|---|---|---|---|
| **MediaTek MT7925** | `wlp195s0` / `mon0` | Onboard PCIe (`14c3:0717`) | MediaTek MT7925 | Production PCIe silicon | MCU `TESTMODE_CTRL` / DebugFS (`icap_trigger`) | **GATE1 = PASS [RUNTIME PROVEN]** / **GATE2 = READY** | **YES `[RUNTIME PROVEN]`** | Await explicit user authorization to execute Gate 2. |
| **TP-Link TL-WN722N** | `wlxf4ec3897c206` | USB 2.0 (`0cf3:9271`) | Qualcomm Atheros AR9271 | **v1.0 / v1.1 `[RUNTIME PROVEN]`** | Open-source FW (`open-ath9k-htc-firmware`) | **HARDWARE DISCOVERED `[RUNTIME PROVEN]`** | **YES `[BOUND]`** | Maintain as Secondary Reference Target; isolate via sysfs unbind during MT7925 Gate 2. |
| **TP-Link TL-WDR3600** | `eno1` / LAN | Ethernet / Wireless | Atheros AR9344 + AR9580 | **DEFERRED `[OUT OF CURRENT SCOPE]`** | Atheros CSI Tool (`ar9003_csi.ko`) | **DEFERRED** | **NO `[DEFERRED]`** | Retain historical documentation only; suspended from active research. |

---

## 2. Hardware Identification Proofs

### MediaTek MT7925 (Primary Onboard Target)
- **PCI ID:** `14c3:0717` `[RUNTIME PROVEN]`
- **Driver:** `mt7925e` (Ubuntu `7.0.0-28-generic` stock signed driver active). `[RUNTIME PROVEN]`

### TP-Link TL-WN722N (Secondary USB Target)
- **USB VID:PID:** `0cf3:9271` `[RUNTIME PROVEN]`
- **Driver:** `ath9k_htc` (Firmware `ath9k_htc/htc_9271-1.4.0.fw` loaded). `[RUNTIME PROVEN]`
- **Revision Proof:** VID `0cf3` PID `9271` conclusively proves TL-WN722N v1.0/v1.1 (Atheros AR9271). Realtek-based v2/v3 use VID `0bda`. Physical sticker inspection is not required. `[RUNTIME PROVEN]`
