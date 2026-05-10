# OPENCODE.md

OpenCode should follow OmniSec repository guardrails and quality gates.

## Basic commands

Interactive:

```bash
opencode
```

Non-interactive:

```bash
opencode run "<task instructions>"
```

## OmniSec validation baseline

```bash
make lint
make test
```

If source-to-payload behavior changed:

```bash
make stage
```

## OpenCode-focused reusable skill

- `.agents/skills/opencode-repo-ops/SKILL.md`

Additional cross-agent skills and prompts:
- `.github/skills/*/SKILL.md`
- `.github/prompts/*.prompt.md`
