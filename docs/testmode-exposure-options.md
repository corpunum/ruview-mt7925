# Testmode Exposure Options Analysis

Evaluation of all potential technical approaches to expose MT7925 testmode / ICAP capabilities on Linux.

## Comparison Matrix

| Approach | Files Changed | Est. LOC | ABI & Upstream Impact | Secure Boot / Deployability | Payload Support | Overall Suitability |
|---|---|---|---|---|---|---|
| **A. Enable `CONFIG_NL80211_TESTMODE` in Kernel** | `/boot/config-*` | 0 | Standard upstream `nl80211` ABI | Requires custom kernel package | Synchronous: YES<br>Async: Partial | Excellent for Linux distros |
| **B. Native `mt76` / `nl80211` Extension** | `mt7925/testmode.c`, `nl80211.c` | ~60 | Upstream-candidate netlink API | Requires signed module build | Synchronous: YES<br>Async: YES | **Best Upstream Goal** |
| **C. DebugFS Research Trigger (`icap_dump`)** | `mt7925/debugfs.c`, `mt7925/testmode.c` | ~45 | DebugFS node (Non-ABI) | Requires signed module build | Synchronous: YES<br>Async: YES | **Best Experimental Prototype** |
| **D. Standard Vendor Interface** | None | 0 | Standard Netlink | Fails on stock Ubuntu (`-95`) | Synchronous: YES<br>Async: NO | Blocked by kernel config |
| **E. Pure eBPF / `ftrace` Read-Only** | None | 0 | No kernel changes | 100% Remote Deployable | Synchronous: NO<br>Async: Read-Only | Cannot inject commands |
| **F. Upstream `mt76` Git Master** | `mt76` core | ~50 | Upstream master tracking | Requires out-of-tree build | Synchronous: YES<br>Async: YES | Long-term target |

## Detailed Evaluation

### Option A: Custom Kernel Package (`CONFIG_NL80211_TESTMODE=y`)
- **Pros:** Standard upstream `nl80211` testmode interface supported by `iw dev mon0 vendor send`.
- **Cons:** Requires rebuilding full kernel Debian packages; heavy deployment overhead.

### Option B: Upstream `mt76` Patch Series (Target Strategy)
- **Pros:** Upstream-friendly, clean `mac80211` integration, submit-ready for `linux-wireless`.
- **Cons:** Must pass strict `netdev` / `linux-wireless` review guidelines.

### Option C: Minimal DebugFS Research Prototype (Phase 2 Target)
- **Pros:** Lowest risk (45 LOC), zero ABI breakage, exposes simple read/write nodes under `/sys/kernel/debug/ieee80211/phy0/mt76/`.
- **Cons:** DebugFS is not intended for production end-user applications.
