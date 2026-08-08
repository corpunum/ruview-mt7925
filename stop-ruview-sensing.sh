#!/usr/bin/env bash
set -euo pipefail

# RuView MT7925 Household Sensing Platform Shutdown Script

echo "=================================================="
echo "   STOPPING RUVIEW MT7925 HOUSEHOLD SENSING PLATFORM   "
echo "=================================================="

echo "[+] Terminating RuView UI HTTP server..."
pkill -f "python3 -m http.server 3000" 2>/dev/null || true

echo "[+] Terminating RuView WebSocket Bridge..."
pkill -f "ruview-mt7925-bridge.py" 2>/dev/null || true

echo "[+] Terminating AR9271 RF Illuminator..."
pkill -f "ping -I wlxf4ec3897c206" 2>/dev/null || true

echo "[+] Executing MT7925 controlled rollback to stock driver..."
sudo bash /home/corpunum/projects/ruview-mt7925/tools/runtime/rollback-mt7925.sh

echo "=================================================="
echo "[+] RuView MT7925 Sensing Platform stopped cleanly."
echo "=================================================="
