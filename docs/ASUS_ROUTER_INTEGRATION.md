# ASUS Router Read-Only Telemetry Integration (`docs/ASUS_ROUTER_INTEGRATION.md`)

This document records the read-only forensic discovery, client telemetry collector design, and sensor-fusion integration for the household ASUS RT-AX86U Pro router.

---

## 1. Router System & Wireless Architecture

- **Router Model:** ASUS RT-AX86U Pro (`RT-AX86U_Pro-D5C8`)
- **Firmware Version:** `3.0.0.6_102` (Stock ASUSWRT build 102)
- **Kernel Version:** Linux `4.19.183` SMP PREEMPT (`aarch64`)
- **SSH Management Port:** Port `1024` (`SSH-2.0-dropbear`)
- **Wireless Interfaces & Radios:**
  - `eth6` -> **2.4 GHz 802.11ax Radio** (Broadcom / Broadcom wl driver)
  - `eth7` -> **5 GHz 802.11ax Radio** (Broadcom / Broadcom wl driver)
- **DHCP Subsystem:** `dnsmasq` (`/var/lib/misc/dnsmasq.leases` or `/tmp/dhcp.leases`)

---

## 2. Read-Only Client Telemetry Data Sources

To extract client metadata without modifying configuration or executing write operations:

1. **Associated Station MAC List:**
   - Command: `wl -i eth6 assoclist` (2.4 GHz) & `wl -i eth7 assoclist` (5 GHz)
2. **Per-Station PHY Statistics:**
   - Command: `wl -i <iface> sta_info <MAC>`
   - Provides:
     - `smoothed rssi` (Per-station RSSI in dBm)
     - `rate of last tx pkt` & `rate of last rx pkt` (PHY speed in Kbps)
     - `per antenna rssi of last rx data frame`
     - `in network` (Connection duration in seconds)
     - `idle` (Inactivity duration in seconds)
3. **DHCP Leases:**
   - File: `/var/lib/misc/dnsmasq.leases`
   - Maps MAC addresses to IP addresses and hostnames.

---

## 3. Sensor Fusion & Household Presence State Machine

The RuView WebSocket bridge continuously fuses MT7925 RF movement signals with active router client associations:

- **`OCCUPIED_MOVING`:** MT7925 motion score > 2.5 + Active mobile Wi-Fi clients present (**Confidence 95–98%**).
- **`OCCUPIED_STILL`:** MT7925 motion score 1.3–2.5 + Active mobile Wi-Fi clients present (**Confidence 85–90%**).
- **`DEVICE_PRESENT_QUIET`:** MT7925 motion score quiet + Active mobile Wi-Fi clients present (**Confidence 80%**).
- **`EMPTY`:** MT7925 motion score quiet + Zero active mobile Wi-Fi clients (**Confidence 88%**).

---

## 4. Safety & Read-Only Audit

- **Router Configuration Writes (`nvram set`):** `ZERO`
- **Service Restarts / Reboots:** `ZERO`
- **Firewall / Routing Alterations:** `ZERO`
- **Network Impact:** Clean, non-disruptive, read-only SSH queries.
