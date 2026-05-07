# NetHunter NextGen Kernel — AnyKernel3 Script
# Device: OnePlus 7 Pro (guacamole)

kernel.string=NetHunter NextGen Kernel v2.0.0 @ OnePlus 7 Pro
device.name1=guacamole
device.name2=guacamoleb
device.name3=guacamoleg
block=/dev/block/bootdevice/by-name/boot
is_slot_device=0
ramdisk_compression=gzip
supported.versions=16
supported.patchlevels=2026-05

# Kernel flashing
dump_boot
write_boot

# DTB flashing
if [ -f /tmp/anykernel/dtb.img ]; then
    dd if=/tmp/anykernel/dtb.img of=/dev/block/bootdevice/by-name/dtb
fi

# DTBO flashing
if [ -f /tmp/anykernel/dtbo.img ]; then
    dd if=/tmp/anykernel/dtbo.img of=/dev/block/bootdevice/by-name/dtbo
fi
