#!/system/bin/sh

# NetHunter Setup Magisk Module Installer
# OnePlus 7 Pro (GM1911) - LineageOS 23.2 / Android 16

SKIPMOUNT=false
PROPFILE=false
POSTFSDATA=true
LATESTARTSERVICE=true

REPLACE="
/system/bin/busybox
/system/etc/init
"

set_perm_recursive() {
	local dir="$1" owner="$2" group="$3" dmode="$4" fmode="$5"
	shift 5
	[ -d "$dir" ] || return 0
	find "$dir" -type d -exec chown "$owner:$group" {} \;
	find "$dir" -type d -exec chmod "$dmode" {} \;
	find "$dir" -type f -exec chown "$owner:$group" {} \;
	find "$dir" -type f -exec chmod "$fmode" {} \;
}

set_perm() {
	chown "$1:$2" "$3"
	chmod "$4" "$3"
}

ui_print "  NetHunter Setup v2.0"
ui_print "  Target: OnePlus 7 Pro (GM1911)"
ui_print "  Android 16 / LineageOS 23.2"
ui_print ""

ui_print "  Extracting nhsystem binaries..."
unzip -o "$ZIPFILE" 'nhsystem-bin/*' -d "$MODPATH" >/dev/null 2>&1
set_perm_recursive "$MODPATH/nhsystem-bin" 0 0 0755 0755

ui_print "  Extracting boot scripts..."
unzip -o "$ZIPFILE" 'service.d/*' -d "$MODPATH" >/dev/null 2>&1
set_perm_recursive "$MODPATH/service.d" 0 0 0755 0755

ui_print "  Extracting no-close-range.so..."
unzip -o "$ZIPFILE" 'system/lib64/*' -d "$MODPATH" >/dev/null 2>&1
set_perm_recursive "$MODPATH/system" 0 0 0755 0644

if [ -d "$MODPATH/system/lib64" ]; then
	set_perm 0 0 "$MODPATH/system/lib64/no-close-range.so" 0644
fi

ui_print ""
ui_print "  Installation complete."
ui_print "  Reboot to activate boot scripts."
