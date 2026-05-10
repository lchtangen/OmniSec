---
name: release-readiness
description: Prepare and validate OmniSec release changes across versioning, build artifacts, and CI expectations.
argument-hint: "[version or release scope]"
---

# Release readiness skill

Use this skill for release prep or release PR hardening.

## Checklist

1. Confirm version metadata consistency:
   - `VERSION.md`
   - `package.json`
   - deploy/module metadata
2. Run quality gates:

```bash
make lint
make test
```

3. Ensure release workflows still align with artifact paths.
4. Summarize release risk by impact area:
   - host scripts
   - device payload
   - native helpers
   - CI/release automation
