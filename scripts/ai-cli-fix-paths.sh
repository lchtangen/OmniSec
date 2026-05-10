#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

LOCAL_BIN="${HOME}/.local/bin"
mkdir -p "${LOCAL_BIN}"

printf "${CYAN}== OmniSec AI CLI Path + Sudo Fix ==${NC}\n"
printf "local-bin: %s\n" "${LOCAL_BIN}"

if [[ ":${PATH}:" != *":${LOCAL_BIN}:"* ]]; then
    export PATH="${LOCAL_BIN}:${PATH}"
    printf "${YELLOW}[warn]${NC} %s was not in PATH; exported for current shell\n" "${LOCAL_BIN}"
fi

fix_exec() {
    local bin="$1"
    if [[ -x "${bin}" ]]; then
        chmod u+rwx,go+rx "${bin}" 2>/dev/null || true
    fi
}

link_local_alias() {
    local src="$1"
    local alias_name="$2"
    if [[ -x "${src}" ]]; then
        ln -sfn "${src}" "${LOCAL_BIN}/${alias_name}"
        printf "${GREEN}[ok]${NC} local alias %s -> %s\n" "${alias_name}" "${src}"
    fi
}

CN_PATH="$(command -v cn 2>/dev/null || true)"
AUGGIE_PATH="$(command -v auggie 2>/dev/null || true)"
CODEX_PATH="$(command -v codex 2>/dev/null || true)"
CLAUDE_PATH="$(command -v claude 2>/dev/null || true)"
OPENCODE_PATH="$(command -v opencode 2>/dev/null || true)"

for p in "${CN_PATH}" "${AUGGIE_PATH}" "${CODEX_PATH}" "${CLAUDE_PATH}" "${OPENCODE_PATH}"; do
    [[ -n "${p}" ]] && fix_exec "${p}"
done

if [[ -n "${AUGGIE_PATH}" ]]; then
    link_local_alias "${AUGGIE_PATH}" "augment"
fi
if [[ -n "${CN_PATH}" ]]; then
    link_local_alias "${CN_PATH}" "continue-cli"
fi

have_sudo=0
if command -v sudo >/dev/null 2>&1 && sudo -n true >/dev/null 2>&1; then
    have_sudo=1
fi

sudo_link() {
    local src="$1"
    local name="$2"
    sudo ln -sfn "${src}" "/usr/local/bin/${name}"
    sudo chmod 755 "${src}" 2>/dev/null || true
    printf "${GREEN}[ok]${NC} sudo link /usr/local/bin/%s -> %s\n" "${name}" "${src}"
}

if [[ "${have_sudo}" -eq 1 ]]; then
    [[ -n "${CN_PATH}" ]] && sudo_link "${CN_PATH}" "cn"
    [[ -n "${CN_PATH}" ]] && sudo_link "${CN_PATH}" "continue-cli"
    [[ -n "${AUGGIE_PATH}" ]] && sudo_link "${AUGGIE_PATH}" "auggie"
    [[ -n "${AUGGIE_PATH}" ]] && sudo_link "${AUGGIE_PATH}" "augment"
    [[ -n "${CODEX_PATH}" ]] && sudo_link "${CODEX_PATH}" "codex"
    [[ -n "${CLAUDE_PATH}" ]] && sudo_link "${CLAUDE_PATH}" "claude"
    [[ -n "${OPENCODE_PATH}" ]] && sudo_link "${OPENCODE_PATH}" "opencode"
else
    printf "${YELLOW}[warn]${NC} sudo non-interactive access unavailable; skipping /usr/local/bin links\n"
    printf "       run manually if needed: sudo %s\n" "$0"
fi

printf "\n${CYAN}Resolved commands:${NC}\n"
for cmd in codex claude gh cn auggie augment continue-cli opencode; do
    if command -v "${cmd}" >/dev/null 2>&1; then
        printf "  ${GREEN}[ok]${NC} %-12s %s\n" "${cmd}" "$(command -v "${cmd}")"
    else
        printf "  ${RED}[--]${NC} %-12s not found\n" "${cmd}"
    fi
done

printf "\n${GREEN}ai-cli-fix-paths: completed${NC}\n"
