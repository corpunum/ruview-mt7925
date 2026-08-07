# MT7925 Passive RX-Vector Telemetry Runtime Proof (`docs/MT7925_RXV_RUNTIME_PROOF.md`)

This document records the Phase 1–7 empirical results of compiling, loading, capturing, analyzing, and rolling back the non-intrusive MT7925 Passive RX-Vector Telemetry ring buffer (`mt7925_rxv_telemetry`).

---

## 1. Executive Summary & Measured Results

| Phase / Metric | Measured Result | Verdict |
|---|---|---|
| **Reproducible Build Automation** | `tools/build-canonical-rxv-telemetry.sh` compiled & signed telemetry modules | **`PASS [RUNTIME PROVEN]`** |
| **Telemetry Patch Loaded** | `mt7925-common.ko` (`c62ccf87...`) & `mt7925e.ko` (`edafd535...`) loaded under Secure Boot | **`PASS [RUNTIME PROVEN]`** |
| **MT7925 PCI Bound** | Bound cleanly (`ASIC revision: 79250000`, `HW/SW Version: 0x8a108a10`) | **`PASS [RUNTIME PROVEN]`** |
| **DebugFS Node Registered** | `/sys/kernel/debug/ieee80211/phy20/mt7925_rxv_telemetry` (`0444`) | **`PASS [RUNTIME PROVEN]`** |
| **Quiet Baseline Capture** | 512 bytes captured (4 RXV samples) in 10-second background run | **`PASS [RUNTIME PROVEN]`** |
| **Active AR9271 Burst Capture** | 1,536 bytes captured (12 RXV samples) during active AR9271 frame transmission | **`PASS [RUNTIME PROVEN]`** |
| **Dropped Telemetry Samples** | `0` dropped samples (Ring size 4,096 items) | **`PASS`** |
| **Differential RCPI0-RCPI1** | RCPI0 mean: -62.50 dBm, RCPI1 mean: -57.58 dBm, Differential mean: **-4.92 dB** | **`MEASURED`** |
| **C-RXV Entropy Analysis** | Words 7 & 8 exhibited high entropy (12 unique values across 12 packets) | **`MEASURED`** |
| **Post-Test Rollback** | Controlled rollback restored stock signed driver `/lib/modules/.../mt7925e.ko.zst` | **`PASS [RUNTIME PROVEN]`** |
| **Sensing Value Classification** | **`MEDIUM`** (Coarse presence detection, spatial trilateration, link quality monitoring) | **`CLASSIFIED`** |

---

## 2. Statistical Time-Series & Differential Analysis

```text
=== PARSED 12 ACTIVE RXV SAMPLES ===
RCPI0 Stats: Mean = -62.50 dBm, Std = 8.45 dB, Min = -76 dBm, Max = -45 dBm
RCPI1 Stats: Mean = -57.58 dBm, Std = 8.31 dB, Min = -72 dBm, Max = -45 dBm
Differential RCPI0-RCPI1: Mean = -4.92 dB, Std = 1.71 dB

=== C-RXV WORD ENTROPY & VARIANCE ANALYSIS (24 WORDS) ===
C-RXV Word  0: Unique Values =  1, Variance =         0.00, Hex Head = 0x00000000
C-RXV Word  1: Unique Values =  1, Variance =         0.00, Hex Head = 0x00000000
C-RXV Word  2: Unique Values =  6, Variance = 88997368352874.66, Hex Head = 0x00000080
C-RXV Word  7: Unique Values = 12, Variance = 1075107787951053696.00, Hex Head = 0x75d0ccd5
C-RXV Word  8: Unique Values = 12, Variance = 661333929140365184.00, Hex Head = 0x7f2f8053
```
