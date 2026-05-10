---
agent: "agent"
description: "Review code changes for correctness, safety, and OmniSec conventions"
---

You are reviewing code for the OmniSec project.

Change to review: ${input:changes:Describe or paste the code change}

Review against these criteria:

## Correctness
1. Does the change do what it claims? Check for off-by-one, race conditions, missing edge cases.
2. Are error paths handled? Every `die`, `return 1`, or exit path should be checked.
3. Are variable expansions properly quoted (`"$var"` not `$var`)?

## Shell Safety (Bash host scripts)
1. `set -euo pipefail` present?
2. `IFS` set to `$'\n\t'` where needed?
3. No unescaped globs on rm -rf?
4. No eval with untrusted input?
5. Temporary files use `mktemp` with cleanup trap?

## Device Script Safety (Android sh)
1. `#!/system/bin/sh` shebang?
2. POSIX-compatible only? No `[[`, `local`, arrays, `<<<`, `$(<file)` ?
3. No dependency on tools not in Android shell environment?

## C Safety
1. Buffer bounds checked? No unsafe `strcpy`/`sprintf`/`gets`?
2. Return values checked for syscalls?
3. No use-after-free or double-free?
4. Static linking constraints maintained?

## Project Conventions
1. Follows existing `nh-*` naming and output style?
2. Uses existing helpers (`nh-defaults.sh`, `nh-lib`) instead of duplicating?
3. Changes scoped to the task — no unrelated refactors?
4. PRIORITY declaration present (for device scripts)?

## Compatibility
1. Won't break existing CI workflows?
2. Won't break existing user-facing commands?
3. Compatible with Android/Bionic (no glibc-only assumptions)?

Return a structured review with: issues found (P0/P1/P2/P3), recommendations, and a verdict (approve/needs-fix/reject).
