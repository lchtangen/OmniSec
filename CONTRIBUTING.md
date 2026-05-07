# Contributing

## Design Constraints

This project targets a specific device stack:

- **Device:** OnePlus 7 Pro (GM1911 / guacamole)
- **Android:** 16 (API 36)
- **ROM:** LineageOS 23.2
- **Kernel:** 4.14.356-openela
- **Root:** Magisk (via `/debug_ramdisk/su`)
- **Shell:** `/system/bin/sh` (device-side), bash (host-side)

All scripts must account for these constraints.

## Script Conventions

### Host-side scripts
- Shebang: `#!/usr/bin/env bash`
- Options: `set -euo pipefail`
- Use `printf` not `echo`
- Source `nh-defaults.sh` for all configuration values
- Use ADB for device communication
- Every "risky" operation must call `run_backup()` first

### Device-side scripts (`payload/`)
- Shebang: `#!/system/bin/sh`
- Options: `set -euo pipefail` (where supported by mksh)
- Source `nhsystem-bin/nh-lib` for helpers
- Only use commands available in Android's minimal shell
- No assumptions about `$PATH` — use full paths

### nhsystem-bin scripts (`payload/nhsystem-bin/`)
- Shebang: `#!/system/bin/sh`
- Source `nh-lib` for shared functions
- Keep functions reusable and composable
- One logical operation per script

### C source code (`payload/`)
- Must compile with `gcc -Wall -Wextra -pedantic`
- Static linking for binaries, PIC for shared libraries
- Target AArch64 (aarch64-linux-gnu)
- Avoid glibc-specific features not available in Android bionic

## Code Style

- 4-space indentation, no tabs
- LF line endings
- 100 character line limit
- `snake_case` for variables and functions
- `SCREAMING_SNAKE_CASE` for environment variables and constants
- Comments in deploy scripts only where intent is non-obvious

## Git Workflow

```bash
git checkout -b feature/my-feature
# make changes
./scripts/validate.sh
make lint
make test
git add -A
git commit -m "description of change"
git push -u origin feature/my-feature
```

## Commit Messages

```
area: brief description

Optional body explaining motivation and approach.
```

Areas: `nhctl`, `payload`, `nhsystem-bin`, `kernel`, `device`, `docs`, `build`, `ci`, `magisk`

## Testing

```bash
make test        # Run all tests
make lint        # Syntax checks only
./tests/run-tests.sh  # Manual test suite
```

Before submitting any change, run:
```bash
./scripts/validate.sh
```

## Pull Request Checklist

- [ ] Shell syntax: `bash -n` on all modified files
- [ ] C syntax: `cc -fsyntax-only` on all modified C files
- [ ] `make lint` passes
- [ ] `make test` passes (or all non-ADB tests)
- [ ] Scripts are executable (`chmod +x`)
- [ ] Device-side scripts use `/system/bin/sh` shebang
- [ ] No hardcoded IPs, paths, or secrets in scripts
- [ ] Changes are backward-compatible or documented as breaking
