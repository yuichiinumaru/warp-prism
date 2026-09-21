---
date: 20260709-061030
timestamp: 20260709-061030
agent: builders
task: "1401"
description: "Task 1401 — Observatory Failure Baseline Inventory Refresh"
is_rebuild_safe: true
---

# Task 1401 — Observatory Failure Baseline Inventory Refresh

> **Date**: 2026-07-09
> **Project**: warp-prism
> **Task**: 1401
> **Type**: governance
> **Author**: builders

## What Changed

Refreshed `docs/reports/observatory-failure-baseline.md` after independent
review rejected the 2026-06-09 inventory as stale. Live scoped diagnostics no
longer match the historical claim of 653 tests / 589 pass / 64 runtime fails.

## Live Baseline (2026-07-09)

- Method: per-suite `flutter test <file> --reporter=json` over all 37
  `apps/observatory/test/**/*_test.dart` suites + `flutter analyze apps/observatory`
- Fully green suites: **25** (472 tests)
- Non-success suite outcomes: **12** (11 compile/load + 1 runtime)
- Analyzer: **1042 issues** (921 error / 7 warning / 114 info)
- Dominant root cause: Observatory production/UI code still uses hidden `DS*`
  symbols while `warp_prism_ui` public barrel exports only `Prism*` aliases
- Only pure runtime suite failure observed: `operate_storytelling_test`
  (`renders PrismStoryPanel when operational risks are detected`) via
  `DSStateSurface` RenderFlex overflow 4.5px
- Historical parser/history/map runtime clusters are largely green now
- Responsive-detail suite re-verified as compile/load fail on test-side
  `DSBreakpoints` (not “maybe pass”)

## Evidence

- Report: `docs/reports/observatory-failure-baseline.md`
- Task ledger: `docs/tasks/02-doing/1401-warp-prism-observatory-failure-baseline-inventory.md`
  (promoted to `03-review/` after self-score 100/100 as inventory)
- No production or test code modified (inventory-only remediation)
- Historical 2026-06-09 changelog retained; this entry supersedes its live counts
