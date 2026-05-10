# C Code Review Skill

Review C code for OmniSec Native helper compatibility and safety.

## When to use
- Writing or modifying `src/c/*.c` files
- Creating C unit tests in `tests/*.c`

## Checklist
1. C17 standard, static linking maintained
2. No glibc-only assumptions (Android/Bionic compatible)
3. `-Wall -Wextra -pedantic` clean
4. No unsafe functions (strcpy, sprintf, gets)
5. Bounds-checked string/buffer operations
6. Consistent error return patterns
7. No memory leaks or use-after-free
