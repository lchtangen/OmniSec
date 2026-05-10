#!/usr/bin/env bash
set -euo pipefail

if ! command -v qemu-system-x86_64 >/dev/null 2>&1; then
  echo "qemu not installed; install qemu-system-x86_64 and retry" >&2
  exit 1
fi

echo "nh-qemu helper is available; pass a full qemu invocation command."
echo "example: nh-qemu.sh -hda image.qcow2 -m 4096"
exec qemu-system-x86_64 "$@"
