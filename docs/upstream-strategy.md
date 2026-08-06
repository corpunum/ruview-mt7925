# Upstream Contribution Strategy

## Objective

Deliver clean, maintainable patches to `linux-wireless` and the OpenWrt `mt76` repository that enable testmode ICAP capabilities without compromising kernel security or driver stability.

## Guiding Principles

1. **Clean `mac80211` / `nl80211` Integration:** Avoid ad-hoc kernel hacks or debugfs bypasses in production submissions.
2. **Backward Compatibility:** Ensure existing `mt7921`, `mt7922`, and `mt7996` driver paths remain completely unaffected.
3. **Upstream Review Process:** Submit RFC patch series to `linux-wireless@vger.kernel.org` following standard Linux kernel patch submission rules.
