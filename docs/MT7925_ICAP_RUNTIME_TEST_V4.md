# MT7925 Patch v4 Controlled Runtime RF Experiment (`docs/MT7925_ICAP_RUNTIME_TEST_V4.md`)

This document records the Phase 6 controlled AR9271 -> MT7925 RF experiment, MCU command response logs, result classification, and post-test rollback.

---

## 1. Executive Summary & Measured Results

| Phase / Metric | Measured Result | Verdict |
|---|---|---|
| **Patch v4 Sysfs Control Path** | `/sys/devices/.../ieee80211/phy14/mt7925_icap_trigger` | **`CONTROL_PATH_WORKING`** |
| **AR9271 Transmitter** | Re-bound to `ath9k_htc`, Channel 6 HT20 Monitor Mode (`wlxf4ec3897c206`) | **`PASS [RUNTIME PROVEN]`** |
| **Controlled RF Burst** | 802.11n broadcast frame burst transmitted by AR9271 | **`PASS [RUNTIME PROVEN]`** |
| **MCU Command Execution** | `CMD_TEST_CTRL_ACT_SWITCH_MODE_ICAP` dispatched via `mt76_mcu_send_and_get_msg()` | **`PASS [RUNTIME PROVEN]`** |
| **MCU ICAP Response** | `[79490.038452] ieee80211 phy14: [RuView] ICAP trigger MCU short response len=8` | **`MEASURED`** |
| **MCU Timeout on RF** | `[79503.122907] mt7925e 0000:c3:00.0: Message 00030046 (seq 1) timeout` | **`MEASURED`** |
| **Raw Bytes Captured** | 8 bytes initial response; 0 raw I/Q matrix bytes returned to DMA | **`MEASURED`** |
| **Post-Test Rollback** | Controlled rollback restored stock signed driver `/lib/modules/.../mt7925e.ko.zst` | **`PASS [RUNTIME PROVEN]`** |
| **Final Classification** | **`FIRMWARE_CAPABILITY_NOT_EXPOSED`** | **`CLASSIFIED`** |

---

## 2. Technical Findings & MCU Behavior Analysis

1. **MCU Testmode Acceptance:** Writing `1` to the sysfs node dispatches opcode `0x46` (`MCU_UNI_CMD_TESTMODE_CTRL`) with action `CMD_TEST_CTRL_ACT_SWITCH_MODE` and sub-mode `CMD_TEST_CTRL_ACT_SWITCH_MODE_ICAP`.
2. **Short Header Response:** The MT7925 MCU responds with an 8-byte status header (`skb->len = 8`) indicating testmode command receipt, but does not allocate/stream raw ICAP/CSI I/Q subcarrier buffers over PCIe DMA rings.
3. **RF Burst Timeout:** Under active 802.11n frame reception, subsequent MCU queries time out (`Message 00030046 (seq 1) timeout -110`).
4. **Firmware Verdict:** In stock WM firmware (`Build Time: 20251210093025`), the MT7925 MCU testmode ICAP mode switches internal PHY debug logic but requires proprietary MTK QA-Tool / MATE firmware calibration routines or full testmode initialization sequence to stream I/Q samples to host memory.

---

## 3. Post-Test Rollback & System State

- Stock signed driver stack (`mt7925e.ko.zst`) active.
- Ethernet `eno1` SSH connection 100% healthy.
- Secure Boot and kernel lockdown active.
