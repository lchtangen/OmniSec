#!/usr/bin/env bats
# NH_KERNEL_VERSION: 2.0.0
# Kernel build system BATS tests

setup() {
	load "$BATS_TEST_DIRNAME/../../tests/helpers.bash"
	KERNEL_DIR="$BATS_TEST_DIRNAME/.."
}

@test "build-kernel.sh exists and is executable" {
	[ -f "$KERNEL_DIR/build-kernel.sh" ]
	[ -x "$KERNEL_DIR/build-kernel.sh" ]
}

@test "build-kernel.sh has valid syntax" {
	bash -n "$KERNEL_DIR/build-kernel.sh"
}

@test "Makefile exists" {
	[ -f "$KERNEL_DIR/Makefile" ]
}

@test "All config fragments exist" {
	local fragments=(base containers security performance battery nethunter debug)
	for f in "${fragments[@]}"; do
		[ -f "$KERNEL_DIR/configs/fragments/$f.conf" ]
	done
}

@test "Device defconfig exists for guacamole" {
	[ -f "$KERNEL_DIR/configs/guacamole_defconfig" ]
}

@test "Device build script exists for guacamole" {
	[ -f "$KERNEL_DIR/device/guacamole/build.sh" ]
}

@test "Device flash script exists for guacamole" {
	[ -f "$KERNEL_DIR/device/guacamole/flash.sh" ]
}

@test "All build variants registered in build-kernel.sh" {
	local variants
	variants=$(grep -oP '\[[a-z]+\]=' "$KERNEL_DIR/build-kernel.sh" | tr -d '[]=' | tr '\n' ' ')
	[ -n "$variants" ]
}

@test "Device registry has guacamole" {
	grep -q "guacamole" "$KERNEL_DIR/build-kernel.sh"
}

@test "build-kernel.sh test command works" {
	run bash "$KERNEL_DIR/build-kernel.sh" test
	[ "$status" -eq 0 ]
}

@test "AnyKernel3 packaging exists" {
	[ -f "$KERNEL_DIR/anykernel3/anykernel.sh" ]
}

@test "Toolchain setup script exists" {
	[ -f "$KERNEL_DIR/toolchain/setup.sh" ]
	[ -x "$KERNEL_DIR/toolchain/setup.sh" ]
}

@test "Patches README exists" {
	[ -f "$KERNEL_DIR/patches/README.md" ]
}

@test "Build system tests detect all framework files" {
	bash "$KERNEL_DIR/build-kernel.sh" test 2>&1 | grep -q "passed"
}
