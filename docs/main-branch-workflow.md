# Main-Only Workflow

This repository currently uses a single active branch: `main`.

## Operating Rules

1. All agent work is performed directly on `main`.
2. Pull latest `main` before editing (`git pull --ff-only origin main`).
3. Never force-push (`git push --force`).
4. Never rewrite published history.
5. Every commit must leave the repository buildable and documented.
6. Risky runtime experiments require an explicit approval gate.
7. Kernel modules, firmware, raw captures, and secrets are never committed.
8. `STATUS.md` must be updated whenever evidence changes.
9. Failed experiments must be documented honestly.
10. Temporary local branches are not allowed unless explicitly approved by the user.
