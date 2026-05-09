# OmniSec Kernel Patches

Patches are applied automatically by `build-kernel.sh` during `prepare`.
Directory layout — each subdirectory maps to a set of variants:

```
patches/
├── generic/       All variants
├── nethunter/     nethunter, omnisec, offensive, exploit-dev
├── offensive/     omnisec, offensive, exploit-dev
└── exploit-dev/   exploit-dev only
```

Patches apply in filename order. Prefix with `NNNN-` to control ordering.

### Naming Convention

```
NNNN-description.patch
```

### Patch Generation

```bash
git diff > patches/generic/0001-my-change.patch
git format-patch -1 HEAD --stdout > patches/generic/0001-commit.patch
```

### Critical Patches to Acquire

#### generic/ — required for all builds

| File | Purpose | Source |
|------|---------|--------|
| `0001-mac80211-inject.patch` | Frame injection without association (monitor→inject) | NetHunter kernel |
| `0002-cfg80211-regdb-bypass.patch` | Remove regulatory domain enforcement | NetHunter |
| `0003-disable-module-verify.patch` | Load unsigned/out-of-tree modules | Custom |

#### nethunter/ — WiFi adapter drivers

| File | Purpose |
|------|---------|
| `0001-rtl8812au.patch` | RTL8812AU/8814AU (Alfa AWUS036ACH — best AC injection) |
| `0002-rtl8821au.patch` | RTL8821AU/8811AU |
| `0003-mt7612u-monitor.patch` | MT7612U monitor mode fix (Alfa AWUS036ACM) |

#### offensive/ — raw access patches

| File | Purpose |
|------|---------|
| `0001-devmem-full.patch` | /dev/mem access to all physical memory |
| `0002-ptrace-any.patch` | ptrace any process regardless of ancestry |
| `0003-raw-tx-bypass.patch` | Layer 2 injection without socket validation |

#### exploit-dev/ — research environment

| File | Purpose |
|------|---------|
| `0001-kptr-expose.patch` | kptr_restrict=0 at boot — all addresses visible |
| `0002-disable-kaslr.patch` | Deterministic kernel layout for research |

### Getting Patches

```bash
# NetHunter kernel patches (authoritative for Android pentesting kernels)
git clone https://github.com/offensive-security/kali-arm-build-scripts
git clone https://github.com/re4son/kali-nethunter-kernel

# RTL8812AU — aircrack-ng maintained, injection-capable
git clone https://github.com/aircrack-ng/rtl8812au

# Backports from mainline
https://cdn.kernel.org/pub/linux/kernel/projects/backports/
```

### Current Known Issues

- `close_range()` syscall not available on Android 4.14 kernel
  (OpenSSH 9.8+ requires it). Current workaround via LD_PRELOAD.
- binderfs not fully exposed in non-init mount namespaces.
- SELinux permissive required for chroot operations.
- RTL8812AU requires out-of-tree patch — not in 4.14 staging tree.
