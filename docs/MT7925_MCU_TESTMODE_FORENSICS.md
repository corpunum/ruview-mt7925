# MediaTek MT7925 MCU Testmode Forensics & Protocol Deconstruction (`docs/MT7925_MCU_TESTMODE_FORENSICS.md`)

This document records the exact protocol deconstruction of the 8-byte MT7925 MCU testmode response, the full MCU call chain, struct layouts, and event routing forensics.

---

## 1. Complete Control & MCU Execution Chain

```text
Userspace (echo 1 > /sys/devices/.../mt7925_icap_trigger)
  └─► mt7925_icap_trigger_store()  [init.c / main.c]
        └─► mt76_mcu_send_and_get_msg(&mdev->mt76, MCU_UNI_QUERY(TESTMODE_CTRL), &cmd, sizeof(cmd), true, &skb)
              │
              ├─► Opcode: MCU_UNI_CMD_TESTMODE_CTRL = 0x46
              ├─► MCU TX Descriptor: Option=0x00, EID=0x01 (UNI_CMD), CID=0x46
              ├─► Payload: struct mt7925_rftest_cmd (action=CMD_TEST_CTRL_ACT_SWITCH_MODE [0], op_mode=CMD_TEST_CTRL_ACT_SWITCH_MODE_ICAP [2])
              │
              ▼ [PCIe DMA Ring Outbound to MT7925 MCU]
         MT7925 MCU Hardware / Firmware Execution
              ▲ [PCIe DMA Ring Inbound from MT7925 MCU]
              │
        ┌─────┴───────────────────────────────────────────────────────┐
        │ MT7925 MCU Response RX Descriptor (struct mt7925_mcu_rxd)  │
        │ Total Inbound Frame: 44 bytes                               │
        │   - 32-byte RXD Header (rxd[8])                             │
        │   - 4-byte Control Header (len=44, pkt_type_id=0xe000)      │
        │   - 8-byte MCU UNI Event (struct mt7925_mcu_uni_event)      │
        └─────┬───────────────────────────────────────────────────────┘
              │
        └─► mt7925_mcu_parse_response()  [mcu.c]
              └─► skb_pull(skb, sizeof(struct mt7925_mcu_rxd)) [Strips 44-byte RXD header]
              └─► Remaining skb->data: 8 bytes (struct mt7925_mcu_uni_event)
```

---

## 2. Structural Deconstruction of the 8-Byte Response

The 8 bytes returned in `skb->data` after `skb_pull(skb, sizeof(struct mt7925_mcu_rxd))` map exactly to `struct mt7925_mcu_uni_event`:

| Byte Offset | Struct Member | Data Type | Measured Hex | Decoded Meaning |
|---|---|---|---|---|
| `0x00` | `cid` | `u8` | `0x46` | Command ID ACK (`MCU_UNI_CMD_TESTMODE_CTRL` = `0x46`) |
| `0x01` - `0x03` | `pad[3]` | `u8[3]` | `0x00 0x00 0x00` | Alignment padding |
| `0x04` - `0x07` | `status` | `__le32` | `0x00000000` | `0x00` = `STATUS_SUCCESS` |

### Structural Hex Dump:
```text
00000000: 46 00 00 00 00 00 00 00                          F.......
```

---

## 3. Protocol Forensics Findings & Verdict

1. **NOT an Error or Reject:** The MCU returned `0x00000000` (`STATUS_SUCCESS`), acknowledging that the MCU successfully processed opcode `0x46` and switched internal mode to `CMD_TEST_CTRL_ACT_SWITCH_MODE_ICAP`.
2. **Synchronous Query Return Limit:** `MCU_UNI_QUERY(TESTMODE_CTRL)` is a synchronous control/status RPC call. Its response is designed solely to return an 8-byte `mt7925_mcu_uni_event` status header. It does **NOT** package large I/Q or CSI subcarrier matrices inside the synchronous RPC response packet.
3. **Async Event / DMA Ring Stream Gap:** Raw spectral or ICAP sample buffers in MediaTek hardware are delivered asynchronously either via unsolicited MCU events (`MCU_UNI_UNSOLICITED_EVENT`) or directly to PCIe RX DMA rings via custom RX status descriptors (`RxD`).
4. **Current Status Verdict:** Reclassified from `FIRMWARE_CAPABILITY_NOT_EXPOSED` to **`CURRENT_TESTMODE_QUERY_RETURNS_STATUS_ONLY`**.
