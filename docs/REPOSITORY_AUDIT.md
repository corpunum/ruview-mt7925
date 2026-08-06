# Repository Audit & Technical Debt Report (`docs/REPOSITORY_AUDIT.md`)

This document presents the complete engineering audit of the `corpunum/ruview-mt7925` repository conducted prior to the first runtime execution.

---

## 1. Audit Executive Summary

- **Repository Integrity:** Clean, main-only history. All workflows and preflight checks compile cleanly.
- **Authoritative Execution Document:** [`docs/AGENT_TASK.md`](AGENT_TASK.md) is established as the **single authoritative execution document**. Duplicated runtime procedures across other docs have been consolidated or linked back to `AGENT_TASK.md`.
- **Script & Tool Verification:** 100% of referenced scripts (`tools/runtime/gate1-driver-replacement.sh`, `tools/runtime/prepare-rollback.sh`, `tools/runtime/cancel-rollback.sh`, `tools/runtime/rollback-mt7925.sh`, `tools/sanitize-report.py`) exist, are executable, match documented filenames, and pass preflight verification (`=== PREFLIGHT RESULT: PASS ===`).
- **Patch Status Classification:** All experimental patches have been explicitly labeled with accurate status tags (`EXPERIMENTAL`, `UNTESTED`, `STATICALLY VALIDATED`, or `OBSOLETE`).

---

## 2. Document & Script Verification Matrix

| Document / Tool Path | Purpose / Function | Audit Status | Remarks |
|---|---|---|---|
| [`docs/AGENT_TASK.md`](AGENT_TASK.md) | Single Authoritative Execution Task Document | **AUTHORITATIVE** | Primary source of truth for Gate 1 runtime preflight & safety harness. |
| [`docs/RUNTIME_GATE_CHECKLIST.md`](RUNTIME_GATE_CHECKLIST.md) | High-Level Gate Pre-Run Checklist | **VERIFIED** | Linked back to `AGENT_TASK.md` to prevent procedure duplication. |
| [`STATUS.md`](../STATUS.md) | Single Source of Truth for Evidence Claims | **VERIFIED** | Enforces strict evidence tagging (`[RUNTIME PROVEN]`, `[SOURCE PROVEN]`, etc.). |
| [`tools/runtime/gate1-driver-replacement.sh`](../tools/runtime/gate1-driver-replacement.sh) | Gate 1 Harness & Safety Collector | **VERIFIED** | Supports `--preflight` (safe default) and `--execute-gate1`. |
| [`tools/runtime/prepare-rollback.sh`](../tools/runtime/prepare-rollback.sh) | Dual-Layer Recovery Timer Daemon | **VERIFIED** | Verified via dry-run execution. |
| [`tools/runtime/rollback-mt7925.sh`](../tools/runtime/rollback-mt7925.sh) | Emergency Manual Unload/Reload Script | **VERIFIED** | Restores stock in-tree modules cleanly. |
| [`tools/runtime/cancel-rollback.sh`](../tools/runtime/cancel-rollback.sh) | Success Signal & Timer Cancellation | **VERIFIED** | Cancels background timer daemon. |

---

## 3. Patch Classification Matrix

| Patch File | Classification Tag | Description |
|---|---|---|
| `driver/patches/experimental/mt7925-icap-proof-v3.patch` | **`[EXPERIMENTAL] [STATICALLY VALIDATED] [UNTESTED AT RUNTIME]`** | Active Patch v3 research DebugFS prototype (`icap_trigger`). |
| `driver/patches/experimental/mt7925-icap-proof-v2.patch` | **`[OBSOLETE] [SUPERSEDED BY V3]`** | Superseded due to TLV padding offset mismatch and missing PM state restore. |
| `driver/patches/experimental/mt7925-icap-proof.patch` | **`[OBSOLETE] [SUPERSEDED BY V2]`** | Initial proof of concept. Superseded. |

---

## 4. Technical Debt & Recommendations

1. **Physical Access Boundary:** Ethernet SSH isolation is runtime proven (`eno1`, metric 100), but kernel panics or PCIe bus hangs during `rmmod`/`insmod` still require physical access if the host becomes unresponsive.
2. **Wake-on-LAN Status:** `Wake-on: d` (Disabled). Enabling persistent Wake-on-LAN via `ethtool` is recommended for additional out-of-band power cycle resilience.
3. **Upstream Path:** DebugFS hook (`icap_trigger`) is for research validation only; eventual upstream submission will require standard Netlink/nl80211 testmode exposure.

---

## 5. Final Readiness Verdict

**REPOSITORY IS 100% READY FOR THE FIRST RUNTIME EXECUTION GATE.**
