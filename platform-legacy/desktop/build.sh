#!/bin/bash
# OmniSec ULTIMATE — Desktop Build Script
set -e

VERSION="3.0.0"
BUILD_DIR="build"
DIST_DIR="dist"

echo "=== OmniSec ULTIMATE Desktop Build ==="
echo "Version: $VERSION"
echo ""

# Clean
rm -rf "$BUILD_DIR" "$DIST_DIR"
mkdir -p "$BUILD_DIR" "$DIST_DIR"

# Build Python package
echo "[1/4] Building Python package..."
python3 setup.py sdist bdist_wheel

# Build AppImage (Linux)
echo "[2/4] Building AppImage..."
if command -v appimagetool &> /dev/null; then
    mkdir -p "$BUILD_DIR/AppDir/usr/bin"
    cp -r omnisec_desktop "$BUILD_DIR/AppDir/usr/"
    cp resources/omnisec.desktop "$BUILD_DIR/AppDir/"
    appimagetool "$BUILD_DIR/AppDir" "$DIST_DIR/OmniSec-$VERSION-x86_64.AppImage"
    echo "  AppImage created"
else
    echo "  Skipping AppImage (appimagetool not installed)"
fi

# Build .deb (Linux)
echo "[3/4] Building .deb..."
if command -v dpkg-deb &> /dev/null; then
    DEB_DIR="$BUILD_DIR/omnisec-$VERSION"
    mkdir -p "$DEB_DIR/DEBIAN"
    mkdir -p "$DEB_DIR/usr/bin"
    mkdir -p "$DEB_DIR/usr/share/applications"
    mkdir -p "$DEB_DIR/usr/share/omnisec"

    cat > "$DEB_DIR/DEBIAN/control" << EOF
Package: omnisec-ultimate
Version: $VERSION
Section: security
Priority: optional
Architecture: all
Depends: python3, python3-pyqt6
Maintainer: OmniSec Team <team@omnisec.io>
Description: OmniSec ULTIMATE — Cyberpunk 2077 Security Platform
 161 tools, AI Copilot, Offline-Only, Post-Quantum Crypto.
 The world's first AI-native cybersecurity platform.
EOF

    cp -r omnisec_desktop "$DEB_DIR/usr/share/omnisec/"
    echo '#!/bin/bash
exec python3 /usr/share/omnisec/omnisec_desktop/main.py gui' > "$DEB_DIR/usr/bin/omnisec"
    chmod +x "$DEB_DIR/usr/bin/omnisec"
    cp resources/omnisec.desktop "$DEB_DIR/usr/share/applications/"

    dpkg-deb --build "$DEB_DIR" "$DIST_DIR/omnisec-ultimate-$VERSION.deb"
    echo "  .deb package created"
else
    echo "  Skipping .deb (dpkg-deb not installed)"
fi

# Build macOS .dmg (placeholder)
echo "[4/4] Build artifacts:"
ls -la "$DIST_DIR/" 2>/dev/null || echo "  No artifacts (build tools missing)"

echo ""
echo "=== Build Complete ==="
