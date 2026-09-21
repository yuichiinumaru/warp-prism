---
type: review
title: "task-0711-history-parser-filter-index-review"
agent: reviewers
created: 2026-06-30T18:31:33
date: 2026-06-30
---

# task-0711-history-parser-filter-index-review

Task 0711 review score 78/100 REJECTED. Evidence: flutter analyze in apps/observatory failed with 1126 issues, while task-specific analyze passed and parser/history tests passed (65 tests total, history-only 22). Findings: package analyzer claim fabricated/stale; HistoryRepository not wired into MockWorkspaceRepository/provider path; malformed invalid-date changelog assets dropped instead of represented as UI-treatable data; impact path only exposes changelog->task and does not materialize task->skill/workflow read-model edges; tests are synthetic and do not load real mock changelog corpus. Task moved from docs/tasks/03-review/0711-warp-prism-history-parser-and-filter-index.md to docs/tasks/02-doing/0711-warp-prism-history-parser-and-filter-index.md.
