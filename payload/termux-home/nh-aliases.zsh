# NH_SETUP_VERSION: 2.0 default
# Profile: Arch ARM64 v2.0 default; Kali ARM64 v2.0 default
# NetHunter + Arch ARM64 aliases for Termux
export NHSYSTEM=/data/local/nhsystem
export NHWORKSPACE=$NHSYSTEM/workspaces/main
export NH_SU="${NH_SU:-/debug_ramdisk/su}"

# ── Chroot Launchers ───────────────────────────────────────────────────────────
alias kali='$NH_SU --mount-master -c /data/local/nhsystem/bin/nh-enter-kali'
alias kali-root='$NH_SU --mount-master -c /data/local/nhsystem/bin/nh-enter-kali-root'
alias arch='$NH_SU --mount-master -c /data/local/nhsystem/bin/nh-enter-arch'
alias arch-root='$NH_SU --mount-master -c /data/local/nhsystem/bin/nh-enter-arch-root'

# ── System Management ─────────────────────────────────────────────────────────
alias nh-status='$NH_SU --mount-master -c /data/local/nhsystem/bin/nh-status'
alias nh-debug='$NH_SU --mount-master -c /data/local/nhsystem/bin/nh-debug'
alias nh-services='$NH_SU --mount-master -c /data/local/nhsystem/bin/nh-services'
alias nh-update='$NH_SU --mount-master -c /data/local/nhsystem/bin/nh-update'
alias nh-health='$NH_SU --mount-master -c /data/local/nhsystem/bin/nh-health'
alias nh-backup='$NH_SU --mount-master -c /data/local/nhsystem/bin/nh-backup'
alias nh-vpn='$NH_SU --mount-master -c /data/local/nhsystem/bin/nh-vpn'

# ── SSH Shortcuts ─────────────────────────────────────────────────────────────
alias arch-ssh='ssh nh-arch'
alias kali-ssh='ssh nh-kali'
alias android-ssh='ssh nh-android'

# ── Workspace Navigation ───────────────────────────────────────────────────────
alias ws='cd "$NHWORKSPACE"'
alias proj='cd "$NHWORKSPACE/projects"'
alias notes='cd "$NHWORKSPACE/notes"'
alias keys='cd "$NHWORKSPACE/keys"'

# ── VPN / Privacy ─────────────────────────────────────────────────────────────
alias vpn-up='$NH_SU --mount-master -c /data/local/nhsystem/bin/nh-vpn up'
alias vpn-down='$NH_SU --mount-master -c /data/local/nhsystem/bin/nh-vpn down'
alias vpn-status='$NH_SU --mount-master -c /data/local/nhsystem/bin/nh-vpn status'
