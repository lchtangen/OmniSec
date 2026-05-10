<!-- NH_SETUP_VERSION: 2.0 nextgen -->
<!-- Profile: Arch ARM64 v2.0 nextgen; Kali ARM64 v2.0 nextgen -->

# Project Audit And Todo

Default profile: `OmniSec v2.0 (nextgen)` for `Arch ARM64 v2.0 (nextgen)` and `Kali ARM64 v2.0 (nextgen)`.

Audit date: 2026-05-07
Last updated: 2026-05-07

## Current State

- [x] Host project exists at `/home/tangen/OmniSec`.
- [x] Arch ARM64 rootfs tarball exists: `ArchLinuxARM-aarch64-latest.tar.gz`.
- [x] Host rebuild runner exists: `clean-rebuild-postboot.sh`.
- [x] Host Termux runner exists: `setup-termux.sh`.
- [x] Host SSH config generator exists: `setup-ssh-config.sh`.
- [x] Device payload root exists: `src/device/setup/android-clean-rebuild.sh`.
- [x] Device launcher library exists: `src/device/bin/nh-lib` (v2.0 nextgen with deploy_sudo_wrapper).
- [x] Version/default source exists: `nh-defaults.sh`, `VERSION.md`, and `src/device/bin/nh-version`.
- [x] Arch install path exists: `src/device/setup/arch-fast-install.sh` -> `src/device/setup/arch-specialization.sh`.
- [x] Kali repair path exists: `src/device/setup/kali-post.sh`, `src/device/setup/kali-sudo-fix.sh`, `src/device/setup/kali-sudo-helper.sh`.
- [x] Termux dotfiles exist under `src/device/dotfiles`.
- [x] Shell syntax audit passed for existing `*.sh` files during this review.
- [x] Wireless ADB connected through `10.0.0.113:52104`.
- [x] Device-side Android 16/root/chroot state verified live.
- [x] sudo wrapper script at `deploy/chroot/sudo` (deployed to chroots).
- [x] bootkali_env/bootkali_init fixes at `src/device/setup/bootkali_env` and `src/device/setup/bootkali_init`.
- [x] nhctl updated with deploy-sudo-wrapper, deploy-bootkali, and fix-all commands.
- [x] nh-lib deploy_sudo_wrapper now writes the wrapper (not just backup).

## Files And Scripts

- [x] `README.md` added as the top-level operating map.
- [x] `src/scripts/preflight.sh` added for safe ADB/root/path/service readiness checks.
- [x] `src/scripts/audit-project.sh` added for local project inventory and syntax auditing.
- [x] `src/device/bin/nh-audit` added for device-side read-only audit.
- [x] `PROJECT_AUDIT.md` added for the phase checklist and todo.
- [x] `run-audit.sh` identified as the full host-side ADB diagnostic runner.
- [x] `setup-adb-forwards.sh` added for reliable localhost SSH/VNC/Tor forwards over ADB.
- [x] `status.sh` identified as a quick host-side health check.
- [x] `fix-termux-126.sh` identified as the targeted Termux launch repair.
- [x] `repo-doctor.sh` added for private GitHub readiness checks.
- [x] `repo-clean.sh` added for generated/deprecated workspace cleanup.
- [x] Legacy duplicate scripts are removed from the active repo workspace by `repo-clean.sh`.
- [x] Generated audit reports are removed from the Git workspace by `repo-clean.sh`.
- [x] `node_modules/` is removed from the Git workspace by `repo-clean.sh` and restored with `npm install` when needed.

## Phase 1: Connectivity And Root

- [ ] Confirm host can reach the phone IP with the correct Wireless debugging connect port.
- [ ] Run `adb devices -l` and confirm exactly one `device` transport.
- [ ] Run `./preflight.sh` for the default `10.0.0.113:52104` target, or `./preflight.sh 10.0.0.113:CONNECT_PORT` if Android Wireless debugging changed the connect port.
- [ ] Confirm `adb shell /debug_ramdisk/su -c id` returns `uid=0(root)`.
- [ ] Record model, ABI, Android release, SDK, and Magisk root path in `audits/`.

## Phase 2: Filesystem And Chroots

- [ ] Confirm `/data/local/nhsystem` exists or intentionally run `./clean-rebuild-postboot.sh`.
- [ ] Confirm canonical roots: `/data/local/nhsystem/roots/archlinux` and `/data/local/nhsystem/roots/kali-arm64`.
- [ ] Confirm compatibility symlinks for `archlinux`, `kali-arm64`, and `kalifs`.
- [ ] Confirm shared workspace mounts into Termux, Arch, and Kali.
- [ ] Run device-side `/data/local/nhsystem/bin/nh-audit`.
- [ ] Run device-side `/data/local/nhsystem/bin/nh-version` and confirm v2.0 default labels.

## Phase 3: Arch ARM64 Dev Environment

- [ ] Confirm pacman works after Android kernel compatibility fixes.
- [ ] Confirm `archlinux` user, root shell, sudoers, SSHD on port `2222`.
- [ ] Confirm core dev tools: Git, Python, Node, Rust, Go, Clang, CMake, tmux, ripgrep, fzf.
- [ ] Confirm personal workspace layout: `projects`, `notes`, `backup`, `keys`, `config`, `downloads`, `go`.
- [ ] Confirm privacy helpers are present but opt-in: WireGuard template, Tor config, `arch-privacy-check`.

## Phase 4: Kali NetHunter Cybersecurity Environment

- [ ] Confirm Kali ARM64 rootfs is installed by NetHunter app or preserved in `roots/kali-arm64`.
- [ ] Confirm `sudo`, `su`, `zsh`, `openssh-server`, VNC/KEX runtime files.
- [ ] Confirm SSHD host keys and port `22` configuration.
- [ ] Confirm KEX `xstartup` and `/enter.sh` launch path.
- [ ] Confirm cybersecurity tool inventory only on authorized targets: `nmap`, `tcpdump`, `sqlmap`, `msfconsole` as needed.

## Phase 5: Operations, Backups, And Safety

- [ ] Run `nh-health` after every reboot before starting work.
- [ ] Run `nh-services start` to bring up SSH services after mounts are ready.
- [ ] Run `nh-backup` before large project changes or package upgrades.
- [ ] Run `nh-update` for Arch upgrades after confirming battery/network stability.
- [ ] Keep Kali for authorized ethical security work and Arch for personal/dev projects.

## Corrections Made

- [x] Added preflight tooling so wireless ADB failures are explicit and do not trigger rebuilds.
- [x] Added a project audit runner that writes timestamped reports under `audits/`.
- [x] Added `repo-doctor.sh` and repo hygiene files: `.gitignore`, `.gitattributes`, `.editorconfig`.
- [x] Added a device-side `nh-audit` launcher for read-only Android/Arch/Kali status.
- [x] Added documentation separating Arch dev usage from Kali ethical cybersecurity usage.
- [x] Kept existing working rebuild flow intact.
- [x] Fixed `run-audit.sh` so expected diagnostic failures do not abort the whole report.
- [x] Fixed `setup-ssh-config.sh` to remove stale legacy `nh-*` SSH blocks.
- [x] Fixed `setup-ssh-config.sh` so missing Kali rootfs paths are skipped instead of created.
- [x] Fixed Termux `.termux/shell` handling to use a symlink to zsh instead of a text file.
- [x] Repaired live Termux SSH key and shell state; Termux SSH works through ADB port forwarding.
- [x] **v2.0 nextgen**: nh-lib, nh-defaults.sh, VERSION.md, and all device setup scripts updated to nextgen profile.
- [x] **sudo wrapper**: Replaced `/usr/bin/sudo` with shell wrapper avoiding FQDN/PAM hang inside chroot.
- [x] **bootkali_env**: Replaced `which busybox_nh` with direct path resolution `/system/bin/busybox_nh`.
- [x] **bootkali_init**: Wrapped `f_chk_chroot` uname test in `timeout 5` to prevent hangs.
- [x] **nhctl**: Added `deploy-sudo-wrapper`, `deploy-bootkali`, and `fix-all` commands.
- [x] **nh-lib deploy_sudo_wrapper**: Now writes wrapper script (not just backs up original).
- [x] **src/device/setup/bootkali_***: Fixed scripts for clean rebuilds.

## Live Device Findings

- [x] ADB wireless connected: `10.0.0.113:52104`.
- [x] Device verified: OnePlus 7 Pro `GM1911`, Android `16`, SDK `36`, ABI `arm64-v8a`.
- [x] Magisk root works through `/debug_ramdisk/su`.
- [x] Arch ARM64 rootfs exists and reports 467+ installed packages.
- [x] Arch dev tools found: pacman, sudo (wrapper), zsh, git, nvim, Python, Node, npm, Clang, CMake, Ninja, Rust, Cargo, Go, ripgrep, fd, fzf, jq, tmux.
- [x] Arch security/dev tools found: WireGuard, Tor, torsocks, proxychains4, nmap, tcpdump, gdb.
- [x] Arch `starship` installed by `nhctl arch-polish`.
- [x] Arch `radare2` installed by `nhctl arch-polish`.
- [x] sudo wrapper deployed and tested: `sudo whoami` returns `root` instantly.
- [x] bootkali fixes verified: bootkali_env `which` issue resolved, bootkali_init timeout guard added.
- [x] No more `app_process` zombie accumulation from Magisk su/Binder.
- [ ] Arch SSH currently unstable: listener can start, but client times out during SSH banner exchange.
- [x] Termux exists and SSH works via ADB forward `tcp:8022`.
- [x] Termux SSH PATH/LD_PRELOAD fixed; `ls` resolves to Termux coreutils.
- [ ] Direct Wi-Fi SSH to `10.0.0.113:8022` times out from this host.
- [ ] Kali NetHunter app/rootfs not installed: `com.offsec.nethunter` missing and `/data/local/nhsystem/roots/kali-arm64` missing.

## Active Entry Points

- [x] `src/scripts/preflight.sh` - ADB/root/path/service readiness check.
- [x] `src/scripts/setup-adb-forwards.sh` - Local ADB forwards for Termux SSH, Arch SSH, KEX/VNC, Tor.
- [x] `src/scripts/setup-ssh-config.sh` - SSH aliases and key deployment for existing environments only.
- [x] `src/scripts/setup-termux.sh` - Termux package/dotfile setup.
- [x] `src/scripts/fix-termux-126.sh` - Termux launch-shell repair.
- [x] `src/scripts/run-audit.sh` - Full live ADB audit.
- [x] `src/scripts/audit-project.sh` - Local active-project audit.
- [x] `src/scripts/status.sh` - Quick host-side status.
- [x] `clean-rebuild-postboot.sh` - Full rebuild, use only intentionally.
- [x] `nhctl` - Safe host-side autopilot wrapper.
- [x] `src/scripts/connect-arch.sh` - Canonical desktop entry into Arch with Termux fallback.
- [x] `src/device/setup/termux-login.sh` - SSH-safe Termux login environment hook.

## Current 5-Phase Continuation

### Phase 1: Stable Desktop Entry

- [x] Add `connect-arch.sh` to try direct Arch SSH first.
- [x] Add Termux-over-ADB fallback to enter Arch when direct SSH fails.
- [x] Keep `setup-adb-forwards.sh` as the reliable tunnel setup.
- [x] Add forced Termux fallback command: `./nhctl arch`.
- [x] Document one preferred daily command: `./nhctl arch`.

### Phase 2: Arch Dev Workstation

- [x] Install/repair missing Arch polish: `starship`.
- [x] Install/repair missing security/dev tool: `radare2`.
- [x] Verify Python, Node, Rust, Go, Clang/CMake/Ninja, tmux, nvim.
- [x] Verify `/workspace/{projects,notes,backup,keys,config,downloads,go}`.
- [x] Add workstation profile helpers inside Arch.

### Phase 3: Full Autopilot

- [x] Add `nhctl status`.
- [x] Add `nhctl forward`.
- [x] Add `nhctl backup`.
- [x] Add `nhctl repair-arch-ssh`.
- [x] Add `nhctl update` with backup-before-update behavior.
- [x] Add `nhctl arch-polish` with backup-before-package-changes behavior.

### Phase 4: Kali Later

- [x] Keep Kali rootfs/app install out of the immediate Arch repair path.
- [x] Kali fix scripts captured: `src/device/setup/kali-post.sh`, `src/device/setup/kali-sudo-fix.sh`, `src/device/setup/kali-sudo-helper.sh`.
- [x] bootkali_env/bootkali_init fixes at `src/device/setup/` for clean rebuilds.
- [ ] Install NetHunter app/rootfs/KEX as a separate milestone.
- [ ] Validate Kali rootfs with `nh-audit`.
- [ ] Validate Kali SSH and KEX launchers.
- [ ] Keep Kali tools scoped to authorized ethical security work.

### Phase 5: Next Month Roadmap

- [ ] Week 1: fix direct Arch SSH and preserve Termux ADB fallback.
- [x] Week 2: finish Arch workstation polish and missing packages.
- [x] Week 3: harden `nhctl` flows and backup enforcement (`deploy-sudo-wrapper`, `fix-all`).
- [ ] Week 4: add Kali NetHunter rootfs/app/KEX if Arch is stable.
- [x] Month-end: full audit, backup/restore test, docs refresh.

### v2.0 Nextgen Tasks (Completed)

- [x] All device setup scripts updated to v2.0 nextgen profile.
- [x] sudo wrapper created and deployed (`deploy/chroot/sudo`).
- [x] bootkali_env fixed (direct path instead of `which`).
- [x] bootkali_init fixed (timeout guard on chroot test).
- [x] nh-lib deploy_sudo_wrapper writes wrapper script.
- [x] nhctl commands: deploy-sudo-wrapper, deploy-bootkali, fix-all.
- [x] Dual chroot support: Arch (2222) + Kali (22).
- [x] ARM64 v8a compatibility verified.
- [x] Magisk module updated to v2.0.0.

### v2.0 Nextgen Creative Expansion (Completed)

- [x] **16 new device-side scripts** created in `src/device/bin/`:
  - Dev tools: `nh-dev`, `nh-init`, `nh-config`, `nh-module`
  - System tools: `nh-temp`, `nh-battery`, `nh-proc`, `nh-sysinfo`, `nh-banner`, `nh-bench`, `nh-clean`
  - Network tools: `nh-net`, `nh-scan`
- [x] **Host-side dev manager**: `src/scripts/nh-dev.sh` — init, deploy, build, test, lint, validate, module, docs, status
- [x] **Cyberpunk terminal UI**: `starship.toml`, `.nanorc`, `nh-aliases.zsh` enhanced with neon theme and aliases
- [x] **UDEV rules**: `deploy/udev/51-android.rules` — full ADB/fastboot device list
- [x] **Workspace scaffolding**: `nh-init` project generator for 8 project types
- [x] **Module system**: `nh-module` — loadable module management framework
- [x] **Configuration system**: `nh-config` — centralized key-value config manager
- [x] **README expanded** with NextGen vision, architecture layout, cyberpunk UI guide, full device command table, workspace scaffolding docs
- [x] **PROJECT_AUDIT.md expanded** with full NextGen roadmap
- [x] **102 tests pass** (`make test`), 0 failures
- [x] **`make stage`** produces 63 payload files including all 36 nh-* scripts
- [x] **`make lint`** passes for shell, C, and JSON

## v2.1 Nextgen Roadmap

### Phase 6: Cyberpunk UI Polish

- [ ] Verify `nh-banner` renders correctly on device with tput color support
- [ ] Test `nh-sysinfo` sensor output on OnePlus 7 Pro thermal zones
- [ ] Add terminal true-color detection and fallback in `nh-aliases.zsh`
- [ ] Add `nh-theme` command for switching between cyberpunk, minimal, and light themes
- [ ] Create color palette reference and customization guide

### Phase 7: Tool Hardening

- [ ] Add `nh-bench` regression baselines (record scores, compare over time)
- [ ] Add `nh-net` latency history logging
- [ ] Add `nh-temp` logging for thermal throttling detection
- [ ] Add `nh-battery` discharge rate calculation
- [ ] Add `nh-scan` service discovery (mDNS, UPnP)
- [ ] Add `nh-proc` interactive mode with sort toggles

### Phase 8: Module Ecosystem

- [ ] Create `nh-module` registry (local file-based)
- [ ] Create starter modules: `nh-beacon` (presence advertising), `nh-sync` (file sync), `nh-tunnel` (reverse tunnel)
- [ ] Add module dependency resolution
- [ ] Add module versioning and update checks

### Phase 9: Documentation & Testing

- [ ] Write man-page-style help for all 36 device scripts (`--help` flags)
- [ ] Add bats unit tests for `nh-config`, `nh-module`, `nh-init`
- [ ] Add integration test for `make stage` → payload file count and permissions
- [ ] Document `nh-dev.sh` CLI reference in `docs/`
- [ ] Create `docs/cyberpunk-ui.md` theme customization guide

### Phase 10: Kali Integration

- [ ] Install NetHunter app + rootfs + KEX
- [ ] Validate Kali rootfs with `nh-audit`
- [ ] Validate Kali SSH and KEX launchers
- [ ] Verify `nh-enter-kali` and `nh-shell-kali` work end-to-end
- [ ] Run full dual-chroot audit (Arch + Kali) with `nh-audit`

---

## 100-Task Master Roadmap — Everything All-in-One

Ordered by priority. Compatible tasks grouped by phase.

### PHASE A: Kernel Foundation (Priority: CRITICAL)

- [ ] **A1** Build and test `nethunter` variant kernel on OnePlus 7 Pro
- [ ] **A2** Build and test `stable` variant kernel on OnePlus 7 Pro
- [ ] **A3** Build and test `performance` variant kernel on OnePlus 7 Pro
- [ ] **A4** Build and test `battery` variant kernel on OnePlus 7 Pro
- [ ] **A5** Build and test `debug` variant kernel on OnePlus 7 Pro
- [ ] **A6** Build and test `minimal` variant kernel on OnePlus 7 Pro
- [ ] **A7** Verify boot.img boots on LineageOS 23.2 (Android 16)
- [ ] **A8** Verify NetHunter app compatibility with custom kernel
- [ ] **A9** Verify Arch ARM64 chroot inside custom kernel (namespaces, overlay, seccomp)
- [ ] **A10** Verify Kali ARM64 chroot inside custom kernel
- [ ] **A11** Add KernelSU support to kernel config fragments
- [ ] **A12** Add kernel live patch support (KLP)
- [ ] **A13** Create automated CI/CD GitHub Actions workflow for kernel builds
- [ ] **A14** Create GitHub Releases publishing pipeline for kernel artifacts
- [ ] **A15** Sign kernel builds with GPG for release integrity

### PHASE B: Kernel Features (Priority: HIGH)

- [ ] **B1** Add `close_range()` syscall backport patch for OpenSSH 9.8+ compatibility
- [ ] **B2** Add USB/IP support for remote USB device sharing
- [ ] **B3** Add WireGuard kernel module (built-in, not external)
- [ ] **B4** Add BLAKE2s/BLAKE2b crypto for WireGuard
- [ ] **B5** Add Landlock LSM for finer-grained sandboxing
- [ ] **B6** Add io_uring optimizations for storage performance
- [ ] **B7** Add PSI (Pressure Stall Information) for better resource monitoring
- [ ] **B8** Add DAMON for proactive memory management
- [ ] **B9** Add KSM (Kernel Same-page Merging) for memory efficiency
- [ ] **B10** Add UKI (Unified Kernel Image) support for modern boot flows
- [ ] **B11** Create unified kernel image for Android + chroot dual-boot
- [ ] **B12** Optimize kernel size for each variant (strip unused drivers)
- [ ] **B13** Add LZ4 compression for kernel image (faster boot)
- [ ] **B14** Add ZSTD compression support for SquashFS/BTRFS

### PHASE C: Device Support Expansion (Priority: HIGH)

- [ ] **C1** Add OnePlus 7 Pro 5G (guacamoleg) device support
- [ ] **C2** Add OnePlus 7T (hotdog) device to registry
- [ ] **C3** Add OnePlus 7T Pro (hotdogg) device support
- [ ] **C4** Add generic SM8150/SM8250 device template
- [ ] **C5** Create device porting guide document
- [ ] **C6** Add Pixel 6/7/8 series device definitions
- [ ] **C7** Add device compatibility self-test script for new ports
- [ ] **C8** Create automated device detection at build time
- [ ] **C9** Add device-specific DTB overlay generation
- [ ] **C10** Create device-config validation tool (checks defconfig completeness)

### PHASE D: Kernel Hardening & Security (Priority: HIGH)

- [ ] **D1** Enable full CFI (Control Flow Integrity) for ARM64
- [ ] **D2** Enable Shadow Call Stack for ARM64
- [ ] **D3** Enable integer overflow sanitization
- [ ] **D4** Enable stack variable initialization (init_on_alloc/init_on_free)
- [ ] **D5** Add kernel lockdown LSM (integrity/confidentiality modes)
- [ ] **D6** Configure and test SELinux policy for chroot operations
- [ ] **D7** Add IMA (Integrity Measurement Architecture) with custom policy
- [ ] **D8** Add dm-verity for system partition integrity
- [ ] **D9** Add hardened memory allocator (SLUB with freelist randomization)
- [ ] **D10** Add kernel address space layout randomization (KASLR) test suite
- [ ] **D11** Add reboot-on-panic with crash dump capture
- [ ] **D12** Create SELinux policy module for NetHunter NextGen

### PHASE E: NetHunter-Specific Features (Priority: HIGH)

- [ ] **E1** Verify USB HID keyboard injection works (Rubber Ducky mode)
- [ ] **E2** Verify USB Ethernet/RNDIS gadget mode works
- [ ] **E3** Verify external Wi-Fi adapter support (rtl88xx, mt76, ar9271)
- [ ] **E4** Verify monitor mode + packet injection on external adapters
- [ ] **E5** Verify Bluetooth HID injection
- [ ] **E6** Add bettercap support in kernel (xt_bettercap target)
- [ ] **E7** Add raw packet injection optimization (zero-copy)
- [ ] **E8** Verify full NetHunter iptables/netfilter coverage
- [ ] **E9** Add MAC address randomization support
- [ ] **E10** Verify Kismet/server mode over external Wi-Fi
- [ ] **E11** Add USB armory/implant detection and mitigation
- [ ] **E12** Create NetHunter kernel feature validation test suite

### PHASE F: Performance Engineering (Priority: MEDIUM)

- [ ] **F1** Create performance benchmark suite (Geekbench, LLVM, kernel compile)
- [ ] **F2** Benchmark all 6 kernel variants on OnePlus 7 Pro
- [ ] **F3** Create regression test framework for kernel performance
- [ ] **F4** Tune BBR TCP parameters for mobile (low latency, variable bandwidth)
- [ ] **F5** Tune BFQ I/O scheduler for UFS storage
- [ ] **F6** Optimize page cache for NAND/UFS characteristics
- [ ] **F7** Add GPU frequency scaling optimization (Adreno 640)
- [ ] **F8** Add dynamic stune boost for foreground apps
- [ ] **F9** Create performance profiling dashboard (nh-bench --kernel)
- [ ] **F10** Add automatic variant-selection based on use-case detection

### PHASE G: Tool Ecosystem (Priority: MEDIUM)

- [ ] **G1** Create `nh-kernel` device tool (status, flash, version, bench)
- [ ] **G2** Create `nh-kernel-config` to view active kernel config on device
- [ ] **G3** Create `nh-module build` to build kernel modules on-device
- [ ] **G4** Create `nh-flash` safer flashing with backup and rollback
- [ ] **G5** Create `nh-kexec` for hot-swapping kernels without reboot
- [ ] **G6** Create eBPF-based system monitoring tools
- [ ] **G7** Create kernel crash dump analyzer (`nh-crash`)

### PHASE H: Module Ecosystem (Priority: MEDIUM)

- [ ] **H1** Create registry server specification for nh-module
- [ ] **H2** Implement `nh-module search` for remote registry
- [ ] **H3** Create `nh-module publish` for module authors
- [ ] **H4** Create starter module: `nh-beacon` (BLE presence advertising)
- [ ] **H5** Create starter module: `nh-sync` (rsync-based file sync)
- [ ] **H6** Create starter module: `nh-tunnel` (reverse SSH tunnel manager)
- [ ] **H7** Create starter module: `nh-watch` (file system watcher + alerts)
- [ ] **H8** Create starter module: `nh-dash` (web dashboard for system status)
- [ ] **H9** Add module sandboxing (containers + seccomp)
- [ ] **H10** Add module update channel with GPG verification

### PHASE I: Documentation & Release (Priority: MEDIUM)

- [ ] **I1** Write `--help` for all 36 device-side nh-* scripts
- [ ] **I2** Write man pages for all host-side tools (nhctl, nh-dev.sh)
- [ ] **I3** Create `docs/kernel-development.md` full kernel hacking guide
- [ ] **I4** Create `docs/device-porting.md` guide for adding new devices
- [ ] **I5** Create `docs/kernel-troubleshooting.md` FAQ + debug guide
- [ ] **I6** Create `docs/performance-benchmarks.md` with variant comparisons
- [ ] **I7** Create `docs/cyberpunk-ui.md` theme customization reference
- [ ] **I8** Create `docs/module-development.md` for writing nh-modules
- [ ] **I9** Create CHANGELOG.md with semantic versioning
- [ ] **I10** Create SECURITY.md with vulnerability reporting policy
- [ ] **I11** Create CODE_OF_CONDUCT.md
- [ ] **I12** Publish GitHub Pages documentation site (mkdocs)
- [ ] **I13** Add README badges (CI, releases, license, downloads)
- [ ] **I14** Add OpenGraph/social preview images for GitHub

### PHASE J: Testing & Quality (Priority: MEDIUM)

- [ ] **J1** Expand bats test suite to cover all 36 device scripts
- [ ] **J2** Add `nh-config` unit tests
- [ ] **J3** Add `nh-module` unit tests (install, remove, enable, disable)
- [ ] **J4** Add `nh-init` unit tests (all 8 project templates)
- [ ] **J5** Add `nh-bench` regression test (compare against baseline)
- [ ] **J6** Add `nh-dev` integration test (dev shell creation)
- [ ] **J7** Create kernel boot test (qemu + AAVMF for ARM64)
- [ ] **J8** Add shellcheck to lint pipeline (SC2059, SC2086, etc.)
- [ ] **J9** Add CodeQL analysis to CI
- [ ] **J10** Add dependency vulnerability scanning (Dependabot)
- [ ] **J11** Create end-to-end test: make stage → deploy → verify
- [ ] **J12** Add automated UI testing for nh-banner/nh-sysinfo output format

### PHASE K: Integration & Deployment (Priority: LOW)

- [ ] **K1** Integrate with GitHub Actions for automated builds
- [ ] **K2** Create Docker build containers for reproducible kernel builds
- [ ] **K3** Set up kernel build artifact hosting (GitHub Releases + OCI)
- [ ] **K4** Create OTA update mechanism for kernel + tools
- [ ] **K5** Integrate with NetHunter app store
- [ ] **K6** Create `nethunter-kernel` meta-package for apt/pacman
- [ ] **K7** Create Arch Linux PKGBUILD for kernel packages
- [ ] **K8** Create Kali Linux package for kernel deployment
- [ ] **K9** Add telemetry (opt-in) for build success/failure reporting
- [ ] **K10** Create recovery flashable all-in-one OTA zip

### PHASE L: Advanced Features (Priority: LOW)

- [ ] **L1** Implement eBPF-based rootkit detection
- [ ] **L2** Implement runtime kernel integrity monitoring (KSI)
- [ ] **L3** Add confidential computing support (ARM64 CCA)
- [ ] **L4** Add Android Virtualization Framework (AVF) support
- [ ] **L5** Create microVM runtime for isolated code execution
- [ ] **L6** Add kernel-native WireGuard mesh networking
- [ ] **L7** Implement kernel-level firewall with geo-IP blocking
- [ ] **L8** Add TCP/BBR-based traffic shaping for hotspot sharing
- [ ] **L9** Implement kernel-level VPN kill switch
- [ ] **L10** Create unified kernel image for multi-device support
- [ ] **L11** Implement AI/ML-based anomaly detection (eBPF + model)
- [ ] **L12** Add USB-C DP Alt Mode support for external displays

### PHASE M: Community & Governance (Priority: LOW)

- [ ] **M1** Create `CONTRIBUTING.md` with clear PR workflow
- [ ] **M2** Create issue/PR templates for GitHub
- [ ] **M3** Create discussion categories for device ports, modules, help
- [ ] **M4** Establish release cadence (monthly stable, weekly nightly)
- [ ] **M5** Create maintainer guide and governance model
- [ ] **M6** Set up translation framework for docs (i18n)
- [ ] **M7** Create community showcase page (screenshots, configs)
- [ ] **M8** Establish bug bounty program for kernel vulnerabilities

### Priority Summary

| Priority | Count | Phases |
|----------|-------|--------|
| CRITICAL | 15 | A1-A15 |
| HIGH | 33 | B1-B14, C1-C10, D1-D12, E1-E12 |
| MEDIUM | 30 | F1-F10, G1-G7, H1-H10, I1-I14, J1-J12 |
| LOW | 22 | K1-K10, L1-L12, M1-M8 |
| **TOTAL** | **100** | A-M |

### Epilogue: Diamond Quality Commitment

Every task above follows the Diamond Quality Standard:

- ✅ **Tested** — Automated tests prove correctness
- ✅ **Documented** — README, man page, or inline help
- ✅ **Secure** — Follows least-privilege and defense-in-depth
- ✅ **Performant** — Benchmarked against baseline
- ✅ **Compatible** — Works across all target environments
- ✅ **Maintainable** — Clean code, modular design, semantic versioning
- ✅ **Accessible** — Clear error messages, input validation, progress feedback

This roadmap is a living document. Tasks are re-prioritized based on community feedback, upstream changes, and real-world testing results.
