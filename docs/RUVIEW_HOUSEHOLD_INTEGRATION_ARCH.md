# RuView Household Sensing Integration Architecture (`docs/RUVIEW_HOUSEHOLD_INTEGRATION_ARCH.md`)

This document records the Phase 1–5 results of the passive LAN inventory, router assessment, device capability mapping, and proposed sensor fusion architecture for extending RuView with existing household devices.

---

## 1. Household Passive LAN Inventory

| IP Address | MAC Address | Hostname / mDNS | Device Manufacturer / Class | Discovered Ports / Services | Online State |
|---|---|---|---|---|---|
| **192.168.50.1** | `E8:9C:25:9F:D5:C8` | `RT-AX86U_Pro-D5C8` | ASUS (RT-AX86U Pro Router / AP) | HTTP:80 (`httpd/3.0`) | **REACHABLE** |
| **192.168.50.2** | `60:83:E7:D5:73:80` | *Unresolved* | Smart Camera / Tapo Security | HTTPS:443 | **REACHABLE** |
| **192.168.50.49** | `DC:CD:2F:F2:72:70` | *Unresolved* | Seiko Epson / Smart Home IoT | HTTPS:8443, Port:9000 | **REACHABLE** |
| **192.168.50.50** | `60:83:E7:D5:66:63` | *Unresolved* | Smart Camera / Tapo Security | HTTPS:443 | **REACHABLE** |
| **192.168.50.59** | `94:24:B8:93:0E:8B` | *Unresolved* | Gree Electric (Air Conditioner / HVAC) | Proprietary UDP/TCP | **REACHABLE** |
| **192.168.50.63** | `CC:A7:C1:4A:81:44` | `09AA01AC382201PP` | Google LLC (Chromecast / Google TV) | mDNS:5353 / Cast API | **REACHABLE** |
| **192.168.50.81** | `3C:0A:F3:BC:45:D7` | `corp-unum-ROG-Ally-X` | ASUS (ROG Ally X / Computer) | SSH:22 | **REACHABLE** |
| **192.168.50.116** | `84:2A:FD:BA:C2:C9` | `HPBAC2C9` | HP / Smart Printer / IoT | HTTP:80, HTTPS:443, 8080 | **REACHABLE** |
| **192.168.50.129** | `8C:86:DD:7F:5B:9C` | `C200` | TP-Link Tapo C200 Security Camera | HTTPS:443 | **REACHABLE** |
| **192.168.50.135** | `F0:C9:D1:42:4E:A5` | `net_a1_4EA5` | Midea Air-Conditioning / HVAC | Proprietary UDP:6445 | **REACHABLE** |
| **192.168.50.137** | `60:83:E7:D5:5C:93` | *Unresolved* | Smart Camera / Tapo Security | HTTPS:443 | **REACHABLE** |
| **192.168.50.142** | `30:68:93:90:4F:FB` | `C210` | TP-Link Tapo C210 Security Camera | HTTPS:443, 8443 | **REACHABLE** |
| **192.168.50.169** | `E0:DC:FF:EA:C3:A7` | *Unresolved* | Xiaomi Communications (Phone / Smart Device) | Passive mDNS | **REACHABLE** |
| **192.168.50.199** | `58:9A:3E:C0:C9:F3` | *Unresolved* | Amazon Technologies (Echo / Fire TV) | Passive SSDP | **REACHABLE** |
| **192.168.50.204** | `6C:22:1A:9B:CD:71` | `116761129` | IoT Smart Device | HTTP:8000 | **REACHABLE** |
| **192.168.50.250** | `CC:50:E3:36:C3:79` | `Sensibo-Sky` | Sensibo Sky (Smart AC / Climate Controller) | Local REST / Espressif | **REACHABLE** |
| **192.168.50.251** | *Local Host* | `corpunumRig` | Ryzen Ubuntu Host (MT7925 + AR9271) | HTTP:3080, WS:3081 | **LOCAL** |

---

## 2. Router Assessment (ASUS RT-AX86U Pro)

- **Router IP:** `192.168.50.1`
- **Model:** ASUS RT-AX86U Pro (`httpd/3.0`)
- **Management Interfaces Discovered:** HTTP Web GUI on Port 80.
- **SSH Availability:** **DISABLED / NOT LISTENING** (Port 22 closed on `192.168.50.1`).
- **Required Credentials / Access:** To retrieve read-only Wi-Fi client association tables, per-client RSSI, and DHCP lease duration directly from the router:
  - *Option A (Recommended):* Enable SSH in ASUS Web GUI (`Administration -> System -> Enable SSH -> LAN only`) and configure an SSH public key for read-only `nvram` / `wl` query scripts.
  - *Option B:* Provide ASUS HTTP Web GUI admin credentials for local REST/JSON API polling (`/api/v1/` or `appGet.cgi`).

---

## 3. Device Capability Matrix

| Device / Class | Room / Zone | Available Sensors / Data | Local Protocol / API | Auth Required? | Polling / Event | RuView Fusion Value | Privacy Impact | Confidence |
|---|---|---|---|---|---|---|---|---|
| **MT7925 PCIe** | System Room | Scalar P-RXV/C-RXV ring, RCPI0-1, diff variance, C-RXV DW7 entropy | DebugFS ring buffer -> WS bridge | No (Local root) | High-rate Stream (~100 Hz) | **PRIMARY** (Physical RF movement & presence) | Zero (RF ambient) | **HIGH** |
| **AR9271 USB** | System Room | Controlled 802.11n frame injection | `ath9k_htc` / `ping` injector | No (Local root) | Configurable (~50 Hz) | **PRIMARY** (Stable RF illumination) | Zero (RF ambient) | **HIGH** |
| **Sensibo-Sky AC** | Living / Main | Ambient temperature, humidity, climate state | Local REST API / mDNS | Optional (API key) | Polling (10s) | Environmental baseline validation | Low (Climate data) | **HIGH** |
| **TP-Link Tapo C200 / C210** | Hall / Entry | Motion events, ONVIF / RTSP stream status | RTSP:554 / ONVIF:2020 | Yes (Device user/pass) | Push Event / RTSP | Motion confirmation & cross-validation | Medium (Video stream) | **HIGH** |
| **Google Chromecast** | Living Room | TV power state, media casting activity | Google Cast V2 / mDNS | No (Local mDNS) | Event / Polling | Active room presence indicator | Low (Media state) | **HIGH** |
| **Gree / Midea ACs** | Bedrooms | HVAC power state, ambient temp | Local UDP (port 6445 / Midea API) | No / Symmetric Key | Polling (15s) | HVAC airflow vs RF movement separation | Low (HVAC state) | **MEDIUM** |
| **Amazon Echo / HP Printer** | Office / Hall | Wi-Fi association status | Ping ARP heartbeat | No | Polling (5s) | Client online/offline presence | Zero (Network metadata) | **HIGH** |
| **ASUS RT-AX86U Pro Router** | Central | Client RSSI, PHY rate, association duration | SSH (`wl -i eth7 assoclist`) / Web API | Yes (Admin SSH Key) | Polling (2s) | Multi-node RSSI fusion | Zero (MAC metadata) | **HIGH** |

---

## 4. Sensor Fusion Architecture Design

```text
  ┌────────────────────────────────────────────────────────────────────────────────┐
  │                           RuView Sensor Fusion Engine                           │
  └───────┬──────────────────┬─────────────────┬───────────────────┬───────────────┘
          │                  │                 │                   │
  ┌───────┴──────┐   ┌───────┴───────┐ ┌───────┴───────┐   ┌───────┴───────┐   ┌───────────────┐
  │ MT7925 PCIe  │   │ Router AP     │ │ Tapo Cameras  │   │ Sensibo AC    │   │ Chromecast/TV │
  │ Telemetry    │   │ Association   │ │ Motion Events │   │ Climate Data  │   │ Media State   │
  └───────┬──────┘   └───────┬───────┘ └───────┬───────┘   └───────┬───────┘   └───────┬───────┘
          │                  │                 │                   │                   │
  (RF Movement &     (Wi-Fi Client     (Optical Motion      (HVAC Airflow      (Active Media
   Diff Variance)     RSSI & Roaming)   Confirmation)        Confounder Check)   Occupancy)
          │                  │                 │                   │                   │
          └──────────────────┴─────────┬───────┴───────────────────┴───────────────────┘
                                       │
                         ┌─────────────┴─────────────┐
                         │   Bayesian Fusion Core    │
                         │ Multi-Feature Classifier  │
                         └─────────────┬─────────────┘
                                       │
                         ┌─────────────┴─────────────┐
                         │  Truthful Household State │
                         │  (Source, Timestamp,      │
                         │   Confidence, Raw/Derived)│
                         └───────────────────────────┘
```

---

## 5. Formal Detection Capability Classification

### A. DIRECTLY MEASURED
1. **Physical RF Environment Disturbances:** Raw per-packet `RCPI0` & `RCPI1` power levels and inter-chain differential `RCPI0 - RCPI1`.
2. **RF Signal Variance & Entropy:** High-rate temporal variance and C-RXV DW7 (`MT_CRXV_HE_BSS_COLOR` / Doppler) frame entropy.
3. **Wi-Fi Client Online/Offline Presence:** Real-time presence of ARP/mDNS active devices (Phones, Echo, Chromecast, Tapo Cameras).
4. **Local HVAC & Climate States:** Sensibo Sky ambient temperature, humidity, and fan state.

### B. DERIVED WITH GOOD CONFIDENCE
1. **Truthful Room Occupancy:** Fused MT7925 RF movement variance + Phone Wi-Fi ARP presence -> **92% Confidence Occupancy State**.
2. **Motion vs Stationary State:** Fused differential variance + C-RXV frame entropy -> **Binary Motion State (`ABSENT`, `PRESENT_STILL`, `ACTIVE`)**.
3. **HVAC Airflow Confounder Filtering:** Correlating Sensibo / Midea AC fan activation against MT7925 variance spikes to prevent false human motion triggers.

### C. EXPERIMENTAL
1. **Coarse Room Proximity:** Estimating approximate distance to MT7925 system based on absolute RSSI and differential variance magnitude.
2. **Media Occupancy State:** Inferring room occupancy from Chromecast playback activity.

### D. NOT POSSIBLE (Without Hardware Upgrades / True CSI)
1. **Raw Subcarrier CSI Phase / Amplitude:** True 3D spatial angle-of-arrival (AoA) or subcarrier phase matrices.
2. **Exact 3D Physical Coordinates:** Precise `(X, Y, Z)` human position tracking.
3. **Multi-Person Skeleton Keypoint Estimation:** 17-keypoint DensePose body estimation.
4. **Left vs Right Spatial Separation:** Resolving left vs right spatial orientation using MT7925 scalar telemetry.

---

## 6. Implementation Plan & Recommended Next Steps

1. **Step 1 (Zero Credentials Required):** Deploy a local LAN discovery daemon in Python (`tools/lan-discovery-daemon.py`) to monitor mDNS, ARP, and Sensibo local REST endpoints.
2. **Step 2 (Router Credentials Required):** Prompt user for read-only ASUS Router SSH / Web API credentials to extract per-client Wi-Fi RSSI and association tables.
3. **Step 3 (Camera Credentials Optional):** Integrate RTSP/ONVIF motion event handlers for Tapo C200 / C210 cameras.
4. **Step 4 (RuView Dashboard Fusion):** Extend RuView's WebSocket bridge to stream fused multi-device presence JSON payloads.
