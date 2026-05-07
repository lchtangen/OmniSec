#!/system/bin/sh
# NH_SETUP_VERSION: 2.0 default
# Profile: Arch ARM64 v2.0 default; Kali ARM64 v2.0 default
# Restore official NetHunter app state and align it to the canonical Kali rootfs.

set -eu

NHSYSTEM="${NHSYSTEM:-/data/local/nhsystem}"
APP_PKG="${APP_PKG:-com.offsec.nethunter}"
NHTERM_PKG="${NHTERM_PKG:-com.offsec.nhterm}"
APP_DIR="/data/data/$APP_PKG"
SCRIPT_DIR="$APP_DIR/scripts"
PREFS_DIR="$APP_DIR/shared_prefs"
CANONICAL_KALI="$NHSYSTEM/roots/kali-arm64"
BACKUP_DIR="$NHSYSTEM/backups/nethunter-app-$(date +%Y%m%d-%H%M%S)"

log() { echo "[repair-nethunter-terminal] $*"; }
die() { echo "[repair-nethunter-terminal] error: $*" >&2; exit 1; }

[ -d "$APP_DIR" ] || die "NetHunter app data missing at $APP_DIR"
[ -d "$SCRIPT_DIR" ] || die "NetHunter script directory missing at $SCRIPT_DIR"
[ -d "$PREFS_DIR" ] || die "NetHunter prefs directory missing at $PREFS_DIR"
[ -d "$CANONICAL_KALI" ] || die "Canonical Kali rootfs missing at $CANONICAL_KALI"

find_original_backup() {
    find "$NHSYSTEM/backups" -path '*/scripts/bootkali' | sort | while IFS= read -r candidate; do
        base="${candidate%/scripts/bootkali}"
        suffix="${base#$NHSYSTEM/backups/nethunter-app-}"
        [ "$suffix" != "$base" ] || continue
        [ -n "$suffix" ] || continue
        case "$suffix" in
            rollback-*|*/*) continue ;;
        esac
        [ -d "$base/shared_prefs" ] || continue
        grep -q 'IMPORT BOOTKALI ENVIRONMENT' "$candidate" 2>/dev/null || continue
        grep -q '/data/local/nhsystem/bin/nh-root-shell' "$candidate" 2>/dev/null && continue
        printf '%s\n' "$base"
        return 0
    done
    return 1
}

log "force-stopping NetHunter apps"
am force-stop "$APP_PKG" >/dev/null 2>&1 || true
am force-stop "$NHTERM_PKG" >/dev/null 2>&1 || true

log "backing up current official app scripts and prefs to $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"
cp -a "$SCRIPT_DIR" "$BACKUP_DIR/scripts"
cp -a "$PREFS_DIR" "$BACKUP_DIR/shared_prefs"

ORIG_BACKUP="${ORIG_BACKUP:-$(find_original_backup || true)}"
if [ -n "$ORIG_BACKUP" ]; then
    log "restoring official NetHunter scripts and prefs from $ORIG_BACKUP"
    rm -rf "$SCRIPT_DIR"
    cp -a "$ORIG_BACKUP/scripts" "$SCRIPT_DIR"
    rm -rf "$PREFS_DIR"
    cp -a "$ORIG_BACKUP/shared_prefs" "$PREFS_DIR"
else
    log "no pristine app backup found; leaving official app files untouched"
fi

if ! grep -q 'NH_FAST_CUSTOM_CMD' "$SCRIPT_DIR/bootkali" 2>/dev/null; then
    log "patching bootkali custom_cmd fast path to avoid settings-screen ANR"
    BOOTKALI_TMP="$BACKUP_DIR/bootkali"
    {
        cat <<'EOF'
#!/system/bin/sh
# NH_FAST_CUSTOM_CMD
if [ "${1:-}" = "custom_cmd" ]; then
    SCRIPT_PATH=$(readlink -f "$0")
    . "${SCRIPT_PATH%/*}/bootkali_init"
    shift
    CMD="$*"
    exec /system/bin/chroot "$MNT" /usr/bin/env -i \
        HOME=/root \
        USER=root \
        LOGNAME=root \
        TERM="${TERM:-xterm-256color}" \
        LANG=C.UTF-8 \
        LC_ALL=C.UTF-8 \
        PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
        /bin/sh -lc "$CMD"
fi
EOF
        tail -n +2 "$SCRIPT_DIR/bootkali"
    } > "$BOOTKALI_TMP"
    cp "$BOOTKALI_TMP" "$SCRIPT_DIR/bootkali"
    chmod 755 "$SCRIPT_DIR/bootkali"
fi

log "aligning kalifs to $CANONICAL_KALI"
rm -f "$NHSYSTEM/kalifs"
ln -s "$CANONICAL_KALI" "$NHSYSTEM/kalifs"

/system/bin/restorecon -RF "$APP_DIR" 2>/dev/null || true

log "effective kalifs link:"
ls -ld "$NHSYSTEM/kalifs" || true
log "current backup:"
echo "$BACKUP_DIR"
if [ -n "$ORIG_BACKUP" ]; then
    log "restored original app state from:"
    echo "$ORIG_BACKUP"
fi
