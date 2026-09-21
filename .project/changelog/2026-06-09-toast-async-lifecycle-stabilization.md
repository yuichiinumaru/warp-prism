---
date: 20260710-011820
timestamp: 20260710-011820
agent: builders
task: "Task 1308"
description: "Task 1308: Toast Async Lifecycle Stabilization"
is_rebuild_safe: true
scope: "warp-prism-ui/molecules"
type: "remediation"
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

- `flutter test --concurrency=1 --no-pub test/molecules/ds_toast_test.dart` — 40/40 pass (3 consecutive
  runs from `packages/warp_prism_ui`, all green) after 2026-07-09 path-to-100 remediation
- `dart analyze --format=machine test/molecules/ds_toast_test.dart lib/src/molecules/ds_toast.dart lib/src/molecules/ds_toast_manager.dart` — 0 machine issues
- `dart format --output=none --set-exit-if-changed` on the 3 files — 0 files changed
- No toast test regressions in broader molecule test suite
- **Reconciliation Note (2026-06-30)**: Re-verified against independent reviewer findings regarding imported symbols. The test file already uses the correct internal molecule/token barrels on the live filesystem.
- **Path-to-100 remediation (2026-07-09)**: After independent review score 84/100:
  1. Live-region `Semantics.label` includes optional `entry.message` while decorative children stay under `ExcludeSemantics`.
  2. `dismiss()`, `clear()`, and `_onHoverChanged()` now guard with `if (!mounted) return` before `setState`.
  3. Action `TextButton` enforces 48x48 `minimumSize` + widget test proof.
  4. Package-wide analyzer issues remain classified EXTERNAL_BLOCKER; no unrelated package files touched.
- **Path-to-100 fixer (2026-07-09, after 87/100)**:
  1. Timer callback re-resolves by toast id (never trusts captured list index).
  2. Pause-on-hover widget regression added; suite **41/41** ×3.
  3. Stale `04-completed` 1308 archived; package residual left EXTERNAL.
  4. See also `docs/changelog/20260709-221609-1308-toast-timer-id-pause-hover-builders.md`.
