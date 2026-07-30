# Changelog Entries

This directory contains append-only source entries for the generated changelog.

- Only the parent orchestrator writes final entries and generated surfaces.
- Add one entry with:
  `bash .agents/skills/project-management/sub-skills/manage-changelog/scripts/rebuild.sh add --project <project> ...`
- Reconcile a wave with:
  `bash .agents/skills/project-management/sub-skills/manage-changelog/scripts/rebuild.sh batch-closeout --input <drafts.jsonl>`
- Generated outputs:
  - `CHANGELOG.md`: latest 100 entries.
  - `CHANGELOG-FULL.md`: complete history.
  - `docs/changelog/index.md`: complete searchable table.
  - `docs/changelog/views/*.md`: project-specific views for classified entries.
  - `docs/changelog/releases/*.md`: explicit immutable milestone snapshots.
