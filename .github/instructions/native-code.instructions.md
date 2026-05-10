---
applyTo: "src/c/**/*.c,src/c/*.c,tests/**/*.c,tests/*.c"
---

# Native C code instructions

- Keep C changes compatible with the existing build flags used by the project:
  - `-Wall -Wextra -pedantic`
  - static linking for helper binaries where already used.
- Avoid glibc-only assumptions that conflict with Android/Bionic usage.
- Follow existing naming and style in `src/c/`:
  - `snake_case` identifiers
  - clear exit paths and explicit error handling.
- Maintain current ABI/behavior of existing binaries unless the task explicitly requires change.
- When adding new C sources, ensure they integrate with Makefile targets and existing test/build flow.
