# Device profile loader
# Usage: . devices/loader.sh [codename]
# If codename is omitted, tries auto-detection via ADB, then falls back to guacamole

NH_DEVICES_DIR="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd)"

nh_load_profile() {
    local codename="${1:-}"
    local profile_path=""

    if [ -n "$codename" ]; then
        profile_path="$NH_DEVICES_DIR/$codename.sh"
        if [ -f "$profile_path" ]; then
            . "$profile_path"
            return 0
        fi
        return 1
    fi

    # Try auto-detection from device
    if command -v adb >/dev/null 2>&1; then
        local detected
        detected=$(adb shell getprop ro.product.board 2>/dev/null | tr -d '\r\n' || echo "")
        [ -z "$detected" ] && detected=$(adb shell getprop ro.build.product 2>/dev/null | tr -d '\r\n' || echo "")
        if [ -n "$detected" ]; then
            profile_path="$NH_DEVICES_DIR/$detected.sh"
            [ -f "$profile_path" ] && { . "$profile_path"; return 0; }
        fi
    fi

    # Fallback to default (guacamole)
    profile_path="$NH_DEVICES_DIR/guacamole.sh"
    [ -f "$profile_path" ] && { . "$profile_path"; return 0; }

    return 1
}

nh_list_profiles() {
    for f in "$NH_DEVICES_DIR"/*.sh; do
        [ "$(basename "$f")" = "loader.sh" ] && continue
        echo "$(basename "$f" .sh)"
    done
}

nh_load_profile "$@"
