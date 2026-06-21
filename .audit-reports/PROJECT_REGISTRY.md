# PROJECT REGISTRY & METADATA
**Comprehensive index of all identified projects**

## Tier 1: Production/Active Development Projects

### CyberFlash-Tool
- **Path:** `CyberFlash-Tool/`
- **Type:** Python (PySide6 Desktop Application)
- **Status:** ✅ Production
- **Files:** 370 | Size: 4.2M
- **Main Files:** 
  - `pyproject.toml` (poetry)
  - `requirements.txt`
  - `docs/`, `tests/`, `src/`
- **Documentation:** README.md ✅, No CHANGELOG ❌
- **License:** Check LICENSE
- **Dependencies:** PySide6, security libs
- **Recommended Actions:**
  - Add CHANGELOG.md
  - Run `pip-audit`
  - Add GitHub Actions CI/CD

### OmniSec (Mobile Security Framework)
- **Path:** `OmniSec/`
- **Type:** Multi-stack (Python + Node.js + Docker + Ansible)
- **Status:** ✅ Production
- **Files:** 1,241 | Size: 9.4M
- **Components:**
  - `/platform/` — Python backend (pyproject.toml)
  - `/website/` — Node.js frontend (package.json)
  - `/plugins/` — Extension system
  - `/ansible/` — Deployment automation
  - `/Dockerfile` (multi-stage)
- **Documentation:** README.md ✅, Architecture docs ✅
- **License:** Check LICENSE
- **Key Issues:**
  - Multiple requirement.txt files (36 total across workspace)
  - Docker base images need audit
  - Node deps need lock files
- **Recommended Actions:**
  - Add CHANGELOG.md
  - Standardize Node.js config
  - Document API endpoints

### Zen-Ai-Pentest
- **Path:** `hacking/ai-pentesting/Zen-Ai-Pentest/`
- **Type:** Complex Python multi-component framework
- **Status:** ⚠️ Active but scattered
- **Files:** Large (multiple pyproject.toml across subdirs)
- **Components (8+ pyproject.toml):**
  - `/cli/` — CLI tool
  - `/api/` — REST API
  - `/agent_spawning_poc/` — POC
  - `/dashboard/` — UI (Node.js)
  - `/cloudflare/` — Integration
  - `/web_ui/` — Full frontend
  - `/zen_shield/` — Module
  - `/k8s/` — Kubernetes operator
- **Documentation:** Limited, scattered
- **Issues:**
  - Over-nested structure
  - Multiple package.json (6 detected)
  - node_modules committed to git
  - No central documentation
- **Recommended Actions:**
  - Refactor to cleaner structure
  - Consolidate pyproject.toml
  - Remove node_modules from git
  - Create architecture.md

### pwntools (Exploit Development)
- **Path:** `hacking/exploit-dev/pwntools/`
- **Type:** Python + Docker
- **Status:** ✅ Production (external framework)
- **Files:** Multiple
- **Components:**
  - `pyproject.toml`
  - `extra/docker/` — 5 Dockerfiles
  - `tests/` — test coverage
  - `docs/` — documentation
- **Documentation:** ✅ Good
- **License:** BSD/MIT
- **Recommended Actions:**
  - Add to dependency scanning
  - Verify Docker base images (5 total)

### metasploit-framework
- **Path:** `hacking/ai-pentesting/metasploit-framework/`
- **Type:** Ruby + Docker (massive framework)
- **Status:** ✅ Reference/Forked version
- **Files:** 8,218+ Ruby files
- **Components:**
  - Core exploits (Ruby)
  - Docker configs (12+ Dockerfiles)
  - Test infrastructure
  - Documentation
- **Special Considerations:**
  - Ruby dependencies (not audited yet)
  - Large Docker footprint
  - Production usage likely
- **Recommended Actions:**
  - Add Ruby vulnerability scanning
  - Audit all Docker base images

### volatility3 (Memory Forensics)
- **Path:** `hacking/forensics/volatility3/`
- **Type:** Python framework
- **Status:** ✅ Reference/Forked
- **Files:** Multiple
- **Structure:** Professional layout
- **Recommended Actions:**
  - Add to dependency scanning
  - Document API usage

---

## Tier 2: Active Sub-Projects

### Nettacker (Network Security)
- **Path:** `hacking/ai-pentesting/Nettacker/`
- **Type:** Python + Docker
- **Components:** pyproject.toml, Dockerfile
- **Action:** Add to CI/CD, run pip-audit

### blacksmith (AI Security)
- **Path:** `hacking/ai-pentesting/blacksmith/`
- **Type:** Python (blacksmithAI) + React frontend
- **Components:** 2x pyproject.toml, 2x Dockerfile, package.json
- **Action:** Consolidate structure

### NeuroSploit
- **Path:** `hacking/ai-pentesting/NeuroSploit/`
- **Type:** Python + React
- **Components:** pyproject.toml, frontend/package.json
- **Action:** Standardize

### red-run (Automated Red Teaming)
- **Path:** `hacking/ai-pentesting/red-run/`
- **Type:** Multi-module Python framework
- **Components:** 7x pyproject.toml (tools/*)
- **Action:** Consider consolidation

---

## Tier 3: Reference/Integration Projects

### awesome-lists (Security References)
- **Path:** `awesome-lists/`
- **Type:** Documentation/Curated lists
- **Files:** 828 | Size: 229M
- **Sub-categories:** h4cker/networking/security/post-quantum
- **Status:** Reference/Documentation only
- **Issues:** Large, contains duplicate references
- **Action:** Consolidate, migrate to knowledge base

### arch-linux (Distro Packaging)
- **Path:** `arch-linux/`
- **Type:** Arch Linux packaging + ArchStrike repo
- **Files:** 8,798 | Size: 142M
- **Main:** `/usb-portable/ArchStrike/` (6000+ PKGBUILD)
- **Components:** 
  - ArchStrike packages (security tools)
  - BlackArch integration
  - ISO customization
- **Status:** Reference/Template
- **Issues:** Massive PKGBUILD collection, versioning unclear
- **Action:** Document build process, create CI/CD for package updates

### hacking/post-quantum (Post-Quantum Cryptography)
- **Path:** `hacking/post-quantum/`
- **Type:** Multiple frameworks (PQClean, MLA, etc.)
- **Files:** 100+ per project
- **Components:** C/C++/Python implementations, Makefiles
- **Status:** Reference/Research
- **Action:** Add to security audit for cryptographic implementations

### hacking/exploit-dev (Exploitation Tools)
- **Path:** `hacking/exploit-dev/`
- **Type:** Collection of exploit frameworks
- **Sub-projects:** pwntools, pwndbg, Certipy (PowerShell), etc.
- **Status:** Mixed (production + reference)
- **Action:** Categorize and audit each

### hacking/web-exploitation
- **Path:** `hacking/web-exploitation/`
- **Type:** Web pentesting frameworks
- **Components:** TIDoS-Framework + others
- **Action:** Document and audit

---

## Tier 4: Configuration/Infrastructure

### OmniSec/platform (Backend)
- **Type:** Python backend + database
- **Path:** `OmniSec/platform/`
- **Key:** `/gui/modules/password_auditor.py`

### OmniSec/ansible (Deployment)
- **Type:** Ansible playbooks
- **Path:** `OmniSec/ansible/`

### linux-omnisec (Distro Config)
- **Path:** `linux-omnisec/`
- **Type:** Arch Linux distro + REUSE.toml (LICENSE MODEL)
- **Files:** 39 | Size: 2.4M
- **Special:** Only project using REUSE specification ✅
- **Action:** Use as template for license compliance

### android (Mobile Projects)
- **Path:** `android/`
- **Type:** Android app (vault-android16)
- **Files:** 302 | Size: 6.7M
- **Status:** Research/Development
- **Issue:** No README
- **Action:** Add documentation

---

## Dependency Summary

### Python Ecosystem (22 projects)
**Top Python Projects Requiring Audit:**
1. CyberFlash-Tool/pyproject.toml
2. OmniSec/platform/pyproject.toml
3. Zen-Ai-Pentest/pyproject.toml (main)
4. Zen-Ai-Pentest/cli/pyproject.toml
5. blacksmith/blacksmithAI/pyproject.toml
6. Nettacker/pyproject.toml
7. NeuroSploit/pyproject.toml
8. volatility3/pyproject.toml
9. pwntools/pyproject.toml

**Action:** Run automated scan:
```bash
for f in $(find . -name pyproject.toml); do
  echo "=== $(dirname $f) ==="
  pip-audit --desc --ignore 12345 "$(dirname $f)" 2>/dev/null
done
```

### Node.js Ecosystem (13 projects)
**Top Projects:**
1. OmniSec/website/package.json
2. Zen-Ai-Pentest/web_ui/frontend/package.json (ISSUE: node_modules committed)
3. blacksmith/frontend/package.json
4. NeuroSploit/frontend/package.json
5. Zen-Ai-Pentest/dashboard/package.json
6. zero-trust/opennhp packages

**Action:** 
```bash
for pkg in $(find . -name package.json ! -path '*/node_modules/*'); do
  npm audit --audit-level=moderate "$(dirname $pkg)"
done
```

### Docker (34 Dockerfiles)
**Base Images to Verify:**
- OmniSec/* — 2 Dockerfiles
- Zen-Ai-Pentest/* — 8 Dockerfiles  
- metasploit-framework/* — 5 Dockerfiles
- pwntools/* — 6 Dockerfiles
- Others — 13 Dockerfiles

**Action:** Audit base image versions
```bash
for df in $(find . -name Dockerfile); do
  echo "=== $(dirname $df) ==="
  grep "^FROM" "$df"
done | sort | uniq -c
```

### Go Modules (6 total)
- zero-trust/opennhp/* — 6 go.mod files
- All in zero-trust networking context

---

## Statistics Summary

| Category | Count | Status |
|----------|-------|--------|
| **Total Projects** | 25+ | Mixed maturity |
| **Tier 1 Projects** | 6 | Production-ready |
| **Tier 2 Projects** | 4 | Active dev |
| **Tier 3 Projects** | 8+ | Reference |
| **Python Projects** | 22 | Need audit |
| **Node Projects** | 13 | Partial audit |
| **Docker Images** | 34 | Need audit |
| **Go Modules** | 6 | Not scanned |
| **Shell Scripts** | 426 | ✅ Well-formed |
| **Total Files** | 46,359 | Organized |
| **Total Size** | 1.7GB | Manageable |

---

## Cross-Project Dependencies

### Known Integrations
- **OmniSec** depends on/integrates:
  - `hacking/ai-pentesting/` modules
  - `hacking/exploit-dev/pwntools`
  
- **Zen-Ai-Pentest** uses:
  - Metasploit framework (embedded copy)
  - Multiple backend services

- **arch-linux** packages include:
  - Tools from `hacking/` subdirs

---

## Maintenance Owners (Recommended)

| Project | Owner | Frequency |
|---------|-------|-----------|
| CyberFlash-Tool | @lead | Weekly |
| OmniSec | @lead | Weekly |
| Zen-Ai-Pentest | @ai-team | Bi-weekly |
| metasploit-framework | @framework-team | Monthly (upstream track) |
| hacking/* | @research-team | As-needed |
| arch-linux | @devops | Monthly |
| awesome-lists | @community | Monthly |

---

**Generated:** May 13, 2026  
**For detailed audit findings, see:** AUDIT_SUMMARY.md
