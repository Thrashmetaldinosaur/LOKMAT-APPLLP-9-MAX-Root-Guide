# APPLLP 7 Pro — fixes and development tracker

**Updated 13 November 2026.** Reference device: `WP_C30_VP69_OLED`, Android 15, build `LOKMAT_APPLLP_7_PRO_C30_EN_V1.0_20260921`, Magisk 31.1, unlocked slot A. **Status labels distinguish user-confirmed results from tests and unverified proposals.**

## Verified / keep working

| Feature | Result and caveat |
| --- | --- |
| Root and recovery | Magisk 31.1 installed and verified. Stock backup retained. See [root README](README.md) |
| Persistent Light Doze | Light ON, Deep OFF after full restart; see [module](Light-Doze-Magisk-v1/README.md). Battery improvement not quantified |
| Fitness debloat | Seven OEM packages disabled reversibly; see [guide](Fitness-Debloat/README.md) |
| YouTube + ReVanced fullscreen | **ReVanced built-in portrait fullscreen setting discovered and verified sufficient by user (13 Nov)**; separate Magisk v6.2 service **disabled by user as redundant**. v6.2 had previously worked at native 182 DPI; 154 DPI override was incompatible with its startup guard. [Historical v6.2 guide](YouTube-ReVanced-Auto-Fullscreen-v6.2/README.md). Do not automatically re-enable it or Vector YouTube hooks |
| Round/watch display | Physical/logical baseline 466×466, 182 native DPI. Global square-first experiment was removed |
| Right-swipe panel | OEM launcher setting changed from fitness to App Menu |
| App grid | `settings get system app_list_style` = **5**, Phone-style paged grid, preferred |
| Custom app sorting | 94 entries reordered, original database backup preserved; SQLite integrity and order verified after restart |
| Pure Face watch face | User installed `DigitalPureBlack` and changed the active face. [Installation and archive note](Pure-Face/README.md) |
| Celsius → Fahrenheit display | **User confirmed working after a normal reboot (13 Nov 2026)** with `wxf.sh`. Potential repeated conversion after service restarts/when a saved value is already Fahrenheit remains an untested edge case. See [weather fix notes](Weather-Temperature-Fahrenheit/README.md) |

## Regressed / needs repair

1. **Smaller notification cards/text:** APPLLP7 Compact Notifications v1 Vector module installed, launcher-scoped; user first said it looked good, **but subsequently reports small notifications are not working**. Re-test hook activation, Vector scope and actual OEM notification view. Do not label the visual result verified until reconfirmed; preserve ability to disable module without affecting other fixes.
2. **Persistent/ongoing notifications:** User wants unwanted persistent notification entries removed/hidden. Inventory notification packages and flags first; only suppress selected nonessential OEM notices without disabling critical phone, charging, security, navigation or accessibility status notifications. This is **not implemented**.

## Under test (not verified)

- **Full First Page v1 — FAILED ON DEVICE (13 Nov 2026)**: APK built and installed correctly at 15:55, user enabled and scoped to `com.android.launcher3` in Vector, and rebooted. A screenshot after reboot still showed the original four-app/clock/date first page. Do **not** describe v1 as working. Stock launcher, app ordering and native 182 DPI remain intact. Root cause pending read-only Vector scope/hook-log check. **Root cause established by 16:27 read-only Vector diagnostic:** Vector loaded the module class into launcher PID 2542, but the first registration raised `NoSuchMethodError` for the Xposed helper signature `XposedHelpers.findAndHookMethod(Class,String,Object[])`; no layout hooks were installed. There was no Vector scope/injection error. **v1.1 source package prepared (13 Nov)**: replace that helper entirely with `XposedBridge.hookAllMethods`, use plain Java reflection for launcher class and app-list lookup, and add hook/geometry milestone logs. Offline Java compilation passed; **device installation and rendered geometry are NOT YET verified**. v1.1 upgrades the same `com.appllp7.fullfirstpage` package (versionCode 2). Avoid reinstalling v1; disable it if unwanted. Goal remains remove clock/date and expand first page with verified tapping and pagination.

## Added requests / priorities

1. **Recents / recent tasks shortcut — high priority.** Add an entry to an **available** quick-access slot or the long-top-button panel (currently volume, brightness and settings), or bind to a truly unused button combination. Do **not** override existing button actions. Investigate Android `KEYCODE_APP_SWITCH` (187) or accessibility `GLOBAL_ACTION_RECENTS`, confirm how the OEM implements its recent-apps page. No watcher/poller unless proven unavoidable.
2. **System-wide Fahrenheit weather units (°F) — NEW, higher priority than refining the existing display script.** User reports the Pure Face watch display generally shows °F after `wxf.sh`, **but the OEM built-in weather app still treats temperatures as °C**, and its updates occasionally overwrite the watch-face value with Celsius. Investigate a possible hidden OEM temperature-unit setting, weather-app preference, provider/ContentProvider unit field, or service-level unit conversion. Read-only inspect `settings` system/secure/global, the weather app's package/resources/preferences and its writer to `WeatherTemp` before changing anything. Target consistent Fahrenheit across built-in weather, watch face, and any related widgets, preferably by switching the source's units rather than continuously rewriting the stored temperature. Do not assume a universal Android setting exists, and preserve a rollback for any discovered key.
3. **Longer lift-to-wake cooldown.** Native lift-to-wake is already available. Increase the minimum interval between allowed wake cycles to prevent repeated wrist-motion wakeups; first measure the current behavior and determine whether an OEM parameter controls cooldown. Preserve native low-power sensor path. S13's 5-second software cooldown is a device-specific reference, not a drop-in APPLLP7 fix.
4. **Aspect-ratio toggle shortcut — secondary to Recents.** Add to the top-button shortcut menu or an unused button combo without replacing current actions; keep native display geometry stable at rest.
5. **Apps ignoring aspect-ratio switches.** Identify which apps fail and which display override/mode is requested. Investigate OEM per-app compatibility, window-layout propagation, activity recreation, and whether active fullscreen v6.2 can coexist. Do not re-enable the broken global square-first modification.
6. **Clock/date-free 12-app first page:** verify experimental module; stop/revert if touch, pagination, or existing notification fixes regress.
7. **Battery, wake, screen-off:** earlier unplugged test showed actual kernel suspend and Light Doze functioning; no proven runaway modem. Preserve baseline and measure before changing.
8. **USB reliability:** return only if issues recur. Minimize reconnects.
9. **Powered-off charging:** wait for the possible OEM OTA; no working custom fix published.

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
