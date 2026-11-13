# Pure Face for APPLLP 7 Pro — `DigitalPureBlack`

**Status: installed and active, confirmed by the watch owner on 13 November 2026.**

This is a stock clockskin face with multiple XML and PNG assets, supplied as `Pure-Face-APPLLP7.zip`. It is not an Android app, Magisk module or Vector module.

## Deployment from a copy of the package

The ZIP includes a `DigitalPureBlack/` directory with `clock_skin.xml`, `clock_skin_model.png`, additional layout XMLs and image files. With an authorized USB connection:

```powershell
adb devices
adb shell mkdir -p /sdcard/clockskin
adb push ".\DigitalPureBlack" /sdcard/clockskin/
```

If more than one ADB device is connected, use **your own** serial in `adb -s <WATCH_SERIAL> ...` rather than relying on a default selection.

On the watch, long-press the active watch face; scroll to the end of the watch-face list and refresh, then select the new face. Return to another face via the same selector for rollback.

The original user-supplied Windows batch script hard-coded a personal device serial and absolute local platform-tools path, so it must **not** be copied verbatim into public guides.

## Distribution and compatibility

- The original watch-face ZIP SHA-256 (reference only) was `4255c34cb4d1a3459b4d896aa0a0f7fc214b08084c8aecb8012ce950ac8d8cb2`.
- **Binary face assets are not attached to this GitHub page.** This is a reproducible install record for a user-supplied asset package, not an assertion that the README alone is an installable face.
- Do not share other owners' watchfaces or redistribute third-party images/fonts unless permission allows.
- No verified compatibility outside the owner's 466×466 APPLLP 7 Pro / Android 15 build.
- The current display uses native 182 DPI, important to the separate YouTube fullscreen v6.2 module.

See [project tracker](../PROJECT-TRACKER.md) for ongoing interface work.
