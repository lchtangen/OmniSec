# Troubleshooting Guide

## ADB

### Wireless ADB won't connect

```bash
# Check if device is reachable
ping -c 2 10.0.0.113

# Force reconnect
adb disconnect 10.0.0.113:52104
adb connect 10.0.0.113:52104

# Check if pairing is needed (Android 15+)
adb pair 10.0.0.113:52104
# Enter pairing code shown on device
```

### "no devices/emulators found"

- Verify Wi-Fi debugging is enabled in Developer Options
- Verify the device is on the same network
- Try USB connection: `adb devices`

### ADB connects but shell shows "$" instead of "#"

- Magisk root not granted
- Run: `adb shell /debug_ramdisk/su -c id`
- If that works, the `ROOT_SU` variable in `nh-defaults.sh` may need updating

### Binder unavailable errors from ADB shell

This is normal. Android's Binder IPC is not available from ADB shell context. Commands that trigger Magisk su dialog (like `which`) will hang.

**Fixes deployed in this project:**
- `bootkali_env`: uses direct path `/system/bin/busybox_nh` instead of `which`
- `bootkali_init`: wraps chroot test in `timeout 5`
- sudo wrapper: replaces `/usr/bin/sudo` with `/bin/su -l root` to avoid PAM/FQDN hangs

### ADB disconnect during long operations

```bash
# Set ADB TCP timeout longer
adb shell settings put global adb_wifi_timeout_ms 3600000
```

---

## Chroot

### Chroot won't mount

```bash
# Check if rootfs exists
adb shell ls -la /data/local/nhsystem/roots/

# Mount manually
adb shell /data/local/nhsystem/bin/nh-mount all

# Check mounts
adb shell grep nhsystem /proc/mounts
```

### sudo hangs inside chroot

This is caused by FQDN hostname resolution or PAM initialization hanging inside the Android chroot.

**Fix:**
```bash
# Deploy sudo wrapper
./nhctl deploy-sudo-wrapper

# Or run inside chroot:
# /usr/bin/sudo has been replaced with a wrapper that calls /bin/su -l root
# Original saved as /usr/bin/sudo.orig
```

### "pacman-key: command not found" in Arch

Arch ARM64 rootfs may not have GPG initialized:

```bash
# Inside Arch chroot:
pacman-key --init
pacman-key --populate archlinuxarm
```

### pacman "failed to commit transaction (could not lock database)"

```bash
# Inside Arch chroot:
rm -f /var/lib/pacman/db.lck
```

### sshd fails to start in chroot

```bash
# From host:
./nhctl repair-arch-ssh

# Check the repair log:
./nhctl logs tail repair-arch-ssh
```

### chroot processes accumulate

```bash
# Kill all chroot processes
adb shell "
for pid in \$(pgrep -f 'chroot /data/local/nhsystem'); do
    kill \$pid 2>/dev/null || true
done
"
```

---

## Kali Rootfs Installation

### Kali rootfs not installed

```bash
# Auto-download and install latest Kali ARM64 rootfs
./nhctl install-kali

# Or use a local tarball
./nhctl install-kali /path/to/kali-linux-2024.4-arm64.tar.zst

# Force reinstall if already present
./nhctl install-kali --force
```

### Low disk space during install

Kali rootfs needs ~3-4 GB. Check space:
```bash
adb shell df -h /data
```

### Extraction fails

```bash
# Check the tarball format (should be .tar.zst)
file kali-linux-*.tar.zst

# Try extracting manually on the device:
adb shell "
  cd /data/local/nhsystem/roots/kali-arm64
  unzstd -c /data/local/tmp/kali-arm64-rootfs.tar.zst | tar -x
"
```

### kali-post.sh fails

Run it manually after install:
```bash
./nhctl exec kali /root/kali-post.sh
```

---

## NetHunter App

### NetHunter app not installed

```bash
# Auto-download and install latest NetHunter APK
./nhctl install-nethunter

# Install from a local APK file
./nhctl install-nethunter --apk /path/to/nethunter.apk

# Install from a specific GitHub release
./nhctl install-nethunter --version 2024.4
```

### NetHunter app crashes within 5 seconds

Root cause is usually the sudo hang or bootkali_env hang.

**Fix:**
```bash
./nhctl fix-all
```

This runs: deploy-tools, deploy-sudo-wrapper, deploy-bootkali, repair-arch-ssh, repair-nhterm.

### "No chroot installed" in NetHunter app

```bash
# Verify app data
adb shell cat /data/data/com.offsec.nethunter/shared_prefs/CHROOT_INSTALLED_TAG.xml

# Should contain:
# <boolean name="CHROOT_INSTALLED_TAG" value="true" />
# <string name="chroot_path">/data/local/nhsystem/kali-arm64</string>

# Re-deploy app fixes:
./nhctl repair-nhterm
```

### NetHunter terminal shows blank screen

```bash
# Redeploy bootkali scripts
./nhctl deploy-bootkali

# Kill any hung app_process zombies
adb shell "
for pid in \$(pgrep -f app_process); do
    kill \$pid 2>/dev/null || true
done
"
```

---

## SSH

### SSH connection times out during banner exchange

This usually affects Arch SSH when NSS calls systemd/resolve modules that hang:

```bash
./nhctl repair-arch-ssh
```

### Port 8022 (Termux SSH) won't connect

```bash
# Check if sshd is running
adb shell ss -tlnp | grep 8022

# Restart
adb shell /data/data/com.termux/files/usr/bin/pkill sshd || true
adb shell su u0_a171 -c /data/data/com.termux/files/usr/bin/sshd

# Try via ADB forward:
./nhctl forward
ssh -p 8022 u0_a171@127.0.0.1
```

### "Host key verification failed"

```bash
ssh-keygen -R 10.0.0.113
ssh-keygen -R '[10.0.0.113]:2222'
```

---

## Performance

### Device gets hot under load

```bash
# Check temperatures
adb shell /data/local/nhsystem/bin/nh-temp

# Check CPU governor
adb shell cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

# Switch to powersave if needed
adb shell echo powersave > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
```

### Low disk space on /data

```bash
# Check usage
adb shell df -h /data

# Clean chroot caches
adb shell /data/local/nhsystem/bin/nh-clean

# Check large files
adb shell du -sh /data/local/nhsystem/* | sort -rh
```

---

## Magisk Module

### Module installs but chroot doesn't start

```bash
# Check boot log
adb shell cat /data/local/nhsystem/boot-arch.log

# Check Magisk service log
adb shell cat /data/adb/magisk/service.log

# Re-deploy boot service
./nhctl deploy-tools
```

### SELinux blocks chroot operations

```bash
# Set permissive (required for chroot)
adb shell setenforce 0

# Verify
adb shell getenforce
```

---

## Backup/Restore

### Backup fails

```bash
# Check backup directory
adb shell ls -la /data/local/nhsystem/backups/

# Check disk space
adb shell df -h /data

# Manual backup
adb shell mkdir -p /data/local/nhsystem/backups
adb shell cp -a /data/local/nhsystem/workspaces/main /data/local/nhsystem/backups/workspace-manual-$(date +%Y%m%d-%H%M%S)
```

### Restore from backup

```bash
# List available backups
./nhctl backup  # uses nh-backup internally

# Manual restore
adb shell "
BACKUP=\$(ls -d /data/local/nhsystem/backups/workspace-* | sort | tail -1)
echo \"latest: \$BACKUP\"
cp -a \$BACKUP/* /data/local/nhsystem/workspaces/main/
"
```
