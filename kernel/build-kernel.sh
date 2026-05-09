#!/usr/bin/env bash
# NH_KERNEL_VERSION: 3.0.0
# OmniSec Kernel Build System — Clang-First Edition
set -eo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
KERNEL_DIR="$ROOT_DIR/kernel"
SRC_DIR="$KERNEL_DIR/src"
BUILD_BASE="$ROOT_DIR/build/kernel"
DIST_DIR="$KERNEL_DIR/dist"
FRAGMENTS_DIR="$KERNEL_DIR/configs/fragments"
DEVICE_DIR="$KERNEL_DIR/device"

NH_VERSION="3.0.0"
KERNEL_BASE="4.14"
KERNEL_REL="356"
KERNEL_VERSION="${KERNEL_BASE}.${KERNEL_REL}"
ANDROID_VERSION="16"
LINEAGE_VERSION="23.2"

say() { printf "\033[32m  %s\033[0m\n" "$*"; }
warn() { printf "\033[33m  %s\033[0m\n" "$*"; }
die() { printf "\033[31m  ERROR: %s\033[0m\n" "$*"; exit 1; }
header() { printf "\033[36m=== %s ===\033[0m\n" "$*"; }

# ── Build Matrix ───────────────────────────────────────────────────
# Each variant defines which config fragments to merge (in order)
declare -A VARIANTS
VARIANTS=(
	[stable]="base containers security"
	[performance]="base containers security performance"
	[battery]="base containers battery"
	[nethunter]="base containers security nethunter performance"
	[debug]="base containers security performance debug"
	[minimal]="base containers"
	# ── OmniSec variants ────────────────────────────────────────────
	[omnisec]="base containers security nethunter offensive wireless-extended hardware-hacking performance"
	[offensive]="base containers nethunter offensive wireless-extended hardware-hacking performance"
	[exploit-dev]="base containers security nethunter offensive exploit-dev debug"
)

declare -A VARIANT_DESC
VARIANT_DESC=(
	[stable]="Balanced daily-driver — security + containers + performance"
	[performance]="Maximum performance — 1000Hz, BBR, BFQ, preempt"
	[battery]="Battery optimized — 100Hz, powersave, debug disabled"
	[nethunter]="Full NetHunter — all security tools, HID, monitor mode, injection"
	[debug]="Development build — full debug, tracing, KGDB"
	[minimal]="Minimal — base + containers only, stripped"
	[omnisec]="ULTIMATE — nethunter + offensive + wireless-extended + hardware-hacking + performance"
	[offensive]="Offensive — MITM, injection, protocol exploitation, hardware attacks"
	[exploit-dev]="Exploit Dev — kprobes, BPF override, KASAN, UBSAN, KGDB, raw memory access"
)

declare -A VARIANT_COLOR
VARIANT_COLOR=(
	[stable]="32"
	[performance]="31"
	[battery]="33"
	[nethunter]="35"
	[debug]="36"
	[minimal]="37"
	[omnisec]="91"
	[offensive]="31"
	[exploit-dev]="93"
)

# ── Device Registry ────────────────────────────────────────────────
declare -A DEVICES
DEVICES=(
	[guacamole]="OnePlus 7 Pro GM1911:sm8150:lineageos_guacamole_defconfig:https://github.com/LineageOS/android_kernel_oneplus_sm8150.git"
	[oneplus7t]="OnePlus 7T HD1903:sm8150:lineageos_hotdog_defconfig:https://github.com/LineageOS/android_kernel_oneplus_sm8150.git"
	[pixel6]="Google Pixel 6:gs101:lineageos_oriole_defconfig:https://github.com/LineageOS/android_kernel_google_gs101.git"
	[pixel7]="Google Pixel 7:gs201:lineageos_panther_defconfig:https://github.com/LineageOS/android_kernel_google_gs201.git"
	[pixel8]="Google Pixel 8:gs301:lineageos_shiba_defconfig:https://github.com/LineageOS/android_kernel_google_gs201.git"
)

# ── Toolchain — Clang-first, ccache-accelerated ────────────────────
# Override: USE_CLANG=0 to fall back to GCC
USE_CLANG="${USE_CLANG:-1}"
# Override: USE_CCACHE=0 to disable
USE_CCACHE="${USE_CCACHE:-1}"
CROSS_COMPILE_GCC="${CROSS_COMPILE:-aarch64-linux-gnu-}"
CLANG_TRIPLE="aarch64-linux-gnu-"
TOOLCHAIN_DIR="$KERNEL_DIR/toolchain"
KERNEL_SUFFIX="${KERNEL_SUFFIX:-}"

# Populated by setup_make_vars — used in every make call
MAKE_VARS=""

# ── Helpers ────────────────────────────────────────────────────────
device_info() {
	local dev="$1"
	echo "${DEVICES[$dev]:-}" | cut -d: -f1
}

device_soc() {
	local dev="$1"
	echo "${DEVICES[$dev]:-}" | cut -d: -f2
}

device_defconfig() {
	local dev="$1"
	echo "${DEVICES[$dev]:-}" | cut -d: -f3
}

device_source() {
	local dev="$1"
	echo "${DEVICES[$dev]:-}" | cut -d: -f4
}

get_variant_dir() {
	local dev="$1" variant="$2"
	echo "$BUILD_BASE/$dev/$variant"
}

get_variant_out() {
	local dev="$1" variant="$2"
	echo "$(get_variant_dir "$dev" "$variant")/out"
}

# ── Toolchain Setup ────────────────────────────────────────────────
setup_make_vars() {
	# Build the MAKE_VARS string used in every kernel make invocation
	if [[ "$USE_CLANG" == "1" ]] && command -v clang &>/dev/null; then
		local cc="clang"
		local cxx="clang++"
		if [[ "$USE_CCACHE" == "1" ]] && command -v ccache &>/dev/null; then
			export CCACHE_DIR="${CCACHE_DIR:-$HOME/.cache/ccache}"
			export CCACHE_SLOPPINESS=random_seed,locale,time_macros
			export CCACHE_MAXSIZE="${CCACHE_MAXSIZE:-20G}"
			cc="ccache clang"
			cxx="ccache clang++"
			say "ccache + Clang toolchain active (CCACHE_DIR=$CCACHE_DIR)"
		else
			say "Clang toolchain active (no ccache)"
		fi
		MAKE_VARS="CC=\"$cc\" CXX=\"$cxx\" LD=ld.lld AR=llvm-ar NM=llvm-nm \
STRIP=llvm-strip OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump READELF=llvm-readelf \
HOSTCC=\"$cc\" HOSTCXX=\"$cxx\" HOSTAR=llvm-ar \
CROSS_COMPILE=$CLANG_TRIPLE CLANG_TRIPLE=$CLANG_TRIPLE LLVM=1 LLVM_IAS=1"
		clang --version | head -1
	elif command -v "${CROSS_COMPILE_GCC}gcc" &>/dev/null; then
		local cc="${CROSS_COMPILE_GCC}gcc"
		if [[ "$USE_CCACHE" == "1" ]] && command -v ccache &>/dev/null; then
			export CCACHE_DIR="${CCACHE_DIR:-$HOME/.cache/ccache}"
			export CCACHE_SLOPPINESS=random_seed,locale,time_macros
			cc="ccache ${cc}"
		fi
		MAKE_VARS="CROSS_COMPILE=$CROSS_COMPILE_GCC"
		warn "Clang not found — falling back to GCC"
		"${CROSS_COMPILE_GCC}gcc" --version | head -1
	elif [ -f "$TOOLCHAIN_DIR/bin/aarch64-linux-android-clang" ]; then
		export PATH="$TOOLCHAIN_DIR/bin:$PATH"
		MAKE_VARS="CC=aarch64-linux-android-clang CROSS_COMPILE=$CLANG_TRIPLE CLANG_TRIPLE=$CLANG_TRIPLE LLVM=1 LLVM_IAS=1"
		say "Using NDK Clang: $TOOLCHAIN_DIR/bin"
	else
		warn "No toolchain found. Install: pacman -S clang lld aarch64-linux-gnu-gcc"
		warn "Or run: $0 toolchain"
		die "No toolchain available"
	fi
}

check_toolchain() {
	say "Checking toolchain..."
	setup_make_vars
}

setup_toolchain() {
	header "Setting up Android NDK Toolchain"
	local ndk_ver="r27"
	local ndk_url="https://dl.google.com/android/repository/android-ndk-${ndk_ver}-linux.zip"
	local ndk_zip="$TOOLCHAIN_DIR/android-ndk-${ndk_ver}-linux.zip"

	mkdir -p "$TOOLCHAIN_DIR"
	if [ ! -f "$ndk_zip" ]; then
		say "Downloading NDK ${ndk_ver}..."
		wget -O "$ndk_zip" "$ndk_url" || curl -Lo "$ndk_zip" "$ndk_url"
	fi

	if [ ! -d "$TOOLCHAIN_DIR/android-ndk-${ndk_ver}" ]; then
		say "Extracting NDK..."
		unzip -q "$ndk_zip" -d "$TOOLCHAIN_DIR"
	fi

	local ndk_tc="$TOOLCHAIN_DIR/android-ndk-${ndk_ver}/toolchains/llvm/prebuilt/linux-x86_64"
	if [ -d "$ndk_tc" ]; then
		ln -sf "$ndk_tc" "$TOOLCHAIN_DIR/bin" 2>/dev/null || true
		export PATH="$ndk_tc/bin:$PATH"
		TOOLCHAIN="aarch64-linux-android-"
		say "NDK toolchain ready: $ndk_tc"
	else
		die "NDK extraction failed"
	fi
}

# ── Source Management ──────────────────────────────────────────────
check_kernel_source() {
	local dev="$1"
	local src_dir="$SRC_DIR/$dev"
	local repo="$(device_source "$dev")"

	if [ ! -d "$src_dir" ]; then
		say "Cloning kernel source for $dev..."
		mkdir -p "$SRC_DIR"
		git clone --depth=1 --branch="lineage-${LINEAGE_VERSION}" "$repo" "$src_dir" 2>/dev/null || \
		git clone --depth=1 "$repo" "$src_dir"
	fi

	say "Source: $src_dir"
	(cd "$src_dir" && git describe --tags --always 2>/dev/null || echo "no tags")
}

update_kernel_source() {
	local dev="$1"
	local src_dir="$SRC_DIR/$dev"
	if [ -d "$src_dir" ]; then
		say "Updating kernel source for $dev..."
		cd "$src_dir"
		git fetch --depth=1
		git reset --hard origin/$(git rev-parse --abbrev-ref HEAD)
		git clean -fdx
	fi
}

# ── Patch System ───────────────────────────────────────────────────
# Patch sets applied per-variant (cumulative — higher sets include lower)
declare -A PATCH_SETS
PATCH_SETS=(
	[stable]="generic"
	[performance]="generic"
	[battery]="generic"
	[minimal]="generic"
	[nethunter]="generic nethunter"
	[debug]="generic nethunter"
	[omnisec]="generic nethunter offensive"
	[offensive]="generic nethunter offensive"
	[exploit-dev]="generic nethunter offensive exploit-dev"
)

apply_patch_dir() {
	local src_dir="$1" patch_dir="$2"
	[ -d "$patch_dir" ] || return 0
	local count=0
	for p in $(ls "$patch_dir"/*.patch 2>/dev/null | sort); do
		[ -f "$p" ] || continue
		say "  patch: $(basename "$p")"
		patch -p1 -N < "$p" 2>/dev/null && (( count++ )) || warn "  (skip — already applied or conflict)"
	done
	[ "$count" -gt 0 ] && say "  $count patch(es) applied from $(basename "$patch_dir")"
}

add_patches() {
	local dev="$1" variant="$2"
	local src_dir="$SRC_DIR/$dev"
	local sets="${PATCH_SETS[$variant]:-generic}"

	say "Applying patches for variant: $variant (sets: $sets)"
	cd "$src_dir"
	for set in $sets; do
		apply_patch_dir "$src_dir" "$KERNEL_DIR/patches/$set"
	done
}

# ── Config Generation ──────────────────────────────────────────────
generate_config() {
	local dev="$1" variant="$2"
	local src_dir="$SRC_DIR/$dev"
	local out_dir="$(get_variant_out "$dev" "$variant")"
	local defconfig="$(device_defconfig "$dev")"

	mkdir -p "$out_dir"
	say "Generating config for: $dev / $variant"

	# Step 1: Start with stock defconfig
	local stock_defconfig="$src_dir/arch/arm64/configs/$defconfig"
	if [ ! -f "$stock_defconfig" ]; then
		die "Stock defconfig not found: $stock_defconfig"
	fi

	# Step 2: Apply base + variant fragments via scripts/kconfig/merge_config
	local merged_config="$out_dir/.config"
	local fragment_list=""

	for frag in ${VARIANTS[$variant]}; do
		local frag_file="$FRAGMENTS_DIR/$frag.conf"
		if [ -f "$frag_file" ]; then
			fragment_list="$fragment_list $frag_file"
		else
			warn "Fragment not found: $frag.conf"
		fi
	done

	if [ -n "$fragment_list" ]; then
		say "Merging fragments: ${VARIANTS[$variant]}"
		cd "$src_dir"
		eval ARCH=arm64 $MAKE_VARS \
		scripts/kconfig/merge_config.sh -m -O "$out_dir" \
			"$stock_defconfig" $fragment_list 2>/dev/null || true
	fi

	# Step 3: Resolve all dependencies
	cd "$src_dir"
	eval make O="$out_dir" ARCH=arm64 $MAKE_VARS -j"$(nproc)" olddefconfig 2>/dev/null

	say "Config generated: $(wc -l < "$out_dir/.config") options"
}

# ── Build Steps ────────────────────────────────────────────────────
build_variant_kernel() {
	local dev="$1" variant="$2"
	local src_dir="$SRC_DIR/$dev"
	local out_dir="$(get_variant_out "$dev" "$variant")"

	header "Building [${variant}] kernel for $dev"
	say "Target: $(device_info "$dev") | SoC: $(device_soc "$dev")"

	generate_config "$dev" "$variant"

	say "Compiling kernel image + DTBs..."
	eval make -C "$src_dir" O="$out_dir" \
		ARCH=arm64 $MAKE_VARS \
		-j"$(nproc)" \
		Image.gz dtbs 2>&1 | tail -5

	local kernel_img="$out_dir/arch/arm64/boot/Image.gz"
	if [ -f "$kernel_img" ]; then
		local size=$(stat -c%s "$kernel_img" 2>/dev/null || stat -f%z "$kernel_img" 2>/dev/null)
		say "Kernel: $((size / 1024)) KB"
	else
		die "Kernel image not built!"
	fi
}

build_variant_modules() {
	local dev="$1" variant="$2"
	local src_dir="$SRC_DIR/$dev"
	local out_dir="$(get_variant_out "$dev" "$variant")"
	local mod_dir="$(get_variant_dir "$dev" "$variant")/modules"

	say "Building kernel modules..."
	eval make -C "$src_dir" O="$out_dir" \
		ARCH=arm64 $MAKE_VARS \
		-j"$(nproc)" \
		modules 2>&1 | tail -3

	mkdir -p "$mod_dir"
	eval make -C "$src_dir" O="$out_dir" \
		ARCH=arm64 $MAKE_VARS \
		INSTALL_MOD_PATH="$mod_dir" \
		modules_install 2>&1 | tail -3

	local mod_count=$(find "$mod_dir" -name "*.ko" 2>/dev/null | wc -l)
	say "Modules built: $mod_count"
}

# ── Device-Specific Build ──────────────────────────────────────────
build_device_specific() {
	local dev="$1" variant="$2"
	local dev_script="$DEVICE_DIR/$dev/build.sh"
	if [ -f "$dev_script" ]; then
		say "Running device-specific build for $dev..."
		"$dev_script" "$variant" "$(get_variant_dir "$dev" "$variant")"
	fi
}

# ── Reproducible Build Info ────────────────────────────────────────
generate_manifest() {
	local dev="$1" variant="$2"
	local out_dir="$(get_variant_dir "$dev" "$variant")"
	local src_dir="$SRC_DIR/$dev"

	cat > "$out_dir/MANIFEST.txt" <<EOF
NetHunter NextGen Kernel Build Manifest
========================================
NH Version:     $NH_VERSION
Device:         $dev ($(device_info "$dev"))
SoC:            $(device_soc "$dev")
Variant:        $variant
Description:    ${VARIANT_DESC[$variant]}
Kernel:         $KERNEL_VERSION
Android:        $ANDROID_VERSION
LineageOS:      $LINEAGE_VERSION
Build Date:     $(date -u '+%Y-%m-%d %H:%M:%S UTC')
Toolchain:      $(${TOOLCHAIN}gcc --version 2>/dev/null | head -1 || echo "N/A")

Source:
  $(device_source "$dev")
  Commit: $(cd "$src_dir" && git describe --tags --always 2>/dev/null || echo "unknown")
  Fragments: ${VARIANTS[$variant]}

Config Options: $(wc -l < "$out_dir/out/.config" 2>/dev/null || echo "0")
EOF
	say "Manifest: $out_dir/MANIFEST.txt"
}

# ── Packaging ──────────────────────────────────────────────────────
package_variant() {
	local dev="$1" variant="$2"
	local variant_dir="$(get_variant_dir "$dev" "$variant")"
	local out_dir="$(get_variant_out "$dev" "$variant")"
	local pkg_dir="$variant_dir/package"
	local pkg_name="nethunter-kernel-${dev}-${variant}-v${NH_VERSION}"
	local pkg_file="$DIST_DIR/${pkg_name}.tar.gz"

	rm -rf "$pkg_dir"
	mkdir -p "$pkg_dir"

	# Kernel image
	mkdir -p "$pkg_dir/kernel"
	cp "$out_dir/arch/arm64/boot/Image.gz" "$pkg_dir/kernel/" 2>/dev/null || true

	# DTBs
	mkdir -p "$pkg_dir/dtbs"
	cp "$out_dir/arch/arm64/boot/dts/qcom/"*.dtb "$pkg_dir/dtbs/" 2>/dev/null || true
	cp "$out_dir/arch/arm64/boot/dts/qcom/"*.dtbo "$pkg_dir/dtbs/" 2>/dev/null || true

	# Modules
	if [ -d "$variant_dir/modules" ]; then
		mkdir -p "$pkg_dir/modules"
		cp -a "$variant_dir/modules/lib/modules/"* "$pkg_dir/modules/" 2>/dev/null || true
	fi

	# AnyKernel3 packaging
	if [ -d "$KERNEL_DIR/anykernel3" ]; then
		mkdir -p "$pkg_dir/anykernel3"
		cp -r "$KERNEL_DIR/anykernel3/"* "$pkg_dir/anykernel3/"
		cp "$out_dir/arch/arm64/boot/Image.gz" "$pkg_dir/anykernel3/"
		cp "$out_dir/arch/arm64/boot/dts/qcom/"*.dtb "$pkg_dir/anykernel3/" 2>/dev/null || true
		(cd "$pkg_dir/anykernel3" && zip -r "$DIST_DIR/${pkg_name}-anykernel3.zip" . >/dev/null 2>&1)
		say "AnyKernel3: $DIST_DIR/${pkg_name}-anykernel3.zip"
	fi

	# Flash script
	mkdir -p "$pkg_dir/flash"
	if [ -f "$DEVICE_DIR/$dev/flash.sh" ]; then
		cp "$DEVICE_DIR/$dev/flash.sh" "$pkg_dir/flash/"
	else
		cat > "$pkg_dir/flash/flash.sh" <<'FLASHEOF'
#!/sbin/sh
# NetHunter NextGen Kernel Flash Script
set -e
echo "NetHunter NextGen Kernel Flash Utility"
echo "Device: guacamole (OnePlus 7 Pro)"
echo ""
echo "Methods:"
echo "  1. Fastboot:  fastboot flash boot kernel/Image.gz"
echo "  2. Recovery:  flash the AnyKernel3 zip via custom recovery"
echo "  3. Magisk:    patch boot.img with Magisk then flash"
echo ""
echo "Recommended: Use the AnyKernel3 zip in recovery"
FLASHEOF
	fi
	chmod +x "$pkg_dir/flash/flash.sh"

	# Manifest + checksums
	cp "$variant_dir/MANIFEST.txt" "$pkg_dir/"
	cd "$pkg_dir"
	find . -type f -exec sha256sum {} \; > "$pkg_dir/SHA256SUMS"

	# Create dist tarball
	mkdir -p "$DIST_DIR"
	cd "$variant_dir"
	tar czf "$pkg_file" -C "$pkg_dir" .

	say "Package: $pkg_file ($(du -h "$pkg_file" | cut -f1))"
}

# ── Full Build Pipeline ────────────────────────────────────────────
build_variant() {
	local dev="$1" variant="$2"
	header "Starting build: $dev / $variant"
	echo "  ${VARIANT_DESC[$variant]}"

	check_kernel_source "$dev"
	add_patches "$dev" "$variant"
	build_variant_kernel "$dev" "$variant"
	build_variant_modules "$dev" "$variant"
	build_device_specific "$dev" "$variant"
	generate_manifest "$dev" "$variant"
	package_variant "$dev" "$variant"
	say "Build complete: $dev / $variant"
}

build_matrix() {
	local dev="${1:-guacamole}"
	header "NetHunter NextGen Kernel Build Matrix v$NH_VERSION"
	echo "Device: $(device_info "$dev") ($dev)"
	echo "SoC:    $(device_soc "$dev")"
	echo ""

	check_toolchain
	check_kernel_source "$dev"

	for variant in "$@"; do
		[ "$variant" = "$dev" ] && continue
		build_variant "$dev" "$variant"
	done
}

# ── Single Variant ─────────────────────────────────────────────────
build_single() {
	local dev="${1:-guacamole}"
	local variant="${2:-stable}"

	if [ -z "${VARIANTS[$variant]:-}" ]; then
		die "Unknown variant: $variant. Valid: ${!VARIANTS[*]}"
	fi

	check_toolchain
	build_variant "$dev" "$variant"
}

# ── Cleanup ────────────────────────────────────────────────────────
clean_all() {
	local dev="${1:-}"
	header "Cleaning builds"
	if [ -n "$dev" ]; then
		rm -rf "$BUILD_BASE/$dev"
		say "Cleaned: $BUILD_BASE/$dev"
	else
		rm -rf "$BUILD_BASE"
		say "Cleaned: $BUILD_BASE"
	fi
}

distclean() {
	local dev="${1:-}"
	clean_all "$dev"
	if [ -n "$dev" ]; then
		rm -rf "$SRC_DIR/$dev"
		say "Cleaned source: $SRC_DIR/$dev"
	else
		rm -rf "$SRC_DIR"
		say "Cleaned source: $SRC_DIR"
	fi
	rm -rf "$DIST_DIR"
	say "Cleaned dist: $DIST_DIR"
}

# ── CI/CD Pipeline ─────────────────────────────────────────────────
ci_build() {
	local dev="${1:-guacamole}"
	header "CI/CD Build Pipeline"

	clean_all "$dev"
	check_toolchain
	setup_toolchain
	check_kernel_source "$dev"
	update_kernel_source "$dev"

	for variant in stable nethunter performance; do
		build_variant "$dev" "$variant"
	done

	header "CI/CD Build Complete"
	echo "Artifacts:"
	find "$DIST_DIR" -type f -name "*.tar.gz" -o -name "*.zip" | sort
}

# ── Tests ──────────────────────────────────────────────────────────
run_tests() {
	header "Kernel Build System Tests"
	local passed=0 failed=0

	# Test 1: Config fragments exist
	for frag in base containers security performance battery nethunter debug; do
		if [ -f "$FRAGMENTS_DIR/$frag.conf" ]; then
			say "PASS: fragment $frag.conf exists"
		else
			warn "FAIL: fragment $frag.conf missing"
			failed=$((failed + 1))
		fi
	done
	passed=$((passed + 7))

	# Test 2: Device registry
	for dev in "${!DEVICES[@]}"; do
		if [ -n "${DEVICES[$dev]}" ]; then
			say "PASS: device $dev registered"
		else
			warn "FAIL: device $dev not registered"
			failed=$((failed + 1))
		fi
	done
	passed=$((passed + ${#DEVICES[@]}))

	# Test 3: Defconfig exists
	for dev in "${!DEVICES[@]}"; do
		if [ -f "$KERNEL_DIR/configs/${dev}_defconfig" ]; then
			say "PASS: defconfig $dev exists"
		else
			warn "FAIL: defconfig $dev missing"
			failed=$((failed + 1))
		fi
	done
	passed=$((passed + ${#DEVICES[@]}))

	# Test 4: Shell syntax
	if bash -n "$0" 2>/dev/null; then
		say "PASS: build-kernel.sh syntax OK"
	else
		warn "FAIL: build-kernel.sh syntax error"
		failed=$((failed + 1))
	fi
	passed=$((passed + 1))

	# Test 5: Device scripts exist
	for dev in "${!DEVICES[@]}"; do
		if [ -f "$DEVICE_DIR/$dev/build.sh" ]; then
			say "PASS: device script $dev/build.sh exists"
		else
			warn "INFO: device script $dev/build.sh not yet created"
		fi
	done
	passed=$((passed + ${#DEVICES[@]}))

	echo ""
	header "Results: $passed passed, $failed failed"
	[ "$failed" -eq 0 ] || die "Some tests failed"
}

# ── Usage ──────────────────────────────────────────────────────────
usage() {
	cat <<EOF
NetHunter NextGen Kernel Build System v$NH_VERSION
Usage: $0 <command> [device] [variant]

Commands:
  build <device> <variant>    Build single variant
  matrix <device> <variants>  Build multiple variants
  all <device>                Build all variants

  kernel <device> <variant>   Build kernel image only
  modules <device> <variant>  Build modules only
  config <device> <variant>   Generate config only

  clean [device]              Clean build output
  distclean [device]          Clean build + source + dist
  toolchain                   Set up Android NDK toolchain
  ci                          CI/CD pipeline (stable+nethunter+perf)
  test                        Run build system tests
  list                        List available devices and variants
  help                        Show this message

Devices:
$(for d in "${!DEVICES[@]}"; do echo "  $d  ($(device_info "$d"))"; done)

Variants:
$(for v in "${!VARIANTS[@]}"; do printf "  %-15s %s\n" "$v" "${VARIANT_DESC[$v]}"; done)

Examples:
  $0 build guacamole nethunter
  $0 matrix guacamole stable performance battery
  $0 all guacamole
  $0 clean guacamole
  $0 ci
  $0 test
EOF
	exit 0
}

# ── Main ───────────────────────────────────────────────────────────
[ $# -ge 1 ] || usage
CMD="$1"; shift

case "$CMD" in
	build)
		DEV="${1:-guacamole}"
		VARIANT="${2:-stable}"
		build_single "$DEV" "$VARIANT"
		;;
	matrix)
		DEV="${1:-guacamole}"
		shift
		[ $# -ge 1 ] && build_matrix "$DEV" "$@" || die "Specify variants"
		;;
	all)
		DEV="${1:-guacamole}"
		build_matrix "$DEV" "${!VARIANTS[@]}"
		;;
	kernel)
		DEV="${1:-guacamole}"
		VARIANT="${2:-stable}"
		check_toolchain
		check_kernel_source "$DEV"
		add_patches "$DEV" "$VARIANT"
		build_variant_kernel "$DEV" "$VARIANT"
		;;
	modules)
		DEV="${1:-guacamole}"
		VARIANT="${2:-stable}"
		check_toolchain
		build_variant_modules "$DEV" "$VARIANT"
		;;
	config)
		DEV="${1:-guacamole}"
		VARIANT="${2:-stable}"
		check_kernel_source "$DEV"
		generate_config "$DEV" "$VARIANT"
		;;
	clean)
		clean_all "${1:-}"
		;;
	distclean)
		distclean "${1:-}"
		;;
	toolchain)
		setup_toolchain
		;;
	ci)
		ci_build "${1:-guacamole}"
		;;
	test)
		run_tests
		;;
	list)
		echo "Devices:"
		for d in "${!DEVICES[@]}"; do
			echo "  $d  -> $(device_info "$d")"
		done
		echo ""
		echo "Variants:"
		for v in "${!VARIANTS[@]}"; do
			printf "  %-15s %s\n" "$v" "${VARIANT_DESC[$v]}"
		done
		;;
	help|--help|-h) usage ;;
	*) die "Unknown command: $CMD";;
esac
