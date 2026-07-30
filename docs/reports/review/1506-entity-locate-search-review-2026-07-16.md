# Independent Review — Task 1506 PrismEntityLocateSearch

**Date**: 2026-07-16  
**Reviewer profile**: `reviewers`  
**Verdict**: REJECT  
**Score**: 86/100  
**Previous report**: `docs/reports/review-wave-2026-07-11/task-1506-independent-review.md`

## Live Evidence Summary

Task claims were treated as untrusted and re-verified on the live filesystem.

- Implementation exists: `packages/warp_prism_ui/lib/src/organisms/entity_locate_search/ds_entity_locate_search.dart`
- Test exists: `packages/warp_prism_ui/test/organisms/entity_locate_search/entity_locate_search_test.dart`
- Prism aliases exist: `packages/warp_prism_ui/lib/src/prism_aliases.dart:816-833`
- Organism barrel export exists: `packages/warp_prism_ui/lib/src/organisms/organisms.dart:41`
- Gallery registration exists: `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart:2472-2482`, demo at `4837-4966`

## Axiom Compliance

| Axiom | Status | Evidence |
| --- | --- | --- |
| Analyzer Integrity | PARTIAL | `dart analyze ...` PASS on the full organism scope. `dart format --output=none --set-exit-if-changed ...` FAILED: reported `Changed lib/src/organisms/entity_locate_search/ds_entity_locate_search.dart`, `Changed lib/src/prism_aliases.dart`, `Changed lib/src/gallery/design_system_gallery_sections.dart`, `Changed test/organisms/entity_locate_search/entity_locate_search_test.dart`. |
| Lifecycle Safety | PASS | `Timer? _debounceTimer` created 1 (`ds_entity_locate_search.dart:564`) / disposed 1 (`606: _debounceTimer?.cancel()`). `TextEditingController` is owned by `DSSearchBar` molecule, not this organism. All lifecycle resources accounted for. |
| Dependency Direction | PASS | Implementation imports Flutter + local ADS atoms/molecules/tokens (`ds_entity_locate_search.dart:1-13`). Boundary harness PASS 7/7. |
| UI Accessibility | PASS | Semantic labels on panel (`736: panelSemanticLabel`), search field (`686`), results (`799: resultsSemanticLabel`), empty (`764/776`), loading (`744`), result row labels (`868`), locate action labels (`943`). Locate `IconButton` at `946-961` uses `constraints: BoxConstraints(minWidth: 48, minHeight: 48)`, meeting 48dp minimum. Result rows are `InkWell` inside a `Material` with `DSSpacing.sm` padding (~24dp vertical), but the row is meant to be scanned with a pointer; internal `IconButton` for locate action is 48dp. |
| Proof Reality | PARTIAL | 12 tests exist (+ 1 unit test inside 12 group), combined organism suite PASS 43/43. False-gap vs `PrismCommandPalette` proven by test at `L197-199`. `matchResults` unit tests exist. Format proof is **stale/red** (live `dart format` failed). |
| Release Security | PASS | No live API keys or print/debugPrint output. Read-only fixture corpora. |

## Findings

### MODERATE — Required format gate is red

- **Evidence**: Live `dart format --output=none --set-exit-if-changed ...` reported:
  - `Changed lib/src/organisms/entity_locate_search/ds_entity_locate_search.dart`
  - `Changed lib/src/prism_aliases.dart`
  - `Changed lib/src/gallery/design_system_gallery_sections.dart`
  - `Changed test/organisms/entity_locate_search/entity_locate_search_test.dart`
- **Impact**: Review procedure explicitly requires this format check; a red required gate is not review-ready.
- **Recommendation**: Apply formatting in builder lane, then re-run until clean.

### LOW — Previous self-score `95/100` not validated against format gate

- **Evidence**: Prior review Ledger claims `95/100` with `HELD_IN_REVIEW_PATH_TO_100`, but live format gate is red on files that existed then. It is unlikely format broke between 2026-07-11 and 2026-07-16 on unchanged source files.
- **Impact**: Credibility gap. Self-score may have been inflated if format was not checked.
- **Recommendation**: Re-check prior review wave format evidence; acknowledge if previous review was incomplete.

### LOW — Locate action IconButton overlap semantics

- **Evidence**: `_LocateResultRowState.build` at `946-961` wraps `IconButton` in both `ExcludeSemantics` (`946`) and an outer `Semantics` with its own `button: true, enabled: true, label` (`936-945`). While not broken, the `ExcludeSemantics` + re-labeled Semantics pattern is redundant and may cause tooling confusion.
- **Impact**: Minimal. Does not affect accessibility tree correctness. A cleanup item.
- **Recommendation**: Consider keeping `IconButton` own semantics or wrapping only with `IconButton` `tooltip` for the label. Remove the `ExcludeSemantics` + unlabeled outer Semantics if the `IconButton` tooltip suffices.

## Commands Run

```text
cd packages/warp_prism_ui

dart analyze (full organism surface family scope)
# No issues found!

flutter test (4 organism test suites combined)
# 00:06 +43: All tests passed!

dart run test/boundaries/boundary_test.dart
# Boundary harness: 7/7 PASS, 0 FAIL, 0 violation(s)

dart format --output=none --set-exit-if-changed (full organism surface scope)
# FAILED: reported Changed ... including Task 1506 files

dart pub outdated
# (informational - not task-blocking)
```

## Score Rationale

86/100. Implementation, test false-gap proof, and lifecycle safety are strong. The format gate being red is a required-procedure failure. Minor semantic layer redundancy is optional cleanup. Score <90 requires rejection.

## Path to 100

1. Apply Dart formatting to listed files; prove clean format gate.
2. Re-run analyze, organism tests, boundary harness, and format check.
3. (Optional) Simplify `_LocateResultRow` locate icon semantics — remove outer redundant Semantics or the `ExcludeSemantics` wrapper.