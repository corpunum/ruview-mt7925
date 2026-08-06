# Evidence Consolidation Summary

This document summarizes the evidence consolidation performed for PR #9 and supports repository bootstrap issue #1.

## Consolidations & Classifications

### 1. Runtime-Proven Facts (`[RUNTIME PROVEN]`)
- Hardware ID: MediaTek MT7925 PCIe (`14c3:0717`).
- Kernel: Ubuntu `7.0.0-28-generic` with Secure Boot and lockdown active.
- Monitor Mode Coexistence: `mon0` (Monitor mode) and `wlp195s0` (Managed mode) coexisted UP on `phy#0` with zero disruption to active SSH session.
- Netlink Command Rejection: `iw dev mon0 vendor send` returned exit code 161 (`-95 EOPNOTSUPP`) because `CONFIG_NL80211_TESTMODE` is disabled in stock kernel config.
- Operational Telemetry Capture: eBPF (`bpftrace`) on `kprobe:mt76_mcu_rx_event` captured 52-byte RSSI telemetry frames.

### 2. Source-Proven Facts (`[SOURCE PROVEN]`)
Refer to [`docs/source-provenance.md`](../source-provenance.md) for full commit, file, function, and line range details:
- **SP-001:** `MCU_UNI_CMD_TESTMODE_CTRL` (`0x46`) defined in `mt76_connac_mcu.h:1351`.
- **SP-002:** `mt7925_tm_query()` in `mt7925/testmode.c:86-119` copies 512 bytes (`MT7925_EVT_RSP_LEN`) from `skb->data + 8`.
- **SP-003:** Unhandled unsolicited MCU event IDs fall through to `default:` in `mt7925_mcu_uni_rx_unsolicited_event()` in `mt7925/mcu.c:655-700` and are freed via `dev_kfree_skb(skb)`.

### 3. Superseded & Rejected Claims (`[REJECTED]`)
- **CSI Extraction Solved:** REJECTED. Measured ICAP payload size remains zero bytes.
- **512-Byte Response Captured:** REJECTED. No 512-byte response has been captured at runtime.
- **120 Complex Subcarriers Proven:** REJECTED. Payload layout remains an unverified hypothesis.

### 4. Excluded Files
- Compiled kernel binary objects (`/tmp/build_mt7925/*.ko`) excluded per `.gitignore`.
- Raw un-sanitized log dumps excluded.
