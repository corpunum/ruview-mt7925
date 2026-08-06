# Open-Source Publication Readiness Evaluation (`docs/OPEN_SOURCE_READINESS.md`)

This document evaluates the `corpunum/ruview-mt7925` repository for eventual open-source release, detailing licensing, sanitization policies, directory structure, and contribution guidelines.

---

## 1. Upstream & Open-Source Principles

1. **Upstream-First Architecture:** Avoid proprietary kernel modifications or closed firmware blobs. All kernel driver work targets standard Linux `mt76`, `mac80211`, and `nl80211` interfaces.
2. **Strict Licensing Compliance:** Upstream `mt76` components retain `BSD-3-Clause-Clear` / `GPL-2.0`. Repository documentation and tools are licensed under `MIT`.
3. **Zero Credentials Policy:** Mandatory execution of `tools/sanitize-report.py` prior to committing log files or reports ensures zero MAC addresses, raw IP addresses, SSIDs, WPA keys, or private key paths are published.

---

## 2. Directory Restructuring & Organization Recommendations

| Current Path | Proposed Open-Source Organization | Action | Rationale |
|---|---|---|---|
| `driver/patches/experimental/` | `driver/patches/upstream-candidates/` | **RENAME** | Separate experimental research hooks from clean upstream-ready patch series. |
| `docs/history/` | `docs/history/` | **RETAIN** | Preserves chronological development audit trail for open-source transparency. |
| `tools/runtime/` | `tools/runtime/` | **RETAIN** | Core safety harness and automated rollback tooling for driver research. |

---

## 3. Recommended Community Guidelines & CI Enhancements

- **Sanitization CI Enforcement:** Enhance GitHub Actions `.github/workflows/validate.yml` to automatically execute `tools/sanitize-report.py` checking on all incoming commits.
- **Contribution Policy:** Document single-branch main policy and empirical evidence tagging (`[RUNTIME PROVEN]`, `[SOURCE PROVEN]`) in `CONTRIBUTING.md`.
