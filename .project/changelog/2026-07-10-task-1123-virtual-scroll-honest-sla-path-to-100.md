---
date: 20260710-120000
timestamp: 20260710-120000
project: warp-prism
agent: "builders"
task: "1123"
description: "2026-07-10 — Task 1123: honest virtualization SLA (path-to-100 after 88 reject)"
is_rebuild_safe: true
---

# Task 1123: Virtual Scroll Honest SLA Path-to-100

**Agent**: builders (gt-flutter-engineer)
**Task**: 1123
**Type**: performance / evidence honesty

## Summary

Closed independent re-review residual (88/100): **16ms/60fps proof was not real** under `flutter_test` (live avg ~35ms, P99 ~95ms while asserts used soft harness budgets). Path-to-100 reframes acceptance to a **measured virtualization SLA** (viewport-bounded buildCount + fixed `itemExtent` O(1) jump-to-index) and removes fake 16ms product claims from benchmark, gallery, API docs, and task exit wording. Cheap virtualization tweak: `DSVirtualScrollConfig.highCache` now sets `addAutomaticKeepAlives: false`.

Lane left in `docs/tasks/02-doing/` for reviewer re-pick.

## Changes

- `packages/warp_prism_ui/test/performance/virtual_scroll_benchmark.dart` — honest SLA contract; hard asserts on buildCount/jumpTo; harness timings informational; fixed-vs-variable comparison.
- `packages/warp_prism_ui/lib/src/organisms/virtual_scroll/ds_virtual_scroll.dart` — highCache keep-alives off; performance docs no longer claim harness 60fps.
- `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` — remove “60fps” catalog claims.
- `packages/warp_prism_ui/test/organisms/virtual_list_test.dart` — highCache keep-alives expectation.
- Task 1123 acceptance / anti-hallucination / completion evidence aligned to honest SLA.

## Explicit non-claims

- Does **not** assert production GPU 16ms / 60fps inside `flutter_test`.
- Historical completion numbers (avg 12.33ms / P99 29ms) were harness noise and are superseded by live re-runs.

## Live closeout (2026-07-10)

```text
flutter test --concurrency=1 --no-pub \
  test/organisms/virtual_list_test.dart \
  test/organisms/virtual_grid_test.dart \
  test/performance/virtual_scroll_benchmark.dart
# → +35 All tests passed
```

| Metric | Live |
| --- | --- |
| 10K fixed builds | 23 (&lt; 200 SLA) |
| Scroll step avg / P99 / max (harness) | 15.00 / 51.18 / 60.30 ms |
| Soft harness avg ceiling | 200 ms (informational) |
| Jump-to index 9000 builds | 24 |
| Variable fresh initial builds | 18 |
| 5K grid builds | 20 |

### Comparison-test isolation fix

Sequential `pumpWidget` of fixed→variable without tree reset caused residual `ScrollPosition` adoption; variable-extent layout then measured from start to the adopted deep offset (~9018 builds). Fixed by distinct keys + intermediate `SizedBox.shrink()` so the variable baseline is a fresh initial build.
