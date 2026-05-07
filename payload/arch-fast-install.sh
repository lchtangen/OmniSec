#!/bin/bash
# NH_SETUP_VERSION: 2.0 nextgen
# Profile: Arch ARM64 v2.0 nextgen
# Arch ARM64 fast install — Android kernel compat + base toolkit
set -euo pipefail

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

echo "[arch-fast] android kernel compatibility fixes"
echo ""
echo "  NOTE: SigLevel is set to Never below because Android's chroot"
echo "  cannot run pacman-key init properly. This disables GPG signature"
echo "  verification for all packages."
echo "  To re-enable: remove the SigLevel line from /etc/pacman.conf"
echo "  and run: pacman-key --init && pacman-key --populate archlinuxarm"
echo ""

# 1. DNS
rm -f /etc/resolv.conf
printf 'nameserver 1.1.1.1\nnameserver 8.8.8.8\n' > /etc/resolv.conf

# 2. /dev/fd for bash process substitution
[ -e /dev/fd ] || ln -sf /proc/self/fd /dev/fd

# 3. pacman.conf: disable sandbox, GPG, disk space checks
cp -f /etc/pacman.conf /etc/pacman.conf.pre-android-fix
sed -i \
  -e 's/^#DisableSandboxFilesystem/DisableSandboxFilesystem/' \
  -e 's/^#DisableSandboxSyscalls/DisableSandboxSyscalls/' \
  -e 's/^DownloadUser = alpm/#DownloadUser = alpm/' \
  -e 's/^SigLevel.*/SigLevel = Never/' \
  -e 's/^CheckSpace/#CheckSpace/' \
  /etc/pacman.conf
grep -q 'DisableSandbox' /etc/pacman.conf || \
  sed -i '/^\[options\]/a DisableSandbox' /etc/pacman.conf

# 4. tmpfs pacman cache (Android encrypted-ext4 statvfs lies about free space)
mkdir -p /var/cache/pacman/pkg
if ! mountpoint -q /var/cache/pacman/pkg 2>/dev/null; then
    _avail_mb="$(awk '/MemAvailable/{print int($2/1024)}' /proc/meminfo 2>/dev/null || echo 1200)"
    _tmpfs_mb=$(( _avail_mb / 2 ))
    [ "$_tmpfs_mb" -gt 600 ] && _tmpfs_mb=600
    [ "$_tmpfs_mb" -lt 100 ] && _tmpfs_mb=100
    mount -t tmpfs -o size="${_tmpfs_mb}m",mode=755 tmpfs /var/cache/pacman/pkg || true
fi

echo "[arch-fast] syncing databases and upgrading base system"
pacman -Syu --noconfirm

echo "[arch-fast] installing core usable toolkit"
pacman -S --needed --noconfirm \
  base base-devel sudo zsh bash-completion openssh git curl wget rsync \
  unzip zip tar xz zstd gzip bzip2 lz4 p7zip ca-certificates gnupg \
  pacman-contrib vim nano tmux less man-db man-pages texinfo tree file which \
  findutils grep sed gawk coreutils util-linux procps-ng psmisc lsof strace \
  iproute2 iputils net-tools bind inetutils traceroute tcpdump nmap openssl \
  python python-pip python-virtualenv nodejs npm clang cmake ninja make \
  pkgconf gdb sqlite jq ripgrep fd fzf htop ncdu

echo "[arch-fast] installing optional heavy/dev packages"
for pkg in go rust yq bat eza screen mc duf dog dust hyperfine procs bottom lsd; do
  pacman -S --needed --noconfirm "$pkg" 2>/dev/null || true
done

echo "[arch-fast] configuring user, sudo, shell, workspace, ssh"
useradd -m -s /usr/bin/zsh -G wheel archlinux 2>/dev/null || true
chsh -s /usr/bin/zsh root 2>/dev/null || true
chsh -s /usr/bin/zsh archlinux 2>/dev/null || true
mkdir -p /etc/sudoers.d /workspace /root/.ssh /home/archlinux/.ssh /run/sshd
chmod 700 /root/.ssh /home/archlinux/.ssh
printf '%%wheel ALL=(ALL:ALL) NOPASSWD: ALL\n' > /etc/sudoers.d/90-wheel-nopasswd
chmod 440 /etc/sudoers.d/90-wheel-nopasswd
visudo -cf /etc/sudoers || true

cat > /etc/profile.d/nethunter.sh <<'EOF'
export WORKSPACE=/workspace
export EDITOR=vim
export VISUAL=vim
export PAGER=less
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias ws='cd /workspace'
EOF
chmod 644 /etc/profile.d/nethunter.sh

cat > /root/.zshrc <<'EOF'
source /etc/profile.d/nethunter.sh 2>/dev/null || true
autoload -Uz compinit 2>/dev/null && compinit -d ~/.zcompdump 2>/dev/null || true
PROMPT='%F{red}%n@arch-arm64%f:%F{blue}%~%f %# '
EOF

cat > /home/archlinux/.zshrc <<'EOF'
source /etc/profile.d/nethunter.sh 2>/dev/null || true
autoload -Uz compinit 2>/dev/null && compinit -d ~/.zcompdump 2>/dev/null || true
PROMPT='%F{green}%n@arch-arm64%f:%F{blue}%~%f %# '
EOF
chown -R archlinux:archlinux /home/archlinux

_set_passwd() {
  user="$1"; pass="$2"
  hash="$(openssl passwd -6 "$pass" 2>/dev/null || echo '$6$deadbeef$'$(openssl passwd -1 "$pass" 2>/dev/null || echo 'x'))"
  sed -i "s|^${user}:[^:]*:|${user}:${hash}:|" /etc/shadow 2>/dev/null || true
}
_set_passwd root root
_set_passwd archlinux archlinux

timeout 30 ssh-keygen -A || true

cat > /etc/ssh/sshd_config <<'EOF'
Port 2222
ListenAddress 0.0.0.0
ListenAddress ::
HostKey /etc/ssh/ssh_host_ed25519_key
HostKey /etc/ssh/ssh_host_rsa_key
PermitRootLogin yes
PasswordAuthentication yes
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
UsePAM no
UseDNS no
X11Forwarding no
PrintMotd no
PidFile /run/sshd-2222.pid
LoginGraceTime 20
MaxStartups 10:30:60
Subsystem sftp /usr/lib/ssh/sftp-server
EOF

cat > /etc/nsswitch.conf <<'EOF'
passwd: files
group: files
shadow: files
gshadow: files
hosts: files dns
networks: files
protocols: files
services: files
ethers: files
rpc: files
EOF

echo "[arch-fast] cleanup"
pacman -Sc --noconfirm || true

if [ -f /root/arch-specialization.sh ]; then
  echo "[arch-fast] running personal desktop specialization"
  bash /root/arch-specialization.sh
fi

echo "[arch-fast] complete"
