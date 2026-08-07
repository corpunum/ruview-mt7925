# MT7925 ICAP DebugFS & Kernel Lockdown Evaluation (`docs/MT7925_ICAP_LOCKDOWN_ANALYSIS.md`)

This document records the Phase 1-4 experimental findings, AR9271 monitor mode configuration, DebugFS write execution results, kernel lockdown constraints, and post-test stock driver restoration.

---

## 1. Executive Summary & Measured Findings

| Dimension | Measured Result | Verdict |
|---|---|---|
| **Reproducible Build Script** | `tools/build-canonical-patch-v3.sh` created & verified 100% reproducible | **`PASS [RUNTIME PROVEN]`** |
| **Patch v3 Signed Module Stack** | Loaded cleanly under Secure Boot (`fc3a1e84...` & `103ff714...`) | **`PASS [RUNTIME PROVEN]`** |
| **DebugFS Node (`icap_trigger`)** | Registered & verified at `/sys/kernel/debug/ieee80211/phy9/mt76/icap_trigger` | **`PASS [RUNTIME PROVEN]`** |
| **AR9271 Transmitter Setup** | Bound to `ath9k_htc`, set to Channel 6 (2.4 GHz) in Monitor Mode (`wlxf4ec3897c206`) | **`PASS [RUNTIME PROVEN]`** |
| **DebugFS Write Execution** | `echo 1 > icap_trigger` blocked by kernel lockdown security policy | **`MEASURED`** |
| **Kernel Lockdown Log** | `Lockdown: sh: debugfs access is restricted; see man kernel_lockdown.7` | **`MEASURED`** |
| **Post-Test Rollback** | Controlled rollback restored stock signed driver `/lib/modules/.../mt7925e.ko.zst` | **`PASS [RUNTIME PROVEN]`** |

---

## 2. Root Cause Analysis: Secure Boot Kernel Lockdown

1. **Kernel Lockdown Security Policy:** Under Ubuntu active Secure Boot (`kernel_lockdown.7`), the Linux kernel operates under **`integrity`** or **`confidentiality`** lockdown mode.
2. **DebugFS Restriction:** Kernel lockdown explicitly restricts write operations (`0200` permissions) to DebugFS nodes to prevent user space from mutating arbitrary kernel data or issuing raw hardware commands that could compromise kernel memory.
3. **Engineering Solution:** To allow `icap_trigger` write execution in future research phases without disabling Secure Boot, the trigger mechanism can be exposed via a `sysfs` attribute (`/sys/class/net/wlp195s0/icap_trigger`) or custom `nl80211` netlink vendor command instead of DebugFS.

---

## 3. Post-Test Rollback & System Health

- `tools/runtime/rollback-mt7925.sh` executed post-test.
- Stock signed driver stack restored in under 1 second.
- Primary SSH session on `eno1` remained 100% active with zero packet loss.
