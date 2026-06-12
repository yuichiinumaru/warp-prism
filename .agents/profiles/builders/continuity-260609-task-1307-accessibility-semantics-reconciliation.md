# Task 1307: Accessibility and Semantics Reconciliation — Complete

**Date**: 2026-06-09
**Executor**: builders
**Status**: Builder Done

## Summary

Fixed 3 accessibility test failures in `design_system_accessibility_test.dart`.
All 13 accessibility tests now pass (was 10/13).

## Root Cause

When a `Semantics(label: 'X')` widget wraps a subtree containing a `Text('X')`
widget, Flutter's default semantics merging concatenates the explicit label with
the Text's auto-generated semantics node, producing doubled labels like
`'X\nX'`. The test `find.bySemanticsLabel('Test Chip')` uses exact matching,
so the doubled label `"Test Chip\nTest Chip"` didn't match `"Test Chip"`.

This only affected components with explicit `Semantics` labels that also had
`Text` children with matching text. Components with `Semantics` wrapping only
`Icon` children (like `DSTopbarAction`) were unaffected.

## Fix Applied

Standard Flutter `Semantics` + `ExcludeSemantics` pattern:

1. Added `explicitChildNodes: true` to prevent child semantics from merging
   into the parent `Semantics` node.
2. Wrapped inner content (`AnimatedContainer` containing `Text`) with
   `ExcludeSemantics` to prevent the `Text` widget from creating a duplicate
   semantics node.

Files changed:
- `lib/src/atoms/ds_chip.dart` (DSChip)
- `lib/src/molecules/ds_filter_chip_group.dart` (_FilterChip)
- `lib/src/organisms/ds_sidebar.dart` (_SidebarItemWidget)

## Lessons Learned

- Flutter's `Semantics` widget merges child semantics by default
  (`explicitChildNodes: false`). When the parent has an explicit `label` AND
  children contribute text, labels get doubled.
- The `find.bySemanticsLabel` matcher does exact string matching on the final
  semantics node label, not substring.
- For labeled interactive components, always use `explicitChildNodes: true` +
  `ExcludeSemantics` on children, following the pattern used by Flutter's own
  `IconButton` and `Chip` widgets.
- Diagnostic approach: `tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!`
  with a recursive dump function reveals the actual semantics tree structure.
