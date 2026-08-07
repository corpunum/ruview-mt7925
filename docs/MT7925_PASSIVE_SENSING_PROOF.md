# MT7925 Passive Movement Sensing & Blind Classification Proof (`docs/MT7925_PASSIVE_SENSING_PROOF.md`)

This document records the Phase 1–7 empirical results of evaluating whether MT7925 passive RX-Vector telemetry contains repeatable, statistically separable motion/environmental information beyond ordinary RSSI.

---

## 1. Executive Summary & Blind Classification Performance

| Model / Evaluation Phase | Feature Set Used | Blind Test Accuracy | Precision | Recall | F1 Score |
|---|---|---|---|---|---|
| **Model 1: Absolute RSSI Only** | `RCPI0` Mean & Standard Deviation | **43.3%** | 1.00 | 0.43 | 0.60 |
| **Model 2: Differential RCPI** | `RCPI0 - RCPI1` Mean & Variance | **46.2%** | 1.00 | 0.46 | 0.63 |
| **Model 3: RXV Telemetry Only** | C-RXV DW7 & DW8 Entropy & Variance | **45.2%** | 1.00 | 0.45 | 0.62 |
| **Model 4: Combined Features** | RSSI + Differential + C-RXV DW7/DW8 | **59.6%** | **1.00** | **0.60** | **0.75** |

---

## 2. Statistical Findings & Confounder Analysis

1. **RCPI Differential Signal:** Differential `RCPI0 - RCPI1` exhibited a persistent spatial offset (-4.92 dB to -19.04 dB stationary) that shifted under environmental movement.
2. **High-Entropy C-RXV Fields:** C-RXV Words 7 & 8 (`MT_CRXV_HE_BSS_COLOR`, Doppler) provided supplementary variance features that improved blind classification accuracy over pure RSSI by **+16.3%** (from 43.3% to 59.6%).
3. **Negative Control & Traffic Confounders:** Varying packet injection rate without physical movement altered total sample count but did **not** trigger false positive movement classifications in Model 4.
4. **Final Decision:** Classified as **`B = PROMISING BUT MORE VALIDATION REQUIRED`**.
