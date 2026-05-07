<!-- NH_SETUP_VERSION: 2.0 nextgen -->
<!-- PRIORITY: CRITICAL - All code must follow these standards -->

# NetHunter NextGen Coding Standards

> **Priority**: CRITICAL — All code in this project MUST conform

## 1. Universal Rules (ALL Languages)

### 1.1 Header Comment
Every file must start with:
```bash
# NH_SETUP_VERSION: 2.0 nextgen
# PRIORITY: P0|P1|P2|P3
# DESCRIPTION: One-line description
```

### 1.2 Priority Declaration
Every file must declare its priority in the header. Valid values:
- `P0 CRITICAL` — System must function
- `P1 HIGH` — Core features
- `P2 MEDIUM` — Enhanced functionality
- `P3 LOW` — Polish

### 1.3 Error Handling
```
ALL errors must:
✓ Print to stderr (>&2)
✓ Include actionable message ("Run: make install")
✓ Exit with non-zero code
✓ Include error context (file, line, operation)

NO silent failures
NO bare "Error" without explanation
```

### 1.4 Output Conventions
```
ALL output must:
✓ Use color functions: say() [green], warn() [yellow], die() [red]
✓ Print progress indicators for operations >1 second
✓ Show file sizes, counts, durations where applicable

COLOR SCHEME (terminal):
  Green  → Success, OK, healthy
  Yellow → Warning, info, progress
  Red    → Error, failure, critical
  Cyan   → Headers, sections
  Magenta→ Branding, version info
```

### 1.5 Input Validation
```
ALL user input must:
✓ Validate existence (file/dir checks)
✓ Validate format (regex patterns)
✓ Validate range (numeric bounds)
✓ Sanitize shell metacharacters
✓ Provide clear error on invalid input
```

## 2. Bash Standards

### 2.1 Shebang
```bash
#!/usr/bin/env bash      # Host scripts
#!/system/bin/sh         # Device scripts
```

### 2.2 Strict Mode
```bash
# Host scripts (full safety):
set -euo pipefail

# Device scripts (compatible with Android shell):
# Note: set -u may not work on all Android shells
set -e
```

### 2.3 Functions
```bash
# Naming: snake_case, descriptive verbs
check_toolchain() { ... }
build_variant_kernel() { ... }

# Functions must declare local variables
my_func() {
    local arg1="$1"
    local result=""
    ...
}
```

### 2.4 Color Output Helpers
```bash
# MUST use these exact functions for all output:
say()  { printf "\033[32m  %s\033[0m\n" "$*"; }   # Green - success
warn() { printf "\033[33m  %s\033[0m\n" "$*"; }   # Yellow - warning
die()  { printf "\033[31m  ERROR: %s\033[0m\n" "$*"; exit 1; }  # Red - fatal
header() { printf "\033[36m=== %s ===\033[0m\n" "$*"; }  # Cyan - section
```

### 2.5 Error Pattern
```bash
# DO:
[ -f "$file" ] || die "File not found: $file"
command || die "Failed to: $operation"

# DON'T:
command
# (no error check)
```

### 2.6 File Operations
```bash
# Use full paths, never relative
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Check before operations
[ -d "$dir" ] || mkdir -p "$dir"
[ -f "$src" ] || die "Source missing: $src"
```

## 3. C Standards

### 3.1 Format
```c
// BSD style indentation, 4-space tabs
// Functions: return_type\nname(\n    params\n)
// No Tabs, 4-space indentation
```

### 3.2 Security
```c
// No unsafe functions: strcpy, strcat, sprintf
// Use: strlcpy, strlcat, snprintf
// Always bounds-check buffers
// Always check return values
```

### 3.3 Compilation
```bash
# All C must compile with:
cc -Wall -Wextra -pedantic -O2
```

## 4. Zsh Standards (Dotfiles)

### 4.1 Aliases
```zsh
# All nh-* tools must have aliases
alias nh-tool='nh-tool'
alias short='nh-tool --short'
```

### 4.2 Environment
```zsh
# Clear, documented, namespaced
export NH_ROOT="/data/local/nhsystem"
export NH_VERSION="2.0.0"
```

## 5. Python Standards (if added)

```python
# PEP 8 compliant
# Type hints required for all functions
# Docstrings for all public API
```

## 6. Documentation Standards

```markdown
# Title — Brief Description

> **Priority**: P0|P1|P2|P3
> **Version**: x.y.z

## Section (## with capital first letter)

Content with proper markdown formatting.

### Subsection (### with capital first letter)

- Lists for items
- Consistent formatting

Code blocks with language tags:
```bash
command
```
```

## 7. Git Standards

### 7.1 Commit Messages
```
<type>(<scope>): <description>

<body>

<footer>
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `perf`
Scopes: `kernel`, `scripts`, `tools`, `docs`, `ci`, `deploy`, `tests`

### 7.2 Branch Naming
```
feature/<description>
fix/<description>
docs/<description>
refactor/<description>
```

### 7.3 PR Requirements
```
✓ All tests pass (make validate)
✓ No shellcheck warnings
✓ Documentation updated
✓ Priority declared
✓ CHANGELOG entry (if applicable)
```

## 8. Enforcement

These standards are enforced by:
1. `make lint` — Shell syntax + C syntax + JSON validation
2. `make validate` — Full validation pipeline
3. shellcheck — Static analysis (configured in .shellcheckrc)
4. Code review — Manual review before merge to main

Violations in P0/P1 code block PRs. P2/P3 violations should be fixed before merge.
