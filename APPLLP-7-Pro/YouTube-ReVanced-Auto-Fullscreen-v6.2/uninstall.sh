#!/system/bin/sh
DIR=/data/local/tmp/appllp7_yt_auto_v6
mkdir -p "$DIR" 2>/dev/null || :
: > "$DIR/stop"
# Remove only the viewport override we own; never overwrite a different size.
if [ -f "$DIR/owned" ]; then
  case "$(wm size 2>/dev/null)" in
    *'Physical size: 466x466'*'Override size: 466x426'*) wm size reset >/dev/null 2>&1 || : ;;
  esac
fi
rm -f "$DIR/owned"
