#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
FULL=0
WITH_DEVICE=0

for arg in "$@"; do
    case "${arg}" in
        --full)
            FULL=1
            ;;
        --with-device)
            WITH_DEVICE=1
            ;;
        *)
            printf 'Usage: %s [--full] [--with-device]\n' "$(basename "$0")" >&2
            exit 1
            ;;
    esac
done

printf '== OmniSec AI Daily Ops ==\n'
printf 'root: %s\n' "${ROOT_DIR}"

printf '\n[1/7] rename audit\n'
"${ROOT_DIR}/scripts/pre-rename-audit.sh"

printf '\n[2/7] repo doctor\n'
"${ROOT_DIR}/repo-doctor.sh"

printf '\n[3/7] cli doctor\n'
"${ROOT_DIR}/scripts/ai-cli-doctor.sh"

printf '\n[4/7] prompt lint\n'
"${ROOT_DIR}/scripts/ai-prompt-lint.sh"

printf '\n[5/7] agent lint\n'
"${ROOT_DIR}/scripts/ai-agent-lint.sh"

printf '\n[6/7] context snapshot\n'
"${ROOT_DIR}/scripts/ai-context-snapshot.sh"

if [[ "${WITH_DEVICE}" -eq 1 ]]; then
    printf '\n[7/7] device ai status\n'
    "${ROOT_DIR}/nhctl" ai status
else
    printf '\n[7/7] device ai status skipped (use --with-device)\n'
fi

if [[ "${FULL}" -eq 1 ]]; then
    printf '\n-- full quality gates --\n'
    make -C "${ROOT_DIR}" lint
    make -C "${ROOT_DIR}" test
fi

printf 'ai-daily-ops: OK\n'
