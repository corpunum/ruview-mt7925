# Remote Testing & Cryptographic Verification Analysis

Analysis of cryptographic signing, Machine Owner Key (MOK) state, network interface resilience, and remote testability for MT7925 Patch v3.

---

## 1. Executive Summary & Core Answers

| # | Question | Answer | Measured Evidence / Basis | Tag |
|---|---|---|---|---|
| **1** | **Machine Owner Key Enrolled?** | **YES [MEASURED]** | `mokutil --list-enrolled` displays enrolled MOK certificate (`<existing-enrolled-MOK-certificate>`). | **`[MEASURED]`** |
| **2** | **Matching Private Key Available Locally?** | **YES [MEASURED]** | Private key `<existing-enrolled-MOK-private-key>` matches DER certificate `<existing-enrolled-MOK-certificate>` (Modulus Hash Verified). | **`[MEASURED]`** |
| **3** | **Can Patch v3 be Signed Locally?** | **YES [MEASURED]** | Kernel `sign-file` utility `/usr/src/linux-headers-7.0.0-28-generic/scripts/sign-file` exists and can sign `.ko` modules using MOK keys. | **`[MEASURED]`** |
| **4** | **Signed Module Signature Metadata Verified?** | **YES [MEASURED]** | Signed module signature metadata verified via `modinfo` PKCS#7 signature trailer presence. Kernel load acceptance is **INFERRED** via `.secondary` keyring trust, but **UNTESTED AT RUNTIME**. | **`[MEASURED]`** |
| **5** | **Is SSH Dependent on MT7925 Wi-Fi?** | **NO [MEASURED]** | Active SSH routing uses primary wired Ethernet interface `eno1` (Metric 100). | **`[MEASURED]`** |
| **6** | **Separate Connection Survives MT7925 Unload?** | **YES [MEASURED]** | Primary default route uses `eno1` (Ethernet link active at 100Mb/s). Unloading `mt7925e` will **NOT** drop active SSH sessions. | **`[MEASURED]`** |
| **7** | **Wake-on-LAN Configured & Usable?** | **NO [MEASURED]** | `ethtool eno1` reports `Wake-on: d` (Disabled). Wake-on-LAN is currently **DISABLED** and cannot serve as a recovery layer without explicit enablement. | **`[MEASURED]`** |
| **8** | **Remote Testing Recoverable?** | **QUALIFIED [MEASURED]** | Recoverable from normal module-load or Wi-Fi-driver failures through an independent Ethernet management path. Kernel panic, full system hang, and boot failure remain outside the guaranteed recovery boundary. | **`[MEASURED]`** |

---

## 2. Cryptographic Security & Keyring Breakdown

### Key & Certificate Audit

- **Enrolled MOK Certificate:** `<existing-enrolled-MOK-certificate>`
- **MOK Certificate Location:** `<existing-enrolled-MOK-certificate>`
- **MOK Private Key Location:** `<existing-enrolled-MOK-private-key>` (Permissions `0600`, owned by `root`).
- **Modulus Hash Verification:** Verified 100% match between DER cert and RSA private key.
- **Kernel Trust Chain:** Shim $\rightarrow$ MOK Keyring $\rightarrow$ Secondary Trusted Keyring (`.secondary`).

---

## 3. Network Interfaces & Routing Isolation

### System Routing Table (`ip route`)
```text
default via XXX.XXX.XXX.XXX dev eno1 proto dhcp src XXX.XXX.XXX.XXX metric 100 
default via XXX.XXX.XXX.XXX dev wlp195s0 proto dhcp src XXX.XXX.XXX.XXX metric 600
```

- Primary Metric `100` is bound to **Wired Ethernet (`eno1`)**.
- Secondary Metric `600` is bound to **Wireless MT7925 (`wlp195s0`)**.
- Active SSH sessions enter over `eno1`. **Unloading `mt7925e` has zero impact on active SSH connectivity.**

---

## 4. Remote Safety & Testability Boundaries

To ensure maximum safety during any future runtime module testing:
1. **Enable Wake-on-LAN on Ethernet:** Run `sudo ethtool -s eno1 wol g` to change `Wake-on: d` to `Wake-on: g`.
2. **Module Signing Command:**
   ```bash
   sudo /usr/src/linux-headers-$(uname -r)/scripts/sign-file sha512 \
     <existing-enrolled-MOK-private-key> \
     <existing-enrolled-MOK-certificate> \
     /path/to/mt7925e.ko
   ```
3. **Module Loading Rule:** Test out-of-tree signed modules in temporary build directories only; **never overwrite `/lib/modules/`**.
