# Patch Prototype v3 Specification

- **Purpose:** Corrects all defects identified in Review v2 and provides a safe, statically validated DebugFS research hook.
- **Target Commit SHA:** `b2704cf5a4068b672bf47ad5bf6b4802b6770a90`
- **Modified File:** `drivers/net/wireless/mediatek/mt76/mt7925/debugfs.c`
- **Design:**
  - Adds `/sys/kernel/debug/ieee80211/phy0/mt76/icap_trigger`.
  - Holds `dev->mt76.mutex` during command dispatch.
  - Temporarily sets `dev->pm.enable = false` and restores `dev->pm.enable = true` on both success and error paths.
  - Validates response `skb->len >= MT7925_EVT_RSP_LEN + 8` before freeing.
- **Limitations:** Research prototype only; not intended as final upstream public ABI.
- **Build Status:** **STATICALLY VALIDATED [COMPILATION SUCCESSFUL]**.
- **Runtime Status:** **UNTESTED AT RUNTIME**.
- **Secure Boot Constraints:** Out-of-tree module loading requires MOK key enrollment or explicit user approval under active Secure Boot.
- **Rollback Strategy:** `sudo rmmod mt7925e && sudo modprobe mt7925e`.
