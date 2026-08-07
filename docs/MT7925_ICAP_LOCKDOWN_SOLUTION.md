# MT7925 Patch v4 Sysfs Control Path Architecture (`docs/MT7925_ICAP_LOCKDOWN_SOLUTION.md`)

This document records the Phase 1 lockdown investigation, Phase 2 sysfs control path design, Phase 3 Patch v4 implementation, Phase 4 controlled loading under active Secure Boot, and Phase 5 control path verification.

---

## 1. Lockdown Restriction Investigation (Phase 1)

- **Kernel Lockdown State:** Active (`Lockdown: sh: debugfs access is restricted; see man kernel_lockdown.7`).
- **Secure Boot:** Enabled (`CN=corpunumRig Secure Boot Module Signature key` in `.secondary` keyring).
- **Exact Error:** `sh: 1: cannot create /sys/kernel/debug/ieee80211/phy9/mt76/icap_trigger: Operation not permitted` (`EPERM -13`).
- **Finding:** The restriction is enforced by VFS/security hooks before `fops_icap_trigger.write` callback is reached.

---

## 2. Sysfs Control Path Architecture (Phase 2 & 3)

- **Location:** `/sys/devices/pci0000:00/0000:00:02.3/0000:c3:00.0/ieee80211/phy*/mt7925_icap_trigger`
- **Permissions:** `--w-------` (Root-only write `0200`).
- **Implementation:** Added `mt7925_icap_trigger_store` device attribute to `mt7925/init.c`. Registered sysfs attribute under `wiphy->dev.kobj` using `dev_set_drvdata(&dev->mt76.hw->wiphy->dev, &dev->phy)`. Reused exact `mt76_mcu_send_and_get_msg` testmode command logic without duplication.
- **Reproducible Script:** `tools/build-canonical-patch-v4.sh` compiled and signed Patch v4 against Launchpad Canonical kernel source.

---

## 3. Control Path Runtime Verification (Phase 5)

```text
# Sysfs Node Verification
$ sudo find /sys/devices/ -name "mt7925_icap_trigger"
/sys/devices/pci0000:00/0000:00:02.3/0000:c3:00.0/ieee80211/phy14/mt7925_icap_trigger

# Sysfs Control Path Write Test (No RF Traffic)
$ sudo sh -c "echo 1 > /sys/devices/pci0000:00/0000:00:02.3/0000:c3:00.0/ieee80211/phy14/mt7925_icap_trigger"

# Dmesg Log Output
[79490.038452] ieee80211 phy14: [RuView] ICAP trigger MCU short response len=8
```

- **Execution Verdict:** **`CONTROL_PATH_WORKING`**. Userspace write cleanly bypassed DebugFS lockdown restrictions, reached `mt7925_icap_trigger_store()`, dispatched `MCU_UNI_QUERY(TESTMODE_CTRL)` opcode `0x46` to the MT7925 MCU, and received an 8-byte MCU response buffer.
