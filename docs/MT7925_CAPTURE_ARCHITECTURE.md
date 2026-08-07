# MediaTek Wi-Fi Capture Architecture & Cross-Generation Comparison (`docs/MT7925_CAPTURE_ARCHITECTURE.md`)

This document compares MediaTek Wi-Fi chip architectures (`MT7925`, `MT7921`, `MT7915`, `MT7996`), mapping testmode, spectral scan, and ICAP data paths across Linux `mt76` drivers.

---

## 1. Cross-Generation MediaTek Capture Architecture Matrix

| Architecture Metric | MediaTek MT7915 (Filogic 830) | MediaTek MT7996 (Filogic 880 Wi-Fi 7) | MediaTek MT7921 (Wi-Fi 6 PCIe) | MediaTek MT7925 (Wi-Fi 7 PCIe) |
|---|---|---|---|---|
| **Driver Location** | `drivers/net/wireless/mediatek/mt76/mt7915` | `drivers/net/wireless/mediatek/mt76/mt7996` | `drivers/net/wireless/mediatek/mt76/mt7921` | `drivers/net/wireless/mediatek/mt76/mt7925` |
| **NL80211 Testmode Support** | Full (`mt7915_testmode_ops`) | Full (`mt7996_testmode_ops`) | Partial (`mt7921_testmode_cmd`) | Partial (`mt7925_testmode_cmd`) |
| **Testmode State Management** | `MT76_TM_STATE_ON` / `OFF` | `MT76_TM_STATE_ON` / `OFF` | `MT76_TM_STATE_ON` / `OFF` | `MT76_TM_STATE_ON` / `OFF` |
| **Spectral Scan Support** | Yes (`mt7915_phy_spectral_scan`) | Yes (`mt7996_phy_spectral_scan`) | No (Disabled in FW) | No (Disabled in FW) |
| **ICAP Command Opcode** | `MCU_UNI_CMD_TESTMODE_CTRL` (`0x46`) | `MCU_UNI_CMD_TESTMODE_CTRL` (`0x46`) | `MCU_UNI_CMD_TESTMODE_CTRL` (`0x46`) | `MCU_UNI_CMD_TESTMODE_CTRL` (`0x46`) |
| **Capture Trigger Path** | `mt76_testmode_cmd` -> ATE set | `mt76_testmode_cmd` -> ATE set | `mt7921_tm_set()` | `mt7925_tm_set()` |
| **Data Return Path** | Asynchronous DMA RX Ring + DebugFS / relay | Asynchronous DMA RX Ring + DebugFS / relay | Synchronous status query | Synchronous status query |
| **Required Pre-Trigger** | `testmode_en = 1` + RX filter config | `testmode_en = 1` + RX filter config | `pm.enable = false` | `pm.enable = false` + `testmode_en = 1` |

---

## 2. MediaTek Testmode Capture Sequence Architecture

In full MediaTek ATE / QA-Tool implementations (such as MT7915/MT7996), capture requires a strict 5-stage state machine sequence:

```text
Stage 1: Enter Testmode
  └─► Command: MCU_UNI_CMD_TESTMODE_CTRL (action = SWITCH_MODE_RF_TEST or SWITCH_MODE_ICAP)
  └─► Driver State: Set mphy->test.state = MT76_TM_STATE_ON
  └─► Power State: Disable Power Save (dev->pm.enable = false)

Stage 2: Configure RF & RX Filter
  └─► Command: MCU_UNI_CMD_TESTMODE_CTRL (action = SET_AT / SET_PARAM)
  └─► Parameters: Channel, Bandwidth, Antenna Index, RX Filter (Promiscuous / Monitor)

Stage 3: Arm ICAP Capture
  └─► Command: MCU_UNI_CMD_TESTMODE_CTRL (action = SWITCH_MODE_ICAP)
  └─► Allocation: Allocate DMA RX Ring buffers or RAM capture trace memory

Stage 4: Trigger Capture & Receive Async Event
  └─► Action: Write trigger opcode or receive target RF packet
  └─► Event: MCU emits async event or streams I/Q samples to PCIe DMA RX Ring

Stage 5: Query / Read Capture Buffer
  └─► Command: MCU_UNI_QUERY(TESTMODE_RX_STAT) or read relay / sysfs buffer
```

---

## 3. Applicability to MT7925

- **Missing Stage 2 (RX Filter Configuration):** Patch v4 executed Stage 1 & Stage 3 directly without issuing Stage 2 (RX Filter & ATE parameter configuration).
- **Missing Stage 4 (Async Event Parser):** `mt7925_mcu_uni_rx_unsolicited_event()` in `mcu.c` currently drops unhandled event IDs.
- **Architectural Relative:** MT7915 (`drivers/net/wireless/mediatek/mt76/mt7915/testmode.c`) provides the closest complete open-source reference for MediaTek MCU testmode RX filter and capture state machine control.
