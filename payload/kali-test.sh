#!/bin/sh
# NH_SETUP_VERSION: 2.0 default
# Profile: Arch ARM64 v2.0 default; Kali ARM64 v2.0 default
set -u
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

echo "id: $(id)"
echo "whoami: $(whoami)"
echo "shells:"
grep -E '^(root|kali):' /etc/passwd
echo "commands:"
command -v id
command -v sudo
command -v su
command -v zsh
command -v sshd
echo "sudo:"
ls -l /usr/bin/sudo
sudo -V | head -2
echo "packages:"
dpkg-query -W sudo zsh openssh-server tigervnc-standalone-server 2>/dev/null
echo "sudoers:"
cat /etc/sudoers.d/90-nethunter-kali
