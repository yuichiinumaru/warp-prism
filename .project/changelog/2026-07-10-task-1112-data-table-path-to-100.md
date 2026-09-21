---
date: 20260710-141500
timestamp: 20260710-141500
project: warp-prism
agent: "builders"
task: "1112"
description: "2026-07-10 — Task 1112: data table path-to-100 (a11y 48×48, filter proof, coverage)"
is_rebuild_safe: true
---

# Task 1112: Data Table Path-to-100

**Agent**: builders (gt-flutter-engineer)
**Task**: 1112
**Type**: feature / a11y / evidence

## Summary

Closed independent re-review residual (**84/100** → path-to-100):

- **F3–F6**: Semantic 48×48 interactive targets for secret reveal, row actions, sort headers, and selection checkboxes (no undersized bare GestureDetector/InkWell).
- **F7**: Toolbar composition proof — `DSSearchBar` + `DSFilterChipGroup` filter rows via parent-owned state (gallery + widget test).
- **F8**: Honest lcov — `ds_data_table.dart` **86.6%** line coverage (311/359).
- **F9**: No `withOpacity`; scoped analyze clean.

Lane left in `docs/tasks/02-doing/` for reviewer re-pick (`ready_for_reviewer: yes`).

## Changes

- `packages/warp_prism_ui/lib/src/organisms/data_table/ds_data_table.dart` — single Semantics nodes with `excludeSemantics` over 48×48 IconButtons; sort InkWell min 48; checkbox columns 48; const decorations; no withOpacity.
- `packages/warp_prism_ui/test/organisms/data_table/ds_data_table_test.dart` — filter SearchBar+FilterChipGroup behavioral test; interactive a11y ≥48 hit-target group.
- Gallery already documents filter toolbar composition (`buildDataTableSection`).

## Live closeout (2026-07-10)

```text
cd packages/warp_prism_ui
flutter test --concurrency=1 --no-pub test/organisms/data_table/
# → +42: All tests passed!

flutter test --concurrency=1 --no-pub --coverage test/organisms/data_table/
# → ds_data_table.dart 311/359 = 86.6%

dart analyze lib/src/organisms/data_table/
# → No issues found!
```
