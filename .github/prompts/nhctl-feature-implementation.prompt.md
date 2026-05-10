---
agent: "agent"
description: "Implement an nhctl feature using OmniSec architecture and safety conventions"
---

Implement an OmniSec feature with `nhctl` as the primary entrypoint.

Feature request: ${input:feature:Describe the feature to implement}

Implementation requirements:

1. Locate the correct source of truth first (prefer `src/` over generated files).
2. If device behavior changes are needed, wire host and device sides consistently:
   - host orchestration (`nhctl`, `src/scripts/**`)
   - device scripts (`src/device/bin/**`, `src/device/setup/**`)
3. Keep output style and command UX consistent with existing `nh-*` tooling.
4. Preserve safe defaults and explicit error handling.
5. Add/update tests where practical and run:
   - `make lint`
   - `make test`

Return:
- files changed
- behavior change summary
- any compatibility notes
