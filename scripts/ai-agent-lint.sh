#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
AGENT_DIR="${ROOT_DIR}/.github/agents"

printf '== OmniSec AI Agent Lint ==\n'
printf 'root: %s\n' "${ROOT_DIR}"

if [[ ! -d "${AGENT_DIR}" ]]; then
    printf '[warn] no agent directory found: %s\n' "${AGENT_DIR}"
    printf 'ai-agent-lint: OK (nothing to lint)\n'
    exit 0
fi

failures=0
total=0

shopt -s nullglob
agent_files=("${AGENT_DIR}"/*.agent.md)
shopt -u nullglob

if [[ ${#agent_files[@]} -eq 0 ]]; then
    printf '[warn] no *.agent.md files found in %s\n' "${AGENT_DIR}"
    printf 'ai-agent-lint: OK (nothing to lint)\n'
    exit 0
fi

for file in "${agent_files[@]}"; do
    total=$((total + 1))
    rel_path="${file#"$ROOT_DIR"/}"

    first_line="$(sed -n '1p' "${file}")"
    if [[ "${first_line}" == "---" ]]; then
        fm_end="$(awk 'NR > 1 && $0 == "---" { print NR; exit }' "${file}")"
        if [[ -z "${fm_end}" ]]; then
            printf '[fail] %s: missing frontmatter end\n' "${rel_path}" >&2
            failures=$((failures + 1))
            continue
        fi

        frontmatter="$(sed -n "1,${fm_end}p" "${file}")"

        if ! printf '%s\n' "${frontmatter}" | grep -Eq '^name:[[:space:]]*.+$'; then
            printf '[fail] %s: missing name field in frontmatter\n' "${rel_path}" >&2
            failures=$((failures + 1))
            continue
        fi

        if ! printf '%s\n' "${frontmatter}" | grep -Eq '^description:[[:space:]]*.+$'; then
            printf '[fail] %s: missing description field in frontmatter\n' "${rel_path}" >&2
            failures=$((failures + 1))
            continue
        fi

        printf '[ok] %s (frontmatter)\n' "${rel_path}"
        continue
    fi

    # Also accept markdown-profile agents with required sections.
    if ! grep -Eq '^#[[:space:]].+' "${file}"; then
        printf '[fail] %s: missing title heading\n' "${rel_path}" >&2
        failures=$((failures + 1))
        continue
    fi

    if ! grep -Eq '^##[[:space:]]+Responsibility' "${file}"; then
        printf '[fail] %s: missing Responsibility section\n' "${rel_path}" >&2
        failures=$((failures + 1))
        continue
    fi

    if ! grep -Eq '^##[[:space:]]+Invocation' "${file}"; then
        printf '[fail] %s: missing Invocation section\n' "${rel_path}" >&2
        failures=$((failures + 1))
        continue
    fi

    printf '[ok] %s (markdown-profile)\n' "${rel_path}"
done

printf 'agents: %d\n' "${total}"
printf 'failures: %d\n' "${failures}"

if [[ "${failures}" -gt 0 ]]; then
    printf 'ai-agent-lint: FAILED\n' >&2
    exit 1
fi

printf 'ai-agent-lint: OK\n'
