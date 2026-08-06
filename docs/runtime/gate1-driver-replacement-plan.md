# Gate 1 Driver Replacement Execution Plan (`docs/runtime/gate1-driver-replacement-plan.md`)

This document defines the strict fail-closed execution plan for Gate 1 driver replacement testing.

---

## 1. Gate 1 Purpose & Boundaries

- **Purpose:** Test unloading stock MT7925 drivers, loading signed Patch v3 modules, binding the PCI adapter (`14c3:0717`), maintaining Ethernet SSH connectivity, and restoring stock modules cleanly.
- **Strict Boundary:** **NO ICAP COMMANDS ARE DISPATCHED IN GATE 1.**

---

## 2. Execution Parameters & Commands

- **Safe Default Command (Preflight Only):**
  ```bash
  sudo bash tools/runtime/gate1-driver-replacement.sh --preflight
  ```
- **Explicit Execution Command (Requires User Approval):**
  ```bash
  sudo bash tools/runtime/gate1-driver-replacement.sh --execute-gate1
  ```

---

## 3. Rollback & Fail-Closed Strategy

- The automated recovery timer (`prepare-rollback.sh 60`) MUST arm successfully before any module unload/load step begins.
- If preflight checks fail, the script exits immediately without altering driver state.
