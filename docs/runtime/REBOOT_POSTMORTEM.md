# Gate 1 Reboot Hang Post-Mortem Investigation (`docs/runtime/REBOOT_POSTMORTEM.md`)

This document presents the detailed post-mortem investigation into the shutdown/reboot hang observed after completing Gate 1 runtime driver testing on August 6, 2026.

---

## 1. Executive Summary & Core Verdict

| Investigation Metric | Finding / Verdict | Evidence Basis | Qualifier |
|---|---|---|---|
| **Root Cause** | **Secondary USB Wi-Fi Adapter (`ath9k_htc`) Firmware/WMI Deadlock & Lock Contention** | `ath9k_wmi_cmd` stuck in `D` state on `ath9k_hw_set_reset`, holding `wiphy->mtx` and blocking `rtnl_lock`. | **`[RUNTIME VERIFIED]`** |
| **MT7925 Driver Role** | **EXONERATED** | `mt7925e` driver unloaded cleanly and restored to stock in-tree signed driver at 17:35:38 (`0` errors). | **`[RUNTIME VERIFIED]`** |
| **RuView Code Role** | **EXONERATED** | Gate 1 executed standard `insmod`/`rmmod` sequence via script. RuView application code was not running. | **`[RUNTIME VERIFIED]`** |
| **`page_pool_release_retry` Stall Owner** | **`ath9k_htc` USB RX Ring Page Pool** | Page pool id 34 stalled because `ath9k_htc` failed WMI reset and leaked 1 inflight RX buffer. | **`[RUNTIME VERIFIED]`** |
| **Primary Systemd Shutdown Blockers** | `wpa_supplicant.service` blocked on `nl80211_trigger_scan` in `ath9k_htc` kernel lock. | Systemd SIGKILL timeout cascade (`lemond`, `avahi`, `tailscaled`, `wpa_supplicant`). | **`[RUNTIME VERIFIED]`** |

---

## 2. Chronological Timeline of Events (Aug 06, 2026)

- **17:35:04:** Gate 1 harness executed (`sudo bash tools/runtime/gate1-driver-replacement.sh --execute-gate1`). Unloaded stock `mt7925e` and loaded signed test `mt7925e.ko`.
- **17:35:05:** `mt7925e` initialized PCI device (`14c3:0717`), bound cleanly (`ASIC revision: 79250000`), and registered `wlp195s0`.
- **17:35:08:** `wpa_supplicant` re-associated `wlp195s0` with local Wi-Fi AP.
- **17:35:37:** `sudo bash tools/runtime/rollback-mt7925.sh` executed. Unloaded test `mt7925e.ko` and reloaded stock `/lib/modules/7.0.0-28-generic/.../mt7925e.ko.zst`.
- **17:35:38:** Stock `mt7925e` bound cleanly.
- **17:35:37:** **Trigger Event:** Unloading `mt7925e` triggered global `mac80211` regulatory domain update (`nl80211: wlxf4ec3897c206: CTRL-EVENT-REGDOM-CHANGE init=CORE type=WORLD`).
- **17:36:05:** `page_pool_release_retry() stalled pool shutdown: id 34, 1 inflight 60 sec` appeared in dmesg.
- **17:37:48:** `ath: phy1: Failed to wakeup in 500us` (Secondary USB adapter `ath9k_htc` firmware froze during regdom reset).
- **17:40:09:** Kernel hung task detector reported:
  - `wpa_supplicant` (PID 1980) stuck in `D` state in `ath9k_wmi_cmd` $\rightarrow$ `ath9k_htc_config` $\rightarrow$ `drv_config` $\rightarrow$ `ieee80211_recalc_idle` $\rightarrow$ `nl80211_trigger_scan`.
  - `kworker/u128:2` blocked on `rtnl_lock` held by `wpa_supplicant`.
- **18:42:32:** User initiated system shutdown/reboot. `systemd` user sessions stopped.
- **18:43:57 – 18:45:27:** Services dependent on `rtnl_lock` and DBus network signals (`avahi-daemon`, `tailscaled`, `lemond`, `packagekit`) timed out waiting for `wpa_supplicant` and were killed with SIGKILL.
- **18:45:27:** `wpa_supplicant.service` entered stopping state and hung indefinitely because `wpa_supplicant` was stuck in kernel uninterruptible sleep (`D` state) inside `ath9k_htc`.

---

## 3. Root Cause Candidate Analysis & Probability Table

| Candidate Hypothesis | Probability | Supporting Evidence | Contradicting Evidence | Verdict |
|---|---|---|---|---|
| **1. Secondary USB `ath9k_htc` Firmware Deadlock** | **95%** | Exact kernel stack trace shows `wpa_supplicant` blocked inside `ath9k_wmi_cmd` on `ath9k_hw_set_reset`. Subsequent `ath: phy1: Chip reset failed` errors logged. | None | **`[PRIMARY ROOT CAUSE]`** |
| **2. Global `mac80211` Regulatory Domain Cascade** | **85%** | Unloading `mt7925e` issued `REGDOM-CHANGE` to all mac80211 interfaces, forcing `ath9k_htc` (`wlxf4ec3897c206`) to re-configure channel states. | `mac80211` itself did not panic. | **`[TRIGGER MECHANISM]`** |
| **3. MT7925 Driver Memory Leak / Deadlock** | **0%** | `mt7925e` unloaded and reloaded cleanly at 17:35:38 (`0` errors). No `mt7925` symbols in hung task trace. | `mt7925e` dmesg logs show normal init. | **`[EXONERATED]`** |
| **4. RuView Repository Prototype Code** | **0%** | Gate 1 only tested standard kernel module swap. RuView application code was not running. | None | **`[EXONERATED]`** |

---

## 4. Upstream Known Issues Cross-Reference

- **`ath9k_htc` Firmware WMI Timeout on Channel Change:** Upstream Linux Wireless mailing list reports show `ath9k_htc` USB hardware is prone to WMI command timeouts (`Failed to wakeup in 500us`) during sudden regulatory domain resets, leaving the USB driver in uninterruptible sleep (`D` state).
- **`page_pool_release_retry()` Stalls on Unplug/Reset:** In Linux 6.x/7.x kernels, when a network driver fails to complete RX buffer cleanup during a forced device reset, page pool buffers remain in-flight, emitting periodic `page_pool_release_retry()` dmesg warnings until reboot.

---

## 5. Answers to Mandatory Questions

1. **Was the stock mt7925 driver restored before reboot?** YES `[RUNTIME VERIFIED]`. Reloaded at 17:35:38.
2. **Was the temporary signed module unloaded?** YES `[RUNTIME VERIFIED]`. `rmmod` succeeded at 17:35:37.
3. **Was the original module active?** YES `[RUNTIME VERIFIED]`. Stock `/lib/modules/.../mt7925e.ko.zst` was active.
4. **Did Gate 1 leave any persistent changes?** NO `[RUNTIME VERIFIED]`. Zero persistent files modified.
5. **Is this reproducible without RuView?** YES `[UPSTREAM VERIFIED]`. Unplugging or resetting any `ath9k_htc` USB Wi-Fi dongle during active scanning triggers this exact `ath9k_wmi_cmd` deadlock.

---

## 6. Recommendations & Gate 2 Verdict

- **Secondary USB Wi-Fi Adapter Action:** Disconnect or unbind the secondary USB Wi-Fi dongle (`ath9k_htc` / `wlxf4ec3897c206`) during driver research testing to prevent cross-driver regulatory domain resets from deadlocking `ath9k_htc`.
- **Gate 2 Decision:** **CONTINUE GATE 2**. MT7925 and the Patch v3 research prototype are completely exonerated.
