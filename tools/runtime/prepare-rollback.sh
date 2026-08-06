#!/usr/bin/env bash
# Safety & Rollback Preparation Script for MT7925 Testing
# Usage: sudo bash tools/runtime/prepare-rollback.sh [timeout_sec]

set -euo pipefail

TIMEOUT_SEC="${1:-60}"
LOG_FILE="/tmp/mt7925_rollback.log"
CANCEL_FLAG="/tmp/mt7925_test_success"

echo "[*] Preparing MT7925 Runtime Test Rollback Timer (${TIMEOUT_SEC}s)..." | tee "$LOG_FILE"
rm -f "$CANCEL_FLAG"

# Verify stock module availability
if ! modinfo mt7925e >/dev/null 2>&1; then
    echo "[!] ERROR: Stock mt7925e module not available in system path. Refusing execution." | tee -a "$LOG_FILE"
    exit 1
fi

echo "[+] Stock module verification PASSED." | tee -a "$LOG_FILE"

# Launch background systemd-independent recovery daemon
(
    sleep "$TIMEOUT_SEC"
    if [ ! -f "$CANCEL_FLAG" ]; then
        echo "[!] TIMEOUT EXPIRED without success signal. Executing emergency rollback..." >> "$LOG_FILE"
        sudo rmmod mt7925e mt7925_common 2>> "$LOG_FILE" || true
        sudo modprobe mt7925e 2>> "$LOG_FILE" || true
        echo "[+] Emergency rollback executed at $(date)." >> "$LOG_FILE"
    else
        echo "[+] Test marked SUCCESS. Rollback cancelled at $(date)." >> "$LOG_FILE"
    fi
) &

TIMER_PID=$!
echo "$TIMER_PID" > /tmp/mt7925_rollback.pid
echo "[+] Rollback timer armed (PID $TIMER_PID, Timeout ${TIMEOUT_SEC}s)." | tee -a "$LOG_FILE"
