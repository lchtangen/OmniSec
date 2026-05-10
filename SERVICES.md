# OmniSec Services — Beta Access Guide

This document defines the official OmniSec service infrastructure endpoints. Beta users can use these hostnames and ports to connect to the network.

---

## Domain

```
omnisec.dev
```

All services are subdomains under `omnisec.dev`. The gateway host `gateway.omnisec.dev` routes traffic to the appropriate backend.

---

## Service Table

| Service | Hostname | Port | Protocol | Purpose |
|---------|----------|------|----------|---------|
| **OpenVPN** | `vpn.omnisec.dev` | 1194 | UDP | Remote access VPN for beta network |
| **OpenSSH** | `ssh.omnisec.dev` | 22 | TCP | SSH gateway / tunnel entry |
| **OpenCode** | `code.omnisec.dev` | 8448 | HTTPS | AI-assisted code collaboration relay |
| **API** | `api.omnisec.dev` | 443 | HTTPS | REST API for service orchestration |
| **Status** | `status.omnisec.dev` | 443 | HTTPS | Service health dashboard |
| **WireGuard** | `wg.omnisec.dev` | 51820 | UDP | Mesh VPN endpoint |
| **Auth** | `auth.omnisec.dev` | 443 | HTTPS | Authentication / token exchange |
| **Keyserver** | `keys.omnisec.dev` | 443 | HTTPS | Public key distribution (SSH CA, GPG) |
| **Registry** | `registry.omnisec.dev` | 443 | HTTPS | Package / artifact registry |

---

## Quick-Start: Connecting as a Beta User

### OpenVPN

Import this profile into OpenVPN for Android or your OS client:

```ini
client
dev tun
proto udp
remote vpn.omnisec.dev 1194
resolv-retry infinite
nobind
remote-cert-tls server
auth SHA256
data-ciphers AES-256-GCM:AES-128-GCM:CHACHA20-POLY1305
verb 3
```

Your `.ovpn` file will be provided by the OmniSec team with embedded CA/cert/key.

### OpenSSH

```bash
ssh -J user@ssh.omnisec.dev user@gateway.omnisec.dev
```

Or direct if your key is authorized:

```bash
ssh -p 22 user@ssh.omnisec.dev
```

### OpenCode

Configure OpenCode to use the relay:

```bash
opencode --relay code.omnisec.dev:8448
```

Or set the environment variable:

```bash
export OPENCODE_RELAY=https://code.omnisec.dev:8448
```

### WireGuard

Peer config for beta access:

```ini
[Peer]
PublicKey = <provided-by-team>
Endpoint = wg.omnisec.dev:51820
AllowedIPs = 10.0.1.0/24
PersistentKeepalive = 25
```

---

## Key Management

Beta users authenticate to OmniSec services using a local key store at `~/.omnisec/keys/`.

### Quick Start

```bash
# Initialize key store
nhctl key init

# Generate keys
nhctl key ssh                    # SSH key pair (ed25519)
nhctl key gpg                    # GPG signing key
nhctl key wg                     # WireGuard key pair
nhctl key api my-beta-key        # API key for service auth

# List and inspect
nhctl key list
nhctl key fingerprint

# Export (encrypted) for backup
nhctl key export ~/omnisec-keys-backup.tar.age
```

### Key types

| Type | Location | Purpose |
|------|----------|---------|
| SSH | `~/.omnisec/keys/ssh/` | Service authentication, git operations |
| GPG | `~/.omnisec/keys/gpg/` | Commit signing, artifact verification |
| WireGuard | `~/.omnisec/keys/wireguard/` | VPN mesh peer auth |
| API | `~/.omnisec/keys/api/` | REST API key registry (hashed) |
| OpenVPN | `~/.omnisec/keys/ovpn/` | Client certificates for VPN |

---

## On-Device Services (NetHunter)

These run on the NetHunter handset itself and are reachable via ADB or LAN:

| Service | IP (LAN) | Port | Notes |
|---------|----------|------|-------|
| ADB | `10.0.0.113` | 52104 | Device control |
| Arch chroot SSH | `10.0.0.113` | 2222 | Arch Linux arm64 |
| Kali chroot SSH | `10.0.0.113` | 22 | Kali Linux arm64 |
| Termux SSH | `10.0.0.113` | 8022 | Termux environment |

---

## VPN Subnet Layout

| Network | CIDR | Purpose |
|---------|------|---------|
| VPN clients | `10.8.0.0/24` | OpenVPN tunnel pool |
| Mesh/WireGuard | `10.0.1.0/24` | WireGuard peer network |
| Management | `10.0.0.0/24` | LAN management subnet |

---

## Machine-Readable Config

Scripts and automation should source `src/services/service-config.sh` for all endpoint variables instead of hardcoding values. This file is the source of truth.

```bash
. src/services/service-config.sh
echo "OpenVPN endpoint: $NH_OVPN_FQDN:$NH_OVPN_PORT/$NH_OVPN_PROTO"
```

---

## Changelog

| Date | Change |
|------|--------|
| 2026-05 | Initial service infrastructure definition |
