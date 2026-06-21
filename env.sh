# OmniSec Universe — Unified Environment
# Source this once to set up the complete workspace.

export OMNISEC_ROOT="$HOME/projects/multi-platform"
export OMNISEC_VERSION="3.0.0"

# ── Platform paths ──────────────────────────────────────────────
export OMNISEC_DIR="$OMNISEC_ROOT/repos/desktop/linux/omnisec"
export CYBERFLASH_DIR="$OMNISEC_ROOT/repos/desktop/linux/cyberflash-tool"
export KALI_DIR="$OMNISEC_ROOT/repos/desktop/linux/kali-workspace"
export KERNEL_DIR="$OMNISEC_ROOT/repos/desktop/linux/linux-omnisec"
export OP7P_DIR="$OMNISEC_ROOT/repos/mobile/android/op7p-env"
export VAULT_DIR="$OMNISEC_ROOT/repos/mobile/android/vault-android16"
export SECTOOLS_DIR="$OMNISEC_ROOT/repos/desktop/linux/security-tools"
export THEMES_DIR="$OMNISEC_ROOT/themes"
export SCRIPTS_DIR="$OMNISEC_ROOT/scripts"
export DASHBOARD_DIR="$OMNISEC_ROOT/dashboard"

# ── PATH ────────────────────────────────────────────────────────
export PATH="$SCRIPTS_DIR:$OMNISEC_DIR:$OMNISEC_DIR/platform/scripts:$PATH"

# ── Python path (make all modules importable) ───────────────────
export PYTHONPATH="$OMNISEC_DIR/platform:$CYBERFLASH_DIR/src:$OMNISEC_ROOT:$PYTHONPATH"

# ── Aliases ─────────────────────────────────────────────────────
alias ws="cd $OMNISEC_ROOT"
alias hub="cd $OMNISEC_ROOT"
alias uni="cd $OMNISEC_ROOT"

# Your projects
alias omni="cd $OMNISEC_DIR"
alias cf="cd $CYBERFLASH_DIR"
alias op="cd $OP7P_DIR"
alias ka="cd $KALI_DIR"
alias lk="cd $KERNEL_DIR"
alias va="cd $VAULT_DIR"
alias st="cd $SECTOOLS_DIR"

# Quick open in VS Code
alias vomni="code $OMNISEC_DIR"
alias vcf="code $CYBERFLASH_DIR"
alias vop="code $OP7P_DIR"
alias vka="code $KALI_DIR"
alias vlk="code $KERNEL_DIR"
alias vva="code $VAULT_DIR"
alias vst="code $SECTOOLS_DIR"
alias vhub="code $OMNISEC_ROOT"

# Unified commands (all start with u-)
alias u-status="$SCRIPTS_DIR/cpe status"
alias u-list="$SCRIPTS_DIR/cpe list"
alias u-search="$SCRIPTS_DIR/cpe search"
alias u-build="cd $OMNISEC_ROOT && make build"
alias u-all="cd $OMNISEC_ROOT && make all-platforms"
alias u-run="cd $OMNISEC_DIR/platform && python3 gui/main.py"
alias u-flash="cd $CYBERFLASH_DIR && python3 -m cyberflash"
alias u-dash="cd $OMNISEC_ROOT && python3 -m http.server 8080"
alias u-help="echo 'u-status u-list u-search u-build u-all u-run u-flash u-dash u-serve u-sync u-health'"
alias u-serve="cd $OMNISEC_ROOT && python3 -m http.server 8080"
alias u-sync="find $OMNISEC_ROOT -name '.git' -type d -execdir git pull \;"
alias u-health="$SCRIPTS_DIR/cpe status"

# ── Git shortcuts ───────────────────────────────────────────────
alias g="git"
alias gs="git status -sb"
alias gl="git log --oneline --graph --decorate -20"
alias gp="git pull"
alias gc="git commit -m"
alias gca="git commit --amend -m"

# ── Docker shortcuts ────────────────────────────────────────────
alias d-build="cd $OMNISEC_DIR && docker buildx build --platform linux/arm64,linux/amd64 -t omnisec/cyberpunk:latest -f Dockerfile.multiarch ."
alias d-run="cd $OMNISEC_DIR/platform && docker-compose up"

# ── System info ─────────────────────────────────────────────────
uname -a 2>/dev/null | awk '{print "  System: " $2 " | " $1 " " $3}'
python3 --version 2>/dev/null | awk '{print "  Python: " $2}'
git --version 2>/dev/null | awk '{print "  Git: " $3}'
echo "  Workspace: $OMNISEC_ROOT"
echo "  Projects: 6 first-party, 40+ tools"
echo ""
echo "  ▸ Type u-help for commands"
echo "  ▸ Type ws-status for project shortcuts"
echo "  ▸ Type omni / cf / op / ka / lk / va to cd to projects"
echo "  ▸ Type vomni / vcf / vop to open in VS Code"
