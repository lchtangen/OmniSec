#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "[build-chroot-image] staging payload and chroot artifacts"
exec make -C "$ROOT_DIR" stage
