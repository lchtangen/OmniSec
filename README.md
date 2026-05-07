<!-- NH_SETUP_VERSION: 2.0 default -->
<!-- Profile: Arch ARM64 v2.0 default; Kali ARM64 v2.0 default -->

# NetHunter Setup

Default profile: `NetHunter setup v2.0 (nextgen)` for `Arch ARM64 v2.0 (nextgen)` and `Kali ARM64 v2.0 (nextgen)`.

Host-side automation and device-side payloads for a rooted Android 16 ARM64 device running Termux, Kali ARM64 (security), and an Arch Linux ARM64 development chroot (workstation).

The project is built around `/data/local/nhsystem` on the phone:

```text
/data/local/nhsystem/
  roots/archlinux
  roots/kali-arm64
  bin
  etc
  workspaces/main
  logs
  tmp
  backups
```

Compatibility symlinks keep older scripts usable:

```text
/data/local/nhsystem/archlinux -> roots/archlinux
/data/local/nhsystem/kali-arm64 -> roots/kali-arm64
/data/local/nhsystem/kalifs -> roots/kali-arm64
```

Version/defaults are centralized in `nh-defaults.sh` on the host and `payload/nhsystem-bin/nh-lib` on the device.

## Safe Checks

Run these before changing the device:

```bash
./preflight.sh
./audit-project.sh
./run-audit.sh
./setup-adb-forwards.sh
./nhctl status
./nhctl deploy-tools
```

The host scripts default to the wireless ADB target `10.0.0.113:52104`. If Android Wireless debugging shows a different connect port, pass it explicitly to `./preflight.sh 10.0.0.113:CONNECT_PORT` or override `ADB_SERIAL`.

## Project Roadmaps

Planning documents for the next phase:

```text
docs/wifi-adapter-projects.md
docs/personal-25-project-roadmap.md
```

Active host entrypoints:

```bash
./nhctl status
./nhctl forward
./nhctl arch
./nhctl connect-arch
./nhctl backup
./nhctl deploy-tools
./nhctl deploy-sudo-wrapper
./nhctl deploy-bootkali
./nhctl repair-arch-ssh
./nhctl repair-nhterm
./nhctl arch-polish
./nhctl update
./nhctl fix-all
./nhctl audit
./preflight.sh
./connect-arch.sh
./setup-adb-forwards.sh
./setup-ssh-config.sh
./setup-termux.sh
./fix-termux-126.sh
./repo-doctor.sh
./repo-clean.sh
./run-audit.sh
./audit-project.sh
./status.sh
```

If Android Wireless debugging shows a different connect port, use it explicitly:

```bash
./preflight.sh 10.0.0.113:CONNECT_PORT
```

## Main Workflow

Use this only when ADB and Magisk root are confirmed:

```bash
./clean-rebuild-postboot.sh
```

That runner stages `payload/`, pushes `ArchLinuxARM-aarch64-latest.tar.gz`, rebuilds `/data/local/nhsystem`, installs Arch ARM64, configures Termux aliases, repairs Kali when present, and starts service launchers.

## Device Commands

From a rooted shell:

```sh
/data/local/nhsystem/bin/nh-status
/data/local/nhsystem/bin/nh-version
/data/local/nhsystem/bin/nh-health
/data/local/nhsystem/bin/nh-audit
/data/local/nhsystem/bin/nh-services start
/data/local/nhsystem/bin/nh-enter-arch
/data/local/nhsystem/bin/nh-enter-kali
/data/local/nhsystem/bin/nh-shell-root
/data/local/nhsystem/bin/nh-android-shell
```

`nh-root-shell` and `nh-shell-root` open the Kali root shell. Use `nh-android-shell` when you specifically want the raw Android root shell instead. If the official NetHunter app state gets out of sync with the current Kali rootfs path, run `./nhctl repair-nhterm` to restore the app-side scripts/prefs from backup and re-align `kalifs`.

## SSH Over ADB

If direct Wi-Fi SSH to the phone IP times out but ADB works, use local forwards:

```bash
./nhctl forward
ssh -p 8022 u0_a171@127.0.0.1
ssh -p 2222 archlinux@127.0.0.1
```

On the audited Android 16 device, Termux SSH works through the ADB `8022` forward. Arch SSH needs chroot-side repair if it times out during banner exchange.

Canonical desktop entry into Arch:

```bash
./nhctl arch
```

`./nhctl arch` enters through Termux over ADB immediately. `./nhctl connect-arch` tries direct `nh-arch` first, then falls back to Termux over ADB and runs the Arch chroot launcher.

From Termux after setup:

```sh
nh-status
nh-health
arch
kali
vpn-status
```

## Role Split

Arch ARM64 is the personal development and project environment: compilers, Python, Node, Rust, Go, editors, tmux, workspace, privacy helpers, and backups.

Kali ARM64 is the ethical cybersecurity environment: NetHunter app integration, KEX, SSH, diagnostics, and security tool availability checks. Use it only on systems where you have authorization.

## Autopilot

`nhctl` is the safe full-autopilot wrapper. Risky operations run a backup first:

```bash
./nhctl backup
./nhctl deploy-tools
./nhctl deploy-sudo-wrapper
./nhctl deploy-bootkali
./nhctl repair-arch-ssh
./nhctl arch-polish
./nhctl update
./nhctl fix-all   # complete repair suite in one command
./nhctl audit
```

Do not use `clean-rebuild-postboot.sh` through autopilot; it remains an explicit rebuild-only command.

Termux SSH sessions are configured by `payload/termux-login.sh`, `~/.zprofile`, and `~/.zshrc` so `$PREFIX/bin` wins over Android toybox and `LD_PRELOAD` is unset over SSH.

## Private Repo Prep

Run this before `git add`:

```bash
./repo-doctor.sh
./repo-clean.sh
./repo-doctor.sh
```

`repo-clean.sh` removes generated/deprecated local clutter: `node_modules/`, `audits/`, and `archive/`. The Arch rootfs tarball stays local but is ignored by Git.

---

## Build System

```bash
make lint          # Syntax check all scripts and C sources
make build-c       # Build C binaries (nh-sudo, no-close-range.so)
make build-module  # Package Magisk flashable module
make test          # Run local test suite
make validate      # Full validation (lint + test + device checks)
make docker        # Build dev container
make clean         # Remove build artifacts
make dist          # Package distribution artifacts
```

See `docs/build-system.md` for full documentation.

## Kernel Development

```bash
cd kernel
./build-kernel.sh all    # Clone source, patch, build kernel + modules
cd ..
./device/flash-kernel.sh  # Flash to device
```

See `docs/kernel-development.md` for toolchain setup and flashing.

## Device Management

```bash
./device/backup-partitions.sh  # Backup boot/recovery/dtbo/vbmeta
./device/flash-kernel.sh       # Flash kernel builds
./device/deploy-boot-script.sh # Install Magisk boot service
```

See `docs/device-maintenance.md` for maintenance procedures.

## Magisk Module

```bash
make build-module
# Output: magisk-module/dist/nethunter-setup-v2.0.0-nextgen.zip
```

See `docs/magisk-module.md` for install/uninstall instructions.

## Development Workflow

```bash
make lint              # Check syntax first
make test              # Run tests
./scripts/validate.sh  # Full validation
git checkout -b feature/my-feature
# make changes...
git commit
```

See `docs/development-workflow.md` for the full development cycle.
See `CONTRIBUTING.md` for coding standards.
