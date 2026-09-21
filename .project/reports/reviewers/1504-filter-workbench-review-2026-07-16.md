# Independent Review — Task 1504 PrismFilterWorkbench

**Date**: 2026-07-16  
**Reviewer profile**: `reviewers`  
**Verdict**: REJECT  
**Score**: 82/100  
**Previous report**: `docs/reports/review-wave-2026-07-11/task-1504-independent-review.md`

## Live Evidence Summary

Task claims were treated as untrusted and re-verified on the live filesystem.

- Implementation exists: `packages/warp_prism_ui/lib/src/organisms/filter_workbench/ds_filter_workbench.dart`
- Test exists: `packages/warp_prism_ui/test/organisms/filter_workbench/filter_workbench_test.dart`
- Prism aliases exist: `packages/warp_prism_ui/lib/src/prism_aliases.dart:483-496`
- Organism barrel export exists: `packages/warp_prism_ui/lib/src/organisms/organisms.dart:34`
- Gallery registration exists: `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart:2432-2444`, demo at `4586-4708`

## Axiom Compliance

| Axiom | Status | Evidence |
| --- | --- | --- |
| Analyzer Integrity | PARTIAL | `dart analyze ...` PASS, but required format gate FAILED: `dart format --output=none --set-exit-if-changed ...` reported changed `ds_filter_workbench.dart`, `prism_aliases.dart`, `design_system_gallery_sections.dart`, and `filter_workbench_test.dart`. |
| Lifecycle Safety | PASS | Exact count: `TextEditingController` created 1 (`ds_filter_workbench.dart:822`) / disposed 1 (`847`); `FocusNode` created 2 (`823`, `1188`) / disposed 2 (`848`, `1200`); `Timer` 0; `StreamSubscription` 0; `AnimationController` 0; `ScrollController` 0. Mounted guard present before post-dialog merge (`386`). |
| Dependency Direction | PASS | UI package imports Flutter + local ADS atoms/molecules/tokens only (`ds_filter_workbench.dart:1-8`); boundary harness live PASS 7/7. |
| UI Accessibility | FAIL | Semantic labels exist for apply/clear, but 7 custom interactive call-sites are below 48dp minimum touch target: 5 `_WorkbenchButton` call-sites use `minHeight: 40`, `_AdvancedExpandable` uses `minHeight: 40`, `_IconHit` uses `minHeight: 40`. |
| Proof Reality | PARTIAL | 10 filter-workbench widget tests exist and combined organism suite passed 43/43. Format proof is false/stale because live format gate is red. |
| Release Security | PASS | No hardcoded secrets or print/debugPrint found in reviewed implementation; read-only fixture UI only. |

## Findings

### MODERATE — Required format gate is red

- **Evidence**: live command `dart format --output=none --set-exit-if-changed ...` reported:
  - `Changed lib/src/organisms/filter_workbench/ds_filter_workbench.dart`
  - `Changed lib/src/prism_aliases.dart`
  - `Changed lib/src/gallery/design_system_gallery_sections.dart`
  - `Changed test/organisms/filter_workbench/filter_workbench_test.dart`
- **Impact**: Task exit condition claims analyze/test pass, but review procedure explicitly requires this format check. A red required gate is not review-ready.
- **Recommendation**: Run `dart format` intentionally in builder lane, then re-run `dart format --output=none --set-exit-if-changed` until it exits clean.

### MODERATE — Custom controls violate 48dp touch target minimum

- **Evidence**:
  - `_WorkbenchButton` uses `constraints: const BoxConstraints(minWidth: 48, minHeight: 40)` at `packages/warp_prism_ui/lib/src/organisms/filter_workbench/ds_filter_workbench.dart:1246`.
  - `_WorkbenchButton` is used for 5 interactive call-sites: advanced open (`583-590`), clear (`613-619`), apply (`621-627`), modal cancel (`1141-1146`), modal done (`1148-1155`).
  - `_AdvancedExpandable` uses `constraints: const BoxConstraints(minHeight: 40)` at `984`, used as an interactive expander (`974-982`).
  - `_IconHit` uses `constraints: const BoxConstraints(minWidth: 40, minHeight: 40)` at `1308`, used for modal close (`1102-1109`).
- **Impact**: Violates UI Accessibility axiom and task requirement for accessible interactive controls. Blast radius is every consumer of the workbench footer and advanced modal.
- **Recommendation**: Change `_WorkbenchButton` and `_IconHit` to `minHeight: kMinInteractiveDimension` / `minWidth: kMinInteractiveDimension`; change `_AdvancedExpandable` to `minHeight: kMinInteractiveDimension` or wrap it in a 48dp hit region.

## Commands Run

```text
cd packages/warp_prism_ui

dart analyze lib/src/organisms/filter_workbench lib/src/organisms/entity_intel_panel lib/src/organisms/entity_locate_search lib/src/organisms/time_machine_scrubber lib/src/organisms/organisms.dart lib/src/prism_aliases.dart lib/src/gallery/design_system_gallery_sections.dart test/organisms/filter_workbench test/organisms/entity_intel_panel test/organisms/entity_locate_search test/organisms/time_machine_scrubber
# No issues found!

flutter test test/organisms/filter_workbench/ test/organisms/entity_intel_panel/ test/organisms/entity_locate_search/ test/organisms/time_machine_scrubber/
# 00:06 +43: All tests passed!

dart run test/boundaries/boundary_test.dart
# Boundary harness: 7/7 PASS, 0 FAIL, 0 violation(s)

dart format --output=none --set-exit-if-changed lib/src/organisms/filter_workbench lib/src/organisms/entity_intel_panel lib/src/organisms/entity_locate_search lib/src/organisms/time_machine_scrubber lib/src/organisms/organisms.dart lib/src/prism_aliases.dart lib/src/gallery/design_system_gallery_sections.dart test/organisms/filter_workbench test/organisms/entity_intel_panel test/organisms/entity_locate_search test/organisms/time_machine_scrubber
# FAILED: reported Changed ... including Task 1504 files

dart pub outdated
# 8 dependencies constrained older than resolvable/latest versions; not task-blocking but recorded for Phase 1.
```

## Score Rationale

82/100. Analyzer/test/boundary behavior is mostly sound, but the format gate is red and accessibility has concrete 48dp violations. Per routing, score <90 requires rejection.

## Path to 100

1. Apply Dart formatting to the listed files and prove `dart format --output=none --set-exit-if-changed ...` is clean.
2. Increase all custom interactive hit regions in `ds_filter_workbench.dart` to 48dp minimum:
   - `_WorkbenchButton` at `1246`
   - `_AdvancedExpandable` at `984`
   - `_IconHit` at `1308`
3. Add/extend a widget test that asserts `tester.getSize` for apply, clear, advanced, modal close, cancel, and done controls is at least 48 logical pixels tall.
4. Re-run analyze, organism tests, boundary harness, and format check.
