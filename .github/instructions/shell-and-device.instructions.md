---
applyTo: "nhctl,*.sh,src/**/*.sh,deploy/**/*.sh,plugins/*,tests/**/*.sh,tests/**/*.bats"
---

# Shell and device script instructions

- Preserve script role boundaries:
  - Host scripts orchestrate via ADB/SSH and should remain Bash-oriented.
  - Device scripts must remain compatible with Android shell environments.
- For host scripts, keep:
  - `#!/usr/bin/env bash`
  - `set -euo pipefail`
  - quoted variables and robust error exits.
- For device scripts under `src/device/**` and `payload/**`, keep:
  - `#!/system/bin/sh`
  - POSIX-compatible syntax and minimal dependencies.
- Prefer `printf` over `echo` for deterministic formatting.
- Reuse project helpers instead of duplicating logic:
  - host configuration and defaults: `nh-defaults.sh`
  - device helper functions: `nh-lib`
- Do not introduce hardcoded secrets, static private keys, or local-only host paths.
- Keep command names and user-facing output consistent with existing `nh-*` tooling style.
