#!/system/bin/sh
MODDIR=${0%/*}
DIR=/data/local/tmp/appllp7_yt_auto_v6
mkdir -p "$DIR" 2>/dev/null || :
printf '%s\n' 'Stopping the automatic YouTube monitor and restoring its display override...'
: > "$DIR/stop"
sleep 4
case "$(wm size 2>/dev/null)" in
  *'Physical size: 466x466'*'Override size: 466x426'*)
      if [ -f "$DIR/owned" ]; then wm size reset; rm -f "$DIR/owned"; fi ;;
esac
printf '%s\n' 'Current display:'
wm size
printf '%s\n' 'The monitor restarts after next boot if the module remains enabled.'
