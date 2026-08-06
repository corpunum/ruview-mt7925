# Project Status

## Runtime Proven

- Target adapter: MediaTek MT7925, PCI ID `14c3:0717`.
- Tested kernel: Ubuntu `7.0.0-28-generic`.
- Secure Boot and kernel integrity lockdown were enabled.
- A temporary monitor interface (`mon0`) coexisted with the managed interface (`wlp195s0`).
- SSH remained connected while the monitor interface was created and removed.
- eBPF/bpftrace observed `mt76` MCU receive events (`kprobe:mt76_mcu_rx_event`).
- Ordinary operational MCU telemetry was captured.
- The attempted stock-kernel testmode/vendor path returned `-EOPNOTSUPP (-95)`.
- The tested kernel had `CONFIG_NL80211_TESTMODE` disabled.
- No genuine ICAP payload was captured.
- Measured ICAP payload size remains zero bytes.

## Source Proven

- MT7925 testmode structures and command paths exist in `mt76` source.
- A fixed-size synchronous testmode response buffer exists in source.
- Unknown unsolicited MCU events may fall through the current handler and be freed (`mt7925_mcu_uni_rx_unsolicited_event`).
- Source-path existence does not prove the payload contains CSI.

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
3. A temporary debugfs proof of concept.
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

Actual CSI extraction is not proven.
