# RuView MT7925 & Dual-Hardware Sensing Platform

Experimental, upstream-oriented support for standalone RuView RF sensing using MediaTek MT7925 (Wi-Fi 7) and TP-Link TL-WN722N (Atheros AR9271) chipsets on Linux.

## Active Hardware Sensing Targets

RuView formally tracks two complementary hardware sensing backends:

1. **MediaTek MT7925 (Primary / Onboard)**
   - **Type:** Onboard Wi-Fi 7 PCI Express adapter (`14c3:0717`).
   - **Status:** Active Primary Target. Gate 1 & Gate 2 Driver Replacement `PASS [RUNTIME PROVEN]`. Canonical Patch v3 `icap_trigger` DebugFS node `PASS [RUNTIME PROVEN]`. Reproducible build script `tools/build-canonical-patch-v4.sh` `PASS [RUNTIME PROVEN]`. Sysfs Lockdown-Compatible Control Path `PASS [RUNTIME PROVEN]` (`CONTROL_PATH_WORKING`). MCU testmode status header captured (`CURRENT_TESTMODE_QUERY_RETURNS_STATUS_ONLY`). Protocol forensics & Patch v5 design complete (`docs/PATCH_V5_DESIGN.md`).
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
> - **Patch v4 Sysfs Control Path is `CONTROL_PATH_WORKING`.**
> - **MT7925 MCU testmode command `MCU_UNI_QUERY(TESTMODE_CTRL)` returned an 8-byte status response header (`CURRENT_TESTMODE_QUERY_RETURNS_STATUS_ONLY`).**
> - **Protocol Forensics & MCU Call Chain Analysis complete (`docs/MT7925_MCU_TESTMODE_FORENSICS.md`).**
> - **Patch v5 Two-Stage Testmode Sequence designed (`docs/PATCH_V5_DESIGN.md`). Awaiting authorization.**
> - TL-WN722N v1.0 USB hardware serves as a controlled 802.11n packet injector.
> - **OpenUnum is completely out of scope.**

---

## Quick Links

- [Project Status](STATUS.md)
- [Agent Task & Execution Log](docs/AGENT_TASK.md)
- [MCU Testmode Forensics](docs/MT7925_MCU_TESTMODE_FORENSICS.md)
- [MediaTek Capture Architecture](docs/MT7925_CAPTURE_ARCHITECTURE.md)
- [Patch v5 Design Proposal](docs/PATCH_V5_DESIGN.md)
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