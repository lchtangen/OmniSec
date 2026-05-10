---
agent: "agent"
description: "Audit missing AI CLIs and provide exact install guidance for this host"
---

You are advising on AI CLI installation readiness for OmniSec.

Run:

1. `./scripts/ai-missing-cli-help.sh`
2. `./scripts/ai-cli-doctor.sh`

Then produce:

- installed tools with detected versions
- missing tools grouped by priority (core and optional)
- safest install commands for this host package manager
- post-install verification commands

Constraints:
- Do not auto-install anything.
- Do not include unverified third-party commands.
- Keep output concise and actionable.
