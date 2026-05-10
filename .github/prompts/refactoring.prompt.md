---
agent: "agent"
description: "Safely refactor OmniSec code while preserving behavior and compatibility"
---

You are refactoring code in the OmniSec project.

Refactoring scope: ${input:scope:What needs refactoring?}
Refactoring goal: ${input:goal:Improve readability / reduce duplication / improve performance / modernize}

## Mandatory Constraints

1. **No behavior changes** — Refactoring must not change observable behavior (exit codes, output, command arguments, file paths)
2. **No API breaks** — `nh-*` command names, arguments, and output formats must remain stable
3. **No regressions** — Existing tests must pass without modification
4. **Surgical scope** — Only touch the specific code identified for refactoring

## Safe Refactoring Patterns

### Shell Scripts
- Extract repeated code into functions (place in `nh-defaults.sh` for host, `nh-lib` for device)
- Replace `echo` with `printf` for deterministic formatting
- Consolidate duplicated error handling patterns into `die()` calls
- Remove dead code (commented blocks, unused functions, unreachable paths)
- Modernize: replace backtick command substitution with `$()` (host scripts only)

### C Code
- Extract magic numbers into named constants
- Break large functions into smaller focused ones
- Replace manual buffer management with bounded functions (`snprintf`, `strlcpy`)
- Add `const` correctness
- Consolidate duplicated error handling patterns

### Python Code
- Extract repeated logic into helper functions
- Add type hints to improve readability
- Use pathlib over os.path for path operations
- Replace dict access with `.get()` for safe defaults

## Validation Sequence
```bash
make lint        # Must pass without new warnings
make test        # Must pass without modification
make validate    # Must pass for deploy-impacting files
```

## Output
Return a diff summary with:
1. Files changed and line counts
2. Refactoring patterns applied
3. Risk assessment (low/medium/high — must be LOW for refactoring)
4. Verification that lint+test still pass
