# Patch v3 Static Validation & Compilation Record

- **Target Source:** `drivers/net/wireless/mediatek/mt76/mt7925/debugfs.c`
- **Pinned Upstream Commit:** `b2704cf5a4068b672bf47ad5bf6b4802b6770a90`
- **Target Kernel Header Version:** `7.0.0-28-generic` (Ubuntu 24.04.1)

## Isolated Build Commands

```bash
# 1. Prepare isolated build directory
rm -rf /tmp/build_v3 && mkdir -p /tmp/build_v3
cp -r /tmp/mt76_kernel/* /tmp/build_v3/

# 2. Apply patch v3 cleanly
python3 /tmp/build_v3_clean.py

# 3. Perform static compilation test (isolated object compilation)
make -C /lib/modules/$(uname -r)/build M=/tmp/build_v3/mt7925 \
  EXTRA_CFLAGS="-I/tmp/build_v3 -include linux/version.h" debugfs.o
```

## Compilation Outcome

- **Status:** **STATIC COMPILATION SUCCESSFUL [COMPILATION SUCCESS]**
- **Output Object File:** `/tmp/build_v3/mt7925/debugfs.o`
- **Object Size:** `670 KB` (text: 12046 bytes, data: 2152 bytes)
- **Runtime Status:** **UNTESTED AT RUNTIME [UNTESTED]**
- **Secure Boot State:** `SecureBoot enabled` (Module insertion blocked until MOK key is enrolled or user explicitly approves testing).
