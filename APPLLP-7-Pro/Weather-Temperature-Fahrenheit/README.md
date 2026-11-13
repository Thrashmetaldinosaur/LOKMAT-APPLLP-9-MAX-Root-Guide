# APPLLP 7 Pro — Celsius → Fahrenheit weather value workaround

**Status: user confirmed Celsius-to-Fahrenheit display remains working after a normal full reboot on 13 November 2026.** The `service.d` workaround therefore survives at least one reboot on the tested watch. This observation does **not** yet establish correctness after repeated service restarts, multiple reboots, or all weather updates.

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

- The user confirmed the displayed Fahrenheit temperature works after reboot. **However**, on a reboot/process restart `L=x` loses its memory; if a saved value is *already* Fahrenheit when the loop first reads it, it **could** convert it again. This edge case has not been observed or ruled out.
- The script has no lock; a manually started copy and Magisk service.d copy may run simultaneously.
- The 60-second polling loop introduces recurring work even when weather data doesn't change, although its actual battery impact has not been measured.
- An OEM weather update could overwrite `WeatherTemp` at any time. Negative temperatures and noninteger values are not explicitly handled.
- No robust detection of the data source's units has been established.

**Before editing/replacing this file**, back up the existing script and note the current `settings get system WeatherTemp` value. Avoid deleting the user's working configuration unilaterally. Future work should identify the weather data producer and convert **before** storage/display, or persist a reliable last-written value and enforce a single process. Full-reboot persistence has now been user-confirmed; test repeated reboots, script restarts and new weather updates before declaring the conversion logic fully robust.

See [project tracker](../PROJECT-TRACKER.md).

## New open issue — system-wide Fahrenheit, not just watch-face display (13 November 2026)

The owner confirms that the watch face usually displays Fahrenheit after the `wxf.sh` workaround, **but the built-in OEM weather app still presents/treats the data as Celsius**. At times an OEM weather refresh causes the face to show Celsius again. Consequently the current workaround is **verified to survive reboot but is not a complete units fix**.

**Goal:** set Fahrenheit consistently across the native weather app, active face and weather widgets, preferably using a hidden native OEM setting or weather application's existing temperature-unit preference if one exists.

**Investigation (read-only first):** identify the OEM weather app package and weather update producer, enumerate relevant `settings list system`, `settings list secure`, and `settings list global` keys (filtered for temperature/unit/weather), inspect the weather app resources and private preferences where authorized, trace which service writes `WeatherTemp`, and identify whether the app has a Celsius/Fahrenheit toggle that's hidden on the watch form factor. Check whether the watch face consumes a temperature value or applies its own units. If a genuine preference is found, save the original value, change it reversibly, and verify on a fresh weather update and after reboot. **Do not guess a setting name or blindly write arbitrary values**. If no native setting exists, design an event-driven conversion at the source rather than repeatedly converting an already converted `WeatherTemp` value.
