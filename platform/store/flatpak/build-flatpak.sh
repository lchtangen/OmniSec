#!/usr/bin/env bash
set -euo pipefail

APP_ID="io.omnisec.OmniSec"
VERSION="${VERSION:-3.0.0}"
FLATPAK_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$FLATPAK_DIR/../.." && pwd)"
OUTPUT_DIR="${PROJECT_DIR}/dist"

echo "=== Building Flatpak: $APP_ID v$VERSION ==="

mkdir -p "$OUTPUT_DIR"

# Check prerequisites
command -v flatpak-builder >/dev/null 2>&1 || { echo "Error: flatpak-builder not found"; exit 1; }
flatpak info org.kde.Platform//6.6 >/dev/null 2>&1 || {
    echo "Adding Flathub remote and installing SDK..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak install -y flathub org.kde.Platform//6.6 org.kde.Sdk//6.6
}

# Create build directory
BUILD_DIR=$(mktemp -d)
trap 'rm -rf "$BUILD_DIR"' EXIT

# Copy project to build directory
echo "[*] Copying project to build dir..."
cp -r "$PROJECT_DIR" "$BUILD_DIR/omnisec"
rm -rf "$BUILD_DIR/omnisec/dist" "$BUILD_DIR/omnisec/__pycache__" "$BUILD_DIR/omnisec/.git"

# Patch manifest source path to point to our copy
MANIFEST="$BUILD_DIR/manifest.yml"
cp "$FLATPAK_DIR/$APP_ID.yml" "$MANIFEST"
sed -i "s|path: /app/build/omnisec|path: $BUILD_DIR/omnisec|" "$MANIFEST"
sed -i "s|type: dir|type: dir\n        path: $BUILD_DIR/omnisec|" "$MANIFEST"

# Build Flatpak
echo "[*] Running flatpak-builder..."
flatpak-builder \
    --force-clean \
    --ccache \
    --repo="$OUTPUT_DIR/flatpak-repo" \
    --subject="OmniSec ULTIMATE v$VERSION" \
    "$BUILD_DIR/build" \
    "$MANIFEST"

# Generate single-file bundle
echo "[*] Creating Flatpak bundle..."
flatpak build-bundle \
    "$OUTPUT_DIR/flatpak-repo" \
    "$OUTPUT_DIR/omnisec-ultimate-${VERSION}.flatpak" \
    "$APP_ID"

echo "[+] Flatpak bundle: $OUTPUT_DIR/omnisec-ultimate-${VERSION}.flatpak"
echo "[+] Repository: $OUTPUT_DIR/flatpak-repo/"
echo "[*] Install with: flatpak install --user omnisec-ultimate-${VERSION}.flatpak"
