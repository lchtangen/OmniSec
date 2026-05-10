---
name: ci-failure-triage
description: Triage OmniSec workflow failures and map to smallest safe fix.
argument-hint: "[workflow/job/failure detail]"
agent: "agent"
---

Triage this OmniSec CI/workflow failure:

${input:failure_context:Paste failing workflow/job step and error output}

Process:

1. Identify failing stage and failing command.
2. Derive equivalent local reproduction commands.
3. Isolate likely root cause to exact files.
4. Propose minimal safe remediation.
5. Provide a short re-run sequence.

Keep recommendations aligned with existing project conventions and quality gates.
