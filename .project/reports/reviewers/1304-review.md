# Review Report: Task 1304 — Gallery Compile Boundary Cleanup — 2026-06-13

## Review Lineage

- **Current task**: Task 1304 (`1304-warp-prism-gallery-compile-boundary-cleanup`); live path `docs/tasks/03-review/1304-warp-prism-gallery-compile-boundary-cleanup.md`.
- **Previous reports read**:
  - `docs/reports/build-gate-review/1303-review.md` — previous dependency report for Task 1303, scored `100/100`; relevant because it documented `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` analyzer backlog before Task 1304.
  - `docs/reports/build-gate-review/1304-review.md` — previous Task 1304 build-gate report, scored `100/100`; relevant because it claimed gallery analyzer scope was clean.
- **Related reports considered**: none beyond the two build-gate reports above.
- **Review mode**: `re-review` / independent wave-1 gate.

## Score And Verdict

- **Score**: `62/100`
- **Verdict**: `REJECTED`
- **Lane recommendation**: `return-to-doing` / no move performed by this reviewer.

Task 1304 is no longer blocked by Dart compilation errors: the gallery tests pass and the gallery files are formatted. It is not complete under Warp Prism reviewer governance because the exact requested analyzer command does not produce a clean analyzer result: `flutter analyze lib/src/gallery/` currently reports `296` info-level diagnostics in the gallery source. The previous `100/100` gallery report is therefore not reproducible from current checkout evidence.

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED`: Gallery tests still pass: `flutter test test/gallery/` reports `13/13` passing.
- `RESOLVED`: Gallery formatting is clean: `dart format --set-exit-if-changed lib/src/gallery/` reports `Formatted 3 files (0 changed)`.
- `RESOLVED`: The gallery test public-boundary patch from `docs/reports/build-gate-review/1304-review.md` is present: `packages/warp_prism_ui/test/gallery/design_system_gallery_test.dart:1-3` imports only `package:warp_prism_ui/warp_prism_ui.dart` plus Flutter test/material.

### Persistent Findings

- `PERSISTENT`: The gallery analyzer backlog noted in `docs/reports/build-gate-review/1303-review.md` is still present in the Task 1304 scope. Current exact count is `296` info-level diagnostics in `lib/src/gallery/`.

### Regressions

- `REGRESSION`: `docs/reports/build-gate-review/1304-review.md` claimed `flutter analyze lib/src/gallery/ test/gallery/` returned `No issues found!`; current `flutter analyze lib/src/gallery/` reports `296` issues.

### New Findings

- `NEW`: Two `DSTabController` listeners call `setState` without an explicit `mounted` guard and without removing the listener before disposing the controller.
- `NEW`: The gallery source contains a hardcoded secret-shaped demo value, `sk-1234567890abcdef`, in `DSSecretCell.fullValue`.

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: Task Completion Evidence at `docs/tasks/03-review/1304-warp-prism-gallery-compile-boundary-cleanup.md:129` claims analyzer PASS while allowing info-level lint suggestions; under the six axioms, analyzer integrity requires zero warnings and zero info-level issues.
- `EXTERNAL_BLOCKER`: `dart pub outdated` shows dependency freshness work remains outside this compile-boundary task: `7` dependencies are constrained older than resolvable versions, and `3` upgradable dependencies are locked older in `pubspec.lock`.

## Six Axiom Compliance

| # | Axiom | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Analyzer Integrity | **FAIL** | `flutter analyze lib/src/gallery/` reports `296` info-level diagnostics. Machine-count split: `274` `PREFER_CONST_CONSTRUCTORS`, `19` `PREFER_CONST_LITERALS_TO_CREATE_IMMUTABLES`, `3` `DEPRECATED_MEMBER_USE`. Representative lines: `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart:163`, `:373`, `:393`, `:2477`, `:2479`. |
| 2 | Lifecycle Safety | **PARTIAL** | Exact gallery disposable count: `2` `DSTabController` instances created at `design_system_gallery_sections.dart:2644` and `:2749`; `2` disposed at `:2688` and `:2755`. Exact listener count: `2` listeners added at `:2683` and `:2750`; exact explicit mounted-guard count in those listener callbacks: `0`. No `TextEditingController`, `ScrollController`, `AnimationController`, `StreamSubscription`, `Timer`, or `FocusNode` is created in `lib/src/gallery/`. |
| 3 | Dependency Direction | **PASS** | Gallery production files import Flutter plus package-internal DS layers/registry only: `design_system_gallery_sections.dart:8-12`, `design_system_gallery_page.dart:9-12`, `design_system_gallery_registry.dart:7-8`. Gallery tests use the public barrel at `test/gallery/design_system_gallery_test.dart:1-3`. |
| 4 | UI Accessibility | **PARTIAL** | Direct `Semantics(` count in `design_system_gallery_sections.dart` is `0`; semantics are delegated to DS components. Direct interactive-marker counts in that file: `onTap:` `8`, `onReorder:` `1`, `onMove:` `1`, `onClose:` `2`, `DSSearchBar(` `1`, `DSFilterChipGroup(` `2`, `DSSidebar(` `2`, `DSTopbarAction(` `2`, `DSActionsCell(` `1`, `DSTabBar(` `2`, `DSChip(` `7`. Representative delegated semantic surfaces exist, but this task does not prove all 27 direct gallery interactive affordance call-sites meet semantics/touch-target/contrast requirements. |
| 5 | Proof Reality | **PARTIAL** | Existing tests pass (`13/13`) and claimed files exist, but the analyzer claim is not reproducible. Completion Evidence claims analyzer PASS at task line `129`; current analyzer result reports `296` info-level diagnostics. |
| 6 | Release Security | **PARTIAL** | No `print(`, `debugPrint(`, `dart:io`, `http`, `dio`, `AsyncValue`, `ref.watch`, `ref.read`, `Provider`, or `GoRouter` appears in `lib/src/gallery/`. However `design_system_gallery_sections.dart:1716-1719` hardcodes a secret-shaped demo value `sk-1234567890abcdef`; use an unmistakably non-secret placeholder instead. |

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | `REGRESSION` | **High** | Open | Gallery analyzer scope is not clean: exact current count is `296` info-level issues. This violates Analyzer Integrity and contradicts the previous Task 1304 report. | `docs/reports/build-gate-review/1303-review.md` as gallery backlog; contradicted by `docs/reports/build-gate-review/1304-review.md` | Command: `flutter analyze lib/src/gallery/`; lines `design_system_gallery_sections.dart:163`, `:373`, `:393`, `:2477`, `:2479` |
| F2 | `NEW` | **Low** | Open | Two tab demo controller listeners call `setState` without explicit `mounted` guards and are not removed before controller disposal. The controllers are owner-disposed, so blast radius is low, but this still fails the strict lifecycle listener pattern required by the harness. | This review | `design_system_gallery_sections.dart:2683`, `:2687-2689`, `:2750`, `:2754-2756` |
| F3 | `NEW` | **Moderate** | Open | Gallery contains a hardcoded secret-shaped value in a demo secret cell. Even if fake, `sk-...` strings should not be committed to release-path source. | This review | `design_system_gallery_sections.dart:1716-1719` |
| F4 | `EVIDENCE_GAP` | **Moderate** | Open | Completion Evidence and prior review evidence overstate analyzer status. Current checkout does not reproduce `No issues found` for the gallery analyzer scope. | This review | `docs/tasks/03-review/1304-warp-prism-gallery-compile-boundary-cleanup.md:129`; `docs/reports/build-gate-review/1304-review.md:21-23`; current command output |
| F5 | `EXTERNAL_BLOCKER` | **Low** | Open outside Task 1304 | Dependency freshness remains outside this task: `dart pub outdated` reports `7` constrained older-than-resolvable dependencies and `3` locked older dependencies. | Previous build-gate reports | `packages/warp_prism_ui/pubspec.yaml:10-17`; command: `dart pub outdated` |
| F6 | `RESOLVED` | **Safe** | Closed | Gallery test public-boundary issue remains fixed: tests import public barrel only, and gallery suite passes. | `docs/reports/build-gate-review/1304-review.md` | `test/gallery/design_system_gallery_test.dart:1-3`; command: `flutter test test/gallery/` |

## Evidence Reviewed

- **Task file inspected**: `docs/tasks/03-review/1304-warp-prism-gallery-compile-boundary-cleanup.md`.
- **Governance inspected**:
  - `AGENTS.md`
  - `.agents/rules/definition-of-done.md`
  - `.agents/skills/code-quality-harness/SKILL.md`
  - `.agents/skills/flutter-harness/SKILL.md`
  - `.agents/skills/code-quality-harness/workflows/review-report-lineage.md`
- **Previous reports inspected**:
  - `docs/reports/build-gate-review/1303-review.md`
  - `docs/reports/build-gate-review/1304-review.md`
- **Where-table source/test files inspected before report write**:
  - `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`
  - `packages/warp_prism_ui/test/gallery/design_system_gallery_test.dart`
  - `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_page.dart`
- **Additional evidence files inspected**:
  - `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_registry.dart`
  - `packages/warp_prism_ui/lib/warp_prism_ui.dart`
  - `packages/warp_prism_ui/pubspec.yaml`
  - `packages/warp_prism_ui/analysis_options.yaml`
  - `docs/changelog/2026-06-09-task-1304-gallery-boundary-cleanup.md`
- **Claimed files existence verification**:
  - `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` exists.
  - `packages/warp_prism_ui/test/gallery/design_system_gallery_test.dart` exists.
  - `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_page.dart` exists.
  - `docs/changelog/2026-06-09-task-1304-gallery-boundary-cleanup.md` exists.
- **Runtime wiring proof**: `DesignSystemGalleryPage` renders every registry entry through `for (final section in dsGallerySections)` at `design_system_gallery_page.dart:32-35`; registry contains exactly `10` section specs at `design_system_gallery_registry.dart:50-115`; public barrel exports gallery page/registry/sections at `warp_prism_ui.dart:29-32`.

## Commands Run

From `packages/warp_prism_ui/` unless noted otherwise:

| Command | Result | Evidence |
| --- | --- | --- |
| `flutter analyze lib/src/gallery/` | **FAIL analyzer-integrity / PASS compile-error boundary** | Reports `296 issues found`: `296` info-level diagnostics, `0` warnings, `0` errors. This proves compile errors are gone but analyzer integrity is not clean. |
| `flutter test test/gallery/` | **PASS** | `13` tests passed, `0` failed. Output ends with `All tests passed!`. |
| `dart format --set-exit-if-changed lib/src/gallery/` | **PASS** | `Formatted 3 files (0 changed) in 0.12 seconds.` |
| `dart analyze --format=machine lib/src/gallery/` | **FAIL analyzer-integrity** | Exact split: total `296`; `INFO DEPRECATED_MEMBER_USE` `3`, `INFO PREFER_CONST_CONSTRUCTORS` `274`, `INFO PREFER_CONST_LITERALS_TO_CREATE_IMMUTABLES` `19`. |
| `dart analyze --format=machine lib/src/gallery/ test/gallery/` | **FAIL analyzer-integrity** | Same exact split: total `296`; all diagnostics are in `design_system_gallery_sections.dart`. |
| `dart pub outdated` | **INFO / EXTERNAL_BLOCKER** | Reports `7` dependencies constrained older than resolvable versions and `3` locked older dependencies; dependency upgrades are protected work outside Task 1304. |

## Path To 100

1. **Make the requested analyzer command clean**: fix all `296` gallery diagnostics, then re-run `flutter analyze lib/src/gallery/` until it reports zero errors, zero warnings, and zero info-level issues. Start with the three non-const categories:
   - Replace deprecated `withOpacity` calls at `design_system_gallery_sections.dart:163`, `:2477`, and `:2479` with `withValues(alpha: ...)`.
   - Add `const` constructors and `const` immutable literals for the exact `274 + 19` const diagnostics reported by `dart analyze --format=machine lib/src/gallery/`.
2. **Harden the tab-demo listener lifecycle**: replace the anonymous listeners at `design_system_gallery_sections.dart:2683` and `:2750` with named `VoidCallback` fields that do `if (!mounted) return; setState(() {});`; remove each listener in `dispose()` before `_controller.dispose()`.
3. **Remove the secret-shaped demo value**: change `design_system_gallery_sections.dart:1716-1719` from `fullValue: 'sk-1234567890abcdef'` to an unmistakably inert placeholder such as `fullValue: 'example-redacted-secret-value'`, and adjust the masked value to avoid `sk-` credential shape.
4. **Strengthen proof coverage for all registered sections**: add a gallery widget test that iterates `dsGallerySectionTitles` and uses `_findByScrolling` to prove all `10` registered sections render, not only the legacy five atomic layer labels.
5. **Re-run and record proof**: `flutter analyze lib/src/gallery/`, `flutter test test/gallery/`, `dart format --set-exit-if-changed lib/src/gallery/`, and, if claiming package health, also run the package-level analyzer/test commands separately with exact issue/test counts.

## Task Ledger Patch Suggestion

```markdown
### 2026-06-13 — review-wave-1
**Score**: 62/100 — Debt
**Verdict**: REJECTED → return to doing / no move by reviewer
**Report**: `docs/reports/review-wave-1/1304-review.md`
**Previous Reports**: `docs/reports/build-gate-review/1303-review.md`; `docs/reports/build-gate-review/1304-review.md`
**Diagnostics**: `flutter analyze lib/src/gallery/` FAIL analyzer-integrity with 296 info-level diagnostics (274 prefer_const_constructors, 19 prefer_const_literals_to_create_immutables, 3 deprecated_member_use); `flutter test test/gallery/` PASS 13/13; `dart format --set-exit-if-changed lib/src/gallery/` PASS 3 files, 0 changed.
**Current Open Blockers**: `REGRESSION` analyzer scope not clean; `NEW` two tab controller listeners lack explicit mounted guards/listener removal; `NEW` secret-shaped demo string `sk-1234567890abcdef` in gallery source; `EVIDENCE_GAP` prior analyzer-clean claim is not reproducible.
**Path-to-100 Summary**: clean all 296 analyzer diagnostics, harden tab listener lifecycle, replace secret-shaped placeholder, add a registry-driven all-10-sections render test, then re-run analyzer/test/format proof.
```
