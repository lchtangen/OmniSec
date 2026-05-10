---
agent: "agent"
description: "Generate BATS or C unit tests for OmniSec shell scripts and C helpers"
---

You are generating tests for the OmniSec project.

Target: ${input:target:Script or C source to test}
Test type: ${input:type:Select test framework} (BATS / C unit test)

## For BATS Tests

Look at `tests/test_scripts.bats` and `tests/helpers.bash` for existing patterns.

Generate tests that cover:

### Shell Script Tests
1. **Help/usage**: Running with `--help` or no args returns usage and exits 0/1
2. **Error handling**: Invalid args produce clear error messages and non-zero exit
3. **Happy path**: Core functionality works with valid inputs
4. **Edge cases**: Empty input, missing deps, unusual arguments
5. **Root checks**: Scripts that require root fail gracefully when not root

### Test Template
```bash
# bats test_tags=category:feature
@test "nh-command: short description of behavior" {
    run ./nhctl command args
    [ "$status" -eq 0 ]
    [[ "$output" == *"expected string"* ]]
}
```

## For C Unit Tests

Look at `tests/test_nh_sudo.c` for existing patterns.

Generate tests that cover:
1. **Function-level**: Each public function with valid/invalid inputs
2. **Error returns**: NULL input, OOM, syscall failures return expected errors
3. **Edge cases**: Boundary values, empty buffers, max lengths
4. **Integration**: Combined operations exercise full code paths

### Test Template
```c
static int test_feature_name(void) {
    // setup
    // exercise
    // assert
    // cleanup
    return 0; // or 1 on failure
}
```

## Coverage Targets
- Line coverage: >80% for new code
- Branch coverage: >70% for conditional logic
- Error path coverage: 100% for all error returns

## Validation
- [ ] All tests pass with `make test`
- [ ] No tests produce false positives (verify by deliberately breaking the code)
- [ ] Tests use `helpers.bash` and existing test infrastructure
- [ ] Tests clean up after themselves (no state leak between tests)
