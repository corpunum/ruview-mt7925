# Project Status & Production Engineering Readiness

## Summary Declaration

**GATE 1 DRIVER REPLACEMENT WAS EXECUTED AND PASSED 100% ON AUGUST 6, 2026 (`docs/runtime/GATE1_RESULTS.md`).**

**POST-MORTEM INVESTIGATION COMPLETE (`docs/runtime/REBOOT_POSTMORTEM.md`):** The reboot hang observed after Gate 1 was **RUNTIME VERIFIED** to be caused by a firmware/WMI deadlock in the secondary USB Wi-Fi adapter (`ath9k_htc`), triggered by a global mac80211 regulatory domain update upon unloading MT7925. MT7925 and RuView code are **100% EXONERATED**.

**DUAL HARDWARE SENSING PLATFORM ESTABLISHED:** RuView formally tracks two hardware backends: Primary Onboard MediaTek MT7925 (Wi-Fi 7 PCIe) and Secondary External TP-Link TL-WDR3600 v1.x (Atheros CSI reference).

---

## Runtime Proven (`[RUNTIME PROVEN]`)

- Target primary adapter: MediaTek MT7925, PCI ID `14c3:0717`. `[RUNTIME PROVEN]`
- Tested kernel: Ubuntu `7.0.0-28-generic`. `[RUNTIME PROVEN]`
- Secure Boot and kernel integrity lockdown were enabled. `[RUNTIME PROVEN]`
- Existing enrolled Machine Owner Key (`CN=corpunumRig Secure Boot Module Signature key`) verified in `.secondary` keyring (`86:AE`). `[RUNTIME PROVEN]`
- Gate 1 Driver Replacement executed cleanly (`docs/runtime/GATE1_RESULTS.md`). `[RUNTIME PROVEN]`
- Reboot hang post-mortem investigation complete (`docs/runtime/REBOOT_POSTMORTEM.md`). Root cause: `ath9k_htc` secondary USB dongle firmware freeze. `[RUNTIME PROVEN]`
- MT7925 driver and RuView codebase exonerated from shutdown stall. `[RUNTIME PROVEN]`
- Signed out-of-tree modules (`mt7925-common.ko`, `mt7925e.ko`) loaded and accepted under Secure Boot. `[RUNTIME PROVEN]`
- MT7925 PCI adapter bound cleanly (`ASIC revision: 79250000`, `HW/SW Version: 0x8a108a10`). `[RUNTIME PROVEN]`
- Primary SSH route uses wired Ethernet (`eno1`, metric 100). SSH remained 100% active throughout driver replacement. `[RUNTIME PROVEN]`
- Automated rollback daemon (`tools/runtime/prepare-rollback.sh`) disarmed cleanly upon success. `[RUNTIME PROVEN]`
- Stock driver restoration script (`tools/runtime/rollback-mt7925.sh`) restored in-tree stock signed modules post-test. `[RUNTIME PROVEN]`

---

## Statically Verified (`[STATICALLY VERIFIED]`)

- Secondary Target Firmware Build: OpenWrt 18.06 SquashFS image targeting TP-Link TL-WDR3600 v1.x built cleanly (`hardware/tl-wdr3600/README.md`). `[STATICALLY VERIFIED]`
- Factory image SHA256: `546569477ff01721002d49157b25185663508793d159bbedbea1c1f509641fd8`. `[STATICALLY VERIFIED]`
- Sysupgrade image SHA256: `08117b6798add73c01aea7a8e04845b2dd3a8f74595542e3c52a9c090c8d84a3`. `[STATICALLY VERIFIED]`
- Atheros CSI kernel module (`ar9003_csi.ko`) and user-space logger (`recvCSI`) integrated in build tree. `[STATICALLY VERIFIED]`
- WDR3600 Flashing Verdict: **`NOT_READY_FOR_FLASH`** (Requires physical router verification and revision sticker check). `[STATICALLY VERIFIED]`

---

## Source Proven (`[SOURCE PROVEN]`)

- MT7925 testmode structures and command opcode `MCU_UNI_CMD_TESTMODE_CTRL = 0x46` exist in source (`SP-001`).
- A fixed-size 512-byte synchronous testmode response buffer is copied from `skb->data + 8` in `mt7925_tm_query()` (`SP-002`).

---

## Declaration

Gate 1 driver replacement is RUNTIME PROVEN.

Secondary TL-WDR3600 firmware is STATICALLY VERIFIED (`NOT_READY_FOR_FLASH`).

Next milestone: Execute Gate 2 (Patch v3 DebugFS ICAP trigger validation) after explicit user authorization.

Actual CSI extraction is not proven on either device.
