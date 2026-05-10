---
agent: "agent"
description: "Build OmniSec context before coding by running AI/CLI and repo readiness checks"
---

You are preparing to work on OmniSec with full project context.

Goal: ${input:goal:What is your immediate objective?}

Perform this sequence:

1. Run workspace readiness checks:
   - `./scripts/pre-rename-audit.sh`
   - `./repo-doctor.sh`
2. Run AI/CLI readiness checks:
   - `for cmd in codex claude aider gh; do command -v "$cmd" || true; done`
   - `./nhctl ai help`
3. Gather repository context:
   - `git status --short`
   - `git --no-pager log --oneline -n 8`
4. Produce a compact briefing with:
   - current branch and cleanliness
   - quality gate status
   - available AI entrypoints (`nhctl ai`, CLI tools)
   - top 3 risks and top 3 safe next steps

Constraints:
- Keep recommendations behavior-safe and minimal.
- Do not propose unrelated refactors.
- Prefer commands and paths already used by this repository.
