# Audit Reports

Audit artifacts for the multi-platform workspace.

## Start Here

- `docs/INDEX.md`: audit navigation hub
- `docs/QUICK_START.md`: one-page summary
- `docs/SUMMARY.md`: executive findings

## Layout

- `docs/`: curated report set by category
- `data/`: timestamped raw outputs from audit runs
- `scripts/run_audit.sh`: audit generator script
- `.metadata`: audit metadata

## Re-run Audit

```bash
cd /home/arch/projects/multi-platform
bash .audit-reports/scripts/run_audit.sh
```

## Notes

- Workspace has been reorganized to a centralized `repos/` hierarchy.
- Some raw reports still describe legacy paths from the initial scan snapshot.
- Use `../docs/REPO-MIGRATION-MAP.md` for path translation.
