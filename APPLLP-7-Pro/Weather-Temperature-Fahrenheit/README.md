# APPLLP 7 Pro — Celsius → Fahrenheit weather value workaround

**Status: user reports Celsius-to-Fahrenheit display working during the session, 13 November 2026. Not verified across a full reboot.** This page documents the existing workaround and its limitations; **do not present this as a safe persistent module**.

## What was run on the watch

A shell script `/data/adb/service.d/wxf.sh` was created, made executable and launched with `nohup`. Its central logic is:

```sh
#!/system/bin/sh
L=x
while true; do
  V=$(settings get system WeatherTemp)
  if [ "$V" != "$L" ] && [ "$V" != null ]; then
    L=$(( ((V<<3)+V+2)/5+32 ))
    settings put system WeatherTemp "$L"
  fi
  sleep 60
done
```

`WeatherTemp` is an OEM system setting, not a standard Android temperature conversion API. The integer expression approximates `°F = 9×°C/5 + 32`.

## Important limitations

- On a reboot/process restart `L=x` loses its memory. If the saved value is already Fahrenheit, it can be converted **again**, producing the wrong temperature.
- The script has no lock; a manually started copy and Magisk service.d copy may run simultaneously.
- The 60-second polling loop introduces recurring work even when weather data doesn't change, although its actual battery impact has not been measured.
- An OEM weather update could overwrite `WeatherTemp` at any time. Negative temperatures and noninteger values are not explicitly handled.
- No robust detection of the data source's units has been established.

**Before editing/replacing this file**, back up the existing script and note the current `settings get system WeatherTemp` value. Avoid deleting the user's working configuration unilaterally. Future work should identify the weather data producer and convert **before** storage/display, or persist a reliable last-written value and enforce a single process. Test reboot and new weather updates before calling the change verified persistent.

See [project tracker](../PROJECT-TRACKER.md).
