#!/bin/bash
# NH_SETUP_VERSION: 2.0 default
# Profile: Arch ARM64 v2.0 default; Kali ARM64 v2.0 default
# arch-autostart.sh — runs inside Arch chroot at session start
# Called by nh-enter-arch / nh-enter-arch-root before exec-ing the shell.
# Idempotent — safe to call on every session entry.
set -euo pipefail

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Ensure critical runtime dirs exist (cleared on Android reboot)
mkdir -p /run/sshd /run/tor /run/sudo /tmp
chmod 1777 /tmp 2>/dev/null || true
chmod 0700 /run/sudo 2>/dev/null || true

# Start sshd if not already running
if ! pgrep -x sshd >/dev/null 2>&1; then
    SSHD=$(command -v sshd 2>/dev/null || true)
    if [ -n "$SSHD" ]; then
        "$SSHD" 2>/dev/null || true
    fi
fi

# Start Tor if torrc exists but daemon not running (on-demand only — not forced)
if [ -f /etc/tor/torrc ] && [ "${ARCH_TOR_AUTO:-0}" = "1" ]; then
    if ! pgrep -x tor >/dev/null 2>&1; then
        tor -f /etc/tor/torrc --RunAsDaemon 1 2>/dev/null || true
    fi
fi

# Check workspace is mounted via /proc/mounts (mountpoint utility may not exist on all Android)
if [ -d /workspace ]; then
    if ! grep -qs ' /workspace ' /proc/mounts 2>/dev/null && \
       ! grep -qs ' /workspace ' /proc/self/mountinfo 2>/dev/null; then
        echo "[arch-autostart] WARNING: /workspace is not mounted"
    fi
fi
