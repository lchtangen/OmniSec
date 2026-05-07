<!-- NH_SETUP_VERSION: 2.0 default -->
<!-- Profile: Arch ARM64 v2.0 default; Kali ARM64 v2.0 default -->

# Arch Chroot Work

This Arch chroot is the personal development workstation.

## Daily User

Use `archlinux` for normal work.

Use root only for:

- chroot repair
- mounts
- ownership fixes
- package recovery
- system config
- kernel/module checks

## Important Limitation

`sudo` may not work when the chroot filesystem is mounted with `nosuid`. Use root SSH or ADB-root entry for root tasks.

