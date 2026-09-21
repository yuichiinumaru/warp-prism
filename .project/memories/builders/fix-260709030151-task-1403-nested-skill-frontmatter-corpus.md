---
type: fix
title: "task-1403-nested-skill-frontmatter-corpus"
agent: builders
created: 2026-07-09T03:01:51
date: 2026-07-09
---

# task-1403-nested-skill-frontmatter-corpus

## Task 1403 remediation (review rejection S=68)

Applied Task 1402 corpus recommendation: added minimal YAML frontmatter
(`name`, `description`) to 39 nested mock skill files under
`apps/observatory/assets/mock_workspace/.agents/skills/*/{sub-skills,workflows,references}/`.

### Result
- Mock corpus: 130/130 files with frontmatter (was 91/130, 39 missing)
- Targeted tests: 78/78 + full parsers 67/67 PASS
- Target analyzer (`lib/data/parsers` + `lib/data/models`): clean
- Package-wide `dart analyze`: EXTERNAL RED (~1042 issues) — not claimed clean

### Handoff
Task moved to `docs/tasks/03-review/1403-warp-prism-parser-and-task-projection-reconciliation.md`.
Self-score 100/100 on task scope.
