#!/usr/bin/env bash
# NH_KERNEL_VERSION: 2.0.0
# Device-specific build — OnePlus 7 Pro (guacamole) SM8150
set -euo pipefail

DEVICE="guacamole"
DEVICE_NAME="OnePlus 7 Pro GM1911"
SOC="sm8150"
BOARD="qcom"
DTB_PATH="arch/arm64/boot/dts/qcom"

VARIANT="${1:-stable}"
BUILD_DIR="${2:-}"
[ -n "$BUILD_DIR" ] || { echo "Usage: $0 <variant> <build_dir>"; exit 1; }

OUT_DIR="$BUILD_DIR/out"
PKG_DIR="$BUILD_DIR/package"
mkdir -p "$PKG_DIR"

echo "  device-specific: $DEVICE_NAME ($DEVICE)"

# ├─ Generate device-specific boot image ─────────────────────────────────────
generate_boot_img() {
	local kernel_img="$OUT_DIR/$DTB_PATH/Image.gz"
	local dtb_file="$OUT_DIR/$DTB_PATH/sm8150.dtb"
	local dtbo_dir="$OUT_DIR/$DTB_PATH"

	if [ -f "$kernel_img" ] && command -v mkbootimg &>/dev/null; then
		mkdir -p "$PKG_DIR/boot"

		# Gather DTBOs
		local dtbo_args=""
		for dtbo in "$dtbo_dir"/*.dtbo; do
			[ -f "$dtbo" ] && dtbo_args="$dtbo_args --dtb $dtbo"
		done

		mkbootimg \
			--kernel "$kernel_img" \
			${dtb_file:+--dtb "$dtb_file"} \
			--base 0x80000000 \
			--pagesize 4096 \
			--kernel_offset 0x00008000 \
			--ramdisk_offset 0x01000000 \
			--tags_offset 0x00000100 \
			--os_version "16.0.0" \
			--os_patch_level 2026-05 \
			--header_version 2 \
			-o "$PKG_DIR/boot/boot-${DEVICE}-${VARIANT}-v2.0.0.img" 2>&1 || {
				echo "  warning: mkbootimg failed (continue anyway)"
			}

		echo "  boot image: $PKG_DIR/boot/boot-${DEVICE}-${VARIANT}.img"
	fi
}

# ├─ Generate DTB overlay ────────────────────────────────────────────────────
generate_dtbo() {
	local dtbo_dir="$OUT_DIR/$DTB_PATH"
	local dtbo_img="$PKG_DIR/dtbo/dtbo-${DEVICE}-${VARIANT}.img"

	if command -v mkdtboimg &>/dev/null && ls "$dtbo_dir"/*.dtbo &>/dev/null 2>&1; then
		mkdir -p "$PKG_DIR/dtbo"
		mkdtboimg create "$dtbo_img" "$dtbo_dir"/*.dtbo 2>/dev/null || {
			# Fallback: just copy dtbo files
			cp "$dtbo_dir"/*.dtbo "$PKG_DIR/dtbo/" 2>/dev/null || true
		}
		echo "  dtbo package: $PKG_DIR/dtbo/"
	fi
}

# ├─ Generate vendor_boot (for A/B devices) ──────────────────────────────────
generate_vendor_boot() {
	local kernel_img="$OUT_DIR/$DTB_PATH/Image.gz"
	local dtb_file="$OUT_DIR/$DTB_PATH/sm8150.dtb"

	if [ -f "$kernel_img" ] && command -v mkbootimg &>/dev/null; then
		# vendor_boot for Android 16+ with vendor_boot partition
		mkbootimg \
			--kernel "$kernel_img" \
			${dtb_file:+--dtb "$dtb_file"} \
			--base 0x80000000 \
			--pagesize 4096 \
			--vendor_cmdline "console=ttyMSM0,115200n8 earlycon=msm_geni_serial,0xa90000 androidboot.hardware=qcom androidboot.console=ttyMSM0" \
			--os_version "16.0.0" \
			--os_patch_level 2026-05 \
			--header_version 3 \
			-o "$PKG_DIR/boot/vendor_boot-${DEVICE}-${VARIANT}.img" 2>/dev/null || {
				echo "  warning: vendor_boot not created (A-only device)"
			}
	fi
}

# ├─ Verify kernel compatibility ─────────────────────────────────────────────
verify_kernel() {
	local kernel_img="$OUT_DIR/$DTB_PATH/Image.gz"
	if [ -f "$kernel_img" ]; then
		local size=$(stat -c%s "$kernel_img" 2>/dev/null || stat -f%z "$kernel_img" 2>/dev/null)
		local size_kb=$((size / 1024))
		echo "  kernel size: ${size_kb}KB"
		if [ "$size_kb" -lt 1000 ]; then
			echo "  warning: kernel seems too small (${size_kb}KB)"
		fi
		if [ "$size_kb" -gt 30000 ]; then
			echo "  warning: kernel seems too large (${size_kb}KB)"
		fi
		gzip -t "$kernel_img" 2>/dev/null && echo "  kernel: valid gzip" || echo "  kernel: not gzip compressed"
	fi
}

# Execute
generate_boot_img
generate_dtbo
generate_vendor_boot
verify_kernel

echo "  device-specific build complete"
