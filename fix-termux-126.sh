#!/usr/bin/env bash
set -euo pipefail

exec "$(cd "$(dirname "$0")" && pwd)/scripts/fix-termux-126.sh" "$@"
