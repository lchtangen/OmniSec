# Rename Playbook

Goal: rename folders and files to clearer names without breaking builds, tasks, scripts, or docs.

## Naming Rules

- Use lowercase kebab-case for folders and files.
- Prefer purpose-first names: `kernel-build-*`, `device-*`, `release-*`, `distribution-*`.
- Avoid overloaded names like `platform`, `matrix`, `release` without context.
- Keep names short but explicit enough for first-time contributors.

## Mandatory Rename Checks

1. `./scripts/pre-rename-audit.sh`
2. `./repo-doctor.sh`
3. `make lint`
4. `make test`

Only proceed with additional rename batches if all pass.

## Migration Status

Canonical names have been applied for the current top-level mapping, and compatibility symlinks have been removed.

Current canonical folders:

- `kernel-build-arch-package`
- `platform-legacy`
- `matrix-runtime`
- `distribution-fdroid`
- `live-iso-build`
- `device-maintenance`
- `device-target-profiles`
- `package-recipes`
- `release-artifacts`

## High-Value Rename Example

- `linux-omnisec` -> `kernel-build-arch-package` (migrated)

Reason: this folder is an Arch Linux kernel packaging/build workspace, and the new name makes that clear in VS Code, terminal completion, and GitHub browsing.

## Execution Strategy

1. Apply renames in small batches (3-10 paths per commit).
2. After each batch, run the mandatory checks.
3. Update references in scripts, Makefile, docs, and CI.
4. Keep compatibility symlinks only when needed, and remove them after all references are migrated.

## Source of Truth

- Rename mapping file: `refactor/rename-map.tsv`
- Use this file to stage and review each rename before execution.
