# Development Workflow

## Daily Development Loop

```bash
# 1. Connect to device
adb connect 10.0.0.113:52104

# 2. Make changes
vim nhctl
vim payload/nhsystem-bin/nh-shell-kali
vim payload/no-close-range.c

# 3. Validate locally
make lint
make test

# 4. Deploy to device
./nhctl deploy-tools

# 5. Test on device
adb shell su -c "nh-health"
adb shell su -c "nh-enter-kali id"
```

## Full Development Cycle

### Phase 1: Setup

```bash
git clone <repo>
cd nethunter-setup

# Check dependencies
./scripts/check-deps.sh

# Connect device
adb connect 10.0.0.113:52104

# Verify connectivity
./preflight.sh
```

### Phase 2: Develop

```bash
# Create feature branch
git checkout -b feature/my-feature

# Edit files
# ...

# Validate
make validate

# Run full test suite
./tests/run-tests.sh
```

### Phase 3: Deploy

```bash
# Incremental deploy (scripts only)
./nhctl deploy-tools

# Full rebuild (chroots + all)
./clean-rebuild-postboot.sh
```

### Phase 4: Release

```bash
# Bump version
./scripts/update-version.sh

# Build all artifacts
make clean
make build
make build-module

# Package distribution
make dist

# Create release tarball
tar czf dist/nethunter-setup-v2.0.0.tar.gz \
  --exclude='.git' --exclude='node_modules' \
  --exclude='audits' --exclude='build' \
  -C . .

# Push and tag
git add -A
git commit -m "release: v2.0.0"
git tag v2.0.0
git push origin main --tags
```

## Architecture Overview

```
Host (your PC)                    Device (OnePlus 7 Pro)
┌─────────────────┐              ┌──────────────────────┐
│  nhctl           │─────ADB─────▶  nhsystem-bin/*      │
│  Makefile        │              │  nh-lib (shared)     │
│  *.sh            │              │                      │
│  payload/        │──push───────▶  /data/local/nhsystem/│
│    nh-sudo.c     │              │  roots/archlinux/    │
│    no-close.c    │              │  roots/kali-arm64/   │
│    nhsystem-bin/ │              │  workspaces/main/    │
│    *.sh          │              │  bin/                │
└─────────────────┘              └──────────────────────┘
```

## Chroot Architecture

```
Android Host (Magisk)
  └── Arch ARM64 (port 2222)
      ├── Daily development
      ├── Python/Node/Rust toolchain
      ├── Privacy tools (Tor, WireGuard)
      └── Workspace access
  └── Kali ARM64 (port 22)
      ├── Security testing
      ├── NetHunter integration
      └── KEX desktop (XFCE4)
  └── Termux (port 8022)
      ├── Fallback shell
      └── ADB-over-SSH bridge
```

## Testing Strategy

| Layer | Tool | What it checks |
|-------|------|----------------|
| Syntax | `bash -n` | Shell script validity |
| Syntax | `cc -fsyntax-only` | C source validity |
| Lint | ShellCheck | Shell script best practices |
| Lint | `json.tool` | JSON file validity |
| Unit | BATS tests | Script behavior |
| Integration | `validate.sh` | Device connectivity + root |
| Health | `nh-health` | Device-side chroot state |
| Audit | `run-audit.sh` | Comprehensive device audit |

## Versioning

Format: `MAJOR.MINOR.PATCH` (semver)

- MAJOR: Breaking changes to deployment or architecture
- MINOR: New features, backward compatible
- PATCH: Bug fixes, documentation, non-breaking changes

Version labels are stored in:
- `VERSION.md` - Human-readable version info
- `nh-defaults.sh` - Machine-readable defaults (`NH_VERSION_CODE`)
- `magisk-module/module.prop` - Magisk version fields
- `package.json` - NPM version field

Update all with:
```bash
./scripts/update-version.sh
```

## Project Map

```
nethunter-setup/
├── nhctl                  # Main orchestration script
├── Makefile               # Build system
├── nh-defaults.sh         # Configuration defaults
├── README.md              # Operating manual
├── VERSION.md             # Version info
├── CONTRIBUTING.md        # Coding standards
├── LICENSE                # GPLv3
├── Dockerfile             # Dev container
├── .github/workflows/     # CI/CD
├── payload/               # Device-side source
│   ├── nhsystem-bin/      #   Management scripts
│   ├── *.sh               #   Setup scripts
│   └── *.c                #   C source
├── scripts/               # Build/validation helpers
├── magisk-module/         # Flashable module
├── kernel/                # Kernel build infra
├── device/                # Device management
├── tests/                 # Test suite
├── templates/             # Config templates
└── docs/                  # Documentation
```
