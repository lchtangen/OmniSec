# Device profile: OnePlus 7 Pro (guacamole)
# Source this file to set device-specific defaults
# Auto-detected by nhctl detect; can also be sourced directly

NH_DEVICE_NAME="${NH_DEVICE_NAME:-OnePlus 7 Pro}"
NH_DEVICE_CODENAME="${NH_DEVICE_CODENAME:-guacamole}"
NH_DEVICE_MODEL="${NH_DEVICE_MODEL:-GM1911}"
NH_ANDROID_RELEASE="${NH_ANDROID_RELEASE:-16}"
NH_ANDROID_SDK="${NH_ANDROID_SDK:-36}"
NH_ANDROID_ABI="${NH_ANDROID_ABI:-arm64-v8a}"
NH_LINEAGE_VERSION="${NH_LINEAGE_VERSION:-23.2}"

# ADB defaults for this device
NH_ADB_PORT="${NH_ADB_PORT:-52104}"
NH_DEVICE_IP="${NH_DEVICE_IP:-}"

# Kernel build config
NH_KERNEL_DEFCONFIG="${NH_KERNEL_DEFCONFIG:-guacamole_defconfig}"
NH_KERNEL_SRC="${NH_KERNEL_SRC:-kernel/oneplus/sm8150}"
NH_KERNEL_DTBS="${NH_KERNEL_DTBS:-sm8150}"
NH_KERNEL_BOOT_IMAGE="${NH_KERNEL_BOOT_IMAGE:-boot.img}"

# Partitions (for backup/flash)
NH_PARTITIONS="${NH_PARTITIONS:-boot dtbo vendor_boot}"
NH_SUPER_PARTITIONS="${NH_SUPER_PARTITIONS:-system system_ext product vendor odm}"
NH_BOOT_PARTITION="${NH_BOOT_PARTITION:-/dev/block/by-name/boot}"
NH_DTBO_PARTITION="${NH_DTBO_PARTITION:-/dev/block/by-name/dtbo}"
