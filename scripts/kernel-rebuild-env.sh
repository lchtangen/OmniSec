#!/usr/bin/env bash
# OmniSec kernel rebuild environment

set -euo pipefail

export OMNISEC_ROOT="${OMNISEC_ROOT:-$HOME/OmniSec}"
export OMNISEC_BUILD_ROOT="${OMNISEC_BUILD_ROOT:-/AI/Builds/OmniSec}"

export KERNEL_OUT="${KERNEL_OUT:-$OMNISEC_BUILD_ROOT/kernel-out}"
export KERNEL_CACHE="${KERNEL_CACHE:-$OMNISEC_BUILD_ROOT/kernel-cache}"
export KERNEL_PACKAGES="${KERNEL_PACKAGES:-$OMNISEC_BUILD_ROOT/kernel-packages}"

export ARCH="${ARCH:-arm64}"
export SUBARCH="${SUBARCH:-arm64}"

export LLVM="${LLVM:-1}"
export LLVM_IAS="${LLVM_IAS:-1}"

export CC="${CC:-clang}"
export LD="${LD:-ld.lld}"
export AR="${AR:-llvm-ar}"
export NM="${NM:-llvm-nm}"
export OBJCOPY="${OBJCOPY:-llvm-objcopy}"
export OBJDUMP="${OBJDUMP:-llvm-objdump}"
export STRIP="${STRIP:-llvm-strip}"

export MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}"

mkdir -p "$KERNEL_OUT" "$KERNEL_CACHE" "$KERNEL_PACKAGES"

echo "OmniSec kernel rebuild environment loaded"
echo "OMNISEC_ROOT=$OMNISEC_ROOT"
echo "OMNISEC_BUILD_ROOT=$OMNISEC_BUILD_ROOT"
echo "KERNEL_OUT=$KERNEL_OUT"
echo "ARCH=$ARCH"
echo "LLVM=$LLVM"
echo "MAKEFLAGS=$MAKEFLAGS"
