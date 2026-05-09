#!/usr/bin/env bash
set -euo pipefail
GPG_KEY="${GPG_KEY:-security@omnisec.io}"
if [ $# -lt 1 ]; then
    echo "Usage: $0 <file-to-sign> [output-dir]"
    exit 1
fi
FILE="$1"
OUTDIR="${2:-./dist/signed}"
mkdir -p "$OUTDIR"
echo "[*] Signing $FILE with key $GPG_KEY..."
gpg --detach-sign --armor --default-key "$GPG_KEY" -o "$OUTDIR/$(basename $FILE).asc" "$FILE"
gpg --verify "$OUTDIR/$(basename $FILE).asc" "$FILE"
sha256sum "$FILE" > "$OUTDIR/$(basename $FILE).sha256"
echo "[+] Signed: $OUTDIR/$(basename $FILE).asc"
