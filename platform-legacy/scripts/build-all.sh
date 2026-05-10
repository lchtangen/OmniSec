#!/usr/bin/env bash
set -euo pipefail
VERSION="${VERSION:-3.0.0}"
DIST="$(pwd)/dist"
echo "=== OmniSec ULTIMATE Build v$VERSION ==="

mkdir -p "$DIST"

build_python_wheel() {
    echo "[*] Building Python wheel..."
    pip install build
    python -m build --wheel --outdir "$DIST"
    echo "[+] Wheel: $DIST/omnisec_ultimate-${VERSION}-*.whl"
}

build_appimage() {
    echo "[*] Building AppImage..."
    which appimagetool >/dev/null || { echo "Need appimagetool"; return; }
    local appdir="$DIST/OmniSec-$VERSION.AppDir"
    mkdir -p "$appdir/usr/bin" "$appdir/usr/share/applications"
    cp desktop/resources/omnisec.desktop "$appdir/"
    cp -r gui "$appdir/usr/lib/omnisec"
    cat > "$appdir/AppRun" << 'EOF'
#!/bin/bash
exec python3 /usr/lib/omnisec/omnisec-gui.py "$@"
EOF
    chmod +x "$appdir/AppRun"
    appimagetool "$appdir" "$DIST/OmniSec-$VERSION-x86_64.AppImage"
    echo "[+] AppImage: $DIST/OmniSec-$VERSION-x86_64.AppImage"
}

build_deb() {
    echo "[*] Building .deb package..."
    local deb_dir="$DIST/omnisec_$VERSION"
    mkdir -p "$deb_dir/DEBIAN"
    mkdir -p "$deb_dir/usr/bin"
    mkdir -p "$deb_dir/usr/share/omnisec"
    mkdir -p "$deb_dir/usr/share/applications"

    cat > "$deb_dir/DEBIAN/control" << EOF
Package: omnisec-ultimate
Version: $VERSION
Section: utils
Priority: optional
Architecture: all
Depends: python3, python3-pip, python3-pyqt6
Maintainer: OmniSec Team <team@omnisec.io>
Description: AI-native, offline-only cybersecurity platform
 161 security tools, AI copilot, post-quantum crypto.
 Homepage: https://omnisec.io
EOF
    cp -r gui "$deb_dir/usr/share/omnisec/"
    cp desktop/resources/omnisec.desktop "$deb_dir/usr/share/applications/"
    echo '#!/bin/bash' > "$deb_dir/usr/bin/omnisec"
    echo 'exec python3 /usr/share/omnisec/gui/main.py "$@"' >> "$deb_dir/usr/bin/omnisec"
    chmod +x "$deb_dir/usr/bin/omnisec"
    dpkg-deb --build "$deb_dir" "$DIST/omnisec-ultimate_${VERSION}_all.deb"
    echo "[+] .deb: $DIST/omnisec-ultimate_${VERSION}_all.deb"
}

build_snap() {
    echo "[*] Building Snap package..."
    which snapcraft >/dev/null || { echo "Need snapcraft"; return; }
    cp store/snap/snapcraft.yaml .
    snapcraft --output "$DIST/omnisec-ultimate_${VERSION}_amd64.snap"
    echo "[+] Snap: $DIST/omnisec-ultimate_${VERSION}_amd64.snap"
}

build_flatpak() {
    echo "[*] Building Flatpak..."
    which flatpak-builder >/dev/null || { echo "Need flatpak-builder"; return; }
    bash store/flatpak/build-flatpak.sh
    echo "[+] Flatpak: $DIST/omnisec-ultimate-${VERSION}.flatpak"
}

generate_sbom() {
    echo "[*] Generating SBOM (CycloneDX)..."
    pip install cyclonedx-bom
    cyclonedx-py -e --output "$DIST/omnisec-sbom-${VERSION}.cdx.json"
    echo "[+] SBOM: $DIST/omnisec-sbom-${VERSION}.cdx.json"
}

case "${1:-all}" in
    wheel)    build_python_wheel ;;
    appimage) build_appimage ;;
    deb)      build_deb ;;
    snap)     build_snap ;;
    flatpak)  build_flatpak ;;
    sbom)     generate_sbom ;;
    all)
        build_python_wheel
        build_deb
        build_appimage
        build_snap
        build_flatpak
        generate_sbom
        echo "=== ALL BUILDS COMPLETE ==="
        ls -lh "$DIST/"
        ;;
    *)
        echo "Usage: $0 {wheel|appimage|deb|snap|flatpak|sbom|all}"
        exit 1
        ;;
esac
