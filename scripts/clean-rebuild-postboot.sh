#!/bin/bash
# NH_SETUP_VERSION: 2.0 default
# Profile: Arch ARM64 v2.0 default; Kali ARM64 v2.0 default
set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
. "$SCRIPT_DIR/nh-defaults.sh"
DEVICE_ARG=()
DEVICE_ARG=(-s "$ADB_SERIAL")

ROOTFS="$SCRIPT_DIR/ArchLinuxARM-aarch64-latest.tar.gz"
PAYLOAD_DIR="$SCRIPT_DIR/payload"
ROOT_SU="${ROOT_SU:-}"
# Auto-detect Magisk su — path varies by Magisk version and Android 16
if [ -z "$ROOT_SU" ]; then
    for _c in /debug_ramdisk/su /data/adb/magisk/magisk64 /data/adb/magisk/magisk /sbin/su; do
        if adb "${DEVICE_ARG[@]}" shell "[ -x $_c ] && echo ok" 2>/dev/null | grep -q ok; then
            ROOT_SU="$_c"; break
        fi
    done
    ROOT_SU="${ROOT_SU:-/debug_ramdisk/su}"
fi
# Must be an array — modern adb single-quotes each argument before sending to the
# device shell, so a plain string "/debug_ramdisk/su --mount-master" would be treated
# as a single token (binary name with space) and fail.
ROOT_SU_MM=("$ROOT_SU" --mount-master)

die() {
  echo "error: $*" >&2
  exit 1
}

[ -f "$ROOTFS" ] || die "missing $ROOTFS"
[ -d "$PAYLOAD_DIR" ] || die "missing $PAYLOAD_DIR"

echo "[host] checking adb device"
if ! adb "${DEVICE_ARG[@]}" get-state >/dev/null 2>&1; then
    echo "[host] ADB unavailable; trying wireless reconnect: $ADB_SERIAL"
    adb connect "$ADB_SERIAL" >/dev/null 2>&1 || true
fi
adb "${DEVICE_ARG[@]}" get-state >/dev/null

echo "[host] checking root"
adb "${DEVICE_ARG[@]}" shell "$ROOT_SU" -c id | grep -q 'uid=0' || die "adb root via MagiskSU is not available"

echo "[host] staging payload"
adb "${DEVICE_ARG[@]}" shell "${ROOT_SU_MM[@]}" -c 'rm -rf /data/local/tmp/nh-clean-payload && mkdir -p /data/local/tmp/nh-clean-payload'
adb "${DEVICE_ARG[@]}" push "$PAYLOAD_DIR"/. /data/local/tmp/nh-clean-payload/

echo "[host] staging Arch Linux ARM64 rootfs"
adb "${DEVICE_ARG[@]}" push "$ROOTFS" /data/local/tmp/archlinuxarm.tar.gz

echo "[host] running clean rebuild"
adb "${DEVICE_ARG[@]}" shell "${ROOT_SU_MM[@]}" -c 'sh /data/local/tmp/nh-clean-payload/android-clean-rebuild.sh'

echo "[host] running final status"
adb "${DEVICE_ARG[@]}" shell "${ROOT_SU_MM[@]}" -c '/data/local/nhsystem/bin/nh-status || true'

echo "[host] checking for Termux — will set up if present"
if adb "${DEVICE_ARG[@]}" shell "$ROOT_SU" -c '[ -d /data/data/com.termux/files/home ] && echo found' \
        2>/dev/null | grep -q found; then
    echo "[host] Termux detected — running setup-termux.sh"
    ADB_SERIAL="$ADB_SERIAL" ROOT_SU="$ROOT_SU" bash setup-termux.sh || true
else
    echo "[host] Termux not installed — skipping Termux setup"
    echo "       Install Termux from F-Droid, open it once, then run: ./setup-termux.sh"
fi

echo "[host] updating ~/.ssh/config for VSCode Remote-SSH"
bash setup-ssh-config.sh || true

echo "[host] rebuild complete"
