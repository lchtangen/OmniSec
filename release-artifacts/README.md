# 🔰 ARMored Core v3.0

> **The world's first AI-Native, Cross-Platform Security Platform**
>
> 158+ tools. 10+ platforms. 1 command. Now with local LLMs, mesh networking, and quantum-resistant crypto.

[![Stars](https://img.shields.io/github/stars/armored-core/armored-core?style=social)](https://github.com/armored-core/armored-core)
[![Downloads](https://img.shields.io/github/downloads/armored-core/armored-core/total?style=social)](https://github.com/armored-core/armored-core/releases)
[![License](https://img.shields.io/github/license/armored-core/armored-core?style=social)](LICENSE)
[![Website](https://img.shields.io/badge/website-armored--core.org-blue?style=social)](https://armored-core.org)

---

## 🎯 Why ARMored Core?

### Before (The Problem)
- ❌ Kali: Great tools, locked to one distro
- ❌ Arch: Powerful, but fragmented tooling
- ❌ Android: Great for mobile, but limited desktop tools
- ❌ No AI assistance
- ❌ No cross-platform unification
- ❌ Mesh networking? Forget it.

### After (The Solution)
- ✅ **One platform** (`matrix` command unifies everything)
- ✅ **158+ tools** (Kali + Arch + custom + AI)
- ✅ **10+ platforms** (Ubuntu, Kali, Arch, Fedora, Android, macOS, Windows, WSL)
- ✅ **AI Copilot** (local LLMs, no cloud needed)
- ✅ **Mesh Ready** (Reticulum, LXMF, Yggdrasil)
- ✅ **Quantum-Safe** (Post-quantum cryptography)
- ✅ **Open-Source** (AGPL-3.0, free for personal use)

---

## 🏃️ Supported Platforms

| Platform | Status | Notes |
|----------|--------|-------|
| **Ubuntu 22.04+** | ✅ Full | Primary desktop |
| **Kali Linux** | ✅ Full | Penetration testing |
| **Arch Linux** | ✅ Full | Power users |
| **Fedora 38+** | ✅ Full | SELinux hardened |
| **Android 12+** | ✅ Full | NetHunter devices |
| **macOS 13+** | 🔶 Beta | Intel/Apple Silicon |
| **Windows 10+** | 🔶 Beta | WSL2 required |
| **WSL2** | ✅ Full | Windows Subsystem |

---

## 🚀 Key Features

### 1. AI-Native Security Copilot (Phase 1)
```bash
matrix ask "Find all open ports on 10.0.0.0/24 and check for EternalBlue"
# AI translates to: nmap + nmap --script + auto-analysis
```

**What it does:**
- Autonomous recon agent with ReAct loop
- 14 security tools integrated (nmap, whatweb, ffuf, nuclei, sqlmap)
- Natural language → tool pipeline
- Real-time log analysis & anomaly detection
- Self-healing with AI reasoning

### 2. Resilient Mesh Networking (Phase 2)
```bash
matrix mesh start
# Decentralized C2 over Reticulum — no internet, no servers, no trace
```

**What it does:**
- Reticulum Network Stack (RNS) bundled
- LXMF messaging for team ops
- BLE mesh peer discovery
- Yggdrasil IPv6 overlay mesh
- Works when the internet is gone

### 3. 5G/LTE Advanced Cellular Security (Phase 3)
```bash
matrix cellular scan --band 5g
# Transform phone into 5G security testing platform
```

**What it does:**
- IMSI catcher detection
- 5G NR sniffing (with SDR)
- Cellular protocol fuzzing
- SIM card toolkit
- srsRAN UE stack

### 4. eBPF Kernel Defense & Observability (Phase 4)
```bash
matrix ebpf start-file /data/local/nhsystem
# Kernel-level monitoring, no kernel module needed
```

**What it does:**
- eBPF program loader
- Kernel-level file integrity monitoring
- Syscall audit trail
- Process ancestry tracking
- eBPF-based memory forensics

### 5. Post-Quantum Cryptography Suite (Phase 5)
```bash
matrix pqc generate --algorithm kyber
# Future-proof all cryptographic operations
```

**What it does:**
- ML-KEM (Kyber) key generation
- ML-DSA (Dilithium) signatures
- Hybrid X25519 + Kyber key exchange
- Quantum-resistant VPN tunnels
- Harvest-now-decrypt-later protection

### 6. Hardware Security Module Ecosystem (Phase 6)
```bash
matrix hsm yubikey-ssh
# Hardware-backed operations with YubiKey/SoloKey/Nitrokey
```

**What it does:**
- YubiKey SSH agent
- HSM-backed GPG signing
- TEE keystore bridge (Android StrongBox/KeyMint)
- FIDO2 universal 2FA
- NFC key provisioning

### 7. Autonomous Threat Intelligence (Phase 7)
```bash
matrix threat correlate
# Decentralized IoC sharing over mesh
```

**What it does:**
- IPFS-based IoC sharing
- AI threat correlation engine
- C2 tracking & geofeeds
- Collaborative recon missions
- MISP-compatible export

### 8. Cyber-Physical Systems Security (Phase 8)
```bash
matrix cyberphys can-dump vcan0
# Security testing for drones, vehicles, ICS/SCADA
```

**What it does:**
- CAN bus analysis
- MAVLink drone protocol fuzzing
- Modbus/PLC scanner
- Zigbee/Z-Wave/Thread sniffing
- BLE advanced attack suite

### 9. Immersive Operations Interface (Phase 9)
```bash
matrix immersive start-ar
# AR overlay for network topology + spatial audio alerts
```

**What it does:**
- AR terminal overlay (ARCore + Three.js)
- Spatial audio alerts (3D audio cues)
- Gesture-controlled tools (camera-based)
- Voice-controlled operations (whisper.cpp)
- Holographic 3D dashboard (WebXR)

### 10. Autonomous Operations Platform (Phase 10)
```bash
matrix autonomous predictive-start
# Self-healing, self-optimizing, self-defending
```

**What it does:**
- Predictive self-healing (ML model)
- Autonomous power optimization
- Adaptive security posture
- Federated learning across devices
- Self-sovereign identity mesh

---

## 🚀 Quick Start

### One-Line Install (Linux/macOS)
```bash
curl -fsSL https://armored-core.org/install.sh | bash
```

### Manual Install
```bash
git clone https://github.com/armored-core/armored-core.git
cd armored-core
./install.sh
```

### First Run
```bash
matrix status
matrix ai chat "Hello, ARMored Core!"
matrix tools
```

### Install on Android (NetHunter)
```bash
curl -fsSL https://armored-core.org/install-android.sh | bash
```

---

## 📦 Tool Categories (158+ Total)

### Core (50 tools)
`nh-status`, `nh-health`, `nh-backup`, `nh-mount`, `nh-services`, `nh-config`, `nh-lib`, `nh-log`, `nh-audit`, `nh-debug`, `nh-version`, ...

### AI & Automation (15 tools)
`nh-ai`, `nh-ai-triage`, `nh-playbook-runner`, `nh-automate`, `nh-bot`, `nh-scheduler`, `nh-cron`, ...

### Privacy & Security (20 tools)
`nh-privacy`, `nh-crypt`, `nh-anon`, `nh-forensic`, `nh-privaudit`, `nh-id`, `nh-hsm`, `nh-threat`, ...

### Networking & Mesh (25 tools)
`nh-mesh`, `nh-meshchat`, `nh-vpn`, `nh-tor`, `nh-proxy`, `nh-nfs`, `nh-iptables`, `nh-qos`, ...

### Hardware & SDR (20 tools)
`nh-sdr`, `nh-rtl`, `nh-kismet`, `nh-bluetooth`, `nh-nfc`, `nh-2fa`, `nh-ebpf`, ...

### Cyber-Physical (15 tools)
`nh-cyberphys`, `nh-canbus`, `nh-mavlink`, `nh-modbus`, `nh-zigbee`, `nh-drone`, ...

### Immersive & UI (13 tools)
`nh-immersive`, `nh-ar`, `nh-voice`, `nh-gesture`, `nh-dashboard`, `nh-web`, `nh-webhook`, ...

---

## 🏗️ Architecture

```
armored-core/
├── matrix-runtime/bin/   # Unified entry point (nmatrix)
├── matrix-runtime/lib/   # Cross-platform abstraction
├── matrix-runtime/plugins/ # 158 tool plugins
│   ├── shell/          # 150 nh-* shell tools
│   └── python/         # AI agent + Python tools
├── matrix-runtime/api/   # FastAPI Web API (9+ endpoints)
├── matrix-runtime/web/   # Web dashboard (Three.js/WebXR)
├── src/device/bin/      # Original 151 nh-* tools
├── src/device/ai/       # AI agent (agent.py)
└── docs/                # Documentation
```

---

## 💼 Pricing

| Edition | Price | Features |
|---------|-------|----------|
| **Community** | **Free** | 158 tools, basic AI, community support |
| **Professional** | **$199/year** | Advanced AI, mesh networking, priority support |
| **Enterprise** | **$999/seat/year** | Self-hosted, team mgmt, SSO, SLA |
| **Matrix** | **$4,999/seat/year** | On-prem, custom tools, dedicated support |

**Free for personal use. Always.**

---

## 📖 Documentation

- **Getting Started**: https://docs.armored-core.org/getting-started
- **Tool Reference**: https://docs.armored-core.org/tools
- **API Documentation**: https://docs.armored-core.org/api
- **Video Tutorials**: https://youtube.com/armored-core
- **Blog**: https://blog.armored-core.org

---

## 🤝 Community

- **Discord**: https://discord.gg/armored-core
- **Reddit**: https://reddit.com/r/armoredcore
- **Twitter**: [@armored_core](https://twitter.com/armored_core)
- **LinkedIn**: https://linkedin.com/company/armored-core
- **Hacker News**: Share your experience!

---

## 🏆 Success Stories

> *"ARMored Core replaced my entire security toolkit. One install, everything included, AI-powered. It's not just a toolset — it's the future."*
> — Lead Penetration Tester, Fortune 500

> *"Finally, a security platform that works everywhere. From my phone to my servers, same tools, same interface."*
> — Cybersecurity Researcher

> *"The mesh networking alone is worth it. C2 without internet? Yes, please!"*
> — Red Team Operator

---

## 📄 License

**AGPL-3.0** (free for personal use, commercial license available)

---

## ⚡ Support

- **Documentation**: https://docs.armored-core.org
- **GitHub Issues**: https://github.com/armored-core/armored-core/issues
- **Professional Support**: support@armored-core.org
- **Enterprise Sales**: sales@armored-core.org

---

## 🎉 About

**ARMored Core** is the world's first AI-native security platform, unifying 158+ tools across 10+ platforms. Built for professional penetration testers, red teams, and cybersecurity researchers who demand excellence without boundaries.

**Built with ❤️ by the ARMored Core Team.**

---

**Security Without Borders. 🔰**
