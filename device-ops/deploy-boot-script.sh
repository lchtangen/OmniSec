#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BOOT_SCRIPT="$ROOT_DIR/src/device/setup/start-arch-boot.sh"
SERVICE_D="/data/adb/service.d/99-nethunter-boot.sh"

say() { printf "\033[32m  %s\033[0m\n" "$*"; }
die() { printf "\033[31m  ERROR: %s\033[0m\n" "$*"; exit 1; }

check_adb() {
	adb devices -l | grep -q device || die "No device connected"
	say "Device connected"
}

check_root() {
	adb shell su -c id 2>/dev/null | grep -q uid=0 || die "No root access"
	say "Root access confirmed"
}

deploy_boot_script() {
	say "Deploying boot script to $SERVICE_D..."
	adb shell su -c "mkdir -p /data/adb/service.d"
	adb push "$BOOT_SCRIPT" /data/local/tmp/start-arch-boot.sh
	adb shell su -c "cp /data/local/tmp/start-arch-boot.sh $SERVICE_D"
	adb shell su -c "chmod 755 $SERVICE_D"
	adb shell su -c "restorecon $SERVICE_D 2>/dev/null || true"
	say "Boot script deployed"
}

verify_deploy() {
	say "Verifying..."
	adb shell su -c "ls -la $SERVICE_D"
	adb shell su -c "bash -n $SERVICE_D" && say "Syntax OK"
}

install_adb_forwards() {
	say "Installing ADB port forwards..."
	adb forward --remove-all 2>/dev/null || true
	adb forward tcp:2222 tcp:2222   # Arch SSH
	adb forward tcp:8022 tcp:8022   # Termux SSH
	adb forward tcp:22 tcp:22       # Kali SSH
	say "ADB forwards:"
	adb forward --list
}

usage() {
	cat <<EOF
Usage: $0 [command]

Commands:
  deploy      Deploy boot script to device (default)
  verify      Verify deployment
  forwards    Set up ADB port forwards
  all         Deploy + verify + forwards
EOF
	exit 0
}

case "${1:-deploy}" in
	deploy) check_adb; check_root; deploy_boot_script ;;
	verify) check_adb; check_root; verify_deploy ;;
	forwards) check_adb; install_adb_forwards ;;
	all) check_adb; check_root; deploy_boot_script; verify_deploy; install_adb_forwards ;;
	help|--help|-h) usage ;;
	*) die "Unknown: $1";;
esac
