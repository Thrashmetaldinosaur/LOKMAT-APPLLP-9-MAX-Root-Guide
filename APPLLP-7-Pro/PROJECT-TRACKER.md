# APPLLP 7 Pro — fixes and development tracker

**Updated 14 November 2026.** Reference device: `WP_C30_VP69_OLED`, Android 15, build `LOKMAT_APPLLP_7_PRO_C30_EN_V1.0_20260921`, Magisk 31.1, unlocked slot A. **Status labels distinguish user-confirmed results from tests and unverified proposals.**

## Verified / keep working

| Feature | Result and caveat |
| --- | --- |
| All Apps Fix (v1.7) | **Verified cumulative module, 14 Nov 2026:** removes clock/date; retains 10-icon 5 × 2 pages, four favorites, and custom ordering; corrects early regular-app indexing and skips the blank wraparound page. Vector logs: `-1 → 9` / `10 → 0`, 97 app entries. **v1.7 replaces v1.6 inside one module**, not a separate add-on. [Canonical All Apps Fix](All-Apps-Fix/README.md) |
| Root and recovery | Magisk 31.1 installed and verified. Stock backup retained. See [root README](README.md) |
| Persistent Light Doze | Light ON, Deep OFF after full restart; see [module](Light-Doze-Magisk-v1/README.md). Battery improvement not quantified |
| Fitness debloat | Seven OEM packages disabled reversibly; see [guide](Fitness-Debloat/README.md) |
| YouTube + ReVanced fullscreen | **ReVanced built-in portrait fullscreen setting discovered and verified sufficient by user (13 Nov)**; separate Magisk v6.2 service **disabled by user as redundant**. v6.2 had previously worked at native 182 DPI; 154 DPI override was incompatible with its startup guard. [Historical v6.2 guide](YouTube-ReVanced-Auto-Fullscreen-v6.2/README.md). Do not automatically re-enable it or Vector YouTube hooks |
| Round/watch display | Physical/logical baseline 466×466, 182 native DPI. Global square-first experiment was removed |
| Right-swipe panel | OEM launcher setting changed from fitness to App Menu |
| App grid | `settings get system app_list_style` = **5**, Phone-style paged grid, preferred |
| Custom app sorting | 94 entries reordered, original database backup preserved; SQLite integrity and order verified after restart |
| Pure Face watch face | User installed `DigitalPureBlack` and changed the active face. [Installation and archive note](Pure-Face/README.md) |
| Native Fahrenheit + watchface v2 | **User-confirmed working 14 Nov 2026:** native `step_user_metric=0` enables Fahrenheit throughout OEM weather; a launcher-scoped Vector hook supplies converted temperature to watch faces in memory. Successful reboot and hook-log verification. Future weather refresh and OTA compatibility not yet proven. [Verified v2 source and guide](Watchface-Fahrenheit-v2/README.md). Old `wxf.sh` was a historical workaround, not the new fix |

## Notification vibration — user-reported working (14 November 2026)

- **Native system setting, no Vector module:** User ran RTOSify root command `settings put system notification_vibration_intensity 0`; prior value was `null`, afterwards `0`, exit code 0. User explicitly confirms that **new notifications no longer vibrate**. Keep this setting unchanged; test persistence after next ordinary reboot (not confirmed). Do not conflate with call/alarm vibration.

## Next tasks — native notification controls first (14 November 2026)

1. **Remove unwanted persistent/ongoing notifications — FIRST:** Inspect Android Settings → Notifications → App notifications / notification categories, or long-press offending notification → Settings. For ongoing foreground-service notifications, determine owning package and channel before suppressing. User will be back at PC; collect sanitized read-only notification inventory if native UI doesn't expose enough controls. Avoid disabling important call, alarm, charging, security, media/navigation, accessibility, or Magisk status. No modifications yet.
2. **Reduce notification card size/text — SECOND:** Check built-in Display size / Font size or native compact notification UI first. Prior APPLLP7 Compact Notifications v1 Vector module launcher-scoped reportedly stopped working; source used unsupported Xposed helper API. Only debug/surgically repair if stock settings cannot solve, preserving the working All Apps v1.7 and Watchface Fahrenheit v2 modules.

### Read-only notification inventory — 14 November 2026, 19:14 ET

- Native setting confirmed: `notification_vibration_intensity=0`, `font_scale=0.85`, physical density 182; no obvious system setting for compact notification cards in the captured keys.
- Snapshot contained **two active notification candidates**: `com.google.android.youtube` (channel `3`, importance `3`) and `app.revanced.android.youtube` (channel `7`, importance `2`, category `transport`). Their **ongoing/foreground flags were not captured**, so these cannot yet be labeled persistent or safe to hide. User needs to identify which visible unwanted notifications to target; preferably a screenshot, or collect a snapshot while those exact cards are visible.
- No Compact Notifications v1 log marker appeared in the recent logcat; older v1 source uses an Xposed helper signature known to be incompatible with this Vector build. Avoid diagnosing it as definitely disabled from this limited log window. Prefer native settings; otherwise fix through compatible runtime hooks.
- **No notification-channel settings, modules, apps or firmware changed by inventory.**

### Compact Notifications v2 installation guard — 14 November 2026, 19:48 ET

- The guarded v2 **upgrade** stopped before building/installing: `pm path com.appllp7.compact` returned no installed package, although v1 had successfully installed on 12 Nov. No watch files/settings/modules were changed by the stopped attempt.
- A corrected **fresh-install-capable v2 installer** was prepared with unchanged v2 Java hook, all original firmware/launcher/DPI/vibration guards, explicit manual Vector module enable and launcher-only scope, one reboot and post-test diagnostics. **Not yet installed or visually tested**; keep GitHub source release pending actual validation. Do not reinstall the broken v1 merely to satisfy an upgrade prerequisite.

## Historical unsuccessful experiments (not active)

- **Full First Page v1 — FAILED ON DEVICE (13 Nov 2026)**: APK built and installed correctly at 15:55, user enabled and scoped to `com.android.launcher3` in Vector, and rebooted. A screenshot after reboot still showed the original four-app/clock/date first page. Do **not** describe v1 as working. Stock launcher, app ordering and native 182 DPI remain intact. Root cause pending read-only Vector scope/hook-log check. **Root cause established by 16:27 read-only Vector diagnostic:** Vector loaded the module class into launcher PID 2542, but the first registration raised `NoSuchMethodError` for the Xposed helper signature `XposedHelpers.findAndHookMethod(Class,String,Object[])`; no layout hooks were installed. There was no Vector scope/injection error. **v1.1 source package prepared (13 Nov)**: replace that helper entirely with `XposedBridge.hookAllMethods`, use plain Java reflection for launcher class and app-list lookup, and add hook/geometry milestone logs. Offline Java compilation passed; **device installation and rendered geometry are NOT YET verified**. v1.1 upgrades the same `com.appllp7.fullfirstpage` package (versionCode 2). Avoid reinstalling v1; disable it if unwanted. Goal remains remove clock/date and expand first page with verified tapping and pagination.

## Launcher follow-ups — after notification vibration (14 November 2026)

1. **Expand the distinct OEM widgets/options panel opened by swiping RIGHT to the screen LEFT of home — NEXT.** This is **not** the modded Style 5 app menu reached by swiping left. The stock widget picker has a limited set of widgets and poor configuration options; the owner's example is the **timer widget, which only offers a few fixed presets**. Determine whether this panel uses Android `AppWidgetHost` (and could offer third-party installed widgets) or a proprietary OEM widget/card registry. Investigate enabling more widgets, configurable widget variants and custom timer durations, preserving the stock swipe gestures, round 466 × 466 layout, and the working first-page/favorites mod. Screenshots showing Celsius are from **before** the successful Fahrenheit fix; do not treat them as a regression.

## Added requests / priorities

1. **Longer lift-to-wake cooldown.** Native lift-to-wake is already available. Increase the minimum interval between allowed wake cycles to prevent repeated wrist-motion wakeups; first measure the current behavior and determine whether an OEM parameter controls cooldown. Preserve native low-power sensor path. S13's 5-second software cooldown is a device-specific reference, not a drop-in APPLLP7 fix.
2. **Aspect-ratio toggle shortcut — secondary to Recents.** Add to the top-button shortcut menu or an unused button combo without replacing current actions; keep native display geometry stable at rest.
3. **Battery, wake, screen-off:** earlier unplugged test showed actual kernel suspend and Light Doze functioning; no proven runaway modem. Preserve baseline and measure before changing.

## User decisions — closed without additional modifications

- **Recent Apps shortcut:** No extra shortcut needed; existing swipe gesture works.
- **Aspect-ratio compatibility:** Previously problematic apps now respond to mode changes; no further fix requested.
- **USB reliability:** Skip further troubleshooting.
- **Powered-off charging:** Do not attempt custom boot or charging changes due to brick risk; leave to OEM firmware.

## Operational notes

- Windows project root: `I:\android\Lokmat\appllp 7`.
- Provide **complete**, copy-paste PowerShell 7 commands for every changed script, bundled per session with a results ZIP.
- Prefer existing native settings and reversible scoped modules; avoid replacing launcher/root/firmware.
- Any proposed change to notifications must explicitly protect important ongoing notifications.
- Separate verified, user-reported, tested-and-regressed, and speculative states.
- Do not publish the watch's USB serial, private ADB logs, sensitive backups or device identifiers.

**v1.1 install result, 13 Nov 2026 16:45 ET:** Gradle build passed, package was upgraded in-place (`Performing Streamed Install` → `Success`), correct model/Android 15/Style 5, physical 182 DPI, unchanged verified launcher APK. v1.1 module SHA-256 `6b76c03417e116147ed01d8beb7e219d193821eb0f1723d25c575c93dda35d13`. Awaiting **normal reboot and screenshot** to prove Vector hook injection and functional 12-icon layout. No new OEM or global DPI modifications.

**Full First Page v1.1 — ALSO FAILED ON DEVICE (13 Nov 2026):** The upgraded module installed successfully, user rebooted, but first page still has the original clock/date and limited app slots. There is **no post-v1.1 hook log in hand yet**, so do not presume v1.1 API failure versus initialization/geometry failure. Plan: inspect fresh Vector module logs; test a minimal clock-only hook and confirm runtime invocation before touching page-count/touch calculations. Avoid modifying/re-signing the privileged OEM launcher unless systemless/rollback/signature behavior can be proven; it provides Quickstep home, gesture service and notification listener. Current working app order and launcher preserved.

**Launcher replacement safety finding (13 Nov):** package dump for `com.android.launcher3` confirms it is `SYSTEM_EXT`/`PRIVILEGED`, declares shared UID `android.uid.system` (UID 1000), and hosts `QuickstepLauncher`, `TouchInteractionService` and a notification listener. A modified APK cannot safely be installed merely by re-signing with a self-generated key; shared-UID signature compatibility must be preserved. Prioritize diagnosis/repair of runtime hooks, then evaluate surgical alternative techniques with rollback before any systemless APK override.

**Full First Page post-v1.1 diagnosis (13 Nov 2026, 18:04 ET):** Read-only diagnostics from the Nov 13 17:49 boot show Vector loaded `com.appllp7.fullfirstpage` into launcher PID 2450, executed its `Application.attach` hook, resolved `MobilePagedAllAppsBoard`, and reported that all OEM hooks were registered. There were **no** subsequent `full grid enabled`, `clock suppressed`, or `app list unavailable at createDrawables` messages. Thus v1.1 passed registration but did not demonstrate invocation of its readiness-triggering code. The generic legacy `XposedHelpers.findAndHookMethod` NoSuchMethodError in the same launcher process likely comes from the **separate Compact Notifications v1** module (which still calls that missing API); this is a separate probable source of its regression.

**Full First Page v1.2 (prepared, NOT device-verified):** Experimental in-place upgrade, versionCode 3, uses the verified OEM `draw()` → `getTargetPosForIndex` / `getPageIndexForApp` / `drawTimeWidget` call path as a throttled, guarded additional initialization point; logs the first draw, clock and position callback invocation. Only proceeds when `mNormalPageAppCount == 12` and at least 12 valid apps are present. Java compilation with local API stubs and ZIP checks passed. Installer retains exact firmware, native 182 DPI, root, Style 5 and OEM APK checksum guards. **Whether hooks dispatch, icons render/tap correctly and clock disappears remains unverified.** No stock launcher writes or app database edits. Disabled v1.1 is not a remedy; v1.2 attempts an actual callback fix without expanding Vector scope.

**Full First Page v1.2 device installation (13 Nov 2026, 18:20 ET):** Owner ran guarded installer; submitted results ZIP confirms `BUILD SUCCESSFUL`, `Performing Streamed Install` → `Success`, correct Android 15/firmware, Style 5, physical 182 DPI, OEM launcher hash `d59e3d2ba375907ecf3ae2f95fccfa172e3fe2529d91037a211e150aa5e089f8`, and module APK SHA-256 `4e5a2ef723108e09a0256919fbf10b88c0d406ae7663965b2d6a55285d9aa6cc`. **No post-reboot layout or callback results yet.** Keep status experimental; wait for visual test before declaring the clock removal or grid change successful.
