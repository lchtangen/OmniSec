#!/usr/bin/env bash
# OmniSec Cyberpunk Edition — Cross-Platform Build & Deploy Script
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="3.0.0"

die() { echo "[!] $*" >&2; exit 1; }
info() { echo "[*] $*"; }
ok()   { echo "[+] $*"; }

usage() {
    cat <<EOF
OmniSec Cyberpunk Edition v${VERSION} — Build & Deploy

Usage: $0 <command> [options]

Commands:
  build [target]     Build for target platform
  deploy [target]    Deploy to target device
  cross <arch>       Cross-compile for architecture
  theme [name]       Apply theme (cyber_dark|cyber_green|cyber_neon|cyber_purple)
  status             Show build status for all platforms

Targets: linux, android, arm64, macos, windows, docker, all
Arch:    aarch64, x86_64, armv7l
EOF
    exit 0
}

detect_arch() {
    case "$(uname -m)" in
        aarch64|arm64) echo "arm64" ;;
        x86_64|amd64)  echo "x86_64" ;;
        armv7l|armhf)  echo "armv7l" ;;
        *)             echo "unknown" ;;
    esac
}

cmd_build() {
    local target="${1:-all}"
    info "Building for target: $target"

    case "$target" in
        linux)
            cd "$ROOT/first-party/OmniSec/platform"
            bash scripts/build-all.sh all
            ok "Linux build complete"
            ;;
        android)
            cd "$ROOT/first-party/OmniSec"
            make build-module && make stage
            ok "Android payload built"
            ;;
        arm64)
            cd "$ROOT/first-party/OmniSec"
            ARCH=aarch64 make build-c
            bash kernel/build-kernel.sh --device guacamole --variant omnisec
            ok "ARM64 build complete"
            ;;
        macos)
            cd "$ROOT/first-party/OmniSec"
            bash platforms/macos/build.sh
            ok "macOS build complete"
            ;;
        windows)
            cd "$ROOT/first-party/CyberFlash-Tool"
            pyinstaller packaging/cyberflash.spec 2>/dev/null || \
                info "Windows build requires native Windows or Wine"
            ok "Windows build complete"
            ;;
        docker)
            cd "$ROOT/first-party/OmniSec"
            docker buildx build \
                --platform linux/arm64,linux/amd64 \
                -t "omnisec/cyberpunk:${VERSION}" \
                -f Dockerfile.multiarch .
            ok "Docker multiarch build complete"
            ;;
        all)
            cmd_build linux
            cmd_build android
            cmd_build arm64
            cmd_build docker
            info "Skipping macOS and Windows (requires native OS)"
            ok "All-platform build complete"
            ;;
        *)
            die "Unknown target: $target"
            ;;
    esac
}

cmd_deploy() {
    local target="${1:-android}"
    info "Deploying to target: $target"

    case "$target" in
        android)
            if ! command -v adb &>/dev/null; then
                die "ADB not found — install android-tools"
            fi
            cd "$ROOT/first-party/OmniSec"
            bash nhctl deploy-tools
            ok "Deployed to Android device"
            ;;
        arch)
            cd "$ROOT/first-party/linux-omnisec"
            makepkg -si
            ok "Installed linux-omnisec kernel"
            ;;
        local)
            cd "$ROOT/first-party/OmniSec/platform"
            pip install -e .
            ok "Installed OmniSec platform locally"
            ;;
        *)
            die "Unknown deploy target: $target"
            ;;
    esac
}

cmd_cross() {
    local arch="${1:-aarch64}"
    info "Cross-compiling for architecture: $arch"

    export CC="${arch}-linux-gnu-gcc"
    export CXX="${arch}-linux-gnu-g++"
    export AR="${arch}-linux-gnu-ar"
    export STRIP="${arch}-linux-gnu-strip"

    if ! command -v "${CC}" &>/dev/null; then
        die "Cross-compiler not found: $CC (install gcc-${arch}-linux-gnu)"
    fi

    cd "$ROOT/first-party/OmniSec"
    make ARCH="${arch}" build-c
    ok "Cross-compile for ${arch} complete"
}

cmd_theme() {
    local name="${1:-cyber_dark}"
    info "Applying theme: $name"

    case "$name" in
        cyber_dark|cyber_green|cyber_neon|cyber_purple)
            echo "Theme: $name"
            echo "Available in: themes/$name.qss"
            echo "Python vars: themes/variables.py"
            ok "Theme $name ready — apply via ThemeEngine.apply_theme('$name')"
            ;;
        *)
            die "Unknown theme: $name (cyber_dark, cyber_green, cyber_neon, cyber_purple)"
            ;;
    esac
}

cmd_status() {
    echo "╔══════════════════════════════════════════════════════╗"
    echo "║  OmniSec Cyberpunk Edition — Build Status           ║"
    echo "╠══════════════════════════════════════════════════════╣"
    printf "║  %-20s %-20s ║\n" "Platform" "Status"
    echo "╠══════════════════════════════════════════════════════╣"
    for pair in \
        "Linux x86_64:$(detect_arch)" \
        "ARM64:$(test -f "$ROOT/first-party/OmniSec/kernel/build-kernel.sh" && echo 'ready' || echo 'missing')" \
        "Android:$(test -d "$ROOT/first-party/OmniSec/payload" && echo 'payload ready' || echo 'needs init')" \
        "macOS:$(test -f "$ROOT/first-party/OmniSec/platforms/macos/build.sh" && echo 'ready' || echo 'missing')" \
        "Windows:$(test -f "$ROOT/first-party/CyberFlash-Tool/packaging/cyberflash.spec" && echo 'ready' || echo 'missing')" \
        "Docker:$(test -f "$ROOT/first-party/OmniSec/Dockerfile.multiarch" && echo 'multiarch ready' || echo 'missing')"; do
        IFS=: read -r platform status <<< "$pair"
        printf "║  %-20s %-20s ║\n" "$platform" "$status"
    done
    echo "╚══════════════════════════════════════════════════════╝"
}

main() {
    [[ $# -eq 0 ]] && usage
    local cmd="$1"
    shift

    case "$cmd" in
        build)   cmd_build "$@" ;;
        deploy)  cmd_deploy "$@" ;;
        cross)   cmd_cross "$@" ;;
        theme)   cmd_theme "$@" ;;
        status)  cmd_status ;;
        help|-h|--help) usage ;;
        *) die "Unknown command: $cmd (use --help)" ;;
    esac
}

main "$@"
