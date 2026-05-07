#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
KERNEL_DIR="$ROOT_DIR/kernel"
BUILD_DIR="$ROOT_DIR/build/kernel"
SRC_DIR="$KERNEL_DIR/src/guacamole"
OUT_DIR="$BUILD_DIR/out"

DEVICE_CODENAME="guacamole"
DEVICE_NAME="OnePlus 7 Pro GM1911"
KERNEL_VERSION="4.14.356"
TOOLCHAIN="${CROSS_COMPILE:-aarch64-linux-gnu-}"

say() { printf "\033[32m  %s\033[0m\n" "$*"; }
warn() { printf "\033[33m  %s\033[0m\n" "$*"; }
die() { printf "\033[31m  ERROR: %s\033[0m\n" "$*"; exit 1; }

check_toolchain() {
	say "Checking toolchain..."
	if ! command -v "${TOOLCHAIN}gcc" &>/dev/null; then
		die "Toolchain not found. Install: sudo apt install gcc-aarch64-linux-gnu"
	fi
	"${TOOLCHAIN}gcc" --version | head -1
}

check_kernel_source() {
	if [ ! -d "$SRC_DIR" ]; then
		say "Cloning LineageOS kernel source..."
		mkdir -p "$KERNEL_DIR/src"
		git clone --depth=1 \
			https://github.com/LineageOS/android_kernel_oneplus_sm8150.git \
			"$SRC_DIR"
	fi
	say "Kernel source: $SRC_DIR"
	cd "$SRC_DIR"
	git describe --tags --always 2>/dev/null || echo "no tags"
}

apply_defconfig() {
	say "Applying defconfig..."
	mkdir -p "$OUT_DIR"
	if [ -f "$KERNEL_DIR/configs/${DEVICE_CODENAME}_defconfig" ]; then
		cp "$KERNEL_DIR/configs/${DEVICE_CODENAME}_defconfig" \
		   "$SRC_DIR/arch/arm64/configs/"
		make -C "$SRC_DIR" O="$OUT_DIR" \
			ARCH=arm64 CROSS_COMPILE="$TOOLCHAIN" \
			"${DEVICE_CODENAME}_defconfig"
	else
		say "Using LineageOS stock defconfig..."
		cd "$SRC_DIR"
		make O="$OUT_DIR" \
			ARCH=arm64 CROSS_COMPILE="$TOOLCHAIN" \
			lineageos_${DEVICE_CODENAME}_defconfig
	fi
}

build_kernel() {
	say "Building kernel image..."
	make -C "$SRC_DIR" O="$OUT_DIR" \
		ARCH=arm64 CROSS_COMPILE="$TOOLCHAIN" \
		-j"$(nproc)" Image.gz dtbs
	say "Kernel built: $OUT_DIR/arch/arm64/boot/Image.gz"
}

build_modules() {
	say "Building kernel modules..."
	make -C "$SRC_DIR" O="$OUT_DIR" \
		ARCH=arm64 CROSS_COMPILE="$TOOLCHAIN" \
		-j"$(nproc)" modules
	MODULES_DIR="$BUILD_DIR/modules"
	mkdir -p "$MODULES_DIR"
	make -C "$SRC_DIR" O="$OUT_DIR" \
		ARCH=arm64 CROSS_COMPILE="$TOOLCHAIN" \
		INSTALL_MOD_PATH="$MODULES_DIR" \
		modules_install
	say "Modules installed: $MODULES_DIR"
}

add_patches() {
	if ls "$KERNEL_DIR/patches/"*.patch 2>/dev/null; then
		say "Applying patches..."
		cd "$SRC_DIR"
		for p in "$KERNEL_DIR/patches/"*.patch; do
			say "  applying: $(basename "$p")"
			patch -p1 < "$p" || warn "  patch failed (may already be applied)"
		done
	fi
}

usage() {
	cat <<EOF
Usage: $0 [target]

Targets:
  all         Full build: patches, kernel, modules (default)
  kernel      Kernel image only
  modules     Kernel modules only
  clean       Clean build output
  distclean   Clean everything including kernel source
EOF
	exit 0
}

case "${1:-all}" in
	all)
		check_toolchain
		check_kernel_source
		add_patches
		apply_defconfig
		build_kernel
		build_modules
		say "Build complete: $OUT_DIR"
		;;
	kernel)
		check_toolchain
		check_kernel_source
		add_patches
		apply_defconfig
		build_kernel
		;;
	modules)
		check_toolchain
		build_modules
		;;
	clean)
		rm -rf "$BUILD_DIR"
		say "Cleaned: $BUILD_DIR"
		;;
	distclean)
		rm -rf "$BUILD_DIR" "$KERNEL_DIR/src"
		say "Cleaned: build + kernel source"
		;;
	help|--help|-h) usage ;;
	*) die "Unknown target: $1";;
esac
