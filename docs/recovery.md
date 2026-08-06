# Recovery & Safety Procedures

## Network & SSH Recovery Protocol

Because development is conducted remotely over SSH, maintaining system accessibility and network stability is critical.

### 1. Non-Destructive Runtime Rule
- **NEVER** replace system kernel modules in `/lib/modules/`.
- **NEVER** run `depmod` or modify initramfs.
- **NEVER** overwrite `/boot/` configuration.
- **NEVER** disable Secure Boot or alter MOK settings remotely.

### 2. Interface Reset Procedure
If `mon0` or `wlp195s0` enters an unexpected state:
```bash
sudo ip link set mon0 down 2>/dev/null || true
sudo iw dev mon0 del 2>/dev/null || true
sudo systemctl restart NetworkManager
```

### 3. Out-of-Tree Driver Module Unload
If testing custom out-of-tree `mt7925e` modules built in temporary directories:
```bash
sudo rmmod mt7925e mt7925_common mt76_connac_lib mt76 2>/dev/null || true
sudo modprobe mt7925e
```
This cleanly restores stock signed Ubuntu kernel modules.
