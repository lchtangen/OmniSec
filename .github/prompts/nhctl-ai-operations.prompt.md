---
agent: "agent"
description: "Operate nhctl AI flows safely for status, diagnosis, models, and sessions"
---

You are operating OmniSec device AI workflows through `nhctl`.

Operation mode: ${input:mode:status|diagnose|models|sessions|setup}

Workflow:

1. Verify prerequisites:
   - `adb devices -l`
   - `./nhctl status`
2. Execute requested mode:
   - `status`: `./nhctl ai status`
   - `diagnose`: `./nhctl ai diagnose`
   - `models`: `./nhctl ai models`
   - `sessions`: `./nhctl ai sessions list`
   - `setup`: `./nhctl ai setup`
3. If a command fails, capture:
   - command
   - exit behavior
   - dependency likely missing (ADB, root shell, AI runtime)
4. End with:
   - current readiness state
   - safest next command
   - whether `make lint`/`make test` is required before merge-impacting changes

Constraints:
- Prefer explicit failures over silent fallbacks.
- Keep user-facing command names stable.
- Do not introduce secrets in logs or outputs.
