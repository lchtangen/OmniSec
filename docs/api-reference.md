# API Reference: nhsystem-bin Scripts

All scripts live in `/data/local/nhsystem/bin/` on device.
Source of truth: `src/device/bin/` (staged to `payload/nhsystem-bin/` via `make stage`).

## Conventions

- **Shebang**: `#!/system/bin/sh`
- **Set**: `set -u` (no `-e` — errors are handled explicitly)
- **Library**: All scripts source `nh-lib` for shared helpers
- **Exit codes**: 0 = success, 1 = runtime error, 2 = usage error

---

## Core Library

### `nh-lib`

Shared library sourced by all scripts. Sets:

| Variable | Default | Description |
|----------|---------|-------------|
| `NHSYSTEM` | `/data/local/nhsystem` | Root of nhsystem tree |
| `NHROOTS` | `$NHSYSTEM/roots` | Chroot roots directory |
| `NHWORK` | `$NHSYSTEM/workspaces/main` | Shared workspace |
| `ARCH_LABEL` | `Arch ARM64 v2.0` | Arch label |
| `KALI_LABEL` | `Kali ARM64 v2.0` | Kali label |
| `NH_LABEL` | `NetHunter setup v2.0` | Project label |

Functions:

| Function | Args | Description |
|----------|------|-------------|
| `kali_root()` | none | Prints Kali rootfs path |
| `arch_root()` | none | Prints Arch rootfs path |
| `is_mounted()` | `<path>` | Returns 0 if path is mounted |
| `mount_root()` | `<path>` | Mounts all chroot filesystems (proc, sys, dev, tmpfs, workspace) |
| `chroot_exec()` | `<path> <cmd>` | Runs command inside chroot with clean env |
| `deploy_sudo_wrapper()` | `<path>` | Backs up sudo and installs su-based wrapper |

---

## Entry/Shell Scripts

### `nh-enter-arch`

Enter Arch chroot as `archlinux` user.

```
nh-enter-arch
```

Uses `setpriv --reuid` for privilege drop. Starts `arch-autostart.sh` on entry.

### `nh-enter-arch-root`

Enter Arch chroot as root.

```
nh-enter-arch-root
```

### `nh-enter-kali`

Enter Kali chroot as `kali` user (requires Magisk root).

```
nh-enter-kali
```

### `nh-enter-kali-root`

Enter Kali chroot as root.

```
nh-enter-kali-root
```

### `nh-shell`

Auto-detect available chroot and drop into it. Falls back to emergency shell.

```
nh-shell
```

### `nh-shell-kali`

Kali user shell via zsh.

### `nh-shell-root`

Kali root shell.

### `nh-shell-bash`

Kali user shell via bash.

### `nh-shell-emergency`

Pure Android emergency shell (no chroot).

### `nh-root-shell`

Magisk-elevated root shell entrypoint.

### `nh-android-shell`

Raw Android system shell: `exec /system/bin/sh`.

---

## Management Scripts

### `nh-mount`

Mount chroot filesystems.

```
nh-mount [all|kali|arch]
```

Mounts proc, sys, dev, dev/pts, dev/shm, tmpfs on /run and /tmp, and binds workspace + sdcard.

### `nh-umount`

Unmount chroot filesystems.

```
nh-umount [all|kali|arch]
```

### `nh-services`

Start SSH and VPN services.

```
nh-services start
```

Starts: Termux sshd (:8022), Kali sshd (:22), Arch sshd (:2222), WireGuard (wg0), Tor.
Service-specific config is regenerated on each boot (tmpfs is ephemeral).

### `nh-status`

Quick system status overview.

```
nh-status
```

Reports: mounts, ports, chroot state, backup timestamp.

### `nh-health`

Comprehensive health check with color-coded pass/fail/warn.

```
nh-health
```

Checks: disk space, nhsystem paths, chroot mounts, service ports, Arch packages, last update, WireGuard, Tor, backups, Termux.

### `nh-debug`

Deep diagnostic report.

```
nh-debug
```

Reports: Android info, disk usage, running services, chroot commands, privacy tool availability, backup state.

### `nh-audit`

Read-only device audit.

```
nh-audit
```

Checks: filesystem layout, permissions, launcher scripts, mounts, ports, tool availability (Arch + Kali).

### `nh-version`

Print version labels for all components.

```
nh-version
```

### `nh-update`

Update Arch chroot packages.

```
nh-update
```

Runs `pacman -Syu` inside Arch chroot with tmpfs cache mount.

### `nh-backup`

Workspace snapshot manager.

```
nh-backup workspace           # Create timestamped snapshot
nh-backup list                # List available snapshots
nh-backup restore <YYYYMMDD>  # Restore from snapshot
```

### `nh-vpn`

WireGuard VPN manager.

```
nh-vpn up            # Start WireGuard (wg0)
nh-vpn down          # Stop WireGuard
nh-vpn status        # Show connection status
nh-vpn setup         # Interactive setup
```

### `nh-config`

Configuration manager for `nhsystem/etc/nh-config.conf`.

```
nh-config list
nh-config get <key>
nh-config set <key> <value>
nh-config delete <key>
nh-config reset
nh-config export
nh-config import <file>
```

### `nh-init`

Project scaffold generator.

```
nh-init python <name>  # Python project scaffold
nh-init node <name>    # Node.js project scaffold
nh-init rust <name>    # Rust project scaffold
nh-init go <name>      # Go project scaffold
nh-init c <name>       # C project scaffold
nh-init shell <name>   # Shell script project scaffold
nh-init module <name>  # nh-module scaffold
nh-init workspace      # Full workspace layout
```

### `nh-module`

Module management system.

```
nh-module list              # List installed modules
nh-module install <url>     # Install module
nh-module remove <name>     # Remove module
nh-module enable <name>     # Enable module
nh-module disable <name>    # Disable module
nh-module info <name>       # Module info
nh-module create <name>     # Create new module
nh-module search <query>    # Search modules
```

### `nh-log`

Log viewer for nhsystem logs.

```
nh-log list                  # List available logs
nh-log tail <name> [lines]   # Tail a log (default 30 lines)
nh-log follow <name>         # Follow a log in real-time
nh-log clear                 # Clear all logs
```

Logs are stored in `/data/local/nhsystem/logs/`.

### `nh-wifi`

Wi-Fi diagnostics and monitor mode status.

```
nh-wifi
```

Reports: interfaces, connection status, scan results, monitor mode, external adapter chipset info.

### `nh-kex`

Kali KEX/VNC session manager.

```
nh-kex start     # Start VNC server on :1
nh-kex stop      # Stop VNC server
nh-kex restart   # Restart VNC
nh-kex status    # Show VNC status and port 5901
nh-kex log       # Show KEX log
```

VNC runs on display `:1`, port `5901` by default.

### `nh-firewall`

Firewall status and kernel netfilter diagnostics.

```
nh-firewall
```

Reports: kernel netfilter modules, nftables/iptables rules, conntrack stats.

### `nh-packages`

Package listing across chroots.

```
nh-packages               # Package counts across all chroots
nh-packages arch [search] # List/search Arch packages
nh-packages kali [search] # List/search Kali packages
nh-packages updates       # Check available updates
```

### `nh-perf`

System performance monitor.

```
nh-perf [duration_sec]
```

Reports: CPU load/cores/governor/freq, top CPU consumers, memory info, disk I/O, thermal zones.

---

## Monitor/Diagnostic Scripts

### `nh-battery`

Battery status and health monitor.

```
nh-battery
```

Visual battery bar, capacity, temp, health, charging status.

### `nh-bench`

Quick benchmark suite.

```
nh-bench
```

CPU prime test, memory bandwidth, storage speed, DNS resolution.

### `nh-clean`

System cleaner.

```
nh-clean
```

Cleans: tmp files, logs, staged files, package caches.

### `nh-dev`

Development environment manager.

```
nh-dev status          # Show dev tool versions
nh-dev setup           # Install/configure dev tools
nh-dev python          # Python toolchain info
nh-dev node            # Node.js toolchain info
nh-dev rust            # Rust toolchain info
nh-dev golang          # Go toolchain info
nh-dev android         # Android SDK/NDK info
nh-dev upgrade         # Upgrade dev tools
nh-dev info            # Detailed environment report
```

### `nh-net`

Network diagnostics toolkit.

```
nh-net
```

Reports: interfaces, routing, DNS, active connections, ARP cache, wireless info, bandwidth stats.

### `nh-proc`

Process monitor.

```
nh-proc
```

Top-like display: top CPU/memory consumers.

### `nh-scan`

Network discovery and port scanning.

```
nh-scan local             # Scan localhost
nh-scan subnet            # Scan current subnet
nh-scan gateway           # Scan gateway
nh-scan <ip>              # Scan specific IP
```

### `nh-temp`

SoC temperature monitor.

```
nh-temp
```

Reports: thermal zones, battery temp, CPU frequencies.
