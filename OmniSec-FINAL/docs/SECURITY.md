# OmniSec ULTIMATE — Security Policy

## Reporting a Vulnerability
**PLEASE DON'T DISCLOSE SECURITY ISSUES PUBLICLY**

Report vulnerabilities to: security@omnisec.io
PGP Key: Available on our website

### What to Include
- Description of the vulnerability
- Steps to reproduce
- Affected versions
- Potential impact
- Suggested fix (if any)

### Response Timeline
- 24h: Initial acknowledgment
- 72h: Assessment and severity
- 7 days: Fix released for critical issues
- 30 days: Fix released for low/medium issues

### Scope
- OmniSec core platform
- Official modules
- Website (omnisec.io)
- API endpoints

### Out of Scope
- Third-party tools bundled with OmniSec
- Operating system vulnerabilities
- Hardware vulnerabilities

### Safe Harbor
We will not pursue legal action against researchers who:
- Follow this policy
- Make a good-faith effort to avoid privacy violations
- Do not cause damage to systems or data
- Do not use extortion or threats

## Security Features
- **Offline-Only Architecture**: No network calls without user action
- **Post-Quantum Cryptography**: Kyber, Dilithium, SPHINCS+
- **Sandbox Execution**: Isolated tool execution
- **Code Signing**: All releases signed with GPG
- **SBOM**: Software Bill of Materials for every release
- **No Telemetry**: Zero data collection
- **Dependency Scanning**: Automated vulnerability checking in CI
