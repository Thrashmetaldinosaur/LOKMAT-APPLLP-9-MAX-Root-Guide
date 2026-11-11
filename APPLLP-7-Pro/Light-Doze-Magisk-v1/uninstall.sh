#!/system/bin/sh
# Restore the factory Doze-disabled baseline when this Magisk module is uninstalled.
/system/bin/cmd deviceidle disable light >/dev/null 2>&1 || true
/system/bin/cmd deviceidle disable deep >/dev/null 2>&1 || true
exit 0
