#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROMPT_DIR="${ROOT_DIR}/.github/prompts"

printf '== OmniSec AI Prompt Lint ==\n'
printf 'root: %s\n' "${ROOT_DIR}"

if [[ ! -d "${PROMPT_DIR}" ]]; then
    printf '[fail] missing prompt directory: %s\n' "${PROMPT_DIR}" >&2
    exit 1
fi

failures=0
total=0

shopt -s nullglob
prompt_files=("${PROMPT_DIR}"/*.prompt.md)
shopt -u nullglob

if [[ ${#prompt_files[@]} -eq 0 ]]; then
    printf '[fail] no prompt templates found (*.prompt.md)\n' >&2
    exit 1
fi

for file in "${prompt_files[@]}"; do
    total=$((total + 1))
    rel_path="${file#"$ROOT_DIR"/}"

    first_line="$(sed -n '1p' "${file}")"
    if [[ "${first_line}" != "---" ]]; then
        printf '[fail] %s: missing frontmatter start\n' "${rel_path}" >&2
        failures=$((failures + 1))
        continue
    fi

    fm_end="$(awk 'NR > 1 && $0 == "---" { print NR; exit }' "${file}")"
    if [[ -z "${fm_end}" ]]; then
        printf '[fail] %s: missing frontmatter end\n' "${rel_path}" >&2
        failures=$((failures + 1))
        continue
    fi

    frontmatter="$(sed -n "1,${fm_end}p" "${file}")"
    if ! printf '%s\n' "${frontmatter}" | grep -Eq '^agent:[[:space:]]*"?.+"?$'; then
        printf '[fail] %s: missing agent field in frontmatter\n' "${rel_path}" >&2
        failures=$((failures + 1))
        continue
    fi

    if ! printf '%s\n' "${frontmatter}" | grep -Eq '^description:[[:space:]]*"?.+"?$'; then
        printf '[fail] %s: missing description field in frontmatter\n' "${rel_path}" >&2
        failures=$((failures + 1))
        continue
    fi

    printf '[ok] %s\n' "${rel_path}"
done

printf 'templates: %d\n' "${total}"
printf 'failures: %d\n' "${failures}"

if [[ "${failures}" -gt 0 ]]; then
    printf 'ai-prompt-lint: FAILED\n' >&2
    exit 1
fi

printf 'ai-prompt-lint: OK\n'
