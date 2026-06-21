# Multi-Platform Workspace

Centralized, platform-first workspace optimized for agent-driven development.

## Personalized Profile

- Primary goal: faster daily development flow
- Organization model: by platform
- Maturity labels: stable, beta, experimental
- Naming style: UPPERCASE docs and kebab-case directories
- Repo model: centralized under `repos/`
- Workflow style: AI agents perform implementation tasks

## New Root Layout

```text
multi-platform/
├── repos/
│   ├── desktop/
│   │   ├── linux/
│   │   │   ├── omnisec/
│   │   │   ├── cyberflash-tool/
│   │   │   ├── linux-omnisec/
│   │   │   ├── kali-workspace/
│   │   │   ├── distros/
│   │   │   ├── security-tools/
│   │   │   └── templates/
│   │   ├── macos/templates/
│   │   └── windows/templates/
│   ├── mobile/
│   │   ├── android/
│   │   │   ├── op7p-env/
│   │   │   ├── vault-android16/
│   │   │   ├── security-tools/mobile/
│   │   │   └── templates/
│   │   └── ios/templates/
│   ├── web/
│   │   ├── security-tools/
│   │   └── templates/
│   ├── embedded/templates/
│   └── reference/awesome-lists/
├── scripts/
├── shared/
├── themes/
├── dashboard/
├── .audit-reports/
└── docs/
```

## Common Agent Workflows

```bash
# Open workspace root
cd ~/projects/multi-platform

# Fast inventory
find repos -maxdepth 3 -type d | sort

# Update all git repos
find repos -name ".git" -type d -execdir git pull --ff-only \;

# Build orchestration
./scripts/omnisec-build.sh
```

## Platform Entry Points

- Linux platform repos: `repos/desktop/linux/`
- Android platform repos: `repos/mobile/android/`
- Web security repos: `repos/web/security-tools/`
- Reference collections: `repos/reference/awesome-lists/`

## Core First-Party Repos

| Repo | New Path | Maturity |
|---|---|---|
| OmniSec | `repos/desktop/linux/omnisec/` | stable |
| CyberFlash-Tool | `repos/desktop/linux/cyberflash-tool/` | stable |
| linux-omnisec | `repos/desktop/linux/linux-omnisec/` | beta |
| kali-workspace | `repos/desktop/linux/kali-workspace/` | beta |
| op7p-env | `repos/mobile/android/op7p-env/` | experimental |
| vault-android16 | `repos/mobile/android/vault-android16/` | experimental |

## Documentation

- Workspace docs: `docs/`
- Audit and compliance docs: `.audit-reports/`
- Reorganization map: `docs/REPO-MIGRATION-MAP.md`
- Platform guides: `docs/START-HERE-DESKTOP.md`, `docs/START-HERE-MOBILE.md`, `docs/START-HERE-WEB.md`, `docs/START-HERE-EMBEDDED.md`
- Validation script: `scripts/validate-workspace-structure.sh`

## Notes

- This layout intentionally prioritizes platform navigation and automation.
- Legacy paths from `first-party/`, `tools/`, `distros/`, `reference/`, and `platform/` have been moved under `repos/`.