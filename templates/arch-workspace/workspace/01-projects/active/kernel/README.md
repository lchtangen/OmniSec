<!-- NH_SETUP_VERSION: 2.0 default -->
<!-- Profile: Arch ARM64 v2.0 default; Kali ARM64 v2.0 default -->

# Kernel Project

Goal: build a reproducible OnePlus 7 Pro SM8150 kernel workflow.

## First Milestones

1. Back up boot-related partitions.
2. Record rollback steps.
3. Mirror source.
4. Build unchanged source.
5. Add NetHunter-related features one patch at a time.

## Paths

```text
source: /workspace/02-source/kernel
build: /workspace/03-build/kernel
artifacts: /workspace/07-artifacts/kernels
boot backups: /workspace/07-artifacts/boot-images
docs: /workspace/06-docs/kernel
```

