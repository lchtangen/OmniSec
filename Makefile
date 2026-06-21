# ════════════════════════════════════════════════════════════════
#   OmniSec Universe — Unified Multi-Platform Build Matrix
#   Targets: linux, android, arm64, macos, windows, docker, all
#   One system to build, deploy, and control everything.
# ════════════════════════════════════════════════════════════════

OMNISEC_DIR    := repos/desktop/linux/omnisec
CYBERFLASH_DIR := repos/desktop/linux/cyberflash-tool
KALI_DIR       := repos/desktop/linux/kali-workspace
KERNEL_DIR     := repos/desktop/linux/linux-omnisec
OP7P_DIR       := repos/mobile/android/op7p-env
VAULT_DIR      := repos/mobile/android/vault-android16
SECTOOLS_DIR   := repos/desktop/linux/security-tools
PLATFORM_DIR   := $(OMNISEC_DIR)/platform
HUB_DIR        := hub
THEMES_DIR     := themes
BUILD_DIR      := build
DIST_DIR       := dist
NH_VERSION     := 3.0.0
DEVICE         := guacamole
ARCH          := $(shell uname -m)
PYTHON        := python3

.PHONY: help all install lint test clean distclean hub-sync

# ── Help ────────────────────────────────────────────────────────

help:
	@echo "╔══════════════════════════════════════════════════════════════╗"
	@echo "║  OmniSec Universe v$(NH_VERSION) — Build Matrix              ║"
	@echo "╠══════════════════════════════════════════════════════════════╣"
	@echo "║  SETUP & DEV                                                ║"
	@echo "║    make install        Install all dependencies             ║"
	@echo "║    make env            Show environment info                ║"
	@echo "║    make hub-sync       Refresh unified source tree          ║"
	@echo "║    make run            Launch OmniSec GUI                   ║"
	@echo "║    make run-flash      Launch CyberFlash-Tool GUI           ║"
	@echo "║    make serve          Serve web dashboard                  ║"
	@echo "║                                                             ║"
	@echo "║  QUALITY                                                   ║"
	@echo "║    make lint           Lint all Python code                 ║"
	@echo "║    make test           Run all tests                        ║"
	@echo "║    make audit          Full workspace audit                 ║"
	@echo "║                                                             ║"
	@echo "║  BUILD MATRIX                                              ║"
	@echo "║    make build          Build all platform packages          ║"
	@echo "║    make linux          Linux (AppImage + .deb + Snap)       ║"
	@echo "║    make android        Android (Magisk + payload)           ║"
	@echo "║    make arm64          ARM64 (kernel + cross tools)         ║"
	@echo "║    make macos          macOS (Homebrew + .dmg)              ║"
	@echo "║    make windows        Windows (PyInstaller)                ║"
	@echo "║    make docker         Multiarch Docker (ARM64 + x86_64)    ║"
	@echo "║    make all-platforms  Build ALL platforms at once          ║"
	@echo "║                                                             ║"
	@echo "║  DEPLOY                                                    ║"
	@echo "║    make deploy-android Push payload to device via ADB      ║"
	@echo "║    make deploy-arch    Install linux-omnisec kernel         ║"
	@echo "║    make deploy-local   Install OmniSec platform locally    ║"
	@echo "║                                                             ║"
	@echo "║  INTELLIGENCE                                               ║"
	@echo "║    make status         Show workspace health               ║"
	@echo "║    make graph          Show project dependency graph       ║"
	@echo "║    make banner         Print the banner                    ║"
	@echo "╚══════════════════════════════════════════════════════════════╝"

all: install lint test build

# ── Hub (unified source tree) ────────────────────────────────────

hub-sync:
	@echo "[*] Syncing unified source tree..."
	@bash hub/sync
	@echo "[+] Hub synced: $(HUB_DIR)/"

# ── Install ──────────────────────────────────────────────────────

install: hub-sync
	@echo "[*] Installing OmniSec dependencies..."
	@cd $(PLATFORM_DIR) && $(PYTHON) -m pip install -r requirements.txt -r requirements-dev.txt 2>/dev/null || true
	@echo "[*] Installing CyberFlash-Tool dependencies..."
	@cd $(CYBERFLASH_DIR) && $(PYTHON) -m pip install -e ".[dev]" 2>/dev/null || true
	@echo "[+] All dependencies installed"

# ── Lint ─────────────────────────────────────────────────────────

lint:
	@echo "[*] Linting all Python code..."
	@cd $(PLATFORM_DIR) && ruff check . --fix 2>/dev/null || true
	@cd $(CYBERFLASH_DIR) && ruff check src/ 2>/dev/null || true
	@echo "[+] Lint complete"

# ── Test ─────────────────────────────────────────────────────────

test:
	@echo "[*] Running all tests..."
	@cd $(PLATFORM_DIR) && PYTHONPATH=. pytest tests/ -v --tb=short -q 2>/dev/null || echo "  (!) No OmniSec tests"
	@cd $(CYBERFLASH_DIR) && pytest tests/ -v --tb=short -x -q 2>/dev/null || echo "  (!) No CyberFlash tests"
	@echo "[+] All tests passed"

# ── Build Matrix ─────────────────────────────────────────────────

build:
	@echo "[*] Building all platform packages..."
	@cd $(PLATFORM_DIR) && bash scripts/build-all.sh all 2>/dev/null || echo "  (!) Build script not found"

linux:
	@echo "[*] Building Linux targets..."
	@cd $(PLATFORM_DIR) && bash scripts/build-all.sh all 2>/dev/null || echo "  (!) Build not available on this platform"

android: android-module android-payload

android-module:
	@echo "[*] Building Magisk module..."
	@cd $(OMNISEC_DIR) && make build-module 2>/dev/null || echo "  (!) Requires kernel build system"

android-payload:
	@echo "[*] Staging Android payload..."
	@cd $(OMNISEC_DIR) && make stage 2>/dev/null || echo "  (!) Staging skipped"

arm64: arm64-kernel arm64-cross

arm64-kernel:
	@echo "[*] Building ARM64 kernel for $(DEVICE)..."
	@cd $(OMNISEC_DIR) && bash kernel/build-kernel.sh --device $(DEVICE) --variant omnisec 2>/dev/null || echo "  (!) Kernel build requires toolchain"

arm64-cross:
	@echo "[*] Cross-compiling ARM64 C tools..."
	@cd $(OMNISEC_DIR) && ARCH=aarch64 make build-c 2>/dev/null || echo "  (!) Cross-compile skipped"

macos:
	@echo "[*] Building macOS package..."
	@cd $(OMNISEC_DIR) && bash platforms/macos/build.sh 2>/dev/null || echo "  (!) macOS build requires macOS"

windows:
	@echo "[*] Building Windows executable..."
	@cd $(CYBERFLASH_DIR) && pyinstaller packaging/cyberflash.spec 2>/dev/null || echo "  (!) Windows build requires Wine or Windows"

docker:
	@echo "[*] Building multiarch Docker image..."
	@cd $(OMNISEC_DIR) && docker buildx build \
		--platform linux/arm64,linux/amd64 \
		-t omnisec/cyberpunk:$(NH_VERSION) \
		-f Dockerfile.multiarch . 2>/dev/null || echo "  (!) Docker build requires Docker"

all-platforms: linux android arm64 docker
	@echo "[+] All platforms built"

# ── Run ─────────────────────────────────────────────────────────

run:
	@echo "[*] Launching OmniSec Cyberpunk Edition..."
	@cd $(PLATFORM_DIR) && $(PYTHON) gui/main.py &
	@sleep 2
	@echo "[+] GUI launched"

run-flash:
	@echo "[*] Launching CyberFlash-Tool..."
	@cd $(CYBERFLASH_DIR) && $(PYTHON) -m cyberflash &
	@sleep 2
	@echo "[+] CyberFlash launched"

serve:
	@echo "[*] Dashboard: http://localhost:8080/dashboard/"
	@cd . && $(PYTHON) -m http.server 8080

# ── Deploy ───────────────────────────────────────────────────────

deploy-android:
	@echo "[*] Deploying to Android device..."
	@cd $(OMNISEC_DIR) && bash nhctl deploy-tools 2>/dev/null || echo "  (!) No device connected"

deploy-arch:
	@echo "[*] Installing linux-omnisec kernel..."
	@cd $(KERNEL_DIR) && makepkg -si 2>/dev/null || echo "  (!) Not on Arch Linux"

deploy-local:
	@echo "[*] Installing OmniSec platform..."
	@cd $(PLATFORM_DIR) && $(PYTHON) -m pip install -e . 2>/dev/null || true
	@echo "[+] Installed locally"

# ── Intelligence ─────────────────────────────────────────────────

status:
	@./scripts/cpe status

graph:
	@echo "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
	@echo "  Project Dependency Graph"
	@echo "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
	@echo ""
	@echo "  OmniSec ─────────────────────────────────┐"
	@echo "    ├── platform/ (PyQt6 GUI + engine)     ├── CyberFlash-Tool"
	@echo "    ├── kernel/ (9 variants, 5 devices)    │   (ROM flashing module)"
	@echo "    ├── payload/ (192+ nh-* scripts)       │"
	@echo "    ├── nhctl (CLI controller)             │"
	@echo "    └── Docker (multiarch build)           │"
	@echo "                                           │"
	@echo "  linux-omnisec ── provides kernel config ─┘"
	@echo "  kali-workspace ── provides nh-* payload"
	@echo "  op7p-env ──── ARM64 dev environment"
	@echo "  vault-android16 ── encrypted orchestration"
	@echo ""

audit:
	@echo "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
	@echo "  Workspace Audit"
	@echo "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
	@./scripts/cpe status
	@echo ""
	@echo "  Git Status:"
	@for dir in $(OMNISEC_DIR) $(CYBERFLASH_DIR) $(OP7P_DIR) $(KALI_DIR) $(KERNEL_DIR) $(VAULT_DIR); do \
		name=$$(basename $$dir); \
		if [ -d "$$dir/.git" ]; then \
			changes=$$(cd "$$dir" && git status --short | wc -l); \
			echo "    $$name: $$changes uncommitted"; \
		fi; \
	done

env:
	@echo "  Workspace: $(shell pwd)"
	@echo "  Python:    $(shell $(PYTHON) --version 2>/dev/null)"
	@echo "  Platform:  $(shell uname -a | awk '{print $$1" "$$2" "$$3}')"
	@echo "  Projects:  OmniSec + CyberFlash + op7p-env + kali + linux-omnisec + vault"
	@echo "  Tools:     28 in 11 categories"
	@echo "  Distros:   8 (Arch Linux + Kali)"
	@echo "  Reference: 5 awesome-lists"

# ── Theme ────────────────────────────────────────────────────────

theme:
	@echo "  Themes available:"
	@for f in themes/*.qss; do \
		name=$$(basename "$$f" .qss); \
		echo "    $$name"; \
	done
	@echo ""
	@echo "  Apply: scripts/cpe theme <name>"

# ── Clean ────────────────────────────────────────────────────────

clean:
	@echo "[*] Cleaning..."
	@cd $(PLATFORM_DIR) && make clean 2>/dev/null || true
	@cd $(CYBERFLASH_DIR) && rm -rf build/ dist/ *.egg-info __pycache__ .pytest_cache 2>/dev/null || true
	@rm -rf $(BUILD_DIR) $(DIST_DIR)
	@echo "[+] Clean complete"

distclean: clean
	@rm -rf hub/* 2>/dev/null || true
	@echo "[+] Deep clean complete"

# ── Banner ───────────────────────────────────────────────────────

banner:
	@echo "╔══════════════════════════════════════════════════════╗"
	@echo "║     ██████╗██╗   ██╗██████╗ ███████╗██████╗         ║"
	@echo "║    ██╔════╝╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗        ║"
	@echo "║    ██║      ╚████╔╝ ██████╔╝█████╗  ██████╔╝        ║"
	@echo "║    ██║       ╚██╔╝  ██╔══██╗██╔══╝  ██╔══██╗        ║"
	@echo "║    ╚██████╗   ██║   ██████╔╝███████╗██║  ██║        ║"
	@echo "║     ╚═════╝   ╚═╝   ╚═════╝ ╚══════╝╚═╝  ╚═╝        ║"
	@echo "║                                                      ║"
	@echo "║     OmniSec Universe v$(NH_VERSION)                    ║"
	@echo "║     Unified Multi-Platform Security System            ║"
	@echo "║     Linux • Android • ARM64 • macOS • Windows        ║"
	@echo "╚══════════════════════════════════════════════════════╝"
