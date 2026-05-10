#!/usr/bin/env bash
set -uo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PASS=0
FAIL=0

say() { printf "\033[32m  %s\033[0m\n" "$*"; }
warn() { printf "\033[33m  %s\033[0m\n" "$*"; }
fail() { printf "\033[31m  FAIL: %s\033[0m\n" "$*"; ((FAIL++)); }
pass() { ((PASS++)); }
check() {
	local label="$1" result
	shift
	if eval "$@" 2>/dev/null; then
		say "PASS: $label"; pass
	else
		fail "$label"; return 1
	fi
}

echo "--- OmniSec validation ---"

check "nh-defaults.sh syntax" bash -n "$ROOT_DIR/nh-defaults.sh"
check "nhctl syntax" bash -n "$ROOT_DIR/nhctl"

for f in "$ROOT_DIR"/src/device/setup/*.sh; do
	[ -f "$f" ] || continue
	check "setup/$(basename "$f") syntax" bash -n "$f"
done

for f in "$ROOT_DIR"/src/device/bin/nh-*; do
	[ -f "$f" ] || continue
	# Skip Python files
	head -1 "$f" 2>/dev/null | grep -q "python" && continue
	check "nhsystem-bin/$(basename "$f") syntax" bash -n "$f"
done

for f in "$ROOT_DIR"/*.sh; do
	[ -f "$f" ] || continue
	check "$(basename "$f") syntax" bash -n "$f"
done

for f in "$ROOT_DIR"/src/c/*.c; do
	[ -f "$f" ] || continue
	check "$(basename "$f") C syntax" cc -fsyntax-only -Wall -Wextra "$f"
done

# Optional: ADB/device checks (skip if no device)
if timeout 5 adb devices -l 2>/dev/null | grep -q device; then
	check "Device root" timeout 10 adb shell su -c id | grep -q uid=0
	check "nhsystem exists" timeout 10 adb shell su -c "test -d /data/local/nhsystem"
else
	warn "SKIP: no ADB device connected (device checks skipped)"
fi

echo ""
echo "--- results: $PASS passed, $FAIL failed ---"
exit $FAIL
