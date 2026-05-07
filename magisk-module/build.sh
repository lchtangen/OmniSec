#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MODULE_DIR="$ROOT_DIR/magisk-module"
DIST_DIR="$MODULE_DIR/dist"
BUILD_DIR="$ROOT_DIR/build"

NH_VERSION="2.0.0"
MODULE_ZIP="nethunter-setup-v${NH_VERSION}.zip"

echo "--- Building Magisk module ---"

mkdir -p "$DIST_DIR"
WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

echo "  staging files..."

cp "$MODULE_DIR/module.prop" "$WORKDIR/"
cp "$MODULE_DIR/customize.sh" "$WORKDIR/"
[ -f "$MODULE_DIR/uninstall.sh" ] && cp "$MODULE_DIR/uninstall.sh" "$WORKDIR/"
[ -f "$MODULE_DIR/service.sh" ] && cp "$MODULE_DIR/service.sh" "$WORKDIR/"

mkdir -p "$WORKDIR/nhsystem-bin"
for f in "$ROOT_DIR"/payload/nhsystem-bin/nh-*; do
	[ -f "$f" ] && cp "$f" "$WORKDIR/nhsystem-bin/"
done

mkdir -p "$WORKDIR/system/lib64"
if [ -f "$BUILD_DIR/no-close-range.so" ]; then
	cp "$BUILD_DIR/no-close-range.so" "$WORKDIR/system/lib64/"
else
	echo "  WARNING: no-close-range.so not built, using source copy"
	cp "$ROOT_DIR/payload/no-close-range.c" "$WORKDIR/system/lib64/"
fi

if [ -f "$BUILD_DIR/nh-sudo" ]; then
	mkdir -p "$WORKDIR/system/bin"
	cp "$BUILD_DIR/nh-sudo" "$WORKDIR/system/bin/"
fi

echo "  creating module zip..."

cd "$WORKDIR"
find . -type f | sort | while read -r f; do
	echo "    $f"
done

zip -r "$DIST_DIR/$MODULE_ZIP" . > /dev/null 2>&1
cd "$ROOT_DIR"

echo "  module: $DIST_DIR/$MODULE_ZIP"
ls -lh "$DIST_DIR/$MODULE_ZIP"
echo "  done"
