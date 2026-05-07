# Kernel Development

## Target

| Property | Value |
|----------|-------|
| Device | OnePlus 7 Pro (GM1911 / guacamole) |
| Kernel base | 4.14.356-openela |
| Source | LineageOS `android_kernel_oneplus_sm8150` |
| Toolchain | `aarch64-linux-gnu-gcc` (GCC 12+) |
| Build system | `kernel/Makefile` + `kernel/build-kernel.sh` |

## Setup Toolchain

```bash
# Debian/Ubuntu
sudo apt install gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu

# Verify
aarch64-linux-gnu-gcc --version
```

## Clone and Build

```bash
cd kernel

# Full build (clone source, apply patches, defconfig, kernel, modules)
./build-kernel.sh all

# Or step by step:
make checkout     # Clone kernel source
make defconfig    # Apply defconfig
make kernel       # Build kernel image
make modules      # Build kernel modules
make dtbs         # Build device tree blobs
make anykernel3   # Package AnyKernel3 zip
make boot-image   # Build flashable boot.img
```

## Kernel Source

```bash
# Manual clone
git clone --depth=1 \
  https://github.com/LineageOS/android_kernel_oneplus_sm8150.git \
  kernel/src/guacamole
```

## Configuration

The defconfig overlay is at `kernel/configs/guacamole_defconfig`. It enables:

- **NetHunter features:** Netfilter modules, USB gadgets, HID, monitor mode
- **Wi-Fi adapters:** RT2x00, RTL8187, RTL8192CU, RTL8XXXU
- **Android compatibility:** BinderFS, SELinux development mode
- **Performance:** 1000Hz timer, schedutil governor
- **Debug:** Magic SysRq, debugfs, dynamic debug
- **Workarounds:** close_range backport note, binderfs mount namespace

This overlay is applied on top of the stock LineageOS defconfig.

## Patches

Place patches in `kernel/patches/` with naming convention:

```
NNNN-description.patch
```

Patches are applied automatically by `build-kernel.sh` before building.

### Known Issues Requiring Patches

1. **close_range() syscall (OpenSSH 9.8+)**
   - Android 4.14 kernel lacks `close_range()`
   - Workaround: LD_PRELOAD stub in `no-close-range.c`
   - Proper fix: backport `close_range()` syscall

2. **binderfs mount namespace**
   - `/dev/binder` symlink → `/dev/binderfs/binder` but target invisible
   - Requires proper binderfs mount propagation

3. **SELinux permissive mode**
   - chroot operations trigger denials even with permissive
   - Kernel patch to allow all chroot-related operations

## Flashing

```bash
# Build boot image
make boot-image

# Flash via fastboot
./device/flash-kernel.sh flash-all

# Or AnyKernel3 zip (flash in custom recovery)
make anykernel3
./device/flash-kernel.sh anykernel
```

## Backup Before Flashing

```bash
./device/backup-partitions.sh backup
# Backs up: boot, recovery, dtbo, vbmeta, vendor_boot
```

## Debugging

```bash
# Check current kernel
adb shell uname -a

# Kernel log
adb shell su -c dmesg | grep -i "nethunter\|kali\|arch"

# Module loading
adb shell su -c modprobe <module>

# Sysrq
adb shell su -c "echo t > /proc/sysrq-trigger"
```
