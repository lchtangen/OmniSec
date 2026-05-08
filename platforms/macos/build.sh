#!/bin/bash
# Aegis Nexus — macOS Build Script
# Supports both Apple Silicon (arm64) and Intel (x86_64)

set -euo pipefail

ARCH="$(uname -m)"
info()  { echo "[Aegis] $*"; }
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

build_aegis() {
    info "Building Aegis Nexus for macOS ($ARCH)..."
    
    # Clone if needed
    if [ ! -d aegis-nexus ]; then
        git clone https://github.com/AegisNexus/aegis-nexus.git
    fi
    
    cd aegis-nexus
    
    # Stage build
    make stage
    
    # Build C tools
    make build-c
    
    info "Build complete!"
}

install_aegis() {
    info "Installing to system..."
    cd aegis-nexus
    
    # Install with Homebrew
    if [ -d "$(brew --prefix)/Cellar/aegis-nexus" ]; then
        brew reinstall ./homebrew/aegis-nexus.rb
    else
        brew install --HEAD ./homebrew/aegis-nexus.rb
    fi
    
    info "Installed! Run: nhctl help"
}

create_release() {
    info "Creating macOS release package..."
    cd aegis-nexus
    
    # Create .tar.gz
    tar -czf "aegis-nexus-macos-${ARCH}-3.0.tar.gz" -C payload/ .
    info "Created: aegis-nexus-macos-${ARCH}-3.0.tar.gz"
}

case "${1:-build}" in
    deps)      install_deps ;;
    build)     install_deps && build_aegis ;;
    install)   install_aegis ;;
    release)   install_deps && build_aegis && create_release ;;
    help|*)
        echo "Usage: $0 [deps|build|install|release]"
        echo "Example: $0 build"
        echo "Example: $0 install"
        ;;
esac
