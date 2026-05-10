---
agent: "agent"
description: "Deep context bootstrap — build full project understanding before a complex task"
---

You are performing a deep context bootstrap for the OmniSec project.

Task objective: ${input:objective:What are you about to work on?}

## Phase 1: Workspace State
1. `git status --short` — current branch and dirty state
2. `git --no-pager log --oneline -n 10` — recent commits
3. `git diff --stat` — uncommitted changes scope
4. `ls -la payload/ 2>/dev/null | wc -l` — staged payload exists?

## Phase 2: Quality Baseline
1. `make lint 2>&1` — establish lint baseline
2. `make test 2>&1 | tail -20` — establish test baseline
3. `./scripts/ai-cli-doctor.sh` — AI tool availability

## Phase 3: Architecture Review
Read these for context based on the task objective:
- **All tasks**: `ARCHITECTURE.md`, `nh-defaults.sh`
- **Shell tasks**: `docs/coding-standards.md` (shell section)
- **C tasks**: `docs/coding-standards.md` (C section), `src/c/*.c`
- **Device tasks**: `src/device/bin/nh-lib`, `docs/install.md`
- **CI/CD tasks**: `.github/workflows/ci.yml`

## Phase 4: File Discovery
- Find files matching the task's subsystem: `ls` into the relevant `src/` subdirectory
- Read the first 20-30 lines of key files to understand structure
- Check `.github/instructions/` for scope-specific rules

## Phase 5: Briefing
Produce a structured briefing with:
1. **Branch**: current branch, ahead/behind, dirty state
2. **Quality baseline**: lint OK? tests passing?
3. **AI tools**: which CLIs are available
4. **Architecture**: relevant subsystem, entry point, data flow
5. **Risk areas**: things that could break, dependencies to be careful with
6. **Recommended approach**: step-by-step plan for the task
