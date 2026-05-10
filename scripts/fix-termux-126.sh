#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
echo "[fix-termux-126] Applying NetHunter Terminal compatibility repair..."
exec "$ROOT_DIR/nhctl" repair-nhterm "$@"
