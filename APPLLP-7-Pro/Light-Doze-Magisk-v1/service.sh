#!/system/bin/sh
# Magisk nonblocking late_start module hook. Bounded, root-only deviceidle commands.
# Does NOT force an idle state, alter network configs, or change anything in /system.
MODDIR=${0%/*}
LOG="$MODDIR/boot-status.log"

note() {
  printf '%s | %s\n' "$(/system/bin/date '+%Y-%m-%dT%H:%M:%S%z' 2>/dev/null)" "$*" >> "$LOG"
}

note "service.sh launched"
DEVICE=$(/system/bin/getprop ro.product.device)
ANDROID=$(/system/bin/getprop ro.build.version.release)
SLOT=$(/system/bin/getprop ro.boot.slot_suffix)
if [ "$DEVICE" != "WP_C30_VP69_OLED" ] || [ "$ANDROID" != "15" ] || [ "$SLOT" != "_a" ]; then
  note "ABORT: device guard mismatch: device=$DEVICE android=$ANDROID slot=$SLOT"
  exit 1
fi

# Wait for framework deviceidle service to be ready. Never block boot startup.
i=0
while [ "$i" -lt 60 ]; do
  if [ "$(/system/bin/getprop sys.boot_completed)" = "1" ]; then
    break
  fi
  /system/bin/sleep 2
  i=$((i + 1))
done
if [ "$(/system/bin/getprop sys.boot_completed)" != "1" ]; then
  note "ABORT: boot_completed not reached in 120 seconds"
  exit 1
fi

# Allow later OEM services a brief opportunity to initialize.
/system/bin/sleep 8

apply_and_check() {
  # Use separate commands; never depend on shell quoting via ADB.
  deep_output=$(/system/bin/cmd deviceidle disable deep 2>&1) || {
    note "FAIL: disable deep: $deep_output"
    return 1
  }
  light_output=$(/system/bin/cmd deviceidle enable light 2>&1) || {
    note "FAIL: enable light: $light_output"
    return 1
  }
  light=$(/system/bin/cmd deviceidle enabled light 2>&1)
  deep=$(/system/bin/cmd deviceidle enabled deep 2>&1)
  if [ "$light" = '1' ] && [ "$deep" = '0' ]; then
    note "VERIFIED light=1 deep=0"
    return 0
  fi
  note "FAIL: unexpected states light=[$light] deep=[$deep]"
  return 1
}

apply_and_check || exit 1
# A bounded second confirmation catches late OEM settings changes.
/system/bin/sleep 20
light=$(/system/bin/cmd deviceidle enabled light 2>&1)
deep=$(/system/bin/cmd deviceidle enabled deep 2>&1)
if [ "$light" != '1' ] || [ "$deep" != '0' ]; then
  note "LATE STATE CHANGED light=[$light] deep=[$deep]; retry once"
  apply_and_check || exit 1
else
  note "POST-BOOT CONFIRMED light=1 deep=0"
fi
exit 0
