# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| 3.0.x (beta) | Beta — reported via email |
| < 3.0 | Not supported |

## Reporting a Vulnerability

**Do not open public GitHub issues for security vulnerabilities.**

Report vulnerabilities privately to the maintainer:

- **Email**: security@omnisec.dev
- **PGP Key**: Available at `keys.omnisec.dev` or via key servers (`0x...`)
- **Response time**: Within 48 hours

### What to include

- Description of the vulnerability
- Steps to reproduce (proof of concept preferred)
- Affected versions and components
- Potential impact
- Suggested fix (if any)

### Disclosure policy

1. Your report will be acknowledged within 48 hours.
2. A fix will be developed and tested.
3. A security advisory will be published after the fix is released.
4. You will be credited in the advisory (unless you prefer to remain anonymous).

## Scope

In-scope:
- The `nhctl` controller and all host-side scripts
- Device-side scripts in `payload/` and `src/device/`
- Native C binaries in `src/c/`
- Deploy artifacts (Magisk module, build.prop)

Out-of-scope:
- Third-party dependencies (report those upstream)
- Android OS itself (LineageOS, AOSP)
- Kali Linux or Arch Linux packages

## Security-relevant features

This project handles:
- **SSH keys** at `~/.omnisec/keys/ssh/`
- **GPG keys** at `~/.omnisec/keys/gpg/`
- **WireGuard keys** at `~/.omnisec/keys/wireguard/`
- **API keys** at `~/.omnisec/keys/api/`
- **OpenVPN certificates** at `~/.omnisec/keys/ovpn/`
- **ADB authentication** via `~/.android/adbkey`

These are all P0 assets. Report any exposure immediately.
