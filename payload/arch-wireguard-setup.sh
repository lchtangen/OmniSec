#!/bin/bash
# NH_SETUP_VERSION: 2.0 default
# Profile: Arch ARM64 v2.0 default; Kali ARM64 v2.0 default
# WireGuard setup helper — run inside Arch chroot to activate VPN
# Usage: arch-wireguard-setup.sh [config-file]
# If no config file given, shows the template and instructions.
set -euo pipefail

TEMPLATE=/etc/wireguard/wg0.conf.template
CONFIG=/etc/wireguard/wg0.conf

if [ ! -f "$TEMPLATE" ]; then
  echo "Error: $TEMPLATE not found. Run arch-specialization.sh first." >&2
  exit 1
fi

if [ -f "$CONFIG" ]; then
  echo "WireGuard config already exists: $CONFIG"
  wg show wg0 2>/dev/null && echo "wg0 is UP" || echo "wg0 is DOWN — run: wg-quick up wg0"
  exit 0
fi

if [ -n "${1:-}" ] && [ -f "$1" ]; then
  echo "Installing WireGuard config from $1"
  cp "$1" "$CONFIG"
  chmod 600 "$CONFIG"
  echo "Done. Bring up the tunnel with: wg-quick up wg0"
  exit 0
fi

echo ""
echo "══ WireGuard Setup ══════════════════════════════════"
echo ""
echo "No wg0.conf found. Steps to activate:"
echo ""
echo "1. Generate a keypair on this device:"
echo "     wg genkey | tee /etc/wireguard/private.key | wg pubkey > /etc/wireguard/public.key"
echo "     chmod 600 /etc/wireguard/private.key"
echo ""
echo "2. Copy the template and fill in your server details:"
echo "     cp $TEMPLATE $CONFIG"
echo "     nano $CONFIG"
echo "     chmod 600 $CONFIG"
echo ""
echo "3. Bring the tunnel up:"
echo "     wg-quick up wg0"
echo ""
echo "4. Verify:"
echo "     arch-privacy-check"
echo ""
echo "Template contents:"
echo "──────────────────"
cat "$TEMPLATE"
echo "══════════════════════════════════════════════════════"
