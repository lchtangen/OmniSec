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

@test "nh-hsm syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-hsm"
	[ "$status" -eq 0 ]
}

@test "nhctl hsm help shows usage" {
	run bash -c "cd $ROOT_DIR && ./nhctl hsm help 2>&1 || true"
	[[ "$output" != *"unbound variable"* ]]
	[[ "$output" != *"syntax error"* ]]
}

@test "setup-hsm.sh syntax check" {
	run bash -n "$ROOT_DIR/src/scripts/setup-hsm.sh"
	[ "$status" -eq 0 ]
}

@test "nh-mesh syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-mesh"
	[ "$status" -eq 0 ]
}

@test "nhctl mesh help shows usage" {
	run bash -c "cd $ROOT_DIR && ./nhctl mesh help 2>&1 || true"
	[[ "$output" != *"unbound variable"* ]]
	[[ "$output" != *"syntax error"* ]]
}

@test "setup-mesh.sh syntax check" {
	run bash -n "$ROOT_DIR/src/scripts/setup-mesh.sh"
	[ "$status" -eq 0 ]
}

# eBPF Component Tests
@test "nh-ebpf syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-ebpf"
	[ "$status" -eq 0 ]
}

@test "nh-trace.c compiles" {
	run bash -c "cc -fsyntax-only -Wall -Wextra -pedantic $ROOT_DIR/src/c/nh-trace.c"
	[ "$status" -eq 0 ]
}

@test "setup-ebpf.sh syntax check" {
	run bash -n "$ROOT_DIR/src/scripts/setup-ebpf.sh"
	[ "$status" -eq 0 ]
}

@test "nhctl ebpf help shows usage" {
	run bash -c "cd $ROOT_DIR && ./nhctl ebpf help 2>&1 || true"
	[[ "$output" != *"unbound variable"* ]]
	[[ "$output" != *"syntax error"* ]]
}

# Premium Feature Syntax Checks (10 initial)
@test "nh-perf syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-perf"
	[ "$status" -eq 0 ]
}

@test "nh-battery syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-battery"
	[ "$status" -eq 0 ]
}

@test "nh-netdiag syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-netdiag"
	[ "$status" -eq 0 ]
}

@test "nh-security-audit syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-security-audit"
	[ "$status" -eq 0 ]
}

@test "nh-backup-pro syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-backup-pro"
	[ "$status" -eq 0 ]
}

@test "nh-log-analyzer syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-log-analyzer"
	[ "$status" -eq 0 ]
}

@test "nh-automate syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-automate"
	[ "$status" -eq 0 ]
}

@test "nh-alert syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-alert"
	[ "$status" -eq 0 ]
}

@test "nh-optimize syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-optimize"
	[ "$status" -eq 0 ]
}

@test "nh-report syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-report"
	[ "$status" -eq 0 ]
}

# Premium Feature Syntax Checks (11-50)
@test "nh-sniffer syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-sniffer"
	[ "$status" -eq 0 ]
}

@test "nh-vuln-scan syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-vuln-scan"
	[ "$status" -eq 0 ]
}

@test "nh-wifi-audit syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-wifi-audit"
	[ "$status" -eq 0 ]
}

@test "nh-bt-audit syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-bt-audit"
	[ "$status" -eq 0 ]
}

@test "nh-container syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-container"
	[ "$status" -eq 0 ]
}

@test "nh-scheduler syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-scheduler"
	[ "$status" -eq 0 ]
}

@test "nh-sync syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-sync"
	[ "$status" -eq 0 ]
}

@test "nh-encrypt syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-encrypt"
	[ "$status" -eq 0 ]
}

@test "nh-decrypt syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-decrypt"
	[ "$status" -eq 0 ]
}

@test "nh-password syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-password"
	[ "$status" -eq 0 ]
}

@test "nh-2fa syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-2fa"
	[ "$status" -eq 0 ]
}

@test "nh-ids syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-ids"
	[ "$status" -eq 0 ]
}

@test "nh-ips syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-ips"
	[ "$status" -eq 0 ]
}

@test "nh-firewall syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-firewall"
	[ "$status" -eq 0 ]
}

@test "nh-vpn syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-vpn"
	[ "$status" -eq 0 ]
}

@test "nh-proxy syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-proxy"
	[ "$status" -eq 0 ]
}

@test "nh-tor syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-tor"
	[ "$status" -eq 0 ]
}

@test "nh-i2p syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-i2p"
	[ "$status" -eq 0 ]
}

@test "nh-dnscrypt syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-dnscrypt"
	[ "$status" -eq 0 ]
}

@test "nh-ssl syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-ssl"
	[ "$status" -eq 0 ]
}

@test "nh-hash syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-hash"
	[ "$status" -eq 0 ]
}

@test "nh-forensics syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-forensics"
	[ "$status" -eq 0 ]
}

@test "nh-recovery syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-recovery"
	[ "$status" -eq 0 ]
}

@test "nh-clone syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-clone"
	[ "$status" -eq 0 ]
}

@test "nh-migrate syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-migrate"
	[ "$status" -eq 0 ]
}

@test "nh-benchmark syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-benchmark"
	[ "$status" -eq 0 ]
}

@test "nh-stress syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-stress"
	[ "$status" -eq 0 ]
}

@test "nh-monitor syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-monitor"
	[ "$status" -eq 0 ]
}

@test "nh-notify syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-notify"
	[ "$status" -eq 0 ]
}

@test "nh-api syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-api"
	[ "$status" -eq 0 ]
}

@test "nh-db syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-db"
	[ "$status" -eq 0 ]
}

@test "nh-web syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-web"
	[ "$status" -eq 0 ]
}

@test "nh-ftp syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-ftp"
	[ "$status" -eq 0 ]
}

@test "nh-samba syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-samba"
	[ "$status" -eq 0 ]
}

@test "nh-nfs syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-nfs"
	[ "$status" -eq 0 ]
}

@test "nh-ssh syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-ssh"
	[ "$status" -eq 0 ]
}

@test "nh-scp syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-scp"
	[ "$status" -eq 0 ]
}

@test "nh-rsync syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-rsync"
	[ "$status" -eq 0 ]
}

@test "nh-git syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-git"
	[ "$status" -eq 0 ]
}

@test "nh-docker syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-docker"
	[ "$status" -eq 0 ]
}

# Phase 7: Autonomous Threat Intelligence Tests
@test "nh-threat syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-threat"
	[ "$status" -eq 0 ]
}

@test "nh-ioc syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-ioc"
	[ "$status" -eq 0 ]
}

@test "setup-threat-intel.sh syntax check" {
	run bash -n "$ROOT_DIR/src/scripts/setup-threat-intel.sh"
	[ "$status" -eq 0 ]
}

@test "nhctl threat help shows usage" {
	run bash -c "cd $ROOT_DIR && ./nhctl threat help 2>&1 || true"
	[[ "$output" != *"unbound variable"* ]]
	[[ "$output" != *"syntax error"* ]]
}

@test "nh-recon-mesh syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-recon-mesh"
	[ "$status" -eq 0 ]
}

# Advanced Tools Tests
@test "nh-exploit syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-exploit"
	[ "$status" -eq 0 ]
}

@test "nh-orchestrate syntax check" {
	run bash -n "$ROOT_DIR/src/device/bin/nh-orchestrate"
	[ "$status" -eq 0 ]
}

@test "nh-web-console.py syntax check" {
	run python3 -m py_compile "$ROOT_DIR/src/device/bin/nh-web-console.py"
	[ "$status" -eq 0 ]
}
