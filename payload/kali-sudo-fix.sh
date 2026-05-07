#!/bin/sh
# NH_SETUP_VERSION: 2.0 default
# Profile: Arch ARM64 v2.0 default; Kali ARM64 v2.0 default
set -u
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

mkdir -p /etc/sudoers.d /run/sudo
chmod 0700 /run/sudo 2>/dev/null || true

cat > /etc/sudoers.d/00-nethunter-android <<'EOF'
# Disable PTY requirement only for kali user — needed in Android chroot
# where full PTY allocation is not always available via ADB/chroot.
Defaults:kali !use_pty
EOF
chmod 440 /etc/sudoers.d/00-nethunter-android

cat > /etc/sudoers.d/90-nethunter-kali <<'EOF'
kali ALL=(ALL:ALL) NOPASSWD: ALL
EOF
chmod 440 /etc/sudoers.d/90-nethunter-kali

visudo -cf /etc/sudoers
echo "sudo fix complete"
