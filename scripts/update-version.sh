#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VERSION_FILE="$ROOT_DIR/VERSION.md"
DEFAULTS_FILE="$ROOT_DIR/nh-defaults.sh"

prompt() {
	local var value
	var="$1"
	shift
	read -rp "$* [${!var:-}]: " value
	echo "${value:-${!var}}"
}

CURRENT_VERSION=$(grep -oP 'NH_VERSION_CODE\s*=\s*"\K[^"]+' "$DEFAULTS_FILE" 2>/dev/null || echo "2.0.0")

echo "=== OmniSec version updater ==="
echo "Current version: $CURRENT_VERSION"

VERSION=$(prompt VERSION "New version")
BUILD=$(prompt BUILD "Build number")
DATE=$(date +%Y%m%d)

cat > "$VERSION_FILE" <<EOF
<!-- NH_SETUP_VERSION: ${VERSION} -->
<!-- Profile: Arch ARM64 v${VERSION}; Kali ARM64 v${VERSION} -->
<!-- Build: ${BUILD} -->
<!-- Date: ${DATE} -->
<!-- Device: OnePlus 7 Pro GM1911 -->
<!-- Android: 16 (API 36) -->
<!-- LineageOS: 23.2 -->

# OmniSec v${VERSION}

## Version Labels

- \`NH_VERSION\` = ${VERSION}
- \`NH_VERSION_CODE\` = ${BUILD}
- \`NH_VERSION_DATE\` = ${DATE}
- \`NH_PROFILE\` = default

## Device Configuration

- \`NH_DEVICE_NAME\` = "OnePlus 7 Pro GM1911"
- \`NH_ANDROID_VERSION\` = "16"
- \`NH_ANDROID_API\` = "36"
- \`NH_LINEAGE_VERSION\` = "23.2"
- \`NH_ARCH\` = "arm64"

## Chroot Profiles

| Chroot | Version | Arch | SSH Port |
|--------|---------|------|----------|
| Arch ARM64 | v${VERSION} | aarch64 | 2222 |
| Kali ARM64 | v${VERSION} | aarch64 | 22 |
| Termux | v${VERSION} | aarch64 | 8022 |
EOF

sed -i "s/NH_VERSION_CODE=\".*\"/NH_VERSION_CODE=\"${VERSION##v}\"/" "$DEFAULTS_FILE"
sed -i "s/NH_VERSION_BUILD=\".*\"/NH_VERSION_BUILD=\"${BUILD}\"/" "$DEFAULTS_FILE"
sed -i "s/NH_VERSION_DATE=\".*\"/NH_VERSION_DATE=\"${DATE}\"/" "$DEFAULTS_FILE"

echo "  updated: VERSION.md"
echo "  updated: nh-defaults.sh"
echo "  version: $VERSION (build $BUILD)"
