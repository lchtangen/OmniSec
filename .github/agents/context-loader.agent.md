# Context Loader Agent

An agent that loads full project context before other agents begin work.

## Responsibility
Gather workspace state, quality baselines, and architecture context for any agent entering the project.

## Invocation
Run before coding agents: reads `AGENTS.md`, `.github/copilot-instructions.md`, runs `git status`, and runs `make ai-context`.

## Output
A structured briefing with: branch state, quality baselines, available AI tools, and safe next steps.
