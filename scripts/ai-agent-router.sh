#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

usage() {
    printf "${CYAN}OmniSec AI Agent Router v3.0${NC}\n"
    printf "Usage: %s <agent> [args...]\n\n" "$(basename "$0")"
    printf "Available agents:\n"
    printf "  ${GREEN}codex${NC}     OpenAI Codex CLI\n"
    printf "  ${GREEN}claude${NC}    Anthropic Claude CLI\n"
    printf "  ${GREEN}copilot${NC}   GitHub Copilot CLI\n"
    printf "  ${GREEN}aider${NC}     Aider AI pair programming\n"
    printf "  ${GREEN}gemini${NC}    Google Gemini CLI\n"
    printf "  ${GREEN}codeium${NC}   Codeium CLI\n"
    printf "  ${GREEN}cody${NC}      Sourcegraph Cody CLI\n"
    printf "  ${GREEN}continue${NC}  Continue.dev CLI (cn)\n"
    printf "  ${GREEN}augment${NC}   Augment CLI (auggie)\n"
    printf "  ${GREEN}opencode${NC}  OpenCode CLI\n"
    printf "  ${GREEN}kilo${NC}      Kilo Code CLI\n"
    printf "  ${GREEN}windsurf${NC}  Windsurf CLI\n"
    printf "  ${GREEN}roo${NC}       Roo CLI\n"
    printf "  ${GREEN}list${NC}      Show which agents are installed\n"
    printf "\n"
    printf "Examples:\n"
    printf "  %s claude\n" "$(basename "$0")"
    printf "  %s aider --model claude-3-5-sonnet\n" "$(basename "$0")"
    printf "  %s list\n" "$(basename "$0")"
}

if [[ $# -lt 1 ]]; then
    usage
    exit 1
fi

agent="$1"
shift

case "$agent" in
    codex)
        exec codex "$@"
        ;;
    claude)
        exec claude "$@"
        ;;
    copilot)
        exec gh copilot "$@"
        ;;
    aider)
        exec aider "$@"
        ;;
    gemini)
        exec gemini "$@"
        ;;
    codeium)
        exec codeium "$@"
        ;;
    cody)
        exec cody "$@"
        ;;
    continue|cn)
        exec cn "$@"
        ;;
    augment|auggie)
        exec auggie "$@"
        ;;
    opencode)
        exec opencode "$@"
        ;;
    kilo)
        exec kilo "$@"
        ;;
    windsurf)
        exec windsurf "$@"
        ;;
    roo)
        exec roo "$@"
        ;;
    list)
        printf "${CYAN}Installed AI Agents:${NC}\n"
        if type -P codex >/dev/null 2>&1; then printf "  ${GREEN}[ok]${NC} codex\n"; else printf "  ${YELLOW}[--]${NC} codex\n"; fi
        if type -P claude >/dev/null 2>&1; then printf "  ${GREEN}[ok]${NC} claude\n"; else printf "  ${YELLOW}[--]${NC} claude\n"; fi
        if type -P gh >/dev/null 2>&1; then printf "  ${GREEN}[ok]${NC} copilot (gh)\n"; else printf "  ${YELLOW}[--]${NC} copilot (gh)\n"; fi
        if type -P aider >/dev/null 2>&1; then printf "  ${GREEN}[ok]${NC} aider\n"; else printf "  ${YELLOW}[--]${NC} aider\n"; fi
        if type -P gemini >/dev/null 2>&1; then printf "  ${GREEN}[ok]${NC} gemini\n"; else printf "  ${YELLOW}[--]${NC} gemini\n"; fi
        if type -P codeium >/dev/null 2>&1; then printf "  ${GREEN}[ok]${NC} codeium\n"; else printf "  ${YELLOW}[--]${NC} codeium\n"; fi
        if type -P cody >/dev/null 2>&1; then printf "  ${GREEN}[ok]${NC} cody\n"; else printf "  ${YELLOW}[--]${NC} cody\n"; fi
        if type -P cn >/dev/null 2>&1; then printf "  ${GREEN}[ok]${NC} continue (cn)\n"; else printf "  ${YELLOW}[--]${NC} continue (cn)\n"; fi
        if type -P auggie >/dev/null 2>&1; then printf "  ${GREEN}[ok]${NC} augment (auggie)\n"; else printf "  ${YELLOW}[--]${NC} augment (auggie)\n"; fi
        if type -P opencode >/dev/null 2>&1; then printf "  ${GREEN}[ok]${NC} opencode\n"; else printf "  ${YELLOW}[--]${NC} opencode\n"; fi
        if type -P kilo >/dev/null 2>&1; then printf "  ${GREEN}[ok]${NC} kilo\n"; else printf "  ${YELLOW}[--]${NC} kilo\n"; fi
        ;;
    help|--help|-h)
        usage
        ;;
    *)
        printf "${RED}Unknown agent: %s${NC}\n" "$agent" >&2
        usage
        exit 2
        ;;
esac
