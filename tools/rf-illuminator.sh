#!/usr/bin/env bash
set -euo pipefail

# AR9271 Controlled RF Traffic Source / Illuminator Script
MODE="${1:-AR9271_LOW}"
IFACE="wlxf4ec3897c206"

echo "=== CONFIGURING AR9271 RF ILLUMINATOR MODE: $MODE ==="

# Check adapter availability
if ! ip link show dev "$IFACE" >/dev/null 2>&1; then
    echo "[!] Warning: Interface $IFACE not found. Attempting USB bind/modprobe..."
    sudo modprobe ath9k_htc 2>/dev/null || true
    echo -n "3-2:1.0" | sudo tee /sys/bus/usb/drivers/ath9k_htc/bind 2>/dev/null || true
    sleep 2
fi

if ! ip link show dev "$IFACE" >/dev/null 2>&1; then
    echo "[!] Error: AR9271 interface $IFACE unavailable."
    exit 1
fi

sudo ip link set "$IFACE" down
sudo iw dev "$IFACE" set type monitor 2>/dev/null || true
sudo ip link set "$IFACE" up
sudo iw dev "$IFACE" set channel 6 HT20

# Kill old illuminator loops
pkill -f "ping -I $IFACE" 2>/dev/null || true

case "$MODE" in
    PASSIVE)
        echo "[+] AR9271 set to PASSIVE mode (no active traffic injection)."
        ;;
    AR9271_LOW)
        echo "[+] AR9271 set to LOW mode (~50 PPS injection)."
        sudo ping -I "$IFACE" -i 0.02 -s 64 255.255.255.255 >/dev/null 2>&1 &
        ;;
    AR9271_MEDIUM)
        echo "[+] AR9271 set to MEDIUM mode (~200 PPS injection)."
        for i in {1..4}; do
            sudo ping -I "$IFACE" -i 0.005 -s 64 255.255.255.255 >/dev/null 2>&1 &
        done
        ;;
    *)
        echo "[!] Unknown mode: $MODE. Using AR9271_LOW."
        sudo ping -I "$IFACE" -i 0.02 -s 64 255.255.255.255 >/dev/null 2>&1 &
        ;;
esac

echo "[+] RF Illuminator setup complete."
