#!/bin/bash
# Aegis Nexus — One-Line Installer
# Usage: curl -sSL https://aegis-nexus.org/install | bash

set -euo pipefail

AEGIS_VERSION="3.0"
AEGIS_REPO="https://github.com/AegisNexus/aegis-nexus.git"
INSTALL_DIR="$HOME/.aegis-nexus"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[Aegis Nexus]${NC} $*"; }
warn()  { echo -e "${YELLOW}[Warning]${NC} $*"; }
err()   { echo -e "${RED}[Error]${NC} $*"; exit 1; }

echo ""
echo "╔════════════════════════════════════════════╗"
echo "║   🛡️  Aegis Nexus v${AEGIS_VERSION} Installer     ║"
echo "║   The Next-Gen Mobile Security Platform  ║"
echo "╚════════════════════════════════════════════╝"
echo ""

info "Starting installation..."

# Detect platform
OS=""
ARCH=""
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    ARCH=$(uname -m)
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    ARCH=$(uname -m)
elif [[ "$OSTYPE" == "android"* ]]; then
    OS="android"
    ARCH="arm64"
else
    warn "Unknown OS: $OSTYPE — attempting Linux install"
    OS="linux"
    ARCH="x86_64"
fi

info "Detected: $OS ($ARCH)"

# Check dependencies
info "Checking dependencies..."
missing_deps=()
for cmd in git make bash; do
    if ! command -v $cmd &>/dev/null; then
        missing_deps+=($cmd)
    fi
done

if [ ${#missing_deps[@]} -gt 0 ]; then
    err "Missing dependencies: ${missing_deps[*]}. Please install them first."
fi

# Clone or update repository
if [ -d "$INSTALL_DIR" ]; then
    info "Updating existing installation..."
    cd "$INSTALL_DIR"
    git pull origin main
else
    info "Cloning Aegis Nexus..."
    git clone "$AEGIS_REPO" "$INSTALL_DIR"
    cd "$INSTALL_DIR"
fi

# Run setup based on platform
info "Running platform-specific setup..."
case "$OS" in
    android)
        info "Setting up for Android..."
        make stage
        info "Done! Run: nhctl help"
        ;;
    linux)
        if [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
            info "Setting up for Linux ARM64..."
            make stage
        else
            info "Setting up for Linux x86_64..."
            make stage
        fi
        sudo make install
        info "Done! Run: nhctl help"
        ;;
    macos)
        info "Setting up for macOS..."
        make stage
        info "Done! Run: nhctl help"
        ;;
esac

echo ""
echo "╔════════════════════════════════════════════╗"
echo "║  ✅ Installation Complete!                   ║"
echo "║                                          ║"
echo "║  Run: nhctl help                       ║"
echo "║  Docs: https://aegis-nexus.org/docs      ║"
echo "║  Community: https://discord.gg/aegis-nexus ║"
echo "╚════════════════════════════════════════════╝"
echo ""
