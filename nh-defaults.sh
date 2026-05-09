#!/bin/sh
# NH_SETUP_VERSION: 2.0 nextgen
# Profile: Universal — auto-detected device profile
# NetHunter setup v2.0 nextgen — dual Arch ARM64 + Kali ARM64 chroot environment
# Device: auto-detected via getprop, override with env vars or device-profiles/<codename>.sh

NH_SETUP_VERSION="${NH_SETUP_VERSION:-2.0}"
NH_SETUP_PROFILE="${NH_SETUP_PROFILE:-full}"

# Load device profile if available
NH_SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" 2>/dev/null || true)"
if [ -n "$NH_SCRIPT_DIR" ] && [ -f "$NH_SCRIPT_DIR/device-profiles/loader.sh" ]; then
    . "$NH_SCRIPT_DIR/device-profiles/loader.sh"
fi

# Device identity — auto-detected or overridden
NH_DEVICE_NAME="${NH_DEVICE_NAME:-OnePlus 7 Pro}"
NH_DEVICE_CODENAME="${NH_DEVICE_CODENAME:-guacamole}"
NH_DEVICE_MODEL="${NH_DEVICE_MODEL:-GM1911}"
NH_ANDROID_RELEASE="${NH_ANDROID_RELEASE:-16}"
NH_ANDROID_SDK="${NH_ANDROID_SDK:-36}"
NH_ANDROID_ABI="${NH_ANDROID_ABI:-arm64-v8a}"
NH_LINEAGE_VERSION="${NH_LINEAGE_VERSION:-23.2}"

# ADB — allow env override, then profile default, then built-in fallback
NH_ADB_PORT="${NH_ADB_PORT:-52104}"
NH_DEVICE_IP="${NH_DEVICE_IP:-}"
DEVICE_IP="${DEVICE_IP:-${NH_DEVICE_IP:-10.0.0.113}}"
ADB_PORT="${ADB_PORT:-${NH_ADB_PORT:-52104}}"
ADB_SERIAL="${ADB_SERIAL:-$DEVICE_IP:$ADB_PORT}"
ROOT_SU="${ROOT_SU:-/debug_ramdisk/su}"

# Filesystem paths
NHSYSTEM="${NHSYSTEM:-/data/local/nhsystem}"
NHROOTS="${NHROOTS:-$NHSYSTEM/roots}"
NHWORK="${NHWORK:-$NHSYSTEM/workspaces/main}"
ARCH_ROOT_NAME="${ARCH_ROOT_NAME:-archlinux}"
KALI_ROOT_NAME="${KALI_ROOT_NAME:-kali-arm64}"
ARCH_ROOT_PATH="${ARCH_ROOT_PATH:-$NHROOTS/$ARCH_ROOT_NAME}"
KALI_ROOT_PATH="${KALI_ROOT_PATH:-$NHROOTS/$KALI_ROOT_NAME}"

# Labels
ARCH_LABEL="${ARCH_LABEL:-Arch ARM64 v$NH_SETUP_VERSION ($NH_SETUP_PROFILE)}"
KALI_LABEL="${KALI_LABEL:-Kali ARM64 v$NH_SETUP_VERSION ($NH_SETUP_PROFILE)}"
NH_LABEL="${NH_LABEL:-NetHunter setup v$NH_SETUP_VERSION ($NH_SETUP_PROFILE)}"

# SSH defaults
ARCH_SSH_USER="${ARCH_SSH_USER:-archlinux}"
ARCH_SSH_PORT="${ARCH_SSH_PORT:-2222}"
KALI_SSH_USER="${KALI_SSH_USER:-kali}"
KALI_SSH_PORT="${KALI_SSH_PORT:-22}"
TERMUX_SSH_USER="${TERMUX_SSH_USER:-u0_a171}"
TERMUX_SSH_PORT="${TERMUX_SSH_PORT:-8022}"
