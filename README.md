<!-- NH_SETUP_VERSION: 2.0 default -->
<!-- Profile: Arch ARM64 v2.0 default; Kali ARM64 v2.0 default -->

# NetHunter Setup — NextGen

> **Profile**: `NetHunter setup v2.0 (nextgen)` for `Arch ARM64 v2.0 (nextgen)` and `Kali ARM64 v2.0 (nextgen)`

Host-side automation and device-side payloads for a rooted Android 16 ARM64 device running Termux, Kali ARM64 (security), and an Arch Linux ARM64 development chroot (workstation).

## NextGen Vision

A cyberpunk-flavored, dual-chroot mobile development and security workstation with:

- **32 device-side management scripts** — everything from system monitoring to project scaffolding
- **4 dev environment tools** — `nh-dev`, `nh-init`, `nh-config`, `nh-module` for managing toolchains, scaffolding projects, configuration, and loadable modules
- **9 system tools** — `nh-scan`, `nh-temp`, `nh-battery`, `nh-net`, `nh-bench`, `nh-proc`, `nh-clean`, `nh-banner`, `nh-sysinfo` for monitoring, diagnostics, and system management
- **Cyberpunk terminal UI** — neon-colored Starship prompt, nano editor theme, ASCII splash banners, color-coded system output
- **Host-side `nh-dev.sh`** — development lifecycle manager (deploy, build, test, lint, validate, module, docs)

## Terminal UI

The NextGen terminal experience is defined by three dotfiles staged to Termux home:

| File | Purpose |
|------|---------|
| `starship.toml` | Cyberpunk 2077-themed multi-line prompt with neon segments, branch indicators, language version badges |
| `.nanorc` | Neon syntax highlighting theme for nano editor |
| `nh-aliases.zsh` | Shell aliases, environment variables, and helpers for all nh-* tools |

Run `nh-banner` at login for an ASCII splash with live system stats, or `nh-sysinfo` for a detailed device report.

## Architecture

The project is built around `/data/local/nhsystem` on the phone:

```text
/data/local/nhsystem/
  roots/archlinux          # Arch ARM64 development chroot
  roots/kali-arm64         # Kali ARM64 security chroot (optional)
  bin/                     # All nh-* management scripts (36 tools)
  etc/                     # Shared config
  workspaces/main/         # Shared workspace
  logs/                    # System logs
  tmp/                     # Temp files
  backups/                 # Backup archives
```

Compatibility symlinks:

```text
/data/local/nhsystem/archlinux -> roots/archlinux
/data/local/nhsystem/kali-arm64 -> roots/kali-arm64
/data/local/nhsystem/kalifs -> roots/kali-arm64
```

Version/defaults are centralized in `nh-defaults.sh` on the host and `src/device/bin/nh-lib` on the device (staged to `payload/nhsystem-bin/nh-lib`).

### Source Layout

```
src/
  c/                     # C sources (nh-sudo, no-close-range)
  scripts/               # Host-side automation scripts
  device/
    bin/                 # 36 device-side management scripts
    setup/               # Device-side setup/recovery scripts
    dotfiles/            # Termux dotfiles (starship, nanorc, aliases)
    skel/                # Kali chroot skel (/root)
deploy/
  magisk/                # Magisk module packaging
  android/               # build.prop overrides
  udev/                  # 51-android.rules (ADB/fastboot)
  chroot/                # Chroot deployable scripts (sudo wrapper)
```

## Safe Checks

Run these before changing the device:

```bash
make stage              # Stage payload/ from src/
./nhctl forward          # Setup ADB forwards
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
./nhctl status           # Quick device status
./nhctl forward          # Set up SSH/VNC forwards over ADB
./nhctl arch             # Canonical Arch entry (SSH → ADB fallback)
./nhctl connect-arch     # Direct Arch SSH with fallback
./nhctl backup           # Backup chroots and configs
./nhctl deploy-tools     # Deploy payload to device
./nhctl deploy-sudo-wrapper
./nhctl deploy-bootkali
./nhctl repair-arch-ssh
./nhctl repair-nhterm
./nhctl arch-polish
./nhctl update           # Safe backup-then-update
./nhctl fix-all          # Complete repair suite
./nhctl audit            # Full device audit
```

Host-side dev manager:

```bash
./src/scripts/nh-dev.sh init       # Initialize project
./src/scripts/nh-dev.sh deploy     # Stage and deploy to device
./src/scripts/nh-dev.sh build      # Build C sources
./src/scripts/nh-dev.sh test       # Run test suite
./src/scripts/nh-dev.sh lint       # Syntax check all scripts
./src/scripts/nh-dev.sh validate   # Full validation pipeline
./src/scripts/nh-dev.sh module     # Package Magisk module
./src/scripts/nh-dev.sh docs       # Preview documentation
./src/scripts/nh-dev.sh status     # Project and device status
```

Make targets:

```bash
make stage        # Stage payload/ from src/
make lint         # Syntax check everything
make validate     # Full validation
make build-c      # Build C binaries
make test         # Run tests (102 checks)
make build-module # Package Magisk module
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

## Device Commands (NextGen)

All 36 device-side scripts live in `/data/local/nhsystem/bin/` and are accessible from any shell after Termux setup (via `nh-aliases.zsh`).

### Core System

| Command | Description |
|---------|-------------|
| `nh-status` | System status overview (mounts, chroots, services) |
| `nh-version` | Show version and profile labels |
| `nh-health` | Health check — run after every reboot |
| `nh-audit` | Read-only device audit (Android, chroots, tools) |
| `nh-services` | Start/stop/restart SSH and service launchers |
| `nh-mount` | Mount chroot filesystems |
| `nh-umount` | Unmount chroot filesystems |
| `nh-update` | Safe chroot package upgrade with backup |
| `nh-backup` | Backup chroots, configs, and workspaces |
| `nh-lib` | Shared library (sourced by other scripts) |

### Chroot Entry

| Command | Description |
|---------|-------------|
| `nh-enter-arch` | Enter Arch ARM64 chroot as `archlinux` user |
| `nh-enter-arch-root` | Enter Arch ARM64 chroot as root |
| `nh-enter-kali` | Enter Kali ARM64 chroot as user |
| `nh-enter-kali-root` | Enter Kali ARM64 chroot as root |
| `nh-shell` | Enter default chroot shell |
| `nh-shell-root` | Enter root shell (Kali) |
| `nh-shell-bash` | Enter bash shell |
| `nh-shell-emergency` | Emergency shell (minimal env) |
| `nh-shell-kali` | Kali-specific shell entry |
| `nh-root-shell` | Alias for Kali root shell |
| `nh-android-shell` | Raw Android root shell (bypass chroot) |

### Dev Environment Tools

| Command | Description |
|---------|-------------|
| `nh-dev` | Dev environment manager (status, setup, python/node/rust/go/android shells, upgrade) |
| `nh-init` | Project scaffold generator (python, node, rust, go, c, shell, module, workspace) |
| `nh-config` | Configuration manager (list, get, set, delete, reset, export, import) |
| `nh-module` | Module management system (list, install, remove, enable, disable, info, create, search) |

### System Monitoring

| Command | Description |
|---------|-------------|
| `nh-temp` | CPU/GPU/SoC temperature monitor with color-coded output |
| `nh-battery` | Battery status and health with visual bar |
| `nh-proc` | Process monitor (top CPU/memory consumers) |
| `nh-sysinfo` | Detailed system information (device, Android, kernel, hardware, sensors, uptime) |

### Network

| Command | Description |
|---------|-------------|
| `nh-net` | Network diagnostics (interfaces, routing, DNS, connections, ARP, wireless, bandwidth) |
| `nh-scan` | Network discovery and port scanning |
| `nh-vpn` | VPN status and management |

### Utilities

| Command | Description |
|---------|-------------|
| `nh-banner` | Cyberpunk ASCII art splash with live system stats |
| `nh-bench` | System benchmark suite (CPU primes, memory, storage, DNS speed) |
| `nh-clean` | System cleaner (temp files, chroot caches, logs) |
| `nh-debug` | Debug information dump |
| `nh-version` | Show version and build info |

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

## Cyberpunk Terminal UI Guide

The NextGen profile includes a fully themed terminal experience inspired by cyberpunk and neon aesthetics.

### Starship Prompt

The `starship.toml` theme features:

- **Multi-line layout** with OS icon, username, directory, git status, and language version segments
- **Neon color palette**: green OS badge, cyan username, blue directory, cyan git branch, green/yellow/red language segment transitions
- **System indicators**: container/virtualization detection, command duration (after 2s), Nix shell state
- **Git status**: conflict, ahead/behind, staged, modified, renamed, deleted, untracked indicators
- **Neon cursor**: green `▶` on success, red `▶` on error, yellow `◀` on vim mode

### Shell Aliases

`nh-aliases.zsh` provides:

```sh
alias nh-status   nh-health   nh-audit   nh-version   nh-services
alias nh-temp     nh-battery  nh-net     nh-scan      nh-bench
alias nh-proc     nh-clean    nh-banner  nh-sysinfo   nh-dev
alias nh-init     nh-config   nh-module  nh-backup    nh-update
alias arch='nh-enter-arch'
alias kali='nh-enter-kali'
alias root='nh-shell-root'
alias android='nh-android-shell'
alias vpn-status='nh-vpn'
alias banner='nh-banner'
alias matrix='nh-scan --matrix'
alias sysinfo='nh-sysinfo'
```

### Nano Editor

The `.nanorc` theme provides neon syntax highlighting with dark background, green strings, cyan comments, yellow keywords, and magenta constants.

### Splash Banner

Run `nh-banner` to display a "NETHUNT SETUP" ASCII art logo with live system stats (battery, SoC temp, load, memory) in terminal colors.

### Color Conventions

Output from all NextGen scripts follows a consistent scheme:

| Color | Meaning |
|-------|---------|
| Green | OK, success, healthy values |
| Yellow | Warning, medium range, informational |
| Red | Error, failure, critical values |
| Cyan | Headers, labels, section markers |
| Magenta | Branding, version info, decorative elements |

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

Termux SSH sessions are configured by `src/device/setup/termux-login.sh`, `~/.zprofile`, and `~/.zshrc` so `$PREFIX/bin` wins over Android toybox and `LD_PRELOAD` is unset over SSH.

## Workspace Scaffolding

Use the device-side project scaffold generator to bootstrap new projects:

```sh
# From any chroot or Termux shell:
nh-init python my-project     # Python project with venv, pytest, setup.py
nh-init node my-app           # Node.js project with package.json, ESLint
nh-init rust my-crate         # Rust project with Cargo.toml, clippy
nh-init go my-module          # Go module with go.mod, standard layout
nh-init c my-lib              # C project with Makefile, compiler flags
nh-init shell my-tool         # Shell script project with tests
nh-init module my-module      # Loadable nh-module package
nh-init workspace my-space    # Full workspace with subdirectories

# Configuration management:
nh-config list                # List all config keys
nh-config get key             # Get a value
nh-config set key value       # Set a value

# Module management:
nh-module list                # List installed modules
nh-module install repo/name   # Install a module
nh-module create my-module    # Create a new module
```

Run this before `git add`:

```bash
make validate
./repo-clean.sh
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
# Output: deploy/magisk/dist/nethunter-setup-v2.0.0.zip
```

See `docs/magisk-module.md` for install/uninstall instructions.

## Development Workflow

```bash
make lint              # Check syntax first
make test              # Run tests
make validate          # Full validation
git checkout -b feature/my-feature
# make changes...
git commit
```

See `docs/development-workflow.md` for the full development cycle.
See `CONTRIBUTING.md` for coding standards.
