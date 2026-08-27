# LOKMAT-APPLLP-9-MAX-Root-Guide
LOKMAT APPLLP 9 MAX — Root + Full Recovery Backup Guide
LOKMAT APPLLP 9 MAX — Root + Full Recovery Backup Guide

This documents a successful root of the LOKMAT APPLLP 9 MAX running full Android 15, including how to enter MediaTek BROM, back up the original firmware, unlock the bootloader, install Magisk, and create both stock and known-good rooted recovery images.

This is based on one specific unit and firmware build. Do not blindly flash images from another watch, especially NVRAM/NVDATA/NVCFG, OTP, Proinfo, Protect or other device-specific partitions.

The biggest goals of this process were:

Preserve LTE/GPS and device-specific modem data
Make a stock recovery path before unlocking
Root without modifying more partitions than necessary
Keep a known-good rooted snapshot in case later experiments break something
Device tested

The device identifies itself as:

Model: APPLLP 9 MAX
Device: YZL_C30_TFT_JL
Android: 15
Platform: MT6768

MTKClient identifies the SoC as:

MT6768/MT6769 (Helio P65/G85 k68v1)
HW code: 0x707

The tested firmware fingerprint was:

alps/vnd_YZL_C30_TFT_JL/YZL_C30_TFT_JL:15/AP3A.240905.015.A2/mp1V13742:user/test-keys

The device uses an A/B partition layout, including:

boot_a / boot_b
vendor_boot_a / vendor_boot_b
init_boot_a / init_boot_b
vbmeta_a / vbmeta_b

That last part is important. On this Android 15 build, Magisk root is installed by patching the active slot's init_boot partition, not by blindly patching boot.img.

Tools used

On Windows:

Android Platform Tools
Python 3.12
MTKClient
UsbDk
MediaTek PreLoader USB VCOM driver
Magisk
PowerShell 7

Platform Tools were used from:

C:\Users\<username>\Downloads\PC\platform-tools

MTKClient was used from:

C:\Users\<username>\Downloads\mtkclient

In PowerShell, run ADB and Fastboot as:

.\adb
.\fastboot

and MTKClient as:

py mtk.py
1. Enable Developer Options

Start with the watch booted normally.

Open:

Settings → About phone / About device

Find:

Build number

Tap the build number repeatedly, usually 7 times, until Android tells you Developer Options have been enabled.

Then go back into Settings and open:

Developer options

Depending on the firmware, this may be under something like:

Settings → System → Developer options

Enable:

OEM unlocking
USB debugging

OEM unlocking is required so Fastboot will later permit the bootloader unlock.

USB debugging is required for ADB access.

2. Connect the watch to the PC and authorize ADB

Connect the APPLLP 9 MAX to the Windows PC over USB.

Open PowerShell in the Platform Tools folder and run:

.\adb devices

The watch should show an:

Allow USB debugging?

prompt.

Approve it, and if available, select:

Always allow from this computer

Run again:

.\adb devices

A successful connection looks similar to:

List of devices attached
MTK0002606101616460    device

Your serial number will be different.

If it shows:

unauthorized

look at the watch and approve the debugging prompt.

3. Record the actual device information

Before modifying anything, record what Android itself reports.

Useful commands:

.\adb shell getprop ro.product.device
.\adb shell getprop ro.product.model
.\adb shell getprop ro.board.platform
.\adb shell getprop ro.hardware
.\adb shell getprop ro.build.fingerprint

On the tested unit:

ro.product.device = YZL_C30_TFT_JL
ro.product.model = APPLLP 9 MAX
ro.board.platform = mt6768
ro.hardware = mt6768

This is useful because marketing listings for these watches may not always match what the hardware actually identifies as.

4. Check the bootloader and active slot

Reboot into Fastboot:

.\adb reboot bootloader

Verify Fastboot sees it:

.\fastboot devices

Then inspect the bootloader:

.\fastboot getvar all

Important findings on the tested device were:

slot-count: 2
current-slot: b
unlocked: no
secure: yes

You can also check only the active slot:

.\fastboot getvar current-slot

On this unit:

current-slot: b

Record your active slot.

Later, that determines whether you patch:

init_boot_a

or:

init_boot_b

Do not unlock yet. The goal is to make the important device-specific backups first.

5. Set up MTKClient and MediaTek USB access

MTKClient requires working MediaTek USB access on Windows.

The working setup used:

Python 3.12
UsbDk
MediaTek PreLoader USB VCOM driver

When the watch enters MediaTek PreLoader/BROM mode, Windows should briefly expose a MediaTek USB device.

On the tested watch, PreLoader appeared as:

MediaTek PreLoader USB VCOM (Android)

with:

VID_0E8D
PID_2000

The COM port number may vary.

6. APPLLP 9 MAX BROM mode trick

This was the most important hardware-specific discovery.

MTKClient's normal prompts tell you to hold Volume Up/Down, but the APPLLP 9 MAX does not expose conventional volume buttons.

On this watch:

Holding the physical crown/wheel button inward while connecting USB enters MediaTek BROM mode.

The reliable sequence was:

Completely power the watch off.
Disconnect USB.
Start the MTKClient command and let it wait for a device.
Press and hold the crown/wheel inward.
While holding it, connect USB.
Release the crown after MTKClient reports detection.

Successful output includes:

Port - Device detected :)
...
Preloader - BROM mode detected.

If you get:

Handshake failed

unplug the watch and retry.

The timing can be slightly finicky, but once the correct crown-button method is known, BROM is reproducible.

7. Dump the device's own preloader

Initially, MTKClient could detect BROM but could not initialize DRAM because the correct EMI/DRAM configuration was missing.

The solution was to dump the APPLLP's own preloader.

From the MTKClient folder:

py mtk.py --debugmode dumppreloader --filename=appllp9_preloader.bin

Use the crown-held BROM procedure.

A successful run produces:

appllp9_preloader.bin

On the tested unit the file size was:

332,960 bytes

Keep this file safe.

It is especially useful because it allows MTKClient to initialize this watch's DRAM correctly.

8. MTKClient argument-ordering quirk

One important CLI quirk came up during testing.

With the MTKClient version used here, the --preloader argument needed to appear after the subcommand.

This worked:

py mtk.py printgpt --debugmode --preloader=".\appllp9_preloader.bin"

After that, MTKClient successfully reported:

DAXFlash - DRAM setup passed.
DAXFlash - Successfully uploaded stage 2

Putting --preloader in the wrong place caused MTKClient to behave as if no preloader had been provided.

So the working pattern was:

py mtk.py COMMAND ... --preloader=".\appllp9_preloader.bin"
9. Inspect the GPT

Before backing up anything, inspect the partition layout:

py mtk.py printgpt --debugmode --preloader=".\appllp9_preloader.bin"

The tested firmware included partitions such as:

nvcfg
nvdata
nvram
proinfo
protect1
protect2
seccfg

boot_a
boot_b
vendor_boot_a
vendor_boot_b
init_boot_a
init_boot_b
dtbo_a
dtbo_b

vbmeta_a
vbmeta_b
vbmeta_system_a
vbmeta_system_b
vbmeta_vendor_a
vbmeta_vendor_b

modem_a
modem_b

super
userdata

Useful sizes on this build:

init_boot_a/b     8 MiB
boot_a/b         64 MiB
vendor_boot_a/b  64 MiB
modem_a/b       128 MiB
super             9 GiB
10. Create the stock-backup directory

Create a dedicated folder:

New-Item -ItemType Directory -Force .\APPLLP9_stock_backup | Out-Null

The goal is for this directory to remain the untouched original recovery set.

11. Back up the critical LTE/device-specific partitions first

Before unlocking or flashing anything, back up:

nvcfg
nvdata
nvram
proinfo
protect1
protect2
seccfg

Example:

py mtk.py r "nvcfg,nvdata,nvram,proinfo,protect1,protect2,seccfg" ".\APPLLP9_stock_backup\nvcfg.bin,.\APPLLP9_stock_backup\nvdata.bin,.\APPLLP9_stock_backup\nvram.bin,.\APPLLP9_stock_backup\proinfo.bin,.\APPLLP9_stock_backup\protect1.bin,.\APPLLP9_stock_backup\protect2.bin,.\APPLLP9_stock_backup\seccfg.bin" --preloader=".\appllp9_preloader.bin"

Use the usual BROM procedure.

A successful run ends with:

DaHandler - All partitions were dumped

These partitions matter especially because the APPLLP 9 MAX includes cellular and GPS functionality.

Some may contain device-specific modem/configuration information.

Do not flash another person's NVRAM/NVDATA/NVCFG onto your watch.

12. Back up the boot chain

Next, back up both A/B slots.

The tested set was:

boot_a
boot_b

init_boot_a
init_boot_b

vendor_boot_a
vendor_boot_b

dtbo_a
dtbo_b

vbmeta_a
vbmeta_b

vbmeta_system_a
vbmeta_system_b

vbmeta_vendor_a
vbmeta_vendor_b

lk_a
lk_b

modem_a
modem_b

Example:

py mtk.py r "boot_a,boot_b,init_boot_a,init_boot_b,vendor_boot_a,vendor_boot_b,dtbo_a,dtbo_b,vbmeta_a,vbmeta_b,vbmeta_system_a,vbmeta_system_b,vbmeta_vendor_a,vbmeta_vendor_b,lk_a,lk_b,modem_a,modem_b" ".\APPLLP9_stock_backup\boot_a.bin,.\APPLLP9_stock_backup\boot_b.bin,.\APPLLP9_stock_backup\init_boot_a.bin,.\APPLLP9_stock_backup\init_boot_b.bin,.\APPLLP9_stock_backup\vendor_boot_a.bin,.\APPLLP9_stock_backup\vendor_boot_b.bin,.\APPLLP9_stock_backup\dtbo_a.bin,.\APPLLP9_stock_backup\dtbo_b.bin,.\APPLLP9_stock_backup\vbmeta_a.bin,.\APPLLP9_stock_backup\vbmeta_b.bin,.\APPLLP9_stock_backup\vbmeta_system_a.bin,.\APPLLP9_stock_backup\vbmeta_system_b.bin,.\APPLLP9_stock_backup\vbmeta_vendor_a.bin,.\APPLLP9_stock_backup\vbmeta_vendor_b.bin,.\APPLLP9_stock_backup\lk_a.bin,.\APPLLP9_stock_backup\lk_b.bin,.\APPLLP9_stock_backup\modem_a.bin,.\APPLLP9_stock_backup\modem_b.bin" --preloader=".\appllp9_preloader.bin"
13. Save the preloader with the backup

Copy the dumped preloader into the backup set:

Copy-Item .\appllp9_preloader.bin .\APPLLP9_stock_backup\appllp9_preloader.bin -Force
14. Back up the super partition

The super partition contains Android's dynamic partitions, such as system/vendor/product-related logical partitions.

On the tested device:

super = 0x240000000 bytes

which is:

9 GiB

Dump it:

py mtk.py r "super" ".\APPLLP9_stock_backup\super.bin" --preloader=".\appllp9_preloader.bin"

At roughly 15–20 MB/s, this takes several minutes.

Verify:

Get-Item .\APPLLP9_stock_backup\super.bin |
    Select-Object Name,Length,FullName

Expected size:

9663676416
15. Back up the GPT

Create a folder:

New-Item -ItemType Directory -Force .\APPLLP9_stock_backup\GPT | Out-Null

Then:

py mtk.py gpt ".\APPLLP9_stock_backup\GPT" --preloader=".\appllp9_preloader.bin"

This should produce:

gpt.bin
gpt_backup.bin

If MTKClient says:

Please disconnect, start mtkclient and reconnect.

just disconnect the watch, wait a few seconds, rerun the command, and re-enter BROM.

That usually means the previous DA session was still active.

16. Generate SHA-256 hashes

Hashes let you verify later that your backup files have not changed or become corrupted.

For the main stock-backup folder:

Get-ChildItem .\APPLLP9_stock_backup -File |
    Get-FileHash -Algorithm SHA256 |
    Export-Csv .\APPLLP9_stock_backup_SHA256.csv -NoTypeInformation -Force

For GPT:

Get-ChildItem .\APPLLP9_stock_backup\GPT -File |
    Get-FileHash -Algorithm SHA256 |
    Export-Csv .\APPLLP9_stock_backup\GPT_SHA256.csv -NoTypeInformation -Force

Do not create the hash CSV inside the same directory while simultaneously enumerating it unless you exclude the CSV, because PowerShell may try to hash the file while it is being written.

17. Boot Android again

Disconnect USB.

Power the watch on normally.

Let Android fully boot.

Reconnect USB without holding the crown.

Verify:

cd $HOME\Downloads\PC\platform-tools
.\adb devices
18. Confirm the active slot again

Before choosing the Magisk image, check:

.\adb shell getprop ro.boot.slot_suffix

On the tested device:

_b

Therefore the stock image to patch was:

init_boot_b.bin

If yours says:

_a

use init_boot_a.bin.

19. Copy the stock init_boot to the watch

For slot B:

.\adb push "$HOME\Downloads\mtkclient\APPLLP9_stock_backup\init_boot_b.bin" /sdcard/Download/init_boot_b.bin

Verify:

.\adb shell ls -lh /sdcard/Download/init_boot_b.bin

Expected size:

8.0M

or:

8388608 bytes
20. Patch init_boot with Magisk

Install/open Magisk.

Choose:

Install → Select and Patch a File

Select:

Download/init_boot_b.bin

Magisk should create something similar to:

magisk_patched-30700_xxxxx.img

in the Download folder.

Do not choose Direct Install at this stage.

21. Pull the patched image back to Windows

Create a separate root-image directory:

New-Item -ItemType Directory -Force "$HOME\Downloads\APPLLP9_root" | Out-Null

Pull the patched file:

.\adb pull /sdcard/Download/magisk_patched-30700_xxxxx.img "$HOME\Downloads\APPLLP9_root\magisk_patched_init_boot_b.img"

Verify:

Get-Item "$HOME\Downloads\APPLLP9_root\magisk_patched_init_boot_b.img" |
    Select-Object Name,Length,FullName

The patched image should remain exactly:

8388608 bytes
22. Compare stock and patched hashes

Hash both:

Get-FileHash "$HOME\Downloads\APPLLP9_root\magisk_patched_init_boot_b.img" -Algorithm SHA256

and:

Get-FileHash "$HOME\Downloads\mtkclient\APPLLP9_stock_backup\init_boot_b.bin" -Algorithm SHA256

The hashes should be different.

That confirms the Magisk image is genuinely modified rather than simply being another copy of stock.

23. Reboot to Fastboot and verify before unlocking

Run:

.\adb reboot bootloader

Verify:

.\fastboot devices

Then:

.\fastboot getvar current-slot

On the tested device it remained:

current-slot: b

You can also check:

.\fastboot flashing get_unlock_ability

Interestingly, the tested bootloader returned:

unlock_ability = 16777216

rather than the more usual-looking 1.

Despite that unusual value, the standard unlock command worked.

24. Unlock the bootloader
Warning

This is the first destructive step.

Bootloader unlocking factory-resets Android userdata.

Make sure your stock backups are complete first.

Run:

.\fastboot flashing unlock

The tested watch returned:

(bootloader) Start unlock flow
OKAY

Then verify:

.\fastboot getvar unlocked

Expected:

unlocked: yes

Also check:

.\fastboot getvar current-slot

to ensure the active slot has not unexpectedly changed.

25. Flash the Magisk-patched init_boot

For slot B:

.\fastboot flash init_boot_b "$HOME\Downloads\APPLLP9_root\magisk_patched_init_boot_b.img"

A clean successful flash looks like:

Sending 'init_boot_b' ... OKAY
Writing 'init_boot_b' ... OKAY
Finished.

If your active slot is A, flash init_boot_a instead.

26. Reboot Android

Run:

.\fastboot reboot

The first boot may take longer than normal.

Because the bootloader unlock erased userdata, expect to:

go through setup again
re-enable Developer Options
re-enable USB Debugging
reauthorize the PC

You may also see an unlocked-bootloader warning during startup.

That is normal.

27. Check the post-unlock boot state

Once Android is running:

.\adb devices

Then:

.\adb shell getprop ro.boot.slot_suffix

The tested watch remained:

_b

Check verified boot:

.\adb shell getprop ro.boot.verifiedbootstate

The tested device returned:

orange

This is expected with an unlocked bootloader.

28. Finish Magisk initialization

Because bootloader unlocking erased userdata, Magisk's app-side installation state was also reset.

Open Magisk.

On the tested watch, Magisk detected the patched boot environment, performed additional setup, and requested a reboot.

Allow it to complete.

Then verify root:

.\adb shell su -c id

Successful root should look similar to:

uid=0(root) gid=0(root) groups=0(root) context=u:r:magisk:s0

That confirms working Magisk root.

29. If su says Permission denied

One issue encountered during testing:

The first Superuser prompt for Shell appeared on the watch, but it timed out before approval.

After that:

.\adb shell su -c id

returned:

Permission denied

The fix was:

Magisk → Superuser → Shell → Grant

After manually granting Shell access:

.\adb shell su -c id

returned:

uid=0(root) gid=0(root) groups=0(root) context=u:r:magisk:s0

So a Permission denied result does not necessarily mean root failed.

30. Save a small known-good root package

Once root is confirmed, save the known-good patched init_boot separately.

Example:

New-Item -ItemType Directory -Force "$HOME\Downloads\APPLLP9_ROOTED_WORKING" | Out-Null

Copy the patched image:

Copy-Item `
"$HOME\Downloads\APPLLP9_root\magisk_patched_init_boot_b.img" `
"$HOME\Downloads\APPLLP9_ROOTED_WORKING\magisk_patched_init_boot_b.img"

Save identifying information:

.\adb shell getprop ro.build.fingerprint > "$HOME\Downloads\APPLLP9_ROOTED_WORKING\build_fingerprint.txt"

.\adb shell getprop ro.boot.slot_suffix > "$HOME\Downloads\APPLLP9_ROOTED_WORKING\active_slot.txt"

.\adb shell getprop ro.boot.verifiedbootstate > "$HOME\Downloads\APPLLP9_ROOTED_WORKING\verifiedbootstate.txt"

.\adb shell su -c id > "$HOME\Downloads\APPLLP9_ROOTED_WORKING\root_test.txt"

Hash the root image:

Get-FileHash `
"$HOME\Downloads\APPLLP9_ROOTED_WORKING\magisk_patched_init_boot_b.img" `
-Algorithm SHA256 |
Export-Csv "$HOME\Downloads\APPLLP9_ROOTED_WORKING\SHA256.csv" -NoTypeInformation
31. Create a known-good rooted firmware snapshot

Once Android and Magisk are both confirmed working, make another firmware-level snapshot.

This gives you two distinct recovery points:

original stock
known-good rooted

Power off the watch.

From MTKClient:

cd $HOME\Downloads\mtkclient

Create:

New-Item -ItemType Directory -Force .\APPLLP9_rooted_snapshot | Out-Null

Then:

py mtk.py rl ".\APPLLP9_rooted_snapshot" --skip="userdata" --preloader=".\appllp9_preloader.bin"

Use the usual crown-held BROM procedure.

userdata was deliberately excluded because this is intended as a firmware-recovery snapshot, not a personal-data backup.

The dump takes a while because super is 9 GiB.

A successful run ends with:

DaHandler - All Dumped partitions success.
32. Hash the rooted snapshot

Generate a manifest:

Get-ChildItem .\APPLLP9_rooted_snapshot -File |
    Get-FileHash -Algorithm SHA256 |
    Export-Csv .\APPLLP9_rooted_snapshot_SHA256.csv -NoTypeInformation -Force

Inspect large files if desired:

Get-ChildItem .\APPLLP9_rooted_snapshot -File |
    Sort-Object Length -Descending |
    Select-Object -First 15 Name,Length |
    Format-Table -AutoSize

The tested snapshot included, among others:

super.bin          9663676416
modem_a.bin         134217728
modem_b.bin         134217728
boot_a.bin           67108864
boot_b.bin           67108864
vendor_boot_a.bin    67108864
vendor_boot_b.bin    67108864
nvram.bin            67108864
nvdata.bin           67108864
metadata.bin         67108864
nvcfg.bin            33554432
33. Verify the rooted snapshot really contains the working Magisk image

Compare:

Get-FileHash .\APPLLP9_rooted_snapshot\init_boot_b.bin -Algorithm SHA256

with:

Get-FileHash "$HOME\Downloads\APPLLP9_ROOTED_WORKING\magisk_patched_init_boot_b.img" -Algorithm SHA256

On the tested watch, the two hashes matched exactly.

That proves the rooted snapshot captured the actual working Magisk init_boot_b.

34. Verify super remained stock

Compare:

Get-FileHash .\APPLLP9_stock_backup\super.bin -Algorithm SHA256

and:

Get-FileHash .\APPLLP9_rooted_snapshot\super.bin -Algorithm SHA256

On the tested watch, both produced:

FFAA657C5BD191AE01F88BFAD33DE8BC5A99391544FBA735C40F3C4F0241EE59

So Magisk rooting did not modify the super partition.

That is useful because it confirms the stock super.bin is still a valid copy of the original system/vendor/product firmware.

Final recovery structure

At the end, I kept three different recovery sets.

1. Original stock firmware
APPLLP9_stock_backup

This contains the important original/pre-root recovery images, including:

appllp9_preloader.bin

boot_a.bin
boot_b.bin

init_boot_a.bin
init_boot_b.bin

vendor_boot_a.bin
vendor_boot_b.bin

dtbo_a.bin
dtbo_b.bin

vbmeta_a.bin
vbmeta_b.bin
vbmeta_system_a.bin
vbmeta_system_b.bin
vbmeta_vendor_a.bin
vbmeta_vendor_b.bin

lk_a.bin
lk_b.bin

modem_a.bin
modem_b.bin

nvcfg.bin
nvdata.bin
nvram.bin

proinfo.bin
protect1.bin
protect2.bin
seccfg.bin

super.bin

GPT\gpt.bin
GPT\gpt_backup.bin

This is the most important recovery set.

2. Known-good rooted firmware snapshot
APPLLP9_rooted_snapshot

This represents:

The watch in a state where Android boots correctly and Magisk root is known to work.

It includes essentially every GPT firmware partition except userdata.

3. Small known-good root package
APPLLP9_ROOTED_WORKING

This contains the known-working Magisk-patched init_boot plus identifying information and hashes.

Recovery philosophy

Do not immediately restore the entire firmware whenever something breaks.

Restore the smallest relevant component first.

For example:

Problem	First recovery attempt
Bad Magisk module / root bootloop	Restore known-good rooted init_boot
Want to remove Magisk	Restore stock init_boot
Damaged system/vendor/product files	Restore super
Corrupted boot component	Restore relevant boot, vendor_boot, or init_boot
Cellular configuration problem	Diagnose before touching NVRAM/NVDATA/NVCFG
Partition-table damage	GPT recovery only when specifically necessary

Be especially careful with:

preloader
GPT
OTP
seccfg
NVRAM
NVDATA
NVCFG
proinfo
protect1
protect2

These are not partitions I would casually rewrite.

Restoring stock init_boot if Magisk breaks boot

If Fastboot still works and the problem is clearly root-related, restoring the original init_boot is much safer than reflashing the whole watch.

For example, if slot B is active:

.\fastboot flash init_boot_b init_boot_b.bin

using the untouched stock file.

Then:

.\fastboot reboot
Do not casually relock the bootloader

Do not run:

fastboot flashing lock

while Magisk-modified firmware is installed.

If you ever want to return fully to stock and relock, restore the stock boot-chain components first, confirm the watch boots correctly as stock, and only then consider relocking.

Key APPLLP 9 MAX discoveries
The APPLLP 9 MAX is rootable

Magisk root works successfully on this Android 15 build.

The hardware identifies as MT6768/MT6769

MTKClient detected:

MT6768/MT6769 (Helio P65/G85 k68v1)

despite potentially conflicting product listings.

The crown is the BROM key

With the watch completely powered off:

Hold the crown/wheel inward and connect USB.

That reliably enters MediaTek BROM mode on the tested unit.

Dumping the device's preloader solves the DRAM problem

MTKClient initially could not initialize DRAM.

Dumping:

appllp9_preloader.bin

and supplying it to subsequent commands resulted in:

DRAM setup passed.
Successfully uploaded stage 2
Android 15 uses init_boot

The correct Magisk target on this build is the active slot's:

init_boot

not blindly boot.img.

The watch uses proper A/B slots

Always check:

.\adb shell getprop ro.boot.slot_suffix

or:

.\fastboot getvar current-slot

before flashing.

LTE/GPS-related device data can be preserved

MTKClient successfully backed up the important radio/configuration partitions before the bootloader unlock.

That is particularly useful on a cellular Android watch.

super can be fully preserved

The complete 9 GiB super partition was successfully dumped.

A known-good rooted snapshot can also be preserved

After rooting, MTKClient successfully dumped essentially the entire firmware state except userdata.

That makes future experimentation much safer.

Final advice

The most important part of the entire process is:

Make the stock backups before unlocking the bootloader.

At minimum, preserve:

preloader
init_boot_a/b
boot_a/b
vendor_boot_a/b
vbmeta*
modem_a/b
NVRAM
NVDATA
NVCFG
seccfg
super
GPT

Generate SHA-256 hashes and keep a second copy of the backup on another physical drive or computer.

After that, you can experiment with Magisk modules, debloating, launchers, system settings and other root modifications with a much stronger recovery path.
