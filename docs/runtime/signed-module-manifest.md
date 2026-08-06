# Signed Module Manifest (`docs/runtime/signed-module-manifest.md`)

This document records the exact, sanitized metadata for the signed disposable Patch v3 module artifacts built for Gate 1 testing.

---

## 1. Pinned Source & Build Environment

- **Target Kernel:** `7.0.0-28-generic` (Ubuntu 24.04.1 LTS)
- **Upstream Baseline:** [`https://github.com/openwrt/mt76`](https://github.com/openwrt/mt76) (Commit `b2704cf5a4068b672bf47ad5bf6b4802b6770a90`)
- **Patch Applied:** Patch v3 (`driver/patches/experimental/mt7925-icap-proof-v3.patch`)
- **Root-Only Runtime Directory:** `/var/tmp/mt7925_gate1/` (Permissions `0700`, owned by `root`).

---

## 2. Module Artifact Manifest

| Module File | File Size | SHA256 Hash (After Signing) | Signer Common Name | Vermagic | Status |
|---|---|---|---|---|---|
| `mt7925-common.ko` | ~5.0 MB | `2070913608358a3c2dba412898040e9dce9a42a9f37f24ee6fc7e321467f6e2a` | `<existing-enrolled-MOK-certificate>` | `7.0.0-28-generic` | `SIGNED_METADATA_VERIFIED` |
| `mt7925e.ko` | ~1.9 MB | `8fe6fadc2c483fdfcb76b41aa1ead8fb700ee7f57a7a85fcfbb25e417e36fde8` | `<existing-enrolled-MOK-certificate>` | `7.0.0-28-generic` | `SIGNED_METADATA_VERIFIED` |

---

## 3. ABI Linkage & Mixed Compatibility Assessment

- **Linkage Test:** Symbols exported by stock `mt792x_lib.ko.zst`, `mt76_connac_lib.ko.zst`, and `mt76.ko.zst` match all undefined symbol references in patched `mt7925-common.ko` and `mt7925e.ko`.
- **Mixed ABI Verdict:** **PASS [SOURCE & HEADER VERIFIED]**. Replacing only `mt7925_common` and `mt7925e` while retaining stock system `mt792x_lib`, `mt76_connac_lib`, and `mt76` is ABI-compatible.
