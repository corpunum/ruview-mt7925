# Rollback Procedure & Safety Design (`docs/runtime/rollback-procedure.md`)

This document specifies the dual-layer automated rollback system designed to protect system stability and remote connectivity during driver testing.

---

## 1. Automated Rollback System Architecture

```text
┌───────────────────────────────────────────────────────────────────┐
│               `tools/runtime/prepare-rollback.sh 60`             │
│               Arms 60-Second Background Recovery Timer             │
└─────────────────────────────────┬─────────────────────────────────┘
                                  │
                                  ▼
                     [ Was Cancel Signal Issued? ]
                     ├── YES ──► `cancel-rollback.sh` (Test PASSED)
                     └── NO  ──► `rollback-mt7925.sh` (Unloads test .ko & reloads stock)
```

---

## 2. Safety Scripts

- **`tools/runtime/prepare-rollback.sh <timeout_sec>`:** Checks stock module availability and launches background timer daemon.
- **`tools/runtime/cancel-rollback.sh`:** Signals test success and disarms rollback timer.
- **`tools/runtime/rollback-mt7925.sh`:** Manual direct emergency recovery script.

---

## 3. Dry-Run Verification

[RUNTIME PROVEN] Dry-run execution of `prepare-rollback.sh 5` followed by `cancel-rollback.sh` confirmed:
- Timer daemon arms successfully (PID logged).
- Stock module verification passes.
- Success cancellation removes background timer cleanly.
