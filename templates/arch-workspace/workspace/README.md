<!-- NH_SETUP_VERSION: 2.0 default -->
<!-- Profile: Arch ARM64 v2.0 default; Kali ARM64 v2.0 default -->

# Arch ARM64 Workspace

This is the main personal development workspace for the OnePlus 7 Pro Arch chroot.

The goal is to keep the system clean:

- Personal work lives in `/workspace`.
- Source trees live in `/workspace/02-source`.
- Build outputs live in `/workspace/03-build`.
- Experiments live in `/workspace/04-labs`.
- Notes live in `/workspace/05-notes`.
- Private material lives in `/workspace/10-private` with strict permissions.

## Daily Start

```sh
cd /workspace
arch-info 2>/dev/null || true
git status 2>/dev/null || true
```

## Rules

- Keep source and build output separate.
- Keep secrets out of Git.
- Keep raw wireless captures private.
- Create one note per project before doing risky work.
- Before kernel/rootfs/package experiments, run backup from the host:

```sh
./nhctl backup
```

## Top-Level Layout

```text
00-inbox/        unsorted notes, downloads, scratch ideas
01-projects/     active personal projects
02-source/       upstream source trees and mirrors
03-build/        build outputs, toolchains, caches, logs
04-labs/         experiments and learning labs
05-notes/        daily notes, research notes, commands
06-docs/         durable documentation
07-artifacts/    generated artifacts worth preserving
08-config/       personal configuration snapshots
09-backups/      workspace/config/device backup staging
10-private/      keys, secrets, identity material
bin/             personal executable helpers
tmp/             disposable local scratch
```

