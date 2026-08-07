# Project Status & Production Engineering Readiness

## Summary Declaration

**GATE 1 DRIVER REPLACEMENT WAS EXECUTED AND PASSED 100% ON AUGUST 6, 2026 (`docs/runtime/GATE1_RESULTS.md`).**

**POST-MORTEM INVESTIGATION COMPLETE (`docs/runtime/REBOOT_POSTMORTEM.md`):** The reboot hang observed after Gate 1 was **RUNTIME VERIFIED** to be caused by a firmware/WMI deadlock in the secondary USB Wi-Fi adapter (`ath9k_htc`), triggered by a global mac80211 regulatory domain update upon unloading MT7925. MT7925 and RuView code are **100% EXONERATED**.

**ACTIVE HARDWARE TARGETS ESTABLISHED:** Primary Target: Onboard MediaTek MT7925 (Wi-Fi 7 PCIe `14c3:0717`). Secondary Target: USB TP-Link TL-WN722N v1.0 (Atheros AR9271 `0cf3:9271`). *(TL-WDR3600 investigation is DEFERRED / OUT OF CURRENT SCOPE)*.

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
- Target secondary USB adapter: TP-Link TL-WN722N v1.0, USB VID:PID `0cf3:9271` (Qualcomm Atheros AR9271). Bound to `ath9k_htc`. `[RUNTIME PROVEN]`
- Stock AR9271 firmware backed up to `/tmp/ar9271_stock_backup/htc_9271-1.4.0.fw.zst` (`SHA256 1ec4cdf...`). `[RUNTIME PROVEN]`
- Safe USB sysfs unbind (`echo 3-2:1.0 > /sys/bus/usb/drivers/ath9k_htc/unbind`) and `rmmod` tested and verified clean. `[RUNTIME PROVEN]`
- AR9271 CSI Feasibility Evaluation: **`CSI_RUNTIME_FAILED`** (AR9271 USB HTC firmware architecture does not expose raw OFDM subcarrier CSI matrices). Authored [`docs/AR9271_CSI_ANALYSIS.md`](docs/AR9271_CSI_ANALYSIS.md). `[RUNTIME PROVEN]`
- Primary SSH route uses wired Ethernet (`eno1`, metric 100). SSH remained 100% active throughout driver replacement. `[RUNTIME PROVEN]`
- Automated rollback daemon (`tools/runtime/prepare-rollback.sh`) disarmed cleanly upon success. `[RUNTIME PROVEN]`
- Stock driver restoration script (`tools/runtime/rollback-mt7925.sh`) restored in-tree stock signed modules post-test. `[RUNTIME PROVEN]`

---

## Source Proven (`[SOURCE PROVEN]`)

- MT7925 testmode structures and command opcode `MCU_UNI_CMD_TESTMODE_CTRL = 0x46` exist in source (`SP-001`).
- A fixed-size 512-byte synchronous testmode response buffer is copied from `skb->data + 8` in `mt7925_tm_query()` (`SP-002`).

---

## Declaration

MT7925 Gate 1 driver replacement is RUNTIME PROVEN. MT7925 Gate 2 is READY.

TL-WN722N v1.0 hardware is RUNTIME PROVEN. Stock firmware backed up (`SHA256 1ec4cdf...`). AR9271 raw CSI extraction is `CSI_RUNTIME_FAILED` (unsupported by USB HTC firmware architecture). Serves as secondary packet injector.

Next milestone: Await explicit user authorization for MT7925 Gate 2 execution.
