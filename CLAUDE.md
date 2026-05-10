# CLAUDE.md

Claude Code should follow repository instructions in this order:

1. `.github/copilot-instructions.md`
2. `.github/instructions/**/*.instructions.md` (path-specific)
3. `AGENTS.md`
4. this `CLAUDE.md`

## OmniSec defaults

- Prefer editing source files in `src/`, `deploy/`, `scripts/`, `tests/`.
- Avoid direct edits to generated outputs (`payload/`, `build/`, `dist/`) unless explicitly requested.
- Keep host/device shell compatibility boundaries intact:
  - host scripts: bash conventions
  - device scripts: `/system/bin/sh` compatibility

## Validation

Run from repo root:

```bash
make lint
make test
```

If source files that drive staged payload changed:

```bash
make stage
```

## Claude-specific notes

- Reuse `.claude/agents/*.md` personas when they fit the task.
- Reuse `.github/skills/*/SKILL.md` and `.github/prompts/*.prompt.md` for repeatable workflows.
