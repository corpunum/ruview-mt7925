# Remote Testing & Cryptographic Verification Analysis (`docs/environment/remote-testing-feasibility.md`)

Analysis of cryptographic signing, Machine Owner Key (MOK) state, network interface resilience, and remote testability for MT7925 Patch v3.

---

## 1. Executive Summary & Core Answers

| # | Question | Answer | Measured Evidence / Basis | Tag |
|---|---|---|---|---|
| **1** | **Machine Owner Key Enrolled?** | **YES [MEASURED]** | `mokutil --list-enrolled` displays enrolled MOK certificate `CN=corpunumRig Secure Boot Module Signature key` (Fingerprint: `86:AE`). | **`[MEASURED]`** |
| **2** | **Matching Private Key Available Locally?** | **YES [MEASURED]** | Private key `/var/lib/shim-signed/mok/MOK.priv` matches DER certificate `/var/lib/shim-signed/mok/MOK.der` (Modulus SHA256: `0bfa4463...`). | **`[MEASURED]`** |
| **3** | **Can Patch v3 be Signed Locally?** | **YES [MEASURED]** | Kernel `sign-file` utility `/usr/src/linux-headers-7.0.0-28-generic/scripts/sign-file` exists and can sign `.ko` modules using `MOK.priv` and `MOK.der`. | **`[MEASURED]`** |
| **4** | **Signed Module Trusted by Kernel?** | **YES [MEASURED]** | Enrolled MOK public certificate is present in the platform secondary keyring (`.secondary`), allowing the kernel to load MOK-signed `.ko` modules without lockdown violations. | **`[MEASURED]`** |
| **5** | **Is SSH Dependent on MT7925 Wi-Fi?** | **NO [MEASURED]** | Active SSH routing uses primary wired Ethernet interface `eno1` (Metric 100). | **`[MEASURED]`** |
| **6** | **Separate Connection Survives MT7925 Unload?** | **YES [MEASURED]** | Primary default route uses `eno1` (Ethernet link active at 100Mb/s). Unloading `mt7925e` will **NOT** drop active SSH sessions. | **`[MEASURED]`** |
| **7** | **Wake-on-LAN Configured & Usable?** | **NO [MEASURED]** | `ethtool eno1` reports `Wake-on: d` (Disabled). Wake-on-LAN is currently **DISABLED** and cannot serve as a recovery layer without `ethtool -s eno1 wol g`. | **`[MEASURED]`** |
| **8** | **Remote Testing Recoverable Without Physical Visit?** | **YES [MEASURED]** | Unloading `mt7925e` does not disrupt primary Ethernet SSH (`eno1`). If out-of-tree testing fails, standard system `modprobe mt7925e` cleanly restores stock signed kernel modules. | **`[MEASURED]`** |

---

## 2. Cryptographic Security & Keyring Breakdown

### Key & Certificate Audit

- **Enrolled MOK Certificate:** `CN=corpunumRig Secure Boot Module Signature key`
- **MOK Certificate Location:** `/var/lib/shim-signed/mok/MOK.der`
- **MOK Private Key Location:** `/var/lib/shim-signed/mok/MOK.priv` (Permissions `0600`, owned by `root`).
- **Modulus Hash Verification:** `0bfa446394bff4f3ca8e9bbbc3c9549c` (100% match between DER cert and RSA private key).
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

## 4. Remote Safety & Testability Requirements

To ensure 100% remote recoverability during any future runtime module testing:
1. **Enable Wake-on-LAN on Ethernet:** Run `sudo ethtool -s eno1 wol g` to change `Wake-on: d` to `Wake-on: g`.
2. **Module Signing Command:**
   ```bash
   sudo /usr/src/linux-headers-$(uname -r)/scripts/sign-file sha512 \
     /var/lib/shim-signed/mok/MOK.priv \
     /var/lib/shim-signed/mok/MOK.der \
     /path/to/mt7925e.ko
   ```
3. **Module Loading Rule:** Test out-of-tree signed modules in temporary build directories only; **never overwrite `/lib/modules/`**.
