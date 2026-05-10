---
agent: "agent"
description: "Triage CI workflow failures and map to minimal source fixes"
---

You are triaging a CI workflow failure in the OmniSec project.

Workflow: ${input:workflow:Failing workflow name or URL}
Failure details: ${input:details:Error output or job failure logs}

## Triage Process

### 1. Identify the failing stage
- Is it `lint`, `test`, `build`, `docker`, or `notify`?
- Is the failure consistent or flaky?
- Check if the same failure occurs locally with `make lint` / `make test`

### 2. Map failure to source
- **Lint failures** → syntax errors in `.sh`, `.c`, or `.json` files → fix in `src/`
- **Test failures** → BATS assertion failures or C test failures → fix in `src/` or `tests/`
- **Build failures** → C compilation errors or stage issues → fix in `src/c/` or `Makefile`
- **Docker failures** → Dockerfile or dependency issues
- **ShellCheck warnings** → source file lint issues → fix in relevant `.sh` file

### 3. Determine root cause
- Recent commit introduced the issue? Run `git bisect` or inspect recent diffs
- CI config change? Check `.github/workflows/ci.yml` for recent modifications
- Environment issue? Check runner OS, tool versions, cache state
- Flaky test? Run the failing test multiple times locally

### 4. Produce remediation

For each issue found, provide:
```yaml
- file: path/to/source.file
  line: NNN
  issue: description of the problem
  severity: error/warning
  fix: |
    The minimal code change to fix it
  verification: command to verify the fix (e.g., "make lint", "bats tests/foo.bats")
```

### 5. Summary
- Root cause
- Files to change
- Verification steps
- Estimated fix complexity (trivial/simple/moderate/complex)
