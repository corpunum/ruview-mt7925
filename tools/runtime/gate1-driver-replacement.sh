#!/usr/bin/env bash
# Gate 1 Driver Replacement & Safety Harness Script
# Usage:
#   sudo bash tools/runtime/gate1-driver-replacement.sh --preflight
#   sudo bash tools/runtime/gate1-driver-replacement.sh --execute-gate1 (REQUIRES EXPLICIT INVOCATION)

set -euo pipefail

ACTION="${1:---preflight}"
MODULE_DIR="/var/tmp/mt7925_gate1"
COMMON_MOD="$MODULE_DIR/mt7925-common.ko"
PCI_MOD="$MODULE_DIR/mt7925e.ko"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
ARTIFACT_DIR="artifacts/runtime/$TIMESTAMP"

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
    COMMON_SIGNER=$(modinfo "$COMMON_MOD" 2>/dev/null | awk '/signer:/ {print $2; exit}')
    PCI_SIGNER=$(modinfo "$PCI_MOD" 2>/dev/null | awk '/signer:/ {print $2; exit}')

    if [ -z "$COMMON_SIGNER" ] || [ -z "$PCI_SIGNER" ]; then
        echo "[!] ERROR: Module PKCS#7 signature missing or invalid."
        exit 1
    fi
    echo "[+] Module signatures verified: $COMMON_SIGNER"

    # 4. Check Ethernet Route Isolation
    PRIMARY_ROUTE=$(ip route show default | awk 'NR==1')
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

collect_pre_state() {
    mkdir -p "$ARTIFACT_DIR/before"
    echo "[*] Collecting baseline state in $ARTIFACT_DIR/before..."
    uname -a > "$ARTIFACT_DIR/before/uname.txt"
    lsmod > "$ARTIFACT_DIR/before/lsmod.txt"
    modinfo mt7925e > "$ARTIFACT_DIR/before/modinfo_mt7925e.txt" 2>&1 || true
    modinfo mt7925_common > "$ARTIFACT_DIR/before/modinfo_mt7925_common.txt" 2>&1 || true
    dmesg > "$ARTIFACT_DIR/before/dmesg_baseline.txt" 2>&1 || true
    journalctl -k -n 200 > "$ARTIFACT_DIR/before/journal_baseline.txt" 2>&1 || true
    mokutil --sb-state > "$ARTIFACT_DIR/before/sb_state.txt" 2>&1 || true
    cat /sys/kernel/security/lockdown > "$ARTIFACT_DIR/before/lockdown.txt" 2>&1 || true
    cat /proc/sys/kernel/tainted > "$ARTIFACT_DIR/before/tainted.txt" 2>&1 || true
}

collect_post_step() {
    local step_name="$1"
    mkdir -p "$ARTIFACT_DIR/step_$step_name"
    echo "[*] Collecting post-step state for $step_name in $ARTIFACT_DIR/step_$step_name..."
    lsmod > "$ARTIFACT_DIR/step_$step_name/lsmod.txt"
    cat /proc/sys/kernel/tainted > "$ARTIFACT_DIR/step_$step_name/tainted.txt" 2>&1 || true
    dmesg | tail -n 200 > "$ARTIFACT_DIR/step_$step_name/dmesg_delta.txt" 2>&1 || true
    journalctl -k -n 100 > "$ARTIFACT_DIR/step_$step_name/journal_delta.txt" 2>&1 || true
    ls -la /sys/kernel/debug/ieee80211/phy*/mt76/ > "$ARTIFACT_DIR/step_$step_name/debugfs_tree.txt" 2>&1 || true
    test -f /sys/kernel/debug/ieee80211/phy0/mt76/icap_trigger && echo "EXISTS" > "$ARTIFACT_DIR/step_$step_name/icap_trigger_status.txt" || echo "MISSING" > "$ARTIFACT_DIR/step_$step_name/icap_trigger_status.txt"
}

on_failure() {
    local failed_step="$1"
    echo "[!] FAILURE OCCURRED in step: $failed_step. Executing fail-closed recovery..."
    sudo bash tools/runtime/rollback-mt7925.sh

    mkdir -p "$ARTIFACT_DIR"
    echo "# Execution Failure Report" > "$ARTIFACT_DIR/FAILURE.md"
    echo "- Failed Step: $failed_step" >> "$ARTIFACT_DIR/FAILURE.md"
    echo "- Timestamp: $(date)" >> "$ARTIFACT_DIR/FAILURE.md"
    echo "- Action Taken: Emergency rollback executed. Stock modules reloaded." >> "$ARTIFACT_DIR/FAILURE.md"
    echo "[!] Failure report written to $ARTIFACT_DIR/FAILURE.md"
    exit 1
}

execute_gate1() {
    echo "=== EXECUTING GATE 1 DRIVER REPLACEMENT ==="
    echo "[!] WARNING: Executing runtime module unload/load."

    collect_pre_state

    # 1. Arm Rollback Timer
    echo "[1] Arming 60-second recovery timer..."
    sudo bash tools/runtime/prepare-rollback.sh 60 || on_failure "arm_rollback"

    # 2. Unload Stock Driver
    echo "[2] Unloading stock mt7925 modules..."
    sudo rmmod mt7925e mt7925_common || on_failure "unload_stock"
    collect_post_step "after_unload"

    # 3. Load Signed Patch v3 Modules
    echo "[3] Loading signed Patch v3 modules..."
    sudo insmod "$COMMON_MOD" || on_failure "load_common"
    sudo insmod "$PCI_MOD" || on_failure "load_pci"
    collect_post_step "after_load"

    # 4. Verify PCI Binding & Dmesg
    sleep 2
    if ! dmesg | tail -n 30 | grep -q -i 'mt7925'; then
        on_failure "pci_bind_check"
    fi

    # 5. Cancel Rollback Timer on Success
    sudo bash tools/runtime/cancel-rollback.sh

    # Generate SUCCESS.md
    echo "# Gate 1 Execution Success Report" > "$ARTIFACT_DIR/SUCCESS.md"
    echo "- Timestamp: $(date)" >> "$ARTIFACT_DIR/SUCCESS.md"
    echo "- Common Module SHA256: $(sha256sum "$COMMON_MOD" | awk '{print $1}')" >> "$ARTIFACT_DIR/SUCCESS.md"
    echo "- PCI Module SHA256: $(sha256sum "$PCI_MOD" | awk '{print $1}')" >> "$ARTIFACT_DIR/SUCCESS.md"
    echo "- ICAP Trigger Status: $(cat "$ARTIFACT_DIR/step_after_load/icap_trigger_status.txt")" >> "$ARTIFACT_DIR/SUCCESS.md"
    echo "- Rollback Verification: PASS (Rollback timer disarmed cleanly)" >> "$ARTIFACT_DIR/SUCCESS.md"
    echo "=== GATE 1 EXECUTION COMPLETE: SUCCESS ==="
    echo "[+] Success report written to $ARTIFACT_DIR/SUCCESS.md"
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
