# OmniSec AI Agent and CLI Playbook

This playbook standardizes how AI tools and agent CLIs are used in OmniSec.

## Supported AI entrypoints

- Host CLIs: codex, claude, gh copilot, aider, gemini, codeium, cody, continue
- Device AI control: ./nhctl ai <subcommand>
- Prompt packs: .github/prompts/*.prompt.md
- Task orchestration: .vscode/tasks.json

## Fast start workflows

1. Standard bootstrap
   - Task: AI: Bootstrap (Standard)
   - Script: ./scripts/ai-bootstrap.sh
2. Full bootstrap with quality gates
   - Task: AI: Bootstrap (Full)
   - Script: ./scripts/ai-bootstrap.sh --full
3. Context gathering only
   - Task: AI: Repo Context Snapshot
   - Script: ./scripts/ai-context-snapshot.sh
4. Daily operations quick pass
   - Task: AI: Daily Ops (Quick)
   - Script: ./scripts/ai-daily-ops.sh
5. Daily operations full pass
   - Task: AI: Daily Ops (Full)
   - Script: ./scripts/ai-daily-ops.sh --full

## Health checks and diagnostics

1. Host AI tools
   - Task: AI: CLI Doctor (Host)
   - Script: ./scripts/ai-cli-doctor.sh
2. Device AI runtime
   - Task: AI: Device AI Status
   - Task: AI: Device AI Diagnose
   - Task: AI: Device AI Models
   - Task: AI: Device AI Sessions (List)
3. Prompt and agent quality
   - Task: AI: Prompt Lint
   - Task: AI: Agent Lint
   - Task: AI: Prompt + Agent Gate
4. Missing tool guidance
   - Task: AI: Missing CLI Install Hints
   - Script: ./scripts/ai-missing-cli-help.sh
5. Missing tool install automation
   - Task: AI: Install Missing CLIs (Plan)
   - Task: AI: Install Missing CLIs (Apply)
   - Script: ./scripts/ai-install-missing-cli.sh --plan|--apply

## Agent routing helper

Use ./scripts/ai-agent-router.sh to launch a specific CLI consistently:

- ./scripts/ai-agent-router.sh codex
- ./scripts/ai-agent-router.sh claude
- ./scripts/ai-agent-router.sh copilot
- ./scripts/ai-agent-router.sh aider
- ./scripts/ai-agent-router.sh gemini
- ./scripts/ai-agent-router.sh codeium
- ./scripts/ai-agent-router.sh cody
- ./scripts/ai-agent-router.sh continue

## Recommended guardrails

1. Run ./scripts/pre-rename-audit.sh before large refactors.
2. Run ./repo-doctor.sh before debugging agent issues.
3. Run make lint and make test before merge-impacting changes.
4. Keep prompt templates in .github/prompts with frontmatter.
5. Use project tasks instead of ad hoc shell aliases for repeatable operations.

## Makefile shortcuts

- make ai-cli-doctor
- make ai-context
- make ai-bootstrap
- make ai-bootstrap-full
- make ai-prompt-lint
- make ai-agent-lint
- make ai-missing-cli-help
- make ai-install-missing-cli-plan
- make ai-install-missing-cli-apply
- make ai-daily-ops
- make ai-daily-ops-full
- make ai-daily-ops-device
