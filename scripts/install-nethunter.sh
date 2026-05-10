#!/bin/bash
set -e

DEVICE="10.0.0.118:42165"

echo "=== NetHunter Installation Script ==="
echo "Device: $DEVICE"
echo ""

# Check device connection
echo "[1/7] Checking device connection..."
adb devices | grep "$DEVICE"

# Verify root
echo "[2/7] Verifying Magisk root..."
adb -s $DEVICE shell "su -c 'id'"
adb -s $DEVICE shell "su -c 'magisk -v'"

# Install NetHunter Store
echo "[3/7] Installing NetHunter Store..."
adb -s $DEVICE install -r ~/OmniSec/nethunter-store.apk

# Install NetHunter App
echo "[4/7] Installing NetHunter App 2026.1..."
adb -s $DEVICE install -r ~/OmniSec/nethunter-app-2026.1.apk

# Download Kali rootfs (using direct mirror)
echo "[5/7] Downloading Kali NetHunter rootfs (minimal ~330MB)..."
if [ ! -f ~/OmniSec/kalifs-arm64-minimal.tar.xz ]; then
    curl -L -o ~/OmniSec/kalifs-arm64-minimal.tar.xz \
        "https://kali.download/nethunter-images/current/rootfs/kalifs-arm64-minimal.tar.xz"
fi

# Push rootfs to device
echo "[6/7] Pushing Kali rootfs to device..."
adb -s $DEVICE push ~/OmniSec/kalifs-arm64-minimal.tar.xz /sdcard/Download/

echo "[7/7] Installation complete!"
echo ""
echo "Next steps:"
echo "1. Open NetHunter app on device"
echo "2. Tap 'Kali Chroot Manager'"
echo "3. Tap 'Install Kali Chroot'"
echo "4. Select the kalifs file from Downloads"
echo ""
