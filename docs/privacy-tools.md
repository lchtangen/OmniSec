# Privacy Tools Documentation

OmniSec includes a suite of privacy-focused tools designed for Android devices running NetHunter with Arch ARM64 and Kali Linux chroots.

## Overview

| Tool | Purpose | Priority |
|------|---------|----------|
| `nh-privacy` | Privacy dashboard and controls | P1 |
| `nh-crypt` | Encryption and key management | P1 |
| `nh-anon` | Anonymization and Tor setup | P1 |
| `nh-forensic` | Anti-forensics and secure deletion | P1 |
| `nh-privaudit` | Privacy exposure audit | P3 |
| `nh-id` | Identity management (MAC, hostname) | P2 |

## Installation

All tools are installed to `/data/local/nhsystem/bin/` during setup. Launcher scripts are available in `src/device/launchers/` for use with Termux widgets.

## Tool Details

### nh-privacy

Privacy dashboard with threat level assessment and quick controls.

**Commands:**
- `nh-privacy status` - Show privacy status dashboard
- `nh-privacy threats` - Display threat analysis
- `nh-privacy lockdown` - Enable maximum privacy mode
- `nh-privacy work` - Enable work profile mode
- `nh-privacy clear-clipboard` - Clear clipboard
- `nh-privacy clear-history` - Clear shell/history files
- `nh-privacy network-scan` - Scan for privacy leaks

### nh-crypt

Encryption and key management tool.

**Commands:**
- `nh-crypt status` - Show encryption status
- `nh-crypt generate-key [type]` - Generate keys (rsa/ed25519/crypto)
- `nh-crypt encrypt <file>` - Encrypt a file
- `nh-crypt decrypt <file>` - Decrypt a file
- `nh-crypt secure-erase <file>` - Secure erase with wipe
- `nh-crypt vault-init` - Initialize encrypted vault
- `nh-crypt vault-mount` - Mount encrypted vault
- `nh-crypt vault-umount` - Unmount encrypted vault

### nh-anon

Anonymization and Tor configuration tool.

**Commands:**
- `nh-anon status` - Show anonymization status
- `nh-anon tor-start` - Start Tor service
- `nh-anon tor-stop` - Stop Tor service
- `nh-anon tor-check` - Verify Tor connectivity
- `nh-anon proxy-on [type]` - Enable proxy (tor/socks5/http)
- `nh-anon proxy-off` - Disable proxy
- `nh-anon mac-spoof` - Spoof MAC address
- `nh-anon user-agent` - Rotate browser user-agent

### nh-forensic

Anti-forensics and secure deletion tool.

**Commands:**
- `nh-forensic status` - Show forensic status
- `nh-forensic scan` - Scan for forensic artifacts
- `nh-forensic wipe-file <path>` - Secure wipe file (3-pass)
- `nh-forensic wipe-free` - Wipe free space
- `nh-forensic clear-logs` - Clear system logs
- `nh-forensic clear-tmp` - Clear temporary files
- `nh-forensic reset-artifacts` - Reset forensic artifacts
- `nh-forensic timeline` - Show artifact timeline

### nh-privaudit

Privacy exposure audit tool.

**Checks:**
- Microphone/camera indicators
- Clipboard exposure
- Network leaks (HTTP, DNS)
- Location exposure
- App permission audit
- Sensitive files
- Open ports
- Running services
- Chroot privacy (SSH keys, history, git credentials)
- Encryption status

**Usage:** `nh-privaudit` (no arguments, runs full audit)

### nh-id

Identity management tool for MAC, hostname, and user-agent randomization.

**Commands:**
- `nh-id status` - Show current identity
- `nh-id random-mac [iface]` - Randomize MAC address
- `nh-id restore-mac [iface]` - Restore original MAC
- `nh-id random-hostname` - Set random hostname
- `nh-id restore-hostname` - Restore original hostname
- `nh-id random-ua` - Generate random browser user-agents
- `nh-id spoof-wifi` - Enable MAC spoofing for WiFi

## Dependencies

Most tools require:
- Root access (for certain operations)
- `nh-lib` (included in OmniSec)
- Standard Linux utilities (ip, ss, mount, etc.)

## Chroot Support

All tools support both Arch Linux ARM64 and Kali Linux ARM64 chroots:
- Arch: `/data/local/nhsystem/roots/archlinux/`
- Kali: `/data/local/nhsystem/roots/kali-arm64/`

## Security Notes

1. MAC address changes require root and interface restart
2. Hostname changes may require reboot
3. Secure erase uses 3-pass overwrite (configurable)
4. Tor proxy requires Tor service running in chroot
5. Always verify privacy status after changes

## Examples

```bash
# Check privacy status
nh-privacy status

# Start Tor and verify
nh-anon tor-start
nh-anon tor-check

# Encrypt a sensitive file
nh-crypt encrypt secret.txt

# Audit privacy exposure
nh-privaudit

# Randomize identity
nh-id random-mac wlan0
nh-id random-hostname
```

## Troubleshooting

- **Tool not found**: Ensure `/data/local/nhsystem/bin` is in PATH
- **Permission denied**: Run with `su` or in rooted shell
- **Chroot errors**: Run `nh-health` to verify chroot setup
- **Tor issues**: Check `nh-services status` and ensure Tor is installed in chroot
