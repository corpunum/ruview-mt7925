# MediaTek MT7925 ICAP Implementation Map (`docs/MT7925_ICAP_IMPLEMENTATION_MAP.md`)

This document presents the Phase 1–5 deep forensic source tracing and component mapping across MediaTek `mt76` drivers (`mt7915`, `mt7996`, `mt7921`, `mt7925`), evaluating whether an ICAP receive path can be constructed from existing source evidence.

---

## 1. Phase 1 — Reference Implementation Trace Matrix

| Required Component | Reference File & Line | Constant / Struct Name | Operational Functionality |
|---|---|---|---|
| **Capture Init** | `mt7915/testmode.c:524` | `struct mt7915_tm_rf_test` | Constructs ATE RF test control structure |
| **SET_AT / RX Filter** | `mt7925/mcu.h:609` | `ENUM_CMD_TEST_CTRL_ACT` (`SET_AT=1`) | Command action enum defined; NO TLV struct in driver |
| **ICAP Mode Switch** | `mt7925/mcu.h:621` | `CMD_TEST_CTRL_ACT_SWITCH_MODE_ICAP` (`2`) | MCU opcode `0x46` submode `2` |
| **Capture Length** | `mt7915/testmode.c:526` | `.icap_len = 120` | Fixed ICAP length parameter in MT7915 ATE struct |
| **DMA Ring Allocation** | `mt76/dma.c:mt76_dma_alloc` | `MT_RXQ_MAIN` / `MT_RXQ_MCU` | Standard DMA rings; no dedicated ICAP ring in mt7925 |
| **MCU Event ID** | `mt76_connac_mcu.h:1053` | `MCU_UNI_EVENT_RESULT = 0x01` | Generic MCU RPC completion ACK event |
| **Event Handler** | `mt7925/mcu.c:570` | `mt7925_mcu_uni_rx_unsolicited_event` | Handles `HIF_CTRL`, `FW_LOG`, `ROC`, `SCAN_DONE`, `COREDUMP` |
| **Sample / IQ Format** | N/A | Undocumented in open mt76 | Closed-source MTK ATE / QA-Tool firmware interface |

---

## 2. Phase 2 — MT7925 Component Classification Matrix

| Component | Source Status | Specific Canonical File / Struct Evidence |
|---|---|---|
| `MCU_UNI_CMD_TESTMODE_CTRL` (`0x46`) | **PRESENT_IDENTICAL** | `mt76_connac_mcu.h:1305` |
| `MCU_UNI_CMD_TESTMODE_RX_STAT` (`0x32`) | **PRESENT_IDENTICAL** | `mt76_connac_mcu.h:1298`, `mt7925/testmode.c:101` |
| `CMD_TEST_CTRL_ACT_SWITCH_MODE_ICAP` | **PRESENT_IDENTICAL** | `mt7925/mcu.h:621` |
| `SET_AT` ATE Parameter TLV | **ABSENT** | Action enum `1` defined in `mcu.h:611`, but zero parameter TLVs exist in `mt7925/` |
| DMA Spectral / ICAP Ring | **ABSENT** | `mt7925` only registers standard RXD Group 3/Group 5 packet rings |
| MCU Unsolicited Spectral Event | **ABSENT** | `mt7925_mcu_uni_rx_unsolicited_event()` drops unhandled event IDs |

---

## 3. Phase 3 — Investigation of `MT7925_TM_WIFISPECTRUM`

- **Location:** Defined in `drivers/net/wireless/mediatek/mt76/mt7925/mcu.h:104`.
- **Status:** **DEAD STRUCT ENUM VALUE**.
- **Source Inspection:** Grepping the entire Linux kernel source tree reveals `MT7925_TM_WIFISPECTRUM` appears **only** inside the `enum` definition in `mt7925/mcu.h:104`. Zero functions, MCU commands, debugfs nodes, or netlink handlers reference `MT7925_TM_WIFISPECTRUM`.
- **Verdict:** `MT7925_TM_WIFISPECTRUM` is a dead header declaration inherited from early MT7921/MT7925 header copies. It does **NOT** expose a usable spectral/IQ path in stock Linux drivers.

---

## 4. Phase 4 — AR9271 Stimulus Validity

- **AR9271 Transmitter Capabilities:** Injects standard 802.11n frames on Channel 6 HT20 (`wlxf4ec3897c206`).
- **MT7925 Ingress Handling:** When MT7925 operates in standard operational mode (`MT_PHY_TYPE_HT`), incoming AR9271 frames correctly trigger PHY P-RXV/C-RXV vector parsing in `mt7925_mac_fill_rx_rate()` (`mac.c:510-536`), populating `chain_signal` RSSI and RCPI (`MT_PRXV_RCPI0-3`).
- **ICAP Mode Stalling:** When MT7925 enters `SWITCH_MODE_ICAP` without host DMA capture ring allocation, inbound AR9271 frames cause MCU control queue timeouts (`-110`), proving that RF input affects internal PHY state, but stock firmware requires host-side DMA ring consumers to drain captured buffers.

---

## 5. Critical Decision Declaration

Based on exhaustive source evidence tracing across Canonical `mt76` source tree:

### **DECISION: C — FIRMWARE BLOCKED / PARTIALLY IMPLEMENTABLE**

- **Justification:** While control opcodes `MCU_UNI_CMD_TESTMODE_CTRL` (`0x46`) and `MCU_UNI_CMD_TESTMODE_RX_STAT` (`0x32`) exist in canonical `mt76` headers, stock MT7925 WM firmware (`Build Time: 20251210093025`) and Linux driver stubs lack the required `SET_AT` ATE TLV definitions, DMA capture ring structures, and MCU unsolicited event parsers to extract raw OFDM CSI matrices without proprietary MediaTek QA-Tool (MATE) calibration binaries.
