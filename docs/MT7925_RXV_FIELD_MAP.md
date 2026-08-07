# MT7925 RX-Vector Bitfield & Descriptor Map (`docs/MT7925_RXV_FIELD_MAP.md`)

This document details the bitfield layout, word definitions, and empirical variance analysis for the MT7925 P-RXV (Phy-Rxv) and C-RXV (Channel-Rxv) hardware descriptor words.

---

## 1. P-RXV Bitfield Layout (4 DWORDs = 16 Bytes)

| DWORD Offset | Bit Range | Field Name | Empirical Behavior | Sensing Utility |
|---|---|---|---|---|
| **P-RXV DW0** | `[6:0]` | `MT_PRXV_TX_RATE` | Variable with sender MCS | Rate identification |
| **P-RXV DW0** | `[10:7]` | `MT_PRXV_NSTS` | Constant (1 stream for AR9271) | Spatial stream count |
| **P-RXV DW0** | `[11]` | `MT_PRXV_TXBF` | Flag (`0` for non-beamformed) | TxBF indicator |
| **P-RXV DW2** | `[2:0]` | `MT_PRXV_FRAME_MODE` | Constant (`0` for 20MHz) | Channel bandwidth |
| **P-RXV DW2** | `[14:11]` | `MT_PRXV_TX_MODE` | Constant (`2` for HT mode) | Modulation format |
| **P-RXV DW3** | `[7:0]` | `MT_PRXV_RCPI0` | **Highly Variable** (-76 to -45 dBm) | Primary antenna RSSI |
| **P-RXV DW3** | `[15:8]` | `MT_PRXV_RCPI1` | **Highly Variable** (-72 to -45 dBm) | Secondary antenna RSSI |
| **P-RXV DW3** | `[23:16]` | `MT_PRXV_RCPI2` | 0 (Unpopulated) | Antenna chain 2 |
| **P-RXV DW3** | `[31:24]` | `MT_PRXV_RCPI3` | 0 (Unpopulated) | Antenna chain 3 |

---

## 2. C-RXV Bitfield & Entropy Map (24 DWORDs = 96 Bytes)

| DWORD Index | Empirical Unique Values | Variance | Primary Field / High-Entropy Bits |
|---|---|---|---|
| **C-RXV DW0-1** | 1 | 0.00 | Reserved alignment words (`0x00000000`) |
| **C-RXV DW2** | 6 | 8.89e13 | HE/EHT Resource Unit allocations (`MT_CRXV_HE_RU0-2`) |
| **C-RXV DW3** | 2 | 1.27e15 | Spatial reuse masks |
| **C-RXV DW7** | **12** | **1.07e18** | **High Entropy:** Doppler, BSS Color (`MT_CRXV_HE_BSS_COLOR`), TXOP Duration |
| **C-RXV DW8** | **12** | **6.61e17** | **High Entropy:** Per-user AID, Beam Change indicators |
| **C-RXV DW9-23** | 4-7 | 1.0e16+ | EHT SIG MCS, LTF symbol counts, AGC gain state history |
