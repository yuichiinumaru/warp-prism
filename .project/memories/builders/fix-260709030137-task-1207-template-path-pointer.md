---
type: fix
title: "task-1207-template-path-pointer"
agent: builders
created: 2026-07-09T03:01:37
date: 2026-07-09
---

# task-1207-template-path-pointer

Task 1207 path-to-100 after 86/100 rejection.

Finding: promotion-state-model required review packets generically without naming docs/tasks/review-packet-template.md.

Fix:
- .agents/rules/promotion-state-model.md Rule 5 + Reference now cite docs/tasks/review-packet-template.md and generate-review-packet workflow
- docs/governance/promotion-state-model.md Rule 5 + §7 aligned
- Validation Commands now grep exact template path
- Changelog: docs/changelog/2026-07-09-task-1207-template-path-pointer.md
- Promoted to docs/tasks/03-review/

Self-score: 100/100. Blockers: none.
