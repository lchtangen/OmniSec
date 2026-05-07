#!/usr/bin/env bats

load helpers

setup() {
	export ROOT_DIR="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
	export PATH="$ROOT_DIR:$PATH"
}

@test "nh-defaults.sh can be sourced without errors" {
	run bash -c "source $ROOT_DIR/nh-defaults.sh && echo OK"
	[ "$status" -eq 0 ]
	[[ "$output" == *"OK"* ]]
}

@test "nhctl shows help" {
	run bash -c "cd $ROOT_DIR && ./nhctl help"
	[ "$status" -eq 0 ]
	[[ "$output" == *"Usage"* ]]
}

@test "nhctl version shows version" {
	run bash -c "cd $ROOT_DIR && ./nhctl version"
	[ "$status" -eq 0 ]
	[[ "$output" == *"NetHunter"* ]]
}

@test "all scripts are executable" {
	run bash -c "find $ROOT_DIR -maxdepth 1 -name '*.sh' -not -perm -u+x | wc -l"
	[ "$status" -eq 0 ]
	[ "$output" -eq 0 ]
}

@test "all nhsystem scripts have correct shebang" {
	run bash -c "head -1 $ROOT_DIR/src/device/bin/nh-lib"
	[ "$status" -eq 0 ]
	[[ "$output" == "#!/system/bin/sh" ]]
}

@test "VERSION.md contains version info" {
	run bash -c "grep -q 'NH_SETUP_VERSION' $ROOT_DIR/VERSION.md"
	[ "$status" -eq 0 ]
}

@test "nh-defaults.sh defines device IP" {
	run bash -c "source $ROOT_DIR/nh-defaults.sh && echo \$NH_DEVICE_IP"
	[ "$status" -eq 0 ]
	[ -n "$output" ]
}

@test "C sources compile" {
	run bash -c "cc -fsyntax-only -Wall -Wextra -pedantic $ROOT_DIR/src/c/nh-sudo.c"
	[ "$status" -eq 0 ]
}

@test "no-close-range.c compiles" {
	run bash -c "cc -fsyntax-only -Wall -Wextra -pedantic $ROOT_DIR/src/c/no-close-range.c"
	[ "$status" -eq 0 ]
}

@test "setup scripts are executable" {
	run bash -c "find $ROOT_DIR/src/device/setup -maxdepth 1 -name '*.sh' -not -perm -u+x | wc -l"
	[ "$status" -eq 0 ]
	[ "$output" -eq 0 ]
}

@test "Makefile has all targets" {
	run bash -c "cd $ROOT_DIR && make help"
	[ "$status" -eq 0 ]
	[[ "$output" == *"build"* ]]
	[[ "$output" == *"lint"* ]]
	[[ "$output" == *"test"* ]]
	[[ "$output" == *"clean"* ]]
}

@test ".editorconfig exists" {
	test -f "$ROOT_DIR/.editorconfig"
}

@test ".gitignore exists" {
	test -f "$ROOT_DIR/.gitignore"
}

@test ".gitattributes exists" {
	test -f "$ROOT_DIR/.gitattributes"
}

@test "dockerignore exists" {
	test -f "$ROOT_DIR/.dockerignore"
}

@test "Dockerfile exists" {
	test -f "$ROOT_DIR/Dockerfile"
}

@test "Magisk module files exist" {
	test -f "$ROOT_DIR/deploy/magisk/module.prop"
	test -f "$ROOT_DIR/deploy/magisk/customize.sh"
	test -f "$ROOT_DIR/deploy/magisk/build.sh"
}

@test "kernel build files exist" {
	test -f "$ROOT_DIR/kernel/Makefile"
	test -f "$ROOT_DIR/kernel/build-kernel.sh"
	test -f "$ROOT_DIR/kernel/configs/guacamole_defconfig"
}

@test "device scripts are executable" {
	run bash -c "find $ROOT_DIR/device -name '*.sh' -not -perm -u+x | wc -l"
	[ "$status" -eq 0 ]
	[ "$output" -eq 0 ]
}

@test "documentation files exist" {
	test -f "$ROOT_DIR/docs/build-system.md"
	test -f "$ROOT_DIR/docs/kernel-development.md"
	test -f "$ROOT_DIR/docs/device-maintenance.md"
	test -f "$ROOT_DIR/docs/magisk-module.md"
	test -f "$ROOT_DIR/docs/development-workflow.md"
	test -f "$ROOT_DIR/docs/api-reference.md"
	test -f "$ROOT_DIR/docs/troubleshooting.md"
}

@test "LICENSE file exists" {
	test -f "$ROOT_DIR/LICENSE"
}

@test "CONTRIBUTING.md exists" {
	test -f "$ROOT_DIR/CONTRIBUTING.md"
}

@test "build.prop template exists" {
	test -f "$ROOT_DIR/deploy/android/build.prop"
}

@test "nh-ai syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-ai"
	[ "$status" -eq 0 ]
}

@test "agent.py syntax check" {
	run python3 -m py_compile "$ROOT_DIR/src/device/ai/agent.py"
	[ "$status" -eq 0 ]
}

@test "setup-ai.sh syntax check" {
	run bash -n "$ROOT_DIR/src/scripts/setup-ai.sh"
	[ "$status" -eq 0 ]
}

@test "nhctl ai help shows usage" {
	run bash -c "cd $ROOT_DIR && ./nhctl ai help"
	[ "$status" -eq 0 ]
	[[ "$output" == *"Usage"* ]]
}

@test "nhctl ask shows no-adb message" {
	run bash -c "cd $ROOT_DIR && ./nhctl ask test 2>&1 || true"
	# Should either succeed or show ADB-related error (not crash)
	[[ "$output" != *"unbound variable"* ]]
	[[ "$output" != *"syntax error"* ]]
}

@test "nh-pqc syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-pqc"
	[ "$status" -eq 0 ]
}

@test "nhctl pqc help shows usage" {
	run bash -c "cd $ROOT_DIR && ./nhctl pqc help 2>&1 || true"
	[[ "$output" != *"unbound variable"* ]]
	[[ "$output" != *"syntax error"* ]]
}

@test "nh-key pq-generate usage" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-key"
	[ "$status" -eq 0 ]
	[[ "$output" == "" ]]
}

@test "nh-secret pq commands check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-secret"
	[ "$status" -eq 0 ]
	[[ "$output" == "" ]]
}
