# Hardware Inventory & Electronic Discovery Audit (`docs/HARDWARE_INVENTORY.md`)

This document records the electronic discovery, network enumeration, and hardware status of all physical and PCI/USB-attached Wi-Fi sensing devices.

---

## 1. Physical & Bus Hardware Inventory

| Hardware Target | System Interface | Bus / Connection | Chipset / SoC | Hardware Revision | CSI Extraction Mechanism | Operational Status | Runtime Tested? | Next Recommended Action |
|---|---|---|---|---|---|---|---|---|
| **MediaTek MT7925** | `wlp195s0` / `mon0` | Onboard PCIe (`14c3:0717`) | MediaTek MT7925 | Production PCIe silicon | MCU `TESTMODE_CTRL` / DebugFS (`icap_trigger`) | **GATE1 = PASS [RUNTIME PROVEN]** / **GATE2 = READY** | **YES `[RUNTIME PROVEN]`** | Await explicit user authorization to execute Gate 2. |
| **Secondary USB Dongle** | `wlxf4ec3897c206` | USB 2.0 (`0cf3:9271`) | Qualcomm Atheros AR9271 | Rev 1.0 (USB) | Standard 802.11n `ath9k_htc` | **ACTIVE / DISCONNECTED** | **YES `[RUNTIME PROVEN]`** | Keep disconnected during MT7925 Gate 2 testing to prevent `ath9k_htc` WMI freeze. |
| **TP-Link TL-WDR3600** | `eno1` / Ethernet LAN | RJ45 Ethernet / Wireless | Atheros AR9344 + AR9580 | **UNKNOWN `[INFERRED v1.x]`** | Atheros CSI Tool (`ar9003_csi.ko`) | **MODEL_CONFIRMED_REVISION_UNKNOWN** | **NO `[UNTESTED]`** | Perform physical sticker / serial console check to confirm exact v1.x subrevision. |

---

## 2. Electronic Discovery Details

### MediaTek MT7925 (Primary Onboard Target)
- **Identification Method:** Direct Linux PCIe bus enumeration (`lsusb`, `lspci`, `modinfo`). `[RUNTIME PROVEN]`
- **Driver State:** Stock in-tree signed driver `/lib/modules/7.0.0-28-generic/.../mt7925e.ko.zst` active. `[RUNTIME PROVEN]`

### Qualcomm Atheros AR9271 (Secondary USB Dongle)
- **Identification Method:** USB bus enumeration (`lsusb`: `ID 0cf3:9271 Qualcomm Atheros AR9271 802.11n`, `dmesg`: `ieee80211 phy1: Atheros AR9271 Rev:1`). `[RUNTIME PROVEN]`

### TP-Link TL-WDR3600 (Secondary External Target)
- **Identification Method:** Electronic network probe (`ip link`, `ip addr`, `ip neigh`, `curl` HTTP/HTTPS probes).
- **Network Status:** The primary host network environment is connected via `eno1` to an upstream broadband gateway (`Xfinity Broadband Router Server` on `192.168.1.1`). No standalone OpenWrt or TP-Link HTTP management interface (`192.168.0.1` / `192.168.1.1`) responded with TP-Link headers electronically.
- **Hardware Version / Revision:** **UNKNOWN `[UNTESTED AT RUNTIME]`**. Electronic discovery confirms no active OpenWrt DHCP lease or management interface is currently exposed on local subnets.
