<!-- NH_SETUP_VERSION: 2.0 default -->
<!-- Profile: Arch ARM64 v2.0 default; Kali ARM64 v2.0 default -->

# Next 50 Tasks

Date: 2026-05-07

Scope: personal Arch ARM64, Android, NetHunter, Kali, Wi-Fi adapter, Codex agents, Linux/source builds, and OnePlus 7 Pro kernel work.

Use this after `05-notes/NEXT-25-TASKS.md`. Work inside VS Code Remote SSH on `arch-arm64`, with the folder opened at:

```text
/home/archlinux/workspace
```

Each task should produce a concrete artifact: note, script, config, source tree, build log, app, package, tested workflow, or validation result.

## Codex Agent Rules

When assigning any task to a Codex agent in VS Code, use this baseline:

```text
Work inside /home/archlinux/workspace.
Use the archlinux user unless root is explicitly required.
Do not touch /workspace/10-private.
Do not install packages or use network unless this task explicitly needs it.
Create or update only the files for this task.
After finishing, summarize files changed, commands run, and how to verify.
```

## Phase 1: Arch Workstation Maturity

- [ ] 26. Create `01-projects/active/arch-health/` with `README.md`, `notes.md`, `scripts/`, and `src/`.
- [ ] 27. Build `/workspace/bin/arch-health`, printing user, kernel, uptime, storage, SSH status, Codex version, Node, Python, Rust, Go, Clang, and workspace paths.
- [ ] 28. Add `arch-health --json` output for future dashboard and Android app use.
- [ ] 29. Create `08-config/arch/bootstrap.md` documenting how to rebuild the Arch dev environment from manifests.
- [ ] 30. Create `08-config/shell/terminal-cheatsheet.md` for zsh, tmux, rg, fd, fzf, jq, nvim, pacman, and system inspection.
- [ ] 31. Create a `tmux` project session script at `/workspace/bin/dev-session`.
- [ ] 32. Build `/workspace/bin/workspace-doctor` to validate required directories, permissions, private-folder mode, helper commands, and workspace ownership.
- [ ] 33. Add `05-notes/commands/root-vs-user.md` explaining when to use `archlinux`, Arch root SSH, and Android ADB root.
- [ ] 34. Create `09-backups/restore-drill.md` and run one restore test for a non-sensitive note file.
- [ ] 35. Create a Git repo for the Arch tooling project, excluding private folders and generated artifacts.

## Phase 2: Codex Agent Workflow

- [ ] 36. Create `01-projects/active/codex/agent-rules.md` defining safe Codex behavior: no secrets, small diffs, user mode by default, root only when explicitly requested.
- [ ] 37. Create `01-projects/active/codex/task-template.md` with sections: goal, constraints, files allowed, commands allowed, done criteria, rollback.
- [ ] 38. Create `01-projects/active/codex/review-checklist.md` for checking Codex changes before accepting them.
- [ ] 39. Test Codex on a harmless docs-only task and record the result in `01-projects/active/codex/codex-log.md`.
- [ ] 40. Create a prompt library for Arch, Android, NetHunter, kernel, Wi-Fi, backup, and source-build tasks.
- [ ] 41. Create a “one task per branch or project folder” convention for source work.
- [ ] 42. Add a `codex-log.md` habit: every Codex session records prompt, files changed, commands run, result, and follow-up.
- [ ] 43. Build `/workspace/bin/codex-session-new`, creating a dated note from the task template.
- [ ] 44. Create `01-projects/active/codex/network-policy.md` for when Codex may run network/package install commands.
- [ ] 45. Create `01-projects/active/codex/root-adb-policy.md` for when Codex may use root, ADB, or Android device mutation.

## Phase 3: Wi-Fi Adapter And Wireless Engineering

- [ ] 46. Create `04-labs/wifi-adapter/adapter-profile.md` with model, chipset, USB ID, driver, power, and support notes.
- [ ] 47. Create `04-labs/wifi-adapter/desktop-test.md` with desktop `lsusb`, `dmesg`, `iw`, `ip`, and driver results.
- [ ] 48. Create `04-labs/wifi-adapter/android-otg-test.md` with phone power/enumeration results.
- [ ] 49. Create `04-labs/wifi-adapter/arch-visibility-test.md` showing whether the chroot can see the adapter/interface.
- [ ] 50. Create `/workspace/bin/wifi-adapter-check` to print USB ID, interface, driver, mode support, and missing tools.
- [ ] 51. Build a passive-only monitor-mode lab on your own router or phone hotspot.
- [ ] 52. Create `04-labs/wifi-adapter/kismet-plan.md` for private passive Kismet logging.
- [ ] 53. Create `04-labs/wifi-adapter/coverage-map.md` for own-network RSSI, channel, and throughput measurements.
- [ ] 54. Create `06-docs/wifi/kernel-requirements.md` mapping chipset to required kernel modules/configs.
- [ ] 55. Decide adapter status: keep, return, desktop-only, or phone-ready.

## Phase 4: Android App And Device Tooling

- [ ] 56. Create `01-projects/active/android/device-status-app/` as the first Android app project.
- [ ] 57. Create `06-docs/android/build-pipeline.md` documenting SDK, Gradle, JDK, signing, install, uninstall, and artifact paths.
- [ ] 58. Build a minimal Kotlin/Compose app that displays static device/project info.
- [ ] 59. Add live status fields: battery, charging, thermal status, storage, and network type.
- [ ] 60. Add a read-only Arch/NetHunter status page fed by generated JSON files.
- [ ] 61. Create a safe ADB install/uninstall script and document debug signing.
- [ ] 62. Add a local-only logs screen for recent status snapshots.
- [ ] 63. Create `06-docs/android/automation-boundaries.md` defining which actions are allowed, confirmed, or forbidden.
- [ ] 64. Add one confirmed action: open Termux or show connection instructions.
- [ ] 65. Create `06-docs/android/kmp-status-parser-plan.md` for sharing status parsing between Android and CLI tools.

## Phase 5: NetHunter And Kali

- [ ] 66. Create `06-docs/nethunter/install-plan.md` with exact milestones: app, Kali ARM64 rootfs, SSH, KeX, audit.
- [ ] 67. Create `06-docs/nethunter/preinstall-checklist.md` requiring backup, free space, ADB root, Arch health, and rollback notes.
- [ ] 68. Create `06-docs/nethunter/rootfs-layout.md` documenting intended path `/data/local/nhsystem/roots/kali-arm64`.
- [ ] 69. Create `06-docs/nethunter/service-model.md` defining how Kali SSH, KeX, and custom commands should start/stop.
- [ ] 70. Create `06-docs/nethunter/validation-checklist.md` for `nh-audit`, SSH, KeX, package tools, and rootfs mounts.
- [ ] 71. Install Kali/NetHunter only after the preinstall checklist is complete.
- [ ] 72. Validate Kali rootfs without adding extra tools first.
- [ ] 73. Add NetHunter custom commands for status, Arch entry, backup, and Wi-Fi checks.
- [ ] 74. Add KeX validation notes and screenshots/artifacts if working.
- [ ] 75. Create `06-docs/nethunter/authorized-use-policy.md` for personal lab-only security work.

## Phase 6: Linux, Kernel, And Source Builds

- [ ] 76. Create `06-docs/kernel/boot-backup-plan.md` covering `boot`, `vendor_boot`, `dtbo`, `vbmeta`, hashes, storage location, and rollback.
- [ ] 77. Create `07-artifacts/boot-images/README.md` explaining which files belong there and how to verify hashes.
- [ ] 78. Create `06-docs/kernel/source-plan.md` for SM8150 source mirror, clean build, defconfig diff, and patch workflow.
- [ ] 79. Create `02-source/kernel/README.md` with source tree naming conventions.
- [ ] 80. Create `03-build/kernel/README.md` with out-of-tree build conventions and log paths.
- [ ] 81. Build a kernel environment checker at `/workspace/bin/kernel-env-check`.
- [ ] 82. Mirror or document the selected SM8150 kernel source only after source plan and backup plan are complete.
- [ ] 83. Produce one clean build log without modifying kernel source.
- [ ] 84. Create a NetHunter kernel feature matrix: HID, USB gadget, Wi-Fi modules, packet sockets, namespaces/cgroups, TUN/WireGuard.
- [ ] 85. Create a one-feature-at-a-time patch stack policy.

## Phase 7: Build Systems And Packaging

- [ ] 86. Create `06-docs/arch/package-build-plan.md` for local Arch package builds.
- [ ] 87. Create `03-build/packages/README.md` for package outputs, logs, and cache rules.
- [ ] 88. Package one tiny local script as an Arch package.
- [ ] 89. Create `06-docs/linux/from-source-build-notes.md` for configure/make, CMake/Ninja, Meson, Cargo, Go, npm, and Python projects.
- [ ] 90. Build one small C project from source and record the build steps.
- [ ] 91. Build one small Rust CLI from source and record the build steps.
- [ ] 92. Build one small Go CLI from source and record the build steps.
- [ ] 93. Create a build-log convention: every source build stores command, version, commit, dependencies, duration, and result.
- [ ] 94. Create `/workspace/bin/build-log-new` to generate a dated build log template.
- [ ] 95. Create `/workspace/bin/source-tree-status` to summarize source trees, Git branches, uncommitted changes, and build logs.

## Phase 8: Personal Products To Build

- [ ] 96. Create a private local dashboard project showing Arch health, package manifests, backups, Wi-Fi adapter state, and Android status.
- [ ] 97. Create a local notes/search project using ripgrep/fzf or a small web UI.
- [ ] 98. Create an encrypted backup workflow using age or GPG for sensitive notes.
- [ ] 99. Create a local AI/Codex lab for prompt templates, agent logs, and generated summaries.
- [ ] 100. Create a month-end report generator that summarizes completed tasks, changed files, device state, builds, and next risks.

## Verification Routine

Run this after each phase:

```sh
cd /home/archlinux/workspace
ws-tree | sed -n '1,120p'
arch-health 2>/dev/null || true
workspace-doctor 2>/dev/null || true
git status 2>/dev/null || true
```

## Safety And Scope

- Use `archlinux` for daily work.
- Use Arch root only for chroot repair, ownership, mounts, package recovery, and system config.
- Use Android ADB root only for device-level work that cannot be done inside Arch.
- Do not flash kernels until boot image backup, hash recording, and rollback steps are complete.
- Keep Wi-Fi testing limited to your own devices and authorized lab networks.
- Keep `/workspace/10-private` out of Codex tasks and Git.

