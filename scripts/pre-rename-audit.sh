#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MAP_FILE="${ROOT_DIR}/refactor/rename-map.tsv"

if [[ ! -f "${MAP_FILE}" ]]; then
    echo "error: rename map not found: ${MAP_FILE}" >&2
    exit 1
fi

echo "== Rename Audit =="
echo "root: ${ROOT_DIR}"
echo "map:  ${MAP_FILE}"

declare -i total=0
declare -i failures=0

echo ""
echo "-- Path checks --"
while IFS=$'\t' read -r old_path new_path map_status _reason; do
    [[ -z "${old_path:-}" || "${old_path}" =~ ^# ]] && continue
    total+=1

    case "${map_status:-planned}" in
        planned)
            if [[ -e "${ROOT_DIR}/${old_path}" ]]; then
                echo "[ok] planned old exists: ${old_path}"
            else
                echo "[fail] planned old missing: ${old_path}"
                failures+=1
            fi

            if [[ -e "${ROOT_DIR}/${new_path}" ]]; then
                echo "[fail] planned new already exists: ${new_path}"
                failures+=1
            else
                echo "[ok] planned new available: ${new_path}"
            fi
            ;;
        migrated)
            if [[ -e "${ROOT_DIR}/${new_path}" ]]; then
                echo "[ok] migrated new exists: ${new_path}"
            else
                echo "[fail] migrated new missing: ${new_path}"
                failures+=1
            fi

            if [[ -L "${ROOT_DIR}/${old_path}" ]]; then
                echo "[ok] compat symlink: ${old_path} -> $(readlink "${ROOT_DIR}/${old_path}")"
            elif [[ -e "${ROOT_DIR}/${old_path}" ]]; then
                echo "[warn] old path still exists as non-symlink: ${old_path}"
            else
                echo "[warn] no compat symlink present: ${old_path}"
            fi
            ;;
        done)
            if [[ -e "${ROOT_DIR}/${new_path}" ]]; then
                echo "[ok] done new exists: ${new_path}"
            else
                echo "[fail] done new missing: ${new_path}"
                failures+=1
            fi

            if [[ -e "${ROOT_DIR}/${old_path}" ]]; then
                echo "[fail] done old path still present: ${old_path}"
                failures+=1
            else
                echo "[ok] done old removed: ${old_path}"
            fi
            ;;
        *)
            echo "[fail] unknown map status '${map_status}' for ${old_path}"
            failures+=1
            ;;
    esac
done < "${MAP_FILE}"

echo ""
echo "-- Reference scan (text) --"
while IFS=$'\t' read -r old_path new_path _status _reason; do
    [[ -z "${old_path:-}" || "${old_path}" =~ ^# ]] && continue
    hits=$(rg -n --hidden --glob '!.git' --glob '!node_modules/**' --glob '!build/**' --glob '!dist/**' --glob '!payload/**' --glob '!**/*.zst' --glob '!**/*.xz' --glob '!**/*.tar.*' "${old_path}" "${ROOT_DIR}" | wc -l | tr -d ' ')
    echo "[refs] ${old_path} -> ${hits}"
done < "${MAP_FILE}"

echo ""
echo "-- Summary --"
echo "entries: ${total}"
echo "failures: ${failures}"

if (( failures > 0 )); then
    echo "rename-audit: FAIL"
    exit 2
fi

echo "rename-audit: OK"
