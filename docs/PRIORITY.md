<!-- NH_SETUP_VERSION: 2.0 nextgen -->
<!-- PRIORITY: CRITICAL - Priority system definition -->

# NetHunter NextGen Priority System

> **Priority**: CRITICAL — This defines how ALL work is organized
> **Version**: 2.0.0

## Overview

The priority system ensures that critical infrastructure is built and maintained first, with enhancements and polish added in order of impact. Every file, task, and feature in the project is assigned one of four priority levels.

## Priority Levels

### P0 — CRITICAL (Red)
**If this fails, the system is broken.**

| Aspect | Criteria |
|--------|----------|
| Impact | Complete system failure |
| Response | Fix immediately, stop all other work |
| Testing | Required before every commit |
| Review | Mandatory peer review |
| Examples | Kernel boot, ADB connectivity, chroot mounts, core tools (nh-status, nh-enter-*) |

**P0 Files:**
- `kernel/build-kernel.sh` — Kernel build entrypoint
- `kernel/configs/fragments/*.conf` — Kernel config
- `src/device/bin/nh-lib` — Shared library
- `src/device/bin/nh-mount`, `nh-umount` — Chroot mounts
- `src/device/bin/nh-enter-*` — Chroot entry
- `nhctl` — Primary host entrypoint
- `Makefile` — Build system
- `src/scripts/preflight.sh` — Device readiness check

### P1 — HIGH (Orange)
**If this fails, core features are degraded.**

| Aspect | Criteria |
|--------|----------|
| Impact | Major feature degradation |
| Response | Fix within 24 hours |
| Testing | Required |
| Review | Recommended |
| Examples | nh-dev, nh-init, nh-config, nh-module, nh-backup, nh-health, nh-net, nh-scan, nh-vpn |

**P1 Directories:**
- `src/device/bin/` — All management scripts
- `src/scripts/` — Host-side automation
- `src/device/setup/` — Device setup scripts
- `deploy/` — Deployment artifacts
- `kernel/device/` — Device-specific build
- `kernel/anykernel3/` — Flashable packaging

### P2 — MEDIUM (Yellow)
**If this fails, enhanced functionality is reduced.**

| Aspect | Criteria |
|--------|----------|
| Impact | Minor feature degradation |
| Response | Fix within 1 week |
| Testing | Recommended |
| Review | Optional |
| Examples | nh-banner, nh-bench, nh-proc, nh-temp, nh-battery, nh-schedule, nh-alert, nh-sync, nh-tunnel, nh-dns |

**P2 Directories:**
- `src/modules/` — Loadable modules
- `tests/` — Test suite
- `docs/` — Documentation
- `.github/` — CI/CD workflows

### P3 — LOW (Green)
**If this fails, only polish is affected.**

| Aspect | Criteria |
|--------|----------|
| Impact | Cosmetic only |
| Response | Fix when convenient |
| Testing | Optional |
| Review | Not required |
| Examples | Themes, wallpapers, community modules, starter packs, i18n translations |

## Priority Assignment Rules

### Rule 1: Dependency Chain
A component's priority is the highest priority of anything it depends on:
```
P0 kernel  → P0 configs
P0 mounts  → P0 nh-lib
P1 nh-dev  → P0 mounts
P2 nh-bench → P1 nh-lib
```

### Rule 2: New Code
All new code must declare priority in its header:
```bash
# PRIORITY: P1
```

### Rule 3: Priority Escalation
If a P2/P3 component becomes critical to daily workflow, it may be escalated to P1.

### Rule 4: Priority Reduction
If a P0 component has been stable for 3+ months with no failures, it may be reduced to P1.

## Task Planning Matrix

| Priority | Dev Time | Test Coverage | Review Required | Response Time |
|----------|----------|---------------|-----------------|---------------|
| P0 | Any | 100% | Yes | Immediate |
| P1 | Any | 80%+ | Yes | 24 hours |
| P2 | Limited | 50%+ | Optional | 1 week |
| P3 | As available | Smoke test | No | Best effort |

## Current Priority Map

### P0 Tasks (15 — Always Working)
```
A1-A15: Kernel builds, device compatibility, CI/CD
```

### P1 Tasks (33 — Next in Queue)
```
B1-B14: Kernel features (close_range, WireGuard, io_uring)
C1-C10: Device support expansion
D1-D12: Security hardening
E1-E12: NetHunter features
```

### P2 Tasks (30 — Enhancement Queue)
```
F1-F10: Performance engineering
G1-G7: Tool ecosystem
H1-H10: Module ecosystem
I1-I14: Documentation
J1-J12: Testing
```

### P3 Tasks (22 — Icebox)
```
K1-K10: Integration/deployment
L1-L12: Advanced features
M1-M8: Community
```

## How to Use This System

### Daily Development
1. Always work on highest-priority items first
2. P0 bugs block all other work
3. P1 features are the normal development target
4. P2 features are for when P0/P1 are stable
5. P3 features are for hackathons and community contributions

### Code Review
1. Check priority declaration in file header
2. Verify test coverage meets priority requirements
3. Confirm documentation meets priority requirements

### Release Management
1. A release must have all P0 items complete
2. P1 items should be complete for major releases
3. P2/P3 items are optional per release
