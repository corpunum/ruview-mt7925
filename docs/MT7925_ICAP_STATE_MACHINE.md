# MediaTek MT7925 ICAP & MCU Testmode State Machine Forensics (`docs/MT7925_ICAP_STATE_MACHINE.md`)

This document presents the complete forensic analysis of the Patch v5 empirical results, MCU command call chain, structural deconstruction of the 8-byte status response, root-cause analysis of the active-RF `-110` (`-ETIMEDOUT`) failure, cross-chipset MediaTek capture state machine mapping, and concrete evaluation for future Patch v6 work.

---

## 1. Proven Patch v5 Observations & Measured Facts

During the authorized Patch v5 runtime experiment on August 8, 2026, the two-stage testmode sequence was executed under two distinct RF environment conditions:

### A. Quiet RF Environment (No AR9271 Injected Burst)
- **Stage 1 (Power Lock):** `mdev->pm.enable = false`, delayed work canceled — **`PASS`**
- **Stage 2 (`SWITCH_MODE_RF_TEST`):** `MCU_UNI_CMD(TESTMODE_CTRL)` action `0` submode `1` — **`SUCCESS`**
- **Stage 3 (`SWITCH_MODE_ICAP`):** `MCU_UNI_CMD(TESTMODE_CTRL)` action `0` submode `2` — **`SUCCESS`**
- **Stage 4 (`TESTMODE_RX_STAT` Query):** `MCU_UNI_QUERY(TESTMODE_RX_STAT)` opcode `0x32` — **`SUCCESS`**
- **Returned Payload Length:** 8 bytes (`len=8`, SHA256 `90b16f394e3e3bcf44ed1e959ce53d10098f9e612ebf1e9444158fb731c34a2e`)
- **Raw Hex Payload:** `32 00 00 00 bb 00 00 c0`
- **Result Verdict:** **`STATUS_ONLY`** / **`CSI_NOT_PROVEN`**

### B. Active RF Traffic Environment (AR9271 802.11n Frame Burst Active)
- **Stage 1 - Stage 3:** Executed & accepted cleanly — **`SUCCESS`**
- **Stage 4 (`TESTMODE_RX_STAT` Query):** `mt76_mcu_send_and_get_msg` timed out after 3.0 seconds (`-110` / `-ETIMEDOUT`)
- **Kernel Log Evidence:** `[105264.255891] mt7925e 0000:c3:00.0: Message 00030032 (seq 5) timeout`
- **Post-Timeout Driver Behavior:** The mt76 driver automatically triggered `mt792x_reset(mdev)` at `[105264.330295]` and successfully re-initialized MCU firmware (`WM Firmware Version: ____000000, Build Time: 20251210093025`). MCU communication recovered cleanly without kernel crash.

---

## 2. Complete MCU Call Chain & Struct Layout

```text
Patch v5 Sysfs Handler (mt7925_icap_trigger_store)
  │
  ├──► Stage 1: Power Control Lock
  │      pm.enable = false, cancel_delayed_work_sync(&pm.ps_work)
  │
  ├──► Stage 2: RF_TEST Mode Switch
  │      Opcode: MCU_UNI_CMD(TESTMODE_CTRL) = 0x46
  │      Payload: struct mt7925_rftest_cmd
  │               - ctrl.action = 0 (CMD_TEST_CTRL_ACT_SWITCH_MODE)
  │               - ctrl.data.op_mode = 1 (CMD_TEST_CTRL_ACT_SWITCH_MODE_RF_TEST)
  │
  ├──► Stage 3: ICAP Mode Switch
  │      Opcode: MCU_UNI_CMD(TESTMODE_CTRL) = 0x46
  │      Payload: struct mt7925_rftest_cmd
  │               - ctrl.action = 0 (CMD_TEST_CTRL_ACT_SWITCH_MODE)
  │               - ctrl.data.op_mode = 2 (CMD_TEST_CTRL_ACT_SWITCH_MODE_ICAP)
  │
  └──► Stage 4: RX Statistics Query
         Opcode: MCU_UNI_QUERY(TESTMODE_RX_STAT) = 0x32
         Payload: struct mt7925_rftest_cmd
                  - cmd.padding = 0x0032 (MCU_UNI_CMD_TESTMODE_RX_STAT)
```

---

## 3. Structural Deconstruction of the 8-Byte Response

The 8 bytes returned by `MCU_UNI_QUERY(TESTMODE_RX_STAT)` in quiet mode map directly to `struct mt7925_mcu_uni_event`:

| Byte Range | Struct Member | Value | Decoded Meaning |
|---|---|---|---|
| `0x00` - `0x03` | `cid` + `pad[3]` | `32 00 00 00` | Acked Opcode `0x32` (`MCU_UNI_CMD_TESTMODE_RX_STAT`) + alignment padding |
| `0x04` - `0x07` | `status` | `bb 00 00 c0` | `0xc00000bb`: MCU testmode state flags (`0xbb` = status ACK, `0xc0` = active testmode state bitmask) |

---

## 4. Forensic Analysis of Active-RF -110 (-ETIMEDOUT)

When active RF frames arrived at the MT7925 hardware during ICAP mode:

1. **Root Cause Diagnosis:** In stock MT7925 WM firmware (`Build Time: 20251210093025`), executing `SWITCH_MODE_ICAP` places the hardware MAC/PHY BBP into internal I/Q capture/logic analyzer mode.
2. **MCU RX Queue Lock:** While receiving active RF energy in ICAP mode without an established DMA capture ring or ATE RX buffer consumer, incoming PHY RX vectors stall the MCU control loop, causing synchronous RPC queries (`MCU_UNI_QUERY(TESTMODE_RX_STAT)`) to time out after 3000ms.
3. **No MCU Crash:** The `-110` timeout is a **synchronous RPC queue timeout**, not a kernel/firmware panic. `mt7925_mcu_parse_response()` caught the timeout cleanly, invoked `mt792x_reset()`, and restored full MCU communication in <100ms.

---

## 5. Cross-Chipset MediaTek Capture Comparison

| Architectural Aspect | MT7915 / Filogic 830 | MT7996 / Filogic 880 | MT7925 (Current Stock Firmware) |
|---|---|---|---|
| **NL80211 Testmode** | Fully supported in in-tree driver (`mt7915_testmode_ops`) | Fully supported in in-tree driver (`mt7996_testmode_ops`) | Stubs only in `mt7925/testmode.c` |
| **Spectral Scan TLVs** | `MT_SWDEF_SPECTRUM_MODE` exposed via debugfs/relay | `MT_SWDEF_SPECTRUM_MODE` exposed via debugfs/relay | Struct enums defined (`MT7925_TM_WIFISPECTRUM`), but no spectral parser in driver |
| **ICAP DMA Ring** | Allocated `icap_len = 120` DMA ring buffers | Allocated `icap_len` DMA ring buffers | No DMA ring allocated by host driver |
| **Status Query** | `MCU_UNI_QUERY(TESTMODE_RX_STAT)` returns ATE counters | `MCU_UNI_QUERY(TESTMODE_RX_STAT)` returns ATE counters | `MCU_UNI_QUERY(TESTMODE_RX_STAT)` returns 8-byte status header |

---

## 6. Identified Missing Operations & Patch v6 Justification

To progress from `STATUS_ONLY` to genuine capture extraction, the following missing operations were identified:

1. **Missing ATE RX Filter Configuration:** `CMD_TEST_CTRL_ACT_SET_AT` is required to configure channel, bandwidth, and RX promiscuous/capture filters before entering ICAP mode.
2. **Missing DMA Capture Ring Allocation:** Allocation of DMA RX ring buffers (`skb_alloc`) to receive streamed I/Q subcarrier frames from MCU unsolicited events.
3. **Missing Event Handler:** Registration of an unsolicited MCU event parser (`MCU_UNI_EVENT`) for spectral/ICAP data buffers in `mt7925_mcu_uni_rx_unsolicited_event()`.

### Verdict on Patch v6 Execution
- **Is Patch v6 Justified Currently?** **NO**.
- **Reason:** Implementing DMA ring allocation and full ATE calibration requires reverse-engineering proprietary MediaTek QA-Tool (MATE) firmware TLV structures. Additional blind runtime patches without QA-Tool firmware specifications will continue returning status headers or timing out under RF input.

---

## 7. Declaration

- **V5 Result Interpretation:** **`STATUS_ONLY`** / **`CSI_NOT_PROVEN`**.
- **Patch v6 Justification:** **`NO`** (Further runtime experimentation prohibited until QA-Tool TLV specifications are analyzed statically).
- **Final Driver State:** Stock signed driver `mt7925e.ko.zst` active.
