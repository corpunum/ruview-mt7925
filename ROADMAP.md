# Project Roadmap

The development roadmap for **ruview-mt7925** is organized into chronological milestones matching GitHub Issues #1 through #8.

## Milestone Alignment Matrix

| Milestone | Objective | GitHub Issue | Status |
|---|---|---|---|
| **Milestone 0** | Repository and evidence baseline | [#1](https://github.com/corpunum/ruview-mt7925/issues/1) | **In Progress** |
| **Milestone 1** | Upstream-friendly testmode exposure | [#2](https://github.com/corpunum/ruview-mt7925/issues/2) | Planned |
| **Milestone 2** | Reproducible safe build environment | [#3](https://github.com/corpunum/ruview-mt7925/issues/3) | Planned |
| **Milestone 3** | First real ICAP payload | [#4](https://github.com/corpunum/ruview-mt7925/issues/4) | Planned |
| **Milestone 4** | Controlled payload dataset | [#5](https://github.com/corpunum/ruview-mt7925/issues/5) | Planned |
| **Milestone 5** | Payload characterization | [#6](https://github.com/corpunum/ruview-mt7925/issues/6) | Planned |
| **Milestone 6** | Standalone decoder | [#7](https://github.com/corpunum/ruview-mt7925/issues/7) | Planned |
| **Milestone 7** | Real-time RuView adapter | [#8](https://github.com/corpunum/ruview-mt7925/issues/8) | Planned |
| **Milestone 8** | Upstream proposal | — | Future |

## Detailed Milestone Descriptions

### Milestone 0 — Repository and Evidence Baseline
- Establish single source of truth repository.
- Consolidate evidence history under `STATUS.md` and `docs/history/`.
- Ensure zero credentials, secrets, or unverified claims are committed.

### Milestone 1 — Upstream-Friendly Testmode Exposure
- Define an upstream-acceptable `mt76` interface to allow testmode command dispatch without breaking stock Ubuntu kernel security guarantees.

### Milestone 2 — Reproducible Safe Driver Test Environment
- Establish DKMS / local build harness with rollback capabilities to safely test driver modifications remotely over SSH.

### Milestone 3 — First Real ICAP Payload
- Execute testmode commands on modified driver/kernel and record the first non-telemetry binary payload (`> 52` bytes).

### Milestone 4 — Controlled Payload Dataset
- Record at least 1,000 payload frames under static and human motion conditions.

### Milestone 5 — Payload Characterization
- Reverse-engineer bit-packing layout, subcarrier channel structure, and complex I/Q sample offsets.

### Milestone 6 — Standalone Decoder
- Build zero-dependency Python/C decoder library (`decoder/src/`).

### Milestone 7 — Real-Time RuView Adapter
- Integrate decoded CSI matrices directly into RuView's real-time motion and Doppler visualization pipeline.

### Milestone 8 — Upstream Proposal
- Prepare patch series for `linux-wireless` and OpenWrt `mt76` trees.
