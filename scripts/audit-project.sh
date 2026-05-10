#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "== Project Audit =="
"$ROOT_DIR/scripts/repo-doctor.sh"

echo "== Lint =="
make -C "$ROOT_DIR" lint

echo "== Tests =="
make -C "$ROOT_DIR" test

echo "audit-project: complete"
