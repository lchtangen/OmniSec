#!/sbin/sh
# NH_KERNEL_VERSION: 2.0.0
# NetHunter NextGen Kernel Flash Utility — OnePlus 7 Pro (guacamole)
set -e

BOLD=$(tput bold 2>/dev/null || echo "")
GREEN=$(tput setaf 2 2>/dev/null || echo "")
CYAN=$(tput setaf 6 2>/dev/null || echo "")
YELLOW=$(tput setaf 3 2>/dev/null || echo "")
RED=$(tput setaf 1 2>/dev/null || echo "")
RESET=$(tput sgr0 2>/dev/null || echo "")

echo "${CYAN}══════════════════════════════════════════════════════════════${RESET}"
echo "${CYAN}  NetHunter NextGen Kernel Flash Utility${RESET}"
echo "${CYAN}  OnePlus 7 Pro (guacamole) — SM8150${RESET}"
echo "${CYAN}══════════════════════════════════════════════════════════════${RESET}"
echo ""

detect_device() {
	local model=$(getprop ro.product.model 2>/dev/null || echo "unknown")
	local device=$(getprop ro.product.device 2>/dev/null || echo "unknown")
	echo "${GREEN}  Detected:${RESET} $model ($device)"

	case "$device" in
		guacamole|guacamoleb|guacamoleg)
			echo "${GREEN}  Device supported!${RESET}"
			;;
		*)
			echo "${RED}  WARNING: Device not in known supported list!${RESET}"
			echo "  This kernel is built for OnePlus 7 Pro (guacamole)."
			echo "  Flashing on unsupported devices may brick your phone."
			;;
	esac
}

check_connection() {
	echo ""
	echo "${YELLOW}  Checking fastboot connection...${RESET}"
	if command -v fastboot &>/dev/null; then
		fastboot devices 2>/dev/null | head -5
	else
		echo "${RED}  fastboot not found in PATH${RESET}"
	fi
}

method_fastboot() {
	echo ""
	echo "${CYAN}  Method 1: Fastboot Flash${RESET}"
	echo ""
	echo "  Requirements:"
	echo "    - Unlocked bootloader"
	echo "    - Device in fastboot mode (Volume Down + Power)"
	echo "    - fastboot command in PATH"
	echo ""
	echo "  Commands:"
	echo "    ${YELLOW}fastboot flash boot boot/boot-${1}-${2}.img${RESET}"
	echo "    ${YELLOW}fastboot flash dtbo dtbo/dtbo-${1}-${2}.img${RESET}"
	echo "    ${YELLOW}fastboot reboot${RESET}"
}

method_recovery() {
	echo ""
	echo "${CYAN}  Method 2: Recovery (AnyKernel3)${RESET}"
	echo ""
	echo "  Requirements:"
	echo "    - Custom recovery (TWRP/LineageOS Recovery)"
	echo "    - anykernel3 zip file"
	echo ""
	echo "  Steps:"
	echo "    1. Boot into recovery"
	echo "    2. Select 'Install' / 'Apply Update'"
	echo "    3. Choose the AnyKernel3 zip"
	echo "    4. Flash and reboot"
}

method_magisk() {
	echo ""
	echo "${CYAN}  Method 3: Magisk (Recommended for root)${RESET}"
	echo ""
	echo "  Requirements:"
	echo "    - Magisk installed"
	echo "    - Stock boot.img for your current ROM"
	echo ""
	echo "  Steps:"
	echo "    1. ${YELLOW}adb push boot.img /sdcard/Download/${RESET}"
	echo "    2. Open Magisk app → Install → Select and Patch a File"
	echo "    3. Choose boot.img"
	echo "    4. ${YELLOW}adb pull /sdcard/Download/magisk_patched-XXXXX.img${RESET}"
	echo "    5. ${YELLOW}fastboot flash boot magisk_patched-XXXXX.img${RESET}"
	echo "    6. ${YELLOW}fastboot reboot${RESET}"
	echo ""
	echo "  To use this custom kernel with Magisk:"
	echo "    1. Extract Image.gz from this package"
	echo "    2. Replace Image.gz inside stock boot.img"
	echo "    3. Use Magisk to patch the modified boot.img"
	echo "    4. Flash the patched boot.img"
}

method_fastboot_direct() {
	echo ""
	echo "${CYAN}  Method 4: Direct Fastboot Boot (No Flash)${RESET}"
	echo ""
	echo "  Test the kernel without flashing:"
	echo "    ${YELLOW}fastboot boot boot/boot-${1}-${2}.img${RESET}"
	echo ""
	echo "  This loads the kernel temporarily. Reboot to restore original."
}

verify_installation() {
	echo ""
	echo "${YELLOW}  Verification${RESET}"
	echo "  After flashing, verify with:"
	echo "    ${GREEN}adb shell uname -r${RESET}"
	echo "    ${GREEN}adb shell cat /proc/version${RESET}"
	echo "    ${GREEN}adb shell getprop ro.kernel.version${RESET} (Android 16+)"
}

# ── Main ───────────────────────────────────────────────────────────
detect_device
check_connection

VARIANT="${1:-nethunter}"
DEVICE="guacamole"

method_fastboot "$DEVICE" "$VARIANT"
method_recovery
method_magisk
method_fastboot_direct "$DEVICE" "$VARIANT"
verify_installation

echo ""
echo "${GREEN}══════════════════════════════════════════════════════════════${RESET}"
echo "${GREEN}  Flash guide complete. Choose a method above.${RESET}"
echo "${GREEN}══════════════════════════════════════════════════════════════${RESET}"
