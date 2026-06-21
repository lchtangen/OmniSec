#!/usr/bin/env bash
set -euo pipefail

ROOT="/home/arch/projects/multi-platform"
cd "$ROOT"

ERRORS=0
WARNINGS=0

echo "== Workspace Structure Validation =="

declare -a required_dirs=(
  "repos/desktop/linux"
  "repos/mobile/android"
  "repos/web"
  "repos/embedded"
  "repos/reference"
  "docs"
  ".audit-reports/docs"
  ".audit-reports/data"
)

echo "[1/4] Checking required directories..."
for d in "${required_dirs[@]}"; do
  if [[ -d "$d" ]]; then
    echo "  OK: $d"
  else
    echo "  FAIL: Missing required directory: $d"
    ERRORS=$((ERRORS + 1))
  fi
done

echo "[2/4] Checking uppercase markdown filenames..."
while IFS= read -r -d '' file; do
  base="$(basename "$file")"
  name="${base%.md}"
  upper="$(printf '%s' "$name" | tr '[:lower:]' '[:upper:]')"
  if [[ "$name" != "$upper" ]]; then
    echo "  FAIL: Non-uppercase markdown filename: $file"
    ERRORS=$((ERRORS + 1))
  fi
done < <(find docs .audit-reports/docs .audit-reports/data -type f -name '*.md' -print0 2>/dev/null)

echo "[3/4] Checking managed kebab-case repo names..."
declare -a managed_repo_paths=(
  "repos/desktop/linux/omnisec"
  "repos/desktop/linux/cyberflash-tool"
  "repos/desktop/linux/linux-omnisec"
  "repos/desktop/linux/kali-workspace"
  "repos/mobile/android/op7p-env"
  "repos/mobile/android/vault-android16"
)

for p in "${managed_repo_paths[@]}"; do
  if [[ ! -d "$p" ]]; then
    echo "  WARN: Managed path not found: $p"
    WARNINGS=$((WARNINGS + 1))
    continue
  fi
  leaf="$(basename "$p")"
  if [[ ! "$leaf" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
    echo "  FAIL: Non-kebab-case managed repo: $p"
    ERRORS=$((ERRORS + 1))
  fi
done

echo "[4/4] Checking broken markdown links..."
while IFS= read -r -d '' mdfile; do
  md_dir="$(dirname "$mdfile")"
  while IFS= read -r target; do
    target="${target%%#*}"
    [[ -z "$target" ]] && continue
    case "$target" in
      http://*|https://*|mailto:*|\#*)
        continue
        ;;
    esac

    if [[ "$target" == /* ]]; then
      resolved="$ROOT$target"
    else
      resolved="$(realpath -m "$md_dir/$target")"
    fi

    if [[ ! -e "$resolved" ]]; then
      echo "  FAIL: Broken link in $mdfile -> $target"
      ERRORS=$((ERRORS + 1))
    fi
  done < <(grep -oE '\[[^]]+\]\(([^)]+)\)' "$mdfile" | sed -E 's/.*\(([^)]+)\).*/\1/' || true)
done < <(find docs .audit-reports -type f -name '*.md' -print0)

echo ""
echo "Validation summary: errors=$ERRORS warnings=$WARNINGS"

if [[ "$ERRORS" -gt 0 ]]; then
  exit 1
fi

exit 0
