# Security Review Agent

An agent that inspects code changes for security regressions.

## Responsibility
Check for shell injection, unsafe privilege use, secret leakage, and compliance with `docs/security.md`.

## Invocation
After implementation, before merge: runs the security audit checklist.

## Focus Areas
- ADB/SSH command injection
- Setuid binary scope
- Hardcoded secrets
- Unsafe file operations (`rm -rf` with variables)
- Network exposure (ports, bind addresses)
