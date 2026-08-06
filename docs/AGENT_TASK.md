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

Exact module paths resolved: PASS/FAIL
Signed module hashes verified: PASS/FAIL
Mixed ABI compatibility: PASS/FAIL/UNKNOWN
Current reference counts understood: PASS/FAIL
Ethernet management: PASS/FAIL
Second SSH session: PASS/FAIL
Rollback systemd dry run: PASS/FAIL
Gate 1 preflight: PASS/FAIL
ICAP commands included: NO
Runtime changes executed: NO
Kernel panic risk: REMAINS
```

---

## Agent Results

_No result posted yet._
