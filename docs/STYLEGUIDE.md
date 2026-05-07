<!-- NH_SETUP_VERSION: 2.0 nextgen -->
<!-- PRIORITY: P2 MEDIUM - Style guide -->

# NetHunter NextGen Cyberpunk Style Guide

> **Priority**: MEDIUM — Visual consistency
> **Version**: 2.0.0

## 1. Color Palette

### Terminal Colors
```
ANSI Code  Role          Hex        Preview
─────────────────────────────────────────────────
32         Success       #00FF00    Green neon
33         Warning       #FFD700    Gold
31         Error         #FF0000    Red alert
36         Headers       #00FFFF    Cyan glow
35         Branding      #FF00FF    Magenta neon
37         Info          #FFFFFF    White
90         Muted         #808080    Dim gray
```

### Usage
```bash
say()    { printf "\033[32m  %s\033[0m\n" "$*"; }  # Green  - Success
warn()   { printf "\033[33m  %s\033[0m\n" "$*"; }  # Yellow - Warning
die()    { printf "\033[31m  ERROR: %s\033[0m\n" "$*"; exit 1; }  # Red
header() { printf "\033[36m=== %s ===\033[0m\n" "$*"; }  # Cyan
brand()  { printf "\033[35m  %s\033[0m\n" "$*"; }  # Magenta - branding
```

## 2. Typography

### ASCII Art Style
```
╔══════════════════════════════════╗
║  NetHunter NextGen v2.0          ║
║  OnePlus 7 Pro (guacamole)       ║
╚══════════════════════════════════╝
```

### Unicode Symbols
```
▶  Prompt cursor (cyan)
⚡ Status indicator (yellow)
✓  Success checkmark (green)
✗  Error cross (red)
→  Arrow (cyan)
◆  Diamond bullet (magenta)
■  Square bullet (cyan)
─  Horizontal line (dim)
│  Vertical line (dim)
══  Double line header (cyan)
──  Single line separator (dim)
```

## 3. Output Formats

### 3.1 Headers
```
══ Section Title ══
```

### 3.2 Subsections
```
── Subsection ──
```

### 3.3 Key-Value
```
  Key:           Value
  Long Key:      Value
```

### 3.4 Tables
```
  ┌─────────┬──────────┐
  │ Name    │ Status   │
  ├─────────┼──────────┤
  │ Item 1  │ ✓ OK     │
  │ Item 2  │ ✗ Error  │
  └─────────┴──────────┘
```

### 3.5 Progress
```
  [████████░░] 80%  (simplified with characters)
```

## 4. Command Naming

### nh-* Tools
```
nh-<verb>           # Primary command
nh-<verb> <noun>    # Action on noun
nh-<verb> --flag    # Flags for options
```

### Verb Conventions
```
get/set       → Configuration access
list/show     → Display information
create/remove → Object lifecycle
start/stop    → Service management
enable/disable→ Feature toggling
install/remove→ Package management
backup/restore→ Data protection
```

## 5. Message Templates

### 5.1 Success
```
  Kernel built: /path/to/output (12MB)
```

### 5.2 Warning
```
  WARNING: Battery below 20%. Plugin charger.
```

### 5.3 Error
```
  ERROR: Toolchain not found.
  Install: sudo apt install gcc-aarch64-linux-gnu
```

### 5.4 Info
```
  Device: OnePlus 7 Pro GM1911 | Android 16 | Kernel 4.14.356
```

## 6. Starship Prompt

The cyberpunk prompt (starship.toml) follows these rules:

```
╭─ 🤖 root ● /data/local/nhsystem  ⎇ main ◇  ⬡ v20.11.0
│  ⚙ v1.65.0  ⌘ v1.21.0  🐳  ████████████████████████████████████
│
▶
```

- Multi-line layout (two lines + cursor)
- Neon segment transitions (green → cyan → blue → magenta → red)
- Language badges auto-detect project files
- Git status displayed inline
- OS icon for Android
- Duration shown for commands >2s
