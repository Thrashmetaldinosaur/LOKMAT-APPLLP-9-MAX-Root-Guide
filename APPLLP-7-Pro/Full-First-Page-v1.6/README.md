# Full First Page v1.6 — verified on LOKMAT APPLLP 7 Pro

**User-confirmed 14 November 2026.** The native Style 5 app drawer shows **10 regular app icons (5 × 2) plus the four original favorites along the bottom**, with the oversized clock/date widget removed. The screenshot confirms the intended visual result; APK installation and reboot were successful. The user reported "perfect." Other firmware builds and devices remain untested.

## Requirements / tested environment

- Device: LOKMAT APPLLP 7 Pro, `WP_C30_VP69_OLED` (`DW Watch`)
- Android 15, firmware `LOKMAT_APPLLP_7_PRO_C30_EN_V1.0_20260921`
- Native 466 × 466 display at **182 physical DPI**; no density override
- OEM launcher `com.android.launcher3`, **Style 5** (`settings get system app_list_style` = `5`)
- Magisk root with **Vector (LSPosed-compatible)**; scope the module **only** to `com.android.launcher3`
- Module package: `com.appllp7.fullfirstpage`, v1.6, versionCode 7

## Behavior

The stock MediaTek launcher dynamically instantiates its app-menu renderer using a custom `DexClassLoader`. Earlier hooks on the parent loader registered but never reached the live `MobilePagedAllAppsBoard` implementation. v1.6 captures the runtime board via `AllAppsBoardFactory.create` and its renderer setter.

The first four OEM app indices remain the four dock favorites, using their original positions and background. All remaining apps use the existing native 5 × 2 grid; the redundant `drawTimeWidget()` clock/date is suppressed. The launcher is **not replaced or re-signed**, the favorites and custom app-order database are not rewritten, and no background polling service is added.

## Build and install

This is a **source-based Vector module**. The verified, sanitized source archive includes the Java hook, Gradle Android project, Xposed compile-only stubs, and complete build instructions. It deliberately excludes private ADB serials, user-specific Windows paths, full diagnostic logs, and firmware backups.

Build with JDK 17, Gradle 8.9, Android SDK 35, and Android Gradle Plugin 8.7.3:

```powershell
gradle --no-daemon :app:assembleDebug
adb devices
adb install -r .\app\build\outputs\apk\debug\app-debug.apk
```

Enable **APPLLP7 Full First Page v1.6** in Vector with scope **`com.android.launcher3` only**, reboot, and verify icon taps and swipes. **Rollback:** disable that module in Vector and reboot; the OEM clock/date and dock return. Do not clear launcher data.

**Source archive SHA-256:** `c93d398a1c6f0eb4191b1ee9386bea67760e65721d0b5caa4d19abb710857d1d` (the clean 12,182-byte source ZIP, retained separately). Do not assume this README alone includes the ZIP.

## Version history (technical)

- v1.0–v1.3: early Vector helper API incompatibility and parent-classloader hooks never reaching the actual renderer.
- v1.4: discovered and hooked the runtime class-loader instance; grid readiness guard still prevented activation.
- v1.5: clock/date removed and 10-icon native grid active, but OEM dock favorites vanished.
- **v1.6: confirmed 10-icon grid + original four favorites + no clock/date.**

No claim is made about untested Android updates, alternate launchers, or other LOKMAT models.
