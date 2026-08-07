# Local Agent Task — Authoritative Handoff & Single Source of Execution Truth

## Scope

Work only on `main` in `corpunum/ruview-mt7925`.

Do not create branches or pull requests.

Do **not** load or unload MT7925 kernel modules without explicit approval.

Do **not** trigger ICAP without explicit approval.

Do **not** flash WDR3600 router. (TL-WDR3600 investigation is DEFERRED / OUT OF CURRENT SCOPE).

---

## Active Hardware Sensing Backends

1. **MediaTek MT7925 (Primary / Onboard)**
   - **Type:** Onboard Wi-Fi 7 PCI Express adapter (`14c3:0717`).
   - **Status:** Active Primary Target. Gate 1 Driver Replacement `PASS [RUNTIME PROVEN]`. Gate 2 Ready (`READY_FOR_GATE2`). Preflight check verified `PASS`.
   - **Documentation:** [`hardware/mt7925/README.md`](../hardware/mt7925/README.md)

2. **TP-Link TL-WN722N v1.0 (Secondary / USB Injector)**
   - **Type:** USB 2.0 Atheros AR9271 High Gain Adapter (`0cf3:9271`).
   - **Status:** Active Secondary Target. Hardware identified & bound to `ath9k_htc` `[RUNTIME PROVEN]`. Stock firmware backed up (`1ec4cdf...`). Raw CSI extraction status: `CSI_RUNTIME_FAILED` (AR9271 USB HTC firmware architecture does not expose raw OFDM subcarrier CSI matrices). Serves as controlled packet injector.
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

### 2026-08-07: AR9271 CSI Firmware Analysis & Feasibility Complete
- **Main Commit SHA:** `PENDING_COMMIT`
- **AR9271 Firmware Backup:** Stock firmware `/lib/firmware/ath9k_htc/htc_9271-1.4.0.fw.zst` backed up to `/tmp/ar9271_stock_backup/` (`SHA256 1ec4cdf426d32602034cb4731b618155911b4afc863b7e0d19407937cbd1c2a2`).
- **AR9271 CSI Feasibility Result:** **`CSI_RUNTIME_FAILED`**. Open-source Atheros CSI Tool (`ar9003_csi.ko`) requires PCI/PCIe chipsets (`AR9344`, `AR9580`, `AR9590`); USB `ath9k_htc` architecture does not expose raw OFDM subcarrier CSI matrices over HTC queues. Authored [`docs/AR9271_CSI_ANALYSIS.md`](AR9271_CSI_ANALYSIS.md).
- **MT7925 Gate 2 Status:** **`READY_FOR_GATE2`**. Re-verified preflight (`PASS`).
- **User Approval Required:** Explicit authorization before executing MT7925 Gate 2 runtime module replacement.
