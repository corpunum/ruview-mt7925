# Hostile Code Audit: Experimental Patch v2

Hostile code review of historical out-of-tree patch draft `driver/patches/experimental/mt7925-icap-proof-v2.patch`.

## Defect Findings Catalog

### Finding 1: Structure Type Mismatch (`mt7925_tm_cmd` vs `mt7925_rftest_cmd`)
- **Severity:** HIGH (Compilation / Memory Corruption)
- **Hunk:** `mt7925_tm_set()` handling
- **Evidence:** `mt7925_tm_cmd` prepends a 4-byte padding header (`u8 padding[4]`) before `struct uni_cmd_testmode_ctrl`. Directly performing `memcpy(pcmd, req, sizeof(struct mt7925_tm_cmd))` shifts the TLV payload by 4 bytes, causing the MCU to parse invalid action opcodes.
- **Required Correction:** Cast and offset payload explicitly: `memcpy(pcmd + 4, &req->c, sizeof(struct uni_cmd_testmode_ctrl))`.

### Finding 2: Unchecked SKB Length on Response Copy
- **Severity:** MEDIUM (Kernel Memory Read Leak)
- **Hunk:** `mt7925_tm_query()` return handling
- **Evidence:** If the returned `skb` is shorter than `MT7925_EVT_RSP_LEN + 8` (520 bytes), reading `skb->data + 8` reads uninitialized kernel heap memory.
- **Required Correction:** Explicitly validate `if (skb->len < MT7925_EVT_RSP_LEN + 8) return -EINVAL;`.

### Finding 3: Missing Power-Management Restore on Error Path
- **Severity:** MEDIUM (Device Hang / Power State Lock)
- **Hunk:** `mt7925_tm_set()` error return
- **Evidence:** Setting `testmode = true` clears `pm->enable = false`. If `mt76_mcu_send_msg()` fails, the driver exits without re-enabling `pm->enable = true`, leaving radio power management permanently disabled.
- **Required Correction:** Add error cleanup handler (`out:`) to restore `pm->enable = true` when command dispatch fails.

### Finding 4: Unbounded DebugFS Read Pointer
- **Severity:** LOW (Infinite Loop in Userspace Read)
- **Hunk:** DebugFS `read` callback
- **Evidence:** Omitting `*ppos` increment in simple read handlers causes `cat /sys/kernel/debug/...` to read in an infinite loop.
- **Required Correction:** Use `simple_read_from_buffer()` with explicit byte counting.
