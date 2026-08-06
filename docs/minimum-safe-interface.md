# Minimal Safe Interface Design Specification

Specification for a research-only, non-persistent DebugFS interface for MT7925 ICAP testing.

## Interface Path

`/sys/kernel/debug/ieee80211/phy*/mt76/icap/`

## Nodes & Functionality

1. **`status` (Read-Only):** Returns current ICAP state (`DISABLED`, `ICAP_MODE_ACTIVE`, `ERROR`).
2. **`trigger` (Write-Only, Root Only):** Writing `1` initiates `CMD_TEST_CTRL_ACT_SWITCH_MODE_ICAP` (`0x02`) and issues `MCU_UNI_QUERY(TESTMODE_CTRL)`.
3. **`dump` (Read-Only, Root Only):** Streams the extracted 512-byte `uni_cmd_testmode_evt` payload to userspace via `simple_read_from_buffer()`.
4. **`cancel` (Write-Only, Root Only):** Writing `1` issues `CMD_TEST_CTRL_ACT_SWITCH_MODE_NORMAL` (`0x00`) and restores standard radio power management (`pm->enable = true`).

## Safety Guarantees

- **Device Mutex:** All MCU command dispatches hold `dev->mt76.mutex`.
- **Automatic Failure Recovery:** Any MCU timeout or DMA error automatically dispatches `SWITCH_MODE_NORMAL` before returning error to userspace.
- **Zero Uninitialized Memory:** Buffers are zeroed with `memset` before copy.
- **Root Only Permissions:** Nodes created with `0400` / `0200` file permissions (`S_IRUSR` / `S_IWUSR`).
