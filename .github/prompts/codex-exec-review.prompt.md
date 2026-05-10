---
name: codex-exec-review
description: Generate a Codex exec/review command plan for an OmniSec task.
argument-hint: "[task objective]"
agent: "ask"
---

I need a practical Codex CLI command plan for this OmniSec task:

${input:task:Describe the task}

Produce:

1. A safe `codex exec` command for initial analysis.
2. A follow-up `codex exec review` command for reviewing the final change set.
3. Suggested approval/sandbox policy for each command.
4. A short note on when to fall back to `make lint` / `make test`.
