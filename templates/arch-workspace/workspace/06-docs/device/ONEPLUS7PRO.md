<!-- NH_SETUP_VERSION: 2.0 default -->
<!-- Profile: Arch ARM64 v2.0 default; Kali ARM64 v2.0 default -->

# OnePlus 7 Pro Device Profile

Device: OnePlus 7 Pro

Known from latest host audit:

```text
model: GM1911
abi: arm64-v8a
android: 16
sdk: 36
kernel: 4.14.356-openela-rc1-perf-g519973973269
arch rootfs: /data/local/nhsystem/roots/archlinux
workspace: /data/local/nhsystem/workspaces/main mounted at /workspace
```

## Access Paths

From desktop:

```sh
./nhctl status
./nhctl forward
ssh -p 2222 archlinux@127.0.0.1
ssh -p 2222 root@127.0.0.1
```

Use `archlinux` for normal work. Use root only for repair, mounts, ownership, package recovery, and kernel/module checks.

## Next Device Notes To Add

- Exact ROM/build fingerprint.
- Magisk version.
- Boot/vendor_boot/dtbo/vbmeta backup hashes.
- Wi-Fi adapter chipset.
- USB OTG power behavior.

