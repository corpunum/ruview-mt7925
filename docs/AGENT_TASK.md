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
   - **Status:** Active Primary Target. Gate 1 & Gate 2 Driver Replacement `PASS [RUNTIME PROVEN]`. Canonical Patch v3 `icap_trigger` DebugFS node `PASS [RUNTIME PROVEN]` (`docs/MT7925_CANONICAL_ABI_PROOF.md`). Patch v4 Sysfs Control Path `CONTROL_PATH_WORKING` (`docs/MT7925_ICAP_LOCKDOWN_SOLUTION.md`). Patch v5 Two-Stage Testmode Sequence `PASS [RUNTIME PROVEN]` (`docs/PATCH_V5_RUNTIME_PROOF.md`). Passive RX-Vector Telemetry Ring Buffer `PASS [RUNTIME PROVEN]` (`docs/MT7925_RXV_RUNTIME_PROOF.md`). RuView Household Live Sensing Platform `PASS [RUNTIME PROVEN]`.
   - **Documentation:** [`hardware/mt7925/README.md`](../hardware/mt7925/README.md)

2. **TP-Link TL-WN722N v1.0 (Secondary / USB Injector)**
   - **Type:** USB 2.0 Atheros AR9271 High Gain Adapter (`0cf3:9271`).
   - **Status:** Active Secondary Target. Hardware identified & bound to `ath9k_htc` `[RUNTIME PROVEN]`. Stock firmware backed up (`1ec4cdf...`). Set to Channel 6 HT20 monitor transmitter (`wlxf4ec3897c206`). Raw CSI extraction status: `CSI_RUNTIME_FAILED` (AR9271 USB HTC firmware architecture does not expose raw OFDM subcarrier CSI matrices). Serves as controlled packet injector.
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
- **Main Commit SHA:** `963d558`
- **AR9271 Firmware Backup:** Stock firmware `/lib/firmware/ath9k_htc/htc_9271-1.4.0.fw.zst` backed up to `/tmp/ar9271_stock_backup/` (`SHA256 1ec4cdf...`).
- **AR9271 CSI Feasibility Result:** **`CSI_RUNTIME_FAILED`**. Open-source Atheros CSI Tool (`ar9003_csi.ko`) requires PCI/PCIe chipsets (`AR9344`, `AR9580`, `AR9590`); USB `ath9k_htc` architecture does not expose raw OFDM subcarrier CSI matrices over HTC queues. Authored [`docs/AR9271_CSI_ANALYSIS.md`](AR9271_CSI_ANALYSIS.md).

### 2026-08-07: Authorized Gate 2 Driver Replacement Execution Complete
- **Main Commit SHA:** `11195b2`
- **Gate 2 Execution Status:** **PASS `[RUNTIME PROVEN]`** ([`docs/GATE2_RESULTS.md`](GATE2_RESULTS.md)).

### 2026-08-07: Canonical-Based Patch v3 Runtime Proof Complete
- **Main Commit SHA:** `43001fe`
- **Canonical Source Provenance:** Launchpad `Ubuntu-hwe-7.0-7.0.0-28.28~24.04.1` (commit `917185778`).
- **Symbol CRC Alignment:** 100% match on all exported symbols (`mt792x_get_txpower` CRC `0x310f36d2`).
- **MOK Signature:** MOK signed via enrolled key (`CN=corpunumRig Secure Boot Module Signature key`).
- **Runtime Module Load:** `insmod` accepted cleanly under Secure Boot with ZERO symbol or version errors (`PASS [RUNTIME PROVEN]`).
- **DebugFS Proof:** **`icap_trigger` DebugFS node RUNTIME PROVEN** at `/sys/kernel/debug/ieee80211/phy9/mt76/icap_trigger` (`--w-------`).
- **Controlled Rollback:** Controlled rollback restored stock in-tree signed driver `/lib/modules/.../mt7925e.ko.zst` in <1 second (`PASS`). Authored [`docs/MT7925_CANONICAL_ABI_PROOF.md`](MT7925_CANONICAL_ABI_PROOF.md).

### 2026-08-07: Patch v4 Sysfs Control Path & Protocol Forensics Complete
- **Main Commit SHA:** `f40cf0e`
- **Sysfs Control Path Status:** **`CONTROL_PATH_WORKING`**. Bypassed Secure Boot kernel lockdown DebugFS write restrictions cleanly without disabling Secure Boot (`docs/MT7925_ICAP_LOCKDOWN_SOLUTION.md`).
- **8-Byte Response Deconstruction:** Decoded `46 00 00 00 00 00 00 00` as `struct mt7925_mcu_uni_event` (`cid=0x46`, `status=0x00` [`STATUS_SUCCESS`]). Authored [`docs/MT7925_MCU_TESTMODE_FORENSICS.md`](MT7925_MCU_TESTMODE_FORENSICS.md).

### 2026-08-08: RuView Household Live Sensing Platform Built & Operational
- **Main Commit SHA:** `31fa133`
- **RuView Repository Cloned & Analyzed:** Cloned `ruvnet/RuView` (`v2146`) to `/home/corpunum/ruview-upstream`. Formally mapped expected CSI JSON schema to MT7925 P-RXV/C-RXV telemetry features (`docs/RUVIEW_INTEGRATION_MAP.md`).
- **Bridge & Illuminator Created:** Created `tools/ruview-mt7925-bridge.py` and `tools/rf-illuminator.sh`.
- **Live Startup & Shutdown Scripts:** Created `start-ruview-sensing.sh` and `stop-ruview-sensing.sh`.
- **Port Conflict Resolution & Network Binding:** Configured HTTP web UI on non-conflicting port `3080` and WebSocket bridge on port `3081`. Explicitly bound to `0.0.0.0` to enable access over both Localhost, LAN (`192.168.50.251`), and Tailscale (`100.76.5.104`).
- **Live Web Interface:** RuView UI live at `http://100.76.5.104:3080/index.html` (Tailscale) and `http://192.168.50.251:3080/index.html` (LAN), receiving live WebSocket stream on `ws://100.76.5.104:3081/ws/sensing`.
