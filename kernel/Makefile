SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

KERNEL_DIR := $(CURDIR)
BUILD_DIR := $(CURDIR)/../build/kernel
DIST_DIR := $(CURDIR)/../dist/kernel

DEVICE := GM1911
DEVICE_CODENAME := guacamole
ANDROID_VERSION := 16
LINEAGE_VERSION := 23.2
KERNEL_VERSION := 4.14.356

CROSS_COMPILE ?= aarch64-linux-gnu-

KERNEL_SRC ?= $(CURDIR)/src/$(DEVICE_CODENAME)
OUT_DIR := $(BUILD_DIR)/out
MODULES_DIR := $(BUILD_DIR)/modules
DTB_DIR := $(BUILD_DIR)/dtbs

.PHONY: all
all: kernel modules dtbs

.PHONY: checkout
checkout:
	@echo "--- Cloning LineageOS kernel source ---"
	@if [ ! -d "$(KERNEL_SRC)" ]; then \
		mkdir -p "$(CURDIR)/src"; \
		cd "$(CURDIR)/src"; \
		git clone --depth=1 \
			https://github.com/LineageOS/android_kernel_oneplus_sm8150.git \
			$(DEVICE_CODENAME); \
	fi

.PHONY: defconfig
defconfig: checkout
	@echo "--- Applying defconfig ---"
	mkdir -p "$(OUT_DIR)"
	cp "$(CURDIR)/configs/$(DEVICE_CODENAME)_defconfig" "$(KERNEL_SRC)/arch/arm64/configs/"
	$(MAKE) -C "$(KERNEL_SRC)" \
		O="$(OUT_DIR)" \
		ARCH=arm64 \
		CROSS_COMPILE="$(CROSS_COMPILE)" \
		$(DEVICE_CODENAME)_defconfig

.PHONY: kernel
kernel: defconfig
	@echo "--- Building kernel ---"
	$(MAKE) -C "$(KERNEL_SRC)" \
		O="$(OUT_DIR)" \
		ARCH=arm64 \
		CROSS_COMPILE="$(CROSS_COMPILE)" \
		-j$$(nproc) \
		Image.gz dtbs

.PHONY: modules
modules: kernel
	@echo "--- Building modules ---"
	$(MAKE) -C "$(KERNEL_SRC)" \
		O="$(OUT_DIR)" \
		ARCH=arm64 \
		CROSS_COMPILE="$(CROSS_COMPILE)" \
		-j$$(nproc) \
		modules
	$(MAKE) -C "$(KERNEL_SRC)" \
		O="$(OUT_DIR)" \
		ARCH=arm64 \
		CROSS_COMPILE="$(CROSS_COMPILE)" \
		INSTALL_MOD_PATH="$(MODULES_DIR)" \
		modules_install

.PHONY: dtbs
dtbs: kernel
	@echo "--- Building DTBs ---"
	mkdir -p "$(DTB_DIR)"
	cp "$(OUT_DIR)/arch/arm64/boot/dts/qcom/"*.dtb "$(DTB_DIR)/" 2>/dev/null || true

.PHONY: anykernel3
anykernel3: kernel modules dtbs
	@echo "--- Packaging AnyKernel3 zip ---"
	mkdir -p "$(DIST_DIR)"
	if [ -d "$(KERNEL_SRC)/anykernel" ]; then \
		cd "$(KERNEL_SRC)/anykernel"; \
		cp "$(OUT_DIR)/arch/arm64/boot/Image.gz" .; \
		cp -r "$(DTB_DIR)/"* . 2>/dev/null || true; \
		zip -r "$(DIST_DIR)/kernel-$(DEVICE_CODENAME)-$(KERNEL_VERSION).zip" .; \
	fi

.PHONY: boot-image
boot-image: kernel
	@echo "--- Building boot image ---"
	@if command -v mkbootimg &>/dev/null; then \
		mkbootimg \
			--kernel "$(OUT_DIR)/arch/arm64/boot/Image.gz" \
			--dtb "$(OUT_DIR)/arch/arm64/boot/dts/qcom/sm8150.dtb" \
			--base 0x80000000 \
			--pagesize 4096 \
			--ramdisk_offset 0x01000000 \
			--tags_offset 0x00000100 \
			--os_version "$(ANDROID_VERSION).0.0" \
			--os_patch_level 2026-05 \
			-o "$(DIST_DIR)/boot-$(DEVICE_CODENAME)-$(KERNEL_VERSION).img"; \
		echo "  boot image: $(DIST_DIR)/boot-$(DEVICE_CODENAME)-$(KERNEL_VERSION).img"; \
	else \
		echo "  mkbootimg not found, skipping boot image"; \
	fi

.PHONY: clean
clean:
	rm -rf "$(BUILD_DIR)"

.PHONY: distclean
distclean: clean
	rm -rf "$(CURDIR)/src"

.PHONY: toolchain
toolchain:
	@echo "--- Checking toolchain ---"
	@if command -v $(CROSS_COMPILE)gcc &>/dev/null; then \
		echo "  toolchain: $(CROSS_COMPILE)gcc"; \
		$(CROSS_COMPILE)gcc --version | head -1; \
	else \
		echo "  toolchain not found. Install: sudo apt install gcc-aarch64-linux-gnu"; \
		exit 1; \
	fi

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*#' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS=":.*?# "}; {printf "  make %-15s %s\n", $$1, $$2}'
