#!/bin/sh
# NH_SETUP_VERSION: 2.0 default
# Profile: Arch ARM64 v2.0 default; Kali ARM64 v2.0 default
# Termux clean setup — runs inside Termux's user environment
# Called by setup-termux.sh on the host via ADB
# Uses /bin/sh (dash) — bash is NOT installed on a fresh Termux build

set -eu

PREFIX=/data/data/com.termux/files/usr
export HOME=/data/data/com.termux/files/home
export PREFIX
case ":$PATH:" in *":$PREFIX/bin:"*) ;; *) PATH="$PREFIX/bin:$PATH" ;; esac
case ":$PATH:" in *":$PREFIX/bin/applets:"*) ;; *) PATH="$PREFIX/bin/applets:$PATH" ;; esac
case ":$PATH:" in *":/system/bin:"*) ;; *) PATH="/system/bin:$PATH" ;; esac
export PATH
export LD_LIBRARY_PATH=$PREFIX/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
export TMPDIR=$PREFIX/tmp
mkdir -p "$TMPDIR"
export TERM=xterm-256color
export LANG=en_US.UTF-8

cd "$HOME"

log() { echo "  [termux] $*"; }

write_shell_profiles() {
  cat > "$PREFIX/etc/termux-login.sh" <<'EOF'
PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
export PREFIX
export HOME="${HOME:-/data/data/com.termux/files/home}"
case ":$PATH:" in *":$PREFIX/bin:"*) ;; *) PATH="$PREFIX/bin:$PATH" ;; esac
case ":$PATH:" in *":$PREFIX/bin/applets:"*) ;; *) PATH="$PREFIX/bin/applets:$PATH" ;; esac
case ":$PATH:" in *":/system/bin:"*) ;; *) PATH="/system/bin:$PATH" ;; esac
export PATH
export LD_LIBRARY_PATH="$PREFIX/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export TMPDIR="$PREFIX/tmp"
export LANG="${LANG:-en_US.UTF-8}"
export TERM="${TERM:-xterm-256color}"
mkdir -p "$TMPDIR" 2>/dev/null || true
if [ -n "${SSH_CONNECTION:-}" ] || [ -n "${SSH_CLIENT:-}" ]; then
    unset LD_PRELOAD
fi
EOF
  chmod 644 "$PREFIX/etc/termux-login.sh"

  cat > "$HOME/.zprofile" <<'EOF'
PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
export PREFIX
export HOME="${HOME:-/data/data/com.termux/files/home}"
case ":$PATH:" in *":$PREFIX/bin:"*) ;; *) PATH="$PREFIX/bin:$PATH" ;; esac
case ":$PATH:" in *":$PREFIX/bin/applets:"*) ;; *) PATH="$PREFIX/bin/applets:$PATH" ;; esac
case ":$PATH:" in *":/system/bin:"*) ;; *) PATH="/system/bin:$PATH" ;; esac
export PATH
export LD_LIBRARY_PATH="$PREFIX/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export TMPDIR="$PREFIX/tmp"
export LANG="${LANG:-en_US.UTF-8}"
export TERM="${TERM:-xterm-256color}"
mkdir -p "$TMPDIR" 2>/dev/null || true
if [ -n "${SSH_CONNECTION:-}" ] || [ -n "${SSH_CLIENT:-}" ]; then
    unset LD_PRELOAD
fi
[ -f "$HOME/.zshrc" ] && source "$HOME/.zshrc"
EOF
  chmod 644 "$HOME/.zprofile"
}

log "configuring package mirror (main repo only)"
# Only termux-main exists on the CF CDN; games/science are separate mirrors.
# Removing them avoids 404 errors that abort the script.
mkdir -p "$PREFIX/etc/apt"
printf 'deb https://packages-cf.termux.dev/apt/termux-main stable main\n' \
    > "$PREFIX/etc/apt/sources.list"

# Force-confold: keep existing config files during upgrade without prompting.
# Without this, dpkg asks interactively about config file conflicts (e.g. openssl.cnf)
# which hangs non-interactive ADB sessions.
mkdir -p "$PREFIX/etc/apt/apt.conf.d"
printf 'Dpkg::Options { "--force-confold"; "--force-confdef"; };\n' \
    > "$PREFIX/etc/apt/apt.conf.d/99-noconfirm.conf"

log "updating package repos"
pkg update -y

log "upgrading installed packages"
DEBIAN_FRONTEND=noninteractive pkg upgrade -y

log "installing core tools"
pkg install -y \
  bash \
  tsu \
  zsh \
  git \
  curl \
  wget \
  openssh \
  gnupg \
  vim \
  nano \
  python \
  clang \
  make \
  cmake \
  ninja \
  pkg-config \
  binutils \
  patchelf \
  strace \
  tmux \
  fzf \
  ripgrep \
  tree \
  jq \
  htop \
  ncdu

log "setting default shell to zsh in Termux shell config"
# Guard: only write .termux/shell if zsh is actually installed and executable.
# Writing this file before zsh exists causes every Termux launch to fail with exit 126.
if [ -x "$PREFIX/bin/zsh" ]; then
    mkdir -p "$HOME/.termux"
    rm -f "$HOME/.termux/shell"
    ln -s "$PREFIX/bin/zsh" "$HOME/.termux/shell"
    log "default shell set to zsh"
else
    log "zsh not found after install — .termux/shell not written (Termux uses built-in default)"
fi

log "writing SSH-safe zsh login profile"
write_shell_profiles

log "generating SSH key (ed25519)"
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
  ssh-keygen -t ed25519 -f "$HOME/.ssh/id_ed25519" -N ""
fi
chmod 600 "$HOME/.ssh/id_ed25519"
chmod 644 "$HOME/.ssh/id_ed25519.pub"
cat "$HOME/.ssh/id_ed25519.pub" >> "$HOME/.ssh/authorized_keys" 2>/dev/null || true
sort -u "$HOME/.ssh/authorized_keys" -o "$HOME/.ssh/authorized_keys" 2>/dev/null || true
chmod 600 "$HOME/.ssh/authorized_keys" 2>/dev/null || true

log "installing Starship prompt for Termux"
STARSHIP_BIN="$PREFIX/bin/starship"
if [ ! -x "$STARSHIP_BIN" ]; then
  # Download the aarch64 binary directly — cargo not available in Termux by default
  # musl static build works on Android and is always published; android NDK build is optional
  STARSHIP_MUSL="https://github.com/starship/starship/releases/latest/download/starship-aarch64-unknown-linux-musl.tar.gz"
  STARSHIP_ANDROID="https://github.com/starship/starship/releases/latest/download/starship-aarch64-linux-android.tar.gz"
  STARSHIP_TMP="$TMPDIR/starship.tar.gz"
  curl -Lo --connect-timeout 15 --max-time 120 "$STARSHIP_TMP" "$STARSHIP_MUSL" 2>/dev/null || \
    curl -Lo --connect-timeout 15 --max-time 120 "$STARSHIP_TMP" "$STARSHIP_ANDROID" 2>/dev/null || true
  [ -s "$STARSHIP_TMP" ] && \
    tar -xzf "$STARSHIP_TMP" -C "$PREFIX/bin" starship 2>/dev/null && \
    chmod 755 "$STARSHIP_BIN" && \
    log "Starship installed: $($STARSHIP_BIN --version)" || \
    log "Starship download failed — prompt will use fallback"
  rm -f "$STARSHIP_TMP"
fi

# Starship config for Termux (same style as Arch)
mkdir -p "$HOME/.config"
if [ ! -f "$HOME/.config/starship.toml" ]; then
  cat > "$HOME/.config/starship.toml" <<'STARSHIP'
format = "$username$hostname$directory$git_branch$git_status$cmd_duration$line_break$character"

[username]
show_always = true
format = "[$user]($style)@"
style_user = "cyan bold"

[hostname]
ssh_only = false
format = "[$hostname]($style):"
style = "yellow"

[directory]
truncation_length = 3
style = "blue bold"

[git_branch]
format = "[$symbol$branch]($style) "
symbol = ""
style = "cyan"

[git_status]
format = "[$all_status$ahead_behind]($style) "
style = "red"

[cmd_duration]
min_time = 2000
format = "[ $duration]($style) "

[character]
success_symbol = "[❯](green)"
error_symbol = "[❯](red)"
STARSHIP
fi

log "starting Termux sshd on port 8022"
if [ -x "$PREFIX/bin/sshd" ]; then
  # Generate host keys if missing
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  [ -f "$PREFIX/etc/ssh/ssh_host_ed25519_key" ] || ssh-keygen -A 2>/dev/null || true
  # Start sshd (daemonizes automatically via termux-services or directly)
  "$PREFIX/bin/sshd" 2>/dev/null || true
  log "sshd started (port 8022)"
else
  log "sshd not found — install openssh first"
fi

log "setup complete — open Termux on device then run:"
echo ""
echo "    source ~/.zshrc"
echo "    tsu -c id        # verify root"
echo "    nh-status        # verify nhsystem"
echo "    arch             # enter Arch ARM64"
echo ""
