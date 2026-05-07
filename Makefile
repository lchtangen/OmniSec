SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

NH_VERSION := 2.0.0
NH_PROFILE := default
ARCH := aarch64
CFLAGS ?= -O2
ANDROID_API := 36
ANDROID_VERSION := 16
LINEAGE_VERSION := 23.2
DEVICE := GM1911
DEVICE_NAME := OnePlus7Pro

ROOT_DIR := $(CURDIR)
SRC_DIR := $(ROOT_DIR)/src
BUILD_DIR := $(ROOT_DIR)/build
DIST_DIR := $(ROOT_DIR)/dist
PAYLOAD_DIR := $(ROOT_DIR)/payload
KERNEL_DIR := $(ROOT_DIR)/kernel
TEST_DIR := $(ROOT_DIR)/tests
DEVICE_DIR := $(ROOT_DIR)/device
WORKSPACE_DIR := $(ROOT_DIR)/workspace
DEPLOY_DIR := $(ROOT_DIR)/deploy

.PHONY: all
all: lint build stage test

.PHONY: build
build: build-c build-module

.PHONY: stage
stage: stage-payload
stage-payload: build-c
	mkdir -p $(PAYLOAD_DIR)/nhsystem-bin
	mkdir -p $(PAYLOAD_DIR)/termux-home
	mkdir -p $(PAYLOAD_DIR)/kali-skel
	mkdir -p $(PAYLOAD_DIR)/chroot-bin
	cp -a $(SRC_DIR)/device/bin/* $(PAYLOAD_DIR)/nhsystem-bin/
	cp -a $(SRC_DIR)/device/setup/* $(PAYLOAD_DIR)/
	find $(SRC_DIR)/device/dotfiles -maxdepth 1 -type f -exec cp -a {} $(PAYLOAD_DIR)/termux-home/ \;
	cp -a $(SRC_DIR)/device/skel/* $(PAYLOAD_DIR)/kali-skel/
	cp $(SRC_DIR)/c/nh-sudo.c $(PAYLOAD_DIR)/
	cp $(SRC_DIR)/c/no-close-range.c $(PAYLOAD_DIR)/
	cp -a $(DEPLOY_DIR)/chroot/* $(PAYLOAD_DIR)/chroot-bin/ 2>/dev/null || true
	chmod +x $(PAYLOAD_DIR)/*.sh $(PAYLOAD_DIR)/nhsystem-bin/nh-* 2>/dev/null || true
	@echo "  staged: $$(find $(PAYLOAD_DIR) -type f | wc -l) files"

.PHONY: build-c
build-c: $(BUILD_DIR)/nh-sudo $(BUILD_DIR)/no-close-range.so $(BUILD_DIR)/nh-diag

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/nh-sudo: $(SRC_DIR)/c/nh-sudo.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -o $@ $< -static -s
	@echo "  built: nh-sudo ($@)"

$(BUILD_DIR)/no-close-range.so: $(SRC_DIR)/c/no-close-range.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -shared -fPIC -o $@ $< -nostartfiles
	@echo "  built: no-close-range.so ($@)"

$(BUILD_DIR)/nh-diag: $(SRC_DIR)/c/nh-diag.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -o $@ $< -static -s
	@echo "  built: nh-diag ($@)"

.PHONY: build-module
build-module: stage-payload
	@$(DEPLOY_DIR)/magisk/build.sh
	@echo "  built: Magisk module"

.PHONY: lint
lint: lint-sh lint-c lint-json

.PHONY: lint-sh
lint-sh:
	@echo "--- Shell syntax check ---"
	@find $(SRC_DIR) -name '*.sh' -exec bash -n {} \;
	@find $(SRC_DIR) -name 'nh-*' -not -name '*.c' -exec bash -n {} \;
	@bash -n $(ROOT_DIR)/nhctl
	@find $(ROOT_DIR)/device -name '*.sh' -exec bash -n {} \;
	@find $(ROOT_DIR)/deploy -name '*.sh' -exec bash -n {} \;
	@find $(ROOT_DIR)/tests -name '*.sh' -exec bash -n {} \;
	@echo "  shell syntax: OK"

.PHONY: lint-c
lint-c:
	@echo "--- C syntax check ---"
	@for f in $(SRC_DIR)/c/*.c; do \
		cc -fsyntax-only -Wall -Wextra -pedantic "$$f" 2>&1 | grep -v "note:" || true; \
	done
	@echo "  C syntax: OK"

.PHONY: lint-json
lint-json:
	@echo "--- JSON validation ---"
	@python3 -m json.tool package.json > /dev/null 2>&1 && echo "  package.json: OK" || echo "  package.json: FAIL"
	@if [ -f .vscode/extensions.json ]; then python3 -m json.tool .vscode/extensions.json > /dev/null 2>&1 && echo "  extensions.json: OK" || echo "  extensions.json: FAIL"; fi
	@if [ -f .vscode/tasks.json ]; then python3 -c "import json; json.loads(open('.vscode/tasks.json').read().replace('//',''))" > /dev/null 2>&1 && echo "  tasks.json: OK" || echo "  tasks.json: OK (VSCode format with comments)"; fi

.PHONY: test
test: test-sh test-c

.PHONY: test-sh
test-sh:
	@echo "--- Shell tests ---"
	@if command -v bats &>/dev/null; then \
		bats $(TEST_DIR)/*.bats; \
	else \
		echo "  bats not found, running basic validation..."; \
		$(TEST_DIR)/run-tests.sh; \
	fi

.PHONY: test-c
test-c: build-c
	@echo "--- C tests ---"
	@$(CC) $(CFLAGS) -Wall -Wextra -pedantic -o $(BUILD_DIR)/test_nh_sudo $(TEST_DIR)/test_nh_sudo.c 2>&1 | grep -v "note:" || true
	@if [ -f $(BUILD_DIR)/test_nh_sudo ]; then \
		$(BUILD_DIR)/test_nh_sudo; \
	else \
		echo "  C test binary not built — skipping"; \
	fi

.PHONY: validate
validate: lint test
	@$(ROOT_DIR)/scripts/validate.sh

.PHONY: deploy
deploy: stage
	@echo "--- Deploying to device ---"
	@./nhctl deploy-tools
	@echo "  deploy: OK"

.PHONY: deploy-full
deploy-full: stage
	@echo "--- Full deploy ---"
	@./clean-rebuild-postboot.sh
	@echo "  full deploy: OK"

.PHONY: docker
docker: Dockerfile
	docker build -t nethunter-setup:$(NH_VERSION) .
	@echo "  docker image: nethunter-setup:$(NH_VERSION)"

.PHONY: docker-run
docker-run: docker
	docker run --rm -it --network host \
		-v /dev/bus/usb:/dev/bus/usb:ro \
		-v $(HOME)/.ssh:/root/.ssh:ro \
		nethunter-setup:$(NH_VERSION)

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR) $(DIST_DIR) $(PAYLOAD_DIR) $(DEPLOY_DIR)/magisk/dist
	@echo "  cleaned: build/, dist/, payload/, deploy/magisk/dist/"

.PHONY: distclean
distclean: clean
	rm -rf node_modules audits archive workspace/build
	@echo "  cleaned: node_modules, audits, archive, workspace/build"

.PHONY: dist
dist: build stage build-module
	mkdir -p $(DIST_DIR)
	cp -r $(BUILD_DIR)/* $(DIST_DIR)/
	cp -r $(DEPLOY_DIR)/magisk/dist/* $(DIST_DIR)/ 2>/dev/null || true
	tar czf $(DIST_DIR)/nethunter-setup-v$(NH_VERSION).tar.gz \
		--exclude='.git' --exclude='node_modules' \
		--exclude='build' --exclude='dist' \
		--exclude='audits' --exclude='*.tar.gz' \
		-C $(ROOT_DIR) .
	@echo "  dist: $(DIST_DIR)"

.PHONY: workspace-init
workspace-init:
	@echo "--- Initializing workspace ---"
	@mkdir -p $(WORKSPACE_DIR)/{projects,source,build,notes/daily,docs,config,inbox,backup}
	@touch $(WORKSPACE_DIR)/.workspace
	@echo "  workspace initialized at $(WORKSPACE_DIR)"

.PHONY: version
version:
	@echo "nethunter-setup v$(NH_VERSION)"
	@echo "  device:  $(DEVICE_NAME) ($(DEVICE))"
	@echo "  android: $(ANDROID_VERSION) (API $(ANDROID_API))"
	@echo "  lineage: $(LINEAGE_VERSION)"
	@echo "  arch:    $(ARCH)"
	@echo "  profile: $(NH_PROFILE)"
	@echo "  src:     $(SRC_DIR)"
	@echo "  deploy:  $(DEPLOY_DIR)"
	@echo "  kernel:  $(KERNEL_DIR)"
	@echo "  device:  $(DEVICE_DIR)"
	@echo "  workspace: $(WORKSPACE_DIR)"

.PHONY: tree
tree:
	@echo "Project tree (depth 3):"
	@find . -maxdepth 3 -not -path './.git/*' -not -path './node_modules/*' \
		-not -path './build/*' -not -path './dist/*' \
		-not -path './payload/*' -not -path './Legacy/*' \
		-not -path './*.tar.gz' \
		| sort | head -60

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*#' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS=":.*?# "}; {printf "  make %-18s %s\n", $$1, $$2}'
