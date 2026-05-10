#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$ROOT_DIR/nh-defaults.sh"

adb connect "$ADB_SERIAL" >/dev/null 2>&1 || true
adb -s "$ADB_SERIAL" get-state >/dev/null 2>&1 || {
	echo "[preflight] ADB target unreachable: $ADB_SERIAL" >&2
	adb devices -l || true
	exit 1
}

echo "[preflight] Connected target: $ADB_SERIAL"
adb devices -l
