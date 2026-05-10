---
name: opencode-repo-ops
description: OpenCode-focused workflow for OmniSec repository operations, validation, and safe patching.
argument-hint: "[task summary]"
---

# OpenCode repository operations skill

Use this skill when running OmniSec tasks through OpenCode.

## Core runbook

1. Explore relevant files and identify source-of-truth locations.
2. Apply minimal changes.
3. Run standard validation:

```bash
make lint
make test
```

4. If source-to-payload behavior changed, regenerate staged payload:

```bash
make stage
```

## Repository guardrails

- Prefer `src/` over generated output directories.
- Keep device-side scripts compatible with `/system/bin/sh`.
- Avoid introducing secrets or local machine assumptions.
