# NetHunter NextGen Kernel — Matrix Build System

> **Version**: 2.0.0 | **Kernel**: 4.14.356 | **Target**: OnePlus 7 Pro (guacamole) / SM8150
> **Android**: 16 | **LineageOS**: 23.2 | **Arch**: ARM64

A modular, multi-variant kernel build system for the NetHunter NextGen mobile development and security workstation. Build custom kernels optimized for performance, battery life, security auditing, or daily driving.

---

## Architecture

```
kernel/
├── build-kernel.sh          # Matrix build system — the main entrypoint
├── Makefile                 # Make targets wrapping build-kernel.sh
├── README.md                # This file — full documentation
│
├── configs/
│   ├── guacamole_defconfig  # Reference defconfig for OnePlus 7 Pro
│   └── fragments/           # Modular config fragments (merged by variant)
│       ├── base.conf        # Foundation — ALL variants include this
│       ├── containers.conf  # Container/chroot support (NS, cgroups, overlay)
│       ├── security.conf    # Security hardening (SELinux, AppArmor, IMA)
│       ├── nethunter.conf   # NetHunter toolkit (netfilter, HID, monitor mode)
│       ├── performance.conf # Performance tuning (1000Hz, BBR, BFQ, preempt)
│       ├── battery.conf     # Battery optimization (100Hz, powersave, no debug)
│       └── debug.conf       # Development (KGDB, ftrace, lockdep, kmemleak)
│
├── patches/
│   ├── README.md            # Patch conventions
│   ├── generic/             # Patches applied to ALL variants
│   └── <variant>/           # Variant-specific patches (e.g., nethunter/, debug/)
│
├── toolchain/
│   ├── setup.sh             # Automated toolchain installer
│   └── README.md            # Toolchain setup documentation
│
├── device/
│   └── guacamole/           # OnePlus 7 Pro device-specific scripts
│       ├── build.sh         # Boot image generation, DTBO packaging
│       └── flash.sh         # Flash utility (fastboot + recovery + Magisk)
│
├── anykernel3/              # AnyKernel3 flashable zip template
│   ├── anykernel.sh
│   └── META-INF/com/google/android/update-binary
│
├── tests/
│   └── build-system.bats    # BATS tests for the build system
│
├── src/                     # Kernel source (cloned by build-kernel.sh)
│   └── guacamole/           # LineageOS kernel source for SM8150
│
└── dist/                    # Output: flashable kernel packages
    ├── nethunter-kernel-guacamole-<variant>-v2.0.0.tar.gz
    ├── nethunter-kernel-guacamole-<variant>-v2.0.0-anykernel3.zip
    └── boot/
        └── boot-guacamole-<variant>-v2.0.0.img
```

## Build Variants

| Variant | Description | Config Merge |
|---------|-------------|--------------|
| `stable` | Balanced daily-driver with security + containers | base + containers + security |
| `performance` | Maximum throughput: 1000Hz timer, BBR TCP, BFQ I/O, full preemption | base + containers + security + performance |
| `battery` | Battery optimized: 100Hz timer, powersave gov, debug disabled | base + containers + battery |
| `nethunter` | Full security toolkit: HID injection, monitor mode, netfilter, external Wi-Fi | base + containers + security + nethunter + performance |
| `debug` | Development build: KGDB, ftrace, lockdep, kmemleak, magic SysRq | base + containers + security + performance + debug |
| `minimal` | Stripped down: base + containers only, no security modules | base + containers |

## Quick Start

### 1. Install Toolchain

```bash
# System toolchain (recommended)
sudo apt install gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu

# Or use the automated setup:
./kernel/toolchain/setup.sh --system

# For Android NDK toolchain:
./kernel/toolchain/setup.sh --ndk

# Both:
./kernel/toolchain/setup.sh --all
```

### 2. Build a Kernel

```bash
# Single variant
./kernel/build-kernel.sh build guacamole nethunter

# Multiple variants
./kernel/build-kernel.sh matrix guacamole stable nethunter performance

# All variants
./kernel/build-kernel.sh all guacamole

# Or use make:
make -C kernel build-nethunter
make -C kernel matrix
make -C kernel matrix-all
```

### 3. Output Artifacts

After building, artifacts are in `kernel/dist/`:

- `nethunter-kernel-guacamole-<variant>-v2.0.0.tar.gz` — Full package: kernel + modules + dtbs + flash scripts + manifest + SHA256
- `nethunter-kernel-guacamole-<variant>-v2.0.0-anykernel3.zip` — Flashable zip for custom recovery
- `boot/boot-guacamole-<variant>-v2.0.0.img` — Complete boot image (if mkbootimg is available)

Each package includes:
- `kernel/Image.gz` — Compressed kernel image
- `dtbs/` — Device tree blobs
- `modules/` — Loadable kernel modules
- `flash/flash.sh` — Flash utility script
- `MANIFEST.txt` — Build manifest with version, config, source commit
- `SHA256SUMS` — Integrity checksums

## Flashing

### Method 1: Fastboot (Recommended)

```bash
# Test without flashing:
fastboot boot kernel/dist/boot/boot-guacamole-nethunter-v2.0.0.img

# Flash permanently:
fastboot flash boot kernel/dist/boot/boot-guacamole-nethunter-v2.0.0.img
fastboot reboot
```

### Method 2: Custom Recovery (AnyKernel3)

```bash
# Flash the AnyKernel3 zip via TWRP/LineageOS Recovery
# File: kernel/dist/nethunter-kernel-guacamole-nethunter-v2.0.0-anykernel3.zip
```

### Method 3: Magisk (Preserve Root)

1. Extract `Image.gz` from the build package
2. Place it in the stock boot.img (replace existing kernel)
3. Patch with Magisk Manager
4. Flash the patched boot.img via fastboot

## CI/CD Pipeline

```bash
# Full CI build: stable + nethunter + performance
./kernel/build-kernel.sh ci guacamole

# This performs:
# 1. Clean build directories
# 2. Install/verify toolchain
# 3. Clone/update kernel source
# 4. Build all three variants
# 5. Package with manifests and checksums
```

## Adding New Devices

1. Add device to the registry in `build-kernel.sh`:
```bash
DEVICES[mydevice]="Device Name:soc:defconfig_name:git_repo_url"
```

2. Create device defconfig: `configs/mydevice_defconfig`

3. Create device build script: `device/mydevice/build.sh`

4. Create device flash script: `device/mydevice/flash.sh`

5. Build:
```bash
./kernel/build-kernel.sh build mydevice stable
```

## Creating New Variants

1. Create config fragment: `configs/fragments/myfeature.conf`

2. Register variant in `build-kernel.sh`:
```bash
VARIANTS[myvariant]="base containers myfeature"
VARIANT_DESC[myvariant]="Description of my variant"
```

3. (Optional) Create variant-specific patches: `patches/myvariant/`

4. Build:
```bash
./kernel/build-kernel.sh build guacamole myvariant
```

## Verifying

```bash
# Run build system tests
./kernel/build-kernel.sh test
make -C kernel test

# Verify a built kernel
gzip -t dist/nethunter-kernel-*/kernel/Image.gz
file dist/nethunter-kernel-*/kernel/Image.gz
# Expected: "gzip compressed data"
```

## Compatibility

| Component | Version | Status |
|-----------|---------|--------|
| Android | 16 (SDK 36) | ✅ Tested |
| LineageOS | 23.2 | ✅ Tested |
| Arch ARM64 chroot | Latest | ✅ Compatible |
| Kali ARM64 chroot | Latest | ✅ Compatible |
| NetHunter app | 2026.x | ✅ Compatible |
| Magisk | 28.x | ✅ Compatible |
| KernelSU | Next | 🚧 Planned |
| Generic ARM64 | N/A | ❌ Device-specific (SM8150) |

## Roadmap

See `PROJECT_AUDIT.md` (kernel sections) for the full 100-task roadmap covering:
- Phase 6-10: Kernel features, hardening, module ecosystem
- Performance benchmarks and regression testing
- Device support expansion (beyond guacamole)
- KernelSU integration
- Upstream kernel version bumps
- NetHunter-specific patch upstreaming

## License

Kernel source is licensed under GPL v2. Build system scripts are MIT.
