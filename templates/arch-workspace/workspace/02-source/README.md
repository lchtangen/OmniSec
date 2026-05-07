<!-- NH_SETUP_VERSION: 2.0 default -->
<!-- Profile: Arch ARM64 v2.0 default; Kali ARM64 v2.0 default -->

# Source Trees

This directory is for upstream or forked source repositories.

Keep source trees separate from build outputs so clean rebuilds are easy.

## Suggested Use

```text
android/      AOSP, LineageOS, Android app source
kernel/       OnePlus 7 Pro / SM8150 kernel trees
nethunter/    NetHunter app, installer, kernel patch references
arch/         Arch packaging, PKGBUILDs, local package recipes
linux/        generic Linux references
external/     third-party projects cloned for study
mirrors/      local mirrors of important repos
```

## Rule

Do not build large source trees in place when an out-of-tree build directory is supported. Use `/workspace/03-build`.

