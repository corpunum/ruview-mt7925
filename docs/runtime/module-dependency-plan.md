# Module Dependency & Load Plan (`docs/runtime/module-dependency-plan.md`)

This document defines the complete kernel module dependency hierarchy, load order, unload order, and active dependent relationship mapping for MediaTek MT7925 testing.

---

## 1. Module Load Hierarchy & Dependencies

From `modprobe --show-depends mt7925e`:

```text
Level 0: libarc4.ko.zst
Level 1: cfg80211.ko.zst
Level 2: mac80211.ko.zst
Level 3: mt76.ko.zst
Level 4: mt76-connac-lib.ko.zst
Level 5: mt792x-lib.ko.zst
Level 6: mt7925-common.ko.zst  <--- Rebuilt by Patch v3
Level 7: mt7925e.ko.zst        <--- Rebuilt by Patch v3
```

---

## 2. Load and Unload Sequences

### Safe Unload Order (Bottom-Up)
1. `mt7925e` (PCIe Bus Driver)
2. `mt7925_common` (MT7925 Core Logic)
3. `mt792x_lib` (Shared MT792x Library)
4. `mt76_connac_lib` (Connac Architecture Helpers)
5. `mt76` (Core MediaTek Mac80211 Engine)

### Safe Load Order (Top-Down)
1. `mt76`
2. `mt76_connac_lib`
3. `mt792x_lib`
4. `mt7925_common`
5. `mt7925e`

---

## 3. Coexisting Drivers & Bluetooth Isolation

- **Other Devices on `mac80211` / `cfg80211`:** Secondary USB Wi-Fi adapter `ath9k_htc` is attached to `cfg80211`/`mac80211`.
- **Bluetooth Subsystem:** MediaTek Bluetooth (`btusb` / `btmtk`) runs on a separate USB endpoint or PCI function. Unloading `mt7925e` does **NOT** unload Bluetooth kernel modules.
