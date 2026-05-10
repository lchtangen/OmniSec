#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
FAIL=0

check_file() {
	local path="$1"
	if [[ -e "${ROOT_DIR}/${path}" ]]; then
		echo "[ok] ${path}"
	else
		echo "[fail] missing: ${path}" >&2
		FAIL=$((FAIL + 1))
	fi
}

check_cmd() {
	local cmd="$1"
	if command -v "${cmd}" >/dev/null 2>&1; then
		echo "[ok] command: ${cmd}"
	else
		echo "[warn] command missing: ${cmd}"
	fi
}

echo "== OmniSec Repo Doctor =="
echo "root: ${ROOT_DIR}"

check_file "nhctl"
check_file "Makefile"
check_file "package.json"
check_file "scripts"
check_file "release-artifacts/plugins/shell"
check_file "tests"

check_cmd bash
check_cmd git
check_cmd rg
check_cmd adb

echo "== git status =="
git -C "${ROOT_DIR}" --no-pager status --short | head -40 || true

if [[ "${FAIL}" -gt 0 ]]; then
	echo "repo-doctor: FAILED (${FAIL} issues)" >&2
	exit 1
fi

echo "repo-doctor: OK"
