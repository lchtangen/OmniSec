---
agent: "agent"
description: "Triage failures across Codex, Claude, Copilot CLI, Aider, and nhctl AI commands"
---

You are troubleshooting AI tooling in OmniSec.

Failure symptom: ${input:symptom:What failed?}

Run a focused triage:

1. Tool availability and versions:
   - `command -v codex claude aider gh`
   - `codex --version || true`
   - `claude --version || true`
   - `aider --version || true`
   - `gh --version`
2. Repo and quality sanity:
   - `./repo-doctor.sh`
   - `make lint`
3. OmniSec AI command sanity:
   - `./nhctl ai help`
   - `./nhctl ai status` (if device is connected)
4. Summarize findings in this exact structure:
   - symptom confirmation
   - failing command(s)
   - root cause hypothesis
   - smallest safe remediation
   - verification command(s)

Constraints:
- Do not edit generated artifacts.
- Keep shell fixes compatible with host-side Bash conventions.
- Keep output concise and actionable.
