<!-- NH_SETUP_VERSION: 2.0 default -->
<!-- Profile: Arch ARM64 v2.0 default; Kali ARM64 v2.0 default -->

# Kernel Work

Goal: build a maintainable OnePlus 7 Pro SM8150 kernel workflow.

## Order

1. Back up current boot-related partitions.
2. Record current Android build, kernel version, Magisk state, and rollback path.
3. Mirror kernel source.
4. Build without modifications.
5. Flash/test only after rollback is proven.
6. Add NetHunter-related features one patch at a time.

## Keep Separate

```text
/workspace/02-source/kernel      source repositories
/workspace/03-build/kernel       object directories and build output
/workspace/07-artifacts/kernels  final kernels/modules worth keeping
/workspace/07-artifacts/boot-images boot/vendor_boot/dtbo/vbmeta backups
```

