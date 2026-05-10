---
agent: "agent"
description: "Run OmniSec-focused quality checks and summarize fix-ready findings"
---

You are validating a change in the OmniSec repository.

Change scope: ${input:scope:What changed?}

Follow this sequence:

1. Run the primary project quality gates from repo root:
   - `make lint`
   - `make test`
2. If failures occur, identify root causes and propose minimal, behavior-safe fixes.
3. For each issue, include:
   - failing command or check
   - likely cause
   - smallest safe remediation
4. End with a concise risk summary for merging.

Constraints:
- Do not suggest unrelated refactors.
- Keep recommendations aligned with current repository structure and script conventions.
