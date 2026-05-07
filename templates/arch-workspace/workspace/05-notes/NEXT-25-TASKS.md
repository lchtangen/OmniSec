<!-- NH_SETUP_VERSION: 2.0 default -->
<!-- Profile: Arch ARM64 v2.0 default; Kali ARM64 v2.0 default -->

# Next 25 Tasks

Date: 2026-05-07

Scope: personal Arch ARM64, Android, NetHunter, Wi-Fi adapter, Codex, and custom source-build roadmap.

Use this as the next working checklist in VS Code. Do these in order unless a task is blocked.

## Foundation

- [ ] 1. Confirm VS Code Remote SSH opens `/home/archlinux/workspace` and integrated terminal starts in the same folder.
- [ ] 2. Run `ws-tree` and read `README.md`, `05-notes/START-HERE.md`, and `06-docs/device/ONEPLUS7PRO.md`.
- [ ] 3. Create baseline package manifests:

```sh
pacman -Qqe > 08-config/arch/pacman-explicit.txt
npm list -g --depth=0 > 08-config/arch/npm-global.txt
codex --version > 08-config/codex/version.txt
```

- [ ] 4. Create a daily log habit in `05-notes/daily/`.
- [ ] 5. From the desktop host, run `./nhctl backup` and record the result in the daily note.

## Arch Development

- [ ] 6. Create your first real project with `new-project arch-health`.
- [ ] 7. Build a small Arch health script that prints user, kernel, storage, SSH, workspace, and key tools.
- [ ] 8. Add the health script to `/workspace/bin`.
- [ ] 9. Create a Git repo for `01-projects/active/arch/` or the first project folder.
- [ ] 10. Write `08-config/git/README.md` with your Git identity, ignore rules, and private-file policy.

## Codex Workflow

- [ ] 11. Run Codex from `01-projects/active/codex`.
- [ ] 12. Create `01-projects/active/codex/workflow.md` with rules for using Codex in Arch: user mode first, no secrets, root only when explicit.
- [ ] 13. Test a small Codex task that edits only one project note.
- [ ] 14. Add a `codex-checklist.md` for reviewing changes before accepting them.

## Wi-Fi Adapter

- [ ] 15. Open only enough of the adapter packaging to record exact model, revision, and chipset if printed.
- [ ] 16. Create `04-labs/wifi-adapter/adapter-profile.md`.
- [ ] 17. Test the adapter on desktop Linux first with `lsusb`, `dmesg`, `iw dev`, and `ip link`.
- [ ] 18. Test Android OTG power and record whether the adapter enumerates on the phone.
- [ ] 19. Decide keep/return/reserve based on chipset, power, and driver evidence.

## Android And NetHunter

- [ ] 20. Create `06-docs/android/app-roadmap.md` for a private Android status/control panel.
- [ ] 21. Create `06-docs/nethunter/install-plan.md` with NetHunter app, Kali rootfs, SSH, KeX, and audit milestones.
- [ ] 22. Do not install NetHunter until the current Arch state is backed up and restore notes exist.
- [ ] 23. Prepare a NetHunter validation checklist: rootfs path, `nh-audit`, SSH, KeX, service start/stop, Wi-Fi adapter visibility.

## Kernel And Source Builds

- [ ] 24. Create `06-docs/kernel/boot-backup-plan.md` with boot, vendor_boot, dtbo, vbmeta backup steps and hash recording.
- [ ] 25. Create `06-docs/kernel/source-plan.md` for SM8150 source mirror, clean build, defconfig diff, and one-feature-at-a-time NetHunter patching.

## Priority After This List

After these 25 tasks, start real source work in this order:

1. Arch health/status tooling.
2. Wi-Fi adapter capability matrix.
3. Android private status app.
4. NetHunter install and validation.
5. Boot image backup and kernel source mirror.
6. Clean SM8150 kernel build.
7. NetHunter kernel feature patch stack.

## Rule

Beginner tasks should produce notes and evidence. Advanced tasks should produce reproducible scripts, source trees, patches, or build artifacts.

