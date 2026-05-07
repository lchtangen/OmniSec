<!-- NH_SETUP_VERSION: 2.0 nextgen -->
<!-- PRIORITY: CRITICAL - System architecture foundation -->

# NetHunter NextGen Architecture

> **Priority**: CRITICAL — All development must follow this architecture
> **Version**: 2.0.0 | **Target**: OnePlus 7 Pro (guacamole) / SM8150

## System Layers (Priority Ordered)

```
P0 CRITICAL ─────────────────────────────────────────────────────
│  KERNEL    → Matrix build system, 6 variants, modular configs
│  SECURITY  → SELinux, AppArmor, IMA, verified boot
│  CORE      → nhsystem, chroots, namespaces, cgroups
│  NETWORK   → Netfilter, VPN, firewall, DNS
├───────────────────────────────────────────────────────────────
P1 HIGH ─────────────────────────────────────────────────────────
│  DEV TOOLS → nh-dev, nh-init, nh-config, nh-module
│  MONITOR   → nh-health, nh-status, nh-audit, nh-sysinfo
│  STORAGE   → nh-backup, nh-sync, nh-clean
│  NET OPS   → nh-net, nh-scan, nh-vpn, nh-tunnel, nh-dns
├───────────────────────────────────────────────────────────────
P2 MEDIUM ───────────────────────────────────────────────────────
│  UTILITIES → nh-banner, nh-bench, nh-proc, nh-temp, nh-battery
│  SCHEDULE  → nh-schedule, nh-alert
│  CONTAINER → nh-container, nh-kex
│  PERIPHERAL→ nh-audio, nh-display, nh-key, nh-secret
├───────────────────────────────────────────────────────────────
P3 LOW ──────────────────────────────────────────────────────────
│  ADVANCED  → nh-firewall, nh-packages, nh-perf, nh-log
│  COMMUNITY → Contributed modules, themes, starter packs
└───────────────────────────────────────────────────────────────
```

## Directory Priority Map

Every file and directory is tagged with its priority level.

```
nethunter-setup/                          [P0 CRITICAL]
├── kernel/                               [P0] Matrix kernel build system
│   ├── build-kernel.sh                   [P0] Primary build entrypoint
│   ├── configs/fragments/                [P0] Modular config fragments
│   ├── device/guacamole/                 [P0] Device-specific scripts
│   ├── patches/                          [P1] Kernel patches
│   ├── toolchain/                        [P1] Toolchain setup
│   ├── anykernel3/                       [P1] Flashable packaging
│   └── README.md                         [P0] Documentation
│
├── src/                                  [P0] Source tree
│   ├── c/                                [P1] C source (nh-sudo, no-close-range)
│   ├── scripts/                          [P0] Host-side automation (15 scripts)
│   ├── device/
│   │   ├── bin/                          [P0] Device-side tools (42 scripts)
│   │   ├── setup/                        [P0] Device setup/recovery
│   │   ├── dotfiles/                     [P1] Termux dotfiles
│   │   └── skel/                         [P1] Kali chroot skeleton
│   └── modules/                          [P2] Loadable modules **(NEW)**
│
├── deploy/                               [P1] Deployment artifacts
│   ├── magisk/                           [P1] Magisk module packaging
│   ├── android/                          [P1] build.prop overrides
│   ├── udev/                             [P1] udev rules
│   └── chroot/                           [P1] Chroot deployable scripts
│
├── docs/                                 [P1] Documentation
│   ├── ARCHITECTURE.md                   [P0] This file
│   ├── CODING_STANDARDS.md               [P0] Coding guidelines
│   ├── PRIORITY.md                       [P0] Priority system
│   ├── SECURITY.md                       [P0] Security standards
│   └── ...                               [P1-P3] Topic docs
│
├── .github/                              [P1] CI/CD and community
│   ├── workflows/                        [P1] GitHub Actions
│   └── ISSUE_TEMPLATE/                   [P2] Issue templates
│
├── tests/                                [P1] Test suite
├── nhctl                                 [P0] Primary host entrypoint
├── Makefile                              [P0] Build system
├── README.md                             [P0] Project overview
└── PROJECT_AUDIT.md                      [P0] Master roadmap + 100 tasks
```

## Priority Definitions

| Priority | Label | Meaning | Failure Impact |
|----------|-------|---------|----------------|
| P0 | CRITICAL | System must function | Complete failure |
| P1 | HIGH | Core features complete | Major degradation |
| P2 | MEDIUM | Enhanced functionality | Minor degradation |
| P3 | LOW | Polish and extras | Cosmetic only |

## Critical Data Flow

```
HOST (Linux x86_64)                        DEVICE (Android ARM64)
─────────────────────                      ──────────────────────
nhctl ──adb──→ /data/local/nhsystem/bin/*  (42 tools)
     │                                        │
     ├──→ make stage ──→ payload/             ├──→ Arch ARM64 chroot
     ├──→ kernel build ──→ dist/              ├──→ Kali ARM64 chroot
     └──→ tests ──→ results/                  └──→ Termux shell
```

## Compliance Rules

1. **ALL new code must declare priority** in header comment: `# PRIORITY: P0|P1|P2|P3`
2. **ALL directories must have priority in ARCHITECTURE.md** before files are added
3. **P0/P1 code must have tests** before merge
4. **P0/P1 code must pass shellcheck** with no warnings
5. **All scripts must use consistent color scheme** (see STYLEGUIDE.md)
6. **All error messages must be actionable** — tell user what to do, not just what failed
7. **All tools must support --help** with usage, description, examples
