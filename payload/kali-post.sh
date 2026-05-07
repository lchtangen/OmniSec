#!/bin/sh
# NH_SETUP_VERSION: 2.0 nextgen
# Profile: Kali ARM64 v2.0 nextgen
# Kali ARM64 post-install — full desktop + security toolkit
set -u

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
export DEBIAN_FRONTEND=noninteractive

echo "[kali-post] installing required packages"

# 1. Base system dependencies
apt-get update -qq 2>/dev/null || true
apt-get install -y --no-install-recommends \
  sudo zsh openssh-server dbus-x11 \
  tigervnc-standalone-server xfce4 xfce4-terminal \
  ca-certificates curl wget rsync unzip \
  2>/dev/null || true

# 2. Security & pentest toolkit (core)
apt-get install -y --no-install-recommends \
  nmap netcat-openbsd tcpdump traceroute \
  hydra john hashcat sqlmap metasploit-framework \
  wireshark aircrack-ng reaver bully \
  burpsuite gobuster dirb nikto \
  exploitdb python3-pip \
  2>/dev/null || true

# 3. Bluetooth tools
apt-get install -y --no-install-recommends \
  bluez bluez-tools bluetooth \
  2>/dev/null || true

# 4. SDR tools
apt-get install -y --no-install-recommends \
  gnuradio gqrx-sdr rtl-sdr hackrf \
  2>/dev/null || true

# 5. Development tools
apt-get install -y --no-install-recommends \
  git vim neovim build-essential cmake \
  python3-dev python3-venv \
  2>/dev/null || true

mkdir -p /run/sshd /run/sudo /workspace /etc/sudoers.d
chmod 0700 /run/sudo 2>/dev/null || true
chmod 1777 /tmp 2>/dev/null || true

# SSH host keys
timeout 30 ssh-keygen -A || true

cat > /etc/ssh/sshd_config <<'EOF'
Port 22
PermitRootLogin yes
PasswordAuthentication yes
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
UsePAM no
X11Forwarding yes
Subsystem sftp /usr/lib/openssh/sftp-server
EOF

if command -v usermod >/dev/null 2>&1 && [ -x /usr/bin/zsh ]; then
    usermod -s /usr/bin/zsh root 2>/dev/null || true
    usermod -s /usr/bin/zsh kali 2>/dev/null || true
fi

cat > /etc/sudoers.d/90-nethunter-kali <<'EOF'
kali ALL=(ALL:ALL) NOPASSWD: ALL
EOF
chmod 440 /etc/sudoers.d/90-nethunter-kali

# Deploy sudo wrapper if sudo.orig exists
if [ -x /usr/bin/sudo.orig ]; then
    cp /usr/bin/sudo.orig /usr/bin/sudo.real 2>/dev/null || true
else
    cp /usr/bin/sudo /usr/bin/sudo.orig 2>/dev/null || true
fi

if [ -f /etc/skel/.zshrc ]; then
    cp /etc/skel/.zshrc /root/.zshrc
    cp /etc/skel/.zshrc /home/kali/.zshrc 2>/dev/null || true
fi
if [ -f /etc/skel/.bashrc ]; then
    cp /etc/skel/.bashrc /root/.bashrc
    cp /etc/skel/.bashrc /home/kali/.bashrc 2>/dev/null || true
fi

chown -R kali:kali /home/kali 2>/dev/null || true

# SSH authorized key
PUBKEY="${PUBKEY:-REPLACE_WITH_YOUR_PUBLIC_KEY}"
for homedir in /root /home/kali; do
    mkdir -p "$homedir/.ssh"
    chmod 700 "$homedir/.ssh"
    echo "$PUBKEY" > "$homedir/.ssh/authorized_keys"
    chmod 600 "$homedir/.ssh/authorized_keys"
done
chown -R kali:kali /home/kali/.ssh 2>/dev/null || true

printf 'kali:kali\nroot:kali\n' | chpasswd 2>/dev/null || true

echo "kali post setup complete"
