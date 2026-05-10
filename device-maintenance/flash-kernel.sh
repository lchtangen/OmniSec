#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/build/kernel/out"
DIST_DIR="$ROOT_DIR/dist/kernel"
DEVICE="GM1911"
DEVICE_CODENAME="guacamole"

say() { printf "\033[32m  %s\033[0m\n" "$*"; }
die() { printf "\033[31m  ERROR: %s\033[0m\n" "$*"; exit 1; }
warn() { printf "\033[33m  %s\033[0m\n" "$*"; }

check_adb() {
	adb devices -l | grep -q device || die "No device connected"
	say "Device connected"
}

check_root() {
	adb shell su -c id 2>/dev/null | grep -q uid=0 || die "No root access"
	say "Root access confirmed"
}

check_boot_mode() {
	local mode
	mode="$(adb shell getprop ro.bootmode 2>/dev/null || echo "")"
	case "$mode" in
		fastboot|bootloader)
			say "Device in fastboot mode"
			return 0
			;;
		*)
			warn "Device not in fastboot mode"
			warn "Reboot to bootloader first: adb reboot bootloader"
			return 1
			;;
	esac
}

flash_boot() {
	local image="$1"
	[ -f "$image" ] || die "Boot image not found: $image"
	say "Flashing: $image"
	fastboot flash boot "$image"
	say "Flash complete"
}

flash_dtbo() {
	local dtb_dir="$BUILD_DIR/arch/arm64/boot/dts/qcom"
	if [ -d "$dtb_dir" ] && ls "$dtb_dir"/*.dtb 1>/dev/null 2>&1; then
		say "Flashing DTBs..."
		for dtb in "$dtb_dir"/*.dtb; do
			fastboot flash dtbo "$dtb" 2>/dev/null || true
		done
	fi
}

flash_anykernel() {
	local zip
	zip="$(ls "$DIST_DIR"/kernel-"$DEVICE_CODENAME"*.zip 2>/dev/null | head -1)"
	if [ -n "$zip" ] && command -v unzip &>/dev/null; then
		say "Found AnyKernel3 zip: $zip"
		warn "Flash in custom recovery (TWRP):"
		warn "  adb push \"$zip\" /sdcard/"
		warn "  Reboot to recovery, flash zip"
	else
		die "No AnyKernel3 zip found in $DIST_DIR"
	fi
}

reboot_bootloader() {
	say "Rebooting to bootloader..."
	adb reboot bootloader
	sleep 10
}

reboot() {
	say "Rebooting device..."
	fastboot reboot 2>/dev/null || adb reboot
}

usage() {
	cat <<EOF
Usage: $0 [command]

Commands:
  boot        Flash boot image (fastboot)
  anykernel   Flash AnyKernel3 zip (recovery)
  reboot      Reboot to bootloader
  flash-all   Reboot bootloader, flash boot, reboot
  status      Check flash readiness
EOF
	exit 0
}

case "${1:-status}" in
	boot)
		check_root
		local img="$DIST_DIR/boot-${DEVICE_CODENAME}-*.img"
		local resolved
		resolved="$(ls $img 2>/dev/null | head -1 || true)"
		[ -n "$resolved" ] || die "No boot image. Run 'make boot-image' first."
		reboot_bootloader
		flash_boot "$resolved"
		reboot
		;;
	anykernel)
		flash_anykernel
		;;
	reboot)
		reboot_bootloader
		;;
	flash-all)
		check_root
		local img
		img="$(ls "$DIST_DIR"/boot-"$DEVICE_CODENAME"*.img 2>/dev/null | head -1 || true)"
		[ -n "$img" ] || die "No boot image. Run 'make boot-image' first."
		reboot_bootloader
		flash_boot "$img"
		flash_dtbo
		reboot
		;;
	status)
		check_adb 2>/dev/null || {
			fastboot devices 2>/dev/null | grep -q . && die "Device in fastboot. Use flash commands."
			die "Device not connected"
		}
		check_root || true
		say "Status: OK - ready for flash operations"
		;;
	help|--help|-h) usage ;;
	*) die "Unknown: $1";;
esac
