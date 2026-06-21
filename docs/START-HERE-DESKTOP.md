# START HERE: DESKTOP

## Scope

Desktop-focused repositories and templates.

## Primary Paths

- `repos/desktop/linux/`
- `repos/desktop/macos/`
- `repos/desktop/windows/`

## Linux First-Party Repositories

- `repos/desktop/linux/omnisec/` (stable)
- `repos/desktop/linux/cyberflash-tool/` (stable)
- `repos/desktop/linux/linux-omnisec/` (beta)
- `repos/desktop/linux/kali-workspace/` (beta)

## Security Tooling Buckets

- `repos/desktop/linux/security-tools/ai-pentesting/`
- `repos/desktop/linux/security-tools/exploitation/`
- `repos/desktop/linux/security-tools/forensics/`
- `repos/desktop/linux/security-tools/reverse-engineering/`
- `repos/desktop/linux/security-tools/zero-trust/`

## Quick Commands

```bash
cd /home/arch/projects/multi-platform
find repos/desktop/linux -maxdepth 2 -type d | sort
cd repos/desktop/linux/omnisec && make test
```
