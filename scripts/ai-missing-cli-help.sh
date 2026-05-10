#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

printf '== OmniSec Missing AI CLI Helper ==\n'
printf 'root: %s\n' "${ROOT_DIR}"
printf 'installer: %s\n' "./scripts/ai-install-missing-cli.sh --plan"

missing=0

detect_pm() {
    if command -v pacman >/dev/null 2>&1; then
        printf 'pacman'
        return
    fi
    if command -v apt >/dev/null 2>&1; then
        printf 'apt'
        return
    fi
    if command -v brew >/dev/null 2>&1; then
        printf 'brew'
        return
    fi
    printf 'unknown'
}

print_hint() {
    local tool="$1"
    local pm="$2"

    case "${tool}" in
        codex)
            printf '  hint: install from OpenAI Codex CLI release/docs\n'
            ;;
        claude)
            printf '  hint: install Claude Code via official installer/docs\n'
            ;;
        gh)
            case "${pm}" in
                pacman) printf '  hint: sudo pacman -S github-cli\n' ;;
                apt) printf '  hint: sudo apt install gh\n' ;;
                brew) printf '  hint: brew install gh\n' ;;
                *) printf '  hint: install GitHub CLI from https://cli.github.com/\n' ;;
            esac
            ;;
        aider)
            printf '  hint: pipx install aider-chat\n'
            ;;
        gemini)
            printf '  hint: install Gemini CLI from official Google Gemini tooling docs\n'
            ;;
        codeium)
            printf '  hint: install Codeium CLI from official Codeium docs\n'
            ;;
        cody)
            printf '  hint: install Cody CLI from Sourcegraph docs\n'
            ;;
        cn)
            printf '  hint: npm install -g --prefix "$HOME/.local" @continuedev/cli\n'
            ;;
        auggie)
            printf '  hint: npm install -g --prefix "$HOME/.local" @augmentcode/auggie\n'
            ;;
        opencode)
            printf '  hint: install OpenCode CLI from official OpenCode docs\n'
            ;;
        *)
            printf '  hint: check official docs for %s\n' "${tool}"
            ;;
    esac
}

pm="$(detect_pm)"
printf 'package-manager: %s\n' "${pm}"

for tool in codex claude gh aider gemini codeium cody cn auggie opencode; do
    if type -P "${tool}" >/dev/null 2>&1; then
        printf '[ok] %s -> %s\n' "${tool}" "$(type -P "${tool}")"
    else
        printf '[missing] %s\n' "${tool}"
        print_hint "${tool}" "${pm}"
        missing=$((missing + 1))
    fi
done

printf '\n[aliases]\n'
printf '  continue -> cn\n'
printf '  augment  -> auggie\n'

printf 'missing-tools: %d\n' "${missing}"
printf 'ai-missing-cli-help: completed\n'
