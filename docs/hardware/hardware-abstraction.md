# Dual-Backend Hardware Architecture Specification (`docs/hardware/hardware-abstraction.md`)

This document defines the formal dual-hardware architecture for the RuView Wi-Fi sensing platform.

---

## 1. Dual-Backend Architecture Overview

RuView formally tracks two distinct hardware sensing backends:

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

---

## 2. Hardware Roles

### A. Primary / Onboard: MediaTek MT7925
- **Role:** Native onboard Wi-Fi 7 PCI Express adapter.
- **Objective:** Production direct kernel/driver CSI extraction without external router hardware.
- **Interface:** Linux `mt76` / `mt7925` MCU DebugFS research hook (`icap_trigger`).

### B. Secondary / External: TP-Link TL-WDR3600 v1.x
- **Role:** External reference & baseline validation router.
- **Objective:** Fast path to validated 802.11n Atheros CSI measurements for cross-verifying MT7925 algorithms.
- **Interface:** Atheros CSI Tool (`ar9003_csi.ko` / `recvCSI` netlink stream over UDP/IP).
