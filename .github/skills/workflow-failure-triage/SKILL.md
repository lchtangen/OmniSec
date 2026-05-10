---
name: workflow-failure-triage
description: Triage GitHub Actions failures by mapping failed jobs to local reproducible commands.
argument-hint: "[workflow/job context]"
context: fork
---

# Workflow failure triage skill

Use this skill when CI workflows fail and you need a deterministic local reproduction path.

## Triage flow

1. Identify the failing workflow/job and the exact failing step.
2. Extract the failing command sequence from workflow YAML.
3. Reproduce locally from repo root.
4. Isolate failing file or assumption.
5. Propose smallest fix and targeted re-run plan.

## OmniSec references

- `.github/workflows/ci.yml`
- `.github/workflows/release.yml`
- `Makefile`

## Typical local reproductions

```bash
make lint
make test
```
