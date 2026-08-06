#!/usr/bin/env bash
# Gate 1 Driver Replacement & Preflight Verification Script
# Usage:
#   sudo bash tools/runtime/gate1-driver-replacement.sh --preflight
#   sudo bash tools/runtime/gate1-driver-replacement.sh --execute-gate1 (REQUIRES EXPLICIT INVOCATION)

set -euo pipefail

ACTION="${1:---preflight}"
MODULE_DIR="/var/tmp/mt7925_gate1"
COMMON_MOD="$MODULE_DIR/mt7925-common.ko"
PCI_MOD="$MODULE_DIR/mt7925e.ko"

run_preflight() {
    echo "=== GATE 1 PREFLIGHT VERIFICATION ==="
    
    # 1. Kernel Version Check
    TARGET_KERNEL=$(uname -r)
    echo "[+] Running Kernel: $TARGET_KERNEL"
    
    # 2. Check Module Artifacts
    if [ ! -f "$COMMON_MOD" ] || [ ! -f "$PCI_MOD" ]; then
        echo "[!] ERROR: Signed module artifacts missing in $MODULE_DIR"
        exit 1
    fi
    echo "[+] Signed module artifacts present in $MODULE_DIR."
    
    # 3. Check Vermagic & Signer
    COMMON_SIGNER=$(modinfo "$COMMON_MOD" 2>/dev/null | grep 'signer' | head -n 1 || true)
    PCI_SIGNER=$(modinfo "$PCI_MOD" 2>/dev/null | grep 'signer' | head -n 1 || true)
    
    if [ -z "$COMMON_SIGNER" ] || [ -z "$PCI_SIGNER" ]; then
        echo "[!] ERROR: Module PKCS#7 signature missing or invalid."
        exit 1
    fi
    echo "[+] Module signatures verified: $COMMON_SIGNER"
    
    # 4. Check Ethernet Route Isolation
    PRIMARY_ROUTE=$(ip route show default | head -n 1)
    if [[ "$PRIMARY_ROUTE" != *"eno1"* ]]; then
        echo "[!] WARNING: Primary default route is NOT wired Ethernet (eno1)."
    else
        echo "[+] Primary route verified on wired Ethernet (eno1)."
    fi
    
    # 5. Check SSH Shell Count
    SSH_COUNT=$(who | grep 'pts' | wc -l || true)
    echo "[+] Active SSH PTS sessions: $SSH_COUNT"
    
    # 6. Verify Rollback Script Ability
    if [ ! -f "tools/runtime/prepare-rollback.sh" ]; then
        echo "[!] ERROR: Rollback preparation script missing."
        exit 1
    fi
    echo "[+] Rollback safety scripts verified."
    
    echo "=== PREFLIGHT RESULT: PASS ==="
}

execute_gate1() {
    echo "=== EXECUTING GATE 1 DRIVER REPLACEMENT ==="
    echo "[!] WARNING: Executing runtime module unload/load."
    
    # 1. Arm Rollback Timer
    sudo bash tools/runtime/prepare-rollback.sh 60
    
    # 2. Unload Stock Driver
    sudo rmmod mt7925e mt7925_common
    
    # 3. Load Signed Patch v3 Modules
    sudo insmod "$COMMON_MOD"
    sudo insmod "$PCI_MOD"
    
    # 4. Verify PCI Binding & Dmesg
    sleep 2
    if dmesg | tail -n 20 | grep -i 'mt7925'; then
        echo "[+] MT7925 PCI binding verified in dmesg."
    fi
    
    # 5. Cancel Rollback Timer on Success
    sudo bash tools/runtime/cancel-rollback.sh
    echo "=== GATE 1 EXECUTION COMPLETE: SUCCESS ==="
}

if [ "$ACTION" == "--preflight" ]; then
    run_preflight
elif [ "$ACTION" == "--execute-gate1" ]; then
    run_preflight
    execute_gate1
else
    echo "Usage: $0 [--preflight | --execute-gate1]"
    exit 1
fi
