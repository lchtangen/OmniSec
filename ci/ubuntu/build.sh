#!/bin/bash
# OmniSec — Ubuntu/Debian Build Script
# Builds for both ARM64 and x86_64

set -euo pipefail

ARCH="${1:-$(uname -m)}"
DISTRO="${2:-ubuntu}"
VERSION="${3:-24.04}"

info()  { echo "[OmniSec] $*"; }
err()   { echo "[Error] $*" >&2; exit 1; }

PKGS_UBUNTU="bash git make gcc python3 openssl nmap curl wget tcpdump"
PKGS_DEBIAN="bash git make gcc python3 openssl nmap curl wget tcpdump"

install_deps() {
    info "Installing dependencies for $DISTRO $VERSION ($ARCH)..."
    case "$DISTRO" in
        ubuntu|debian)
            sudo apt-get update
            sudo apt-get install -y $PKGS_UBUNTU
            ;;
        *)
            err "Unknown distro: $DISTRO"
            ;;
    esac
}

build_omnisec() {
    info "Building OmniSec for $ARCH..."

    # Clone if needed
    if [ ! -d omnisec ]; then
        git clone https://github.com/lchtangen/OmniSec.git omnisec
    fi

    cd omnisec

    # Stage build
    make stage

    # Build C tools with architecture-specific flags
    case "$ARCH" in
        aarch64|arm64)
            export CC="aarch64-linux-gnu-gcc"
            ;;
        x86_64)
            export CC="gcc"
            ;;
    esac

    make build-c

    info "Build complete!"
}

install_omnisec() {
    info "Installing to system..."
    cd omnisec
    sudo make install
    info "Installed! Run: nhctl help"
}

create_deb_package() {
    info "Creating .deb package..."
    cd omnisec

    # Create DEB structure
    mkdir -p deb-build/omnisec_3.0/DEBIAN

    # Control file
    cat > deb-build/omnisec_3.0/DEBIAN/control <<EOF
Package: omnisec
Version: 3.0
Section: security
Priority: optional
Architecture: ${ARCH}
Depends: bash, git, make, gcc, python3, openssl, nmap
Maintainer: OmniSec Team <lchtangen@gmail.com>
Description: Next-Generation Mobile Security Platform
 OmniSec brings enterprise-grade security to mobile devices
 with on-device AI, mesh networking, eBPF kernel defense,
 post-quantum cryptography, and hardware security modules.
EOF

    # Install files
    mkdir -p deb-build/omnisec_3.0/usr/local/bin
    cp -a payload/nhsystem-bin/* deb-build/omnisec_3.0/usr/local/bin/
    cp payload/nhsystem-bin/nh-ebpf deb-build/omnisec_3.0/usr/local/bin/ 2>/dev/null || true

    # Build package
    dpkg-deb --build deb-build/omnisec_3.0
    info "Created: deb-build/omnisec_3.0.deb"
}

case "${1:-build}" in
    deps)      install_deps ;;
    build)     install_deps && build_omnisec ;;
    install)   install_omnisec ;;
    deb)       install_deps && build_omnisec && create_deb_package ;;
    help|*)
        echo "Usage: $0 [deps|build|install|deb] [ubuntu|debian] [version]"
        echo "Example: $0 build ubuntu 24.04"
        echo "Example: $0 deb debian 12"
        ;;
esac
