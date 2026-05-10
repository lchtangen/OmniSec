<!-- NH_SETUP_VERSION: 2.0 nextgen -->
<!-- PRIORITY: P0 CRITICAL - Security standards -->

# NetHunter NextGen Security Standards

> **Priority**: CRITICAL — All code must follow these security rules
> **Version**: 2.0.0

## 1. Core Principles

```
✓ Least Privilege  — Code runs with minimum required permissions
✓ Defense in Depth — Multiple layers of security
✓ Secure Defaults  — Opt-IN to less secure modes
✓ Fail Secure      — Errors result in locked-down state
✓ No Secrets in Code — Keys, passwords, tokens NEVER in source
```

## 2. Threat Model

### Assets
| Asset | Location | Priority |
|-------|----------|----------|
| User SSH keys | `~/.ssh/`, chroot `/home/*/.ssh/` | P0 |
| GPG keys | `~/.gnupg/` | P0 |
| WireGuard keys | `/data/local/nhsystem/roots/*/etc/wireguard/` | P1 |
| Configuration | `nh-config` store | P1 |
| Secrets | `nh-secret` encrypted store | P1 |
| Backups | `/data/local/nhsystem/backups/` | P1 |

### Threats
| Threat | Impact | Mitigation |
|--------|--------|------------|
| Unauthorized ADB access | Full device compromise | Remove ADB auth keys when not in use |
| Chroot escape | Access to Android host | SELinux policies, seccomp, user namespaces |
| Network MITM | Data interception | SSH key verification, HTTPS, WireGuard |
| Stolen device | All data compromised | Full-disk encryption, remote wipe capability |
| Malicious modules (nh-module) | Arbitrary code execution | Module signing, sandboxing, review process |

## 3. Mandatory Security Practices

### 3.1 Secrets Management
```bash
# NEVER:
- Hard-code passwords, API keys, tokens
- Commit .env files, credential files
- Log sensitive data
- Use weak crypto

# ALWAYS:
- Use nh-secret for credential storage
- Use environment variables for runtime secrets
- GPG-encrypt sensitive configs at rest
- Use SSH keys over passwords
```

### 3.2 File Permissions
```bash
# SSH keys
chmod 600 ~/.ssh/id_*
chmod 644 ~/.ssh/*.pub
chmod 700 ~/.ssh/

# Secrets store
chmod 700 /data/local/nhsystem/secrets/
chmod 600 /data/local/nhsystem/secrets/*

# Scripts (read-only for non-root)
chmod 755 /data/local/nhsystem/bin/nh-*
```

### 3.3 Input Validation
```bash
# ALL user input must be sanitized:
# 1. Strip shell metacharacters
# 2. Validate against allowlist when possible
# 3. Use printf %q for safe interpolation
# 4. Never eval user input
```

### 3.4 Network Security
```bash
# SSH:
- Key-based auth only (no passwords)
- Protocol 2 only
- PermitRootLogin prohibit-password
- Use non-standard ports (8022, 2222)

# VPN:
- WireGuard preferred over OpenVPN
- Kill switch on VPN disconnect
- DNS over TLS (DoT) or HTTPS (DoH)

# Firewall:
- nh-firewall for iptables rules
- Default deny inbound
- Rate limit SSH connections
```

### 3.5 SELinux
```bash
# Kernel:
CONFIG_SECURITY_SELINUX=y
CONFIG_SECURITY_SELINUX_BOOTPARAM=y
CONFIG_SECURITY_SELINUX_DEVELOP=y

# Policy:
- Targeted policy for chroot operations
- Type Enforcement for system_server
- neverallow rules for critical paths
```

## 4. Secure Development Lifecycle

### 4.1 Pre-Commit
```bash
✓ shellcheck — No warnings (P0/P1), no errors (all)
✓ Secret scanning — No credentials in code
✓ Dependency check — Known vulnerabilities
```

### 4.2 CI/CD
```bash
✓ CodeQL analysis
✓ Dependabot alerts
✓ SAST scanning
✓ Container image scanning
```

### 4.3 Release
```bash
✓ GPG signing of release artifacts
✓ SHA256 checksums published
✓ SBOM (Software Bill of Materials)
✓ Signed git tags
```

## 5. Incident Response

### 5.1 Severity Levels
| Level | Definition | Response Time |
|-------|------------|---------------|
| S0 | Active exploitation | Immediate |
| S1 | Confirmed vulnerability | 24 hours |
| S2 | Potential vulnerability | 72 hours |
| S3 | Best practice violation | Next release |

### 5.2 Response Procedure
1. **Identify** — Determine scope and impact
2. **Contain** — Disable affected features, revoke keys
3. **Eradicate** — Fix the vulnerability
4. **Recover** — Restore from clean backups
5. **Post-mortem** — Document and improve

## 6. Compliance Checklist

Every PR must pass these checks:

- [ ] No secrets in code
- [ ] Input validation on all user-facing parameters
- [ ] Proper file permissions
- [ ] Error messages don't leak sensitive info
- [ ] Uses safe functions (no eval, no system() with user input)
- [ ] HTTPS for all external downloads
- [ ] GPG verification for downloaded packages
- [ ] Logs don't contain credentials
- [ ] Default configuration is secure
- [ ] Documentation covers security considerations
