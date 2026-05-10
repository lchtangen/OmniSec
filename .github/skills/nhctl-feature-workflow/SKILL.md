---
name: nhctl-feature-workflow
description: Implement or modify nhctl features with correct host/device wiring and validation.
argument-hint: "[feature or command behavior]"
---

# nhctl feature workflow skill

Use this skill for changes touching `nhctl` and related command behavior.

## Step-by-step

1. Identify command surface in `nhctl`.
2. Trace underlying script or helper in:
   - `src/scripts/`
   - `src/device/bin/`
   - `src/device/setup/`
3. Implement minimal changes in source-of-truth files.
4. If staged payload behavior is affected, run:

```bash
make stage
```

5. Validate:

```bash
make lint
make test
```

## Guardrails

- Keep UX and command names stable unless change request explicitly requires a rename.
- Keep host/device shell compatibility boundaries intact.
