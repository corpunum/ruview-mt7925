# MediaTek MT7925 Sensing Hardware Integration (`hardware/mt7925/README.md`)

This folder contains hardware-specific documentation, research notes, and test procedures for the primary MediaTek MT7925 Wi-Fi 7 PCI Express adapter.

---

## 1. Primary Target Metadata

- **Device Name:** MediaTek MT7925 802.11be Wi-Fi 7 PCI Express Adapter
- **PCI ID:** `14c3:0717`
- **Host Kernel:** Ubuntu `7.0.0-28-generic`
- **Driver Module Stack:** `mt7925e`, `mt7925_common`, `mt792x_lib`, `mt76_connac_lib`, `mt76`
- **Interface Mechanism:** MCU `TESTMODE_CTRL` DebugFS research hook (`icap_trigger` via `driver/patches/experimental/mt7925-icap-proof-v3.patch`)

---

## 2. Gate Verification Status

- **Gate 1 (Driver Replacement):** **PASS `[RUNTIME PROVEN]`** (Executed Aug 6, 2026; signed out-of-tree module loading, PCI binding, Ethernet SSH survival, and stock module restoration verified).
- **Reboot Post-Mortem:** **EXONERATED `[RUNTIME VERIFIED]`** (Shutdown hang isolated to secondary USB `ath9k_htc` dongle WMI freeze).
- **Gate 2 (DebugFS ICAP Trigger):** **READY FOR GATE 2 `[STATICALLY VALIDATED]`** (Awaiting explicit user invocation).
