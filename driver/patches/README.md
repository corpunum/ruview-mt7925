# Experimental Driver Patches & Classification Index

This directory contains experimental research patches for the Linux kernel `mt76` driver (`drivers/net/wireless/mediatek/mt76/mt7925/debugfs.c`).

---

## Patch Lifecycle Classification Index

| Patch File | Documentation | Classification Tag | Build Status | Runtime Status | Summary / Notes |
|---|---|---|---|---|---|
| `experimental/mt7925-icap-proof-v3.patch` | [`experimental/mt7925-icap-proof-v3.md`](experimental/mt7925-icap-proof-v3.md) | **`[EXPERIMENTAL] [STATICALLY VALIDATED] [UNTESTED AT RUNTIME]`** | **STATICALLY VALIDATED** | **UNTESTED** | Active research DebugFS prototype (`icap_trigger`). Corrects all Patch v2 defects. |
| `experimental/mt7925-icap-proof-v2.patch` | [`experimental/REVIEW.md`](experimental/REVIEW.md) | **`[OBSOLETE] [SUPERSEDED BY V2 REVIEW]`** | **OBSOLETE** | **REJECTED** | Superseded due to TLV padding offset error and missing PM state restore. |
| `experimental/mt7925-icap-proof.patch` | — | **`[OBSOLETE] [SUPERSEDED BY V2]`** | **OBSOLETE** | **REJECTED** | Initial proof of concept. Superseded by v2 and v3. |

---

Refer to [`STATUS.md`](../../STATUS.md) and [`docs/REPOSITORY_AUDIT.md`](../../docs/REPOSITORY_AUDIT.md) for full empirical verification details.
