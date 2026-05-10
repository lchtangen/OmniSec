---
agent: "agent"
description: "Audit OmniSec code for security vulnerabilities and unsafe patterns"
---

You are performing a security audit on OmniSec code.

Target: ${input:target:File, directory, or change to audit}

## Audit Checklist

### Shell Injection
- [ ] All arguments to `adb shell`, `ssh`, `chroot` properly quoted/escaped
- [ ] No unsanitized user input passed to shell evaluation
- [ ] No `eval` with controllable input
- [ ] No `source`/`.` with controllable paths

### Privilege Escalation
- [ ] Setuid binaries (`nh-sudo`) minimize scope of elevated operations
- [ ] Root shell sessions dropped privileges where possible
- [ ] Device-side scripts run with least privilege

### Secrets Management
- [ ] No hardcoded keys, tokens, passwords, or credentials
- [ ] No credentials in command-line arguments (visible in `ps`)
- [ ] No secrets in debug output or logs
- [ ] SSH keys properly permissioned (0600)

### File System Safety
- [ ] No unsafe `rm -rf` with variable paths (check for empty/unset vars)
- [ ] Temporary files created with `mktemp` not predictable paths
- [ ] Cleanup traps (`trap 'rm -f ...' EXIT`) for temp files
- [ ] File permissions set restrictively (0600 for keys, 0700 for scripts)

### Network Security
- [ ] ADB connections validated (not just blindly trusted)
- [ ] SSH host key verification enabled
- [ ] No hardcoded IPs or credentials in network configs
- [ ] Forwarded ports bound to localhost (not 0.0.0.0)

### Supply Chain
- [ ] External sources pinned (GitHub action SHAs, package versions)
- [ ] No curl-to-bash patterns without checksum verification
- [ ] No unnecessary network calls in install/setup scripts

## Output Format

```
╔══════════════════════════════════════════╗
║           OmniSec Security Audit         ║
╚══════════════════════════════════════════╝

[P0] Critical issues (mitigate immediately)
  - description, location, fix recommendation

[P1] High issues (fix within current cycle)
  - description, location, fix recommendation

[P2] Medium issues (fix when convenient)
  - description, location, fix recommendation

[P3] Low / Informational
  - description, location, note

Summary: X issues across P0-P3
Risk level: CRITICAL / HIGH / MEDIUM / LOW
```
