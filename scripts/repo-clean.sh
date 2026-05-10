#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "[repo-clean] Removing generated artifacts..."
rm -rf "$ROOT_DIR/build" "$ROOT_DIR/dist" "$ROOT_DIR/payload/stage" 2>/dev/null || true

echo "[repo-clean] Current git status:"
git -C "$ROOT_DIR" --no-pager status --short
