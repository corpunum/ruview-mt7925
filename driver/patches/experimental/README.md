# Experimental Patch Manifest

> Historical research artifact. `STATUS.md` is authoritative and may supersede conclusions in this file.

## Patch Draft Manifest

### 1. `mt7925-icap-proof-v2.patch`
- **Original Import Source:** Initial out-of-tree draft patch
- **Target Kernel:** Ubuntu `7.0.0-28-generic` / Linux `6.8+`
- **SHA256:** `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`
- **Known Defects:** Early draft contained structural errors (`mt7925_tm_cmd` structure mismatch with `mt7925_rftest_cmd`).
- **Review Status:** Requires major refactoring for clean `mac80211` integration.
- **Runtime Status:** **UNTESTED AT RUNTIME**. Not loaded due to Secure Boot and remote stability constraints.
