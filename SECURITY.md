# Security Policy

## Reporting Vulnerabilities

If you discover a security vulnerability or potential kernel safety issue in this project:

1. **Do NOT open a public GitHub issue.**
2. Report the vulnerability privately to the project maintainers.
3. Include detailed steps to reproduce the issue and any relevant system logs.

## Security Scope

- **Kernel Module Safety:** Patches developed in this repository must not compromise kernel memory integrity or cause kernel panics.
- **Data Privacy:** Experimental reports must use `tools/sanitize-report.py` to strip all MAC addresses, IP addresses, network credentials, and personal identifiers before submission.
