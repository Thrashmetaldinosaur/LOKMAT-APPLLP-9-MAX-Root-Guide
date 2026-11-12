#!/system/bin/sh
# Magisk late_start; non-blocking. Runs only if this module is enabled.
MODDIR=${0%/*}
(
  until [ "$(getprop sys.boot_completed 2>/dev/null)" = '1' ]; do sleep 4; done
  sh "$MODDIR/monitor.sh" daemon
) >/dev/null 2>&1 &
