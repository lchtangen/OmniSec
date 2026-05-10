# Shell Hardening Skill

Audit and harden shell scripts for OmniSec compatibility, portability, and safety.

## When to use
- Writing new device scripts (`src/device/**`)
- Modifying existing host scripts
- Reviewing PRs with shell changes

## Workflow
1. Check shebang matches role (host: bash, device: `/system/bin/sh`)
2. Verify strict mode for host scripts
3. Verify POSIX-only for device scripts
4. Check all variable expansions are quoted
5. Validate error handling paths
6. Run `make lint` and fix ShellCheck warnings
