# Runtime Dependency Architecture (`docs/RUNTIME_DEPENDENCIES.md`)

This document maps all kernel module dependencies, load/unload hierarchies, kernel interfaces, DebugFS nodes, and artifact locations for MT7925 testing.

---

## 1. Kernel Module Load Hierarchy

```text
Level 0: libarc4.ko.zst          (Crypto Dependency)
Level 1: cfg80211.ko.zst         (Linux Wireless Configuration API)
Level 2: mac80211.ko.zst         (Linux IEEE 802.11 Core Subsystem)
Level 3: mt76.ko.zst             (MediaTek Core Driver Engine)
Level 4: mt76-connac-lib.ko.zst  (MediaTek Connac Hardware Library)
Level 5: mt792x-lib.ko.zst       (MediaTek MT792x Shared Library)
Level 6: mt7925-common.ko        (MT7925 Core Logic - Patch v3)
Level 7: mt7925e.ko              (MT7925 PCIe Bus Driver - Patch v3)
```

---

## 2. Load & Unload Sequences

- **Safe Unload Order (Bottom-Up):** `mt7925e` $\rightarrow$ `mt7925_common`
- **Safe Load Order (Top-Down):** `mt7925-common.ko` $\rightarrow$ `mt7925e.ko`

---

## 3. Kernel & User-Space Interfaces

- **DebugFS Research Node:** `/sys/kernel/debug/ieee80211/phy0/mt76/icap_trigger`
- **PCI Device Path:** `/sys/bus/pci/devices/0000:c3:00.0/` (Vendor ID `14c3`, Device ID `0717`)
- **Primary Management Network:** Wired Ethernet `eno1` (`ip route`: default metric 100).

---

## 4. Runtime Artifact Locations

- **Root-Only Module Directory:** `/var/tmp/mt7925_gate1/`
- **Runtime Execution Logs:** `artifacts/runtime/<timestamp>/`
- **Log Subdirectories:** `before/` (baseline state), `step_after_unload/`, `step_after_load/`
- **Report Outputs:** `SUCCESS.md` or `FAILURE.md`
