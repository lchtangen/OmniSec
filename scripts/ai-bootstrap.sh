#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
FULL=0

if [[ "${1:-}" == "--full" ]]; then
    FULL=1
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

step() { printf "\n${CYAN}[%s/%s]${NC} %s\n" "$1" "$2" "$3"; }
pass() { printf "${GREEN}  ✓${NC} %s\n" "$1"; }
fail() { printf "${RED}  ✗${NC} %s\n" "$1"; }

TOTAL=7

printf "${CYAN}╔══════════════════════════════════════╗${NC}\n"
printf "${CYAN}║      OmniSec AI Bootstrap v3.0       ║${NC}\n"
printf "${CYAN}╚══════════════════════════════════════╝${NC}\n"
printf "root: %s\n" "$ROOT_DIR"
printf "mode: %s\n\n" "$([[ "$FULL" -eq 1 ]] && echo "full" || echo "standard")"

step 1 $TOTAL "Repository Health"
if "$ROOT_DIR/scripts/pre-rename-audit.sh" 2>&1 | tail -3; then
    pass "rename audit"
else
    fail "rename audit had warnings"
fi

step 2 $TOTAL "Repo Doctor"
if "$ROOT_DIR/repo-doctor.sh" 2>&1 | tail -3; then
    pass "repo doctor"
else
    fail "repo doctor had issues"
fi

step 3 $TOTAL "AI CLI Path Fix"
if "$ROOT_DIR/scripts/ai-cli-fix-paths.sh" 2>&1 | tail -2; then
    pass "ai cli path fix"
else
    fail "ai cli path fix had issues"
fi

step 4 $TOTAL "AI CLI Tools"
if "$ROOT_DIR/scripts/ai-cli-doctor.sh" 2>&1 | tail -1; then
    pass "ai cli doctor"
else
    fail "ai cli doctor had issues"
fi

step 5 $TOTAL "AI Context Snapshot"
if "$ROOT_DIR/scripts/ai-context-snapshot.sh" 2>&1 | tail -1; then
    pass "context snapshot"
else
    fail "context snapshot had issues"
fi

step 6 $TOTAL "Agent Config Audit"
missing=0
for cfg in "$ROOT_DIR/.cursorrules" "$ROOT_DIR/.windsurfrules" "$ROOT_DIR/.clinerules" "$ROOT_DIR/.aider.conf.yml" "$ROOT_DIR/.continue/config.json" "$ROOT_DIR/.claude/settings.local.json" "$ROOT_DIR/AGENTS.md" "$ROOT_DIR/.github/copilot-instructions.md"; do
    if [[ ! -f "$cfg" ]]; then
        printf "  ${YELLOW}missing:${NC} %s\n" "${cfg#$ROOT_DIR/}"
        missing=$((missing + 1))
    fi
done
if [[ "$missing" -eq 0 ]]; then
    pass "all agent configs present"
else
    fail "$missing agent config(s) missing"
fi

step 7 $TOTAL "Quality Gate"
if [[ "$FULL" -eq 1 ]]; then
    printf "  Running lint...\n"
    if make -C "$ROOT_DIR" lint 2>&1 | tail -3; then
        pass "lint"
    else
        fail "lint failed"
    fi
    printf "  Running tests...\n"
    if make -C "$ROOT_DIR" test 2>&1 | tail -5; then
        pass "tests"
    else
        fail "tests had failures"
    fi
else
    printf "  ${YELLOW}skip lint+test (use --full to include)${NC}\n"
    printf "  ${YELLOW}hint: run 'make ai-bootstrap-full' or 'make validate' separately${NC}\n"
fi

printf "\n${GREEN}╔══════════════════════════════════════╗${NC}\n"
printf "${GREEN}║     AI Bootstrap: Complete           ║${NC}\n"
printf "${GREEN}╚══════════════════════════════════════╝${NC}\n"
