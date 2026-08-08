#!/usr/bin/env bash
set -euo pipefail

# RuView MT7925 Household Sensing Platform Start Script
REPO_DIR="/home/corpunum/projects/ruview-mt7925"
RUVIEW_UI_DIR="/home/corpunum/ruview-upstream/ui"
ILLUMINATOR_MODE="${1:-AR9271_LOW}"

HTTP_PORT=3080
WS_PORT=3081

echo "=================================================="
echo "   STARTING RUVIEW MT7925 HOUSEHOLD SENSING PLATFORM   "
echo "=================================================="

cd "$REPO_DIR"

echo "=== STEP 1: PREFLIGHT & GATE 1 DRIVER REPLACEMENT ==="
bash tools/runtime/gate1-driver-replacement.sh --preflight

echo "=== EXECUTING GATE 1 SIGNED TELEMETRY DRIVER REPLACEMENT ==="
echo -n "3-2:1.0" | sudo tee /sys/bus/usb/drivers/ath9k_htc/unbind 2>/dev/null || true
sudo rmmod ath9k_htc ath9k_common ath9k_hw ath 2>/dev/null || true

sudo bash tools/runtime/gate1-driver-replacement.sh --execute-gate1

DEBUGFS_NODE=$(sudo find /sys/kernel/debug/ -name "mt7925_rxv_telemetry" | head -n 1)
if [ -z "$DEBUGFS_NODE" ]; then
    echo "[!] Error: MT7925 DebugFS telemetry node not found!"
    sudo bash tools/runtime/rollback-mt7925.sh
    exit 1
fi
echo "[+] MT7925 Telemetry Node: $DEBUGFS_NODE"

echo "=== STEP 2: CONFIGURING MT7925 PROMISCUOUS MONITOR MODE ==="
MT7925_IF="wlp195s0"
sudo ip link set "$MT7925_IF" down
sudo iw dev "$MT7925_IF" set type monitor 2>/dev/null || true
sudo ip link set "$MT7925_IF" up
sudo iw dev "$MT7925_IF" set channel 6 HT20

echo "=== STEP 3: STARTING AR9271 RF ILLUMINATOR ($ILLUMINATOR_MODE) ==="
bash tools/rf-illuminator.sh "$ILLUMINATOR_MODE"

echo "=== STEP 4: STARTING RUVIEW MT7925 WEBSOCKET BRIDGE (PORT $WS_PORT) ==="
sudo pkill -f "ruview-mt7925-bridge.py" 2>/dev/null || true
sudo python3 tools/ruview-mt7925-bridge.py --node "$DEBUGFS_NODE" --port "$WS_PORT" --mode "$ILLUMINATOR_MODE" > /tmp/ruview_bridge.log 2>&1 &
BRIDGE_PID=$!
echo "[+] Bridge started on port $WS_PORT with PID $BRIDGE_PID"

echo "=== STEP 5: LAUNCHING RUVIEW WEB FRONTEND (PORT $HTTP_PORT) ==="
sudo pkill -f "python3 -m http.server $HTTP_PORT" 2>/dev/null || true
cd "$RUVIEW_UI_DIR"
python3 -m http.server "$HTTP_PORT" > /tmp/ruview_ui.log 2>&1 &
UI_PID=$!
echo "[+] RuView UI HTTP server started on port $HTTP_PORT (PID $UI_PID)"

LAN_IP=$(ip -4 addr show dev eno1 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n 1 || echo "127.0.0.1")
TAILSCALE_IP=$(ip -4 addr show dev tailscale0 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n 1 || echo "N/A")

echo ""
echo "=================================================="
echo "RUVIEW LAN URL:        http://$LAN_IP:$HTTP_PORT/index.html"
echo "RUVIEW TAILSCALE URL:  http://$TAILSCALE_IP:$HTTP_PORT/index.html"
echo "MODE:                  $ILLUMINATOR_MODE"
echo "HTTP PORT:             $HTTP_PORT"
echo "WEBSOCKET PORT:        $WS_PORT"
echo "MT7925:                PCIe Wi-Fi 7 (14c3:0717) [ACTIVE TELEMETRY]"
echo "AR9271:                USB 802.11n (0cf3:9271) [RF ILLUMINATOR]"
echo "LIVE SAMPLE RATE:      ~65.0 - 117.6 samples/sec"
echo "PRESENCE DETECTION:    ACTIVE (Adaptive Baseline Classifier)"
echo "MOTION DETECTION:      ACTIVE (RCPI Differential Variance)"
echo "TRUE CSI:              NO (Scalar RX-Vector Telemetry Mode)"
echo "SPATIAL LOCALIZATION:   NO (Dispersed Proxy Signal Field)"
echo "=================================================="
echo ""
echo "[+] RuView MT7925 Household Sensing Platform is now LIVE."
