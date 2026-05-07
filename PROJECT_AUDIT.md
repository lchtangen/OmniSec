<!-- NH_SETUP_VERSION: 2.0 nextgen -->
<!-- Profile: Arch ARM64 v2.0 nextgen; Kali ARM64 v2.0 nextgen -->

# Project Audit And Todo

Default profile: `NetHunter setup v2.0 (nextgen)` for `Arch ARM64 v2.0 (nextgen)` and `Kali ARM64 v2.0 (nextgen)`.

Audit date: 2026-05-07
Last updated: 2026-05-07

## Current State

- [x] Host project exists at `/home/tangen/nethunter-setup`.
- [x] Arch ARM64 rootfs tarball exists: `ArchLinuxARM-aarch64-latest.tar.gz`.
- [x] Host rebuild runner exists: `clean-rebuild-postboot.sh`.
- [x] Host Termux runner exists: `setup-termux.sh`.
- [x] Host SSH config generator exists: `setup-ssh-config.sh`.
- [x] Device payload root exists: `payload/android-clean-rebuild.sh`.
- [x] Device launcher library exists: `payload/nhsystem-bin/nh-lib` (v2.0 nextgen with deploy_sudo_wrapper).
- [x] Version/default source exists: `nh-defaults.sh`, `VERSION.md`, and `payload/nhsystem-bin/nh-version`.
- [x] Arch install path exists: `payload/arch-fast-install.sh` -> `payload/arch-specialization.sh`.
- [x] Kali repair path exists: `payload/kali-post.sh`, `payload/kali-sudo-fix.sh`, `payload/kali-sudo-helper.sh`.
- [x] Termux dotfiles exist under `payload/termux-home`.
- [x] Shell syntax audit passed for existing `*.sh` files during this review.
- [x] Wireless ADB connected through `10.0.0.113:52104`.
- [x] Device-side Android 16/root/chroot state verified live.
- [x] sudo wrapper script at `payload/chroot-bin/sudo` (deployed to chroots).
- [x] bootkali_env/bootkali_init fixes at `payload/bootkali_env` and `payload/bootkali_init`.
- [x] nhctl updated with deploy-sudo-wrapper, deploy-bootkali, and fix-all commands.
- [x] nh-lib deploy_sudo_wrapper now writes the wrapper (not just backup).

## Files And Scripts

- [x] `README.md` added as the top-level operating map.
- [x] `preflight.sh` added for safe ADB/root/path/service readiness checks.
- [x] `audit-project.sh` added for local project inventory and syntax auditing.
- [x] `payload/nhsystem-bin/nh-audit` added for device-side read-only audit.
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
- [x] **v2.0 nextgen**: nh-lib, nh-defaults.sh, VERSION.md, and all payload scripts updated to nextgen profile.
- [x] **sudo wrapper**: Replaced `/usr/bin/sudo` with shell wrapper avoiding FQDN/PAM hang inside chroot.
- [x] **bootkali_env**: Replaced `which busybox_nh` with direct path resolution `/system/bin/busybox_nh`.
- [x] **bootkali_init**: Wrapped `f_chk_chroot` uname test in `timeout 5` to prevent hangs.
- [x] **nhctl**: Added `deploy-sudo-wrapper`, `deploy-bootkali`, and `fix-all` commands.
- [x] **nh-lib deploy_sudo_wrapper**: Now writes wrapper script (not just backs up original).
- [x] **payload/bootkali_***: Fixed scripts captured in `payload/` for clean rebuilds.

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

- [x] `preflight.sh` - ADB/root/path/service readiness check.
- [x] `setup-adb-forwards.sh` - Local ADB forwards for Termux SSH, Arch SSH, KEX/VNC, Tor.
- [x] `setup-ssh-config.sh` - SSH aliases and key deployment for existing environments only.
- [x] `setup-termux.sh` - Termux package/dotfile setup.
- [x] `fix-termux-126.sh` - Termux launch-shell repair.
- [x] `run-audit.sh` - Full live ADB audit.
- [x] `audit-project.sh` - Local active-project audit.
- [x] `status.sh` - Quick host-side status.
- [x] `clean-rebuild-postboot.sh` - Full rebuild, use only intentionally.
- [x] `nhctl` - Safe host-side autopilot wrapper.
- [x] `connect-arch.sh` - Canonical desktop entry into Arch with Termux fallback.
- [x] `payload/termux-login.sh` - SSH-safe Termux login environment hook.

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
- [x] Kali fix scripts captured: `payload/kali-post.sh`, `payload/kali-sudo-fix.sh`, `payload/kali-sudo-helper.sh`.
- [x] bootkali_env/bootkali_init fixes added to `payload/` for clean rebuilds.
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

- [x] All payload scripts updated to v2.0 nextgen profile.
- [x] sudo wrapper created and deployed (`payload/chroot-bin/sudo`).
- [x] bootkali_env fixed (direct path instead of `which`).
- [x] bootkali_init fixed (timeout guard on chroot test).
- [x] nh-lib deploy_sudo_wrapper writes wrapper script.
- [x] nhctl commands: deploy-sudo-wrapper, deploy-bootkali, fix-all.
- [x] Dual chroot support: Arch (2222) + Kali (22).
- [x] ARM64 v8a compatibility verified.
- [x] Magisk module updated to v2.0.0.
