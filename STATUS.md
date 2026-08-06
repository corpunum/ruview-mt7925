# Project Status

## Runtime Proven

- Target adapter: MediaTek MT7925, PCI ID `14c3:0717`.
- Tested kernel: Ubuntu `7.0.0-28-generic`.
- Secure Boot and kernel integrity lockdown were enabled.
- A Machine Owner Key (`CN=corpunumRig Secure Boot Module Signature key`) is enrolled and present in `.secondary` keyring (`docs/environment/remote-testing-feasibility.md`).
- Matching MOK private signing key exists locally at `/var/lib/shim-signed/mok/MOK.priv`.
- Primary SSH route uses wired Ethernet (`eno1`, metric 100), proving unloading `mt7925e` will not drop SSH access.
- Ethernet Wake-on-LAN is currently disabled (`Wake-on: d`).
- A temporary monitor interface (`mon0`) coexisted with the managed interface (`wlp195s0`).
- SSH remained connected while the monitor interface was created and removed.
- eBPF/bpftrace observed `mt76` MCU receive events (`kprobe:mt76_mcu_rx_event`).
- Ordinary operational MCU telemetry was captured.
- The attempted stock-kernel testmode/vendor path returned `-EOPNOTSUPP (-95)`.
- The tested kernel had `CONFIG_NL80211_TESTMODE` disabled.
- No genuine ICAP payload was captured.
- Measured ICAP payload size remains zero bytes.

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

Patch v3 is statically compiled but un-executed.

MOK signing key and Ethernet SSH isolation are verified.

Actual CSI extraction is not proven.
