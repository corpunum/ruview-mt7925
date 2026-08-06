#!/usr/bin/env bash
# Emergency Direct Rollback Script for MT7925
# Usage: sudo bash tools/runtime/rollback-mt7925.sh

set -euo pipefail

LOG_FILE="/tmp/mt7925_rollback.log"

echo "[*] Executing manual emergency rollback of MT7925 driver..." | tee -a "$LOG_FILE"

# Unload out-of-tree / test modules
sudo rmmod mt7925e mt7925_common 2>> "$LOG_FILE" || true

# Reload stock signed in-tree module
sudo modprobe mt7925e 2>> "$LOG_FILE"

echo "[+] Stock MT7925 driver reloaded successfully at $(date)." | tee -a "$LOG_FILE"
