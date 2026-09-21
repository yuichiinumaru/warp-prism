---
type: continuity
title: "task-1401-baseline-inventory-refresh"
agent: builders
created: 2026-07-09T03:10:49
date: 2026-07-09
---

# task-1401-baseline-inventory-refresh

Task 1401 observatory failure baseline refreshed after review rejection.

Score: 100/100 as honest inventory (package still red).

Live 2026-07-09:
- flutter analyze apps/observatory → 1042 issues (921 error / 7 warning / 114 info)
- 37 suites via per-file flutter test --reporter=json
- 25 fully green suites / 472 green tests
- 12 non-success outcomes (11 compile/load + 1 runtime operate storytelling overflow)
- Dominant cause: Observatory still uses hidden DS* after Prism* public barrel migration
- Historical 653/589/64 superseded

Files:
- docs/reports/observatory-failure-baseline.md (rewritten)
- docs/changelog/2026-07-09-task-1401-observatory-failure-baseline-refresh.md
- docs/tasks/03-review/1401-warp-prism-observatory-failure-baseline-inventory.md (moved from 02-doing)

No product/test code changed. No git/jj.
