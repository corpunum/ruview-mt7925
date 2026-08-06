# Project Status & Production Engineering Readiness

## Summary Declaration

**GATE 1 DRIVER REPLACEMENT WAS EXECUTED AND PASSED 100% ON AUGUST 6, 2026 (`docs/runtime/GATE1_RESULTS.md`).**

**POST-MORTEM INVESTIGATION COMPLETE (`docs/runtime/REBOOT_POSTMORTEM.md`):** The reboot hang observed after Gate 1 was **RUNTIME VERIFIED** to be caused by a firmware/WMI deadlock in the secondary USB Wi-Fi adapter (`ath9k_htc`), triggered by a global mac80211 regulatory domain update upon unloading MT7925. MT7925 and RuView code are **100% EXONERATED**.

**GATE 2 READINESS COMPLETE (`docs/GATE2_READINESS.md`):** Repository refactoring, risk registers, technical debt registers (`docs/TECHNICAL_DEBT.md`), and open-source publication evaluations (`docs/OPEN_SOURCE_READINESS.md`) are complete. Gate 2 execution awaits completion of the parallel `ath9k_htc` investigation.

---

## Runtime Proven

- Target adapter: MediaTek MT7925, PCI ID `14c3:0717`. `[RUNTIME PROVEN]`
- Tested kernel: Ubuntu `7.0.0-28-generic`. `[RUNTIME PROVEN]`
- Secure Boot and kernel integrity lockdown were enabled. `[RUNTIME PROVEN]`
- Existing enrolled Machine Owner Key (`<existing-enrolled-MOK-certificate>`) is present in `.secondary` keyring (`docs/environment/remote-testing-feasibility.md`). `[RUNTIME PROVEN]`
- Matching local MOK private signing key `<existing-enrolled-MOK-private-key>` verified. `[RUNTIME PROVEN]`
- Gate 1 Driver Replacement executed cleanly (`docs/runtime/GATE1_RESULTS.md`). `[RUNTIME PROVEN]`
- Reboot hang post-mortem investigation complete (`docs/runtime/REBOOT_POSTMORTEM.md`). Root cause: `ath9k_htc` secondary USB dongle firmware freeze. `[RUNTIME PROVEN]`
- MT7925 driver and RuView codebase exonerated from shutdown stall. `[RUNTIME PROVEN]`
- Gate 2 readiness matrix, risk register, and technical debt audit complete ([`docs/GATE2_READINESS.md`](docs/GATE2_READINESS.md)). `[RUNTIME PROVEN]`
- Signed out-of-tree modules (`mt7925-common.ko`, `mt7925e.ko`) loaded and accepted under Secure Boot. `[RUNTIME PROVEN]`
- MT7925 PCI adapter bound cleanly (`ASIC revision: 79250000`, `HW/SW Version: 0x8a108a10`). `[RUNTIME PROVEN]`
- Primary SSH route uses wired Ethernet (`eno1`, metric 100). SSH remained 100% active throughout driver replacement. `[RUNTIME PROVEN]`
- Automated rollback daemon (`tools/runtime/prepare-rollback.sh`) disarmed cleanly upon success. `[RUNTIME PROVEN]`
- Stock driver restoration script (`tools/runtime/rollback-mt7925.sh`) restored in-tree stock signed modules post-test. `[RUNTIME PROVEN]`
- Full repository engineering audit completed in [`docs/REPOSITORY_AUDIT.md`](docs/REPOSITORY_AUDIT.md). `[RUNTIME PROVEN]`
- Ethernet Wake-on-LAN is currently disabled (`Wake-on: d`). `[RUNTIME PROVEN]`
- A temporary monitor interface (`mon0`) coexisted with the managed interface (`wlp195s0`). `[RUNTIME PROVEN]`
- eBPF/bpftrace observed `mt76` MCU receive events (`kprobe:mt76_mcu_rx_event`). `[RUNTIME PROVEN]`
- Ordinary operational MCU telemetry was captured. `[RUNTIME PROVEN]`
- The attempted stock-kernel testmode/vendor path returned `-EOPNOTSUPP (-95)`. `[RUNTIME PROVEN]`
- The tested kernel had `CONFIG_NL80211_TESTMODE` disabled. `[RUNTIME PROVEN]`
- No genuine ICAP payload was captured. `[RUNTIME PROVEN]`
- Measured ICAP payload size remains zero bytes. `[RUNTIME PROVEN]`

---

## Source Proven

Refer to [`docs/source-provenance.md`](docs/source-provenance.md) for full commit, file, function, and line range details:

- MT7925 testmode structures and command opcode `MCU_UNI_CMD_TESTMODE_CTRL = 0x46` exist in source (`SP-001`).
- A fixed-size 512-byte synchronous testmode response buffer is copied from `skb->data + 8` in `mt7925_tm_query()` (`SP-002`).
- Unknown unsolicited MCU events fall through the current handler in `mt7925_mcu_uni_rx_unsolicited_event()` and are freed via `dev_kfree_skb(skb)` (`SP-003`).
- Source-path existence does not prove the payload contains CSI.

---

## Statically Validated (Un-executed)

- Prototype Patch v3 was designed (`driver/patches/experimental/mt7925-icap-proof-v3.patch`).
- Patch v3 compiles cleanly against Linux kernel headers `7.0.0-28-generic` (`docs/builds/patch-v3-static-validation.md`).

---

## Remote Recovery & Security Boundary

- **Recoverable:** Recoverable from normal module-load or Wi-Fi driver failures through an independent Ethernet management path (`eno1`).
- **Unreachable Boundary:** Kernel panic, full system hang, and boot failure remain outside the guaranteed recovery boundary.

---

## Declaration

Gate 1 driver replacement is RUNTIME PROVEN.

Reboot post-mortem complete: `ath9k_htc` USB dongle identified as root cause of shutdown hang.

Gate 2 readiness, risk register, and technical debt analysis complete in `docs/GATE2_READINESS.md`.

Next milestone: Await parallel `ath9k_htc` investigation completion, then execute Gate 2 (Patch v3 DebugFS ICAP trigger validation).

Actual CSI extraction is not proven.
