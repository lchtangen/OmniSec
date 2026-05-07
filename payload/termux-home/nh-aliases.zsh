# NH_SETUP_VERSION: 2.0 nextgen
# Profile: Arch ARM64 v2.0 full; Kali ARM64 v2.0 full
# ╔══════════════════════════════════════════════════════════════╗
# ║  NetHunter NextGen — Cyberpunk Terminal Environment         ║
# ║  OnePlus 7 Pro (GM1911) / Android 16 / LineageOS 23.2      ║
# ╚══════════════════════════════════════════════════════════════╝

export NHSYSTEM=/data/local/nhsystem
export NHWORKSPACE=$NHSYSTEM/workspaces/main
export NH_SU="${NH_SU:-/debug_ramdisk/su}"
export NH_BIN=$NHSYSTEM/bin
export NH_ANDROID_SDK=36
export NH_DEVICE=GM1911

# ── Chroot Launchers ─────────────────────────────────────────
alias kali='$NH_SU --mount-master -c $NH_BIN/nh-enter-kali'
alias kali-root='$NH_SU --mount-master -c $NH_BIN/nh-enter-kali-root'
alias arch='$NH_SU --mount-master -c $NH_BIN/nh-enter-arch'
alias arch-root='$NH_SU --mount-master -c $NH_BIN/nh-enter-arch-root'

# ── System Management ─────────────────────────────────────────
alias nh-status='$NH_SU --mount-master -c $NH_BIN/nh-status'
alias nh-debug='$NH_SU --mount-master -c $NH_BIN/nh-debug'
alias nh-services='$NH_SU --mount-master -c $NH_BIN/nh-services'
alias nh-update='$NH_SU --mount-master -c $NH_BIN/nh-update'
alias nh-health='$NH_SU --mount-master -c $NH_BIN/nh-health'
alias nh-backup='$NH_SU --mount-master -c $NH_BIN/nh-backup'
alias nh-vpn='$NH_SU --mount-master -c $NH_BIN/nh-vpn'
alias nh-scan='$NH_SU --mount-master -c $NH_BIN/nh-scan'
alias nh-temp='$NH_SU --mount-master -c $NH_BIN/nh-temp'
alias nh-battery='$NH_SU --mount-master -c $NH_BIN/nh-battery'
alias nh-net='$NH_SU --mount-master -c $NH_BIN/nh-net'
alias nh-bench='$NH_SU --mount-master -c $NH_BIN/nh-bench'
alias nh-clean='$NH_SU --mount-master -c $NH_BIN/nh-clean'
alias nh-proc='$NH_SU --mount-master -c $NH_BIN/nh-proc'

# ── SSH Shortcuts ─────────────────────────────────────────────
alias arch-ssh='ssh nh-arch'
alias kali-ssh='ssh nh-kali'
alias android-ssh='ssh nh-android'
alias arch-root-ssh='ssh nh-arch-root'

# ── Workspace Navigation ──────────────────────────────────────
alias ws='cd "$NHWORKSPACE"'
alias proj='cd "$NHWORKSPACE/projects"'
alias notes='cd "$NHWORKSPACE/notes"'
alias docs='cd "$NHWORKSPACE/docs"'
alias config='cd "$NHWORKSPACE/config"'
alias inbox='cd "$NHWORKSPACE/inbox"'
alias src='cd "$NHWORKSPACE/source"'
alias build='cd "$NHWORKSPACE/build"'
alias ls='ls --color=auto'
alias ll='ls -la'
alias la='ls -la'
alias lt='ls -lt'

# ── VPN / Privacy ─────────────────────────────────────────────
alias vpn-up='nh-vpn up'
alias vpn-down='nh-vpn down'
alias vpn-status='nh-vpn status'

# ── Cyberpunk Aesthetics ──────────────────────────────────────
alias banner='$NH_BIN/nh-banner'
alias matrix='$NH_BIN/nh-matrix'
alias sysinfo='$NH_BIN/nh-sysinfo'
alias weather='curl -s wttr.in/0,0?format="%l:+%c+%t+%w" 2>/dev/null || echo "offline"'

# ── Dev Tools ─────────────────────────────────────────────────
alias nh-dev='$NH_SU --mount-master -c $NH_BIN/nh-dev'
alias nh-init='$NH_SU --mount-master -c $NH_BIN/nh-init'
alias nh-config='$NH_SU --mount-master -c $NH_BIN/nh-config'
alias nh-module='$NH_SU --mount-master -c $NH_BIN/nh-module'
