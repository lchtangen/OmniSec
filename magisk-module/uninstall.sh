#!/system/bin/sh

# NetHunter Setup Magisk Module - Uninstaller

NHSYSTEM="/data/local/nhsystem"
BACKUP_DIR="/data/local/nhsystem-backups"

# Stop services
for svc in sshd tor; do
	PID="$(pidof "$svc" 2>/dev/null || true)"
	[ -n "$PID" ] && kill "$PID" 2>/dev/null || true
done

# Umount chroots
if [ -f "$NHSYSTEM/bin/nh-umount" ]; then
	sh "$NHSYSTEM/bin/nh-umount" all 2>/dev/null || true
fi

# Remove boot script from Magisk service.d
rm -f /data/adb/service.d/99-nethunter-boot.sh

ui_print "  NetHunter Setup module removed."
ui_print "  nhsystem data preserved at: $NHSYSTEM"
ui_print "  Backups preserved at: $BACKUP_DIR"
ui_print "  Manual cleanup: rm -rf $NHSYSTEM"
