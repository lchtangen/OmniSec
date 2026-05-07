#!/bin/sh
# NH_SETUP_VERSION: 2.0 default
# Profile: Arch ARM64 v2.0 default; Kali ARM64 v2.0 default
set -u

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export TERM="${TERM:-xterm-256color}"
export LANG="${LANG:-C.UTF-8}"
export LC_ALL="${LC_ALL:-C.UTF-8}"

if [ "$(id -u)" -eq 0 ]; then
    chmod 0666 /dev/pts/ptmx /dev/ptmx 2>/dev/null || true
    chmod 1777 /tmp 2>/dev/null || true
    mkdir -p /run/sshd /run/sudo /workspace
    chmod 0700 /run/sudo 2>/dev/null || true
    [ -s /etc/resolv.conf ] || printf 'nameserver 1.1.1.1\nnameserver 8.8.8.8\n' > /etc/resolv.conf 2>/dev/null || true

    if [ -x /usr/bin/zsh ]; then
        usermod -s /usr/bin/zsh root 2>/dev/null || true
        id kali >/dev/null 2>&1 && usermod -s /usr/bin/zsh kali 2>/dev/null || true
    fi
fi

if [ "$(id -u)" -eq 0 ] && id kali >/dev/null 2>&1; then
    if command -v runuser >/dev/null 2>&1; then
        exec /usr/sbin/runuser -u kali -- /usr/bin/env -i \
            HOME=/home/kali \
            USER=kali \
            LOGNAME=kali \
            TERM="$TERM" \
            LANG="$LANG" \
            LC_ALL="$LC_ALL" \
            SHELL=/usr/bin/zsh \
            PROMPT='kali@nethunter:%~$ ' \
            PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
            /usr/bin/zsh -l
    else
        # runuser not available (minimal Kali image) — fall back to su
        exec su - kali -s /usr/bin/zsh 2>/dev/null || exec su kali
    fi
fi

export HOME=/root USER=root LOGNAME=root SHELL=/usr/bin/zsh
cd /root 2>/dev/null || cd /
if [ -x /usr/bin/zsh ]; then
    exec /usr/bin/zsh -l
fi
exec /bin/bash --login
