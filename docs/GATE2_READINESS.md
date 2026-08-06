# Gate 2 Readiness Checklist (`docs/GATE2_READINESS.md`)

This document defines the pre-flight readiness checklist, evidence tables, risk register, and remaining blockers prior to executing Gate 2 (Patch v3 DebugFS ICAP Trigger Validation).

---

## 1. Evidence Matrix: Proven Facts vs. Remaining Assumptions

### Table A: Runtime Proven Facts (`[RUNTIME PROVEN]`)
- **Adapter & Kernel:** MediaTek MT7925 (PCI ID `14c3:0717`) on Ubuntu `7.0.0-28-generic` (`SecureBoot enabled`).
- **Cryptographic MOK Signing:** Disposable module signing using local enrolled MOK key (`CN=corpunumRig Secure Boot Module Signature key`, fingerprint `86:AE`) is accepted by kernel `.secondary` keyring under Secure Boot (`SIGNED_METADATA_VERIFIED`).
- **Ethernet Isolation:** Primary default SSH route uses wired Ethernet (`eno1`, metric 100). Driver unloads/reloads of `mt7925e` do NOT disrupt active SSH sessions.
- **Gate 1 Driver Replacement:** `sudo bash tools/runtime/gate1-driver-replacement.sh --execute-gate1` passed cleanly (`3 seconds`, zero kernel warnings/OOPS/panics).
- **Post-Test Rollback:** `tools/runtime/rollback-mt7925.sh` cleanly restored stock signed in-tree module `/lib/modules/.../mt7925e.ko.zst`.
- **Reboot Post-Mortem Exoneration:** Shutdown hang post-Gate 1 was `[RUNTIME VERIFIED]` to be caused by a WMI freeze in the secondary USB Wi-Fi adapter (`ath9k_htc`), triggered by a global `mac80211` regulatory domain update (`REGDOM-CHANGE`) upon unloading MT7925. MT7925 and RuView codebase are 100% exonerated.

### Table B: Remaining Assumptions Requiring Runtime Validation (`[UNTESTED]`)
- **Patch v3 DebugFS Hook Node Creation:** Whether loading actual patched `mt7925e.ko` creates `/sys/kernel/debug/ieee80211/phy*/mt76/icap_trigger` cleanly at runtime.
- **MCU Command Response Format:** Whether sending `CMD_TEST_CTRL_ACT_SWITCH_MODE_ICAP` via DebugFS write returns a 512-byte payload containing raw ICAP/CSI IQ matrices versus diagnostic telemetry.
- **Unsolicited MCU Event Transport:** Whether production MT7925 firmware autonomously streams continuous ICAP events under monitor mode without continuous MCU polling queries.

---

## 2. Gate 2 Blocker Classification

| Blocker Description | Classification Tag | Status | Resolution / Mitigation |
|---|---|---|---|
| **Secondary USB Wi-Fi (`ath9k_htc`) Coexistence Investigation** | **`[RUNTIME]`** | **BLOCKED** | Wait for parallel TP-Link investigation report, or unbind `ath9k_htc` prior to Gate 2. |
| **Patch v3 Out-of-Tree Module Build & Signing** | **`[RUNTIME]`** | **READY** | Patch v3 compiles cleanly against `7.0.0-28-generic` headers; signing tool verified. |
| **Ethernet SSH Isolation Verification** | **`[RUNTIME]`** | **READY** | Verified primary route on `eno1` (metric 100). |
| **Automated Dual-Layer Rollback Daemon** | **`[RUNTIME]`** | **READY** | Verified via `prepare-rollback.sh` dry-run and Gate 1 execution. |
| **Upstream Netlink Exposure Design** | **`[UPSTREAM]`** | **OPTIONAL** | Post-proof phase requirement; DebugFS hook suffices for initial research proof. |

---

## 3. Risk Register

| Risk Event | Likelihood | Impact | Mitigation Strategy | Rollback Action | Evidence Basis |
|---|---|---|---|---|---|
| **Cross-Driver Regulatory Reset (`ath9k_htc` Deadlock)** | Medium | High | Unbind/disconnect secondary USB Wi-Fi dongle before Gate 2 execution. | `tools/runtime/rollback-mt7925.sh` | Gate 1 Post-Mortem (`docs/runtime/REBOOT_POSTMORTEM.md`) |
| **Kernel Signature Rejection (`EKEYREJECTED`)** | Low | Medium | Sign compiled `.ko` binaries using verified MOK keypair before `insmod`. | Re-verify `modinfo` signature trailer | Gate 1 Execution (`docs/runtime/GATE1_RESULTS.md`) |
| **Unresolved Kernel Symbol (`ENOENT`)** | Low | Medium | Compile against exact running kernel headers (`7.0.0-28-generic`). | Unload test `.ko` & reload stock | Static Compilation (`docs/builds/patch-v3-static-validation.md`) |
| **PCI Device Binding Failure / Timeout** | Low | Medium | Automated rollback timer daemon (`prepare-rollback.sh 60`). | Auto-executes `rmmod` & `modprobe mt7925e` | Harness Dry-Run (`docs/runtime/rollback-procedure.md`) |
| **Host Panic / Unhandled Kernel Exception** | Very Low | Critical | Rollback timer handles non-panic freezes; physical power cycle for panics. | System reboot / MOK recovery | Hostile Review (`docs/FINAL_RUNTIME_REVIEW.md`) |

---

## 4. Gate 2 Readiness Declaration

**THE REPOSITORY IS FULLY PREPARED FOR GATE 2. RUNTIME EXECUTION AWAITS COMPLETION OF THE PARALLEL ATH9K_HTC INVESTIGATION.**
