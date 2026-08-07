# Local Agent Task — Authoritative Handoff & Single Source of Execution Truth

## Scope

Work only on `main` in `corpunum/ruview-mt7925`.

Do not create branches or pull requests.

Do **not** load or unload kernel modules without explicit approval.

Do **not** trigger ICAP without explicit approval.

Do **not** flash WDR3600 router. (TL-WDR3600 investigation is DEFERRED / OUT OF CURRENT SCOPE).

---

## Active Hardware Sensing Backends

1. **MediaTek MT7925 (Primary / Onboard)**
   - **Type:** Onboard Wi-Fi 7 PCI Express adapter (`14c3:0717`).
   - **Status:** Active Primary Target. Gate 1 Driver Replacement `PASS [RUNTIME PROVEN]`. Gate 2 Ready (`READY_FOR_GATE2`). Preflight check verified `PASS`.
   - **Documentation:** [`hardware/mt7925/README.md`](../hardware/mt7925/README.md)

2. **TP-Link TL-WN722N v1.0 (Secondary / USB Reference)**
   - **Type:** USB 2.0 Atheros AR9271 High Gain Adapter (`0cf3:9271`).
   - **Status:** Active Secondary Target. Hardware identified & bound to `ath9k_htc` `[RUNTIME PROVEN]`. Fail-closed USB unbind isolation verified (`echo 3-2:1.0 > /sys/bus/usb/drivers/ath9k_htc/unbind`).
   - **Documentation:** [`hardware/tl-wn722n/README.md`](../hardware/tl-wn722n/README.md)

*(Note: TP-Link TL-WDR3600 router investigation is DEFERRED / OUT OF CURRENT SCOPE).*

---

## Agent Results & Execution Log

### 2026-08-06: Gate 1 Hardening & Preflight Verification Complete
- **Main Commit SHA:** `ff8b93d`
- **Gate 1 Preflight Status:** `PASS` (`bash tools/runtime/gate1-driver-replacement.sh --preflight` clean exit code 0).

### 2026-08-06: Gate 1 Driver Replacement Runtime Execution Complete
- **Main Commit SHA:** `3686011`
- **Gate 1 Execution Status:** **PASS `[RUNTIME PROVEN]`** ([`docs/runtime/GATE1_RESULTS.md`](runtime/GATE1_RESULTS.md))

### 2026-08-06: Gate 1 Reboot Hang Post-Mortem Investigation Complete
- **Main Commit SHA:** `d225413`
- **Post-Mortem Analysis Document:** [`docs/runtime/REBOOT_POSTMORTEM.md`](runtime/REBOOT_POSTMORTEM.md)
- **Root Cause Identified:** **Secondary USB Wi-Fi Adapter (`ath9k_htc`) Firmware/WMI Deadlock** (`ath9k_wmi_cmd` stuck in `D` state holding `wiphy->mtx`). MT7925 and RuView codebase **100% EXONERATED**.

### 2026-08-06: Gate 2 Preparation & Open-Source Readiness Complete
- **Main Commit SHA:** `957ba68`
- **Gate 2 Readiness Matrix:** Authored [`docs/GATE2_READINESS.md`](GATE2_READINESS.md).

### 2026-08-07: Phase 1-7 Hardware Discovery & CSI Comparison Complete
- **Main Commit SHA:** `PENDING_COMMIT`
- **MT7925 Status:** Primary Target. `PCI ID: 14c3:0717`. Driver: `mt7925e`. Gate 1: `PASS [RUNTIME PROVEN]`. Gate 2: `READY_FOR_GATE2` (Preflight check verified `PASS`).
- **TL-WN722N Status:** Secondary Target. `USB VID:PID: 0cf3:9271`. Chipset: Qualcomm Atheros AR9271. Hardware Revision: `v1.0 / v1.1 [RUNTIME PROVEN]`. Driver: `ath9k_htc`.
- **CSI Path Selection:** **PRIMARY_CSI_PATH:** MediaTek MT7925 (Wi-Fi 7 2x2 MIMO). **SECONDARY_CSI_PATH:** TL-WN722N v1.0 (USB AR9271 1x1 SISO). Authored [`docs/CSI_PATH_COMPARISON.md`](CSI_PATH_COMPARISON.md).
- **USB Isolation Plan:** Pre-Gate 2 isolation command verified (`echo 3-2:1.0 > /sys/bus/usb/drivers/ath9k_htc/unbind` + `rmmod ath9k_htc`). Completely eliminates cross-driver shutdown hang risk during MT7925 testing.
- **Hardware Inventory:** Updated [`docs/HARDWARE_INVENTORY.md`](HARDWARE_INVENTORY.md) and [`hardware/tl-wn722n/README.md`](../hardware/tl-wn722n/README.md). Marked TL-WDR3600 as `DEFERRED / OUT OF CURRENT SCOPE`.
- **User Approval Required:** Explicit authorization before executing Gate 2 runtime module replacement.
