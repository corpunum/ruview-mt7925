# RuView MT7925 & Dual-Hardware Sensing Platform

Experimental, upstream-oriented support for standalone RuView RF sensing using MediaTek MT7925 (Wi-Fi 7) and TP-Link TL-WN722N (Atheros AR9271) chipsets on Linux.

## Active Hardware Sensing Targets

RuView formally tracks two complementary hardware sensing backends:

1. **MediaTek MT7925 (Primary / Onboard)**
   - **Type:** Onboard Wi-Fi 7 PCI Express adapter (`14c3:0717`).
   - **Status:** Active Primary Target. Gate 1 Driver Replacement `PASS [RUNTIME PROVEN]`. Gate 2 Ready (`READY_FOR_GATE2`).
   - **Documentation:** [`hardware/mt7925/README.md`](hardware/mt7925/README.md)

2. **TP-Link TL-WN722N v1.0 (Secondary / USB Reference)**
   - **Type:** USB 2.0 Atheros AR9271 High Gain Adapter (`0cf3:9271`).
   - **Status:** Secondary Reference Target. Hardware identified & bound to `ath9k_htc` `[RUNTIME PROVEN]`. USB sysfs unbind isolation verified.
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
                │ MCU TESTMODE / DebugFS │       │ open-ath9k-htc-firmware │
                └────────────────────────┘       └─────────────────────────┘
```

> [!WARNING]
> **PROMINENT CURRENT-STATUS WARNING**
> - **No genuine MT7925 ICAP/CSI payload has yet been captured.**
> - **No claim of working MT7925 CSI extraction is currently made.**
> - TL-WN722N v1.0 USB hardware is verified and bound to `ath9k_htc`, but CSI firmware extraction remains to be executed.
> - Managed and monitor interfaces were proven to coexist on MT7925 (`mon0` + `wlp195s0` UP simultaneously).
> - eBPF (`bpftrace`) was proven to observe ordinary `mt76` MCU events.
> - **OpenUnum is completely out of scope.**

---

## Quick Links

- [Project Status](STATUS.md)
- [Agent Task & Execution Log](docs/AGENT_TASK.md)
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