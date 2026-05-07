#!/system/bin/sh

# NetHunter Setup Magisk Module - Boot Service
# OnePlus 7 Pro (GM1911) - LineageOS 23.2 / Android 16

MODDIR="${0%/*}"
NHSYSTEM="/data/local/nhsystem"
BOOT_SCRIPT="$NHSYSTEM/bin/start-arch-boot.sh"

until [ "$(getprop sys.boot_completed)" = "1" ]; do
	sleep 5
done

sleep 15

if [ -f "$BOOT_SCRIPT" ]; then
	exec "$BOOT_SCRIPT"
fi
