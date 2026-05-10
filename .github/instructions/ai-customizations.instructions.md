---
applyTo: ".github/agents/*.agent.md,.github/prompts/*.prompt.md,.github/skills/*/SKILL.md,.agents/skills/*/SKILL.md,.claude/agents/*.md,AGENTS.md,CLAUDE.md,CODEX.md,OPENCODE.md"
---

# AI customization file instructions

- Keep AI customization files deterministic and repository-specific.
- Use clear task-oriented language with minimal ambiguity.
- Do not include secrets, API keys, or machine-specific credentials.
- Prefer reusable guidance over one-off task instructions.
- When custom commands are referenced, keep them aligned with repository defaults (`make lint`, `make test`).
- Keep skill names in lowercase kebab-case and matched to the skill directory name.
