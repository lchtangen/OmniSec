# Device Maintenance

## OnePlus 7 Pro (GM1911) - LineageOS 23.2 / Android 16

## ADB Connection

```bash
adb connect 10.0.0.113:52104
adb devices -l
adb shell su -c id  # Verify root
```

## Periodic Maintenance

### Weekly

```bash
./nhctl status              # Health check
make validate               # Full validation
```

### Monthly

```bash
./device/backup-partitions.sh backup
./nhctl update              # Update Arch packages
```

### After ROM Update

```bash
./nhctl deploy-tools        # Re-deploy scripts
./device/deploy-boot-script.sh deploy  # Re-install boot service
```

## Backup and Restore

### Partition Backup

```bash
./device/backup-partitions.sh
# Saves to: backups/partitions/GM1911-{boot,recovery,dtbo,vbmeta}-YYYYMMDD-HHMMSS.img
```

### Full Device Backup

```bash
./nhctl backup
# Uses nh-backup on device for daily snapshots
```

### Restore

```bash
# Boot image
fastboot flash boot backups/partitions/GM1911-boot-*.img

# Full nhsystem restore
adb shell su -c nh-backup restore YYYYMMDD
```

## Clean Rebuild

```bash
./clean-rebuild-postboot.sh  # Full rebuild from scratch
```

## Common Issues

### "Binder driver could not be opened"

The `am` and `monkey` commands fail because binderfs is not visible
in the shell's mount namespace. The app must be launched from the
device UI, not from ADB shell.

```bash
# Workaround: use Magisk's su to launch
adb shell su -c "am start -n com.offsec.nethunter/.SplashActivity"
# (still may fail - use UI instead)
```

### App crashes on launch

```bash
# Check logs
adb shell su -c "logcat -d | grep -i nethunter"

# Repair NetHunter terminal
./nhctl repair-nhterm
```

### ADB disconnected

```bash
adb connect 10.0.0.113:52104
adb kill-server && adb start-server && adb connect 10.0.0.113:52104
```

### Magisk modules not loading

```bash
adb shell su -c "ls /data/adb/service.d/"
adb shell su -c "ls /data/adb/modules/"
```

## SELinux Notes

SELinux is set to permissive mode for chroot compatibility.
Key denials to watch for:

```bash
adb shell su -c "dmesg | grep avc | grep nethunter"
adb shell su -c "logcat -d | grep avc"
```

## Filesystem Layout

```
/data/local/nhsystem/
  bin/              # nhsystem management scripts
    nh-lib          #   Shared library
    nh-enter-arch   #   Enter Arch user
    nh-enter-kali   #   Enter Kali user
    nh-mount        #   Mount chroots
    nh-umount       #   Umount chroots
    nh-services     #   Start/stop services
    nh-health       #   Health check
    ...
  roots/
    archlinux/      # Arch ARM64 rootfs
    kali-arm64/     # Kali ARM64 rootfs
  workspaces/
    main/           # Shared workspace bind-mounted into both chroots
  backups/          # Daily snapshots
  logs/             # Boot and setup logs
  etc/              # Config files
  tmp/              # Temp files
```
