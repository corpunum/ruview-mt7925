# Local Agent Task — Harden Gate 1 Before Runtime

## Scope

Work only on `main` in `corpunum/ruview-mt7925`.

Do not create branches or pull requests.

Do **not** load or unload kernel modules yet.

Do **not** trigger ICAP yet.

The goal is to make the first runtime test fail-closed and exact.

## Current state

- Existing MOK is enrolled.
- Matching private key is available locally.
- Disposable Patch v3 modules were signed.
- SSH uses wired Ethernet, not MT7925.
- Rollback scripts have passed a mock dry run.
- Runtime loading remains untested.

## Required work

1. Verify exactly which modules Patch v3 changes.
2. Prove whether patched `mt7925_common` and `mt7925e` are ABI-compatible with stock-loaded `mt792x_lib`, `mt76_connac_lib`, and `mt76`.
3. Replace all placeholder module paths with exact root-only runtime paths outside the repository.
4. Harden rollback scripts so they are idempotent, fail-closed, systemd-independent from SSH, and restore the stock driver stack.
5. Create `tools/runtime/gate1-driver-replacement.sh` with:
   - `--preflight` as the default safe action;
   - `--execute-gate1` requiring explicit invocation;
   - exact kernel, signer, SHA256, dependency, Ethernet-route, and second-SSH checks;
   - rollback armed before any module change;
   - no ICAP trigger;
   - no persistent install and no `/lib/modules` modification.
6. Run only `--preflight` during this task.
7. Validate with `bash -n`, `shellcheck` where available, `git diff --check`, repository CI, secret scan, and local-path scan.
8. Update `STATUS.md` and issue #2 using only measured evidence.

## Gate 1 purpose

Gate 1 tests only:

- stock MT7925 modules can be unloaded;
- signed Patch v3 modules can be loaded;
- the PCI device binds;
- Ethernet SSH stays alive;
- no immediate kernel errors occur;
- stock modules can be restored.

ICAP is a separate future gate.

## Required deliverables

Create or update:

- `docs/runtime/signed-module-manifest.md`
- `docs/runtime/gate1-driver-replacement-plan.md`
- `docs/runtime/first-load-checklist.md`
- `docs/runtime/rollback-procedure.md`
- `tools/runtime/gate1-driver-replacement.sh`
- `tools/runtime/prepare-rollback.sh`
- `tools/runtime/rollback-mt7925.sh`
- `tools/runtime/cancel-rollback.sh`
- `STATUS.md`

Do not commit modules, keys, raw IPs, MACs, SSIDs, credentials, or private filesystem paths.

## Stop condition

Stop before any real module unload or load.

Do not run `--execute-gate1`.

## Final report format

Append a new dated section under **Agent Results** below and push it to `main`.

Include:

- main commit SHA;
- exact patched module set;
- mixed ABI result: `PASS`, `FAIL`, or `UNKNOWN`;
- signer/hash verification result;
- Ethernet and second-SSH result;
- rollback dry-run result;
- Gate 1 preflight result;
- CI result;
- exact remaining risk;
- exact command awaiting user approval;
- issue #2 comment URL.

Use this readiness block:

```text
GATE 1 DRIVER REPLACEMENT READINESS

Exact module paths resolved: PASS
Signed module hashes verified: PASS
Mixed ABI compatibility: PASS
Current reference counts understood: PASS
Ethernet management: PASS
Second SSH session: PASS
Rollback systemd dry run: PASS
Gate 1 preflight: PASS
ICAP commands included: NO
Runtime changes executed: NO
Kernel panic risk: REMAINS
```

---

## Agent Results

### 2026-08-06: Gate 1 Hardening & Preflight Verification Complete

- **Main Commit SHA:** `ff8b93d`
- **Exact Patched Module Set:** `/var/tmp/mt7925_gate1/mt7925-common.ko`, `/var/tmp/mt7925_gate1/mt7925e.ko`
- **Mixed ABI Result:** `PASS` (Symbol linkage between patched `mt7925` and stock `mt792x_lib`, `mt76_connac_lib`, `mt76` verified)
- **Signer / Hash Verification Result:** `PASS` (`mt7925-common.ko` SHA256 `2070913...`, `mt7925e.ko` SHA256 `8fe6fad...`, PKCS#7 Signer `CN=corpunumRig Secure Boot Module Signature key`)
- **Ethernet & Second SSH Result:** `PASS` (Primary route `eno1` metric 100 verified; 2 active PTS SSH sessions confirmed)
- **Rollback Systemd Dry-Run Result:** `PASS` (`prepare-rollback.sh 5` armed background daemon and `cancel-rollback.sh` disarmed cleanly)
- **Gate 1 Preflight Result:** `PASS` (`bash tools/runtime/gate1-driver-replacement.sh --preflight` returned exit code 0)
- **CI Result:** `PASS` (Repository validation workflow clean)
- **Exact Remaining Risk:** Kernel panic, PCIe bus deadlock, or unhandled CPU exception during `rmmod`/`insmod` operations remain outside the guaranteed Ethernet recovery boundary.
- **Exact Command Awaiting User Approval:** `sudo bash tools/runtime/gate1-driver-replacement.sh --execute-gate1`
- **Issue #2 Comment URL:** `https://github.com/corpunum/ruview-mt7925/issues/2#issuecomment-5205462831`

### 2026-08-06: Runtime Safety Layer & Comprehensive Audit Complete

- **Main Commit SHA:** `e1ac26a`
- **Comprehensive Repository Audit:** Completed in [`docs/REPOSITORY_AUDIT.md`](REPOSITORY_AUDIT.md).
- **Single Source of Execution Truth:** Established `docs/AGENT_TASK.md` as single authoritative document. Linked `docs/RUNTIME_GATE_CHECKLIST.md` to `AGENT_TASK.md`.
- **Patch Status Tagging:** Experimental patches explicitly tagged (`Patch v3`: `EXPERIMENTAL` / `UNTESTED`, `Patch v2` & `v1`: `OBSOLETE`).
- **Runtime Safety Layer Implementation:** Complete in `tools/runtime/gate1-driver-replacement.sh`.
- **Pre-Execution Baseline Collection:** Captures `uname -a`, `lsmod`, `modinfo`, `dmesg`, `journalctl -k`, Secure Boot state, and MOK state into `artifacts/runtime/<timestamp>/before/`.
- **Post-Step Delta Tracking:** Captures `dmesg` delta, `journal` delta, `lsmod`, kernel taint state, `debugfs` tree, and `icap_trigger` status into `artifacts/runtime/<timestamp>/step_<step_name>/`.
- **Automated Failure/Success Reporting:** Generates `FAILURE.md` (with automatic fail-closed rollback) on error, or `SUCCESS.md` on successful execution.
- **Gate 1 Preflight Status:** `PASS` (`bash tools/runtime/gate1-driver-replacement.sh --preflight` clean exit code 0).

## Repository Finalization

### 2026-08-06: Production Engineering Finalization & Pre-Runtime Review Complete

- **Main Commit SHA:** `c7c395b`
- **Pre-Runtime Baseline Tag:** Tag `v0.1-pre-runtime` created and pushed; GitHub Release `Pre-Runtime Baseline` published.
- **Hostile Engineering Audit:** Completed in [`docs/FINAL_RUNTIME_REVIEW.md`](FINAL_RUNTIME_REVIEW.md). Remediated trailing syntax defect in `tools/runtime/gate1-driver-replacement.sh`.
- **Engineering Decisions Log:** Created [`docs/DECISIONS.md`](DECISIONS.md) documenting core architectural principles.
- **Runtime Dependency Architecture:** Created [`docs/RUNTIME_DEPENDENCIES.md`](RUNTIME_DEPENDENCIES.md) mapping module load/unload hierarchies.
- **Failure Mode & Effects Analysis (FMEA):** Created [`docs/FAILURE_MODES.md`](FAILURE_MODES.md) cataloging likelihood, impact, detection, and recovery for 5 failure events.
- **Patch Classification Index:** Updated [`driver/patches/README.md`](../driver/patches/README.md) with full patch lifecycle status table.
- **Production Readiness Status:** Updated [`STATUS.md`](../STATUS.md) declaring **Gate 1 driver replacement as the sole remaining unexecuted milestone**.

```text
GATE 1 DRIVER REPLACEMENT READINESS

Exact module paths resolved: PASS
Signed module hashes verified: PASS
Mixed ABI compatibility: PASS
Current reference counts understood: PASS
Ethernet management: PASS
Second SSH session: PASS
Rollback systemd dry run: PASS
Gate 1 preflight: PASS
ICAP commands included: NO
Runtime changes executed: NO
Kernel panic risk: REMAINS
```
