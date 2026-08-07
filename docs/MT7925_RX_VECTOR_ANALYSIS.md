# MT7925 Passive RX-Vector Forensics & PHY Telemetry Analysis (`docs/MT7925_RX_VECTOR_ANALYSIS.md`)

This document records the Phase 1 deep forensic analysis of the MediaTek MT7925 operational RX-Vector / P-RXV / C-RXV hardware descriptor pipeline.

---

## 1. Complete RX-Vector Hardware Pipeline

In normal operational mode, the MT7925 MAC populates hardware RX descriptors (`RxD`) with up to 7 distinct descriptor groups:

```text
PCIe RX DMA Ring
  └─► skb->data
        ├─► RXD DW0-DW4 (Base Descriptor Header: Timestamp, Length, Key ID, AMSDU)
        ├─► RXD Group 3: P-RXV (Phy-Rxv 4 DWORDs)
        │      ├─► rxv[0]: MT_PRXV_TX_RATE, MT_PRXV_NSTS, MT_PRXV_TXBF, MT_PRXV_HE_RU_ALLOC
        │      ├─► rxv[1]: Reserved / PHY state
        │      ├─► rxv[2]: MT_PRXV_HT_SHORT_GI, MT_PRXV_HT_STBC, MT_PRXV_TX_MODE, MT_PRXV_FRAME_MODE
        │      └─► rxv[3]: MT_PRXV_RCPI0, MT_PRXV_RCPI1, MT_PRXV_RCPI2, MT_PRXV_RCPI3
        │
        └─► RXD Group 5: C-RXV (Channel-Rxv 24 DWORDs = 96 Bytes)
               ├─► rxv[4]: MT_CRXV_HE_LTF_SIZE, MT_CRXV_EHT_LTF_SIZE
               ├─► rxv[5]: MT_CRXV_HE_PE_DISAMBIG, MT_CRXV_HE_UPLINK
               ├─► rxv[7]: MT_CRXV_HE_DOPPLER, MT_CRXV_HE_BSS_COLOR
               └─► rxv[13-20]: Spatial Reuse Masks, EHT SIG MCS, LTF Symbols
```

---

## 2. Comprehensive RX-Vector Telemetry Matrix

| Telemetry Measurement | Source Field in Hardware RXD | Discarded by Stock Driver? | Radiotap Status |
|---|---|---|---|
| **Per-Chain RCPI (Ch 0-3)** | `MT_PRXV_RCPI0-3` (`rxv[3]`) | Exported to `status->chain_signal[0-3]` | Standard Radiotap RSSI |
| **Transmit Beamforming (TxBF)** | `MT_PRXV_TXBF` (`rxv[0]:BIT(11)`) | **DISCARDED** by `mt7925_mac_fill_rx()` | HE / EHT Radiotap Header |
| **HE / EHT RU Allocation** | `MT_PRXV_HE_RU_ALLOC` (`rxv[0]:GENMASK(30,22)`) | **DISCARDED** for non-EHT | HE Radiotap RU Field |
| **LTF Size & Symbol Count** | `MT_CRXV_HE_LTF_SIZE` (`rxv[4]:GENMASK(28,27)`) | Parsed for EHT/HE radiotap | HE / EHT Radiotap Header |
| **BSS Color & Doppler** | `MT_CRXV_HE_BSS_COLOR` (`rxv[7]:GENMASK(15,10)`) | **DISCARDED** | HE Radiotap Header |
| **Carrier Frequency Offset (CFO)** | Discarded in C-RXV Group 5 | **DISCARDED** | Not exposed in stock driver |

---

## 3. Discarded Telemetry Evaluation

Stock `mt7925_mac_fill_rx()` in `mac.c:510` skips 24 DWORDs of C-RXV metadata (`rxd += 24`) for standard 802.11a/b/g/n packets. Preserving these 96 bytes enables non-intrusive per-packet PHY telemetry logging without requiring MCU testmode switches or firmware modifications.
