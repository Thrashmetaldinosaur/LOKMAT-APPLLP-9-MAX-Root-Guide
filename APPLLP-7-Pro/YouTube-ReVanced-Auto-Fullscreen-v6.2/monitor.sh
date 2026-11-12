#!/system/bin/sh
# APPLLP7 YouTube Auto Full Player - Android 15, screen-size-only runtime helper.
# No boot/property/firmware writes. Runs in Magisk late_start (service.sh) or pilot.

MODE="${1:-daemon}"
MODDIR="${0%/*}"
STATE_DIR="${YT_STATE_DIR:-/data/local/tmp/appllp7_yt_auto_v6}"
LOG="$STATE_DIR/events.log"
STOP="$STATE_DIR/stop"
OWNED="$STATE_DIR/owned"
RUNNING="$STATE_DIR/running"
BOOTED="$STATE_DIR/booted"

mkdir -p "$STATE_DIR" || exit 1

log() {
    # No periodic logging, only transitions. Rotate at approximately 64 KiB.
    if [ -f "$LOG" ]; then
        sz=$(wc -c < "$LOG" 2>/dev/null)
        if [ "${sz:-0}" -gt 65000 ]; then
            mv -f "$LOG" "$LOG.old" 2>/dev/null || :
        fi
    fi
    printf '%s | %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$LOG"
}

size_now() { wm size 2>/dev/null; }
stock_size() {
    ss="$(size_now)"
    case "$ss" in
      *'Physical size: 466x466'*)
         case "$ss" in *'Override size:'*) return 1;; *) return 0;; esac ;;
    esac
    return 1
}
our_size() {
    ss="$(size_now)"
    case "$ss" in *'Physical size: 466x466'*'Override size: 466x426'*) return 0;; esac
    return 1
}

device_ok() {
    [ "$(getprop ro.product.device 2>/dev/null)" = 'WP_C30_VP69_OLED' ] || return 1
    [ "$(getprop ro.build.version.sdk 2>/dev/null)" = '35' ] || return 1
    density="$(wm density 2>/dev/null)"
    case "$density" in *'Physical density: 182'*) ;; *) return 1;; esac
    case "$density" in *'Override density:'*) return 1;; esac
    return 0
}

# Known package IDs used by stock YouTube and common ReVanced/RVX variants.
# Extra exact IDs may be added through targets.conf, populated by the PC installer.
TARGET_PACKAGES='com.google.android.youtube app.revanced.android.youtube app.rvx.android.youtube anddea.youtube bill.youtube'
if [ -f "$MODDIR/targets.conf" ]; then
    while IFS= read -r extra || [ -n "$extra" ]; do
        case "$extra" in
          ''|'#'*) continue ;;
          *[!a-zA-Z0-9._]*) continue ;;
          *) TARGET_PACKAGES="$TARGET_PACKAGES $extra" ;;
        esac
    done < "$MODDIR/targets.conf"
fi

foreground_package() {
    # Android 15: topResumedActivity=ActivityRecord{... u0 app.revanced.android.youtube/...}
    top="$(dumpsys activity activities 2>/dev/null | grep -m 1 'topResumedActivity=ActivityRecord')"
    [ -n "$top" ] || return 1
    for pkg in $TARGET_PACKAGES; do
        case "$top" in
          *" $pkg/"*) printf '%s\n' "$pkg"; return 0 ;;
        esac
    done
    return 1
}

playing_package() {
    # Inspect the media session for the *same package* as the foreground app.
    # ReVanced may change the visible session label, so do not depend on
    # "YouTube playerlib". An active PLAYING state from a different package
    # must never trigger a system-wide viewport override.
    watch_pkg="$1"
    [ -n "$watch_pkg" ] || return 1
    dumpsys media_session 2>/dev/null | awk -v wanted="$watch_pkg" '
      /Sessions Stack - have [0-9]+ sessions/ {stack=1; package=""; active=0; playing=0; next}
      stack && /^Audio playback/ {stack=0}
      stack && /^    [^ ]/ {
        if (package==wanted && active && playing) found=1
        package=""; active=0; playing=0
      }
      stack && /^[[:space:]]+package=/ {
        p=$0
        sub(/^[[:space:]]+package=/,"",p)
        sub(/[[:space:]\r].*$/,"",p)
        package=p
      }
      stack && /^[[:space:]]+active=true[[:space:]]*$/ {active=1}
      stack && /state=PlaybackState [{]state=PLAYING[(]3[)]/ {playing=1}
      END {
        if (package==wanted && active && playing) found=1
        if (found) print "PLAYING"
      }
    ' | grep -q '^PLAYING$'
}

restore_owned() {
    [ -f "$OWNED" ] || return 0
    if our_size; then
        if wm size reset >/dev/null 2>&1 && stock_size; then
            log 'RESTORE: reset 466x426 to original 466x466'
        else
            log 'ERROR: wm size reset failed'
            return 1
        fi
    else
        log 'RESTORE SKIP: display was changed externally; not overwriting it'
    fi
    rm -f "$OWNED"
    return 0
}

clean_exit() {
    restore_owned || :
    rm -f "$RUNNING" "$STOP"
}
trap 'clean_exit' 0
trap 'exit 0' 1 2 3 15

if ! device_ok; then
    log 'ABORT: device identity / Android SDK / density guard failed'
    exit 2
fi

# If the old monitor died while owning the override, restore before monitoring.
if [ -f "$OWNED" ]; then
    log 'START: previous run left owned marker; restoring before new watch loop'
    restore_owned || exit 3
fi

if ! stock_size; then
    log 'ABORT: preexisting display-size override or non-stock resolution; no changes made'
    exit 4
fi

rm -f "$STOP"
printf '%s\n' "$$" > "$RUNNING"
log "START mode=$MODE pid=$$"
if [ "$MODE" = 'pilot' ]; then
    deadline=$(( $(date +%s) + 240 ))
else
    deadline=0
fi

candidate=0
missed=0
in_player=0
last_pkg=""
while :; do
    if [ -f "$STOP" ]; then
        log 'STOP requested'
        break
    fi
    if [ "$MODE" = daemon ] && [ -f "$MODDIR/disable" ]; then
        log 'MODULE DISABLED: stopping monitor'
        break
    fi
    if [ "$deadline" -ne 0 ] && [ "$(date +%s)" -ge "$deadline" ]; then
        log 'PILOT TIMEOUT: stopping monitor and restoring any owned display override'
        break
    fi

    if [ "$in_player" -eq 1 ]; then
        if ! our_size; then
            log 'DISPLAY CHANGED externally while owned; monitor will not fight it'
            rm -f "$OWNED"
            in_player=0
            candidate=0
            sleep 6
            continue
        fi
        if foreground_package >/dev/null; then
            missed=0
        else
            missed=$((missed + 1))
            if [ "$missed" -ge 2 ]; then
                log 'YouTube left foreground; restoring stock viewport'
                if restore_owned; then
                    in_player=0
                    missed=0
                    candidate=0
                    if [ "$MODE" = 'pilot' ]; then
                        log 'PILOT PASS: applied and restored after leaving YouTube'
                        break
                    fi
                fi
            fi
        fi
        sleep 3
        continue
    fi

    if ! stock_size; then
        # Another app or user configured a display override; never overwrite.
        candidate=0
        sleep 8
        continue
    fi
    # Probe foreground first; expensive session dump only for eligible apps.
    fg="$(foreground_package)"
    if [ -n "$fg" ] && playing_package "$fg"; then
        if [ "$fg" = "$last_pkg" ]; then
            candidate=$((candidate + 1))
        else
            candidate=1
            last_pkg="$fg"
        fi
        if [ "$candidate" -ge 2 ]; then
            # Recheck both signals before resizing: ReVanced can play in background.
            verify_fg="$(foreground_package)"
            if [ "$verify_fg" = "$fg" ] && playing_package "$fg" && stock_size; then
                : > "$OWNED"
                if wm size 466x426 >/dev/null 2>&1 && our_size; then
                    log "APPLIED: pkg=$fg PLAYING foreground; wm size 466x426"
                    in_player=1
                    missed=0
                else
                    log 'ERROR: wm resize failed; attempting safe rollback'
                    restore_owned || :
                fi
            fi
            candidate=0
        fi
        sleep 2
    else
        candidate=0
        last_pkg=""
        sleep 5
    fi
done
log 'END'
