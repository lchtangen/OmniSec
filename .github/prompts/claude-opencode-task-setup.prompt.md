---
name: claude-opencode-task-setup
description: Build a deterministic task handoff prompt for Claude Code or OpenCode in OmniSec.
argument-hint: "[task and preferred tool]"
agent: "ask"
---

Create a handoff-ready task prompt for OmniSec using:

- Tool: ${input:tool:claude or opencode}
- Objective: ${input:objective:What should the agent accomplish?}

Prompt requirements:

1. Include repository context and source-of-truth locations.
2. Include strict validation sequence (`make lint`, `make test`).
3. Include safety guardrails for host/device shell boundaries.
4. Keep prompt concise, explicit, and execution-ready.
