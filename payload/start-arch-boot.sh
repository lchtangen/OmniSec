#!/system/bin/sh
# NH_SETUP_VERSION: 2.0 nextgen
# Profile: Arch ARM64 v2.0 nextgen; Kali ARM64 v2.0 nextgen
# Magisk service.d v2 — auto-start dual chroots + services + watchdog

NH_SETUP_VERSION="${NH_SETUP_VERSION:-2.0}"
NH_SETUP_PROFILE="${NH_SETUP_PROFILE:-nextgen}"
NHBIN=/data/local/nhsystem/bin
NHROOTS=/data/local/nhsystem/roots
LOG=/data/local/nhsystem/boot-arch.log
WATCHDOG_PID=/data/local/nhsystem/.boot-watchdog
NH_ADB_PORT="${NH_ADB_PORT:-52104}"

exec >>"$LOG" 2>&1
echo "--- $(date) NetHunter setup v$NH_SETUP_VERSION ($NH_SETUP_PROFILE) boot start ---"

# Wait for Android to finish booting
until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 2
done
sleep 5

# SELinux permissive
setenforce 0 && echo "SELinux: permissive" || echo "SELinux: failed"

# Ensure ADB listens on configurable port
setprop service.adb.tcp.port "$NH_ADB_PORT"
stop adbd; start adbd
echo "adbd: restarted on port $NH_ADB_PORT"

# Copy no-close-range.so between chroots
ARCH_SO="$NHROOTS/archlinux/usr/local/lib/nh-no-close-range.so"
KALI_SO="/data/local/nhsystem/kali-arm64/usr/local/lib/nh-no-close-range.so"
if [ -f "$ARCH_SO" ] && [ ! -f "$KALI_SO" ]; then
    mkdir -p "$(dirname "$KALI_SO")"
    cp "$ARCH_SO" "$KALI_SO" && echo "so: copied to kali" || echo "so: copy failed"
fi

# Mount chroot filesystems
"$NHBIN/nh-mount" && echo "mount: ok" || { echo "mount: failed"; exit 1; }

# Deploy sudo wrapper to chroots
for chroot_dir in "$NHROOTS/archlinux" "$NHROOTS/kali-arm64" "/data/local/nhsystem/kali-arm64"; do
    SUDO_BIN="$chroot_dir/usr/bin/sudo"
    SUDO_ORIG="$chroot_dir/usr/bin/sudo.orig"
    if [ -f "$SUDO_BIN" ] && [ ! -f "$SUDO_ORIG" ] && [ ! -L "$SUDO_BIN" ]; then
        if file "$SUDO_BIN" | grep -q ELF; then
            cp "$SUDO_BIN" "$SUDO_ORIG" && echo "sudo: backed up in $(basename $chroot_dir)"
        fi
    fi
done

# Start services (sshd, tor, wireguard)
"$NHBIN/nh-services" start && echo "services: started" || echo "services: failed"

# Start KEX if autostart enabled
"$NHBIN/nh-kex" boot 2>/dev/null && echo "kex: autostart checked" || true

# Run scheduled tasks
"$NHBIN/nh-schedule" run 2>/dev/null && echo "schedule: tasks checked" || true

echo "--- boot done ---"
