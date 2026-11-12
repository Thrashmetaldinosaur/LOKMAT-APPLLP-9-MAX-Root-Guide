# APPLLP 7 Pro — reversible OEM fitness debloat (verified)

**Tested:** 10 November 2026 on `WP_C30_VP69_OLED` running Android 15, firmware `LOKMAT_APPLLP_7_PRO_C30_EN_V1.0_20260921`. This is a record of **seven Android user-0 package disables**, not APK deletion or a Magisk module.

The tester confirmed these packages disabled successfully with `pm disable-user --user 0` while keeping the original launcher and essential communications/services. The Stage 2 diagnostic verified the last two package changes and showed all seven OEM fitness packages disabled. A measured reduction in battery drain was **not** established, and disabling the packages may remove OEM health/step functionality.

## Packages disabled in the tested configuration

| Stage | Package | Approximate function |
| --- | --- | --- |
| 1 | `com.wiite.wiite_heartrate` | OEM heart-rate UI |
| 1 | `com.wiite.wiite_bloodoxygen` | OEM SpO2 UI |
| 1 | `com.wiite.wiite_sleep` | OEM sleep UI |
| 1 | `com.wiite.breathtraining` | OEM breathing UI |
| 1 | `com.sprots.wiiteer.fitness` | OEM fitness app |
| 2 | `com.wiite.wearhealthuart` | OEM fitness/pedometer-facing UART component |
| 2 | `com.wiite.healthcenter` | OEM health dashboard |

**Not disabled by this guide:** `com.android.launcher3`, watch-face engine, `com.wiite.wearuart` (general UART), `com.wiite.devicedaemon`, `com.wiite.servicecenter`, `com.wiite.power`, cellular, Wi‑Fi, Google services, or Health Connect. The original right-swipe fitness panel is **not** replaced by this modification.

## Before changing anything

- Ensure the watch identity is `WP_C30_VP69_OLED`, Android SDK `35`, and the correct firmware. **Do not run on APPLLP 9 MAX or other watches.**
- Use a working authorized ADB connection, keeping the watch charged.
- Run `adb shell pm list packages -d --user 0` to record which packages were **already disabled**. Preserve that output privately for rollback.
- These operations are reversible for Android user 0 and do not flash partitions, but third-party apps or watch faces may rely on OEM health services.

## Disable (only packages confirmed present and currently enabled)

```powershell
$adb = 'adb'
$packages = @(
  'com.wiite.wiite_heartrate',
  'com.wiite.wiite_bloodoxygen',
  'com.wiite.wiite_sleep',
  'com.wiite.breathtraining',
  'com.sprots.wiiteer.fitness',
  'com.wiite.wearhealthuart',
  'com.wiite.healthcenter'
)
$device = (& $adb shell getprop ro.product.device | Out-String).Trim()
$sdk = (& $adb shell getprop ro.build.version.sdk | Out-String).Trim()
if ($device -ne 'WP_C30_VP69_OLED' -or $sdk -ne '35') { throw 'Wrong watch or OS' }
$before = & $adb shell pm list packages -d --user 0
$before | Set-Content -Encoding utf8 '.\appllp7-disabled-before.txt'
foreach ($pkg in $packages) {
  if (($before -contains "package:$pkg")) { Write-Host "Already disabled: $pkg"; continue }
  & $adb shell pm disable-user --user 0 $pkg
  if ($LASTEXITCODE -ne 0) { throw "Disable failed for $pkg; inspect and roll back" }
}
& $adb shell pm list packages -d --user 0
```

This is a transparent reference snippet, **not** the original journaled Stage 1/2 installer. It assumes a single selected ADB target; pass `-s SERIAL` for multiple connected devices. Review dependencies before running, and restore any package needed by your watch face or health features.

## Restore

```powershell
$packages = @(
  'com.wiite.wiite_heartrate','com.wiite.wiite_bloodoxygen',
  'com.wiite.wiite_sleep','com.wiite.breathtraining',
  'com.sprots.wiiteer.fitness','com.wiite.wearhealthuart','com.wiite.healthcenter'
)
foreach ($pkg in $packages) {
  adb shell pm enable --user 0 $pkg
}
```

**Important:** If a package was already disabled before the debloat, do not inadvertently enable it. Use the saved pre-change list to restore only packages that changed. The original Stage 1/2 scripted workflow recorded these states in a private journal.

## Status

- **Verified:** Package-disable states and continued launcher access on the tested watch.
- **Unverified:** Long-term battery savings, push-notification timing, impact on every possible watch-face widget.
- **Deferred:** Replacing the right-swipe fitness panel with All Apps; that requires a separate launcher investigation.

The source diagnostic ZIPs contain private device logs and are deliberately **not** published.
