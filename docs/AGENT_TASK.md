# Local Agent Task — Authoritative Handoff & Single Source of Execution Truth

## Scope

Work only on `main` in `corpunum/ruview-mt7925`.

Do not create branches or pull requests.

Do **not** load or unload kernel modules without explicit approval.

Do **not** trigger ICAP without explicit approval.

Do **not** flash WDR3600 router without physical verification.

---

## Dual Hardware Sensing Backends

1. **MediaTek MT7925 (Primary / Onboard)**
   - **Type:** Onboard Wi-Fi 7 PCI Express adapter (`14c3:0717`).
   - **Status:** Active Primary Target. Gate 1 Driver Replacement `PASS [RUNTIME PROVEN]`. Gate 2 Ready.
   - **Documentation:** [`hardware/mt7925/README.md`](../hardware/mt7925/README.md)

2. **TP-Link TL-WDR3600 v1.x (Secondary / External Reference)**
   - **Type:** External Atheros AR9344 / AR9580 dual-band router.
   - **Status:** Secondary Reference Target. Custom OpenWrt SquashFS firmware successfully compiled `[STATICALLY VERIFIED]`. Runtime validation pending (`NOT_READY_FOR_FLASH`).
   - **Documentation:** [`hardware/tl-wdr3600/README.md`](../hardware/tl-wdr3600/README.md)

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

### 2026-08-07: Dual Hardware Integration & WDR3600 Forensic Audit Complete
- **Main Commit SHA:** `PENDING_COMMIT`
- **MT7925 Current Status:** Primary target; Gate 1 `PASS [RUNTIME PROVEN]`; Gate 2 ready.
- **TL-WDR3600 Current Status:** Secondary reference target; OpenWrt firmware compiled `[STATICALLY VERIFIED]`; Flashing status `NOT_READY_FOR_FLASH`.
- **WDR3600 Factory Image SHA256:** `546569477ff01721002d49157b25185663508793d159bbedbea1c1f509641fd8`
- **WDR3600 Sysupgrade Image SHA256:** `08117b6798add73c01aea7a8e04845b2dd3a8f74595542e3c52a9c090c8d84a3`
- **CSI Presence in Firmware:** `STATICALLY VERIFIED` (`ar9003_csi.ko` & `recvCSI` integrated in build tree).
- **WDR3600 Flash Readiness:** **`NOT_READY_FOR_FLASH`** (Requires physical router access & revision sticker check).
- **MT7925 Gate 2 Readiness:** **`READY_FOR_GATE2`** (Requires explicit user invocation command: `sudo bash tools/runtime/gate1-driver-replacement.sh --execute-gate1` after compiling Patch v3 DebugFS module).
- **User Approval Required:** Explicit authorization before executing Gate 2 runtime module replacement.
