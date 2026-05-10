# CI Triage Skill

Diagnose and fix CI workflow failures in OmniSec.

## When to use
- GitHub Actions workflow failures
- Local `make lint`/`make test` failures
- Unexpected build failures

## Workflow
1. Identify failing stage (lint/test/build/docker/deploy)
2. Reproduce locally with same commands
3. Map to source file and root cause
4. Apply minimal fix
5. Verify with `make lint && make test`
6. Document the fix in the PR

## Common failure patterns
- Shell syntax errors in new/edited scripts
- Missing PRIORITY declarations in device scripts
- BATS test assertions failing due to output changes
- C compilation errors from missing includes or API changes
- ShellCheck new warnings from stricter rules
