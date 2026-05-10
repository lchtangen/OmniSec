---
agent: "agent"
description: "Audit and harden device-side scripts for Android shell compatibility and safety"
---

Audit and harden a device-side script in OmniSec.

Target file(s): ${input:targets:Provide one or more target paths}
Threat or reliability concern: ${input:concern:What should be improved?}

Checklist:

1. Confirm script portability for `#!/system/bin/sh`.
2. Remove fragile assumptions about `PATH`, shell features, and tool availability.
3. Improve quoting, input validation, and failure handling.
4. Preserve user-visible behavior unless a safety bug requires change.
5. Summarize hardening changes with rationale and possible runtime impact.

Validation:
- run applicable lint/test commands for the touched scope
- include any follow-up checks to run on-device
