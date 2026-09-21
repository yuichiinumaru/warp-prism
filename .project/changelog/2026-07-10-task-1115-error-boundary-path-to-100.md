---
date: 20260710-170700
timestamp: 20260710-170700
project: warp-prism
agent: "builders"
task: "1115"
description: "2026-07-10 — Task 1115 path-to-100: error boundary restore stack + real proofs + shimmer a11y/reduced-motion"
is_rebuild_safe: true
---

# Task 1115: Loading Skeleton And Error Boundary Path-to-100

**Agent**: builders (gt-flutter-engineer)
**Task**: 1115
**Type**: feature | design-system | remediation

## Summary

Closed independent re-review residual (**72/100**): `DSErrorBoundary` dispose restore identity mismatch (F1), vacuous catch/retry tests (F3), isolation overclaim (F2), and shimmer a11y/reduced-motion gap (F5). Nested handler stack with stable static tear-offs, real throw-in-build proofs, `ExcludeSemantics`, and reduced-motion solid base are in place.

Lane left in `docs/tasks/02-doing/` for reviewer re-pick.

## Changes

- `packages/warp_prism_ui/lib/src/organisms/ds_error_boundary.dart` — nested `_stack`; static `_dispatchFlutterError` / `_dispatchErrorWidget` tear-offs; outermost-only restore of `FlutterError.onError` + `ErrorWidget.builder`; honest isolation contract docs.
- `packages/warp_prism_ui/test/molecules/ds_error_boundary_test.dart` — real throw-in-build, custom fallbackBuilder, retry rebuild, dispose restore, nested dispose, innermost capture (not FallbackView-only).
- `packages/warp_prism_ui/lib/src/molecules/ds_shimmer.dart` — `ExcludeSemantics`; honors `MediaQuery.disableAnimationsOf` (solid base, controller stopped).
- `packages/warp_prism_ui/test/molecules/ds_shimmer_test.dart` — scoped ExcludeSemantics finder; reduced-motion test.

## Verification

```text
cd packages/warp_prism_ui
flutter test --concurrency=1 --no-pub \
  test/molecules/ds_error_boundary_test.dart \
  test/molecules/ds_shimmer_test.dart
# → +39: All tests passed! (18 error boundary + 21 shimmer)

dart analyze \
  lib/src/molecules/ds_shimmer.dart \
  lib/src/molecules/ds_skeleton_card.dart \
  lib/src/molecules/ds_skeleton_table_rows.dart \
  lib/src/molecules/ds_skeleton_text_line.dart \
  lib/src/organisms/ds_error_boundary.dart \
  lib/src/organisms/ds_fallback_view.dart
# → No issues found!
```

## Explicit non-claims

- Does **not** claim React-style true subtree isolation; contract documents global stack + ErrorWidget.builder participation.
