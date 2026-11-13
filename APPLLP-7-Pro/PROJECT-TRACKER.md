# APPLLP 7 Pro — fixes and development tracker

**Updated 13 November 2026.** Reference device: `WP_C30_VP69_OLED`, Android 15, build `LOKMAT_APPLLP_7_PRO_C30_EN_V1.0_20260921`, Magisk 31.1, unlocked slot A. **Status labels distinguish user-confirmed results from tests and unverified proposals.**

## Verified / keep working

| Feature | Result and caveat |
| --- | --- |
| Root and recovery | Magisk 31.1 installed and verified. Stock backup retained. See [root README](README.md) |
| Persistent Light Doze | Light ON, Deep OFF after full restart; see [module](Light-Doze-Magisk-v1/README.md). Battery improvement not quantified |
| Fitness debloat | Seven OEM packages disabled reversibly; see [guide](Fitness-Debloat/README.md) |
| YouTube + ReVanced fullscreen | Magisk auto fullscreen v6.2 works. **Native 182 DPI with no override is required on the observed setup**; overriding to 154 DPI broke it, and `wm density reset` restored playback. [v6.2 guide](YouTube-ReVanced-Auto-Fullscreen-v6.2/README.md). Vector YouTube hooks are NOT needed |
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

- **Full First Page v1**: separate Vector/LSPosed module designed to suppress redundant clock/date and expand the first Style 5 page from 4 to 12 apps. **APK built and installed on the confirmed APPLLP7 on 13 Nov 2026 at 15:55**, Android reported `Success`; source/build/verification results ZIP inspected. **Vector activation, first-page rendering, touch targets and page swipes are still unverified**. Scope only to `com.android.launcher3`; disable module and reboot on regression. Original launcher and database left unchanged.

## Added requests / priorities

1. **Recents / recent tasks shortcut — high priority.** Add an entry to an **available** quick-access slot or the long-top-button panel (currently volume, brightness and settings), or bind to a truly unused button combination. Do **not** override existing button actions. Investigate Android `KEYCODE_APP_SWITCH` (187) or accessibility `GLOBAL_ACTION_RECENTS`, confirm how the OEM implements its recent-apps page. No watcher/poller unless proven unavoidable.
2. **Longer lift-to-wake cooldown.** Native lift-to-wake is already available. Increase the minimum interval between allowed wake cycles to prevent repeated wrist-motion wakeups; first measure the current behavior and determine whether an OEM parameter controls cooldown. Preserve native low-power sensor path. S13's 5-second software cooldown is a device-specific reference, not a drop-in APPLLP7 fix.
3. **Aspect-ratio toggle shortcut — secondary to Recents.** Add to the top-button shortcut menu or an unused button combo without replacing current actions; keep native display geometry stable at rest.
4. **Apps ignoring aspect-ratio switches.** Identify which apps fail and which display override/mode is requested. Investigate OEM per-app compatibility, window-layout propagation, activity recreation, and whether active fullscreen v6.2 can coexist. Do not re-enable the broken global square-first modification.
5. **Clock/date-free 12-app first page:** verify experimental module; stop/revert if touch, pagination, or existing notification fixes regress.
6. **Battery, wake, screen-off:** earlier unplugged test showed actual kernel suspend and Light Doze functioning; no proven runaway modem. Preserve baseline and measure before changing.
7. **USB reliability:** return only if issues recur. Minimize reconnects.
8. **Powered-off charging:** wait for the possible OEM OTA; no working custom fix published.

## Operational notes

- Windows project root: `I:\android\Lokmat\appllp 7`.
- Provide **complete**, copy-paste PowerShell 7 commands for every changed script, bundled per session with a results ZIP.
- Prefer existing native settings and reversible scoped modules; avoid replacing launcher/root/firmware.
- Any proposed change to notifications must explicitly protect important ongoing notifications.
- Separate verified, user-reported, tested-and-regressed, and speculative states.
- Do not publish the watch's USB serial, private ADB logs, sensitive backups or device identifiers.
