#!/usr/bin/env bash
# Post-install Arch Linux host setup for OmniSec.
# Idempotent. Targets the currently-running system. No disk partitioning.
# Usage: scripts/arch-host-setup.sh [--plan|--apply] [--yes]
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TARGET_USER="${SUDO_USER:-${USER:-tangen}}"
MODE="plan"
ASSUME_YES="0"

for arg in "$@"; do
    case "$arg" in
        --plan)  MODE="plan" ;;
        --apply) MODE="apply" ;;
        --yes|-y) ASSUME_YES="1" ;;
        -h|--help)
            sed -n '2,4p' "$0"; exit 0 ;;
        *)
            printf 'unknown arg: %s\n' "$arg" >&2; exit 2 ;;
    esac
done

have_cmd() { type -P "$1" >/dev/null 2>&1; }
log()      { printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*"; }
step()     { printf '\n\033[1;36m== %s ==\033[0m\n' "$*"; }
run() {
    if [[ "$MODE" == "apply" ]]; then
        printf '  $ %s\n' "$*"; eval "$*"
    else
        printf '  [plan] %s\n' "$*"
    fi
}

# ── pre-checks ──────────────────────────────────────────────────────────────
[[ $EUID -eq 0 ]] && { echo "do not run as root; the script invokes sudo itself" >&2; exit 1; }
[[ -f /etc/arch-release ]] || { echo "this script is Arch-only (no /etc/arch-release)" >&2; exit 1; }
have_cmd sudo    || { echo "sudo not installed" >&2; exit 1; }
have_cmd pacman  || { echo "pacman not installed" >&2; exit 1; }
id "$TARGET_USER" >/dev/null 2>&1 || { echo "user $TARGET_USER does not exist" >&2; exit 1; }

step "mode=$MODE  user=$TARGET_USER  host=${HOSTNAME:-$(uname -n)}"
if [[ "$MODE" == "apply" && "$ASSUME_YES" != "1" ]]; then
    read -r -p "proceed? [y/N] " ans
    [[ "$ans" =~ ^[Yy]$ ]] || { echo "aborted"; exit 0; }
fi

# Prime sudo once so subsequent calls are non-interactive in apply mode.
[[ "$MODE" == "apply" ]] && sudo -v

# ── 1. repair /etc/sudoers.d/tangen and ensure wheel rule ───────────────────
step "1/7 sudoers (NOPASSWD for $TARGET_USER, wheel group rule)"
fix_sudoers() {
    local tmp; tmp="$(mktemp)"
    printf '%s ALL=(ALL:ALL) NOPASSWD: ALL\n' "$TARGET_USER" > "$tmp"
    chmod 0440 "$tmp"
    sudo visudo -cf "$tmp" >/dev/null
    sudo install -m 0440 -o root -g root "$tmp" "/etc/sudoers.d/$TARGET_USER"
    rm -f "$tmp"
    if ! sudo grep -Eq '^\s*%wheel\s+ALL=\(ALL(:ALL)?\)\s+ALL' /etc/sudoers /etc/sudoers.d/* 2>/dev/null; then
        local tw; tw="$(mktemp)"
        printf '%%wheel ALL=(ALL:ALL) ALL\n' > "$tw"
        chmod 0440 "$tw"
        sudo visudo -cf "$tw" >/dev/null
        sudo install -m 0440 -o root -g root "$tw" /etc/sudoers.d/wheel
        rm -f "$tw"
    fi
}
if [[ "$MODE" == "apply" ]]; then fix_sudoers; log "sudoers ok"
else log "[plan] would rewrite /etc/sudoers.d/$TARGET_USER and ensure wheel rule"; fi

# ── 2. group memberships relevant to OmniSec / NetHunter dev ────────────────
step "2/7 groups for $TARGET_USER"
GROUPS_WANTED=(wheel adbusers uucp plugdev kvm input storage optical network)
for g in "${GROUPS_WANTED[@]}"; do
    getent group "$g" >/dev/null || { log "skip $g (group missing)"; continue; }
    if id -nG "$TARGET_USER" | tr ' ' '\n' | grep -qx "$g"; then
        log "have $g"
    else
        run "sudo gpasswd -a '$TARGET_USER' '$g' >/dev/null"
    fi
done

# ── 3. pacman packages: base-devel, OmniSec dev stack, NetHunter workflow ───
step "3/7 pacman packages"
PKGS=(
    base-devel git make gcc clang lld pkgconf
    bash bash-completion zsh
    shellcheck shfmt bats
    python python-pip python-pipx python-virtualenv
    nodejs npm
    android-tools android-udev scrcpy
    qemu-base qemu-system-x86 qemu-system-arm qemu-user-static-binfmt
    arch-install-scripts debootstrap
    wireshark-cli nmap tcpdump openssh openvpn rsync curl wget
    jq yq ripgrep fd fzf bat tree htop tmux neovim
    git-lfs unzip zip p7zip
    polkit dbus
)
if [[ "$MODE" == "apply" ]]; then
    sudo pacman -Sy --needed --noconfirm "${PKGS[@]}"
else
    log "[plan] sudo pacman -Sy --needed --noconfirm ${PKGS[*]}"
fi

# ── 4. enable services ──────────────────────────────────────────────────────
step "4/7 services"
SERVICES=(systemd-udevd dbus polkit NetworkManager adb)
for s in "${SERVICES[@]}"; do
    if systemctl list-unit-files "${s}.service" --no-legend 2>/dev/null | grep -q .; then
        run "sudo systemctl enable --now ${s}.service"
    else
        log "skip ${s}.service (unit not present)"
    fi
done
run "sudo udevadm control --reload"
run "sudo udevadm trigger"

# ── 5. AI CLI tools (npm + pip) — installed for $TARGET_USER, no sudo ───────
step "5/7 AI CLI tools"
NPM_PKGS=(@anthropic-ai/claude-code @githubnext/github-copilot-cli @google/gemini-cli)
PIPX_PKGS=(aider-chat openai)
if [[ "$MODE" == "apply" ]]; then
    sudo -u "$TARGET_USER" sh -c '
        set -e
        mkdir -p "$HOME/.npm-global"
        npm config set prefix "$HOME/.npm-global" >/dev/null
        case ":$PATH:" in *":$HOME/.npm-global/bin:"*) ;; *)
            grep -q ".npm-global/bin" "$HOME/.bashrc" 2>/dev/null || \
                printf "\nexport PATH=\"\$HOME/.npm-global/bin:\$PATH\"\n" >> "$HOME/.bashrc"
        esac
        export PATH="$HOME/.npm-global/bin:$PATH"
        npm install -g '"${NPM_PKGS[*]}"' || echo "[warn] some npm pkgs failed"
        pipx ensurepath >/dev/null 2>&1 || true
        for p in '"${PIPX_PKGS[*]}"'; do pipx install --force "$p" || echo "[warn] pipx $p failed"; done
    '
else
    log "[plan] npm -g (user prefix): ${NPM_PKGS[*]}"
    log "[plan] pipx install:        ${PIPX_PKGS[*]}"
fi

# ── 6. OmniSec repo build/test smoke (only if Makefile exists) ──────────────
step "6/7 OmniSec smoke"
if [[ -f "$ROOT_DIR/Makefile" ]]; then
    run "make -C '$ROOT_DIR' lint"
    run "make -C '$ROOT_DIR' test"
else
    log "no Makefile at $ROOT_DIR; skipping"
fi

# ── 7. summary ──────────────────────────────────────────────────────────────
step "7/7 verification"
run "sudo -k"
run "sudo -n id"
run "groups '$TARGET_USER'"
run "systemctl is-active adb.service NetworkManager.service 2>/dev/null || true"
log "done. log out and back in (or run: newgrp wheel) to refresh group membership."
