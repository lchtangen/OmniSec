# ♊ GEMINI.md — OmniSec AI Project Context

> **Project Name:** OmniSec v3.0  
> **Version:** 2.0.0 (Core) / 3.0.0 (AI Suite)  
> **Target:** OnePlus 7 Pro (GM1911) / Android 16 / LineageOS 23.2

---

## 🏗️ Project Overview

OmniSec is the ultimate mobile security and development platform, unifying 192+ tools across 7 platforms. It provides a specialized environment for Android NetHunter-style security workflows, mesh networking, and AI-assisted development.

### Core Architecture
- **Host Controller:** `nhctl` (Bash-based orchestrator)
- **Device Tools:** 391+ `nh-*` scripts in `src/device/bin/`
- **Dual Chroot:** Integrated Arch Linux and Kali Linux environments.
- **AI Suite:** Comprehensive integration with modern AI coding agents (Kilo, Claude, Aider, etc.).
- **Build System:** `Makefile` handles C compilation, payload staging, and linting.

---

## 🚀 Building and Running

### Key Commands

- `make` — Run the full quality gate (lint, build, stage, test).
- `make lint` — Validate shell syntax, C code, and JSON configs.
- `make test` — Execute BATS shell tests and C unit tests.
- `make stage` — Regenerate the `payload/` directory from `src/` (run after modifying source files).
- `make deploy` — Stage and push tools to the connected device via `nhctl`.
- `nhctl status` — Show overall system and device status.

### AI Tooling

- `make ai-cli-doctor` — Verify installation of AI CLI tools.
- `make ai-cli-fix-paths` — Fix PATH and permissions for AI tools.
- `make ai-context` — Generate a repo context snapshot for AI agents.
- `opencode` — Launch the OpenCode AI agent.
- `kilo` — Launch the **Kilo Code CLI** (AI coding assistant).

---

## 🛠️ Development Conventions

### Scripting Guardrails
- **Host Scripts (`scripts/`, `nhctl`):** Use `#!/usr/bin/env bash` with `set -euo pipefail`. Source `nh-defaults.sh`.
- **Device Scripts (`src/device/`):** Use `#!/system/bin/sh`. Only use POSIX-compliant shell features. Source `nh-lib`.
- **Priority:** All device-side scripts must declare a `PRIORITY:` (P0-P3) in their header.

### Quality Gate
- All changes must pass `make lint` and `make test`.
- Use `make stage` to propagate changes from `src/` to `payload/`.
- Never edit files in `payload/` directly; modify the corresponding files in `src/` instead.

### AI Integration
- This project uses `AGENTS.md` as the canonical memory bank for AI agents.
- Custom instructions for specific file types are located in `.github/instructions/`.
- Prompt templates are stored in `.github/prompts/`.

---

## 📝 Key Files

- `nhctl` — Main entry point for host-side operations.
- `Makefile` — Project build and automation system.
- `AGENTS.md` — AI agent operating manual and project map.
- `ARCHITECTURE.md` — System layers and priority definitions.
- `opencode.json` / `kilo.json` — AI agent project configuration.
- `src/c/nh-sudo.c` — Core native helper for privilege escalation on device.
- `scripts/ai-agent-router.sh` — Routing script for various AI CLI agents.
