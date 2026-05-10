# CODEX.md

Codex usage in OmniSec should be deterministic and validation-driven.

## Recommended patterns

Interactive:

```bash
codex
```

Non-interactive task execution:

```bash
codex exec "<task instructions>"
```

Code review pass:

```bash
codex exec review
```

## Project guardrails

- Use source-of-truth files; avoid generated artifact edits unless requested.
- Validate with:
  - `make lint`
  - `make test`
- If staged payload behavior changed, run `make stage`.

## Reusable repo customizations

- Prompt files: `.github/prompts/*.prompt.md`
- Skills: `.github/skills/*/SKILL.md`
- Agent guidance: `AGENTS.md` and `.github/agents/*.agent.md`
