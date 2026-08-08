# RuView Integration Mapping & Compatibility Table (`docs/RUVIEW_INTEGRATION_MAP.md`)

This document documents Phase 2 feature mapping between RuView's expected sensing APIs and our proven MediaTek MT7925 Passive RX-Vector (P-RXV / C-RXV) telemetry stream.

---

## RuView Expected Feature Mapping Table

| RuView Expected Feature | MT7925 Available Equivalent | Capability Status | Transformation / Adapter Function |
|---|---|---|---|
| **`timestamp`** | `ts_ns` (Hardware ktime nanoseconds) | **EXACT** | Converted to Epoch seconds (`ts_ns / 1e9`) |
| **`mean_rssi`** | `RCPI0` / `RCPI1` average | **EXACT** | `(rcpi[0] + rcpi[1]) / 2.0` |
| **`variance` / `std`** | Rolling variance of `RCPI0 - RCPI1` | **EXACT** | Rolling window std dev over 20 samples |
| **`motion_band_power`** | Derivative of `RCPI0 - RCPI1` + C-RXV Word 7 entropy | **APPROXIMATE** | High-pass filtered RCPI differential variance |
| **`breathing_band_power`** | Low-pass filtered RCPI differential | **APPROXIMATE** | Low-pass filtered RCPI differential |
| **`presence` / `motion_level`** | Multi-feature adaptive threshold model | **EXACT** | Adaptive threshold classifier (`absent`, `present_still`, `active`) |
| **`confidence`** | Normalized classification margin | **EXACT** | `0.5 + 0.45 * (std / threshold)` bounded `[0.5, 0.98]` |
| **`subcarriers` / OFDM Matrix** | **UNAVAILABLE** (MT7925 lacks raw CSI) | **UNAVAILABLE** | Cleared / set to 0 (Labeled `NO TRUE CSI — RXV SENSING MODE`) |
| **`signal_field` / 3D Grid** | Signal variance proxy grid | **APPROXIMATE** | Radial Gaussian blob centered on MT7925 receiver |

---

## Ingestion Architecture

The adapter streams JSON payloads directly over WebSocket endpoint `/ws/sensing` matching RuView's exact schema:

```json
{
  "type": "sensing_update",
  "timestamp": 1723072200.123,
  "source": "mt7925_rxv",
  "_simulated": false,
  "nodes": [
    {
      "node_id": 1,
      "rssi_dbm": -60.5,
      "rcpi0": -60,
      "rcpi1": -61,
      "rcpi_diff": 1.0,
      "snr": 28,
      "subcarrier_count": 0
    }
  ],
  "features": {
    "mean_rssi": -60.5,
    "variance": 2.45,
    "std": 1.56,
    "motion_band_power": 0.18,
    "breathing_band_power": 0.04
  },
  "classification": {
    "motion_level": "active",
    "presence": true,
    "confidence": 0.88
  }
}
```
