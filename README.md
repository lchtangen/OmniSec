# 🔰 OmniSec v3.0

> **The Ultimate Mobile Security & Development Platform**
>
> 192+ tools. 7 platforms. 1 command. Now with AI, mesh networking, and quantum-resistant crypto.

[![Stars](https://img.shields.io/github/stars/lchtangen/OmniSec?style=social)](https://github.com/lchtangen/OmniSec)
[![Downloads](https://img.shields.io/github/downloads/lchtangen/OmniSec/total?style=social)](https://github.com/lchtangen/OmniSec/releases)
[![License](https://img.shields.io/badge/license-GPLv3-blue.svg)](LICENSE)
[![CI](https://img.shields.io/github/actions/workflow/status/lchtangen/OmniSec/ci.yml?branch=main&label=ci)](https://github.com/lchtangen/OmniSec/actions/workflows/ci.yml)
[![Code of Conduct](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](CODE_OF_CONDUCT.md)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![Website](https://img.shields.io/badge/web-omnisec.dev-blue)](https://omnisec.dev)

---

## 🎯 Why OmniSec?

### Before (The Problem)
- ❌ Kali: Great tools, locked to one distro
- ❌ Arch: Powerful, but fragmented tooling
- ❌ Android: Great for mobile, but limited desktop tools
- ❌ No AI assistance
- ❌ No cross-platform unification
- ❌ Mesh networking? Forget it.

### After (The Solution)
- ✅ **One platform** (`nhctl` command unifies everything)
- ✅ **192+ tools** (Kali + Arch + custom + AI)
- ✅ **7 platforms** (Ubuntu, Kali, Arch, Fedora, Android, macOS, Windows/WSL)
- ✅ **AI Copilot** (local LLMs, no cloud needed)
- ✅ **Mesh Ready** (Reticulum, LXMF, Yggdrasil)
- ✅ **Quantum-Safe** (Post-quantum cryptography)
- ✅ **Open-Source** (GPLv3, free for everyone)

---

## 🏗️ Supported Platforms

| Platform | Status | Notes |
|----------|--------|-------|
| **Ubuntu 22.04+** | ✅ Full | Primary desktop |
| **Kali Linux** | ✅ Full | Penetration testing |
| **Arch Linux** | ✅ Full | Power users |
| **Fedora 38+** | ✅ Full | SELinux hardened |
| **Android 12+** | ✅ Full | NetHunter devices |
| **macOS 13+** | 🔶 Beta | Intel/Apple Silicon |
| **Windows 10+** | 🔶 Beta | WSL2 required |

---

## 🚀 Key Features

### Phase 1: AI-Native Copilot
- Local LLM integration (Ollama)
- Intelligent command suggestions
- Automated pentest reporting
- Code generation and review

### Phase 2: Mesh Networking
- Reticulum mesh protocol
- LXMF messaging
- Yggdrasil overlay network
- Off-grid communication

### Phase 3: 5G/LTE Security (Sim)
- 5G protocol analysis
- IMSI catcher detection
- LTE security testing

### Phase 4: eBPF Kernel Defense
- eBPF-based security monitoring
- Runtime kernel protection
- Performance tracing

### Phase 5: Post-Quantum Crypto
- Quantum-resistant algorithms
- Hybrid TLS implementations
- Future-proof encryption

### Phase 6: HSM Ecosystem
- Hardware Security Module support
- Secure key storage
- TPM integration

### Phase 7: Threat Intelligence
- IOC (Indicator of Compromise) tracking
- Threat feed integration
- Automated analysis

### Phase 8: Cyber-Physical (Sim)
- IoT device security
- Industrial control systems
- Smart infrastructure

### Phase 9: Immersive Ops (Sim)
- VR/AR security visualization
- 3D network mapping
- Immersive dashboards

### Phase 10: Autonomous Ops
- Self-healing networks
- Automated incident response
- Autonomous security agents

---

## 📦 Quick Install

```bash
curl -fsSL https://omnisec.dev/install.sh | bash
```

Or manual install:

```bash
git clone https://github.com/lchtangen/OmniSec.git
cd OmniSec
./install.sh
```

---

## 🎮 Usage

```bash
# Main controller
nhctl status          # Check system status
nhctl shell kali       # Enter Kali shell
nhctl shell arch       # Enter Arch shell
nhctl mount            # Mount chroots
nhctl backup           # Backup everything

# AI Copilot
nhctl ai "scan this network"
nhctl ai-triage /path/to/suspicious/file

# Mesh networking
nhctl mesh status
nhctl mesh peer add <address>

# Security tools
nhctl pentest --target 192.168.1.0/24
nhctl threat intel update
```

---

## 🏗️ Architecture

- **Host Controller**: `nhctl` (911 lines of bash)
- **Device Tools**: 192+ scripts (nh-*, an-*)
- **Dual Chroot**: Arch Linux + Kali Linux
- **AI Engine**: Local LLM via Ollama
- **Mesh Network**: Reticulum + LXMF
- **Kernel**: Custom NetHunter with eBPF, PQ crypto

---

## 🤝 Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.
All contributors must follow our [Code of Conduct](CODE_OF_CONDUCT.md).

### Quick Start

```bash
git clone https://github.com/lchtangen/OmniSec.git
cd OmniSec
make              # lint, build, stage, test
```

### Report Issues

- [Bug Report](https://github.com/lchtangen/OmniSec/issues/new?labels=bug&template=bug_report.md)
- [Feature Request](https://github.com/lchtangen/OmniSec/issues/new?labels=enhancement&template=feature_request.md)
- [Security Vulnerability](SECURITY.md)

## 💬 Community

| Resource | Link |
|----------|------|
| **Discord** | [OmniSec Community](https://discord.gg/omnisec) |
| **Matrix** | `#omnisec:matrix.org` |
| **IRC** | `#omnisec` on Libera.Chat |
| **Discussions** | [GitHub Discussions](https://github.com/lchtangen/OmniSec/discussions) |
| **Support** | [SUPPORT.md](SUPPORT.md) |
| **Service Status** | [status.omnisec.dev](https://status.omnisec.dev) |

## 📄 License

**GNU General Public License v3.0** — See [LICENSE](LICENSE) for details.

This is free software: you can use, modify, and redistribute it under the terms of the GPLv3.
No warranty is provided — use at your own risk.

### Third-party licenses

This project builds on these open source works:
- **Kali Linux** — GPLv3 | [kali.org](https://www.kali.org)
- **Arch Linux** — GPLv2 | [archlinux.org](https://archlinux.org)
- **NetHunter** — GPLv3 | [gitlab.com/kalilinux/nethunter](https://gitlab.com/kalilinux/nethunter)
- **OpenVPN** — GPLv2 | [openvpn.net](https://openvpn.net)
- **WireGuard** — GPLv2 | [wireguard.com](https://www.wireguard.com)
- **OpenCode** — Apache 2.0 | [opencode.ai](https://opencode.ai)
- **easy-rsa** — GPLv2 | [github.com/OpenVPN/easy-rsa](https://github.com/OpenVPN/easy-rsa)

---

**OmniSec — Open Source. Free. For Everyone.**
