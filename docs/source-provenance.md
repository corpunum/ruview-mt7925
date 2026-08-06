# Source Provenance Record

This document records the exact upstream repository, commit SHA, file paths, functions, and line ranges for all `[SOURCE PROVEN]` claims in this repository.

## Upstream Repository Baseline

- **Repository:** [`https://github.com/openwrt/mt76`](https://github.com/openwrt/mt76) (or upstream Linux kernel `drivers/net/wireless/mediatek/mt76/`)
- **Pinned Commit SHA:** `b2704cf5a4068b672bf47ad5bf6b4802b6770a90`
- **Verification Date:** 2026-08-06

---

## Source Provenance Table

| Claim ID | Evidence Tag | Upstream Repository | Commit SHA | File Path | Function / Symbol | Line Range | Verified Date |
|---|---|---|---|---|---|---|---|
| **SP-001** | `[SOURCE PROVEN]` | `openwrt/mt76` | `b2704cf5a4068b672bf47ad5bf6b4802b6770a90` | `mt76_connac_mcu.h` | `MCU_UNI_CMD_TESTMODE_CTRL` | L1351 | 2026-08-06 |
| **SP-002** | `[SOURCE PROVEN]` | `openwrt/mt76` | `b2704cf5a4068b672bf47ad5bf6b4802b6770a90` | `mt7925/testmode.c` | `mt7925_tm_query()` | L86–L119 | 2026-08-06 |
| **SP-003** | `[SOURCE PROVEN]` | `openwrt/mt76` | `b2704cf5a4068b672bf47ad5bf6b4802b6770a90` | `mt7925/mcu.c` | `mt7925_mcu_uni_rx_unsolicited_event()` | L655–L700 | 2026-08-06 |

---

## Detailed Source Audit Rationale

### SP-001: MCU Testmode Control Opcode (`MCU_UNI_CMD_TESTMODE_CTRL = 0x46`)
- **File:** `mt76_connac_mcu.h` (Line 1351)
- **Source Verification:** Enum `MCU_UNI_CMD_TESTMODE_CTRL` is defined with explicit hex value `0x46`.
- **Driver Usage:** In `mt7925/mcu.c:3693` and `mt7925/testmode.c:99`, this opcode is passed to identify testmode control commands.

### SP-002: Fixed-Size Synchronous Query Response Copying (`mt7925_tm_query`)
- **File:** `mt7925/testmode.c` (Lines 86–119)
- **Source Verification:** `mt7925_tm_query()` dispatches `MCU_UNI_QUERY(TESTMODE_CTRL)` via `mt76_mcu_send_and_get_msg()`. If `skb->len >= MT7925_EVT_RSP_LEN + 8` (where `#define MT7925_EVT_RSP_LEN 512`), it executes `memcpy((char *)evt_resp, (char *)skb->data + 8, MT7925_EVT_RSP_LEN)`.
- **Scope Limit:** Proven in driver source that a 512-byte response buffer is copied from `skb->data + 8`. **It is NOT proven by source alone that this buffer contains subcarrier CSI data.**

### SP-003: Unhandled Unsolicited MCU Event Discard Behavior
- **File:** `mt7925/mcu.c` (Lines 655–700)
- **Source Verification:** `mt7925_mcu_uni_rx_unsolicited_event()` inspects `rxd->eid` in a `switch` statement. Recognized events (`SCAN_DONE`, `TX_DONE`, `RSSI_MONITOR`, etc.) call specific event handlers. The `default:` branch is empty and falls through to `dev_kfree_skb(skb)`.
- **Scope Limit:** Proves unhandled unsolicited event IDs are freed by default.
