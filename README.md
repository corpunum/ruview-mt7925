# RuView MT7925 & Dual-Hardware Sensing Platform

Experimental, upstream-oriented support for standalone RuView RF sensing using MediaTek MT7925 (Wi-Fi 7) and TP-Link TL-WDR3600 (Atheros) chipsets on Linux.

## Dual Hardware Sensing Targets

RuView formally tracks two complementary hardware sensing backends:

1. **MediaTek MT7925 (Primary / Onboard)**
   - **Type:** Onboard Wi-Fi 7 PCI Express adapter (`14c3:0717`).
   - **Status:** Active Primary Target. Gate 1 Driver Replacement `PASS [RUNTIME PROVEN]`. Gate 2 Ready.
   - **Documentation:** [`hardware/mt7925/README.md`](hardware/mt7925/README.md)

2. **TP-Link TL-WDR3600 v1.x (Secondary / External Reference)**
   - **Type:** External Atheros AR9344 / AR9580 dual-band router.
   - **Status:** Secondary Reference Target. Custom OpenWrt SquashFS firmware successfully compiled `[STATICALLY VERIFIED]`. Runtime validation pending.
   - **Documentation:** [`hardware/tl-wdr3600/README.md`](hardware/tl-wdr3600/README.md)

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
                │ Primary / Onboard      │       │ Secondary / External    │
                │ MediaTek MT7925        │       │ TP-Link TL-WDR3600 v1.x  │
                │ (Wi-Fi 7 PCIe)         │       │ (Atheros AR9344 / AR9580)│
                └───────────┬────────────┘       └──────────┬──────────────┘
                            │                               │
                ┌───────────┴────────────┐       ┌──────────┴──────────────┐
                │ Linux mt76 / mt7925    │       │ OpenWrt ar71xx          │
                │ MCU TESTMODE / DebugFS │       │ Atheros CSI Tool        │
                └────────────────────────┘       └─────────────────────────┘
```

> [!WARNING]
> **PROMINENT CURRENT-STATUS WARNING**
> - **No genuine MT7925 ICAP/CSI payload has yet been captured.**
> - **No claim of working MT7925 CSI extraction is currently made.**
> - TL-WDR3600 OpenWrt firmware has been statically built, but NOT yet flashed or runtime-validated.
> - Managed and monitor interfaces were proven to coexist on MT7925 (`mon0` + `wlp195s0` UP simultaneously).
> - eBPF (`bpftrace`) was proven to observe ordinary `mt76` MCU events.
> - **OpenUnum is completely out of scope.**

---

## Quick Links

- [Project Status](STATUS.md)
- [Agent Task & Execution Log](docs/AGENT_TASK.md)
- [Hardware Abstraction Overview](docs/hardware/hardware-abstraction.md)
- [Hardware Comparison Matrix](docs/hardware/csi-hardware-comparison.md)
- [MediaTek MT7925 Details](hardware/mt7925/README.md)
- [TP-Link TL-WDR3600 Details](hardware/tl-wdr3600/README.md)
- [Gate 1 Results](docs/runtime/GATE1_RESULTS.md)
- [Gate 1 Reboot Post-Mortem](docs/runtime/REBOOT_POSTMORTEM.md)
- [Gate 2 Readiness](docs/GATE2_READINESS.md)
- [Development Roadmap](ROADMAP.md)
- [Contributing Guidelines](CONTRIBUTING.md)
- [Evidence Policy](docs/evidence-policy.md)

---

## License

This project is licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for details.