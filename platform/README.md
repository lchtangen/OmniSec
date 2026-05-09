<h1 align="center">
  <img src="https://raw.githubusercontent.com/lchtangen/OmniSec/matrix-platform-unified/website/assets/logo.svg" alt="OmniSec" width="120" style="vertical-align: middle;"/>
  <br>OmniSec
</h1>
<p align="center">
  <strong>AI-Native, Offline-First Cybersecurity Platform</strong>
  <br>
  161 Tools · AI Copilot · Post-Quantum Crypto · Mesh Networking
  <br>
  <strong>Zero Cloud · Zero Telemetry · Maximum Privacy</strong>
</p>

<p align="center">
  <a href="https://github.com/omnisec-io/armored/releases"><img src="https://img.shields.io/github/v/release/omnisec-io/armored?style=flat&color=00FFFF" alt="Release"></a>
  <a href="https://github.com/omnisec-io/armored/blob/main/LICENSE"><img src="https://img.shields.io/github/license/omnisec-io/armored?style=flat&color=FF00FF" alt="License"></a>
  <a href="https://www.gnu.org/philosophy/free-sw.html"><img src="https://img.shields.io/badge/free-as%20in%20freedom-00FF00?style=flat" alt="Free Software"></a>
  <a href="https://github.com/omnisec-io/armored/issues"><img src="https://img.shields.io/github/issues/omnisec-io/armored?style=flat&color=FFFF00" alt="Issues"></a>
</p>

---

## ⚡ Features

- **AI Copilot** — Local LLM with Chain-of-Thought reasoning
- **161 Security Tools** — One unified platform, one CLI
- **100% Offline** — No cloud, no tracking, no telemetry
- **Post-Quantum Cryptography** — Kyber, Dilithium, SPHINCS+
- **Mesh Networking** — Operate without internet infrastructure
- **Cyberpunk UI** — Neon-soaked, holographic, frameless interface
- **Cross-Platform** — Android, Linux, macOS, Windows
- **Free Forever** — Open source, no paywalls, no enterprise upsells

## 📦 Installation

### Linux
```bash
# AppImage
wget https://github.com/omnisec-io/armored/releases/latest/download/OmniSec-x86_64.AppImage
chmod +x OmniSec-x86_64.AppImage
./OmniSec-x86_64.AppImage

# Debian/Ubuntu
sudo dpkg -i omnisec_3.0.0_all.deb
omnisec

# Snap
sudo snap install omnisec
```

### Android
[<img src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png" height="60">](https://play.google.com/store/apps/details?id=io.omnisec.app)
[<img src="https://fdroid.gitlab.io/artwork/badge/get-it-on.png" height="60">](https://f-droid.org/packages/io.omnisec.app)

### Python
```bash
pip install omnisec
omnisec gui
```

## 🚀 Quick Start
```bash
# Launch GUI
omnisec gui

# Network scan
omnisec scan 192.168.1.0/24

# AI Copilot
omnisec ai "How do I check for open ports?"

# List all tools
omnisec modules list
```

## 🏗 Architecture
```
┌────────────────────────────────────────────┐
│           OmniSec ULTIMATE                  │
├──────────┬─────────┬─────────┬──────────────┤
│ Desktop  │ Mobile  │   CLI   │    Web UI    │
│ (PyQt6)  │(KivyMD) │ (Rich)  │  (HTML5/JS)  │
├──────────┴─────────┴─────────┴──────────────┤
│          Module System (161 tools)           │
├─────────────────────────────────────────────┤
│  AI Copilot  ·  Sandbox  ·  Post-Quantum    │
└─────────────────────────────────────────────┘
```

## 🔒 Security
- **Zero data collection** — No telemetry, no analytics, no phone-home
- **Sandbox execution** — Tools run in isolated environments
- **Code signing** — All releases GPG-signed
- **SBOM** — Software Bill of Materials for every release
- **Dependency scanning** — Automated vulnerability checking in CI

## 📚 Documentation
- [Architecture](docs/ARCHITECTURE.md)
- [Security Policy](docs/SECURITY.md)
- [Privacy Policy](docs/PRIVACY.md)
- [Contributing Guide](docs/CONTRIBUTING.md)
- [API Reference](docs/API.md)

## 🤝 Contributing
See [CONTRIBUTING.md](docs/CONTRIBUTING.md). All contributions welcome!

## 📄 License
MIT License — see [LICENSE](LICENSE)

## ⭐ Support
Star this repo, share with friends, contribute code.
**Together we build the ultimate open-source security platform.**

## 🌐 Website Deployment (Cloudflare Pages)

The website is a static HTML/CSS/JS site ready for Cloudflare Pages:

1. Push this repo to GitHub (`github.com/omnisec-io/armored`)
2. In Cloudflare Dashboard → Pages → Connect to GitHub → select repo
3. Build settings: **Framework preset: None**, **Build output: /** (root)
4. Add custom domain: `omnisec.io`
5. Deploy — done. Auto-deploys on every push to main.

`_headers` and `_redirects` are pre-configured for security (CSP, HSTS, permissions).

