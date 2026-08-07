# Hardware Sensing Comparison (`docs/hardware/csi-hardware-comparison.md`)

Engineering comparison between the Primary MT7925 onboard sensing target and the Secondary TL-WDR3600 external reference target.

---

## Technical Comparison Matrix

| Technical Feature | Primary Onboard Target (MT7925) | Secondary External Target (TL-WDR3600 v1.x) |
|---|---|---|
| **Chipset** | MediaTek MT7925 | Atheros AR9344 (2.4 GHz) + AR9580 (5 GHz) |
| **Wi-Fi Generation** | Wi-Fi 7 (802.11be / ax / ac / n) | Wi-Fi 4 (802.11n / a / b / g) |
| **Bus Type** | PCI Express (`14c3:0717`) | System-on-Chip (ar71xx MIPS 24Kc) |
| **Operating System** | Host Linux Kernel (Ubuntu `7.0.0-28-generic`) | Embedded OpenWrt (ar71xx 18.06 base) |
| **Driver Engine** | Linux `mt76` / `mt7925e` | `ath9k` (`ar9003_csi.ko`) |
| **CSI Mechanism** | MCU `TESTMODE_CTRL` ICAP Query / Event | Atheros CSI Tool Netlink Frame Injection |
| **CSI Maturity** | `[EXPERIMENTAL] [STATICALLY VALIDATED]` | `[SOURCE VERIFIED] [STATICALLY VERIFIED]` |
| **Required Modification** | Kernel driver DebugFS hook (Patch v3) | Custom OpenWrt SquashFS Firmware Flash |
| **Max Channel Bandwidth** | 160 MHz / 320 MHz | 20 MHz / 40 MHz |
| **MIMO Streams** | 2x2 | 2x2 (AR9344) / 3x3 (AR9580) |
| **Subcarriers** | Up to 120 / 242+ subcarriers | 56 subcarriers (HT20) / 114 subcarriers (HT40) |
| **Data Fields** | Complex I/Q (Amplitude & Phase) | Complex I/Q (Amplitude & Phase) |
| **Remote Risk** | Medium (Driver replacement fail-closed) | High (Potential router bricking on flash) |
| **Current Status** | Gate 1 Executed (`PASS`); Gate 2 Ready | Firmware Built; Flashing Pending |
