# Current Target Environment Specification

This document records the exact, sanitized hardware, kernel, module, firmware, and security configuration of the primary target platform.

## Environment Summary

- **OS / Distro:** Ubuntu 24.04.1 LTS
- **Running Kernel:** `7.0.0-28-generic` (x86_64)
- **Kernel Build:** `7.0.0-28-generic #28~24.04.1-Ubuntu SMP PREEMPT_DYNAMIC`
- **Compiler:** `x86_64-linux-gnu-gcc-13 (Ubuntu 13.3.0-6ubuntu2~24.04.1)`

## Target Hardware & PCI Details

- **Wi-Fi Chipset:** MediaTek MT7925 / RZ717 Wi-Fi 7 PCIe Adapter
- **PCI Subsystem ID:** `14c3:0717` (also matches alias `14c3:7925`)
- **Driver Module:** `mt7925e`

## Active Driver Modules & Dependencies

- `mt7925e.ko` (`drivers/net/wireless/mediatek/mt76/mt7925/mt7925e.ko.zst`)
- `mt7925-common.ko` (`drivers/net/wireless/mediatek/mt76/mt7925/mt7925-common.ko.zst`)
- `mt76-connac-lib.ko` (`drivers/net/wireless/mediatek/mt76/mt76-connac-lib.ko.zst`)
- `mt76.ko` (`drivers/net/wireless/mediatek/mt76/mt76.ko.zst`)
- Module `vermagic`: `7.0.0-28-generic SMP preempt mod_unload modversions`

## Firmware Blobs

- Patch MCU Header: `mediatek/mt7925/WIFI_MT7925_PATCH_MCU_1_1_hdr.bin`
- RAM Runtime Code: `mediatek/mt7925/WIFI_RAM_CODE_MT7925_1_1.bin`

## Security & Lockdown Enforcements

- **`CONFIG_NL80211_TESTMODE`:** `# CONFIG_NL80211_TESTMODE is not set` (Disabled in stock kernel)
- **Secure Boot State:** `SecureBoot enabled` (Requires PKCS#7 signed `.ko` modules or MOK key enrollment to load out-of-tree modules)
- **Kernel Lockdown:** `none [integrity] confidentiality` (Integrity lockdown active; unsigned kernel module loading blocked by kernel)
