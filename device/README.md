# Device Management: OnePlus 7 Pro (GM1911)

## Specs

| Property | Value |
|----------|-------|
| Model | GM1911 (guacamole) |
| Android | 16 (API 36) |
| ROM | LineageOS 23.2 |
| Kernel | 4.14.356-openela |
| Arch | arm64-v8a |
| ABI | arm64 |
| Root | Magisk (via `/debug_ramdisk/su`) |

## Available Partitions

| Partition | Size | Description |
|-----------|------|-------------|
| `boot` | 64MB | Kernel + ramdisk |
| `recovery` | 64MB | Recovery image |
| `dtbo` | 16MB | Device tree blob |
| `vbmeta` | 8KB | Verified boot metadata |
| `vendor_boot` | 64MB | Vendor boot image |

## Backup (run before any flash)

```bash
./device/backup-partitions.sh backup
```

## Flash Kernel

```bash
# Build kernel first
cd kernel && ./build-kernel.sh all
cd ..

# Then flash
./device/flash-kernel.sh flash-all
```

## Boot Script

```bash
./device/deploy-boot-script.sh all
```

## ADB

```bash
adb connect 10.0.0.113:52104
adb shell su -c id
```

## Useful Commands

```bash
adb reboot bootloader   # Reboot to fastboot
fastboot devices        # Check fastboot connection
fastboot flash boot boot.img
fastboot reboot
```
