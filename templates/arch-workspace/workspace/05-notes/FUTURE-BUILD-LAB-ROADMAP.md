<!-- NH_SETUP_VERSION: 2.0 default -->
<!-- Profile: Arch ARM64 v2.0 default; Kali ARM64 v2.0 default -->

# Future Build Lab Roadmap

Date: 2026-05-07

Scope: long-range creative roadmap for the OnePlus 7 Pro Arch ARM64, Android, Kali, NetHunter, Linux, source-build, custom kernel, UI/design, and Codex agent lab.

Use this after `NEXT-25-TASKS.md` and `NEXT-50-TASKS.md`. This file is not a replacement checklist. It is the larger direction for what we are building together.

## Research Signals

- Kali NetHunter full feature set depends on kernel support for features such as Wi-Fi injection, HID, BT Arsenal, and related low-level capabilities. Rootless/Lite are useful, but do not replace full kernel-enabled NetHunter.
- Kali kernel builder guidance recommends starting from Lineage or device kernel sources and building test kernels deliberately.
- Official NetHunter kernel listings still show OnePlus 7 family support mostly around older Android/OOS lines, so Android 16 should be treated as a porting project rather than a blind flash target.
- LineageOS still tracks OnePlus 7 Pro `guacamole`, making it a serious reference path for Android/device-tree/kernel research.
- postmarketOS shows OnePlus 7 Pro has mobile Linux research value, but incomplete areas such as Wi-Fi/modem/GPS make it a research lane rather than the daily working path.
- Kismet Linux Wi-Fi capture depends on monitor-mode interfaces and Linux wireless APIs.
- MT7612U-style adapters are attractive when possible because of the in-kernel `mt76` driver family.
- Current software trends strongly favor AI-assisted development, TypeScript, Python, shell automation, local agents, Android Compose/Kotlin, and careful secret management.
- Secret leakage from GitHub and agent/MCP configuration is now a major risk, so secret hygiene is a first-class project.
- Android UI direction is Material 3, Compose, adaptive layouts, and local/on-device intelligence.

Source links:

- https://www.kali.org/docs/nethunter/
- https://www.kali.org/docs/nethunter/porting-nethunter-kernel-builder/
- https://nethunter.kali.org/kernels.html
- https://wiki.lineageos.org/devices/guacamole/
- https://wiki.postmarketos.org/wiki/OnePlus_7_Pro_%28oneplus-guacamole%29
- https://www.kismetwireless.net/docs/readme/datasources/wifi-linux/
- https://github.com/morrownr/7612u
- https://github.blog/news-insights/octoverse/octoverse-a-new-developer-joins-github-every-second-as-ai-leads-typescript-to-1/
- https://www.gitguardian.com/state-of-secrets-sprawl-report-2026
- https://developer.android.com/develop/ui/compose/designsystems/material3
- https://developer.android.com/jetpack/androidx/releases/compose-material3-adaptive

## Phase 9: Device Recovery And Install Safety

Goal: make risky work survivable before installing NetHunter or flashing kernels.

Build:

- Recovery binder for the OnePlus 7 Pro.
- Partition inventory: current slot, boot, vendor_boot, dtbo, vbmeta, metadata, rootfs paths.
- Backup hash sheet for all boot-critical artifacts.
- Rollback command sheet for desktop, ADB, fastboot, and recovery.
- Flash gate script that refuses risky steps unless backup docs and hashes exist.
- Visual recovery flowchart for viewing in VS Code and on the phone.

First artifact:

```text
06-docs/device/recovery-binder.md
```

Done when:

- Boot-related backups exist with hashes.
- Rollback steps are written in exact commands.
- Kernel/NetHunter mutation has an explicit preflight gate.

Codex prompt:

```text
Create 06-docs/device/recovery-binder.md for OnePlus 7 Pro GM1911. Include current known device facts, required boot-critical backups, hash recording table, rollback command placeholders, and a no-flash-until checklist. Do not run ADB, fastboot, root, or mutation commands.
```

## Phase 10: Android Control Center App

Goal: build a private Android app that makes this system understandable without a terminal.

Product name:

```text
NH Control Center
```

Screens:

- Device
- Arch
- Kali
- NetHunter
- Wi-Fi Adapter
- Kernel
- Backups
- Logs
- Codex Sessions

Design:

- Material 3.
- Dark-first.
- Dense but readable dashboard.
- Adaptive list/detail layout.
- Status chips for healthy, warning, broken, unknown, blocked.
- No destructive actions in v1.

Data model:

- App reads local JSON status snapshots.
- Root actions are not performed directly by the app in v1.
- Later actions require clear confirmation and audit logging.

First artifact:

```text
01-projects/active/android/nh-control-center/README.md
```

Done when:

- App skeleton exists.
- First screen displays static device and project data.
- Data source contract is documented.

Codex prompt:

```text
Plan the NH Control Center Android app in 01-projects/active/android/nh-control-center. Create README.md, ui-map.md, data-contract.md, and implementation-plan.md. Keep v1 read-only. Use Material 3, Compose, and adaptive dashboard design. Do not create source code yet unless asked.
```

## Phase 11: Visual And Graphic Design System

Goal: give all dashboards, Android UI, docs, and reports one coherent visual language.

Build:

- Project name and naming rules.
- Color palette for device, Arch, Kali, kernel, Wi-Fi, backup, warning, blocked.
- Typography rules for terminal-heavy technical UI.
- Icon plan using familiar symbols.
- Status component design.
- Dashboard wireframes.
- Report layout.

Design rules:

- Operational, not marketing.
- Compact, scannable, dark-friendly.
- No decorative gradients or oversized hero layouts.
- Every status must be quickly understandable.

First artifact:

```text
06-docs/design/design-system.md
```

Done when:

- Android app and web dashboard can share the same status language.
- Status colors and labels are defined.
- Wireframes exist for phone and desktop.

Codex prompt:

```text
Create 06-docs/design/design-system.md for the Arch/NetHunter build lab. Define color tokens, typography, status chips, icon guidance, dashboard layout rules, and wireframes in Markdown. Keep it operational and technical, not decorative.
```

## Phase 12: Local Web Dashboard

Goal: build a private local dashboard served over localhost or ADB-forwarded port.

Product name:

```text
ArchDock
```

Tech direction:

- TypeScript.
- Vite.
- Small local API.
- Static export option.
- No public bind by default.

Widgets:

- Arch health.
- Package manifest age.
- Backup age.
- Free space.
- Wi-Fi adapter state.
- Kali rootfs state.
- Kernel build state.
- Codex agent session log.
- Last known good state.

First artifact:

```text
01-projects/active/dashboard/README.md
```

Done when:

- Dashboard plan exists.
- JSON status files are mapped.
- First static HTML prototype displays fake data.

Codex prompt:

```text
Create a dashboard project plan in 01-projects/active/dashboard. Define widgets, JSON inputs, local-only serving rules, no-public-bind default, and a first static prototype milestone. Do not install packages yet.
```

## Phase 13: Agentic Development Lab

Goal: turn Codex usage into a controlled engineering process.

Product name:

```text
AgentLedger
```

Build:

- Agent task templates.
- Prompt library.
- Run ledger.
- Risk level labels.
- Files touched list.
- Commands run list.
- Verification status.
- Human approval matrix.

Approval matrix:

- Docs-only: normal.
- Code edits: review required.
- Package install: approval required.
- Network use: approval required.
- Root: explicit approval required.
- ADB mutation: explicit approval required.
- Flashing: blocked until recovery gate passes.

First artifact:

```text
01-projects/active/codex/agent-ledger.md
```

Done when:

- Every Codex task has an audit trail.
- Risk levels are defined.
- The VS Code Codex agent can follow a standard prompt.

Codex prompt:

```text
Create AgentLedger docs under 01-projects/active/codex. Include task template, risk labels, approval matrix, session log format, and review checklist. Do not change system files.
```

## Phase 14: Secrets And Identity Hardening

Goal: make secrets difficult to leak through Git, Codex, MCP configs, or logs.

Build:

- Secret scanning policy.
- `.env` policy.
- MCP config policy.
- SSH key policy.
- API-token policy.
- pcap/log privacy policy.
- Encrypted backup plan.
- Pre-commit hook plan.

First artifact:

```text
06-docs/security/secrets-policy.md
```

Done when:

- Private file patterns are defined.
- Git ignore and pre-commit requirements are documented.
- `/workspace/10-private` is explicitly banned from Codex tasks.

Codex prompt:

```text
Create 06-docs/security/secrets-policy.md. Cover Git, Codex, MCP configs, SSH keys, API tokens, .env files, pcap/log privacy, /workspace/10-private rules, and pre-commit scanner recommendations. Do not read or modify private files.
```

## Phase 15: Wi-Fi And Radio Lab

Goal: build a legal personal RF engineering lab around the new adapter.

Product name:

```text
WiFi Atlas
```

Build:

- Adapter profile.
- Driver/mode checker.
- Passive-only lab mode.
- Kismet plan.
- Coverage map.
- Throughput results.
- Privacy sanitizer for logs.
- Kernel requirements matrix.

Rules:

- Owned or authorized networks only.
- Raw wireless captures stay private.
- No deauth/password attacks in beginner phases.
- First goal is engineering visibility, not offensive tooling.

First artifact:

```text
04-labs/wifi-adapter/wifi-atlas.md
```

Done when:

- Adapter status is known.
- Own-network RSSI/throughput data exists.
- Kernel requirements are tied to the actual chipset.

Codex prompt:

```text
Create 04-labs/wifi-adapter/wifi-atlas.md. Define adapter profile, passive testing workflow, own-network coverage workflow, Kismet privacy rules, and kernel requirement mapping. Do not include offensive instructions.
```

## Phase 16: NetHunter/Kali Build From Source

Goal: install and understand NetHunter/Kali without letting it destabilize Arch.

Build:

- Kali rootfs install plan.
- NetHunter app plan.
- KeX validation.
- SSH validation.
- Custom commands.
- Source mirror for NetHunter scripts.
- Build notes for image/rootfs work.

Paths:

```text
Kali rootfs: /data/local/nhsystem/roots/kali-arm64
Docs:       /workspace/06-docs/nethunter
Source:     /workspace/02-source/nethunter
Builds:     /workspace/03-build/rootfs
```

First artifact:

```text
06-docs/nethunter/from-source-plan.md
```

Done when:

- Rootfs install is documented.
- Validation checklist exists.
- Kali can be audited before adding extra tools.

Codex prompt:

```text
Create 06-docs/nethunter/from-source-plan.md. Define source mirrors, rootfs build/install stages, validation gates, SSH/KeX checks, and custom command integration. Do not install Kali yet.
```

## Phase 17: Kernel Engineering Track

Goal: build a reproducible custom kernel workflow before attempting NetHunter features.

Product name:

```text
KernelForge
```

Build:

- Source selection memo.
- Clean build pipeline.
- Defconfig diff tracking.
- Build environment checker.
- Artifact tracker.
- Capability matrix.
- Patch queue policy.
- Flash gate integration.

Capability matrix:

- HID gadget.
- USB configfs.
- USB Wi-Fi chipsets.
- Packet sockets.
- TUN/WireGuard.
- Namespaces/cgroups.
- eBPF feasibility.
- KVM/virt feasibility if available.

First artifact:

```text
06-docs/kernel/kernelforge.md
```

Done when:

- Clean kernel build is reproducible.
- Patch stack policy exists.
- No kernel is flashed before recovery gate passes.

Codex prompt:

```text
Create 06-docs/kernel/kernelforge.md. Define source selection, clean build pipeline, defconfig diff tracking, build logs, feature matrix, patch policy, and flash gate requirements. Do not clone sources or flash anything.
```

## Phase 18: Mainline Linux Research Track

Goal: learn mobile Linux architecture using OnePlus 7 Pro research without replacing the daily Android setup.

Build:

- postmarketOS notes.
- Device-tree learning track.
- Mainline kernel notes.
- Firmware/remoteproc notes.
- Display/touch/panel driver notes.
- Modem/GPS/Wi-Fi limitation notes.

First artifact:

```text
06-docs/linux-phone/mainline-research.md
```

Done when:

- You understand what mainline Linux can and cannot do on this device today.
- It is clearly separated from the daily Android/Arch/NetHunter track.

Codex prompt:

```text
Create 06-docs/linux-phone/mainline-research.md. Summarize the OnePlus 7 Pro mainline/postmarketOS research lane, what to study, what works, what is limited, and why this is not the daily path yet.
```

## Phase 19: Android Source And ROM Track

Goal: understand Android/Lineage source builds for `guacamole`.

Build:

- LineageOS source plan.
- Device tree map.
- Vendor blob plan.
- Kernel source relation.
- Storage/build machine requirements.
- Build cache layout.
- First repo-sync plan.
- Build log format.

First artifact:

```text
06-docs/android/rom-source-plan.md
```

Done when:

- You know where Android source will live.
- Build requirements are documented.
- First goal is learning and clean build, not custom ROM release.

Codex prompt:

```text
Create 06-docs/android/rom-source-plan.md for OnePlus 7 Pro guacamole. Define source location, build requirements, device tree/vendor/kernel relationship, build logs, and first clean-build milestone. Do not run repo sync.
```

## Phase 20: Personal Products To Build

These become the creative product layer on top of the system.

### NH Control Center

Android app for phone-side status, docs, and safe actions.

First artifact:

```text
01-projects/active/android/nh-control-center/README.md
```

### ArchDock

Local web dashboard for Arch, Kali, NetHunter, Wi-Fi, backups, builds, and Codex sessions.

First artifact:

```text
01-projects/active/dashboard/README.md
```

### KernelForge

Kernel source, build matrix, artifacts, capabilities, and flash gate.

First artifact:

```text
06-docs/kernel/kernelforge.md
```

### WiFi Atlas

Private Wi-Fi adapter and own-network engineering dashboard.

First artifact:

```text
04-labs/wifi-adapter/wifi-atlas.md
```

### AgentLedger

Codex agent task manager, session log, approval matrix, and review workflow.

First artifact:

```text
01-projects/active/codex/agent-ledger.md
```

### SourceForge Local

Source tree status, build logs, patch status, and artifact browser.

First artifact:

```text
01-projects/active/sourceforge-local/README.md
```

### Recovery Vault

Boot images, hashes, rollback docs, and emergency flowcharts.

First artifact:

```text
06-docs/device/recovery-binder.md
```

### Pocket Lab

Phone-side launcher for terminal, dashboard, notes, docs, and status.

First artifact:

```text
01-projects/active/android/pocket-lab/README.md
```

## Master Safety Gates

### Before NetHunter Install

- [ ] Arch health passes.
- [ ] Workspace backup exists.
- [ ] Restore drill is documented.
- [ ] Free space is checked.
- [ ] ADB root works.
- [ ] Kali rootfs path is confirmed.
- [ ] Validation checklist exists.

### Before Kernel Flash

- [ ] Boot-critical partition backups exist.
- [ ] Hashes are recorded.
- [ ] Rollback commands are written.
- [ ] Current slot is known.
- [ ] Clean kernel build log exists.
- [ ] Feature patch is isolated.
- [ ] Flash gate passes.

### Before Codex Root Or Network Tasks

- [ ] Task states exactly why root/network is needed.
- [ ] Files allowed are listed.
- [ ] Private paths are excluded.
- [ ] Rollback or undo path exists.
- [ ] Human review is required.

### Before Wi-Fi Capture

- [ ] Network is owned or explicitly authorized.
- [ ] Capture purpose is documented.
- [ ] Raw logs are stored privately.
- [ ] Sanitization plan exists before sharing.

## Recommended Order After NEXT-50

1. Recovery Vault.
2. AgentLedger.
3. Secrets policy.
4. ArchDock static prototype.
5. NH Control Center app plan.
6. WiFi Atlas adapter profile.
7. NetHunter from-source plan.
8. KernelForge clean-build plan.
9. Android ROM source plan.
10. Mainline Linux research notes.

## One-Line Prompts For VS Code Codex

Use these to start focused agent sessions:

```text
Create the Recovery Vault docs. Work only in 06-docs/device and 07-artifacts/boot-images. Do not run ADB or fastboot.
```

```text
Create AgentLedger docs and templates. Work only in 01-projects/active/codex. Do not read private files.
```

```text
Create the Material 3 design system for NH Control Center and ArchDock. Work only in 06-docs/design.
```

```text
Create the WiFi Atlas planning docs. Work only in 04-labs/wifi-adapter and 06-docs/wifi. Keep it passive and legal.
```

```text
Create the KernelForge planning docs. Work only in 06-docs/kernel, 02-source/kernel README, and 03-build/kernel README. Do not clone or build yet.
```

```text
Create the NetHunter from-source plan. Work only in 06-docs/nethunter. Do not install anything.
```

```text
Create the Android ROM source plan. Work only in 06-docs/android. Do not run repo sync.
```

## Definition Of Complete Setup

The setup is “complete enough” when:

- Arch is stable and documented.
- Backups and restore drill are proven.
- VS Code and Codex workflow are predictable.
- Secrets and private files are protected.
- Android app and dashboard have read-only status views.
- NetHunter/Kali is installed and validated.
- Wi-Fi adapter capability is known.
- Kernel source can clean-build reproducibly.
- No flashing or root mutation happens without gates.
- Every major subsystem has docs, scripts, artifacts, and verification.

