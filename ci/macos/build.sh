#!/bin/bash
# OmniSec — macOS Build Script
# Supports both Apple Silicon (arm64) and Intel (x86_64)

set -euo pipefail

ARCH="$(uname -m)"
info()  { echo "[OmniSec] $*"; }
err()   { echo "[Error] $*" >&2; exit 1; }

check_homebrew() {
    if ! command -v brew &>/dev/null; then
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
}

install_deps() {
    info "Installing dependencies for macOS ($ARCH)..."
    check_homebrew

    brew install bash git make gcc python3 openssl nmap curl wget
}

build_omnisec() {
    info "Building OmniSec for macOS ($ARCH)..."

    # Clone if needed
    if [ ! -d omnisec ]; then
        git clone https://github.com/lchtangen/OmniSec.git omnisec
    fi

    cd omnisec

    # Stage build
    make stage

    # Build C tools
    make build-c

    info "Build complete!"
}

install_omnisec() {
    info "Installing to system..."
    cd omnisec

    # Install with Homebrew
    if [ -d "$(brew --prefix)/Cellar/omnisec" ]; then
        brew reinstall ./homebrew/omnisec.rb
    else
        brew install --HEAD ./homebrew/omnisec.rb
    fi

    info "Installed! Run: nhctl help"
}

create_release() {
    info "Creating macOS release package..."
    cd omnisec

    # Create .tar.gz
    tar -czf "omnisec-macos-${ARCH}-3.0.tar.gz" -C payload/ .
    info "Created: omnisec-macos-${ARCH}-3.0.tar.gz"
}

case "${1:-build}" in
    deps)      install_deps ;;
    build)     install_deps && build_omnisec ;;
    install)   install_omnisec ;;
    release)   install_deps && build_omnisec && create_release ;;
    help|*)
        echo "Usage: $0 [deps|build|install|release]"
        echo "Example: $0 build"
        echo "Example: $0 install"
        ;;
esac
