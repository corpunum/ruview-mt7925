# Evidence Policy & Classification Guidelines

This document defines the strict classification standards required for all technical claims, experiment logs, and research reports in this repository.

## Evidence Classifications

### [RUNTIME PROVEN]
Observed directly on real physical hardware (`MediaTek MT7925`) and backed by reproducible runtime logs, eBPF trace outputs, or binary artifacts.

### [SOURCE PROVEN]
Confirmed through line-by-line inspection of authoritative open-source repositories (e.g., Linux kernel, `mt76` driver tree), referencing exact commit hashes, file paths, and line numbers.

### [STATISTICALLY INFERRED]
Supported by empirical measurements or mathematical models (e.g., entropy calculation, variance analysis) but not yet semantically decoded.

### [ASSUMED]
An unverified engineering hypothesis awaiting physical runtime or source code validation.

### [UNKNOWN]
Insufficient evidence to form a definitive engineering conclusion.

### [FAILED]
An attempted runtime operation or command sequence did not succeed (e.g., returned an error code like `-EOPNOTSUPP`).

### [REJECTED]
Empirical evidence explicitly contradicted a prior hypothesis or interpretation.

---

## Experiment Report Requirements

Every experimental log submitted to `docs/experiment-log.md` or `experiments/` MUST contain:

1. **Date and Timezone:** e.g., `2026-08-06T15:30:00+03:00`
2. **Host Hardware Summary:** CPU, Wi-Fi PCIe card (`14c3:0717`), System model
3. **Kernel Version:** `uname -r` output (e.g., `7.0.0-28-generic`)
4. **Repository Branch and Commit:** `git rev-parse HEAD`
5. **Exact Commands Executed:** Shell command strings
6. **Expected Result:** Hypothesis
7. **Observed Result:** Empirical stdout/stderr and exit code
8. **Raw Log Location:** Path to saved output or trace artifact
9. **Network and Safety Impact:** Effect on active Wi-Fi / SSH
10. **Cleanup and Rollback Result:** Verification that system was restored cleanly
11. **Evidence Classifications:** Tagged summary of outcomes (`[RUNTIME PROVEN]`, `[FAILED]`, etc.)
