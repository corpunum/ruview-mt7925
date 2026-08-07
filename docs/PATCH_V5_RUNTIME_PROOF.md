# MT7925 Patch v5 Two-Stage Testmode Sequence Runtime Proof (`docs/PATCH_V5_RUNTIME_PROOF.md`)

This document records the Phase 1-6 empirical results of executing the Patch v5 Two-Stage Testmode sequence (`MT76_TM_STATE_ON` -> `SWITCH_MODE_RF_TEST` -> `SWITCH_MODE_ICAP` -> `MCU_UNI_QUERY(TESTMODE_RX_STAT)`).

---

## 1. Executive Summary & Measured Results

| Phase / Metric | Measured Result | Verdict |
|---|---|---|
| **Reproducible Build Script** | `tools/build-canonical-patch-v5.sh` compiled & signed Patch v5 modules | **`PASS [RUNTIME PROVEN]`** |
| **Patch v5 Loaded** | `mt7925-common.ko` (`2220ac9d...`) & `mt7925e.ko` (`d86a0553...`) loaded under Secure Boot | **`PASS [RUNTIME PROVEN]`** |
| **MT7925 PCI Bound** | Bound cleanly (`ASIC revision: 79250000`, `HW/SW Version: 0x8a108a10`) | **`PASS [RUNTIME PROVEN]`** |
| **Stage 1 (Power Lock & TM State)** | `mdev->pm.enable = false`, `mdev->mt76.phy.test.state = MT76_TM_STATE_ON` | **`PASS [RUNTIME PROVEN]`** |
| **Stage 2 (SWITCH_MODE_RF_TEST)** | `CMD_TEST_CTRL_ACT_SWITCH_MODE_RF_TEST` dispatched & accepted by MCU | **`PASS [RUNTIME PROVEN]`** |
| **Stage 3 (SWITCH_MODE_ICAP)** | `CMD_TEST_CTRL_ACT_SWITCH_MODE_ICAP` dispatched & accepted by MCU | **`PASS [RUNTIME PROVEN]`** |
| **Stage 4 (TESTMODE_RX_STAT Query)** | `MCU_UNI_QUERY(TESTMODE_RX_STAT)` returned **8-byte** payload (`len=8`) | **`PASS [RUNTIME PROVEN]`** |
| **Returned Payload Hex** | `32 00 00 00 bb 00 00 c0` (Payload SHA256: `90b16f394e3e3bcf44ed1e959ce53d10098f9e612ebf1e9444158fb731c34a2e`) | **`STATUS_ONLY`** |
| **A/B RF Traffic Difference** | Quiet: 8-byte status returned. Active RF Burst: MCU query timed out (-110) | **`MEASURED`** |
| **Post-Test Rollback** | Controlled rollback restored stock signed driver `/lib/modules/.../mt7925e.ko.zst` | **`PASS [RUNTIME PROVEN]`** |
| **Final Classification** | **`STATUS_ONLY` / `CSI_NOT_PROVEN`** | **`CLASSIFIED`** |

---

## 2. Detailed Stage-by-Stage Kernel Log Evidence

```text
[105250.807995] ieee80211 phy17: [RuView V5] Stage 1: Power Lock complete, PM disabled
[105250.808027] ieee80211 phy17: [RuView V5] Stage 2: SWITCH_MODE_RF_TEST SUCCESS!
[105250.808032] ieee80211 phy17: [RuView V5] Stage 3: SWITCH_MODE_ICAP SUCCESS!
[105250.811819] ieee80211 phy17: [RuView V5] Stage 4: TESTMODE_RX_STAT SUCCESS! Payload len=8
[105250.811823] [RuView V5 RX_STAT] 00000000: 32 00 00 00 bb 00 00 c0
```

---

## 3. Structural Deconstruction of V5 `TESTMODE_RX_STAT` Payload

- **Length:** 8 bytes (`len=8`).
- **Raw Hex:** `32 00 00 00 bb 00 00 c0`
- **Field Analysis:**
  - Bytes `0x00`-`0x03`: `0x00000032` (MCU command ID `0x32` ACK for `MCU_UNI_QUERY(TESTMODE_RX_STAT)`).
  - Bytes `0x04`-`0x07`: `0xc00000bb` (MCU status flags: `0xbb` opcode status, `0xc0` internal PHY state mask).
- **CSI Verdict:** The response is a static 8-byte status/state snapshot header. Zero subcarrier channel matrices or I/Q sample arrays were returned (`CSI_NOT_PROVEN`).
