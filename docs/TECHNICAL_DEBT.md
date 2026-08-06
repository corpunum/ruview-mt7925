# Technical Debt & Refactoring Register (`docs/TECHNICAL_DEBT.md`)

This document records identified technical debt, deprecated artifacts, naming inconsistencies, and planned refactoring items across the repository.

---

## 1. Identified Technical Debt & Status

| Item / Defect Description | Location / Subsystem | Category | Current Status | Remediation Plan |
|---|---|---|---|---|
| **Trailing Syntax Error in Harness Script** | `tools/runtime/gate1-driver-replacement.sh` | **SCRIPT** | **REMEDIATED** | Removed self-chmod line; verified exit code `0`. |
| **SIGPIPE on `head -n 1` in Pipelines** | `tools/runtime/gate1-driver-replacement.sh` | **SCRIPT** | **REMEDIATED** | Replaced `grep | head -n 1` with `awk` to prevent signal 141. |
| **Secondary USB Wi-Fi (`ath9k_htc`) Shutdown Stall** | `drivers/net/wireless/ath/ath9k/` | **HARDWARE / DRIVER** | **DOCUMENTED** | Documented in `docs/runtime/REBOOT_POSTMORTEM.md`. Unbind dongle prior to Gate 2. |
| **Superseded Experimental Patches (v1 & v2)** | `driver/patches/experimental/` | **PATCH** | **DEPRECATED** | Tagged as `[OBSOLETE]` in `driver/patches/README.md`. |
| **Ethernet Wake-on-LAN Disabled (`Wake-on: d`)** | Network Interface `eno1` | **SYSTEM CONFIG** | **OPTIONAL** | Documented enablement command (`sudo ethtool -s eno1 wol g`). |

---

## 2. Deprecated Files & Patches

- **`driver/patches/experimental/mt7925-icap-proof.patch`:** Superseded by v2 and v3 (`[OBSOLETE]`).
- **`driver/patches/experimental/mt7925-icap-proof-v2.patch`:** Superseded by v3 due to TLV padding offset mismatch (`[OBSOLETE]`).
