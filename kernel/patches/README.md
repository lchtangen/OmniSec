# Kernel Patches

Place `.patch` files here. They are applied by `build-kernel.sh` before
building the kernel.

### Naming Convention

```
NNNN-description.patch
```

Example:
```
0001-wifi-rt2800usb-monitor-mode-fix.patch
0002-binder-mount-namespace-fix.patch
0003-close_range-syscall-backport.patch
```

### Patch Generation

```bash
# Create a patch from current changes
git diff > patches/0001-my-change.patch

# Create a patch from a commit
git format-patch -1 HEAD --stdout > patches/0001-commit-msg.patch
```

### Current Known Issues

- `close_range()` syscall not available on Android 4.14 kernel
  (OpenSSH 9.8+ requires it). Current workaround via LD_PRELOAD.
- binderfs not fully exposed in non-init mount namespaces.
- SELinux permissive required for chroot operations.
