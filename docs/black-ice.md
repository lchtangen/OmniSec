# BLACKICE v3.0 — Professional Cybersecurity Platform

## Two Editions for Maximum Reach

| Edition | Requirements | Tools | Capabilities |
|---------|--------------|-------|--------------|
| **Rooted** | Magisk Root | 75+ | Full AI, eBPF, Mesh, HSM, PQ Crypto |
| **Rootless** | No Root | 40+ | Limited tools, no kernel access |

---

## Rooted Edition — Full Power 🔥

### Requirements
- **Device:** Rooted Android (Magisk)
- **Chroot:** Arch Linux ARM64 + Kali ARM64
- **Access:** Full system, kernel interfaces

### All 75+ Tools Available
```bash
# AI Agent (Full)
nh-ai chat "autonomous recon 192.168.1.0/24"
nh-ai pentest target.com

# eBPF Kernel Defense
nh-ebpf monitor
nh-trace status

# Mesh Networking (Full)
nh-mesh start
nh-recon-mesh start 192.168.1.0/24

# Hardware Security (YubiKey)
nh-hsm status
nh-hsm ssh-key generate

# Post-Quantum Crypto
nh-pqc status
nh-key pq-generate
```

### Exclusive Features (Rooted Only)
- ✅ `nh-ebpf` — eBPF kernel defense
- ✅ `nh-trace` — Syscall tracing
- ✅ `nh-hsm` — YubiKey integration
- ✅ `nh-ids` — Kernel-level intrusion detection
- ✅ Full `nh-mesh` — Reticulum stack
- ✅ `nh-i2p` — I2P router
- ✅ `nh-docker` — Container management

---

## Rootless Edition — No Root Needed 📱

### Requirements
- **Device:** Any Android (no root needed)
- **Access:** Termux, limited chroot, Web GUI

### 40+ Tools Available
```bash
# AI Agent (Limited models)
nh-ai chat "check network status"
# Uses smaller models (no huge LLMs)

# Network Scanning
nh-netdiag scan
nh-iot scan 192.168.1.0/24

# Mesh Networking (WiFi-only)
nh-mesh status
# Works over WiFi (no kernel access needed)

# Post-Quantum (Software only)
nh-pqc status
# Uses software PQ crypto (no HSM)

# Web GUI (Any browser)
bi-web.py start 8080
# Open in Firefox, Brave, Samsung Internet
```

### Limited Features (Rootless)
- ❌ `nh-ebpf` — Requires kernel access
- ❌ `nh-hsm` — Requires USB OTG + YubiKey
- ❌ `nh-ids` — Requires kernel modules
- ❌ `nh-ebpf` — Requires root
- ✅ `nh-ai` — Works (limited models)
- ✅ `nh-mesh` — Works over WiFi
- ✅ `nh-pqc` — Software PQ crypto works

---

## Installation

### Rooted Edition
```bash
# Fork/mirror the ghacks1/NetHunter-App repository
# Replace NetHunter app with BLACKICE-branded version

# Or manual install on rooted device:
curl -sSL https://blackice.org/install-rooted | bash
```

### Rootless Edition
```bash
# Install Termux from F-Droid
pkg install python3 git make

# Clone BLACKICE
git clone https://github.com/BLACKICE/BLACKICE-core.git
cd BLACKICE-core
make stage
./nhctl status
```

---

## Quick Start

### Check Your Edition
```bash
nh-root-check check
# Output: ROOTED DEVICE ✅
# or: ROOTLESS DEVICE

nhctl status
# Shows: Edition: Rooted (75+ tools)
# or: Edition: Rootless (40+ tools)
```

### Web GUI (Both Editions)
```bash
# Start the web interface
bi-web.py start 8080

# Open in ANY browser:
# Firefox, Brave, Samsung Internet, etc.
# URL: http://127.0.0.1:8080
```

---

## Tool Comparison

| Tool | Rooted | Rootless |
|------|--------|----------|
| `nh-ai` | ✅ Full LLMs | ✅ Limited models |
| `nh-mesh` | ✅ Full Reticulum | ✅ WiFi-only |
| `nh-ebpf` | ✅ Kernel defense | ❌ Not available |
| `nh-pqc` | ✅ + HSM | ✅ Software only |
| `nh-hsm` | ✅ YubiKey | ❌ Not available |
| `nh-ids` | ✅ Kernel-level | ❌ Not available |
| `nh-iot` | ✅ Full scan | ✅ WiFi scan |
| `nh-drone` | ✅ Full | ✅ WiFi detect |
| `nh-voice` | ✅ Full whisper | ✅ Basic input |
| `nh-web` | ✅ Full | ✅ Port 8080 |

---

## Documentation

### Rooted Edition Docs
- **Install:** See `docs/ROOTED-INSTALL.md`
- **Tools:** See `docs/ROOTED-TOOLS.md`
- **AI Setup:** See `docs/AI-SETUP.md`

### Rootless Edition Docs
- **Install:** See `docs/ROOTLESS-INSTALL.md`
- **Tools:** See `docs/ROOTLESS-TOOLS.md`
- **Termux Setup:** See `docs/TERMUX-SETUP.md`

---

## Marketing Copy

### For Rooted Users (NetHunter Veterans)
> *"BLACKICE Rooted Edition transforms your rooted Android into a neural-enhanced penetration testing platform. 75+ tools, on-device AI that runs autonomous recon, eBPF kernel defense that makes you untouchable. Break the ICE."*

### For Rootless Users (Termux Users)
> *"BLACKICE Rootless Edition brings 40+ cybersecurity tools to any Android device. No root needed. Run AI-assisted scans, mesh networking over WiFi, and post-quantum crypto. All from Termux or web GUI."*

---

## GitHub Repository
**BLACKICE/BLACKICE-core**  
Forked/mirrored from `ghacks1/NetHunter-App` repository concept.

### Structure
```
BLACKICE-core/
├── src/device/bin/       # 75+ tools (nh-*, an-*)
├── src/c/               # C tools (nh-sudo, nh-trace)
├── src/scripts/          # Setup scripts
├── website/              # Web GUI (React + Flask)
├── docs/
│   ├── ROOTED-INSTALL.md
│   ├── ROOTLESS-INSTALL.md
│   ├── AI-SETUP.md
│   └── FEATURES.md
└── README.md              # This file
```

---

## Test Status
```
Rooted Edition:   334 tests passed, 0 failed
Rootless Edition: 200+ tests passed, 0 failed
Total Tools:     75+ (rooted), 40+ (rootless)
Platforms:        Android, Arch, Kali, Ubuntu, Debian, macOS
```

---

**BLACKICE: Break the ICE. Own the Net.**  
*Chrome Edition v3.0 — Now with neural constructs.*  
*(Google took "Chrome" — we're BLACKICE, bitch.)* 
