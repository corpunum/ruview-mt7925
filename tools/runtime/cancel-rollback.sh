#!/usr/bin/env bash
# Cancellation Script for MT7925 Rollback Timer
# Usage: sudo bash tools/runtime/cancel-rollback.sh

set -euo pipefail

CANCEL_FLAG="/tmp/mt7925_test_success"
LOG_FILE="/tmp/mt7925_rollback.log"

echo "[*] Signaling test SUCCESS and cancelling rollback timer..." | tee -a "$LOG_FILE"
touch "$CANCEL_FLAG"

if [ -f /tmp/mt7925_rollback.pid ]; then
    PID=$(cat /tmp/mt7925_rollback.pid)
    kill "$PID" 2>/dev/null || true
    rm -f /tmp/mt7925_rollback.pid
    echo "[+] Rollback process $PID cancelled." | tee -a "$LOG_FILE"
fi
