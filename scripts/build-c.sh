#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SRC_DIR="$ROOT_DIR/src/c"
BUILD_DIR="$ROOT_DIR/build"
CROSS_COMPILE="${CROSS_COMPILE:-}"
CC="${CROSS_COMPILE}${CC:-gcc}"
CFLAGS="-Wall -Wextra -pedantic -Os"

mkdir -p "$BUILD_DIR"

build_nh_sudo() {
	echo "  building nh-sudo (static)..."
	$CC $CFLAGS -o "$BUILD_DIR/nh-sudo" "$SRC_DIR/nh-sudo.c" -static -s
	file "$BUILD_DIR/nh-sudo"
}

build_no_close_range() {
	echo "  building no-close-range.so (shared)..."
	$CC $CFLAGS -shared -fPIC -o "$BUILD_DIR/no-close-range.so" "$SRC_DIR/no-close-range.c" -nostartfiles
	file "$BUILD_DIR/no-close-range.so"
}

build_all() {
	build_nh_sudo
	build_no_close_range
	echo ""
	echo "  Build artifacts in: $BUILD_DIR"
	ls -lh "$BUILD_DIR"
}

case "${1:-all}" in
	sudo) build_nh_sudo ;;
	noclose) build_no_close_range ;;
	all|*) build_all ;;
esac
