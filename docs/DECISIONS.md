# Architectural & Engineering Decisions Log (`docs/DECISIONS.md`)

This document records all fundamental architectural and operational engineering decisions established during the MediaTek MT7925 Wi-Fi sensing research project.

---

## 1. Single Main-Branch Development Workflow
- **Decision:** All research, documentation, safety harness tools, and patches are committed directly to `main`. No feature branches or pull requests are created unless explicitly requested by the project lead.
- **Rationale:** Prevents context fragmentation, eliminates branch synchronization overhead, maintains an immutable linear commit log, and ensures CI validation runs continuously against the single source of truth.

---

## 2. Strict Evidence Classification Policy
- **Decision:** Technical claims must be tagged with explicit evidence qualifiers: `[RUNTIME PROVEN]`, `[SOURCE PROVEN]`, `[STATISTICALLY INFERRED]`, `[ASSUMED]`, `[UNKNOWN]`, `[FAILED]`, or `[REJECTED]`.
- **Rationale:** Eliminates speculative engineering assumptions. Prevents unverified source-derived inferences from being reported as runtime facts.

---

## 3. Mandatory Explicit User Approval Gate
- **Decision:** No kernel module loading, unloading, patch insertion, MOK key modification, or ICAP command execution may be performed without explicit, real-time user confirmation.
- **Rationale:** Ensures strict safety enforcement under active Secure Boot and prevents accidental host instability or SSH loss during remote development.

---

## 4. Rollback-First Safety Philosophy
- **Decision:** An automated, systemd-independent recovery daemon (`prepare-rollback.sh`) MUST be armed before any module load/unload step is executed.
- **Rationale:** Guarantees that if a driver load fails or an SSH session hangs, the system automatically restores stock signed kernel drivers without requiring physical access.

---

## 5. Upstream-First Architecture & Minimal Patch Footprint
- **Decision:** Prefer solutions that conform to upstream Linux `mt76`, `mac80211`, and `nl80211` standards. Avoid custom kernel/firmware modifications whenever userspace, eBPF, or standard Netlink testmode exposure can achieve the objective.
- **Rationale:** Ensures long-term maintainability, standalone RuView compatibility, and eventual mergeability into mainstream Linux kernel trees.

---

## 6. Empirical Runtime Evidence Primacy
- **Decision:** Runtime empirical measurement always overrides source code analysis or theoretical documentation.
- **Rationale:** Source code proves what *can* be called; runtime execution proves what *actually* happens on physical hardware.
