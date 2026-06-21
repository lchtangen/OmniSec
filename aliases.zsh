# ===== OmniSec Cyberpunk Edition — Project Aliases =====
# Source this from .zshrc or .bashrc

export WS_ROOT="$HOME/projects/multi-platform"

# ── Quick cd aliases ────────────────────────────────────────────

# Platform roots
alias repos="cd $WS_ROOT/repos"
alias r-linux="cd $WS_ROOT/repos/desktop/linux"
alias r-android="cd $WS_ROOT/repos/mobile/android"
alias r-web="cd $WS_ROOT/repos/web"
alias r-macos="cd $WS_ROOT/repos/desktop/macos"
alias r-windows="cd $WS_ROOT/repos/desktop/windows"
alias r-embedded="cd $WS_ROOT/repos/embedded"
alias r-ios="cd $WS_ROOT/repos/mobile/ios"
alias r-ref="cd $WS_ROOT/repos/reference"

# Your projects (desktop/linux)
alias omnisec="cd $WS_ROOT/repos/desktop/linux/omnisec"
alias cyberflash="cd $WS_ROOT/repos/desktop/linux/cyberflash-tool"
alias kali="cd $WS_ROOT/repos/desktop/linux/kali-workspace"
alias lk="cd $WS_ROOT/repos/desktop/linux/linux-omnisec"
alias sec-tools="cd $WS_ROOT/repos/desktop/linux/security-tools"

# Your projects (mobile/android)
alias op7p="cd $WS_ROOT/repos/mobile/android/op7p-env"
alias vault="cd $WS_ROOT/repos/mobile/android/vault-android16"
alias m-sec-tools="cd $WS_ROOT/repos/mobile/android/security-tools"

# Tools & scripts
alias ws="cd $WS_ROOT"
alias themes="cd $WS_ROOT/themes"
alias dash="cd $WS_ROOT/dashboard"
alias scr="cd $WS_ROOT/scripts"
alias docs="cd $WS_ROOT/docs"

# ── VS Code shortcuts ───────────────────────────────────────────

alias vsws="code $WS_ROOT"
alias vsomnisec="code $WS_ROOT/repos/desktop/linux/omnisec"
alias vscyberflash="code $WS_ROOT/repos/desktop/linux/cyberflash-tool"
alias vsop7p="code $WS_ROOT/repos/mobile/android/op7p-env"
alias vskali="code $WS_ROOT/repos/desktop/linux/kali-workspace"
alias vslk="code $WS_ROOT/repos/desktop/linux/linux-omnisec"
alias vsvault="code $WS_ROOT/repos/mobile/android/vault-android16"
alias vssec="code $WS_ROOT/repos/desktop/linux/security-tools"
alias vsref="code $WS_ROOT/repos/reference"
alias vsthemes="code $WS_ROOT/themes"
alias vsdash="code $WS_ROOT/dashboard"

# ── Launch shortcuts ────────────────────────────────────────────

alias launch-omnisec="cd $WS_ROOT/repos/desktop/linux/omnisec/platform && python3 gui/main.py"
alias launch-cyberflash="cd $WS_ROOT/repos/desktop/linux/cyberflash-tool && python3 -m cyberflash"
alias launch-dash="cd $WS_ROOT && python3 -m http.server 8080 &; sleep 1; xdg-open http://localhost:8080/dashboard/"

# ── Quick git commands ──────────────────────────────────────────

alias gs="git status -sb"
alias gl="git log --oneline --graph --decorate -20"
alias gpull-all="find $WS_ROOT -name '.git' -type d -execdir git pull \;"

# ── Make/CPE wrappers ───────────────────────────────────────────

alias cpe="$WS_ROOT/scripts/cpe"
alias cpestatus="$WS_ROOT/scripts/cpe status"
alias cpelist="$WS_ROOT/scripts/cpe list"
alias cpesearch="$WS_ROOT/scripts/cpe search"
alias cpetheme="$WS_ROOT/scripts/cpe theme"

# ── Workspace context ───────────────────────────────────────────

ws-status() {
  echo "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
  echo "  OmniSec Cyberpunk Edition — Workspace Context"
  echo "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
  echo "  Root:   $WS_ROOT"
  echo "  Shell:  $(basename $SHELL)"
  echo "  Python: $(python3 --version 2>/dev/null)"
  echo "  Node:   $(node --version 2>/dev/null || echo 'N/A')"
  echo "  Git:    $(git --version 2>/dev/null)"
  echo ""
  echo "  Quick access:"
  echo "    omnisec     — NetHunter Matrix v3.0"
  echo "    cyberflash  — AI-Powered ROM Flasher"
  echo "    op7p        — OnePlus 7 Pro Dev Environment"
  echo "    kali        — NetHunter Workspace"
  echo "    lk          — linux-omnisec kernel"
  echo "    vault       — Encrypted Backup"
  echo ""
  echo "  Commands:"
  echo "    vs<project> — Open project in VS Code"
  echo "    cpe <cmd>   — Unified CLI tool"
  echo "    launch-*    — Run GUI applications"
}

# Show workspace context on terminal start
echo "  [CPE] Workspace loaded. Type 'ws-status' for project shortcuts."
