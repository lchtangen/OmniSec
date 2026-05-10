# NetHunter + Arch Setup Guide - OnePlus 7 Pro

## ✅ Completed
- Magisk v28.1 installed (root working)
- LineageOS 23.2 (Android 16)
- NetHunter Store installed
- NetHunter App 2026.1 installed
- ADB connected: `10.0.0.118:39119`

## 📦 Downloaded Files Ready
Location: `~/OmniSec/`
- `kalifs-arm64-minimal.tar.xz` (132 MB) - Kali rootfs
- `ArchLinuxARM-aarch64-latest.tar.gz` (941 MB) - Arch rootfs

---

## Step 1: Install Kali NetHunter Chroot (ON DEVICE)

### Option A: Let NetHunter App Download (EASIEST)
1. Open **NetHunter** app on phone
2. Tap **☰ Menu** → **Kali Chroot Manager**
3. Tap **DOWNLOAD KALIFS**
4. Select **Minimal** (smallest, fastest)
5. Wait for download (~132 MB)
6. Tap **INSTALL KALI CHROOT**
7. Wait 5-10 minutes for extraction

### Option B: Use Pre-Downloaded File
```bash
# Push the file (this will take time)
adb -s 10.0.0.118:39119 push ~/OmniSec/kalifs-arm64-minimal.tar.xz /sdcard/Download/

# Then on device:
# 1. Open NetHunter app
# 2. Menu → Kali Chroot Manager
# 3. Tap "..." → Install from file
# 4. Select kalifs-arm64-minimal.tar.xz from Downloads
```

---

## Step 2: Install Arch Linux Chroot (MANUAL)

### On device via NetHunter Terminal:
```bash
su
cd /data/local

# Create Arch chroot directory
mkdir -p arch-chroot
cd arch-chroot

# Download Arch rootfs (ON DEVICE - faster)
wget http://os.archlinuxarm.org/os/ArchLinuxARM-aarch64-latest.tar.gz

# Or if already pushed from PC:
# cp /sdcard/Download/ArchLinuxARM-aarch64-latest.tar.gz ./

# Extract (takes 5-10 minutes)
tar -xzf ArchLinuxARM-aarch64-latest.tar.gz
rm ArchLinuxARM-aarch64-latest.tar.gz

# Create mount script
cat > /data/local/start-arch.sh << 'EOF'
#!/system/bin/sh
busybox mount -o bind /dev /data/local/arch-chroot/dev
busybox mount -o bind /sys /data/local/arch-chroot/sys
busybox mount -o bind /proc /data/local/arch-chroot/proc
busybox mount -t devpts devpts /data/local/arch-chroot/dev/pts
busybox chroot /data/local/arch-chroot /bin/su - root
EOF

chmod +x /data/local/start-arch.sh
```

### Enter Arch chroot:
```bash
su
/data/local/start-arch.sh
# Now you're in Arch Linux!
```

---

## Step 3: Install NetHunter Kernel (OPTIONAL for WiFi injection)

### On device:
1. Open **NetHunter** app
2. Tap **☰ Menu** → **NetHunter Kernel**
3. Tap **DOWNLOAD KERNEL**
4. Select your device if available
5. Or flash manually via TWRP

### Manual kernel installation:
```bash
# Download kernel for OnePlus 7 Pro
# Search: https://nethunter.kali.org/kernels.html
# Look for: oneplus7-oos (if on OxygenOS) or lineageos variant

# Flash via Magisk:
# 1. Download kernel zip to /sdcard/Download/
# 2. Open Magisk app
# 3. Modules → Install from storage
# 4. Select kernel zip
# 5. Reboot
```

---

## Step 4: Test Everything

### Test Kali:
```bash
# On device in NetHunter Terminal
nh       # Enter Kali chroot
whoami   # Should show: root
uname -a # Should show: Kali Linux
exit
```

### Test Arch:
```bash
su
/data/local/start-arch.sh
whoami      # Should show: root
pacman -Sy  # Update package database
exit
```

### Test Magisk Root:
```bash
adb -s 10.0.0.118:39119 shell "su -c 'id'"
# Should show: uid=0(root) gid=0(root)
```

---

## Quick Commands Summary

**Start Kali:**
```bash
nh
```

**Start Arch:**
```bash
su
/data/local/start-arch.sh
```

**Check what's running:**
```bash
adb shell "su -c 'mount | grep chroot'"
```

---

## Next: Build OmniSec APK

Once chroots are setup, install buildozer and build:
```bash
cd ~/OmniSec/platform-legacy/mobile/kivy_app
python3 -m pip install --user buildozer cython
buildozer android debug
adb -s 10.0.0.118:39119 install -r bin/*.apk
```

---

## Troubleshooting

**If NetHunter app can't find su:**
```bash
adb shell "su -c 'which su'"
# Grant root in Magisk app when prompted
```

**If chroot mount fails:**
```bash
su
busybox mount  # Check if busybox available
# NetHunter provides busybox, or install from Magisk modules
```

**Speed up file transfers:**
- Use device's browser to download directly
- USB cable is faster than wireless ADB
- Or use `adb push` with patience (5-10 min for Arch)
