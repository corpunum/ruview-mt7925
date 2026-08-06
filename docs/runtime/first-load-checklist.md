# Pre-Runtime Safety Checklist (`docs/runtime/first-load-checklist.md`)

This checklist MUST be verified 100% prior to requesting explicit user approval for runtime module loading.

---

## Pre-Flight Requirements Checklist

- [x] **Clean Git State:** `main` working tree clean (`git status`). `[RUNTIME PROVEN]`
- [x] **CI Validation:** GitHub Actions `Validate Repository & Security` workflow passing. `[RUNTIME PROVEN]`
- [x] **Target Kernel Match:** Module `vermagic` matches `7.0.0-28-generic SMP preempt mod_unload modversions`. `[RUNTIME PROVEN]`
- [x] **Signed Module Artifacts:** Signed disposable modules (`/var/tmp/mt7925_gate1/mt7925-common.ko`, `mt7925e.ko`) verified via `modinfo` signature metadata (`SIGNED_METADATA_VERIFIED`). `[RUNTIME PROVEN]`
- [x] **Mixed ABI Compatibility:** Symbol linkage between patched `mt7925` and stock `mt76` libraries verified (`PASS`). `[SOURCE & HEADER VERIFIED]`
- [x] **Ethernet Management Isolation:** Active SSH session routes over wired Ethernet (`eno1`, metric 100). `[RUNTIME PROVEN]`
- [x] **Second SSH Session:** Second active SSH shell open and connected. `[RUNTIME PROVEN]`
- [x] **Rollback Systemd Dry-Run:** Automated rollback timer dry-run (`prepare-rollback.sh`) passed 100%. `[RUNTIME PROVEN]`
- [x] **Zero System Changes:** `/lib/modules/`, `/boot/`, initramfs, and EFI remain completely untouched. `[RUNTIME PROVEN]`
- [x] **User Approval Gate:** Explicit user confirmation requested prior to executing runtime module load commands (`--execute-gate1`). `[PENDING]`

---

## Abort Conditions

Testing MUST be aborted immediately if:
- Wired Ethernet link (`eno1`) shows instability or drops packets.
- `sign-file` metadata shows signature or hash mismatch.
- Rollback timer fails to arm or cancel during dry-run.
- Kernel panic or unhandled exception occurs.
