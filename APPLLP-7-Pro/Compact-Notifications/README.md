# APPLLP 7 Pro — Compact Notifications (Vector/LSPosed)
 
**v2 verified; v3 denser profile experimental.** Source only, for the exact tested APPLLP 7 Pro Android 15 OEM launcher firmware.
 
[Download complete public source bundle (.tar.xz)](APPLLP7-Compact-Notifications-PUBLIC-SOURCE-v2-v3.tar.xz). Extract with `tar -xf APPLLP7-Compact-Notifications-PUBLIC-SOURCE-v2-v3.tar.xz` on Windows or Linux. The archive includes **two complete Android Gradle projects**, `v2-verified` and `v3-experimental`, and build/rollback instructions. SHA-256: `837d7e2b5b89395f0aa6ebceda6b2ae5899603a74f9a3f4944fd9e51ef19e556`.
 
## Verified environment
 
- Device: LOKMAT APPLLP 7 Pro, `WP_C30_VP69_OLED`
- Android 15, OEM firmware `LOKMAT_APPLLP_7_PRO_C30_EN_V1.0_20260921`
- Stock launcher `com.android.launcher3`; Vector scope **only** this launcher package
- Full Android Gradle projects use JDK 17, Gradle 8.9, Android Gradle Plugin 8.7.3, SDK 35
 
## Notification layout comparison
 
| Element | v2 — verified | v3 — experimental |
| --- | ---: | ---: |
| Title | 18sp | 14sp |
| Body | 16sp | 12sp |
| Icon | 32dp | 24dp |
| Bottom padding | maximum 6dp | maximum 2dp |
| Time | 11sp | 10sp |
 
**v2** was installed, visually approved, and confirmed via Vector hook logs after reboot. **v3** was built with the Android toolchain and upgraded in-place successfully, but ADB did not reconnect after the requested reboot, so subsequent visual and hook verification was not completed. The v3.1 correction fixed the *private installer's package-path detector*; it is **not** a different Android APK (the code remains versionCode 3).
 
## Safety and recovery
 
Both modules hook specific OEM notification-row view IDs. They change font size, icon size, and certain vertical spacing, while leaving launcher APK, notification permissions, channels, action-button handlers, and horizontal round-screen insets untouched. There is no guaranteed compatibility with other firmware or devices. Disable the Compact Notifications module in Vector and reboot to revert the UI; for v3-to-v2 downgrades, a backup of the previously installed, **identically signed** v2 APK is needed. Don't uninstall a working module to bypass an APK signature mismatch.
 
This publication contains **only privacy-screened source**, not private test scripts, diagnostic ZIPs, notifications, device serials, debug signing keys, or personal host paths.
