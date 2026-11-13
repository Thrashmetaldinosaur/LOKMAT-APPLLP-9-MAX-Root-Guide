# APPLLP 7 Pro — Automatic YouTube + ReVanced fullscreen (v6.2)

**Tested:** 11–12 November 2026 on LOKMAT APPLLP 7 Pro `WP_C30_VP69_OLED`, Android 15, 466×466 logical/physical default, 182 DPI, Magisk 31.1, active slot A.

**Verified on the device:** The v6.2 monitor automatically triggers fullscreen for **regular YouTube** (`com.google.android.youtube`) and **YouTube ReVanced** (`app.revanced.android.youtube`). Video remained moving, controls were usable, and pressing Home restored the original 466×466 viewport. The module was installed with Magisk and the tester confirmed both apps still worked **after a full reboot** on 12 November 2026.

## How the fix works

This is **not** an APK patch, an Xposed/Vector hook, or a new permanent screen shape.

On this watch, launching YouTube on its normal square 466×466 viewport results in a small top-aligned video with a metadata area beneath it. But once playback has begun, **changing the Android logical viewport to 466×426** causes YouTube to enter its own native landscape/full-player presentation. The player, controls, and overlays then occupy the full logical viewport.

The Magisk `service.sh` launches a background monitor after boot. It requires **both** the supported package to be foreground and that *same package* to own a `PLAYING(3)` media session. Only then does it apply `wm size 466x426`. When YouTube/ReVanced leaves the foreground, it restores `wm size reset` to return to 466×466.

This is a **temporary system-wide logical-size override** during YouTube playback. The physical AMOLED panel, DPI, firmware, and APK files remain unchanged. There is a small potential background polling/battery cost; battery benefit or cost has not yet been quantified.

## Installation and configuration

The verified Magisk module ID is `appllp7_youtube_auto_fullplayer`; version **6.2**. Download **[APPLLP7PRO-YOUTUBE-AUTO-MAGISK-v6.2.zip](APPLLP7PRO-YOUTUBE-AUTO-MAGISK-v6.2.zip)** and install through **Magisk → Modules → Install from storage**, then perform a normal full reboot. The public ZIP is repacked from the **exact source scripts** of the tested v6.2 module (all seven Git blob hashes checked against the original); repacking changes the ZIP checksum, not the script content. Public ZIP SHA-256: `d3b093516622e85520128789376cce884f1b1acf400b85ec231812e8abb70d60`.

The module has a `targets.conf` listing accepted package IDs, one per line. The actual successful installed configuration contained:

```text
com.google.android.youtube
app.revanced.android.youtube
```

Other ReVanced/RVX package names can differ by patcher and version. The source package recognizes common variants such as `app.rvx.android.youtube`, `anddea.youtube`, and `bill.youtube`, but **only the stock and `app.revanced.android.youtube` packages were confirmed on this physical watch**. If using another installed ID, configure `targets.conf` for the exact package. Never assume a matching app label implies the same package name.

Disable earlier experimental Vector/LSPosed YouTube fullscreen and square-screen hooks to avoid conflicts. They are unnecessary for this fix.

## Verify

At idle or on Home, `adb shell wm size` should report **Physical size: 466x466**, with **no Override size** line. Open a video in YouTube or ReVanced, let playback start, and then recheck:

```text
Physical size: 466x466
Override size: 466x426
```

Verify **moving video**, native expanded controls and correct centering, then press Home. The `Override size` line should disappear. Check both apps again after a normal reboot.

## Recovery / removal

Disable **APPLLP7 YouTube + ReVanced Auto Fullscreen** in Magisk and reboot. If a previous monitor run left the known owned 466×426 override behind, inspect `wm size` and then use `adb shell wm size reset` **only after confirming no other feature intentionally set that override**. The module's uninstall script attempts to restore only the size it owns. Do not run two copies of the monitor simultaneously.

The script must not be used on other displays or different Android watch models without reviewing the strict device checks and dimensions.

## Proven limits and experiments

- Changing `round + watch` to `notround + normal` at boot **did not fix either YouTube app**. The global square-first overlay was tested and then removed; it is **not** a recommended permanent fix.
- A permanent rectangular viewport *before* YouTube starts did not reliably reproduce the same playback behavior. The **live transition after playback starts** is essential to this tested fix.
- Early S13-derived YouTube hooks adjusted video views but not all controls; these are deprecated for APPLLP 7 Pro.
- Charging while completely off is not part of this module. The tester reports LOKMAT plans that feature for a future OTA; it was not verified in this repository.

Only module source and release artifacts should be public. **Do not publish results ZIPs** containing user-specific media sessions, screenshots, account metadata, ADB identifiers, recovery dumps, or firmware partitions.

Related: [APPLLP 7 Pro root guide](../README.md) · [Light Doze v1](../Light-Doze-Magisk-v1/README.md).

## Status change — 13 November 2026

The watch owner found a **built-in portrait fullscreen option in YouTube ReVanced** that meets their needs, and has **disabled the formerly working v6.2 Magisk monitor as redundant**. The v6.2 method remains documented here as a tested historical alternative for configurations that need it, not as a module currently active on this watch. The ReVanced option is app-specific; no claim is made that standard YouTube exposes identical controls. Avoid automatically re-enabling the monitor during unrelated display/launcher changes.
