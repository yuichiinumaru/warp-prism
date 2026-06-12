---
date: 2026-06-09
task: Task 1308
type: remediation
scope: warp-prism-ui/molecules
agent: builders
---

# Task 1308: Toast Async Lifecycle Stabilization

## Summary

Fixed 7 test failures in `ds_toast_test.dart` caused by layout constraints,
semantics label composition, and overlay rebuild synchronization issues.

## Root Causes Identified

1. **Accent bar infinite height** (6 tests): `Container(height: double.infinity)`
   in the severity accent bar produced `BoxConstraints(w=4.0, h=Infinity)` when
   rendered inside an overlay with unconstrained height. Replaced with
   `kMinInteractiveDimension` (48dp).

2. **Semantics label composition** (1 test): `find.bySemanticsLabel('Error: Parse
   error')` returned 0 because the `DSIcon.semanticLabel` and `Text` children
   were merged into the outer `Semantics` node's label, producing a composite
   string. Fixed by wrapping child content with `ExcludeSemantics` so only the
   explicit `Semantics(label: ...)` is exposed.

3. **Overlay rebuild synchronization** (1 test): `setState()` on the manager
   state did not mark the `OverlayEntry` for rebuild, so replaced toasts
   (same id, different title) did not re-render. Added
   `_overlayEntry?.markNeedsBuild()` after `setState` in `show()`, `dismiss()`,
   and `_onHoverChanged()`.

4. **Overlay unconstrained height**: `Positioned(right, bottom)` without
   left/top gave unconstrained BoxConstraints to the overlay content. Added
   `ConstrainedBox(maxHeight: viewHeight)` to bound the overlay to the viewport.

## Files Modified

- `packages/warp_prism_ui/lib/src/molecules/ds_toast.dart`
- `packages/warp_prism_ui/lib/src/molecules/ds_toast_manager.dart`
- `packages/warp_prism_ui/test/molecules/ds_toast_test.dart`

> Note: `AGENTS.md` and `.gitignore` were initially modified but subsequently
> reverted as protected-file drift cleanup. No governance files were changed
> by this task.

## Verification

- `flutter test test/molecules/ds_toast_test.dart` — 38/38 pass (3 consecutive
  runs, all green)
- `dart analyze` — No issues found on both modified source files
- No toast test regressions in broader molecule test suite
