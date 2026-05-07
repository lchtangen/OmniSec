#!/bin/bash
# NH_SETUP_VERSION: 2.0 default
# Profile: Arch ARM64 v2.0 default; Kali ARM64 v2.0 default
# arch-polish.sh - finish Arch ARM64 dev workstation basics
set -euo pipefail

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

log() { echo "[arch-polish] $*"; }

log "ensuring workspace layout"
mkdir -p /workspace/{projects,notes,inbox,backup,keys,config,downloads,go}
chmod 700 /workspace/keys

log "installing missing workstation packages when available"
for pkg in starship radare2 zoxide bat eza btop restic; do
    pacman -S --needed --noconfirm "$pkg" || log "skipped: $pkg"
done

log "writing dev helper profile"
cat > /etc/profile.d/arch-workstation.sh <<'EOF'
export WORKSPACE=/workspace
export PROJECTS=/workspace/projects
export GOPATH=/workspace/go
export EDITOR=nvim
export VISUAL=nvim
export PAGER=less

case ":$PATH:" in *":/usr/local/bin:"*) ;; *) PATH="/usr/local/bin:$PATH" ;; esac
case ":$PATH:" in *":$GOPATH/bin:"*) ;; *) PATH="$GOPATH/bin:$PATH" ;; esac
case ":$PATH:" in *":$HOME/.cargo/bin:"*) ;; *) PATH="$HOME/.cargo/bin:$PATH" ;; esac
export PATH

alias ws='cd /workspace'
alias proj='cd /workspace/projects'
alias notes='cd /workspace/notes'
alias inbox='cd /workspace/inbox'
alias keys='cd /workspace/keys'
alias ll='ls -lah --color=auto'
alias py='python3'
alias r2='radare2'
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)" 2>/dev/null || true
EOF
chmod 644 /etc/profile.d/arch-workstation.sh

log "ensuring zsh sources workstation profile"
for rc in /root/.zshrc /home/archlinux/.zshrc; do
    touch "$rc"
    grep -q '/etc/profile.d/arch-workstation.sh' "$rc" 2>/dev/null || \
        printf '\n[ -f /etc/profile.d/arch-workstation.sh ] && source /etc/profile.d/arch-workstation.sh\n' >> "$rc"
done
chown archlinux:archlinux /home/archlinux/.zshrc 2>/dev/null || true

log "tool summary"
for t in starship radare2 nvim python node npm rustc cargo go clang cmake ninja tmux rg fd fzf jq; do
    if command -v "$t" >/dev/null 2>&1; then
        echo "  OK  $t"
    else
        echo "  --  $t"
    fi
done

log "complete"
