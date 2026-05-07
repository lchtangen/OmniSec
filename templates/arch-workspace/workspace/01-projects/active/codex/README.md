<!-- NH_SETUP_VERSION: 2.0 default -->
<!-- Profile: Arch ARM64 v2.0 default; Kali ARM64 v2.0 default -->

# Codex Project

Goal: make Codex useful inside the Arch chroot without mixing secrets, root-only tasks, and project work.

## Start

```sh
cd /workspace/01-projects/active/codex
codex
```

## Rules

- Use `archlinux`, not root, for normal Codex work.
- Keep secrets outside project files.
- Use root only for explicit system repair or kernel tasks.
- Prefer project-local notes and scripts.

