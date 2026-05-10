---
name: security-review-shell-and-device
description: Perform a focused security review of OmniSec host/device shell changes.
argument-hint: "[changed files or feature area]"
agent: "agent"
---

Perform a high-signal security review for the OmniSec shell/device change set:

Scope: ${input:scope:Describe changed files or command area}

Review focus:

1. Shell injection and unsafe quoting risks.
2. Privilege and boundary issues (host, Android root, chroot).
3. Silent-failure behavior that can hide security problems.
4. Compatibility hazards for `/system/bin/sh` scripts.

Return:
- confirmed findings only
- severity and impact
- minimum safe remediation per finding
