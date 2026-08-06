# System Architecture & Pipeline Design

## Pipeline Architecture

```text
┌───────────────────────────────────────────────────────────────────┐
│                    MediaTek MT7925 Wi-Fi 7 Card                   │
└─────────────────────────────────┬─────────────────────────────────┘
                                  │ PCIe Gen3 DMA Rings
                                  ▼
┌───────────────────────────────────────────────────────────────────┐
│             Linux mt76 Driver (`mt7925/debugfs.c`)                │
│             Exposes: /sys/kernel/debug/.../icap_dump              │
└─────────────────────────────────┬─────────────────────────────────┘
                                  │ Raw Binary Stream
                                  ▼
┌───────────────────────────────────────────────────────────────────┐
│               RuView Capture Daemon & Ring Buffer                 │
└─────────────────────────────────┬─────────────────────────────────┘
                                  │ Raw ICAP Payload
                                  ▼
┌───────────────────────────────────────────────────────────────────┐
│            `libruview_mt7925` Complex I/Q CSI Decoder             │
│            Extracts: Subcarrier Amplitude (A) & Phase (φ)         │
└─────────────────────────────────┬─────────────────────────────────┘
                                  │ Subcarrier Matrix
                                  ▼
┌───────────────────────────────────────────────────────────────────┐
│                  RuView Real-Time Sensing GUI                     │
└───────────────────────────────────────────────────────────────────┘
```

> **Authoritative Status Note:** See [`STATUS.md`](../STATUS.md) for current runtime verification state.
