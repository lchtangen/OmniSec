SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

NH_VERSION := 2.0.0
DEVICE := GM1911
DEVICE_CODENAME := guacamole
ANDROID_VERSION := 16
LINEAGE_VERSION := 23.2
KERNEL_VERSION := 4.14.356

CROSS_COMPILE ?= aarch64-linux-gnu-
BUILD_SCRIPT := ./build-kernel.sh

.PHONY: all
all: build-nethunter

# ── Build Variants ─────────────────────────────────────────────────
.PHONY: build-stable build-performance build-battery build-nethunter build-debug build-minimal

build-stable:
	$(BUILD_SCRIPT) build $(DEVICE_CODENAME) stable

build-performance:
	$(BUILD_SCRIPT) build $(DEVICE_CODENAME) performance

build-battery:
	$(BUILD_SCRIPT) build $(DEVICE_CODENAME) battery

build-nethunter:
	$(BUILD_SCRIPT) build $(DEVICE_CODENAME) nethunter

build-debug:
	$(BUILD_SCRIPT) build $(DEVICE_CODENAME) debug

build-minimal:
	$(BUILD_SCRIPT) build $(DEVICE_CODENAME) minimal

# ── Matrix Builds ─────────────────────────────────────────────────
.PHONY: matrix matrix-all

matrix: build-stable build-nethunter build-performance
	@echo "  matrix build complete"

matrix-all:
	$(BUILD_SCRIPT) all $(DEVICE_CODENAME)

# ── Component Builds ──────────────────────────────────────────────
.PHONY: kernel modules config

kernel:
	$(BUILD_SCRIPT) kernel $(DEVICE_CODENAME) $(VARIANT)

modules:
	$(BUILD_SCRIPT) modules $(DEVICE_CODENAME) $(VARIANT)

config:
	$(BUILD_SCRIPT) config $(DEVICE_CODENAME) $(VARIANT)

# ── Source Management ─────────────────────────────────────────────
.PHONY: checkout update

checkout:
	$(BUILD_SCRIPT) build $(DEVICE_CODENAME) stable 2>&1 | head -5

update:
	$(BUILD_SCRIPT) distclean $(DEVICE_CODENAME)
	$(BUILD_SCRIPT) build $(DEVICE_CODENAME) stable

# ── Toolchain ─────────────────────────────────────────────────────
.PHONY: toolchain

toolchain:
	$(BUILD_SCRIPT) toolchain

# ── Packaging ─────────────────────────────────────────────────────
.PHONY: package dist

package:
	@echo "  packages are created automatically during build"
	@ls -la dist/

dist: matrix-all
	@echo "  distribution: dist/"

# ── CI/CD ─────────────────────────────────────────────────────────
.PHONY: ci

ci:
	$(BUILD_SCRIPT) ci $(DEVICE_CODENAME)

# ── Testing ───────────────────────────────────────────────────────
.PHONY: test

test:
	$(BUILD_SCRIPT) test

# ── Cleanup ───────────────────────────────────────────────────────
.PHONY: clean distclean

clean:
	$(BUILD_SCRIPT) clean $(DEVICE_CODENAME)

distclean:
	$(BUILD_SCRIPT) distclean $(DEVICE_CODENAME)

# ── Help ──────────────────────────────────────────────────────────
.PHONY: help

help:
	@echo "NetHunter NextGen Kernel Build System v$(NH_VERSION)"
	@echo ""
	@echo "Targets:"
	@echo "  make build-stable       Build stable (daily driver) variant"
	@echo "  make build-nethunter    Build nethunter (full security) variant"
	@echo "  make build-performance  Build performance-tuned variant"
	@echo "  make build-battery       Build battery-optimized variant"
	@echo "  make build-debug        Build debug/development variant"
	@echo "  make build-minimal      Build minimal variant"
	@echo ""
	@echo "  make matrix             Build stable + nethunter + performance"
	@echo "  make matrix-all         Build ALL variants"
	@echo "  make ci                 CI/CD pipeline build"
	@echo ""
	@echo "  make kernel  VARIANT=nethunter  Build kernel image only"
	@echo "  make modules VARIANT=nethunter  Build modules only"
	@echo "  make config  VARIANT=nethunter  Generate config only"
	@echo ""
	@echo "  make checkout           Clone kernel source"
	@echo "  make update             Refresh source and rebuild"
	@echo "  make toolchain          Set up NDK toolchain"
	@echo "  make test               Run build system tests"
	@echo "  make clean              Clean build output"
	@echo "  make distclean          Clean everything"
	@echo "  make help               Show this message"
	@echo ""
	@echo "Device: $(DEVICE_CODENAME) ($(DEVICE))"
	@echo "Kernel: $(KERNEL_VERSION) / Android: $(ANDROID_VERSION)"
	@echo "Lineage: $(LINEAGE_VERSION) / NH: $(NH_VERSION)"
