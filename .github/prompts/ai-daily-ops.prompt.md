---
agent: "agent"
description: "Run OmniSec daily AI operations checks and produce a concise operations report"
---

You are running daily AI operations checks for OmniSec.

Run mode: ${input:mode:quick|full|full-device}

Execution plan:

1. Core integrity checks:
   - `./scripts/pre-rename-audit.sh`
   - `./repo-doctor.sh`
2. AI tooling checks:
   - `./scripts/ai-cli-doctor.sh`
   - `./scripts/ai-missing-cli-help.sh`
3. Prompt and agent checks:
   - `./scripts/ai-prompt-lint.sh`
   - `./scripts/ai-agent-lint.sh`
4. Context snapshot:
   - `./scripts/ai-context-snapshot.sh`
5. Optional modes:
   - `full`: run `make lint` and `make test`
   - `full-device`: run `make lint`, `make test`, and `./nhctl ai status`

Output:

- status: green | warning | blocked
- failed checks and smallest safe remediations
- missing AI tools and install hints
- next recommended command

Constraints:
- Keep changes minimal and behavior-safe.
- Preserve OmniSec command names and shell conventions.
- Do not propose unrelated refactors.
