#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DEEP=0

if [[ "${1:-}" == "--deep" ]]; then
    DEEP=1
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

section() { printf "\n${CYAN}== %s ==${NC}\n" "$1"; }
kv() { printf "  %-20s %s\n" "$1" "$2"; }

printf "${CYAN}╔══════════════════════════════════════╗${NC}\n"
printf "${CYAN}║   OmniSec AI Context Snapshot v3.0   ║${NC}\n"
printf "${CYAN}╚══════════════════════════════════════╝${NC}\n"

section "Repository"
kv "root" "$ROOT_DIR"
kv "branch" "$(git -C "$ROOT_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'N/A')"
kv "commit" "$(git -C "$ROOT_DIR" rev-parse HEAD 2>/dev/null | head -c 12 || echo 'N/A')"
kv "modified files" "$(git -C "$ROOT_DIR" status --short | wc -l | tr -d ' ')"

section "Working Tree"
git -C "$ROOT_DIR" --no-pager status --short 2>/dev/null || echo "(not a git repo)"

section "Recent Commits"
git -C "$ROOT_DIR" --no-pager log --oneline -n 10 2>/dev/null || echo "(no commits)"

section "Project Structure"
printf "  src/device/bin/         %4d nh-* tools\n" "$(find "$ROOT_DIR/src/device/bin/" -type f 2>/dev/null | wc -l)"
printf "  src/device/setup/       %4d setup scripts\n" "$(find "$ROOT_DIR/src/device/setup/" -type f 2>/dev/null | wc -l)"
printf "  src/c/                  %4d C source files\n" "$(find "$ROOT_DIR/src/c/" -type f -name '*.c' 2>/dev/null | wc -l)"
printf "  scripts/                %4d automation scripts\n" "$(find "$ROOT_DIR/scripts/" -type f -name '*.sh' 2>/dev/null | wc -l)"
printf "  plugins/                %4d plugin scripts\n" "$(find "$ROOT_DIR/plugins/" -type f 2>/dev/null | wc -l)"
printf "  tests/                  %4d test files\n" "$(find "$ROOT_DIR/tests/" -type f 2>/dev/null | wc -l)"
printf "  deploy/                 %4d deployment files\n" "$(find "$ROOT_DIR/deploy/" -type f 2>/dev/null | wc -l)"
printf "  .github/prompts/        %4d prompt templates\n" "$(find "$ROOT_DIR/.github/prompts/" -maxdepth 1 -type f -name '*.prompt.md' 2>/dev/null | wc -l)"
printf "  .github/instructions/   %4d instruction sets\n" "$(find "$ROOT_DIR/.github/instructions/" -maxdepth 1 -type f 2>/dev/null | wc -l)"

section "AI Agent Configs"
for cfg in "$ROOT_DIR/.cursorrules" "$ROOT_DIR/.windsurfrules" "$ROOT_DIR/.clinerules" "$ROOT_DIR/.aider.conf.yml" "$ROOT_DIR/.continue/config.json" "$ROOT_DIR/.claude/settings.local.json" "$ROOT_DIR/AGENTS.md" "$ROOT_DIR/.github/copilot-instructions.md"; do
    if [[ -f "$cfg" ]]; then
        printf "  ${GREEN}[ok]${NC} %s\n" "${cfg#$ROOT_DIR/}"
    else
        printf "  ${YELLOW}[missing]${NC} %s\n" "${cfg#$ROOT_DIR/}"
    fi
done

section "AI Tasks (VS Code)"
if [[ -f "$ROOT_DIR/.vscode/tasks.json" ]]; then
    grep -n '"label": "[A-Za-z].*:' "$ROOT_DIR/.vscode/tasks.json" 2>/dev/null | sed 's/^/  /' | head -40 || true
fi

section "Prompt Templates"
if [[ -d "$ROOT_DIR/.github/prompts" ]]; then
    find "$ROOT_DIR/.github/prompts" -maxdepth 1 -type f -name '*.prompt.md' | sort | while read -r f; do
        desc="$(head -3 "$f" | grep 'description:' | sed 's/description: *//' || true)"
        printf "  ${CYAN}-${NC} %s\n" "$(basename "$f"): ${desc:-no description}"
    done
fi

section "AI CLI Tools"
if [[ -x "$ROOT_DIR/scripts/ai-cli-doctor.sh" ]]; then
    "$ROOT_DIR/scripts/ai-cli-doctor.sh" 2>&1 | grep -E '^\[(ok|missing)\]' | head -20
else
    printf "  (ai-cli-doctor.sh not found)\n"
fi

section "nhctl AI Help"
if [[ -x "$ROOT_DIR/nhctl" ]]; then
    "$ROOT_DIR/nhctl" ai help 2>/dev/null || printf "  (nhctl ai help unavailable)\n"
fi

if [[ "$DEEP" -eq 1 ]]; then
    section "Deep: Lint Baseline"
    make -C "$ROOT_DIR" lint 2>&1 | tail -5 || true

    section "Deep: Test Baseline"
    make -C "$ROOT_DIR" test 2>&1 | tail -10 || true

    section "Deep: Source Tree (depth 3)"
    find "$ROOT_DIR/src" -maxdepth 3 -type f | sort | sed "s|$ROOT_DIR/||" | head -50

    section "Deep: Notable Configs"
    for f in "$ROOT_DIR/.shellcheckrc" "$ROOT_DIR/.pre-commit-config.yaml" "$ROOT_DIR/.editorconfig" "$ROOT_DIR/cspell.json" "$ROOT_DIR/package.json"; do
        if [[ -f "$f" ]]; then
            printf "  ${CYAN}-${NC} %s\n" "${f#$ROOT_DIR/}"
        fi
    done
fi

printf "\n${GREEN}ai-context-snapshot: completed${NC}\n"
