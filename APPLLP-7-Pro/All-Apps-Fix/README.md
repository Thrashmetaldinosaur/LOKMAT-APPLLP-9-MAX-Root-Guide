# All Apps Fix — APPLLP 7 Pro

**Current verified release: Full First Page v1.7 (14 November 2026).**

This is **one cumulative All Apps / Style 5 launcher fix**, not multiple modules to install separately. Version **1.7 replaces v1.6 in the same** `com.appllp7.fullfirstpage` **Vector module**. It preserves all features introduced by earlier successful versions:

- Removes the oversized clock/date from the first app-menu screen.
- Shows the OEM native **5 × 2 grid** (10 regular icons per full page).
- Preserves the **four OEM favorites/shortcuts** at the bottom.
- Preserves custom app ordering and normal icon taps.
- Corrects the first four regular-app positions that could otherwise overlap the favorites' reserved slots.
- **Skips the unusable empty page** when swiping past the first or last populated page; normal wraparound becomes first ↔ last.

**Verified on:** LOKMAT APPLLP 7 Pro / `WP_C30_VP69_OLED`, Android 15, `LOKMAT_APPLLP_7_PRO_C30_EN_V1.0_20260921`, `com.android.launcher3` Style 5, native 466 × 466 / 182 DPI. User reported the empty-screen skip working on 14 November 2026, and post-reboot Vector traces recorded page requests `-1 → 9` and `10 → 0` with 97 app entries and four favorites. Other models or firmware are untested.

## Get the complete current fix

- **[Download complete sanitized v1.7 All Apps module source](../Full-First-Page-v1.7/APPLLP7-Full-First-Page-v1.7-PUBLIC-SOURCE.zip)**.
- [v1.7 technical details, source checksum, build, install and rollback](../Full-First-Page-v1.7/README.md).
- [v1.6 historical release](../Full-First-Page-v1.6/README.md), retained only as a known-working earlier version and rollback option.

The source ZIP is a buildable Vector/LSPosed-compatible module project, **not a flashable firmware package or a prebuilt APK**. Build with JDK 17, Gradle 8.9 and Android SDK 35; install the resulting APK, enable its module in Vector scoped **only to `com.android.launcher3`**, and reboot. An existing v1.6 module upgrades in place. Do **not** install v1.6 as a second module. Leave unrelated modules, including Watchface Fahrenheit v2, alone.

**Rollback:** Disable **Full First Page** in Vector and reboot to restore the original OEM app-menu layout. Restoring the exact older v1.6 requires reinstalling the backed-up v1.6 APK. Do not clear launcher data or modify the privileged OEM launcher APK.

## Version history

| Version | Outcome |
| --- | --- |
| v1.0–v1.3 | Early helper API / parent-classloader hook issues; layout unchanged |
| v1.4 | First hooks reached the OEM renderer's dynamically loaded runtime class |
| v1.5 | Removed the clock and enabled the native 10-icon grid, but lost four favorites |
| v1.6 | Restored favorites alongside the clock-free 10-icon grid |
| **v1.7 (current)** | Preserves all v1.6 features, corrects early regular-app indexing and skips the empty wraparound page |

This page is the canonical All Apps Fix entry. The version-specific folders are release archives and technical documentation.
