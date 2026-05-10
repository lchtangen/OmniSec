#!/usr/bin/env bash
# OpenVPN server + first client profile, Arch host.
# Idempotent. Generates PKI via easy-rsa, writes systemd-compatible config,
# enables NAT/forwarding, starts openvpn-server@server.service, and emits
# an inline .ovpn the client can import.
# Usage: scripts/setup-openvpn.sh [--plan|--apply] [--client NAME] [--remote HOST]
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MODE="plan"
CLIENT_NAME="phone"
OVPN_REMOTE=""        # public hostname/IP clients dial; required for --apply
OVPN_PORT="1194"
OVPN_PROTO="udp"
OVPN_NET="10.8.0.0"
OVPN_MASK="255.255.255.0"
OVPN_CIDR="10.8.0.0/24"
WAN_IF="$(ip route show default 2>/dev/null | awk '/default/ {print $5; exit}')"
PKI_DIR="/etc/easy-rsa"
SRV_CONF="/etc/openvpn/server/server.conf"
OUT_DIR="$ROOT_DIR/openvpn-clients"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --plan)   MODE="plan"; shift ;;
        --apply)  MODE="apply"; shift ;;
        --client) CLIENT_NAME="$2"; shift 2 ;;
        --remote) OVPN_REMOTE="$2"; shift 2 ;;
        -h|--help) sed -n '2,6p' "$0"; exit 0 ;;
        *) echo "unknown arg: $1" >&2; exit 2 ;;
    esac
done

have_cmd() { type -P "$1" >/dev/null 2>&1; }
log()  { printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*"; }
step() { printf '\n\033[1;36m== %s ==\033[0m\n' "$*"; }
run() {
    if [[ "$MODE" == "apply" ]]; then printf '  $ %s\n' "$*"; eval "$*"
    else printf '  [plan] %s\n' "$*"; fi
}
need_sudo() {
    sudo -n true 2>/dev/null || {
        echo "sudo (NOPASSWD) required. Fix /etc/sudoers.d/$USER first." >&2
        exit 1
    }
}

[[ $EUID -eq 0 ]] && { echo "do not run as root; script invokes sudo itself" >&2; exit 1; }
[[ -f /etc/arch-release ]] || { echo "Arch-only" >&2; exit 1; }
[[ -z "$WAN_IF" ]] && { echo "could not detect WAN interface (ip route show default)" >&2; exit 1; }

if [[ "$MODE" == "apply" ]]; then
    [[ -z "$OVPN_REMOTE" ]] && { echo "--remote <host_or_ip> required in --apply mode" >&2; exit 2; }
    need_sudo
fi

step "mode=$MODE client=$CLIENT_NAME remote=${OVPN_REMOTE:-<unset>} wan=$WAN_IF net=$OVPN_CIDR"

# ── 1. ensure packages ──────────────────────────────────────────────────────
step "1/9 packages (openvpn, easy-rsa)"
NEEDED=()
have_cmd openvpn  || NEEDED+=(openvpn)
have_cmd easyrsa  || NEEDED+=(easy-rsa)
if ((${#NEEDED[@]})); then
    run "sudo pacman -Sy --needed --noconfirm ${NEEDED[*]}"
else log "have openvpn + easy-rsa"; fi

# ── 2. PKI: CA, server cert, client cert, dh, tls-crypt key ────────────────
step "2/9 PKI ($PKI_DIR)"
if [[ "$MODE" == "apply" ]]; then
    if [[ ! -d "$PKI_DIR/pki" ]]; then
        sudo install -d -m 0755 -o root -g root "$PKI_DIR"
        sudo cp -rT /usr/share/easy-rsa "$PKI_DIR"
        sudo sh -c "cd '$PKI_DIR' && ./easyrsa init-pki"
        sudo sh -c "cd '$PKI_DIR' && EASYRSA_BATCH=1 EASYRSA_REQ_CN='OmniSec-CA' ./easyrsa build-ca nopass"
        sudo sh -c "cd '$PKI_DIR' && EASYRSA_BATCH=1 ./easyrsa gen-dh"
        sudo sh -c "cd '$PKI_DIR' && EASYRSA_BATCH=1 ./easyrsa build-server-full server nopass"
        sudo openvpn --genkey secret "$PKI_DIR/pki/ta.key"
        sudo chmod 0600 "$PKI_DIR/pki/ta.key"
        log "PKI initialized"
    else log "PKI already present at $PKI_DIR/pki"; fi
    if ! sudo test -f "$PKI_DIR/pki/issued/$CLIENT_NAME.crt"; then
        sudo sh -c "cd '$PKI_DIR' && EASYRSA_BATCH=1 ./easyrsa build-client-full '$CLIENT_NAME' nopass"
    else log "client $CLIENT_NAME cert exists"; fi
else
    log "[plan] init PKI, build CA, dh, server cert, ta.key, client cert ($CLIENT_NAME)"
fi

# ── 3. server config ────────────────────────────────────────────────────────
step "3/9 server config $SRV_CONF"
SRV_BODY=$(cat <<EOF
port $OVPN_PORT
proto $OVPN_PROTO
dev tun
ca   $PKI_DIR/pki/ca.crt
cert $PKI_DIR/pki/issued/server.crt
key  $PKI_DIR/pki/private/server.key
dh   $PKI_DIR/pki/dh.pem
tls-crypt $PKI_DIR/pki/ta.key
topology subnet
server $OVPN_NET $OVPN_MASK
ifconfig-pool-persist /var/log/openvpn/ipp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 1.1.1.1"
push "dhcp-option DNS 9.9.9.9"
keepalive 10 120
data-ciphers AES-256-GCM:AES-128-GCM:CHACHA20-POLY1305
auth SHA256
user nobody
group nobody
persist-key
persist-tun
status /var/log/openvpn/status.log
log-append /var/log/openvpn/openvpn.log
verb 3
explicit-exit-notify 1
EOF
)
if [[ "$MODE" == "apply" ]]; then
    sudo install -d -m 0755 /var/log/openvpn /etc/openvpn/server
    printf '%s\n' "$SRV_BODY" | sudo install -m 0640 -o root -g root /dev/stdin "$SRV_CONF"
    log "wrote $SRV_CONF"
else log "[plan] write $SRV_CONF (port $OVPN_PORT/$OVPN_PROTO, subnet $OVPN_CIDR)"; fi


# ── 4. ip_forward (persistent) ──────────────────────────────────────────────
step "4/9 sysctl ip_forward"
SCTL=/etc/sysctl.d/99-openvpn.conf
if [[ "$MODE" == "apply" ]]; then
    printf 'net.ipv4.ip_forward = 1\n' | sudo install -m 0644 -o root -g root /dev/stdin "$SCTL"
    sudo sysctl -p "$SCTL" >/dev/null
    log "ip_forward=1 (persistent via $SCTL)"
else log "[plan] write $SCTL with net.ipv4.ip_forward=1"; fi

# ── 5. NAT + forwarding via nftables (persistent) ───────────────────────────
step "5/9 nftables NAT (out via $WAN_IF)"
NFT=/etc/nftables.conf
NFT_BODY=$(cat <<EOF
#!/usr/bin/nft -f
flush ruleset
table inet filter {
    chain input {
        type filter hook input priority filter; policy accept;
        iif "lo" accept
        ct state established,related accept
        udp dport $OVPN_PORT accept comment "openvpn"
    }
    chain forward {
        type filter hook forward priority filter; policy accept;
        ip saddr $OVPN_CIDR accept
        ip daddr $OVPN_CIDR ct state established,related accept
    }
    chain output { type filter hook output priority filter; policy accept; }
}
table ip nat {
    chain postrouting {
        type nat hook postrouting priority srcnat; policy accept;
        ip saddr $OVPN_CIDR oifname "$WAN_IF" masquerade
    }
}
EOF
)
if [[ "$MODE" == "apply" ]]; then
    printf '%s\n' "$NFT_BODY" | sudo install -m 0755 -o root -g root /dev/stdin "$NFT"
    sudo nft -f "$NFT"
    sudo systemctl enable --now nftables.service
    log "nftables loaded + enabled"
else log "[plan] write $NFT (allow udp/$OVPN_PORT, NAT $OVPN_CIDR -> $WAN_IF) and enable nftables.service"; fi

# ── 6. tun module + service ─────────────────────────────────────────────────
step "6/9 service openvpn-server@server"
if [[ "$MODE" == "apply" ]]; then
    sudo modprobe tun || true
    printf 'tun\n' | sudo install -m 0644 -o root -g root /dev/stdin /etc/modules-load.d/tun.conf
    sudo systemctl enable --now openvpn-server@server.service
    sleep 1
else log "[plan] modprobe tun, persist via /etc/modules-load.d/tun.conf, enable openvpn-server@server"; fi


# ── 7. emit inline .ovpn for $CLIENT_NAME ──────────────────────────────────
step "7/9 client profile -> $OUT_DIR/$CLIENT_NAME.ovpn"
mkdir -p "$OUT_DIR"; chmod 0700 "$OUT_DIR"
if [[ "$MODE" == "apply" ]]; then
    CA=$(sudo cat "$PKI_DIR/pki/ca.crt")
    CRT=$(sudo openssl x509 -in "$PKI_DIR/pki/issued/$CLIENT_NAME.crt")
    KEY=$(sudo cat "$PKI_DIR/pki/private/$CLIENT_NAME.key")
    TA=$(sudo cat "$PKI_DIR/pki/ta.key")
    umask 077
    cat > "$OUT_DIR/$CLIENT_NAME.ovpn" <<EOF
client
dev tun
proto $OVPN_PROTO
remote $OVPN_REMOTE $OVPN_PORT
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
auth SHA256
data-ciphers AES-256-GCM:AES-128-GCM:CHACHA20-POLY1305
verb 3
<ca>
$CA
</ca>
<cert>
$CRT
</cert>
<key>
$KEY
</key>
<tls-crypt>
$TA
</tls-crypt>
EOF
    chmod 0600 "$OUT_DIR/$CLIENT_NAME.ovpn"
    log "wrote $OUT_DIR/$CLIENT_NAME.ovpn (mode 0600)"
else log "[plan] emit $OUT_DIR/$CLIENT_NAME.ovpn with inline ca/cert/key/tls-crypt"; fi

# ── 8. verification ─────────────────────────────────────────────────────────
step "8/9 verify"
if [[ "$MODE" == "apply" ]]; then
    sleep 1
    log "PID:        $(pgrep -a openvpn | head -1 || echo 'NOT RUNNING')"
    log "tun iface:  $(ip -br addr show 2>/dev/null | awk '/^tun/{print; exit}' || echo none)"
    log "listening:  $(ss -ulnp 2>/dev/null | awk -v p=":$OVPN_PORT" '$0 ~ p {print; exit}' || echo none)"
    log "service:    $(systemctl is-active openvpn-server@server.service)"
else log "[plan] would print openvpn PID, tun iface, port $OVPN_PORT listener, service state"; fi

# ── 9. next steps ───────────────────────────────────────────────────────────
step "9/9 next steps"
cat <<EOF
  • Push the profile to your NetHunter phone:
      adb push "$OUT_DIR/$CLIENT_NAME.ovpn" /sdcard/Download/
    Then import it in OpenVPN for Android, or in the Kali chroot:
      openvpn --config /sdcard/Download/$CLIENT_NAME.ovpn
  • Make sure UDP $OVPN_PORT is reachable on '$OVPN_REMOTE' (router port-forward
    to 10.0.0.98, or public-IPv6 bind). LAN-only test: another LAN host can
    connect using the host's LAN IP as --remote.
  • Add another client:
      sudo sh -c "cd $PKI_DIR && EASYRSA_BATCH=1 ./easyrsa build-client-full <name> nopass"
      then re-run: scripts/setup-openvpn.sh --apply --client <name> --remote $OVPN_REMOTE
  • Revoke a client:
      sudo sh -c "cd $PKI_DIR && ./easyrsa revoke <name> && ./easyrsa gen-crl"
EOF
