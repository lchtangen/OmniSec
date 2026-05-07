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
for f in "$ROOT_DIR"/scripts/*.sh; do
	check "scripts/$(basename "$f")" bash -n "$f"
done
for f in "$ROOT_DIR"/*.sh; do
	[ -f "$f" ] || continue
	check "$(basename "$f")" bash -n "$f"
done
for f in "$ROOT_DIR"/payload/*.sh; do
	check "payload/$(basename "$f")" bash -n "$f"
done
for f in "$ROOT_DIR"/payload/nhsystem-bin/nh-*; do
	check "nhsystem-bin/$(basename "$f")" bash -n "$f"
done
for f in "$ROOT_DIR"/payload/termux-home/*.zsh; do
	check "termux/$(basename "$f")" bash -n "$f" || true
done

echo ""
echo "--- C syntax checks ---"
for f in "$ROOT_DIR"/payload/*.c; do
	check "$(basename "$f")" cc -fsyntax-only -Wall -Wextra -pedantic "$f"
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
	"payload/nh-sudo.c" "payload/no-close-range.c"
	"payload/nhsystem-bin/nh-lib"
	"payload/nhsystem-bin/nh-mount" "payload/nhsystem-bin/nh-umount"
	"payload/nhsystem-bin/nh-enter-kali" "payload/nhsystem-bin/nh-enter-arch"
	"payload/nhsystem-bin/nh-services" "payload/nhsystem-bin/nh-health"
	"payload/android-clean-rebuild.sh"
	"payload/arch-fast-install.sh"
	"payload/kali-post.sh"
	"payload/start-arch-boot.sh"
)
for f in "${REQUIRED[@]}"; do
	check "exists: $f" test -f "$ROOT_DIR/$f"
done

echo ""
echo "--- executable permission checks ---"
for f in nhctl scripts/*.sh device/*.sh; do
	[ -f "$ROOT_DIR/$f" ] || continue
	check "executable: $f" test -x "$ROOT_DIR/$f"
done

echo ""
echo "============================================"
echo "  results: $PASS passed, $FAIL failed, $SKIP skipped"
echo "============================================"
exit $FAIL
