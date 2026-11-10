#!/usr/bin/env python3
"""Patch APPLLP 7 Pro stock init_boot_a using Magisk v31.1, without a file picker.

No root, bootloader unlock, firmware writes, or flashing. Requires Python 3
and an authorized ADB connection to the watch with Magisk v31.1 installed.
"""
import argparse
import hashlib
import json
import shutil
import struct
import subprocess
import tempfile
import time
import zipfile
from pathlib import Path

DEVICE = "WP_C30_VP69_OLED"
BUILD = "LOKMAT_APPLLP_7_PRO_C30_EN_V1.0_20260921"
STOCK_SHA256 = "b4bbf7fab5d7ddfa8d821d79718457b386786c836059b7784f4e10e1e7110d3c"
MAGISK_31_1_APK_SHA256 = "89cefac0a318afa39fb3880c45c87b036c05bc1ebf02a7a715b7f8d7c26ac6e7"
EXPECTED_BYTES = 8 * 1024 * 1024


def digest(path):
    h = hashlib.sha256()
    with open(path, "rb") as stream:
        for block in iter(lambda: stream.read(1048576), b""):
            h.update(block)
    return h.hexdigest()


def require(ok, message):
    if not ok:
        raise RuntimeError(message)


def boot_header(path):
    with open(path, "rb") as stream:
        raw = stream.read(48)
    require(len(raw) >= 44 and raw[:8] == b"ANDROID!", "Not an Android boot image")
    kernel = struct.unpack_from("<I", raw, 8)[0]
    ramdisk = struct.unpack_from("<I", raw, 12)[0]
    version = struct.unpack_from("<I", raw, 40)[0]
    require(version == 4 and kernel == 0 and ramdisk > 0,
            "Expected v4 init_boot with no kernel and non-empty ramdisk")
    return {"header_version": version, "kernel_bytes": kernel, "ramdisk_bytes": ramdisk}


def run(argv, check=True):
    result = subprocess.run([str(arg) for arg in argv], text=True,
                            errors="replace", stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT)
    if check and result.returncode != 0:
        raise RuntimeError("Command failed: " + " ".join(map(str, argv[:4]))
                           + "\n" + result.stdout[-1500:])
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--stock", required=True, type=Path,
                        help="Stock init_boot_a.bin read from YOUR matching watch/build")
    parser.add_argument("--adb", default="adb", help="Path to adb executable, or adb on PATH")
    parser.add_argument("--serial", help="ADB serial if more than one device is connected")
    parser.add_argument("--out", type=Path, default=Path("appllp7-root-output"))
    args = parser.parse_args()

    stock = args.stock.resolve()
    require(stock.is_file(), "Stock init_boot_a input not found")
    require(stock.stat().st_size == EXPECTED_BYTES, "Stock image is not 8 MiB")
    require(digest(stock) == STOCK_SHA256,
            "Stock image SHA256 differs from tested build. STOP; do not bypass this check.")
    boot_header(stock)

    devices = run([args.adb, "devices"]).stdout.splitlines()
    connected = [line.split()[0] for line in devices[1:] if "\tdevice" in line]
    require(len(connected) == 1 if not args.serial else args.serial in connected,
            "Connect exactly one authorized watch, or supply --serial")
    serial = args.serial or connected[0]
    adb = [args.adb, "-s", serial]
    def device(*argv, check=True):
        return run(adb + list(argv), check=check)
    def prop(name):
        return device("shell", "getprop", name).stdout.strip()

    require(prop("ro.product.device") == DEVICE, "Incorrect device; refusing patch")
    require(prop("ro.build.display.id") == BUILD, "Incorrect firmware build; refusing patch")
    require(prop("ro.boot.slot_suffix") == "_a",
            "Only tested slot A. Do not switch slots; do not use slot B.")
    require(prop("ro.product.cpu.abi") == "arm64-v8a", "Unexpected CPU ABI")

    apk_lines = device("shell", "pm", "path", "com.topjohnwu.magisk").stdout.splitlines()
    apks = [line.split(":", 1)[1].strip() for line in apk_lines
            if line.startswith("package:")]
    require(len(apks) == 1 and apks[0].endswith(".apk"),
            "Install official Magisk v31.1 app; expected one base APK")

    args.out.mkdir(parents=True, exist_ok=True)
    output = (args.out / "magisk_patched_init_boot_a.img").resolve()
    require(not output.exists(), f"Refusing to overwrite existing output: {output}")
    remote = f"/data/local/tmp/appllp7_magisk_patch_{int(time.time())}"
    with tempfile.TemporaryDirectory(prefix="appllp7-magisk-") as tmp:
        stage = Path(tmp)
        apk = stage / "Magisk-v31.1.apk"
        device("pull", apks[0], str(apk))
        require(digest(apk) == MAGISK_31_1_APK_SHA256,
                "Installed Magisk APK does not match official v31.1; no patch attempted")
        libs = ("magiskboot", "magiskinit", "magisk", "init-ld")
        with zipfile.ZipFile(apk) as package:
            for name in libs:
                entry = f"lib/arm64-v8a/lib{name}.so"
                require(entry in package.namelist(), f"Magisk APK missing {entry}")
                (stage / name).write_bytes(package.read(entry))
            for name in ("boot_patch.sh", "util_functions.sh"):
                entry = "assets/" + name
                require(entry in package.namelist(), f"Magisk APK missing {entry}")
                (stage / name).write_bytes(package.read(entry))
        image = stage / "init_boot.img"
        shutil.copyfile(stock, image)

        device("shell", "mkdir", "-p", remote)
        for name in (*libs, "boot_patch.sh", "util_functions.sh", "init_boot.img"):
            device("push", str(stage / name), remote + "/" + name)
        on_watch_hash = device("shell", "sha256sum", remote + "/init_boot.img").stdout.split()[0]
        require(on_watch_hash.lower() == STOCK_SHA256,
                "ADB push hash mismatch; patch canceled")
        device("shell", "chmod", "700", *[remote + "/" + x for x in
               (*libs, "boot_patch.sh", "util_functions.sh")])

        patch = device("shell", f"cd {remote} && BOOTMODE=true KEEPVERITY=true "
                       "KEEPFORCEENCRYPT=true PATCHVBMETAFLAG=false RECOVERYMODE=false "
                       "LEGACYSAR=false sh ./boot_patch.sh init_boot.img", check=False)
        print(patch.stdout)
        require(patch.returncode == 0 and "Repacking boot image" in patch.stdout,
                "Magisk patch failed. No firmware has been flashed.")
        remote_output = remote + "/new-boot.img"
        device("pull", remote_output, str(output))
        require(output.stat().st_size == EXPECTED_BYTES, "Patched image size unexpected")
        header = boot_header(output)
        require(digest(output) != STOCK_SHA256, "Patched output unchanged from stock")
        remote_hash = device("shell", "sha256sum", remote_output).stdout.split()[0]
        require(remote_hash.lower() == digest(output), "Patched image transfer hash mismatch")

        verification = device("shell", f"cd {remote} && mkdir inspect && cd inspect && "
                              "../magiskboot unpack ../new-boot.img >/dev/null 2>&1 && "
                              "../magiskboot cpio ramdisk.cpio test", check=False)
        require(verification.returncode == 1,
                "Magisk ramdisk test did not report patched state (status 1)")
        report = {"device": DEVICE, "build": BUILD, "slot": "_a",
                  "stock_sha256": STOCK_SHA256,
                  "patched_sha256": digest(output), "size_bytes": output.stat().st_size,
                  "patch": "Magisk v31.1", "ramdisk_status": "patched",
                  **header, "flashed": False}
        (args.out / "PATCH-REPORT.json").write_text(
            json.dumps(report, indent=2) + "\n", encoding="utf-8")
        print("\nPASS: rootless Magisk patch created:", output)
        print("SHA256:", digest(output))
        print("NO partition was flashed or bootloader unlocked.")
    # The remote scratch folder holds a separate working copy; remove only that
    # uniquely named folder after the patched file has been successfully retrieved.
    device("shell", "rm", "-rf", remote)


if __name__ == "__main__":
    main()
