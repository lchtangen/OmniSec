---
applyTo: ".github/workflows/**/*.yml,.github/workflows/**/*.yaml"
---

# GitHub workflow instructions

- Keep workflow changes minimal and deterministic.
- Prefer pinned major action versions already used in this repository.
- Ensure shell snippets in workflows are non-interactive and fail fast.
- When adding CI checks, mirror existing local commands where possible:
  - `make lint`
  - `make test`
- Avoid adding workflows that require unavailable secrets by default.
- Keep runner choices aligned with repository expectations (Linux-first unless task requires otherwise).
