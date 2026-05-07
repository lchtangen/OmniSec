#!/system/bin/sh
# NH_SETUP_VERSION: 2.0 default
# Profile: Arch ARM64 v2.0 default; Kali ARM64 v2.0 default
set -u

NHSYSTEM=/data/local/nhsystem
PAYLOAD=/data/local/tmp/nh-clean-payload
ARCH_TARBALL=/data/local/tmp/archlinuxarm.tar.gz
NH_SETUP_VERSION="${NH_SETUP_VERSION:-2.0}"
NH_SETUP_PROFILE="${NH_SETUP_PROFILE:-default}"
TS="$(date +%Y%m%d-%H%M%S)"

log() {
    echo "[$(date +%H:%M:%S)] $*"
}

run_chroot() {
    root="$1"
    shift
    /system/bin/chroot "$root" /usr/bin/env -i \
        HOME=/root USER=root LOGNAME=root TERM=xterm-256color \
        LANG=C.UTF-8 LC_ALL=C.UTF-8 \
        PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
        "$@"
}

log "clean rebuild started for NetHunter setup v$NH_SETUP_VERSION ($NH_SETUP_PROFILE)"

if [ -f "$NHSYSTEM/bin/nh-umount" ]; then
    log "unmounting any active chroot mounts"
    "$NHSYSTEM/bin/nh-umount" all 2>/dev/null || true
    for mp in mnt/payload workspace tmp run dev/shm dev/pts dev sys proc; do
        umount -l "$NHSYSTEM/roots/archlinux/$mp" 2>/dev/null || true
        umount -l "$NHSYSTEM/roots/kali-arm64/$mp" 2>/dev/null || true
    done
fi

if [ -d "$NHSYSTEM" ]; then
    log "moving previous nhsystem to backup"
    mkdir -p /data/local/nhsystem-backups
    mv "$NHSYSTEM" "/data/local/nhsystem-backups/nhsystem-$TS" 2>/dev/null || {
        log "backup move failed; stopping to avoid partial deletion"
        exit 1
    }
fi

mkdir -p "$NHSYSTEM/roots" "$NHSYSTEM/bin" "$NHSYSTEM/etc" \
    "$NHSYSTEM/workspaces/main" "$NHSYSTEM/logs" "$NHSYSTEM/tmp" "$NHSYSTEM/backups"
cp -a "$PAYLOAD/nhsystem-bin/." "$NHSYSTEM/bin/"
chmod 755 "$NHSYSTEM"/bin/nh-* "$NHSYSTEM/bin/nh-lib" 2>/dev/null || true
chmod 755 "$NHSYSTEM/bin/nh-vpn" "$NHSYSTEM/bin/nh-backup" "$NHSYSTEM/bin/nh-health" 2>/dev/null || true
if [ -f "$PAYLOAD/start-arch-boot.sh" ]; then
    mkdir -p /data/adb/service.d
    cp "$PAYLOAD/start-arch-boot.sh" /data/adb/service.d/99-nethunter-boot.sh
    chmod 755 /data/adb/service.d/99-nethunter-boot.sh
    log "installed Magisk boot helper with fixed ADB port"
fi

log "deploying Arch ARM64 v$NH_SETUP_VERSION ($NH_SETUP_PROFILE)"
if [ ! -f "$ARCH_TARBALL" ]; then
    log "missing $ARCH_TARBALL"
    exit 1
fi
mkdir -p "$NHSYSTEM/roots/archlinux"
tar -xzf "$ARCH_TARBALL" -C "$NHSYSTEM/roots/archlinux" || { log "tar extraction failed"; exit 1; }
ln -s roots/archlinux "$NHSYSTEM/archlinux" 2>/dev/null || true

"$NHSYSTEM/bin/nh-mount" arch || { log "nh-mount arch failed; aborting"; exit 1; }
cp "$PAYLOAD/arch-fast-install.sh"    "$NHSYSTEM/roots/archlinux/root/arch-fast-install.sh"
cp "$PAYLOAD/arch-specialization.sh"  "$NHSYSTEM/roots/archlinux/root/arch-specialization.sh"
cp "$PAYLOAD/arch-autostart.sh"       "$NHSYSTEM/roots/archlinux/root/arch-autostart.sh"
cp "$PAYLOAD/arch-wireguard-setup.sh" "$NHSYSTEM/roots/archlinux/root/arch-wireguard-setup.sh"
run_chroot "$NHSYSTEM/roots/archlinux" /bin/bash /root/arch-fast-install.sh

log "configuring Termux aliases when present"
TERMUX_HOME=/data/data/com.termux/files/home
if [ -d "$TERMUX_HOME" ]; then
    cp "$PAYLOAD/termux-home/nh-aliases.zsh" "$TERMUX_HOME/.nh-aliases.zsh"
    owner="$(stat -c '%u:%g' "$TERMUX_HOME" 2>/dev/null || \
        ls -nd "$TERMUX_HOME" 2>/dev/null | awk '{print $3":"$4}' || echo '')"
    [ -n "$owner" ] && chown "$owner" "$TERMUX_HOME/.nh-aliases.zsh" 2>/dev/null || true
    [ -e "$TERMUX_HOME/workspace" ] || ln -s "$NHSYSTEM/workspaces/main" "$TERMUX_HOME/workspace"
    if ! grep -qF '.nh-aliases.zsh' "$TERMUX_HOME/.zshrc" 2>/dev/null; then
        printf '\n# NetHunter repaired launchers\n[ -f "$HOME/.nh-aliases.zsh" ] && source "$HOME/.nh-aliases.zsh"\n' >> "$TERMUX_HOME/.zshrc"
    fi
    [ -n "$owner" ] && chown -h "$owner" "$TERMUX_HOME/workspace" 2>/dev/null || true
fi

log "checking for Kali rootfs"
if [ -d "$NHSYSTEM/roots/kali-arm64" ]; then
    KALI="$NHSYSTEM/roots/kali-arm64"
elif [ -d "$NHSYSTEM/kali-arm64" ]; then
    KALI="$NHSYSTEM/kali-arm64"
else
    KALI=""
fi

if [ -n "$KALI" ]; then
    log "repairing Kali ARM64 v$NH_SETUP_VERSION ($NH_SETUP_PROFILE) rootfs at $KALI"
    [ "$KALI" = "$NHSYSTEM/roots/kali-arm64" ] || {
        mkdir -p "$NHSYSTEM/roots"
        mv "$KALI" "$NHSYSTEM/roots/kali-arm64"
        KALI="$NHSYSTEM/roots/kali-arm64"
    }
    ln -s roots/kali-arm64 "$NHSYSTEM/kali-arm64" 2>/dev/null || true
    ln -s roots/kali-arm64 "$NHSYSTEM/kalifs" 2>/dev/null || true
    cp "$PAYLOAD/kali-skel/enter.sh" "$KALI/enter.sh"
    chmod 755 "$KALI/enter.sh"
    mkdir -p "$KALI/root/.vnc" "$KALI/home/kali/.vnc"
    cp "$PAYLOAD/kali-skel/xstartup" "$KALI/root/.vnc/xstartup"
    cp "$PAYLOAD/kali-skel/xstartup" "$KALI/home/kali/.vnc/xstartup" 2>/dev/null || true
    chmod 700 "$KALI/root/.vnc" "$KALI/root/.vnc/xstartup" 2>/dev/null || true
    "$NHSYSTEM/bin/nh-mount" kali
    cp "$PAYLOAD/kali-post.sh" "$KALI/root/kali-post.sh"
    cp "$PAYLOAD/kali-sudo-fix.sh" "$KALI/root/kali-sudo-fix.sh"
    cp "$PAYLOAD/nh-sudo.c" "$KALI/root/nh-sudo.c"
    cp "$PAYLOAD/kali-sudo-helper.sh" "$KALI/root/kali-sudo-helper.sh"
    run_chroot "$KALI" /bin/sh /root/kali-post.sh || true
    run_chroot "$KALI" /bin/sh /root/kali-sudo-fix.sh || true
    run_chroot "$KALI" /bin/sh /root/kali-sudo-helper.sh || true
else
    log "Kali rootfs not present yet; install NetHunter rootfs, then rerun this script"
fi

log "starting services"
"$NHSYSTEM/bin/nh-services" start || true
"$NHSYSTEM/bin/nh-status" || true
log "clean rebuild complete"
