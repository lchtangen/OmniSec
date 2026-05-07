#!/bin/sh
# NH_SETUP_VERSION: 2.0 default
# Profile: Arch ARM64 v2.0 default; Kali ARM64 v2.0 default
set -u
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

mkdir -p /usr/local/sbin /usr/local/src
cp /root/nh-sudo.c /usr/local/src/nh-sudo.c

if ! command -v gcc >/dev/null 2>&1; then
    [ -s /etc/resolv.conf ] || printf 'nameserver 1.1.1.1\nnameserver 8.8.8.8\n' > /etc/resolv.conf
    apt-get install -y --no-install-recommends gcc 2>/dev/null || true
fi

if ! command -v gcc >/dev/null 2>&1; then
    echo "gcc not available; skipping setuid sudo helper (install gcc and rerun kali-sudo-helper.sh)"
    exit 0
fi

gcc -O2 -Wall -Wextra \
    -fPIE -fstack-protector-strong -D_FORTIFY_SOURCE=2 \
    -Wl,-z,relro,-z,now -pie \
    -o /usr/local/sbin/nh-sudo /usr/local/src/nh-sudo.c
chown root:root /usr/local/sbin/nh-sudo
chmod 4755 /usr/local/sbin/nh-sudo
ln -sf nh-sudo /usr/local/sbin/sudo

echo "setuid sudo helper installed"
