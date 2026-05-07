#!/usr/bin/env bash
# NH_KERNEL_VERSION: 2.0.0
# Automated toolchain setup for kernel development
set -euo pipefail

KERNEL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TOOLCHAIN_DIR="$KERNEL_DIR/toolchain"

say() { printf "\033[32m  %s\033[0m\n" "$*"; }
warn() { printf "\033[33m  %s\033[0m\n" "$*"; }
die() { printf "\033[31m  ERROR: %s\033[0m\n" "$*"; exit 1; }

detect_distro() {
	if command -v apt &>/dev/null; then
		echo "debian"
	elif command -v pacman &>/dev/null; then
		echo "arch"
	elif command -v dnf &>/dev/null; then
		echo "fedora"
	else
		echo "unknown"
	fi
}

install_system_toolchain() {
	local distro=$(detect_distro)
	say "Detected distro: $distro"

	case "$distro" in
		debian|ubuntu)
			say "Installing Debian/Ubuntu toolchain..."
			sudo apt update
			sudo apt install -y \
				gcc-aarch64-linux-gnu \
				binutils-aarch64-linux-gnu \
				cpio \
				build-essential \
				bc \
				bison \
				flex \
				libssl-dev \
				libelf-dev \
				device-tree-compiler \
				git \
				curl \
				wget \
				unzip \
				zip
			;;
		arch)
			say "Installing Arch toolchain..."
			sudo pacman -S --needed \
				aarch64-linux-gnu-gcc \
				aarch64-linux-gnu-binutils \
				cpio \
				base-devel \
				bc \
				bison \
				flex \
				openssl \
				dtc \
				git \
				curl \
				wget \
				unzip \
				zip
			;;
		fedora)
			say "Installing Fedora toolchain..."
			sudo dnf install -y \
				gcc-aarch64-linux-gnu \
				binutils-aarch64-linux-gnu \
				cpio \
				make \
				automake \
				gcc \
				gcc-c++ \
				kernel-devel \
				bc \
				bison \
				flex \
				openssl-devel \
				dtc \
				git \
				curl \
				wget \
				unzip \
				zip
			;;
		*)
			warn "Unknown distro. Please install manually:"
			warn "  sudo apt install gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu"
			;;
	esac
}

install_ndk_toolchain() {
	local ndk_ver="r27"
	local ndk_url="https://dl.google.com/android/repository/android-ndk-${ndk_ver}-linux.zip"
	local ndk_zip="$TOOLCHAIN_DIR/android-ndk-${ndk_ver}-linux.zip"
	local ndk_dir="$TOOLCHAIN_DIR/android-ndk-${ndk_ver}"

	mkdir -p "$TOOLCHAIN_DIR"

	if [ ! -f "$ndk_zip" ]; then
		say "Downloading Android NDK ${ndk_ver}..."
		wget -O "$ndk_zip" "$ndk_url" 2>/dev/null || curl -Lo "$ndk_zip" "$ndk_url" || {
			warn "Download failed. Trying mirror..."
			wget -O "$ndk_zip" "https://dl.google.com/android/repository/android-ndk-${ndk_ver}-linux.zip" || {
				die "Cannot download NDK. Check internet connection."
			}
		}
	fi

	if [ ! -d "$ndk_dir" ]; then
		say "Extracting NDK (this may take a while)..."
		unzip -q "$ndk_zip" -d "$TOOLCHAIN_DIR"
	fi

	local tc_dir="$ndk_dir/toolchains/llvm/prebuilt/linux-x86_64"
	if [ -d "$tc_dir" ]; then
		say "NDK toolchain ready at: $tc_dir"
		export PATH="$tc_dir/bin:$PATH"
		cat >> "$HOME/.bashrc" <<EOF
# NetHunter NDK toolchain
export PATH="$tc_dir/bin:\$PATH"
export CROSS_COMPILE=aarch64-linux-android-
EOF
		say "Added NDK to ~/.bashrc (CROSS_COMPILE set)"
	else
		die "NDK extraction incomplete: missing $tc_dir"
	fi
}

verify_toolchain() {
	say "Verifying toolchain..."
	local found=false

	if command -v aarch64-linux-gnu-gcc &>/dev/null; then
		say "System toolchain: $(aarch64-linux-gnu-gcc --version | head -1)"
		found=true
	fi

	if command -v aarch64-linux-android-gcc &>/dev/null || \
	   command -v aarch64-linux-android21-clang &>/dev/null; then
		say "NDK toolchain: $(aarch64-linux-android21-clang --version 2>/dev/null | head -1 || echo present)"
		found=true
	fi

	if [ -n "${CROSS_COMPILE:-}" ]; then
		say "CROSS_COMPILE set to: $CROSS_COMPILE"
	fi

	$found || die "No toolchain found. Run: $0 --install"
	say "Toolchain verification complete"
}

usage() {
	cat <<EOF
NetHunter NextGen Toolchain Setup

Usage: $0 [options]

Options:
  --system      Install system toolchain (apt/pacman/dnf)
  --ndk         Install Android NDK toolchain
  --all         Install both system + NDK toolchains
  --verify      Verify installed toolchains
  --help        Show this message
EOF
	exit 0
}

# ── Main ───────────────────────────────────────────────────────────
case "${1:---verify}" in
	--system|system)
		install_system_toolchain
		verify_toolchain
		;;
	--ndk|ndk)
		install_ndk_toolchain
		verify_toolchain
		;;
	--all|all)
		install_system_toolchain
		install_ndk_toolchain
		verify_toolchain
		;;
	--verify|verify)
		verify_toolchain
		;;
	--help|help|-h)
		usage
		;;
	*)
		die "Unknown option: $1"
		;;
esac
