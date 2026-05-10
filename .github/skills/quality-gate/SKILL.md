---
name: quality-gate
description: Run and interpret OmniSec quality gates. Use when validating changes or diagnosing failing checks.
argument-hint: "[optional changed scope]"
---

# OmniSec quality gate skill

Use this skill to validate change sets consistently.

## Commands

From repository root:

```bash
make lint
make test
```

Use `make validate` when deployment/runtime behavior may be affected.

## Investigation checklist

1. Confirm the failing command and exact failure line.
2. Determine whether issue is syntax, test behavior, or generated artifact mismatch.
3. Propose the smallest safe fix.
4. Re-run relevant checks.

## References

- [Contributing guide](../../../CONTRIBUTING.md)
- [Build system guide](../../../docs/build-system.md)
