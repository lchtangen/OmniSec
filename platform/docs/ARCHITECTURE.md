# OmniSec ULTIMATE — Architecture

## Overview
```
┌─────────────────────────────────────────────────────┐
│                   OmniSec ULTIMATE                    │
├────────────┬────────────┬────────────┬───────────────┤
│  Desktop   │   Mobile   │    CLI     │    Web UI     │
│  (PyQt6)   │  (KivyMD)  │  (Rich)    │  (HTML5/JS)   │
├────────────┴────────────┴────────────┴───────────────┤
│                  Module System (161)                  │
│  Core │ Network │ Web │ Exploit │ Crypto │ OSINT...  │
├──────────────────────────────────────────────────────┤
│                 AI Copilot (Local LLM)                 │
├──────────────────────────────────────────────────────┤
│              Security Layer (Sandbox + Certs)          │
├──────────────────────────────────────────────────────┤
│               Post-Quantum Cryptography                │
├──────────────────────────────────────────────────────┤
│              Mesh Networking (Reticulum)               │
└──────────────────────────────────────────────────────┘
```

## Design Principles
1. **Offline-first** — All functionality works without internet
2. **Privacy-maximalist** — Zero telemetry, zero cloud
3. **Modular** — Plugin architecture, discover modules at runtime
4. **Cross-platform** — Same codebase for desktop + mobile
5. **API-first** — Every module exposes a CLI + GUI + API interface

## Core Components

### Desktop GUI (`gui/main.py`)
- PyQt6 frameless window with custom title bar
- 7 main pages with smooth transitions
- Matrix rain animation with glitch effects
- Threaded scanners (non-blocking UI)
- System tray with quick actions

### Module System (`gui/modules/`)
- 30+ modules across 12 categories
- Auto-discovery via `discover_modules()`
- Each module: name, category, version, icon, get_widget()
- Lazy loading for performance

### Mobile App (`mobile/`)
- KivyMD for cross-platform mobile
- Buildozer for Android APK
- Optimized for touch interaction
- Background service for persistent operations

### Security Layer (`security/`)
- Permission model (granular, user-approved)
- Sandbox execution (seccomp + containers)
- Code signing verification
- Audit logging

## Data Flow
```
User Input → Permission Check → Sandbox → Module → Output
                 ↓                                  ↓
          Audit Log                          Report Generator
```
