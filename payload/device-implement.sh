#!/system/bin/sh
# NH_SETUP_VERSION: 2.0 default
# Profile: Arch ARM64 v2.0 default; Kali ARM64 v2.0 default
set -u

NHSYSTEM=/data/local/nhsystem
ROOTS=$NHSYSTEM/roots
BIN=$NHSYSTEM/bin
ETC=$NHSYSTEM/etc
WORK=$NHSYSTEM/workspaces/main
BACKUPS=$NHSYSTEM/backups
LOGS=$NHSYSTEM/logs
TMP=$NHSYSTEM/tmp
TERMUX=/data/data/com.termux/files
TERMUX_HOME=$TERMUX/home
PAYLOAD=/data/local/tmp/nh-repair-payload
TS="$(date +%Y%m%d-%H%M%S)"
LOG=$LOGS/repair-$TS.log

log() {
    echo "[$(date +%H:%M:%S)] $*" | tee -a "$LOG"
}

run() {
    log "+ $*"
    "$@" 2>&1 | tee -a "$LOG"
}

mkdir -p "$NHSYSTEM" "$ROOTS" "$BIN" "$ETC" "$WORK" "$BACKUPS" "$LOGS" "$TMP"
log "NetHunter repair started"

OLD_KALI=$NHSYSTEM/kali-arm64
NEW_KALI=$ROOTS/kali-arm64
ARCH=$ROOTS/archlinux

log "Creating selected backups"
BK=$BACKUPS/pre-repair-$TS
mkdir -p "$BK"
for p in \
    "$OLD_KALI/root/.ssh" \
    "$OLD_KALI/root/.zshrc" \
    "$OLD_KALI/root/.bashrc" \
    "$OLD_KALI/root/.profile" \
    "$OLD_KALI/root/.vnc" \
    "$OLD_KALI/home/kali/.ssh" \
    "$OLD_KALI/home/kali/.zshrc" \
    "$OLD_KALI/home/kali/.bashrc" \
    "$OLD_KALI/home/kali/.profile" \
    "$OLD_KALI/home/kali/.zprofile" \
    "$OLD_KALI/home/kali/.vnc" \
    "$OLD_KALI/enter.sh" \
    "$TERMUX_HOME/.ssh" \
    "$TERMUX_HOME/.termux" \
    "$TERMUX_HOME/.zshrc" \
    "$TERMUX_HOME/.bashrc" \
    "$TERMUX_HOME/.codex"; do
    if [ -e "$p" ]; then
        rel="$(echo "$p" | sed 's#^/##')"
        mkdir -p "$BK/$(dirname "$rel")"
        cp -a "$p" "$BK/$rel" 2>/dev/null || log "backup skipped: $p"
    fi
done

if [ -d "$OLD_KALI" ] && [ ! -e "$NEW_KALI" ]; then
    log "Moving Kali rootfs into roots layout"
    for pid in $(cat "$OLD_KALI/run/sshd.pid" 2>/dev/null); do kill "$pid" 2>/dev/null || true; done
    for p in workspace tmp run dev/shm dev/pts dev sys proc; do
        mountpoint="$OLD_KALI/$p"
        grep -qs " $mountpoint " /proc/mounts && umount "$mountpoint" 2>/dev/null || true
    done
    mv "$OLD_KALI" "$NEW_KALI"
fi

if [ -d "$NEW_KALI" ]; then
    rm -f "$NHSYSTEM/kali-arm64" "$NHSYSTEM/kalifs" 2>/dev/null || true
    ln -s roots/kali-arm64 "$NHSYSTEM/kali-arm64" 2>/dev/null || true
    ln -s roots/kali-arm64 "$NHSYSTEM/kalifs" 2>/dev/null || true
fi

if [ -d "$ARCH" ]; then
    rm -f "$NHSYSTEM/archlinux" 2>/dev/null || true
    ln -s roots/archlinux "$NHSYSTEM/archlinux" 2>/dev/null || true
fi

log "Installing launchers"
cp -a "$PAYLOAD/nhsystem-bin/." "$BIN/"
chmod 755 "$BIN"/nh-* 2>/dev/null || true

if [ -d "$NEW_KALI" ]; then
    log "Repairing Kali shell and KEX configs"
    cp "$PAYLOAD/kali-skel/enter.sh" "$NEW_KALI/enter.sh"
    chmod 755 "$NEW_KALI/enter.sh"

    mkdir -p "$NEW_KALI/root/.vnc" "$NEW_KALI/home/kali/.vnc" "$NEW_KALI/workspace"
    cp "$PAYLOAD/kali-skel/xstartup" "$NEW_KALI/root/.vnc/xstartup"
    cp "$PAYLOAD/kali-skel/xstartup" "$NEW_KALI/home/kali/.vnc/xstartup"
    chmod 700 "$NEW_KALI/root/.vnc" "$NEW_KALI/home/kali/.vnc"
    chmod 700 "$NEW_KALI/root/.vnc/xstartup" "$NEW_KALI/home/kali/.vnc/xstartup"

    if [ -f "$NEW_KALI/etc/skel/.zshrc" ]; then
        cp "$NEW_KALI/etc/skel/.zshrc" "$NEW_KALI/root/.zshrc"
        cp "$NEW_KALI/etc/skel/.zshrc" "$NEW_KALI/home/kali/.zshrc"
    fi
    if [ -f "$NEW_KALI/etc/skel/.bashrc" ]; then
        cp "$NEW_KALI/etc/skel/.bashrc" "$NEW_KALI/root/.bashrc"
        cp "$NEW_KALI/etc/skel/.bashrc" "$NEW_KALI/home/kali/.bashrc"
    fi
    chown -R 100000:100000 "$NEW_KALI/home/kali" 2>/dev/null || true

    mkdir -p "$NEW_KALI/etc/sudoers.d"
    printf 'kali ALL=(ALL:ALL) NOPASSWD: ALL\n' > "$NEW_KALI/etc/sudoers.d/90-nethunter-kali"
    chmod 440 "$NEW_KALI/etc/sudoers.d/90-nethunter-kali"

    if [ -x "$NEW_KALI/usr/bin/zsh" ]; then
        sed -i 's#^\(root:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:\).*#\1/usr/bin/zsh#' "$NEW_KALI/etc/passwd"
        sed -i 's#^\(kali:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:\).*#\1/usr/bin/zsh#' "$NEW_KALI/etc/passwd"
    fi
fi

log "Repairing Termux workspace and aliases"
if [ -d "$TERMUX_HOME" ]; then
    cp "$PAYLOAD/termux-home/nh-aliases.zsh" "$TERMUX_HOME/.nh-aliases.zsh"
    chown "$(stat -c '%u:%g' "$TERMUX_HOME")" "$TERMUX_HOME/.nh-aliases.zsh" 2>/dev/null || true
    if [ ! -e "$TERMUX_HOME/workspace" ]; then
        ln -s "$WORK" "$TERMUX_HOME/workspace" 2>/dev/null || true
        chown -h "$(stat -c '%u:%g' "$TERMUX_HOME")" "$TERMUX_HOME/workspace" 2>/dev/null || true
    fi
    if ! grep -q '.nh-aliases.zsh' "$TERMUX_HOME/.zshrc" 2>/dev/null; then
        printf '\n# NetHunter repaired launchers\n[ -f "$HOME/.nh-aliases.zsh" ] && source "$HOME/.nh-aliases.zsh"\n' >> "$TERMUX_HOME/.zshrc"
    fi
fi

log "Mounting Kali for package repair"
if [ -x "$BIN/nh-mount" ]; then
    "$BIN/nh-mount" kali 2>&1 | tee -a "$LOG" || true
fi

if [ -d "$NEW_KALI" ]; then
    log "Attempting native Kali package repair for sudo/dpkg/zsh/ssh/kex"
    /system/bin/chroot "$NEW_KALI" /usr/bin/env -i \
        HOME=/root USER=root LOGNAME=root TERM=xterm-256color LANG=C.UTF-8 LC_ALL=C.UTF-8 \
        PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
        /bin/sh -lc 'apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --reinstall -y sudo dpkg zsh openssh-server tigervnc-standalone-server dbus-x11 xfce4' \
        2>&1 | tee -a "$LOG" || log "Kali package repair failed; see log"

    log "Generating Kali SSH keys and config"
    /system/bin/chroot "$NEW_KALI" /usr/bin/env -i \
        HOME=/root USER=root LOGNAME=root TERM=xterm-256color LANG=C.UTF-8 LC_ALL=C.UTF-8 \
        PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
        /bin/sh -lc 'ssh-keygen -A; mkdir -p /run/sshd; printf "%s\n" "Port 22" "PermitRootLogin yes" "PasswordAuthentication yes" "PubkeyAuthentication yes" "AuthorizedKeysFile .ssh/authorized_keys" "UsePAM no" "X11Forwarding yes" "Subsystem sftp /usr/lib/openssh/sftp-server" > /etc/ssh/sshd_config' \
        2>&1 | tee -a "$LOG" || true
fi

log "Device repair script complete: $LOG"
