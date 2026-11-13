<#
Install a user-supplied DigitalPureBlack clockskin via ADB without writing system partitions.
You must supply the original DigitalPureBlack assets beside this script (or use -FaceFolder).
This installer does not supply any watchface graphics.
#>
[CmdletBinding()]
param(
  [string]$FaceFolder = (Join-Path $PSScriptRoot 'DigitalPureBlack'),
  [string]$Serial,
  [string]$Adb = 'adb'
)
$ErrorActionPreference = 'Stop'
if (!(Test-Path -LiteralPath (Join-Path $FaceFolder 'clock_skin.xml'))) {
  throw "clock_skin.xml not found under $FaceFolder"
}
& $Adb version | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'ADB is unavailable' }
$devices = @(
  & $Adb devices |
    Select-String '^([^\s]+)\s+device\s*$' |
    ForEach-Object { $_.Matches[0].Groups[1].Value }
)
if (!$Serial) {
  if ($devices.Count -ne 1) {
    throw "Expected exactly one authorized ADB device, found $($devices.Count). Supply -Serial YOUR_WATCH_SERIAL."
  }
  $Serial = $devices[0]
} elseif ($Serial -notin $devices) {
  throw "Specified device not connected/authorized: $Serial"
}
$device = (& $Adb -s $Serial shell getprop ro.product.device).Trim()
$build = (& $Adb -s $Serial shell getprop ro.build.display.id).Trim()
if ($device -ne 'WP_C30_VP69_OLED' -or $build -notlike 'LOKMAT_APPLLP_7_PRO_C30_EN_*') {
  throw "Unexpected device/firmware: $device / $build"
}
$leaf = Split-Path -Leaf (Resolve-Path -LiteralPath $FaceFolder)
if ($leaf -ne 'DigitalPureBlack') {
  throw 'Expected the face folder to be named DigitalPureBlack'
}
& $Adb -s $Serial shell mkdir -p /sdcard/clockskin
if ($LASTEXITCODE -ne 0) { throw 'Unable to create target directory' }
& $Adb -s $Serial push $FaceFolder /sdcard/clockskin/
if ($LASTEXITCODE -ne 0) { throw 'ADB push failed' }
& $Adb -s $Serial shell ls -l /sdcard/clockskin/DigitalPureBlack/clock_skin.xml
if ($LASTEXITCODE -ne 0) { throw 'Clockskin copy could not be verified' }
Write-Host 'Copy complete. Long-press the watch face, refresh the list, and select DigitalPureBlack.'
