# Contributing Guidelines

Thank you for contributing to **ruview-mt7925**! This project focuses on upstream-oriented, standalone RuView Wi-Fi 7 sensing support for the MediaTek MT7925 chipset.

## Core Rules

1. **Upstream First:** All kernel patches must be designed for eventual submission to `linux-wireless` and `mt76`.
2. **Strict Evidence Standards:** Every technical claim must be tagged in accordance with [docs/evidence-policy.md](docs/evidence-policy.md) (`[RUNTIME PROVEN]`, `[SOURCE PROVEN]`, `[FAILED]`, etc.).
3. **Zero Secrets / Credentials:** Never commit credentials, PSKs, SSIDs, MAC addresses, or private keys. Always run `tools/sanitize-report.py`.
4. **No Binary Artifacts:** Do not commit compiled kernel modules (`.ko`), PCAPs (`.pcap`), or raw binary captures (`.bin`).

## Pull Request Process

1. Fork or branch from `main`.
2. Ensure CI validation passes (`.github/workflows/validate.yml`).
3. Fill out the [Pull Request Template](.github/pull_request_template.md).
