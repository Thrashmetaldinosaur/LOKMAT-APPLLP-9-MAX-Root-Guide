# LOKMAT APPLLP 7 Pro — Android 15 Magisk root (verified)

**Status:** Successfully rooted and booted on 9 November 2026 with Magisk **v31.1**. Root Checker confirmed working superuser access.

This is a **short root guide**, not a full firmware-backup procedure. You do **not** need to dump the entire 62.5 GB eMMC user area to root this model. You **do** need a genuine, *matching* stock \`init_boot_a\` image before unlocking, both as patch input and a minimal recovery option. Keep that 8 MiB file; **do not flash someone else's image**.

## Exact tested device

| Property | Tested value |
| --- | --- |
| Model | LOKMAT APPLLP 7 Pro |
| Product/device codename | \`WP_C30_VP69_OLED\` |
| OS | Android 15 |
| Firmware build | \`LOKMAT_APPLLP_7_PRO_C30_EN_V1.0_20260921\` |
| SoC | MediaTek MT6768/MT6769 family (HW code \`0x707\`) |
| Active partition slot | **A** (\`_a\`) |
| Bootloader | Initially locked; \`fastboot flashing unlock\` worked |
| Magisk | **31.1**, patched stock \`init_boot_a\` |
| Stock \`init_boot_a\` | **8,388,608 bytes** |
| Stock SHA-256 | \`b4bbf7fab5d7ddfa8d821d79718457b386786c836059b7784f4e10e1e7110d3c\` |
| Tested patched SHA-256 | \`19764da82435c42930211e518c4b2953279ca4de87e8853e0bad70448658526f\` |

**Do not treat these hashes as universal**: they identify the particular tested firmware and Magisk output. If your build or stock image differs, stop and investigate rather than bypassing checks. **The inactive slot B was observed to contain zeroed boot-chain images**; never switch this tested watch to B as part of rooting.

## Requirements

- Windows with [Android SDK Platform Tools](https://developer.android.com/tools/releases/platform-tools): \`adb\` and \`fastboot\`.
- [Python 3](https://www.python.org/) and [MTKClient](https://github.com/bkerler/mtkclient) with working MediaTek USB/UsbDk drivers, **unless you already have a verified stock \`init_boot_a\` for your exact build**.
- Official [Magisk v31.1 APK](https://github.com/topjohnwu/Magisk/releases/tag/v31.1).
- USB debugging and **OEM unlocking** enabled under Developer Options.
- A reliable magnetic USB connection (check contacts for debris). Have the watch charged.
- Time to complete Android setup again: **bootloader unlocking factory-resets userdata** and resets ADB authorizations.

**Never flash the APPLLP 9 MAX preloader or boot images onto an APPLLP 7 Pro.** Similar SoC does not mean compatible board firmware.

## 1. Verify the watch and active slot

With Android running and authorized ADB:

\`\`\`powershell
adb devices
adb shell getprop ro.product.device
adb shell getprop ro.build.display.id
adb shell getprop ro.boot.slot_suffix
\`\`\`

For the tested build, these must indicate \`WP_C30_VP69_OLED\`, \`LOKMAT_APPLLP_7_PRO_C30_EN_V1.0_20260921\`, and \`_a\`.

**Do not continue with another model, firmware, or slot.**

## 2. Obtain the original stock \`init_boot_a\` (8 MiB only)

If you already have a genuine, checksum-verified stock \`init_boot_a.bin\` for the **exact same firmware**, reuse it. A full eMMC backup is **not required** for this root procedure.

Otherwise, a **single-partition read** through MTKClient is sufficient. On the tested APPLLP 7 Pro, BROM entry worked as follows:

1. Power the watch **fully off** and disconnect its magnetic USB cradle.
2. Start the MTKClient command so it is waiting for a device.
3. **Hold the top-right physical button** while connecting USB.
4. Release after MediaTek BROM detection.

On this unit, MTKClient needed the **watch's own preloader** to initialize DRAM. If you don't already have it, first obtain that from **this same watch** (one read-only BROM session):

\`\`\`powershell
py mtk.py dumppreloader --filename="appllp7_own_preloader.bin"
\`\`\`

Then read **only** \`init_boot_a\` in another BROM session:

\`\`\`powershell
py mtk.py r init_boot_a "init_boot_a.bin" --preloader=".\appllp7_own_preloader.bin"
\`\`\`

The \`--preloader\` option placement depends on MTKClient revision/subcommand; if its parser rejects it, check \`py mtk.py --help\` and \`py mtk.py r --help\`, and place the option where your installed version requires. **Do not try another watch's preloader.** No write/erase command is needed.

Power the watch on normally again. Verify the file:

\`\`\`powershell
(Get-Item .\init_boot_a.bin).Length
(Get-FileHash .\init_boot_a.bin -Algorithm SHA256).Hash
\`\`\`

Expected on this *tested* build: **8388608** bytes; SHA-256 **\`b4bbf7fab5d7ddfa8d821d79718457b386786c836059b7784f4e10e1e7110d3c\`**. Keep this unmodified original for a possible recovery.

> **Optional but prudent:** Back up critical device-specific partitions separately before the unlock if you expect to experiment extensively. They were backed up in the original investigation, but a full flash dump is not necessary merely to obtain root. A bootloader unlock will erase user data regardless.

## 3. Patch \`init_boot_a\` with Magisk

Android 15 on this watch uses a **version 4 \`init_boot\`** image with a ramdisk. The image that was successfully patched had **no kernel** and an approximately 2.6 MB compressed stock ramdisk. **Patch \`init_boot_a\`, not \`boot_a\`**.

### Option A: Magisk app file picker

If Magisk's **Install → Select and Patch a File** opens a normal file manager:

1. \`adb push .\init_boot_a.bin /sdcard/Download/init_boot_a.img\`
2. In Magisk, select the file from Downloads and let Magisk patch it.
3. Pull the generated \`magisk_patched*.img\` file back to the PC.
4. Verify its size, boot image header, and SHA-256. Do not flash an unverifiable output.

### Option B: Working ADB rootless patcher — avoids broken file picker

**This was the successful method on the tested APPLLP 7 Pro.**

On its Android 15 firmware, Magisk's file-pick request was repeatedly redirected into an audio-only/photo picker even when a separate file manager was installed. Instead, we used the **official installed Magisk 31.1 APK's bundled \`boot_patch.sh\` and matching ARM64 binaries** in \`/data/local/tmp\`. Root was **not required to patch**; no partition was written during this step.

Install official Magisk v31.1 on the still-locked watch, authorize ADB, download the adjacent [\`rootless_magisk_patch.py\`](rootless_magisk_patch.py) script, and run (from a folder containing the stock image):

\`\`\`powershell
py -3 .\rootless_magisk_patch.py --stock ".\init_boot_a.bin" --adb "C:\path\to\platform-tools\adb.exe"
\`\`\`

Or if \`adb\` is on PATH:

\`\`\`powershell
py -3 .\rootless_magisk_patch.py --stock ".\init_boot_a.bin"
\`\`\`

If multiple ADB devices are attached, supply \`--serial YOUR_ADB_SERIAL\`.

The script verifies the model, **exact tested build**, active slot A, 8 MiB stock image hash, and **official v31.1 APK hash**; extracts Magisk's own scripts/binaries from the installed APK; patches an unmodified *copy* using \`boot_patch.sh\`; verifies the output's header, remote/local SHA-256, and Magisk ramdisk test; and writes:

\`\`\`text
appllp7-root-output/
  magisk_patched_init_boot_a.img
  PATCH-REPORT.json
\`\`\`

**It does not unlock, reboot, or flash**. Do not bypass safety checks if they fail. This script targets **only the tested firmware and Magisk v31.1**, not every APPLLP 7 Pro update.

## 4. Unlock the bootloader (WIPES Android data)

**This is destructive.** Verify the stock and patched images are safely stored on the PC **before** proceeding. Enable OEM unlocking, then:

\`\`\`powershell
adb reboot bootloader
fastboot devices
fastboot getvar current-slot
fastboot getvar unlocked
fastboot flashing get_unlock_ability
\`\`\`

On the tested unit, \`current-slot\` was \`a\`. The unusual \`get_unlock_ability\` result was \`16777216\` rather than \`1\`, but unlock still succeeded.

Proceed only if you understand the factory reset and have the correct device selected:

\`\`\`powershell
fastboot flashing unlock
\`\`\`

Approve on the watch if prompted. Confirm:

\`\`\`powershell
fastboot getvar unlocked
fastboot getvar current-slot
\`\`\`

**Expected: \`unlocked: yes\` and \`current-slot: a\`.** If either is wrong or Fastboot loses the device, **stop**.

## 5. Flash only the patched \`init_boot_a\`

From the directory containing your locally generated patched image:

\`\`\`powershell
fastboot flash init_boot_a ".\appllp7-root-output\magisk_patched_init_boot_a.img"
fastboot reboot
\`\`\`

The tested device reported \`Sending ... OKAY\` and \`Writing ... OKAY\`, then booted Android successfully. No \`super\`, \`vbmeta\`, GPT, preloader, or slot B writes were required.

After the unlock wipe, complete Android setup again. Install/reopen **Magisk v31.1** if needed; it may perform additional setup and ask for a **reboot**. Allow that to finish.

## 6. Verify root

With Magisk initialized:

\`\`\`powershell
adb shell su -c id
\`\`\`

A successful result contains \`uid=0(root)\`. Allow **Shell** superuser access in Magisk if prompted. If that prompt was missed, grant **Shell** manually in Magisk → Superuser and retry. On the tested unit, **Root Checker** also reported root access properly installed.

After an initial reboot, scrcpy's rotated mirror briefly misaligned its mouse clicks; a later restart resolved that. This was not a rooting failure.

## Minimal rollback / important cautions

If a Magisk-related boot problem occurs **and Fastboot still works**, while the bootloader remains **unlocked** and current slot is **A**, you can consider restoring the exact saved stock image:

\`\`\`powershell
fastboot flash init_boot_a ".\init_boot_a.bin"
fastboot reboot
\`\`\`

Restore **only after verifying which partition caused the failure**. This does not reverse the earlier userdata wipe.

- **Never relock the bootloader while modified firmware is installed.**
- **Never switch this tested watch to slot B**; the captured inactive boot-chain partitions included zeroed images.
- Never flash a different model's \`init_boot\`, preloader, or device-specific partitions.
- Keep the *stock* image private/unchanged; **no firmware image or user-specific partition dump is hosted in this repository**.
- Google Services Framework/check-in IDs are **device-specific** and should not be published or reused from someone else's watch.
- Off-state charging behavior remains **uninvestigated/unresolved**; it is unrelated to proof of root.

## What was actually proven

On the exact tested unit: BROM via top-right button; own-preloader-assisted firmware access; stock \`init_boot_a\` extraction; Magisk v31.1 rootless patch; successful \`fastboot flashing unlock\`; successful \`fastboot flash init_boot_a\`; normal Android 15 boot; Magisk app initialization; working Root Checker superuser access.

**The complete 62.5 GB backup was taken for recovery/experimentation, not because rooting required it.** This short guide deliberately omits that long backup process.

Related: [APPLLP 9 MAX root guide](../README.md), which uses a different board and, on the tested APPLLP 9 unit, a different active slot.

## Verified follow-up: persistent Light Doze (10 November 2026)

A reversible Magisk module for the rooted APPLLP 7 Pro is published in **[Light-Doze-Magisk-v1](Light-Doze-Magisk-v1/README.md)**, including the directly installable ZIP and its source scripts. On the tested Android 15/Slot A watch, the module successfully enabled **Light Doze ON / Deep Doze OFF** following a full reboot. A soft/framework-only reboot may reset the settings until the next full boot. The battery-life improvement has not yet been quantified.

## Verified follow-up: YouTube + ReVanced auto fullscreen (11–12 November 2026)

See **[YouTube-ReVanced-Auto-Fullscreen-v6.2](YouTube-ReVanced-Auto-Fullscreen-v6.2/README.md)** for the working Magisk `service.sh` approach, device measurements, and recovery notes. Regular YouTube and `app.revanced.android.youtube` were both confirmed working after reboot. It temporarily changes the logical viewport **466×466 → 466×426** *after foreground playback begins*, then returns to 466×466 on Home. It does **not** patch YouTube's APK or require Vector hooks. A static `normal + notround` system configuration was tested and **rolled back** because it did not independently solve fullscreen.

## Verified follow-up: reversible OEM fitness debloat (10 November 2026)

See **[Fitness-Debloat](Fitness-Debloat/README.md)** for the seven OEM health/fitness packages disabled for Android user 0 on the tested watch and the commands to restore them. Battery savings have not yet been quantified. The launcher and core connectivity services were preserved.

## Off-state charging

As of 12 November 2026, the tester reports that LOKMAT **plans** powered-off charging support in a future OTA. This is **not** a confirmed firmware release or a working custom modification. Existing firmware modifications should not be presented as solving powered-off charging.

## Android 15 Xposed/Vector compatibility note (10 November 2026)

On the tested device, an LSPosed interface/notification issue was resolved by switching to **Vector** (an LSPosed-compatible implementation). This is a **device observation**, not a packaged source patch or a compatibility guarantee for other builds. No older S13 YouTube Xposed fullscreen hooks are required for the separate v6.2 Magisk YouTube/ReVanced fix.


## Current customization tracker (13 November 2026)

See **[APPLLP 7 Pro project tracker](PROJECT-TRACKER.md)** for verified fixes, outstanding display/wake issues, and the requested Recents shortcut, longer lift-to-wake cooldown, aspect-ratio shortcut, and per-app aspect-ratio compatibility improvements.

- [Pure Face / DigitalPureBlack watch face](Pure-Face/README.md) — installed and confirmed by the tester; installation helper included, user-supplied graphical assets not committed.
- [Celsius-to-Fahrenheit display workaround](Weather-Temperature-Fahrenheit/README.md) — **user confirmed working after a full reboot (13 Nov 2026)**; repeated-conversion edge cases remain under review.
- Compact notification layout — a launcher-scoped Vector module was reported to work initially, **but user later reports it isn't working**; now tracked as a regression, not resolved.
- Unwanted persistent notifications — investigate selective removal without silencing essential indicators.
- Full First Page v1 — clock/date removal and first-page expansion are **still experimental**, awaiting on-device confirmation.

**Display warning:** On the observed configuration, a 154 DPI override prevented the separate YouTube/ReVanced fullscreen v6.2 Magisk service from starting; returning to 182 native DPI with `wm density reset` restored fullscreen. Preserve the native 466×466/182 DPI display during other interface work.
