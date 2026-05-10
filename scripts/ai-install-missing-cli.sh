#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MODE="plan"

if [[ "${1:-}" == "--apply" ]]; then
    MODE="apply"
elif [[ "${1:-}" == "--plan" || -z "${1:-}" ]]; then
    MODE="plan"
else
    printf 'Usage: %s [--plan|--apply]\n' "$(basename "$0")" >&2
    exit 1
fi

have_cmd() {
    type -P "$1" >/dev/null 2>&1
}

detect_pm() {
    if have_cmd pacman; then
        printf 'pacman'
        return
    fi
    if have_cmd apt; then
        printf 'apt'
        return
    fi
    if have_cmd brew; then
        printf 'brew'
        return
    fi
    printf 'unknown'
}

run_or_print() {
    local cmd="$1"
    if [[ "$MODE" == "apply" ]]; then
        printf '[run] %s\n' "$cmd"
        eval "$cmd"
    else
        printf '[plan] %s\n' "$cmd"
    fi
}

install_npm_global() {
    local pkg="$1"
    run_or_print "npm install -g --prefix \"$HOME/.local\" $pkg"
}

install_with_pm() {
    local pm="$1"
    local pkg="$2"
    case "$pm" in
        pacman)
            run_or_print "sudo pacman -S --needed $pkg"
            ;;
        apt)
            run_or_print "sudo apt update && sudo apt install -y $pkg"
            ;;
        brew)
            run_or_print "brew install $pkg"
            ;;
        *)
            printf '[skip] package manager unknown for %s\n' "$pkg"
            ;;
    esac
}

printf '== OmniSec AI CLI Installer ==\n'
printf 'root: %s\n' "$ROOT_DIR"
printf 'mode: %s\n' "$MODE"

pm="$(detect_pm)"
printf 'package-manager: %s\n' "$pm"

if ! have_cmd npm; then
    printf '[warn] npm not found; npm-based installs will be skipped\n'
fi
if ! have_cmd pipx; then
    printf '[warn] pipx not found; aider install can be skipped or use pip\n'
fi

printf '\n-- Checking tools --\n'

# GitHub CLI
if have_cmd gh; then
    printf '[ok] gh already installed (%s)\n' "$(type -P gh)"
else
    printf '[missing] gh\n'
    install_with_pm "$pm" github-cli
fi

# Codex CLI
if have_cmd codex; then
    printf '[ok] codex already installed (%s)\n' "$(type -P codex)"
else
    printf '[missing] codex\n'
    if have_cmd npm; then
        install_npm_global "@openai/codex"
    else
        printf '[skip] npm not available for codex\n'
    fi
fi

# Claude CLI
if have_cmd claude; then
    printf '[ok] claude already installed (%s)\n' "$(type -P claude)"
else
    printf '[missing] claude\n'
    if have_cmd npm; then
        install_npm_global "@anthropic-ai/claude-code"
    else
        printf '[skip] npm not available for claude\n'
    fi
fi

# Continue CLI (cn)
if have_cmd cn; then
    printf '[ok] cn already installed (%s)\n' "$(type -P cn)"
else
    printf '[missing] cn\n'
    if have_cmd npm; then
        install_npm_global "@continuedev/cli"
    else
        printf '[skip] npm not available for cn\n'
    fi
fi

# Augment CLI (auggie)
if have_cmd auggie; then
    printf '[ok] auggie already installed (%s)\n' "$(type -P auggie)"
else
    printf '[missing] auggie\n'
    if have_cmd npm; then
        install_npm_global "@augmentcode/auggie"
    else
        printf '[skip] npm not available for auggie\n'
    fi
fi

# OpenCode CLI
if have_cmd opencode; then
    printf '[ok] opencode already installed (%s)\n' "$(type -P opencode)"
else
    printf '[missing] opencode\n'
    if have_cmd npm; then
        install_npm_global "@opencode/cli"
    else
        printf '[skip] npm not available for opencode\n'
    fi
fi

# Aider
if have_cmd aider; then
    printf '[ok] aider already installed (%s)\n' "$(type -P aider)"
else
    printf '[missing] aider\n'
    if have_cmd pipx; then
        run_or_print "pipx install aider-chat"
    else
        printf '[skip] pipx not available for aider\n'
    fi
fi

printf '\n-- Manual installs (official docs recommended) --\n'
for tool in gemini codeium cody windsurf; do
    if have_cmd "$tool"; then
        printf '[ok] %s already installed (%s)\n' "$tool" "$(type -P "$tool")"
    else
        printf '[manual] %s is missing; install from official vendor docs\n' "$tool"
    fi
done

printf '\n-- Post install verification --\n'
printf '[next] %s\n' "./scripts/ai-cli-doctor.sh"
printf '[next] %s\n' "./scripts/ai-missing-cli-help.sh"
printf 'ai-install-missing-cli: completed\n'
