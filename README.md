# RuView MT7925

Experimental, upstream-oriented support for standalone RuView using the MediaTek MT7925 Wi-Fi 7 chipset on Linux.

## Pipeline Architecture

```text
MT7925 Hardware
  └── Linux mt76 capture interface
        └── Raw ICAP/testmode payload
              └── Validated payload decoder
                    └── Standalone RuView source adapter
```

> [!WARNING]
> **PROMINENT CURRENT-STATUS WARNING**
> - **No genuine MT7925 ICAP/CSI payload has yet been captured.**
> - **No claim of working CSI extraction is currently made.**
> - The fixed-size testmode response seen in source code has not been proven to contain CSI.
> - Stock Ubuntu rejected the attempted testmode path with `-EOPNOTSUPP` (`-95`).
> - `CONFIG_NL80211_TESTMODE` was disabled on the tested stock kernel (`7.0.0-28-generic`).
> - Managed and monitor interfaces were proven to coexist (`mon0` + `wlp195s0` UP simultaneously).
> - eBPF (`bpftrace`) was proven to observe ordinary `mt76` MCU events.
> - **OpenUnum is not part of this project.**

## Quick Links

- [Project Status](STATUS.md)
- [Development Roadmap](ROADMAP.md)
- [Contributing Guidelines](CONTRIBUTING.md)
- [Security Policy](SECURITY.md)
- [Evidence Policy](docs/evidence-policy.md)
- [GitHub Issues #1–#8](https://github.com/corpunum/ruview-mt7925/issues)

## License

This project is licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for details.