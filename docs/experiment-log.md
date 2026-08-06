# Experiment Log

> **Authoritative Status Note:** `STATUS.md` is authoritative.

## Log 2026-08-06-01: Baseline Netlink Vendor Command Attempt

- **Date / Timezone:** 2026-08-06T13:52:35+03:00
- **Host Hardware:** BOSGAME AMD Ryzen AI Max+ 395, MediaTek MT7925 PCIe (`14c3:0717`)
- **Kernel Version:** Ubuntu `7.0.0-28-generic`
- **Branch / Commit:** `main`
- **Exact Command:** `sudo iw dev mon0 vendor send 0x000c43 0x01 0x00000000`
- **Expected Result:** Vendor command dispatched to MT7925 driver.
- **Observed Result:** Exit code 161 (`-95 EOPNOTSUPP`). Stderr: `command failed: Operation not supported (-95)`.
- **Raw Log Location:** `/tmp/run_icap_experiment.py` output log.
- **Network / Safety Impact:** Zero impact. Active SSH session on `wlp195s0` remained 100% stable.
- **Cleanup & Rollback Result:** Interface `mon0` removed cleanly via `sudo iw dev mon0 del`.
- **Evidence Classifications:** `[RUNTIME PROVEN]` (Monitor mode coexistence), `[FAILED]` (Vendor command netlink dispatch).
