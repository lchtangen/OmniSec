# Copilot admin checklist (repository settings)

Use this checklist in GitHub repository settings to activate all committed customizations.

## Repository settings

1. Ensure the default branch contains:
   - `.github/workflows/copilot-setup-steps.yml`
   - `.github/copilot-instructions.md`
   - `.github/instructions/**`
2. Confirm GitHub Copilot is enabled for this repository.
3. Ensure custom instructions are enabled for Copilot code review and cloud agent usage.

## Environment settings

Create the **`copilot`** environment and add any required variables/secrets for private dependencies.

Examples:
- `NPM_TOKEN` (if private npm registry is needed)
- internal proxy variables (if required by organization policy)

## Workflow checks

- Verify `Copilot Setup Steps` runs successfully from the Actions tab.
- Verify `Copilot Customizations CI` runs on customization changes.
