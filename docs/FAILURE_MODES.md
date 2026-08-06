# Failure Mode & Effects Analysis (`docs/FAILURE_MODES.md`)

This document analyzes potential runtime failure modes, likelihood, impact, detection mechanisms, and recovery procedures during MT7925 testing.

---

## Failure Mode Matrix

| Failure Event | Likelihood | Impact | Detection Mechanism | Automated Recovery | SSH Session Survival |
|---|---|---|---|---|---|
| **Module Unload Error (`EBUSY`)** | Low | Low | Exit code of `rmmod` | Abort execution; stock module remains active | **YES (`eno1`)** |
| **Signature Reject (`EKEYREJECTED`)** | Low | Medium | `insmod` returns `-1 Key was rejected by service` | Trigger `on_failure` $\rightarrow$ Reload stock in-tree modules | **YES (`eno1`)** |
| **Unresolved Symbol Error (`ENOENT`)** | Low | Medium | `dmesg` reports Unknown symbol in module | Trigger `on_failure` $\rightarrow$ Reload stock in-tree modules | **YES (`eno1`)** |
| **PCI Device Init Timeout** | Low | Medium | `dmesg` shows MT7925 init failed | `prepare-rollback.sh` timeout expires $\rightarrow$ Unloads test `.ko`, reloads stock | **YES (`eno1`)** |
| **Kernel Panic / Host Freeze** | Very Low | Critical | Host unresponsive to ping/SSH | Automated rollback timer (if kernel alive) or physical power cycle | **NO** |

---

## Recovery Verification

- **Ethernet Management Isolation:** Active SSH routes over `eno1` (Metric 100). Driver unloads of `mt7925e` will **NOT** drop active SSH sessions.
- **Fail-Closed Guarantee:** Rollback daemon automatically restores stock modules upon any non-zero exit code or timeout.
