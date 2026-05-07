#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BACKUP_DIR="$ROOT_DIR/backups/partitions"
DEVICE="GM1911"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
PARTITIONS=(
	"boot"
	"recovery"
	"dtbo"
	"vbmeta"
	"vendor_boot"
)

say() { printf "\033[32m  %s\033[0m\n" "$*"; }
die() { printf "\033[31m  ERROR: %s\033[0m\n" "$*"; exit 1; }

check_adb() {
	adb devices -l | grep -q device || die "No device connected"
	say "Device connected"
}

check_root() {
	adb shell su -c id 2>/dev/null | grep -q uid=0 || die "No root access"
	say "Root access confirmed"
}

list_partitions() {
	say "Available partitions:"
	adb shell su -c "ls -la /dev/block/by-name/" 2>/dev/null || \
	adb shell su -c "ls -la /dev/block/platform/soc/*/by-name/" 2>/dev/null || \
	say "  (using raw partition list)"
}

backup_partition() {
	local part="$1"
	local output="$BACKUP_DIR/$DEVICE-${part}-${TIMESTAMP}.img"
	say "Backing up $part..."
	adb shell su -c "dd if=/dev/block/by-name/$part" 2>/dev/null | \
		pv -s "$(adb shell su -c "blockdev --getsize64 /dev/block/by-name/$part" 2>/dev/null || echo 0)" > "$output" 2>/dev/null || {
		warn "  $part backup failed (partition may not exist)"
		return 1
	}
	say "  saved: $output"
	ls -lh "$output"
}

backup_all() {
	mkdir -p "$BACKUP_DIR"
	say "Backing up partitions to: $BACKUP_DIR"
	for part in "${PARTITIONS[@]}"; do
		backup_partition "$part" || true
	done
	say "Backup complete ($BACKUP_DIR)"
}

verify_backup() {
	say "Verifying backups..."
	for f in "$BACKUP_DIR"/*.img; do
		[ -f "$f" ] || continue
		local size
		size=$(stat -c%s "$f" 2>/dev/null || stat -f%z "$f" 2>/dev/null)
		if [ "$size" -gt 0 ] 2>/dev/null; then
			say "  OK: $(basename "$f") ($(numfmt --to=iec "$size" 2>/dev/null || ls -lh "$f" | awk '{print $5}'))"
		else
			warn "  EMPTY: $(basename "$f")"
		fi
	done
}

usage() {
	cat <<EOF
Usage: $0 [command]

Commands:
  list        List available partitions on device
  backup      Backup all specified partitions
  boot        Backup only boot partition
  verify      Verify backup integrity
  all         List, backup, and verify (default)
EOF
	exit 0
}

case "${1:-all}" in
	list) check_adb; list_partitions ;;
	backup) check_adb; check_root; backup_all ;;
	boot) check_adb; check_root; mkdir -p "$BACKUP_DIR"; backup_partition "boot" ;;
	verify) verify_backup ;;
	all) check_adb; check_root; list_partitions; backup_all; verify_backup ;;
	help|--help|-h) usage ;;
	*) die "Unknown: $1";;
esac
