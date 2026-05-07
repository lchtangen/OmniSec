<!-- NH_SETUP_VERSION: 2.0 default -->
<!-- Profile: Arch ARM64 v2.0 default; Kali ARM64 v2.0 default -->

# Build Area

This directory is for generated build outputs. It is allowed to be large and disposable.

## Layout

```text
android/      APKs, Gradle outputs, Android build products
kernel/       kernel object directories and boot image staging
rootfs/       rootfs experiments and chroot packaging
packages/     Arch packages, local package output
toolchains/   compilers and SDKs when not managed elsewhere
cache/        build caches
logs/         build logs
```

## Rule

If it can be regenerated, it belongs here or in `tmp/`, not in source directories.

