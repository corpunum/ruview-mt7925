# Runtime Gate Checklist

Before executing Gate 1:

- Refer to [`docs/AGENT_TASK.md`](AGENT_TASK.md) as the **single authoritative execution document**.
- Verify current branch is `main`.
- Confirm latest pull completed.
- Confirm preflight passes (`sudo bash tools/runtime/gate1-driver-replacement.sh --preflight`).
- Verify rollback scripts exist in `tools/runtime/`.
- Verify Ethernet management session is active (`eno1`, metric 100).
- Start terminal logging.
- Execute Gate 1 only with explicit user approval (`sudo bash tools/runtime/gate1-driver-replacement.sh --execute-gate1`).
- Archive all runtime artifacts in `artifacts/runtime/<timestamp>/`.
- Update `STATUS.md` and `docs/AGENT_TASK.md` with measured results only.
