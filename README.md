# RuView MT7925 & Dual-Hardware Sensing Platform

Experimental, upstream-oriented support for standalone RuView RF sensing using MediaTek MT7925 (Wi-Fi 7) and TP-Link TL-WN722N (Atheros AR9271) chipsets on Linux.

## Active Hardware Sensing Targets

RuView formally tracks two complementary hardware sensing backends:

1. **MediaTek MT7925 (Primary / Onboard)**
   - **Type:** Onboard Wi-Fi 7 PCI Express adapter (`14c3:0717`).
   - **Status:** Active Primary Target. Gate 1 & Gate 2 Driver Replacement `PASS [RUNTIME PROVEN]`. Canonical Patch v3 `icap_trigger` DebugFS node `PASS [RUNTIME PROVEN]`. Passive RX-Vector Telemetry Ring Buffer `PASS [RUNTIME PROVEN]` (`docs/MT7925_RXV_RUNTIME_PROOF.md`). High-Rate Profiling Proof complete (`docs/MT7925_HIGHRATE_PROFILING_PROOF.md`). Passive Sensing & Blind Classification Proof complete (`docs/MT7925_PASSIVE_SENSING_PROOF.md`). Declared `B = PROMISING BUT MORE VALIDATION REQUIRED`. Reproducible build script `tools/build-high-rate-telemetry.sh` `PASS [RUNTIME PROVEN]`.
   - **Documentation:** [`hardware/mt7925/README.md`](hardware/mt7925/README.md)

2. **TP-Link TL-WN722N v1.0 (Secondary / USB Reference & Packet Injector)**
   - **Type:** USB 2.0 Atheros AR9271 High Gain Adapter (`0cf3:9271`).
   - **Status:** Active Secondary Target / Controlled Packet Injector. Hardware identified & bound to `ath9k_htc` `[RUNTIME PROVEN]`. Set to Channel 6 HT20 monitor mode (`wlxf4ec3897c206`). Raw CSI extraction status: `CSI_RUNTIME_FAILED` (AR9271 USB HTC firmware architecture does not expose raw OFDM subcarrier CSI matrices). Serves as controlled packet injector.
   - **Documentation:** [`hardware/tl-wn722n/README.md`](hardware/tl-wn722n/README.md)

*(Note: TP-Link TL-WDR3600 router investigation is DEFERRED / OUT OF CURRENT SCOPE).*

---

## Unified Sensing Pipeline Architecture

```text
                                ┌──────────────────────────┐
                                │   RuView Core Platform   │
                                └────────────┬─────────────┘
                                             │
                                ┌────────────┴─────────────┐
                                │  Hardware Abstraction    │
                                │   CSI Normalization API  │
                                └──────┬─────────────┬─────┘
                                       │             │
                 ┌─────────────────────┴──┐       ┌──┴──────────────────────┐
                 │ Primary / Onboard      │       │ Secondary / USB Reference│
                 │ MediaTek MT7925        │       │ TP-Link TL-WN722N v1.0  │
                 │ (Wi-Fi 7 PCIe)         │       │ (Atheros AR9271 USB)    │
                 └───────────┬────────────┘       └──────────┬──────────────┘
                             │                               │
                 ┌───────────┴────────────┐       ┌──────────┴──────────────┐
                 │ Linux mt76 / mt7925    │       │ Linux ath9k_htc         │
                 │ MCU TESTMODE / Sysfs   │       │ open-ath9k-htc-firmware │
                 └────────────────────────┘       └─────────────────────────┘
```

> [!WARNING]
> **PROMINENT CURRENT-STATUS WARNING**
> - **MT7925 Passive RX-Vector Telemetry Ring Buffer is `PASS [RUNTIME PROVEN]`.**
> - **Exposes per-packet `RCPI0-3` (4 antenna chains), TxBF, MCS, BW, NSS, and STBC metrics.**
> - **High-Rate Reception Profiling complete (`docs/MT7925_HIGHRATE_PROFILING_PROOF.md`). Achieved 65.0 to 117.6 samples/sec in monitor mode.**
> - **Blind Motion Classification complete (`docs/MT7925_PASSIVE_SENSING_PROOF.md`). Model 4 Combined Features achieved 59.6% test accuracy (F1: 0.75).**
> - TL-WN722N v1.0 USB hardware serves as a controlled 802.11n packet injector.
> - **OpenUnum is completely out of scope.**

---

## Quick Links

- [Project Status](STATUS.md)
- [Agent Task & Execution Log](docs/AGENT_TASK.md)
- [MT7925 Passive Sensing Proof](docs/MT7925_PASSIVE_SENSING_PROOF.md)
- [MT7925 High-Rate Profiling Proof](docs/MT7925_HIGHRATE_PROFILING_PROOF.md)
- [MT7925 RX-Vector Runtime Proof](docs/MT7925_RXV_RUNTIME_PROOF.md)
- [MT7925 RX-Vector Field Map](docs/MT7925_RXV_FIELD_MAP.md)
- [MT7925 RX-Vector Analysis](docs/MT7925_RX_VECTOR_ANALYSIS.md)
- [Passive Telemetry Patch Design](docs/MT7925_PASSIVE_TELEMETRY_DESIGN.md)
- [CSI Hardware Ecosystem Alternatives](docs/CSI_HARDWARE_ALTERNATIVES.md)
- [MT7925 ICAP Implementation Map](docs/MT7925_ICAP_IMPLEMENTATION_MAP.md)
- [Patch v6 Minimum Design](docs/PATCH_V6_DESIGN.md)
- [MT7925 ICAP State Machine Forensics](docs/MT7925_ICAP_STATE_MACHINE.md)
- [Patch v5 Runtime Proof](docs/PATCH_V5_RUNTIME_PROOF.md)
- [MCU Testmode Forensics](docs/MT7925_MCU_TESTMODE_FORENSICS.md)
- [MediaTek Capture Architecture](docs/MT7925_CAPTURE_ARCHITECTURE.md)
- [Patch v4 Sysfs Solution](docs/MT7925_ICAP_LOCKDOWN_SOLUTION.md)
- [Canonical ABI Proof](docs/MT7925_CANONICAL_ABI_PROOF.md)
- [CSI Path Comparison](docs/CSI_PATH_COMPARISON.md)
- [Hardware Inventory](docs/HARDWARE_INVENTORY.md)
- [MediaTek MT7925 Details](hardware/mt7925/README.md)
- [TP-Link TL-WN722N Details](hardware/tl-wn722n/README.md)
- [Gate 1 Results](docs/runtime/GATE1_RESULTS.md)
- [Gate 1 Reboot Post-Mortem](docs/runtime/REBOOT_POSTMORTEM.md)
- [Gate 2 Readiness](docs/GATE2_READINESS.md)
- [Development Roadmap](ROADMAP.md)
- [Contributing Guidelines](CONTRIBUTING.md)
- [Evidence Policy](docs/evidence-policy.md)

---

## License

This project is licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for details.