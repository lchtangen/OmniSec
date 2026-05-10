<!-- NH_SETUP_VERSION: 2.0 default -->
<!-- Profile: Arch ARM64 v2.0 default; Kali ARM64 v2.0 default -->

# Personal 25 Project Roadmap

Default profile: `OmniSec v2.0 (default)` with `Arch ARM64 v2.0 (default)` and `Kali ARM64 v2.0 (default)`.

Date: 2026-05-07

Owner: personal/private use only.

Scope: Android 16 OnePlus 7 Pro, Arch Linux ARM64 chroot, future Kali NetHunter, custom kernel work, Wi-Fi adapter lab, and private development workflows.

## Rules For This Roadmap

- Keep this private unless sanitized. Logs can contain IPs, MACs, GPS, device IDs, SSH keys, package lists, and personal habits.
- Work only on your own devices and authorized lab networks.
- Prefer reproducible notes and scripts over one-off terminal sessions.
- Every project should finish with one artifact: script, note, config, package list, dashboard, kernel diff, or working service.
- Before risky package/kernel work, run `./nhctl backup`.

## Phase 1: Foundation And Access

### 1. Daily Device Entry Reliability

Level: beginner

Goal: make Arch entry boring and repeatable.

Build:

- A daily checklist around `adb connect`, `./nhctl status`, `./nhctl forward`, and `./nhctl arch`.
- A note showing direct SSH, Termux fallback, Arch user, and Arch root entry.

Done when:

- You can enter Arch user and root without guessing.
- You know what to do after every phone reboot.

### 2. Arch SSH Stabilization

Level: beginner to intermediate

Goal: fix the current Arch `2222` listener/banner instability.

Build:

- A reproducible repair path using `./nhctl repair-arch-ssh`.
- A device-side log checklist for `/tmp/sshd-2222.log`.
- A known-good `sshd_config` for chroot use.

Done when:

- `ssh -p 2222 archlinux@127.0.0.1` works through ADB forward.
- `ssh -p 2222 root@127.0.0.1` works only when intentionally enabled.

### 3. Workspace Layout And Notes System

Level: beginner

Goal: make `/workspace` the center of the system.

Build:

- `/workspace/projects`
- `/workspace/notes`
- `/workspace/backup`
- `/workspace/keys`
- `/workspace/config`
- `/workspace/downloads`

Done when:

- Each project has a note.
- Sensitive files live under `/workspace/keys` with strict permissions.

### 4. Backup And Restore Drill

Level: beginner

Goal: prove the setup can survive mistakes.

Build:

- A backup habit using `./nhctl backup`.
- A restore note with exact paths.
- A small test restore into a temporary directory.

Done when:

- You can restore one note/config file from backup.
- You know where backups are stored on the phone.

### 5. Package Manifest Baseline

Level: beginner

Goal: capture what makes the Arch environment yours.

Build:

- `pacman -Qqe` package manifest.
- pipx, cargo, npm, and go tool manifests.
- A bootstrap note for reinstalling key tools.

Done when:

- You can rebuild the dev environment from a clean Arch rootfs with fewer guesses.

## Phase 2: Arch Development Workstation

### 6. Terminal Power Workbench

Level: beginner

Goal: master `tmux`, `zsh`, `nvim`, `rg`, `fd`, `fzf`, and `jq`.

Build:

- A `tmux` session template for phone development.
- A personal shell cheatsheet.
- A minimal `nvim` configuration note.

Done when:

- You can work for one hour in Arch without returning to the desktop shell.

### 7. Python Toolchain Lab

Level: beginner to intermediate

Goal: make Arch a clean Python automation environment.

Build:

- `pipx` based tools.
- A small CLI that runs `nh-status` style checks and emits JSON.
- Formatting with `ruff`.

Done when:

- You have one useful Python CLI under `/workspace/projects`.

### 8. Rust CLI Lab

Level: intermediate

Goal: learn Rust for fast device tooling.

Build:

- A Rust CLI that parses audit logs.
- Output modes: text and JSON.
- Basic tests.

Done when:

- The tool reads files from `audits/` and summarizes device health.

### 9. Go Network Utility Lab

Level: intermediate

Goal: learn simple network service development.

Build:

- A small Go service that serves local device status on localhost only.
- No public binding.
- Optional system/service launcher later.

Done when:

- You can query phone/Arch status from a browser or `curl` over a forwarded port.

### 10. Local Dev Dashboard

Level: intermediate

Goal: build a private dashboard for this project.

Build:

- Static or lightweight web UI.
- Shows ADB state, Arch status, storage, backups, package count, and open forwards.

Done when:

- You have a dashboard that makes the setup easier to operate.

## Phase 3: Android Development

### 11. Android App Build Pipeline

Level: beginner to intermediate

Goal: build and install a basic Android app to the OnePlus 7 Pro.

Build:

- Kotlin app with a simple status screen.
- ADB install workflow.
- Release/debug signing notes.

Done when:

- You can build, install, run, and uninstall your own APK.

### 12. Jetpack Compose Control Panel

Level: intermediate

Goal: build a phone-native control panel for your environment.

Build:

- Compose UI for status, service buttons, and links into Termux/NetHunter.
- Read-only first. Actions require confirmation.

Done when:

- The app displays local project status without needing a terminal.

### 13. Kotlin Multiplatform Shared Logic

Level: intermediate

Goal: follow the current Android direction and share logic cleanly.

Build:

- KMP module for parsing audit/status JSON.
- Android UI consumes it.
- JVM command-line test consumes the same logic.

Done when:

- One parser runs in Android and on desktop/Arch JVM.

### 14. Android Sensor And Context Logger

Level: intermediate

Goal: learn Android APIs safely.

Build:

- Local-only logger for battery, thermals, charging state, network type, and storage.
- No cloud sync.

Done when:

- You can correlate phone thermals/battery with Arch builds and Wi-Fi adapter usage.

### 15. Private Android Automation Helper

Level: advanced

Goal: explore Android automation carefully.

Build:

- A local helper that triggers safe routines: start notes, open dashboard, show status, start backup.
- Avoid SMS/calls/destructive actions until the approval model is solid.

Done when:

- You have one personally useful, non-dangerous automation flow.

## Phase 4: Wi-Fi Adapter And Wireless Engineering

### 16. Adapter Bring-Up

Level: beginner

Goal: identify the unopened adapter and decide if it fits the roadmap.

Build:

- USB ID and chipset note.
- Desktop Linux test.
- Android OTG power test.
- Arch chroot visibility test.

Done when:

- You know whether to keep the adapter.

### 17. Passive Monitor Mode Learning

Level: beginner

Goal: learn Wi-Fi frame observation in a legal lab.

Build:

- Monitor-mode notes.
- Own AP channel observations.
- No third-party traffic capture.

Done when:

- You understand managed mode, monitor mode, channels, RSSI, BSSID, and SSID.

### 18. Kismet Passive Sensor

Level: intermediate

Goal: run a private passive Wi-Fi sensor.

Build:

- Kismet source config.
- Private log storage.
- Sanitization checklist.

Done when:

- You can start Kismet and collect data from your own lab environment.

### 19. Own-Network Coverage And Throughput Map

Level: intermediate

Goal: use the adapter for practical network engineering.

Build:

- `iperf3` test plan.
- RSSI/channel notes.
- Small coverage map for home/lab.

Done when:

- You can improve your own Wi-Fi placement from measured data.

### 20. Wi-Fi Kernel Capability Matrix

Level: advanced

Goal: connect adapter needs to custom kernel config.

Build:

- `nh-wifi-check` concept.
- Required modules and kernel config list.
- Per-kernel test results.

Done when:

- Every future kernel build has a Wi-Fi validation checklist.

## Phase 5: NetHunter And Kernel Work

### 21. Kali NetHunter Install Milestone

Level: intermediate

Goal: install Kali/NetHunter as a separate milestone after Arch is stable.

Build:

- Rootfs/app install plan.
- KeX and SSH validation.
- Tool inventory.

Done when:

- Kali exists under `/data/local/nhsystem/roots/kali-arm64` and `nh-audit` sees it.

### 22. NetHunter Services And Custom Commands

Level: intermediate

Goal: make NetHunter manageable, not just installed.

Build:

- Service start/stop checklist.
- Custom commands for status, backup, Arch entry, Wi-Fi check.

Done when:

- Common actions are one tap or one command, with safe defaults.

### 23. Boot Image Backup And Recovery Lab

Level: advanced

Goal: prepare for kernel development without gambling the phone.

Build:

- Backup current boot-related partitions.
- Store hashes and device metadata.
- Write rollback steps.

Done when:

- You can explain exactly how to return to the current known-good boot state.

### 24. Custom SM8150 Kernel Build

Level: advanced

Goal: build a reproducible OnePlus 7 Pro kernel.

Build:

- Source mirror.
- Toolchain notes.
- Defconfig diff.
- Build script.
- Flash/test checklist.

Done when:

- You can build the kernel from source and produce a boot artifact with documented inputs.

### 25. NetHunter Feature Patch Stack

Level: advanced

Goal: add NetHunter-relevant features deliberately.

Build:

- Patch queue for USB gadget, HID, Wi-Fi adapter support, packet sockets, namespaces/cgroups where useful.
- One feature per branch/patch.
- Test results linked to the capability matrix.

Done when:

- You have a maintainable patch stack instead of a mystery kernel.

## Personal Weekly Rhythm

Monday:

- Review notes and choose one small deliverable.

Tuesday to Thursday:

- Build and test.

Friday:

- Write down what changed, what broke, and what to do next.

Weekend:

- Backup, clean workspace, and only then do risky kernel or rootfs experiments.

## Priority For The Next 10 Sessions

1. Reconnect ADB and confirm `./nhctl status`.
2. Stabilize Arch SSH.
3. Run backup and restore drill.
4. Open adapter packaging only enough to record exact model/revision.
5. Test adapter on desktop Linux.
6. Test adapter OTG power on phone.
7. Start passive monitor-mode lab.
8. Build `wifi-adapter-lab.md` notes.
9. Create package manifests.
10. Start the local dev dashboard.

## Source Notes

- Kali NetHunter overview: https://www.kali.org/docs/nethunter/
- Kali NetHunter wireless cards: https://www.kali.org/docs/nethunter/wireless-cards/
- Kismet Linux Wi-Fi datasource: https://www.kismetwireless.net/docs/readme/datasources/wifi-linux/
- Android Kotlin Multiplatform: https://developer.android.com/kotlin/multiplatform
- Android on-device/edge AI context: https://www.edge-ai-vision.com/2026/01/on-device-llms-in-2026-what-changed-what-matters-whats-next/
- GitHub Octoverse AI and typed-language trend context: https://octoverse.github.com/
