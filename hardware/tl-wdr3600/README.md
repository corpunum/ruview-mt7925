# TP-Link TL-WDR3600 v1.x Research & Firmware Assessment (`hardware/tl-wdr3600/README.md`)

This document records the build forensic audit, source provenance, and pre-flash assessment for the TP-Link TL-WDR3600 v1.x secondary sensing target.

---

## 1. Source Provenance & Build Specifications

- **Upstream Source Repository:** `Atheros_CSI_tool_OpenWRT_src` (`https://github.com/xieyaxiongfly/Atheros_CSI_tool_OpenWRT_src`)
- **OpenWrt Base Version:** OpenWrt 18.06 (`ar71xx` target, `generic` profile)
- **Kernel Version:** Linux `4.9.111` (`mips_24kc` architecture)
- **Build Container Environment:** Isolated Ubuntu Bionic Build Environment (`/tmp/bionic-build/`)
- **Toolchain:** `toolchain-mips_24kc_gcc-7.3.0_musl`

---

## 2. Generated Firmware Artifacts & SHA256 Hashes

| Firmware Image Type | Filename | Byte Size | SHA256 Hash |
|---|---|---|---|
| **Factory Image** | `openwrt-ar71xx-generic-tl-wdr3600-v1-squashfs-factory.bin` | `8,126,464 bytes` (~7.8 MB) | `546569477ff01721002d49157b25185663508793d159bbedbea1c1f509641fd8` |
| **Sysupgrade Image** | `openwrt-ar71xx-generic-tl-wdr3600-v1-squashfs-sysupgrade.bin` | `3,538,948 bytes` (~3.4 MB) | `08117b6798add73c01aea7a8e04845b2dd3a8f74595542e3c52a9c090c8d84a3` |

---

## 3. Forensic Content Verification

- **CSI Kernel Module:** Verified `ar9003_csi.c` and `ar9003_csi.h` integrated into `package/kernel/mac80211/csi/` and patched into `ath9k` (`554-ath9k_CSI_Makefile.patch`, `556-ath9k_CSI_ar9003mac.patch`). `[STATICALLY VERIFIED]`
- **User-Space Extractor:** Verified `package/recvCSI/` compiled user-space CSI logging utility (`recvCSI`). `[STATICALLY VERIFIED]`

---

## 4. Pre-Flash Safety & Flashing Verdict

- **Hardware Compatibility Warning:** Factory image targets **TL-WDR3600 v1.x ONLY**. Flashing onto v2.x hardware will brick the device.
- **Runtime Validation Status:** **UNTESTED AT RUNTIME `[UNTESTED]`**. Compilation success does NOT prove CSI extraction functionality on live hardware.
- **Flashing Readiness Verdict:** **`NOT_READY_FOR_FLASH`**
  - *Reason:* Flashing requires physical access / TFTP / web interface access to the physical router and verification of exact hardware revision sticker (v1.x).
