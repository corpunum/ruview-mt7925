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
   - **Status:** Active Primary Target. Gate 1 & Gate 2 Driver Replacement `PASS [RUNTIME PROVEN]`. Phase 1 ABI Forensics Complete (`docs/MT76_ABI_ANALYSIS.md`).
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
- **Main Commit SHA:** `963d558`
- **AR9271 Firmware Backup:** Stock firmware `/lib/firmware/ath9k_htc/htc_9271-1.4.0.fw.zst` backed up to `/tmp/ar9271_stock_backup/` (`SHA256 1ec4cdf...`).
- **AR9271 CSI Feasibility Result:** **`CSI_RUNTIME_FAILED`**. Open-source Atheros CSI Tool (`ar9003_csi.ko`) requires PCI/PCIe chipsets (`AR9344`, `AR9580`, `AR9590`); USB `ath9k_htc` architecture does not expose raw OFDM subcarrier CSI matrices over HTC queues. Authored [`docs/AR9271_CSI_ANALYSIS.md`](AR9271_CSI_ANALYSIS.md).

### 2026-08-07: Authorized Gate 2 Driver Replacement Execution Complete
- **Main Commit SHA:** `11195b2`
- **Gate 2 Execution Status:** **PASS `[RUNTIME PROVEN]`** ([`docs/GATE2_RESULTS.md`](GATE2_RESULTS.md)).

### 2026-08-07: Patch v3 Build & Symbol Provenance Analysis Complete
- **Main Commit SHA:** `9015f68`
- **Source Instrumentation:** Patch v3 applied to `mt7925/debugfs.c` (`mt7925_icap_trigger_set`, `fops_icap_trigger`).
- **Static Binary Proof:** Symbol `icap_trigger` verified inside `debugfs.o` and `mt7925-common.ko` via `strings` (`PASS [STATICALLY VERIFIED]`).
- **Runtime Load Result:** Rejected by kernel with `Unknown symbol mt792x_get_txpower (err -2)` due to kernel ABI symbol CRC mismatch (`PATCH_V3_RUNTIME_FAILED`). Authored [`docs/PATCH_V3_RUNTIME_PROOF.md`](PATCH_V3_RUNTIME_PROOF.md).

### 2026-08-07: Phase 1 ABI Forensics & Dependency Tree Complete
- **Main Commit SHA:** `2dd942d`
- **Kernel Configuration:** `CONFIG_MODVERSIONS=y`, `CONFIG_MODULE_SIG=y`, `CONFIG_MODULE_SIG_ALL=y`, `CONFIG_MODULE_SIG_HASH="sha512"`.
- **Dependency Graph:** `cfg80211` -> `mac80211` -> `mt76` -> `mt76-connac-lib` -> `mt792x-lib` -> `mt7925-common` -> `mt7925e`.
- **Root Cause Diagnosis:** Building upstream `openwrt/mt76` out-of-tree without rebuilding all 5 interdependent modules (`mt76`, `mt76-connac-lib`, `mt792x-lib`, `mt7925-common`, `mt7925e`) causes symbol CRC checksum divergence against Ubuntu `7.0.0-28-generic` stock headers.
- **ABI Forensics Document:** Authored [`docs/MT76_ABI_ANALYSIS.md`](MT76_ABI_ANALYSIS.md).
- **Final Driver State:** Stock signed driver active (`PASS`).
