# MediaTek MT7925 Patch v3 Build & Symbol Provenance Analysis (`docs/PATCH_V3_RUNTIME_PROOF.md`)

This document records the empirical investigation, build provenance findings, symbol resolution analysis, and final verdict for exposing the Patch v3 `icap_trigger` DebugFS node on Ubuntu kernel `7.0.0-28-generic`.

---

## 1. Executive Summary & Verdict

| Dimension | Measured Finding | Verdict |
|---|---|---|
| **Target Driver Stack** | MediaTek MT7925 (Wi-Fi 7 PCIe `14c3:0717`) | **`[RUNTIME PROVEN]`** |
| **Tested Kernel** | Ubuntu `7.0.0-28-generic` (Secure Boot Enabled) | **`[RUNTIME PROVEN]`** |
| **Gate 2 Replacement Pipeline** | Unload stock modules, `insmod` MOK-signed out-of-tree modules | **`PASS [RUNTIME PROVEN]`** |
| **Patch v3 Source Instrumentation** | Applied to `mt7925/debugfs.c` (`mt7925_icap_trigger_set`, `fops_icap_trigger`) | **`[SOURCE PROVEN]`** |
| **Static Binary Proof** | `icap_trigger` string & symbols confirmed in `debugfs.o` and `mt7925-common.ko` | **`[STATICALLY VERIFIED]`** |
| **Kernel ABI Symbol Resolution** | Out-of-tree `mt7925-common.ko` missing in-tree kernel symbols `mt792x_get_txpower` & `__mt76_wcid_alloc` | **`[MEASURED]`** |
| **Final Driver State** | **STOCK SIGNED MT7925 DRIVER ACTIVE** (`/lib/modules/.../mt7925e.ko.zst`) | **`PASS [RUNTIME PROVEN]`** |
| **Final Verdict Classification** | **`PATCH_V3_RUNTIME_FAILED`** (Symbol ABI mismatch prevents out-of-tree module load) | **`MEASURED`** |

---

## 2. Technical Findings & Root Cause Analysis

1. **Gate 2 Infrastructure Provenance:** Gate 2 replacement, PKCS#7 MOK signature acceptance under Secure Boot, PCI rebind, and Ethernet/SSH stability are 100% **`[RUNTIME PROVEN]`**.
2. **Patch v3 Code Instrumentation:** Patch v3 was correctly applied to `/tmp/mt76_source/mt7925/debugfs.c`. Static inspection using `strings` confirmed `icap_trigger`, `fops_icap_trigger`, and `CMD_TEST_CTRL_ACT_SWITCH_MODE_ICAP` inside `mt7925-common.ko`.
3. **Kernel ABI Symbol Mismatch:** Upon executing `insmod /var/tmp/mt7925_gate1/mt7925-common.ko`, the kernel rejected insertion with `Unknown symbol mt792x_get_txpower (err -2)` and `Unknown symbol __mt76_wcid_alloc (err -2)`.
4. **Root Cause:** Ubuntu stock kernel `7.0.0-28-generic` exports `mt792x_lib.ko` and `mt76.ko` with specific CRC symbol versions. Out-of-tree compilation of `mt7925-common.ko` without rebuilding the entire in-tree kernel image results in symbol CRC divergence.
5. **Fail-Closed Rollback Execution:** The automated rollback mechanism (`tools/runtime/rollback-mt7925.sh`) disarmed the timer, caught the `insmod` error, and cleanly restored stock signed `mt7925e.ko.zst` in under 1 second. Zero system disruption occurred.

---

## 3. Required Next Engineering Steps

To achieve `PATCH_V3_RUNTIME_PROVEN`:
- Either compile the entire `mt76` stack (`mt76.ko`, `mt76-connac-lib.ko`, `mt792x-lib.ko`, `mt7925-common.ko`, `mt7925e.ko`) in a unified build directory matching Ubuntu `7.0.0-28-generic` kernel headers, OR
- Submit Patch v3 directly to upstream `linux-wireless` for clean kernel build integration.
