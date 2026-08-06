# Verified Engineering Facts

> **Authoritative Note:** This file documents verified facts. `STATUS.md` remains authoritative.

## Verified Runtime Facts

1. **Hardware ID:** MediaTek MT7925 PCIe Wi-Fi 7 adapter, PCI ID `14c3:0717`. `[RUNTIME PROVEN]`
2. **Kernel Environment:** Tested on Ubuntu `7.0.0-28-generic` with Secure Boot and kernel lockdown enabled. `[RUNTIME PROVEN]`
3. **Monitor Mode Coexistence:** Virtual monitor interface `mon0` can be created and activated alongside `wlp195s0` (Managed mode) with zero interruption to active SSH connections. `[RUNTIME PROVEN]`
4. **Stock Kernel Netlink Blocker:** Issuing Netlink vendor testmode commands on stock Ubuntu generic kernels fails with exit code 161 (`-95 EOPNOTSUPP`) because `CONFIG_NL80211_TESTMODE` is disabled in kernel config. `[RUNTIME PROVEN]`

## Verified Source Code Facts

Refer to [`docs/source-provenance.md`](source-provenance.md) for pinned repository, commit SHA, file path, function, and line range details:

1. **Testmode Command Structures (SP-001):** `mt76_connac_mcu.h:1351` defines `MCU_UNI_CMD_TESTMODE_CTRL = 0x46`. `[SOURCE PROVEN]`
2. **Synchronous Query Handler (SP-002):** `mt7925/testmode.c:86-119` (`mt7925_tm_query()`) copies 512 bytes (`MT7925_EVT_RSP_LEN`) from `skb->data + 8`. `[SOURCE PROVEN]`
3. **Unsolicited Event Drop (SP-003):** `mt7925/mcu.c:655-700` (`mt7925_mcu_uni_rx_unsolicited_event()`) drops unhandled unsolicited event IDs via `dev_kfree_skb(skb)`. `[SOURCE PROVEN]`
