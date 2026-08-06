# Pre-Runtime Safety Checklist (`docs/runtime/first-load-checklist.md`)

This checklist MUST be verified 100% prior to requesting explicit user approval for runtime module loading.

---

## Pre-Flight Requirements Checklist

- [x] **Clean Git State:** `main` working tree clean (`git status`). `[RUNTIME PROVEN]`
- [x] **CI Validation:** GitHub Actions `Validate Repository & Security` workflow passing. `[RUNTIME PROVEN]`
- [x] **Target Kernel Match:** Module `vermagic` matches `7.0.0-28-generic SMP preempt mod_unload modversions`. `[RUNTIME PROVEN]`
- [x] **Signed Disposable Copy Metadata:** Signed module PKCS#7 trailer matches enrolled MOK signer (`CN=corpunumRig Secure Boot Module Signature key`). `[RUNTIME PROVEN]`
- [x] **Ethernet Management Isolation:** Active SSH session routes over wired Ethernet (`eno1`, metric 100). `[RUNTIME PROVEN]`
- [x] **Second SSH Session:** Second active SSH shell open and connected. `[RUNTIME PROVEN]`
- [x] **Rollback Dry-Run:** Automated rollback timer dry-run (`prepare-rollback.sh`) passed 100%. `[RUNTIME PROVEN]`
- [x] **Zero System Changes:** `/lib/modules/`, `/boot/`, initramfs, and EFI remain completely untouched. `[RUNTIME PROVEN]`
- [x] **User Approval Gate:** Explicit user confirmation requested prior to executing runtime module load commands. `[PENDING]`

---

## Abort Conditions

Testing MUST be aborted immediately if:
- Wired Ethernet link (`eno1`) shows instability or drops packets.
- `sign-file` metadata shows signature or hash mismatch.
- Rollback timer fails to arm or cancel during dry-run.
- Kernel panic or unhandled exception occurs.
