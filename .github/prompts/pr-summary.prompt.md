---
agent: "agent"
description: "Generate a structured PR summary for OmniSec changes"
---

You are generating a pull request summary for the OmniSec project.

Changes to summarize: ${input:changes:Git diff or description of changes}

## Required PR Structure

### Title
Format: `type(scope): brief description`
Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `security`, `perf`
Examples:
- `feat(nhctl): add eBPF program loader subcommand`
- `fix(device): correct nh-mount bind path for Android 16`
- `security(nh-sudo): restrict setuid scope to authorized operations`

### Body Structure
```markdown
## Summary
<!-- 1-3 bullet points covering what this PR does and why -->

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update
- [ ] Security fix
- [ ] Performance improvement

## Files Changed
| File | Change |
|------|--------|
| `path/to/file` | Brief description of change |

## Testing
- [ ] `make lint` passes
- [ ] `make test` passes
- [ ] `make stage` regenerates payload (if applicable)
- [ ] Manual testing performed (describe)

## Compatibility Notes
<!-- Any migration steps, config changes, or breaking changes -->

## Related Issues
<!-- Closes #123, Related to #456 -->
```

## Guidelines
- Keep the summary concise and focused on the "why"
- Include migration steps if behavior changed
- Reference any related issues or discussions
- Be explicit about testing performed
- Flag any potential regressions or compatibility concerns
