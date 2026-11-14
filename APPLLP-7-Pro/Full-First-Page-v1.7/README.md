# Full First Page v1.7 — verified pagination correction

**Status:** User-reported working and verified in runtime hook logs, 14 November 2026. **This version is the current integrated [All Apps Fix](../All-Apps-Fix/README.md), not a separate add-on.** Builds on the [v1.6 clock-free 10-icon grid](../Full-First-Page-v1.6/README.md).

[Download sanitized v1.7 source archive](APPLLP7-Full-First-Page-v1.7-PUBLIC-SOURCE.zip) · SHA-256: `76467fb041e70540e54effa49caac51c61d30518ebaa50cd32f874f0dee38ada`

## Fix

The OEM app-menu page calculation included an empty, non-addressable page during wraparound; in v1.6 the first four regular app entries also risked being mapped into the OEM favorites-only slots.

v1.7 retains the stock 5 × 2 grid (10 normal icons per full page), four persistent favorites, custom ordering, and the suppressed oversized clock/date. It corrects regular-app indexing and only remaps out-of-range page requests.

The user's test reported that swipes now **skip the empty screen**. The post-reboot Vector diagnostic confirmed:

- 97 app-info entries and 97 drawables, with four native favorites.
- 10 paged app screens indexed 0 through 9.
- Wrap from request `-1` corrected to page `9`.
- Wrap from request `10` corrected to page `0`.
- Clock/date suppression and the runtime `MobilePagedAllAppsBoard` hooks active.

## Tested hardware

LOKMAT APPLLP 7 Pro (`WP_C30_VP69_OLED`), Android 15, firmware `LOKMAT_APPLLP_7_PRO_C30_EN_V1.0_20260921`, native 466 × 466 / 182 DPI, launcher `com.android.launcher3` Style 5. Stock launcher APK SHA-256 `d59e3d2ba375907ecf3ae2f95fccfa172e3fe2529d91037a211e150aa5e089f8`.

Requires Magisk root and Vector LSPosed-compatible module manager. Scope `com.appllp7.fullfirstpage` **only** to `com.android.launcher3`. Leave Watchface Fahrenheit v2 and unrelated modules unchanged.

## Build, install and rollback

The ZIP is a source-only Gradle Android project with compile-only Xposed stubs. Build with JDK 17, Android SDK 35, Gradle 8.9:

```powershell
gradle --no-daemon :app:assembleDebug
adb install -r .\app\build\outputs\apk\debug\app-debug.apk
```

Reboot after an enabled module upgrade, then verify icons, touch targets and both wraparound boundaries. **Rollback:** Disable only Full First Page in Vector and reboot to restore the OEM launcher. To specifically restore v1.6, reinstall the signed v1.6 APK saved by the v1.7 installer; don't clear the launcher database.

The public archive omits private device identifiers, installer diagnostics, paths and backups. Other firmware versions are untested.
