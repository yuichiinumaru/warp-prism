---
date: 20260718-052500
timestamp: 20260718-052500
project: warp-prism
agent: gt-flutter-engineer
task: "1513"
description: "Resubmit path-to-100: legend 48dp, size test, module split"
is_rebuild_safe: true
---

# Task 1513: PrismEntityRelationCard — Review Resubmit Fixes

## Summary

Addressed HELD_IN_REVIEW_RESUBMIT findings (score 88 → path-to-100) for
`PrismEntityRelationCard`. Composes `DSGraphCanvas`; no force-graph JS.

## Changes

- Legend filter chips: `ConstrainedBox(minWidth/minHeight: 48)` hit targets
- Keyboard Enter/Space activation retained via `FocusableActionDetector`
- Module split: host + legend + sections
- Widget test asserts legend render box ≥ 48×48 (7 tests total)

## Verification

```bash
cd packages/warp_prism_ui
dart analyze lib/src/organisms/entity_relation_card test/organisms/entity_relation_card
# No issues found! (exit 0)

dart format --output=none --set-exit-if-changed \
  lib/src/organisms/entity_relation_card test/organisms/entity_relation_card
# Formatted 0 changed (exit 0)

flutter test test/organisms/entity_relation_card/ --concurrency=1
# All tests passed (7)

dart analyze lib test
# No issues found! (exit 0)

dart run test/boundaries/boundary_test.dart
# Boundary harness: 7/7 PASS
```

## Changelog Draft

```yaml
task: 1513
agent: gt-flutter-engineer
project: warp-prism
title: PrismEntityRelationCard path-to-100 legend a11y
description: >
  Legend filter 48dp hit targets + size test; host/legend/sections split;
  fixture graph preview only.
summary: Entity relation card resubmit ready for re-review.
verification: scoped analyze/format/tests + package analyze + 7/7 boundaries
```
