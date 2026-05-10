---
agent: "agent"
description: "Run release-readiness checks across OmniSec AI tooling and quality gates"
---

You are validating release readiness for OmniSec AI operations.

Release scope: ${input:scope:What is part of this release?}

Execute in order:

1. Repository integrity:
   - `./scripts/pre-rename-audit.sh`
   - `./repo-doctor.sh`
2. AI host tooling checks:
   - `./scripts/ai-cli-doctor.sh`
3. Context and command sanity:
   - `./scripts/ai-context-snapshot.sh`
   - `./nhctl ai help`
4. Quality gates:
   - `make lint`
   - `make test`

Output format:

- readiness status: ready | blocked
- blockers (if any)
- minimal remediations
- verification rerun commands
- merge risk summary

Constraints:
- Keep recommendations small and behavior-safe.
- Do not suggest broad refactors.
- Preserve existing OmniSec command names and conventions.
