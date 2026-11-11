# APPLLP 7 Pro — Persistent Light Doze (verified v1)

**Verified:** 10 November 2026, LOKMAT APPLLP 7 Pro `WP_C30_VP69_OLED`, Android 15, Magisk 31.1, active slot `_a`. A full reboot followed by an independent ADB check confirmed **Light Doze enabled (1), Deep Doze disabled (0)** and the module boot log indicated successful execution. SMS and incoming calls worked in a prior Light Doze trial. WhatsApp push timing and actual battery savings were **not** quantified.

## Install

Download **[APPLLP7PRO-Light-Doze-Magisk-Module-v1.zip](APPLLP7PRO-Light-Doze-Magisk-Module-v1.zip)** without extracting it, copy to the watch, and install via **Magisk → Modules → Install from storage**. Reboot the watch normally. This is **not** a firmware ZIP; do not flash it with fastboot or recovery.

SHA-256 of the module ZIP: `49fd0b8a0de987bf27422c4ab9f29794963db3ffa2c7c362b2b77b91ef5ca568`.

The on-watch module checks device identity, Android version, and slot before acting. The module waits for Android boot completion, disables **Deep** Doze, enables **Light** Doze, verifies both states, then checks again after 20 seconds. It does **not** force idle, change LTE/Wi-Fi, install Zygisk components, poll continuously, modify system partitions, or alter other Magisk modules.

## Verify after a FULL reboot

With the watch connected via USB ADB:

```powershell
.\adb shell cmd deviceidle enabled light
.\adb shell cmd deviceidle enabled deep
```

Expected responses: `1` and `0`, respectively. The actual module log is under `/data/adb/modules/appllp7_light_doze_persist/boot-status.log` (root access required). You can inspect it with the Magisk root shell.

**Important limitation:** A **soft/framework-only reboot** may reset the in-memory Doze switches without rerunning Magisk's `service.sh`. This was observed after a Vector-related soft reboot: both settings reverted to 0 until a full reboot. The module provides persistence across **normal full reboots**, not guaranteed persistence across framework soft restarts. No constantly running repair daemon was installed.

## Removal / rollback

Disable or remove **APPLLP 7 Pro - Persistent Light Doze** in Magisk Modules and perform a normal reboot. When removed, `uninstall.sh` attempts to return both Doze switches to the original factory-disabled baseline (Light 0, Deep 0). Verify the states with the commands above; merely disabling the module does not instantly undo an already applied runtime setting.

## Source and scope

The installable ZIP contains this directory's `module.prop`, `service.sh`, `uninstall.sh`, and empty `skip_mount` marker. Files are published for review. Only this precise watch/firmware family and Slot A were tested. Do not copy this module to unrelated models or switch slots.

The module is distinct from the older APPLLP 9 MAX root procedures. The parent [APPLLP 7 Pro root guide](../README.md) covers the verified bootloader/root setup.
