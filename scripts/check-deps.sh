#!/usr/bin/env bash
set -euo pipefail

MISSING=0
check() {
	if ! command -v "$1" &>/dev/null; then
		echo "  MISSING: $1${2:+ ($2)}"
		((MISSING++))
	else
		echo "  FOUND:   $1 ($(command -v "$1"))"
	fi
}

echo "--- dependency check ---"

check adb "Android Debug Bridge"
check bash
check cc "C compiler (gcc/clang)"
check ssh
check ssh-keygen
check git
check rsync
check ping
check timeout
check tar
check gzip
check file

echo ""
if [ $MISSING -gt 0 ]; then
	echo "  $MISSING missing dependencies"
	exit 1
else
	echo "  all dependencies satisfied"
fi
