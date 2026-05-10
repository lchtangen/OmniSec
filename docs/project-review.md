# OmniSec — Master Review & Next-Gen Roadmap

**Profile:** `v2.0-full` · **Device:** OnePlus 7 Pro (GM1911) · **Android:** 16 · **LineageOS:** 23.2 · **ABI:** arm64-v8a  
**Chroots:** Arch ARM64 (dev workstation) + Kali ARM64 (security)

---

## 1. Project Overview

Host-side automation and device-side payloads for a rooted Android ARM64 device running a **dual chroot** environment:

| Chroot | Role | SSH Port | User | Package Manager |
|--------|------|----------|------|----------------|
| **Arch Linux ARM64** | Dev workstation — compilers, editors, containers, VPN | 2222 | `archlinux` | pacman |
| **Kali Linux ARM64** | Security testing — NetHunter, KEX, pentest tools | 22 | `kali` | apt |
| **Termux** | Android-side bridge — SSH gateway, launcher scripts | 8022 | `u0_a171` | pkg |

All three environments share a workspace at `/data/local/nhsystem/workspaces/main`.

---

## 2. Architecture

```
Host (Linux PC)                     Device (OnePlus 7 Pro)
┌─────────────────────────┐        ┌──────────────────────────────────┐
│  nhctl (orchestrator)   │──ADB──▶  /data/local/nhsystem/            │
│  Makefile (build)       │        │    bin/        (42 nhsystem tools)│
│  src/ (source of truth) │        │    roots/archlinux  (Arch chroot) │
│    c/         (2 files) │        │    roots/kali-arm64 (Kali chroot) │
│    scripts/  (12 files) │        │    workspaces/main (shared work)  │
│    device/              │        │    logs/          (diagnostics)    │
│      bin/    (42 tools) │        │    backups/       (snapshots)     │
│      setup/  (17 files) │        │    etc/           (config)        │
│      dotfiles/          │        │                                   │
│      skel/              │        │  /data/adb/service.d/             │
│  deploy/                │        │    99-nethunter-boot.sh (Magisk)  │
│    magisk/  (module)    │        │                                   │
│    chroot/  (sudo wrap) │        │  /data/data/com.offsec.nethunter/ │
│    android/ (build.prop)│        │    files/bootkali_{env,init}       │
│    udev/    (rules)     │        │                                   │
│  docs/      (10 files)  │        │  /data/data/com.termux/files/     │
│  tests/                 │        │    usr/bin/sshd :8022             │
│  payload/  (generated)  │        └──────────────────────────────────┘
└─────────────────────────┘
```

---

## 3. Progress — All Features & Tools

### 3.1 Host-Side Controller (`nhctl` — 22 commands)

| Command | Status | Description |
|---------|--------|-------------|
| `status` | ✅ | Host preflight + device nh-status |
| `backup` | ✅ | Workspace/config snapshot |
| `update` | ✅ | Backup then Arch pacman update |
| `audit` | ✅ | Host + device audit |
| `doctor` | ✅ | Self-diagnostic (deps, structure, ADB, git) |
| `shell [kali\|arch\|android]` | ✅ | Open interactive chroot shell via ADB |
| `exec <kali\|arch> <cmd>` | ✅ | Run command in chroot |
| `mount [all\|kali\|arch]` | ✅ | Mount chroot filesystems |
| `umount [all\|kali\|arch]` | ✅ | Unmount chroot filesystems |
| `forward` | ✅ | Setup ADB port forwards |
| `port-forward {list\|add\|remove\|setup}` | ✅ | Manage ADB forwards |
| `connect-arch` | ✅ | Enter Arch (SSH → Termux fallback) |
| `arch` | ✅ | Enter Arch via Termux immediately |
| `termux` | ✅ | SSH into Termux via ADB forward |
| `setup-ssh [IP]` | ✅ | Generate SSH config + deploy keys |
| `kex {start\|stop\|restart\|status\|log}` | ✅ | Kali KEX/VNC session manager |
| `wifi` | ✅ | Wi-Fi diagnostics |
| `logs {list\|tail\|follow\|clear\|fetch}` | ✅ | View/fetch device logs |
| `deploy-tools` | ✅ | Deploy nhsystem helpers + boot service |
| `deploy-sudo-wrapper` | ✅ | Deploy sudo wrapper to chroots |
| `deploy-bootkali` | ✅ | Deploy fixed bootkali scripts |
| `repair-arch-ssh` | ✅ | Rewrite sshd_config, restart sshd |
| `repair-nhterm` | ✅ | Restore NetHunter app state |
| `arch-polish` | ✅ | Finish Arch workstation setup |
| `fix-all` | ✅ | Complete repair suite (all above) |
| `install-kali [source]` | ✅ | Download/extract/post-install Kali ARM64 rootfs |
| `install-nethunter [opts]` | ✅ | Download + install NetHunter APK on device |
| `help` | ✅ | Usage |

### 3.2 Device-Side Tools (`src/device/bin/` — 42 scripts)

#### Core Library
| Tool | Status | Description |
|------|--------|-------------|
| `nh-lib` | ✅ | Shared library: paths, mounts, chroot_exec, deploy_sudo_wrapper |

#### Entry & Shell
| Tool | Status | Description |
|------|--------|-------------|
| `nh-enter-arch` | ✅ | Arch user shell |
| `nh-enter-arch-root` | ✅ | Arch root shell |
| `nh-enter-kali` | ✅ | Kali user shell |
| `nh-enter-kali-root` | ✅ | Kali root shell |
| `nh-shell` | ✅ | Auto-detect default shell |
| `nh-shell-kali` | ✅ | Kali user via zsh |
| `nh-shell-root` | ✅ | Kali root |
| `nh-shell-bash` | ✅ | Kali user via bash |
| `nh-shell-emergency` | ✅ | Android emergency shell |
| `nh-root-shell` | ✅ | Magisk root entry |
| `nh-android-shell` | ✅ | Raw system shell |

#### System Management
| Tool | Status | Description |
|------|--------|-------------|
| `nh-mount` | ✅ | Mount chroot filesystems |
| `nh-umount` | ✅ | Unmount chroot filesystems |
| `nh-services` | ✅ | Start sshd, WireGuard, Tor |
| `nh-status` | ✅ | Quick status overview |
| `nh-health` | ✅ | Comprehensive health check |
| `nh-debug` | ✅ | Deep diagnostic report |
| `nh-audit` | ✅ | Read-only device audit |
| `nh-version` | ✅ | Version labels |
| `nh-update` | ✅ | Arch pacman -Syu |
| `nh-backup` | ✅ | Workspace snapshot manager |
| `nh-vpn` | ✅ | WireGuard VPN manager |
| `nh-config` | ✅ | Config key-value store |
| `nh-init` | ✅ | Project scaffold generator |
| `nh-module` | ✅ | Module management system |
| `nh-clean` | ✅ | System cleaner |
| `nh-banner` | ✅ | ASCII art banner |

#### Monitoring & Diagnostics
| Tool | Status | Description |
|------|--------|-------------|
| `nh-battery` | ✅ | Battery status + health |
| `nh-bench` | ✅ | CPU/memory/storage/DNS benchmark |
| `nh-dev` | ✅ | Dev environment manager |
| `nh-net` | ✅ | Network diagnostics |
| `nh-proc` | ✅ | Process monitor |
| `nh-scan` | ✅ | Network discovery + port scan |
| `nh-sysinfo` | ✅ | Detailed system info |
| `nh-temp` | ✅ | SoC temperature monitor |
| `nh-perf` | ✅ | Performance monitor |
| `nh-log` | ✅ | Log viewer |
| `nh-wifi` | ✅ | Wi-Fi diagnostics |
| `nh-kex` | ✅ | Kali KEX/VNC session manager |
| `nh-firewall` | ✅ | Netfilter/firewall status |
| `nh-packages` | ✅ | Package listing across chroots |

**42 total device-side tools** — every subsystem monitored and manageable.

### 3.3 Device Setup Scripts (`src/device/setup/` — 17 files)

| Script | Status | Description |
|--------|--------|-------------|
| `arch-fast-install.sh` | ✅ | First-run Arch setup: DNS, pacman, base packages, users, sshd |
| `arch-polish.sh` | ✅ | Workspace layout, workstation packages, profile |
| `arch-specialization.sh` | ✅ | Full dev workstation: privacy, CTF, desktop, toolchains |
| `arch-autostart.sh` | ✅ | Session auto-start: runtime dirs, sshd, Tor |
| `arch-wireguard-setup.sh` | ✅ | WireGuard keygen + tunnel config |
| `kali-post.sh` | ✅ | Kali packages: xfce4, VNC, pentest, bluetooth, SDR |
| `kali-sudo-fix.sh` | ✅ | Sudoers config for chroot compat |
| `kali-sudo-helper.sh` | ✅ | Build setuid nh-sudo binary |
| `kali-test.sh` | ✅ | Kali health check |
| `termux-setup.sh` | ✅ | Termux packages, sshd, dotfiles |
| `termux-login.sh` | ✅ | SSH-safe login environment hook |
| `android-clean-rebuild.sh` | ✅ | Full device rebuild from scratch |
| `device-implement.sh` | ✅ | Device repair + migration |
| `repair-nethunter-terminal.sh` | ✅ | NetHunter app state restoration |
| `start-arch-boot.sh` | ✅ | Magisk boot service (chroot + services) |
| `bootkali_env` | ✅ | Fixed bootkali env (no `which` hang) |
| `bootkali_init` | ✅ | Fixed bootkali init (timeout guard) |

### 3.4 C Sources (`src/c/` — 2 files)

| File | Status | Description |
|------|--------|-------------|
| `nh-sudo.c` | ✅ | Static setuid sudo helper for chroots |
| `no-close-range.c` | ✅ | LD_PRELOAD shim for missing `close_range()` syscall |

### 3.5 Deploy/Distribution (`deploy/`)

| Component | Status | Files | Description |
|-----------|--------|-------|-------------|
| **Magisk module** | ✅ | 6 | Flashable zip: build.sh, customize.sh, module.prop, service.sh, uninstall.sh, update.json |
| **Chroot scripts** | ✅ | 1 | `sudo` wrapper for chroots |
| **Android build.prop** | ✅ | 1 | System property overlay (performance, network, ADB) |
| **UDEV rules** | ✅ | 1 | ADB/fastboot device rules |

### 3.6 Documentation (`docs/` — 10 files)

| Document | Status | Description |
|----------|--------|-------------|
| `build-system.md` | ✅ | Makefile targets, directory layout, C build, validation |
| `development-workflow.md` | ✅ | Dev cycles, architecture, testing strategy |
| `device-maintenance.md` | ✅ | ADB, backups, clean rebuild, common issues |
| `kernel-development.md` | ✅ | Kernel build, defconfig, patching, flashing |
| `magisk-module.md` | ✅ | Module build, install, uninstall |
| `api-reference.md` | ✅ | Full API ref for all 42 nhsystem-bin scripts |
| `troubleshooting.md` | ✅ | Common issues: ADB, chroot, SSH, KEX, Magisk |
| `personal-25-project-roadmap.md` | ✅ | 25-project personal roadmap |
| `wifi-adapter-projects.md` | ✅ | Wi-Fi adapter bring-up projects |
| `vscode-kwallet-keyring.md` | ✅ | KDE keyring config for VS Code |

### 3.7 Build System (`Makefile` — 25 targets)

| Target | Status | Description |
|--------|--------|-------------|
| `all` | ✅ | lint + build + stage + test |
| `build`, `build-c` | ✅ | Compile C sources |
| `stage`, `stage-payload` | ✅ | Stage src/ → payload/ |
| `build-module` | ✅ | Build Magisk flashable zip |
| `lint`, `lint-sh`, `lint-c`, `lint-json` | ✅ | Syntax checks |
| `test`, `test-sh` | ✅ | Test suite (116 tests) |
| `validate` | ✅ | Full validation |
| `deploy`, `deploy-full` | ✅ | Deploy to device |
| `docker`, `docker-run` | ✅ | Docker dev container |
| `clean`, `distclean` | ✅ | Cleanup |
| `dist` | ✅ | Distribution package |
| `workspace-init` | ✅ | Create workspace |
| `version`, `tree`, `help` | ✅ | Info |

---

## 4. Test Suite

**116 tests passing, 0 failing, 2 skipped** (ELF binaries in build/).

| Category | Tests | Description |
|----------|-------|-------------|
| Shell syntax | 70+ | `bash -n` on all scripts |
| C syntax | 2 | `nh-sudo.c`, `no-close-range.c` |
| JSON validation | 3 | package.json, extensions.json, tasks.json |
| File existence | 20+ | Required project files |
| Executable perms | 15+ | Scripts are `chmod +x` |
| Shebang checks | all | Proper `#!/...` lines |

---

## 5. Next-Gen Roadmap — Cross-Device & Cross-System

### 5.1 Phase: Universal Device Support

Currently hardcoded for OnePlus 7 Pro (GM1911). Next-gen makes this device-agnostic.

| Task | Priority | Description |
|------|----------|-------------|
| **Device auto-detection** | 🔴 High | Scripts detect model/codename/ABI via `getprop` instead of hardcoded vars |
| **Dynamic ADB discovery** | 🔴 High | Scan LAN for ADB devices instead of hardcoded IP:port |
| **Device profile database** | 🟡 Medium | `devices/` directory with per-model configs (partitions, codenames, kernel src) |
| **Wireless ADB pairing flow** | 🟡 Medium | Automated pairing code entry for Android 15+ |
| **Multi-device orchestration** | 🟢 Low | `nhctl` operates on multiple devices simultaneously |

### 5.2 Phase: Chroot Management

| Task | Priority | Description |
|------|----------|-------------|
| **Chroot image builder** | 🔴 High | Script to download/extract/configure Arch/Kali rootfs images standalone |
| **Containerized rootfs build** | 🔴 High | Docker-based chroot image builder with cross-arch support |
| **Chroot registry/versioning** | 🟡 Medium | Keep multiple chroot versions, rollback on failure |
| **Minimal chroot profiles** | 🟡 Medium | Lightweight chroot variants (no GUI, no bloat) |
| **Auto-healing chroots** | 🟡 Medium | Detect broken packages, auto-fix on boot |
| **Chroot snapshots** | 🟢 Low | btrfs/zfs-style snapshot before every update |

### 5.3 Phase: NetHunter Integration

| Task | Priority | Description |
|------|----------|-------------|
| **Kali rootfs auto-install** | 🔴 High | Download/extract Kali rootfs, run kali-post.sh automatically |
| **NetHunter app auto-install** | 🔴 High | Download + install latest NetHunter APK |
| **KEX session persistence** | 🟡 Medium | Auto-start KEX on boot, reconnect after disconnect |
| **Custom kernel flash via nhctl** | 🟡 Medium | `nhctl kernel build` + `flash` |
| **Kali metapackage profiles** | 🟢 Low | Choose Kali tool subsets (top10, wireless, sdr, etc.) |

### 5.4 Phase: Security & Privacy

| Task | Priority | Description |
|------|----------|-------------|
| **VPN kill switch** | 🔴 High | Ensure all traffic fails closed when VPN drops |
| **Secrets management** | 🔴 High | Encrypted storage for SSH keys, API tokens, WireGuard keys |
| **SELinux policy module** | 🟡 Medium | Custom SELinux policy for chroot operations |
| **App sandbox profiles** | 🟡 Medium | Per-app network/permission containment |
| **Audit log shipping** | 🟡 Medium | Ship device audit logs to host for analysis |
| **Integrity checking** | 🟢 Low | File integrity monitoring for critical paths |

### 5.5 Phase: Wi-Fi & Wireless

| Task | Priority | Description |
|------|----------|-------------|
| **External adapter manager** | 🔴 High | Auto-detect USB Wi-Fi adapters, load kernel modules |
| **Monitor mode helper** | 🔴 High | `nhctl wifi monitor {on\|off}` — enable monitor mode |
| **Kismet integration** | 🟡 Medium | Auto-start Kismet server, web UI tunnel |
| **Channel hopping** | 🟡 Medium | Configurable channel hopping for scanning |
| **Bluetooth tools** | 🟡 Medium | Bluetooth adapter mgmt, scanning, pairing |
| **SDR device support** | 🟢 Low | RTL-SDR / HackRF detection + GQRX launcher |

### 5.6 Phase: SDR & Radio

| Task | Priority | Description |
|------|----------|-------------|
| **SDR device detection** | 🟡 Medium | `nh-sdr` script to auto-detect RTL-SDR, HackRF, LimeSDR |
| **Radio spectrum scanner** | 🟢 Low | Automated frequency scanning with rtl_power |
| **ADS-B decoder** | 🟢 Low | Flight tracking with dump1090 |
| **APRS/iGate** | 🟢 Low | APRS packet radio gateway |
| **NOAA APT decoder** | 🟢 Low | Weather satellite image decoding |

### 5.7 Phase: Development Environment

| Task | Priority | Description |
|------|----------|-------------|
| **Remote VS Code tunnels** | 🟡 Medium | Auto-configure VS Code Remote SSH tunnels |
| **Dev container support** | 🟡 Medium | Docker/podman inside Arch chroot |
| **CI/CD runner** | 🟡 Medium | Run CI pipelines on-device (act, woodpecker) |
| **Cross-compilation toolchain** | 🟡 Medium | Build ARM64 → x86_64, cross-arch kernels |
| **Database services** | 🟢 Low | PostgreSQL, Redis, SQLite service templates |

### 5.8 Phase: Automation & Monitoring

| Task | Priority | Description |
|------|----------|-------------|
| **Auto-backup scheduler** | 🟡 Medium | Cron-like scheduled backups |
| **Health alerting** | 🟡 Medium | Push notifications for low disk, high temp, failed services |
| **System dashboard** | 🟡 Medium | Web-based status dashboard (streamlit/grafana) |
| **Automatic ADB reconnect** | 🟢 Low | Background watchdog for ADB connection |
| **Usage telemetry (local)** | 🟢 Low | Track uptime, backup success, service reliability |

### 5.9 Phase: C Tooling Expansion

| Task | Priority | Description |
|------|----------|-------------|
| **Native Android diagnostics** | 🟡 Medium | C binaries for battery, temp, process monitoring |
| **C unit tests** | 🟡 Medium | `make test-c` actually runs tests |
| **ADB multiplexer** | 🟢 Low | Lightweight ADB-over-SSH tunnel in C |
| **Kernel module helpers** | 🟢 Low | C-based kernel module loader/unloader |

### 5.10 Phase: CI/CD & Releases

| Task | Priority | Description |
|------|----------|-------------|
| **Automated rootfs build** | 🔴 High | CI pipeline to build/test Arch/Kali rootfs images |
| **Magisk module CI test** | 🟡 Medium | CI tests flashable module in emulator |
| **Automated releases** | 🟡 Medium | GitHub Releases on tag push |
| **Cross-arch CI matrix** | 🟡 Medium | Test on arm64, amd64, armv7 |
| **Container registry** | 🟢 Low | Push Docker images to GHCR |

---

## 6. Package & Tool Inventory

### 6.1 Host-Side Dependencies

| Tool | Required | Version | Purpose |
|------|----------|---------|---------|
| `adb` | ✅ | any | Android Debug Bridge |
| `bash` | ✅ | 4+ | Script execution |
| `make` | ✅ | any | Build system |
| `gcc` | ✅ | any | C compilation |
| `openssh-client` | ✅ | any | SSH connections |
| `git` | ⚠ | any | Version control |
| `file` | ⚠ | any | Binary detection |
| `shellcheck` | ⬜ | any | Optional lint |
| `bats` | ⬜ | any | Optional test runner |
| `docker` | ⬜ | any | Optional container build |

### 6.2 Arch Chroot Packages

| Category | Packages |
|----------|----------|
| **Base** | sudo, zsh, openssh, git, vim, neovim, tmux |
| **Languages** | python, python-pip, nodejs, npm, rust, cargo, go, jdk-openjdk |
| **Compilers** | gcc, clang, cmake, ninja, make, base-devel |
| **Security** | nmap, tcpdump, wireshark-cli, tor, torsocks, proxychains-ng, gdb, radare2 |
| **Privacy** | wireguard-tools, tor, torsocks, proxychains-ng |
| **Dev tools** | ripgrep, fd, fzf, jq, bat, lsd, duf, dog, dust, hyperfine, procs, bottom |
| **Editors** | neovim, vim, starship |

### 6.3 Kali Chroot Packages

| Category | Packages |
|----------|----------|
| **Desktop** | xfce4, xfce4-terminal, tigervnc-standalone-server, dbus-x11 |
| **Pentest** | nmap, netcat-openbsd, tcpdump, hydra, john, hashcat, sqlmap, metasploit-framework |
| **Wireless** | aircrack-ng, reaver, bully, wireshark |
| **Web** | burpsuite, gobuster, dirb, nikto, exploitdb |
| **Bluetooth** | bluez, bluez-tools, bluetooth |
| **SDR** | gnuradio, gqrx-sdr, rtl-sdr, hackrf |
| **Dev** | git, vim, neovim, build-essential, cmake, python3-dev, python3-venv |

### 6.4 Termux Packages

| Category | Packages |
|----------|----------|
| **Shell** | zsh, starship |
| **Connectivity** | openssh, termux-services |
| **Utils** | git, ripgrep, fd, fzf, jq, bat, tmux, neovim |
| **Android** | termux-api |

---

## 7. Key Metrics

| Metric | Value |
|--------|-------|
| **Total scripts** | 81 (42 device-bin + 17 setup + 14 host + 6 magisk + 2 C) |
| **make targets** | 25 |
| **nhctl commands** | 24 |
| **Docs files** | 10 |
| **Tests passing** | 116 |
| **Test coverage** | shell syntax, C syntax, JSON validation, file existence, permissions, shebangs |
| **Build artifacts** | 2 C binaries, 1 Magisk flashable zip, 46 staged payload files |
| **Chroot packages (Arch)** | 467+ |
| **Chroot packages (Kali)** | 600+ (when installed) |

---

## 8. Real Device State (Live Verification)

| Check | Status | Detail |
|-------|--------|--------|
| Wireless ADB | ✅ | `10.0.0.113:52104` |
| Root access | ✅ | `/debug_ramdisk/su` |
| Chroot mounts | ✅ | Arch + Kali proc/sys/dev/workspace |
| Arch rootfs | ✅ | 467+ packages |
| Kali rootfs | 🟡 | Auto-install via nhctl install-kali |
| sshd (Arch :2222) | ✅ | Running |
| sshd (Termux :8022) | ✅ | Running |
| WireGuard | ✅ | Configured |
| sudo wrapper | ✅ | Deployed (no hangs) |
| bootkali fixes | ✅ | Deployed (no `which` hangs) |
| NetHunter app | 🟡 | Auto-install via nhctl install-nethunter |
| Custom kernel | ⬜ | Not flashed (pending) |

---

## 9. Version History

| Version | Profile | Date | Changes |
|---------|---------|------|---------|
| `2.0-full` | nextgen | 2026-05-07 | Full v2.0: 42 nhsystem-bin tools, 22 nhctl commands, dual chroots, sudo wrapper, bootkali fixes, 116 tests, doc suite, CI/CD |
| `1.0` | classic | 2026-04 | Initial: basic Arch/Kali chroot, nhsystem-bin core, ADB automation |

---

## 10. Quick-Start for New Devices

To adapt this project for a **different phone or Android version**:

```bash
# 1. Fork the project
git clone <your-fork>

# 2. Update device variables
vim nh-defaults.sh
# Change: DEVICE_IP, ADB_PORT, NH_DEVICE_NAME, NH_DEVICE_CODENAME, etc.

# 3. Connect ADB
adb connect <your-phone-ip>:<port>

# 4. Run preflight
make stage
./nhctl doctor

# 5. Deploy tools
./nhctl deploy-tools

# 6. Install rootfs
#   - Arch:  adb push ArchLinuxARM-aarch64-latest.tar.gz /sdcard/
#            adb shell /data/local/nhsystem/bin/nh-mount arch
#            ...then run arch-fast-install.sh inside chroot
#   - Kali:  Download Kali NetHunter rootfs, extract to /data/local/nhsystem/roots/kali-arm64

# 7. Verify
./nhctl status
./nhctl health
```

For multi-device support:

```bash
# Set per-device configs
ADB_SERIAL=192.168.1.50:45678 ./nhctl status
```

---

## Legend

| Symbol | Meaning |
|--------|---------|
| ✅ | Done — implemented and tested |
| 🔴 High | Critical next priority |
| 🟡 Medium | Important but not blocking |
| 🟢 Low | Nice-to-have / exploratory |
| ⬜ | Optional / not implemented |
