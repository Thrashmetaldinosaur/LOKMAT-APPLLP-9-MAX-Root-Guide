# APPLLP 7 Pro — Watchface Fahrenheit v2 (verified)

**Verified on the user's watch, 14 November 2026:** native OEM weather screens and weather-enabled watch face display Fahrenheit after one normal reboot. Vector logs confirm that the watch-face temperature hook ran (6°C to 42.8°F in memory). This was a user-reported visual PASS; future OTA compatibility and repeated weather refreshes are not yet independently verified.

## Download

**[Full sanitized source archive](APPLLP7-Watchface-Fahrenheit-v2-PUBLIC-SOURCE.zip)** (7,685 bytes; SHA-256 `ee96b89e51ee21340622db6717811590d031e61266a3da19409b04e422283d31`).

The ZIP contains the Java hook, Android Gradle project, Vector/Xposed API stubs, and build/rollback instructions; no personal ADB serial, local Windows paths, diagnostic logs, pulled system APKs, or firmware backups.

## Supported device and setup

- LOKMAT APPLLP 7 Pro (`WP_C30_VP69_OLED`), Android 15; build `LOKMAT_APPLLP_7_PRO_C30_EN_V1.0_20260921`
- OEM launcher SHA-256 `d59e3d2ba375907ecf3ae2f95fccfa172e3fe2529d91037a211e150aa5e089f8`; native DPI 182
- Rooted with Magisk, Vector LSPosed-compatible framework
- **Native Fahrenheit enabled:** `settings get system step_user_metric` returns `0`
- Vector module `com.appllp7.watchfacefahrenheit`, scoped **only** to `com.android.launcher3`
- Works alongside [Full First Page v1.6](../Full-First-Page-v1.6/README.md), which remains enabled.

## Mechanism

The OEM weather application already understands Fahrenheit through `step_user_metric=0`, but the watch-face engine blanks temperature in imperial mode. The OEM setting `WeatherTemp` remains raw Celsius. The module spoof-reads `step_user_metric=1` **within the launcher process only**, keeping its working complication path, then intercepts the OEM `SettingsProvider.getWeatherTemperature(ContentResolver)` **float** result to convert Celsius to Fahrenheit in memory. No periodic polling or shared-setting rewrite is needed; the OEM Weather app continues reading native `0` for Fahrenheit.

## Install and rollback

Build from the ZIP with JDK 17, Gradle 8.9 and Android SDK 35, install the debug APK, enable module in Vector with **launcher-only** scope, reboot and verify the suffix and value on watch faces and weather screens. To roll back, disable only this module in Vector and reboot. Do not remove or disable Full First Page v1.6.

Do **not** install this on an unverified watch or firmware build.
