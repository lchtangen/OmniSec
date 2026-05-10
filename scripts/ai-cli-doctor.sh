#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

check_cmd() {
    local name="$1" bin="$2" version_cmd="$3" extra="${4:-}"

    if type -P "$bin" >/dev/null 2>&1; then
        local path; path="$(type -P "$bin")"
        printf "${GREEN}[ok]${NC} %-18s %s\n" "$name" "$path"
        if [[ -n "$version_cmd" ]]; then
            local tmpfile; tmpfile="$(mktemp /tmp/omnisec_ai_doctor_XXXXXX)"
            if eval "$version_cmd" 2>/dev/null | head -1 > "$tmpfile"; then
                local version_line; version_line="$(cat "$tmpfile" || true)"
                printf "     ${CYAN}version:${NC} %s\n" "${version_line:-"(no output)"}"
            else
                printf "     ${YELLOW}version:${NC} (failed to query)\n"
            fi
            rm -f "$tmpfile"
        fi
        if [[ -n "$extra" ]]; then
            printf "     ${CYAN}info:${NC} %s\n" "$extra"
        fi
    else
        printf "${YELLOW}[missing]${NC} %-14s %s\n" "$name" "$bin"
    fi
}

check_config() {
    local name="$1" path="$2"
    if [[ -f "$path" ]]; then
        local size; size="$(wc -l < "$path" | tr -d ' ')"
        printf "${GREEN}[ok]${NC} %-18s %s (%d lines)\n" "$name" "$path" "$size"
    else
        printf "${YELLOW}[missing]${NC} %-14s %s\n" "$name" "$path"
    fi
}

printf "${CYAN}╔══════════════════════════════════════╗${NC}\n"
printf "${CYAN}║      OmniSec AI CLI Doctor v3.0      ║${NC}\n"
printf "${CYAN}╚══════════════════════════════════════╝${NC}\n"
printf "root: %s\n\n" "$ROOT_DIR"

printf "${CYAN}--- AI CLI Tools ---${NC}\n"
check_cmd "Codex" "codex" "codex --version" "npm install -g @openai/codex"
check_cmd "Claude" "claude" "claude --version" "npm install -g @anthropic-ai/claude-code"
check_cmd "Aider" "aider" "aider --version" "pip install aider-chat"
check_cmd "Copilot CLI" "gh" "gh --version" "npm install -g @githubnext/github-copilot-cli"
check_cmd "Gemini" "gemini" "gemini --version" "install from official Gemini CLI docs"
check_cmd "Codeium" "codeium" "codeium --version" "install from official Codeium CLI docs"
check_cmd "Cody" "cody" "npx cody --version" "install from official Sourcegraph Cody docs"
check_cmd "Continue (cn)" "cn" "cn --version || true" "npm install -g --prefix \$HOME/.local @continuedev/cli"
check_cmd "Augment (auggie)" "auggie" "auggie --version || true" "npm install -g --prefix \$HOME/.local @augmentcode/auggie"
check_cmd "OpenCode" "opencode" "opencode --version 2>/dev/null || true" "npm install -g @opencode/cli"
check_cmd "Windsurf" "windsurf" "windsurf --version 2>/dev/null || true" "install from official Windsurf docs"

printf "\n${CYAN}--- Agent Config Files ---${NC}\n"
check_config "AGENTS.md" "$ROOT_DIR/AGENTS.md"
check_config ".cursorrules" "$ROOT_DIR/.cursorrules"
check_config ".windsurfrules" "$ROOT_DIR/.windsurfrules"
check_config ".clinerules" "$ROOT_DIR/.clinerules"
check_config ".aider.conf.yml" "$ROOT_DIR/.aider.conf.yml"
check_config "Continue config" "$ROOT_DIR/.continue/config.json"
check_config "Claude settings" "$ROOT_DIR/.claude/settings.local.json"
check_config "Copilot instructions" "$ROOT_DIR/.github/copilot-instructions.md"

printf "\n${CYAN}--- Prompt Templates ---${NC}\n"
prompt_dir="$ROOT_DIR/.github/prompts"
if [[ -d "$prompt_dir" ]]; then
    local_count="$(find "$prompt_dir" -maxdepth 1 -type f -name '*.prompt.md' | wc -l | tr -d ' ')"
    printf "${GREEN}[ok]${NC} %-18s %d prompt files\n" "Prompt count" "$local_count"
    find "$prompt_dir" -maxdepth 1 -type f -name '*.prompt.md' | while read -r f; do
        desc="$(head -3 "$f" | grep 'description:' | sed 's/description: *//' || true)"
        printf "     ${CYAN}-${NC} %s\n" "$(basename "$f" .prompt.md): ${desc:-no description}"
    done
else
    printf "${YELLOW}[warn]${NC} missing prompt template directory\n"
fi

printf "\n${CYAN}--- AI Agent Instructions ---${NC}\n"
inst_dir="$ROOT_DIR/.github/instructions"
if [[ -d "$inst_dir" ]]; then
    find "$inst_dir" -maxdepth 1 -type f -name '*.instructions.md' | while read -r f; do
        apply_to="$(head -5 "$f" | grep 'applyTo:' | sed 's/applyTo: *//' || true)"
        printf "     ${CYAN}-${NC} %s (applies to: %s)\n" "$(basename "$f" .instructions.md)" "${apply_to:-all}"
    done
fi

printf "\n${GREEN}ai-cli-doctor: completed${NC}\n"
