# Magisk Module

## Overview

The Magisk module packages nhsystem-bin scripts and boot services into a
flashable `.zip` for Magisk v27+ (API 28+).

## Contents

```
OmniSec-v2.0.0.zip
├── module.prop         # Module metadata
├── customize.sh        # Installation script
├── uninstall.sh        # Clean uninstall
├── service.sh          # Boot service (post-fs-data)
├── nhsystem-bin/       # Management scripts
│   ├── nh-lib
│   ├── nh-enter-arch
│   ├── nh-enter-kali
│   └── ...
└── system/
    └── lib64/
        └── no-close-range.so  # LD_PRELOAD syscall stub
```

## Build

```bash
# Prerequisites: C binaries must be built first
make build-c
make build-module

# Output: deploy/magisk/dist/OmniSec-v2.0.0.zip
```

Or manually:
```bash
bash deploy/magisk/build.sh
```

## Install

1. Build the module
2. Push to device: `adb push deploy/magisk/dist/*.zip /sdcard/`
3. Open Magisk app → Modules → Install from storage
4. Reboot

The `service.sh` script automatically runs on boot after a 15-second
delay (to ensure system is ready). It:
- Mounts chroot filesystems
- Starts SSH services
- Restores ADB TCP port

## Uninstall

1. Magisk app → Modules → Remove
2. Or flash uninstaller: `adb shell sh /data/adb/modules/OmniSec/uninstall.sh`

The uninstaller preserves:
- `/data/local/nhsystem/` (chroot filesystems)
- `/data/local/nhsystem-backups/` (backups)

## Boot Script (service.sh)

```bash
#!/system/bin/sh

MODDIR="${0%/*}"
until [ "$(getprop sys.boot_completed)" = "1" ]; do
  sleep 5
done
sleep 15

if [ -f "$NHSYSTEM/bin/start-arch-boot.sh" ]; then
  exec "$NHSYSTEM/bin/start-arch-boot.sh"
fi
```

This can also be installed standalone without the module:

```bash
./device/deploy-boot-script.sh deploy
```

## update.json

For Magisk's built-in update check:

```json
{
  "version": "2.0.0",
  "versionCode": 200,
  "zipUrl": "https://github.com/lchtangen/OmniSec/releases/latest/download/OmniSec-v2.0.0.zip",
  "changelog": "https://github.com/lchtangen/OmniSec/releases/latest"
}
```

Update the URL to match your GitHub repository after pushing.
