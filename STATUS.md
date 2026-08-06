# Project Status

## Runtime Proven

- Target adapter: MediaTek MT7925, PCI ID `14c3:0717`.
- Tested kernel: Ubuntu `7.0.0-28-generic`.
- Secure Boot and kernel integrity lockdown were enabled.
- Existing enrolled Machine Owner Key (`<existing-enrolled-MOK-certificate>`) is present in `.secondary` keyring (`docs/environment/remote-testing-feasibility.md`). `[RUNTIME PROVEN]`
- Matching local MOK private signing key `<existing-enrolled-MOK-private-key>` verified. `[RUNTIME PROVEN]`
- Disposable module PKCS#7 signature metadata verified (`SIGNED_METADATA_VERIFIED`). `[RUNTIME PROVEN]`
- Runtime Safety Layer implemented in `tools/runtime/gate1-driver-replacement.sh` (`artifacts/runtime/<timestamp>/` logger & `SUCCESS.md`/`FAILURE.md` generator). `[RUNTIME PROVEN]`
- Full repository engineering audit completed in [`docs/REPOSITORY_AUDIT.md`](docs/REPOSITORY_AUDIT.md). All scripts verified. `[RUNTIME PROVEN]`
- Primary SSH route uses wired Ethernet (`eno1`, metric 100). Unloading `mt7925e` will not drop SSH access. `[RUNTIME PROVEN]`
- Rollback scripts (`tools/runtime/prepare-rollback.sh`) verified via dry-run. `[RUNTIME PROVEN]`
- Ethernet Wake-on-LAN is currently disabled (`Wake-on: d`). `[RUNTIME PROVEN]`
- A temporary monitor interface (`mon0`) coexisted with the managed interface (`wlp195s0`). `[RUNTIME PROVEN]`
- SSH remained connected while the monitor interface was created and removed. `[RUNTIME PROVEN]`
- eBPF/bpftrace observed `mt76` MCU receive events (`kprobe:mt76_mcu_rx_event`). `[RUNTIME PROVEN]`
- Ordinary operational MCU telemetry was captured. `[RUNTIME PROVEN]`
- The attempted stock-kernel testmode/vendor path returned `-EOPNOTSUPP (-95)`. `[RUNTIME PROVEN]`
- The tested kernel had `CONFIG_NL80211_TESTMODE` disabled. `[RUNTIME PROVEN]`
- No genuine ICAP payload was captured. `[RUNTIME PROVEN]`
- Measured ICAP payload size remains zero bytes. `[RUNTIME PROVEN]`

## Source Proven

Refer to [`docs/source-provenance.md`](docs/source-provenance.md) for full commit, file, function, and line range details:

- MT7925 testmode structures and command opcode `MCU_UNI_CMD_TESTMODE_CTRL = 0x46` exist in source (`SP-001`).
- A fixed-size 512-byte synchronous testmode response buffer is copied from `skb->data + 8` in `mt7925_tm_query()` (`SP-002`).
- Unknown unsolicited MCU events fall through the current handler in `mt7925_mcu_uni_rx_unsolicited_event()` and are freed via `dev_kfree_skb(skb)` (`SP-003`).
- Source-path existence does not prove the payload contains CSI.

## Statically Validated (Un-executed)

- Prototype Patch v3 was designed (`driver/patches/experimental/mt7925-icap-proof-v3.patch`).
- Patch v3 compiles cleanly against Linux kernel headers `7.0.0-28-generic` (`docs/builds/patch-v3-static-validation.md`).
- **Runtime execution of Patch v3 remains UNTESTED.**

## Remote Recovery & Security Boundary

- **Recoverable:** Recoverable from normal module-load or Wi-Fi driver failures through an independent Ethernet management path (`eno1`).
- **Unreachable Boundary:** Kernel panic, full system hang, and boot failure remain outside the guaranteed recovery boundary.

## Statistically Inferred

- No payload-layout claim is ready to promote.

## Assumed or Unknown

- Whether the fixed-size response contains CSI, IQ, FFT, calibration data or another diagnostic structure.
- Header and metadata lengths.
- Sample bit width and byte order.
- Antenna and spatial-stream mapping.
- Continuous unsolicited ICAP behavior.
- Direct compatibility with RuView.

## Rejected Earlier Claims

- CSI extraction is already solved.
- A 512-byte response was captured at runtime.
- A 480-byte CSI data region is proven.
- Exactly 120 complex subcarriers are proven.
- One tiny debugfs hook is guaranteed to be sufficient.
- RuView integration is almost complete.

## Current Blocker

The running Ubuntu kernel did not expose the required nl80211 testmode path because `CONFIG_NL80211_TESTMODE` was disabled.

Possible engineering paths:

1. An upstream-friendly `mt76` interface.
2. A safely testable kernel with `CONFIG_NL80211_TESTMODE=y`.
3. A temporary debugfs proof of concept (Patch v3 designed & compiled).
4. A separate physical test environment.

## Immediate Milestone

Capture the first genuine non-telemetry MT7925 ICAP payload with:

- exact branch and commit
- command sequence
- return codes
- kernel logs
- payload length
- SHA256
- rollback evidence
- static versus motion comparison

## Declaration

The access architecture is partially understood.

Patch v3 is statically compiled and signed, but un-executed.

MOK signature metadata and Ethernet SSH isolation are verified.

Repository audit complete in `docs/REPOSITORY_AUDIT.md`.

Actual CSI extraction is not proven.
