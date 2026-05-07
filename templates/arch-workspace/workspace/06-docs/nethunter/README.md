<!-- NH_SETUP_VERSION: 2.0 default -->
<!-- Profile: Arch ARM64 v2.0 default; Kali ARM64 v2.0 default -->

# NetHunter Work

NetHunter is a separate milestone after Arch is stable.

## Rules

- Keep Kali/NetHunter separate from Arch daily development.
- Use only authorized targets and your own lab networks.
- Validate services before adding tools.
- Do not let NetHunter experiments break Arch entry or backups.

## First Milestones

1. Install Kali rootfs under `/data/local/nhsystem/roots/kali-arm64`.
2. Validate with `nh-audit`.
3. Validate SSH and KeX.
4. Add custom commands for status, backup, and Wi-Fi checks.

