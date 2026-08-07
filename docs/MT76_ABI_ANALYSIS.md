# MediaTek MT76 Kernel Symbol ABI & Dependency Analysis (`docs/MT76_ABI_ANALYSIS.md`)

This document records the Phase 1 ABI forensics, kernel module dependency tree, symbol CRC verification results, and root cause diagnosis for building out-of-tree MT7925 modules on Ubuntu `7.0.0-28-generic`.

---

## 1. System Metrics & Kernel Module Configuration

- **Running Kernel:** `Linux corpunumRig 7.0.0-28-generic #28~24.04.1-Ubuntu SMP PREEMPT_DYNAMIC`
- **Module Signing Configuration:**
  - `CONFIG_MODVERSIONS=y`
  - `CONFIG_MODULE_SIG=y`
  - `CONFIG_MODULE_SIG_ALL=y`
  - `CONFIG_MODULE_SIG_HASH="sha512"`
- **Enrolled MOK Key:** `CN=corpunumRig Secure Boot Module Signature key` (verified in `.secondary` keyring `86:AE`)

---

## 2. Mandatory Module Dependency Tree

The in-tree kernel module dependency graph for `mt7925e` on Ubuntu `7.0.0-28-generic` is strictly established via `modprobe --show-depends`:

```text
cfg80211.ko.zst (Ubuntu Stock)
  └─► mac80211.ko.zst (Ubuntu Stock)
        └─► mt76.ko.zst (Base driver)
              └─► mt76-connac-lib.ko.zst (Mediatek Connac Common API)
                    └─► mt792x-lib.ko.zst (MT792x Family Common API)
                          └─► mt7925-common.ko.zst (MT7925 Common Layer)
                                └─► mt7925e.ko.zst (MT7925 PCIe Driver)
```

---

## 3. ABI Forensics & Symbol CRC Mismatch Analysis

1. **Original Failure Symptom:** Runtime insertion of experimental `mt7925-common.ko` failed with `Unknown symbol mt792x_get_txpower (err -2)` and `Unknown symbol __mt76_wcid_alloc (err -2)`.
2. **Root Cause:** When building upstream `openwrt/mt76` out-of-tree against Ubuntu kernel headers without rebuilding the underlying `mt76.ko` and `mt792x-lib.ko` base modules, the compiler generates symbol CRC checksums that diverge from the stock Ubuntu kernel's in-tree `Module.symvers`.
3. **Internal Symbol Resolution Requirement:** Because `mt7925-common.ko` calls exported functions from both `mt76.ko` and `mt792x-lib.ko`, all 5 modules in the MediaTek wireless stack (`mt76`, `mt76-connac-lib`, `mt792x-lib`, `mt7925-common`, `mt7925e`) must be compiled together from a unified source tree matching the exact Ubuntu kernel header version (`linux-hwe-7.0-headers-7.0.0-28`).

---

## 4. Phase 2 & 3 Build Strategy Verdict

- **Strategy Selection:** **`PATCH_V3_RUNTIME_FAILED`** (Static ABI validation halted runtime insertion).
- **Justification:** Building upstream `openwrt/mt76` out-of-tree introduces symbol CRC mismatches against Ubuntu stock `mt792x-lib.ko`. Replacing all 5 in-tree `mt76` modules simultaneously risks instability if symbol definitions differ from Ubuntu's distro-patched `mac80211`.
- **Primary Technical Recommendation:** To achieve `PATCH_V3_RUNTIME_PROVEN`, apply Patch v3 directly into Ubuntu's canonical kernel package source (`linux-hwe-7.0-headers-7.0.0-28`) and build a fully aligned module set with zero symbol CRC drift.
