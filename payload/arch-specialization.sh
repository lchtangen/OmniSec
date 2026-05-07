#!/bin/bash
# NH_SETUP_VERSION: 2.0 nextgen
# Profile: Arch ARM64 v2.0 nextgen
# Arch ARM64 v2.0 — full dev workstation specialization
set -euo pipefail

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
export HOME=/root

log() { echo "[arch-spec] $*"; }

# ── Privacy & Network Tools ───────────────────────────────────────────────────
log "installing privacy and network packages"
for pkg in \
  tor torsocks proxychains-ng \
  wireguard-tools openvpn \
  age pass cryptsetup \
  tcpdump nmap bind-tools \
  netcat-openbsd whois macchanger \
  ssh-audit; do
  pacman -S --needed --noconfirm "$pkg" 2>/dev/null || log "  skipped: $pkg"
done

# ── Security / CTF Tools ─────────────────────────────────────────────────────
log "installing security and CTF tools"
for pkg in radare2 rizin binwalk gdb strace ltrace; do
  pacman -S --needed --noconfirm "$pkg" 2>/dev/null || log "  skipped: $pkg"
done

pip install --break-system-packages --quiet pwntools 2>/dev/null || true

# pwndbg
if [ ! -d /opt/pwndbg ]; then
  git clone --depth=1 https://github.com/pwndbg/pwndbg /opt/pwndbg 2>/dev/null || true
  if [ -d /opt/pwndbg ]; then
    cd /opt/pwndbg
    ./setup.sh --quiet 2>/dev/null || pip install --break-system-packages -r requirements.txt 2>/dev/null || true
    cd /
  fi
fi

# checksec wrapper
cat > /usr/local/bin/checksec <<'CHECKSEC'
#!/bin/bash
if command -v checksec >/dev/null 2>&1 && [ "$(which checksec)" != "/usr/local/bin/checksec" ]; then
  exec checksec "$@"
fi
for f in "$@"; do
  echo "=== $f ==="
  readelf -l "$f" 2>/dev/null | grep -E 'GNU_RELRO|GNU_STACK|PHDR' || echo "  (readelf not available)"
  readelf -d "$f" 2>/dev/null | grep -E 'BIND_NOW|FLAGS' || true
done
CHECKSEC
chmod 755 /usr/local/bin/checksec

# ── Desktop & Productivity ────────────────────────────────────────────────────
log "installing desktop and productivity tools"
for pkg in neovim ranger highlight mediainfo w3m btop yt-dlp ffmpeg restic \
  newsboat calcurse zoxide bandwhich lazygit lazydocker jq yq pup htmlq \
  delta difftastic shellcheck shfmt; do
  pacman -S --needed --noconfirm "$pkg" 2>/dev/null || log "  skipped: $pkg"
done

# ── Python Full Stack ─────────────────────────────────────────────────────────
log "installing Python full stack"
pacman -S --needed --noconfirm python-pipx 2>/dev/null || pip install --break-system-packages pipx 2>/dev/null || true

export PIPX_HOME=/opt/pipx
export PIPX_BIN_DIR=/usr/local/bin
for tool in poetry black mypy ruff ipython pre-commit cookiecutter; do
  pipx install "$tool" 2>/dev/null || \
    pip install --break-system-packages "$tool" 2>/dev/null || \
    log "  warning: $tool install failed (non-fatal)"
done

# ── Rust Toolchain Extras ─────────────────────────────────────────────────────
log "installing Rust toolchain extras"
if command -v cargo >/dev/null 2>&1; then
  cargo install sccache 2>/dev/null || true
  command -v sccache >/dev/null 2>&1 && export RUSTC_WRAPPER=sccache || true
  cargo install cargo-watch 2>/dev/null || true
  cargo install cargo-edit 2>/dev/null || true
  cargo install cargo-audit 2>/dev/null || true
  cargo install cargo-expand 2>/dev/null || true
  cargo install cargo-tarpaulin 2>/dev/null || true
else
  log "  cargo not found — skipping Rust extras"
fi

# ── Go Toolchain Extras ───────────────────────────────────────────────────────
log "installing Go toolchain extras"
if command -v go >/dev/null 2>&1; then
  export GOPATH=/workspace/go
  export PATH=$GOPATH/bin:$PATH
  go install golang.org/x/tools/gopls@latest 2>/dev/null || true
  go install github.com/air-verse/air@latest 2>/dev/null || true
  go install golang.org/x/tools/cmd/goimports@latest 2>/dev/null || true
  go install github.com/go-delve/delve/cmd/dlv@latest 2>/dev/null || true
else
  log "  go not found — skipping Go extras"
fi

# ── Starship Prompt ───────────────────────────────────────────────────────────
log "installing Starship prompt"
if command -v cargo >/dev/null 2>&1; then
  cargo install starship 2>/dev/null || true
  if ! command -v starship >/dev/null 2>&1; then
    curl -sS https://starship.rs/install.sh | sh -s -- --yes 2>/dev/null || true
  fi
else
  curl -sS https://starship.rs/install.sh | sh -s -- --yes 2>/dev/null || true
fi

mkdir -p /root/.config /home/archlinux/.config
cat > /root/.config/starship.toml <<'STARSHIP'
format = "$username$hostname$directory$git_branch$git_status$python$rust$golang$nodejs$cmd_duration$line_break$character"

[username]
show_always = true
format = "[$user]($style)@"
style_user = "red bold"
style_root = "red bold"

[hostname]
ssh_only = false
format = "[$hostname]($style):"
style = "yellow bold"

[directory]
truncation_length = 4
truncate_to_repo = true
style = "blue bold"

[git_branch]
format = "[$symbol$branch]($style) "
symbol = ""
style = "cyan"

[git_status]
format = "[$all_status$ahead_behind]($style) "
style = "red"

[python]
format = "[$version]($style) "
style = "yellow"

[rust]
format = "[$version]($style) "
style = "red"

[golang]
format = "[$version]($style) "
style = "cyan"

[nodejs]
format = "[$version]($style) "
style = "green"

[cmd_duration]
min_time = 2000
format = "[ $duration]($style) "
style = "yellow"

[character]
success_symbol = "[>](green)"
error_symbol = "[>](red)"
STARSHIP
cp /root/.config/starship.toml /home/archlinux/.config/starship.toml

# ── Proxychains Config ────────────────────────────────────────────────────────
cat > /etc/proxychains.conf <<'EOF'
strict_chain
proxy_dns
tcp_read_time_out 15000
tcp_connect_time_out 8000
[ProxyList]
socks5 127.0.0.1 9050
EOF

# ── Tor Config ────────────────────────────────────────────────────────────────
log "configuring Tor (on-demand)"
mkdir -p /var/lib/tor /run/tor
chmod 700 /var/lib/tor
cat > /etc/tor/torrc <<'EOF'
SocksPort 9050
DataDirectory /var/lib/tor
Log notice stderr
EOF

# ── WireGuard Config Template ─────────────────────────────────────────────────
log "writing WireGuard config template"
mkdir -p /etc/wireguard
chmod 700 /etc/wireguard
cat > /etc/wireguard/wg0.conf.template <<'EOF'
[Interface]
PrivateKey = <YOUR_DEVICE_PRIVATE_KEY>
Address    = 10.0.0.2/24
DNS        = 1.1.1.1

[Peer]
PublicKey  = <SERVER_PUBLIC_KEY>
Endpoint   = <SERVER_IP>:<SERVER_PORT>
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF

# ── arch-privacy-check ────────────────────────────────────────────────────────
log "installing arch-privacy-check v2"
cat > /usr/local/bin/arch-privacy-check <<'EOF'
#!/bin/bash
ok()   { printf "  \033[32m✓\033[0m %s\n" "$*"; }
fail() { printf "  \033[31m✗\033[0m %s\n" "$*"; }
info() { printf "  \033[33m→\033[0m %s\n" "$*"; }

echo ""
echo "═══ Privacy Status v2 ════════════════════════════════"

echo ""
echo "── WireGuard ─────────────────────────────────────────"
if command -v wg >/dev/null 2>&1; then
  if wg show wg0 &>/dev/null 2>&1; then
    ok "wg0 interface UP"
    wg show wg0 | grep -E 'endpoint|latest handshake' | sed 's/^/    /'
  elif [ -f /etc/wireguard/wg0.conf ]; then
    fail "wg0 DOWN — run: sudo wg-quick up wg0"
  else
    info "No wg0.conf — copy /etc/wireguard/wg0.conf.template"
  fi
else
  fail "wireguard-tools not installed"
fi

echo ""
echo "── Tor ───────────────────────────────────────────────"
if pgrep -x tor >/dev/null 2>&1; then
  ok "Tor running (SOCKS5 :9050)"
else
  info "Tor not running — start with: tor &"
fi

echo ""
echo "── DNS ───────────────────────────────────────────────"
RESOLVE=$(dig +short +time=3 myip.opendns.com @resolver1.opendns.com 2>/dev/null || true)
if [ -n "$RESOLVE" ]; then
  ok "DNS working: $RESOLVE"
else
  info "DNS check skipped"
fi

echo ""
echo "── Exit IP ───────────────────────────────────────────"
REAL_IP=$(curl -s --max-time 5 https://api.ipify.org 2>/dev/null || echo "unreachable")
TOR_IP=$(torsocks curl -s --max-time 10 https://api.ipify.org 2>/dev/null || echo "unreachable")
info "Real IP: $REAL_IP"
info "Tor IP : $TOR_IP"
echo ""
echo "══════════════════════════════════════════════════════"
EOF
chmod 755 /usr/local/bin/arch-privacy-check

# ── arch-info v2 ──────────────────────────────────────────────────────────────
log "installing arch-info v2"
cat > /usr/local/bin/arch-info <<'EOF'
#!/bin/bash
echo "=== Arch ARM64 v2.0 ==="
echo "Kernel   : $(uname -r)"
echo "Arch     : $(uname -m)"
echo "Packages : $(pacman -Q 2>/dev/null | wc -l) installed"
echo "Updated  : $(stat -c '%y' /var/lib/pacman/local 2>/dev/null | cut -d. -f1)"
echo ""
echo "=== Network ==="
ip -br addr show 2>/dev/null | grep -v '^lo'
echo ""
echo "=== Listening Ports ==="
ss -tlnp 2>/dev/null | grep LISTEN || echo "  none"
echo ""
echo "=== Disk ==="
df -h /workspace /root 2>/dev/null
echo ""
echo "=== Active Tools ==="
for t in nvim starship cargo go python3 node radare2 pwn wg tor lazydog lazygit; do
  command -v "$t" >/dev/null 2>&1 && printf "  ✓ %s\n" "$t" || printf "  - %s\n" "$t"
done
EOF
chmod 755 /usr/local/bin/arch-info

# ── Neovim Config ─────────────────────────────────────────────────────────────
log "configuring neovim"
mkdir -p /root/.config/nvim /home/archlinux/.config/nvim
cat > /root/.config/nvim/init.vim <<'EOF'
set number relativenumber
set expandtab tabstop=4 shiftwidth=4
set smartindent
set clipboard=unnamedplus
set mouse=a
set termguicolors
set wrap linebreak
set ignorecase smartcase
set hidden
syntax on
filetype plugin indent on

nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
tnoremap <Esc> <C-\><C-n>
EOF
cp /root/.config/nvim/init.vim /home/archlinux/.config/nvim/init.vim

# ── Tmux Config ───────────────────────────────────────────────────────────────
log "configuring tmux"
cat > /root/.tmux.conf <<'EOF'
set -g prefix C-a
unbind C-b
bind C-a send-prefix

set -g mouse on
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",xterm-256color:Tc"
set -g history-limit 10000
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on

set -g status-style bg=colour235,fg=colour136
set -g status-left '#[fg=colour166,bold] #S '
set -g status-right '#[fg=colour136] %H:%M  %d-%b '
set -g status-interval 5

bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
bind r source-file ~/.tmux.conf \; display "reloaded"

bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R
EOF
cp /root/.tmux.conf /home/archlinux/.tmux.conf

# ── Workspace Structure ───────────────────────────────────────────────────────
log "creating workspace layout"
mkdir -p /workspace/{projects,notes,backup,keys,config,downloads,go}

# ── Profile v2 ────────────────────────────────────────────────────────────────
log "writing /etc/profile.d/arch-personal.sh"
cat > /etc/profile.d/arch-personal.sh <<'EOF'
export WORKSPACE=/workspace
export PROJECTS=/workspace/projects
export GOPATH=/workspace/go
export PIPX_HOME=/opt/pipx
export PIPX_BIN_DIR=/usr/local/bin
export EDITOR=nvim
export VISUAL=nvim
export PAGER=less
export BROWSER=w3m
export GPG_TTY=$(tty 2>/dev/null)

# Rust sccache
export RUSTC_WRAPPER=sccache

# PATH
for _p in /usr/local/bin "$GOPATH/bin" "$HOME/.cargo/bin"; do
  echo "$PATH" | grep -q "$_p" || export PATH="$_p:$PATH"
done

# Aliases
alias vim='nvim'
alias vi='nvim'
alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias grep='grep --color=auto'
alias ws='cd /workspace'
alias proj='cd /workspace/projects'
alias notes='cd /workspace/notes'
alias ..='cd ..'
alias ...='cd ../..'

# Privacy
alias tor-start='tor &'
alias tor-stop='pkill tor 2>/dev/null || true'
alias tor-status='pgrep -x tor >/dev/null && echo "Tor: running" || echo "Tor: stopped"'
alias tor-curl='torsocks curl'
alias tor-git='torsocks git'
alias wg-up='sudo wg-quick up wg0'
alias wg-down='sudo wg-quick down wg0'
alias wg-status='sudo wg show'
alias privacy-check='arch-privacy-check'

# Dev
alias myip='curl -s https://api.ipify.org && echo'
alias myip-tor='torsocks curl -s https://api.ipify.org && echo'
alias gpg-list='gpg --list-secret-keys --keyid-format LONG'
alias py='python3'
alias pip='pip3'
alias r2='radare2'

# Tools
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)" 2>/dev/null || true
command -v starship >/dev/null 2>&1 && eval "$(starship init bash)" 2>/dev/null || true
EOF
chmod 644 /etc/profile.d/arch-personal.sh

cat > /etc/profile.d/nethunter.sh <<'EOF'
export WORKSPACE=/workspace
EOF
chmod 644 /etc/profile.d/nethunter.sh

# ── Zsh Config ────────────────────────────────────────────────────────────────
log "writing zsh configs"

_zshrc_body() {
cat <<'ZSHRC'
source /etc/profile.d/arch-personal.sh 2>/dev/null || true

autoload -Uz compinit
compinit -d ~/.zcompdump 2>/dev/null || true
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

HISTSIZE=20000
SAVEHIST=20000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY EXTENDED_HISTORY

bindkey -e
bindkey '^R' history-incremental-search-backward
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line

command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/fzf/completion.zsh ]   && source /usr/share/fzf/completion.zsh

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
ZSHRC
}

{ _zshrc_body; printf '\n[ -z "$STARSHIP_SHELL" ] && PROMPT="%%F{red}%%n@arch-arm64%%f:%%F{blue}%%~%%f %%# "\n'; } \
  > /root/.zshrc

{ _zshrc_body; printf '\n[ -z "$STARSHIP_SHELL" ] && PROMPT="%%F{green}%%n@arch-arm64%%f:%%F{blue}%%~%%f %%# "\n'; } \
  > /home/archlinux/.zshrc

chown -R archlinux:archlinux /home/archlinux

log "specialization complete"
echo ""
echo "  arch-info          — system overview"
echo "  arch-privacy-check — WireGuard + Tor + IP status"
echo "  nvim               — editor"
echo "  radare2 / pwndbg   — CTF/security tools"
echo "  tor-start          — start Tor SOCKS5 on :9050"
echo "  wg-up / wg-down    — WireGuard VPN"
echo "  /workspace/{projects,notes,backup,keys,config,downloads,go}"
echo ""
echo "  v2.0 nextgen additions:"
echo "  lazydog/lazygit    — terminal UI for git/docker"
echo "  delta/difftastic   — diff viewers"
echo "  cargo-audit/tarpaulin — Rust security/testing"
echo "  dalv (dlv)          — Go debugger"
echo "  pre-commit          — git hook manager"
echo "  cookiecutter        — project templates"
echo ""
