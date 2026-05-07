#!/usr/bin/env bash
set -uo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PASS=0
FAIL=0
SKIP=0

say() { printf "\033[32m  %s\033[0m\n" "$*"; }
fail() { printf "\033[31m  FAIL: %s\033[0m\n" "$*"; ((FAIL++)); }
skip() { printf "\033[33m  SKIP: %s\033[0m\n" "$*"; ((SKIP++)); }
pass() { ((PASS++)); }
check() {
	local label="$1"
	shift
	if eval "$@" 2>/dev/null; then
		say "PASS: $label"; pass
	else
		fail "$label"; return 1
	fi
}

echo "============================================"
echo "  nethunter-setup test suite"
echo "  $(date)"
echo "============================================"
echo ""

echo "--- syntax checks ---"
check "nh-defaults.sh" bash -n "$ROOT_DIR/nh-defaults.sh"
check "nhctl" bash -n "$ROOT_DIR/nhctl"
for f in "$ROOT_DIR"/src/scripts/*.sh; do
	check "scripts/$(basename "$f")" bash -n "$f"
done
for f in "$ROOT_DIR"/src/device/setup/*.sh; do
	check "setup/$(basename "$f")" bash -n "$f"
done
for f in "$ROOT_DIR"/src/device/bin/nh-*; do
	# Skip Python files
	head -1 "$f" 2>/dev/null | grep -q "python" && continue
	check "nhsystem-bin/$(basename "$f")" bash -n "$f"
done
for f in "$ROOT_DIR"/src/device/dotfiles/*.zsh; do
	check "dotfiles/$(basename "$f")" bash -n "$f" || true
done

echo ""
echo "--- C syntax checks ---"
for f in "$ROOT_DIR"/src/c/*.c; do
	check "$(basename "$f")" cc -fsyntax-only -Wall -Wextra -pedantic "$f"
done

echo ""
echo "--- Python syntax checks ---"
for f in "$ROOT_DIR"/src/device/ai/*.py; do
	check "$(basename "$f")" python3 -m py_compile "$f"
done

echo ""
echo "--- shebang checks ---"
while IFS= read -r f; do
	[ -f "$f" ] || continue
	shebang=$(head -1 "$f")
	case "$shebang" in
		'#!/system/bin/sh'|'#!/system/bin/sh'*) ;;
		'#!/data/data/com.termux/files/usr/bin/bash'|'#!/data/data/com.termux/files/usr/bin/zsh') ;;
		'#!/usr/bin/env bash'|'#!/bin/bash'|'#!/usr/bin/bash'|'#!/bin/sh') ;;
		'#!/usr/bin/env python3'|'#!/usr/bin/python3') ;;
		*) skip "$f: $shebang" ;;
	esac
done < <(find "$ROOT_DIR" -type f -executable -not -path '*/node_modules/*' -not -path '*/.git/*' 2>/dev/null || true)

echo ""
echo "--- file existence checks ---"
REQUIRED=(
	"nhctl" "nh-defaults.sh" "README.md" "VERSION.md" "Makefile"
	"src/c/nh-sudo.c" "src/c/no-close-range.c"
	"src/device/bin/nh-lib"
	"src/device/bin/nh-mount" "src/device/bin/nh-umount"
	"src/device/bin/nh-enter-kali" "src/device/bin/nh-enter-arch"
	"src/device/bin/nh-services" "src/device/bin/nh-health"
	"src/device/bin/nh-wifi" "src/device/bin/nh-kex"
	"src/device/bin/nh-log" "src/device/bin/nh-firewall"
	"src/device/bin/nh-packages" "src/device/bin/nh-perf"
	"src/device/setup/android-clean-rebuild.sh"
	"src/device/setup/arch-fast-install.sh"
	"src/device/setup/kali-post.sh"
	"src/device/setup/start-arch-boot.sh"
	"src/scripts/install-kali-rootfs.sh"
	"src/scripts/install-nethunter-app.sh"
	"src/scripts/discover-adb.sh"
	"src/scripts/adb-pair.sh"
	"src/scripts/build-chroot-image.sh"
	"src/device/bin/nh-device-detect"
	"src/device/bin/nh-killswitch"
	"src/device/bin/nh-bt"
	"src/device/bin/nh-sdr"
	"src/device/bin/nh-dashboard"
	"src/scripts/setup-vscode-tunnel.sh"
	"src/device/bin/nh-kismet"
	"src/device/bin/nh-cross"
	"src/device/bin/nh-rtl"
	"src/c/nh-diag.c"
	"tests/test_nh_sudo.c"
	"src/device/bin/nh-ai"
	"src/device/ai/agent.py"
	"src/scripts/setup-ai.sh"
	"src/device/bin/nh-pqc"
	"src/scripts/setup-pqc.sh"
	"src/device/bin/nh-schedule" "src/device/bin/nh-alert"
	"src/device/bin/nh-sync" "src/device/bin/nh-tunnel"
	"src/device/bin/nh-dns" "src/device/bin/nh-container"
	"src/device/bin/nh-key" "src/device/bin/nh-secret"
	"src/device/bin/nh-audio" "src/device/bin/nh-display"
	"src/scripts/nh-toolchain.sh" "src/scripts/nh-validate.sh"
	"src/scripts/nh-qemu.sh"
	"docs/CODING_STANDARDS.md" "docs/PRIORITY.md"
	"docs/SECURITY.md" "docs/PERFORMANCE.md" "docs/STYLEGUIDE.md"
	"ARCHITECTURE.md"
	".shellcheckrc" ".pre-commit-config.yaml"
	".github/ISSUE_TEMPLATE/bug_report.md"
	".github/ISSUE_TEMPLATE/feature_request.md"
	".github/ISSUE_TEMPLATE/device_port.md"
	".github/ISSUE_TEMPLATE/module_request.md"
	".github/PULL_REQUEST_TEMPLATE.md"
	"kernel/README.md"
	"kernel/configs/fragments/base.conf"
	"kernel/configs/fragments/containers.conf"
	"kernel/configs/fragments/security.conf"
	"kernel/configs/fragments/nethunter.conf"
	"kernel/configs/fragments/performance.conf"
	"kernel/configs/fragments/battery.conf"
	"kernel/configs/fragments/debug.conf"
	"kernel/device/guacamole/build.sh"
	"kernel/device/guacamole/flash.sh"
	"kernel/toolchain/setup.sh"
	"kernel/tests/build-system.bats"
	"kernel/anykernel3/anykernel.sh"
)
for f in "${REQUIRED[@]}"; do
	check "exists: $f" test -f "$ROOT_DIR/$f"
done

echo ""
echo "--- executable permission checks ---"
for f in nhctl src/scripts/*.sh device/*.sh; do
	[ -f "$ROOT_DIR/$f" ] || continue
	check "executable: $f" test -x "$ROOT_DIR/$f"
done

echo ""
echo "============================================"
echo "  results: $PASS passed, $FAIL failed, $SKIP skipped"
echo "============================================"
exit $FAIL
