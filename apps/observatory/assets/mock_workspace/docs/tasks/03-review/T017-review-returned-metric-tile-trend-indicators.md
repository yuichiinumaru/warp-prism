---
id: T017
title: "Review returned: metric tile trend indicators"
status: review
priority: low
owner: gt-code-quality-reviewer
created: "2026-06-02"
updated: "2026-06-06"
skills:
  - code-quality-harness
  - frontend-quality-harness
workflows:
  - gt-code-review
depends_on:
  - T009
proof_state: none
review_score: 6.0
---

# Review Returned: Metric Tile Trend Indicators

## Goal
Fix the DSTrend indicator in DSMetricTile where the switch expression using Dart 3 pattern matching produces incorrect colors for DSTrend.flat and add animation for trend transitions.

## Scope
- Fix DSTrend.flat case returning wrong color (currently returns statusWarning instead of statusNeutral)
- Add AnimatedSwitcher for trend state changes
- Add golden file tests for all 4 trend states

## Exit Conditions
- [ ] DSTrend.flat renders with DSColors.statusNeutral
- [ ] Trend transitions animate smoothly
- [ ] Golden file tests pass for up/down/flat/unknown states

## Verification Commands
```bash
flutter test test/design_system/ds_metric_tile_test.dart --update-goldens
```

## Completion Evidence
*Not yet completed — returned from review, fix in progress. Previous review identified color mapping bug on line 91 of ds_metric_tile.dart.*
