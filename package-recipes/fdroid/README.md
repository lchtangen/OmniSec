# F-Droid Repository for Aegis Nexus Android App
# Place this in distribution-fdroid/ directory

## Repository Structure
```
distribution-fdroid/
├── repo/
│   ├── aegis-nexus_3.0.apk
│   ├── aegis-nexus_3.0.jar
│   ├── index.xml
│   └── icons/
│       └── aegis-nexus.png
├── metadata/
│   └── org.aegisnexus.app.yml
└── config.yml
```

## config.yml
```yaml
repo_url: https://fdroid.aegis-nexus.org
repo_name: Aegis Nexus F-Droid Repo
keystore: keystore.p12
```

## metadata/org.aegisnexus.app.yml
```yaml
Categories:
  - Security
  - System
License: Apache-2.0
AuthorName: Aegis Nexus Team
AuthorEmail: team@aegis-nexus.org
Summary: Next-Gen Mobile Security Platform
Description: |
  Aegis Nexus brings enterprise-grade security to mobile devices.

  Features:
  * On-device AI agent (llama.cpp)
  * Mesh networking (Reticulum + Yggdrasil)
  * eBPF kernel defense & observability
  * Post-Quantum cryptography (ML-KEM, ML-DSA)
  * Hardware Security Module (YubiKey/SoloKey)
  * 67+ premium security tools

  The only mobile platform with autonomous operations.
WebSite: https://aegis-nexus.org
IssueTracker: https://github.com/AegisNexus/aegis-nexus/issues

RepoType: git
Repo: https://github.com/AegisNexus/aegis-nexus

Builds:
  - versionName: 3.0
    versionCode: 300
    commit: v3.0
    subdir: src/android
    gradle:
      - yes
    build:
      - make stage
      - cd src/android && ./gradlew assembleRelease

AutoUpdateMode: Version v%v
UpdateCheckMode: Tags
```

## Quick Setup
```bash
# Initialize F-Droid repo
fdroid init
fdroid update
fdroid deploy
```
