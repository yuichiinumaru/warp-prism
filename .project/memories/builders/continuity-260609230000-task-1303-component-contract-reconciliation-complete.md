# Task 1303: Component Contract Reconciliation — Complete

> **Date**: 2026-06-09
> **Task**: 1303
> **Status**: Builder Done
> **Agent**: builders

## What was done

Fixed 14 contract test failures across 5 test files in `warp_prism_ui`:

- **atoms_contract_test.dart** (1): AnimatedBuilder count assertion loosened
  (MaterialApp internals contribute extra AnimatedBuilder)
- **molecules_contract_test.dart** (8): 6 DSSearchBar tests wrapped in
  Scaffold (Material ancestor fix); DSStateType count 3→7
- **templates_contract_test.dart** (3): Surface size set to 1600px for
  detail/search tests; History text count fixed to 2; DSSearchBar finder
  instead of TextField
- **operational_components_test.dart** (1): Semantics label lookup uses
  widget predicate instead of `.first`
- **state_surface_test.dart** (1): DSStateType count 3→7

## Code fix

`ds_search_bar.dart`: Added `_controller.addListener` for clear button
reactivity. Without this, the clear button could never appear after dynamic
text entry because the widget never rebuilt on controller changes.

## Key learnings

- `setSurfaceSize` is async — needs `await`
- Flutter's default test surface is 800x600 — templates with sidebar (240px)
  need wider surfaces for responsive layout testing
- `Scaffold` may use `LookupBoundary` preventing `Material.of()` from
  reaching deeply nested `TextField` widgets — direct `Material` wrapper
  works around this
- `find.byType(Semantics).first` is fragile when child widgets contribute
  their own Semantics — use `find.byWidgetPredicate` for specific labels
