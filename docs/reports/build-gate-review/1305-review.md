# Build-Gate Review: 1305 — Catalog Contract Expansion

**Date**: 2026-06-12  
**Reviewer**: Implacable Flutter Reviewer / gt-build-review  
**Task file**: `docs/tasks/02-doing/1305-warp-prism-catalog-contract-expansion.md`  
**Verdict**: **REJECTED — stays in `docs/tasks/02-doing/`**  
**Score**: **66/100 — Debt**

## Executive Verdict

Task 1305 is not build-gate approvable. The good news is real: `flutter test` now executes and reports **14/14 passing**, the gallery page is registry-backed, stable section IDs exist, a duplicate section-ID test exists, a high-text-scale test exists, and four layer-named state-matrix tests exist.

The gate still fails because `flutter analyze lib/ test/` returns **3 info-level issues**, violating Analyzer Integrity. The proof surface is also weaker than the task contract: the duplicate-ID proof covers only **10 section IDs**, not component/case IDs; the high-text-scale assertion is vacuous (`overflowCount >= 0`); the state-matrix tests are layer-labeled but shallow; and the responsive tests prove renderability/no overflow, not layout adaptation.

No lane move was performed because the score is below 90.

## Diagnostics

| Command / Check | Result | Exact Evidence |
|---|---:|---|
| `TMPDIR=/home/sephiroth/working/ganthritor/warp-prism/tmp PUB_CACHE=/home/sephiroth/working/ganthritor/warp-prism/tmp/pub-cache flutter test` from `apps/catalog` | PASS | **14/14 passed** in 01:01. Test declarations counted: **14** (`apps/catalog/test/widget_test.dart:45`, `:53`, `:67`, `:77`, `:94`, `:113`, `:139`, `:195`, `:218`, `:241`, `:301`, `:347`, `:393`, `:408`). |
| `TMPDIR=/home/sephiroth/working/ganthritor/warp-prism/tmp PUB_CACHE=/home/sephiroth/working/ganthritor/warp-prism/tmp/pub-cache flutter analyze lib/ test/` from `apps/catalog` | FAIL | **3 info issues**: `prefer_const_constructors` at `apps/catalog/test/widget_test.dart:246`, `:247`, `:248`. Analyzer Integrity requires 0 errors, 0 warnings, 0 infos. |
| `dart format --set-exit-if-changed lib/ test/` from `apps/catalog` | FAIL | Reported `Formatted test/widget_test.dart` and `Formatted 2 files (1 changed)`. This command has a formatting side effect; it is recorded as a failed formatting gate, not an approval patch. |
| Stable gallery registry IDs | PASS | `DSGallerySectionSpec.id` exists at `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_registry.dart:15-20`; **10** section specs are registered at `:50-115`; `dsGallerySectionIds` returns IDs at `:117-121`. |
| Duplicate-ID test exists | PARTIAL | Section-ID uniqueness test exists at `apps/catalog/test/widget_test.dart:53-64`. No component/case-ID uniqueness test exists (`grep` found 0 `componentIds`/`caseIds`/component-ID registry matches in `apps/catalog/test` and `packages/warp_prism_ui/lib/src/gallery`). |
| High text scale test exists | PARTIAL | Test exists at `apps/catalog/test/widget_test.dart:240-297` and uses `MediaQueryData(textScaler: TextScaler.linear(2.0))` at `:249`; assertion at `:285-287` is vacuous because every integer overflow count is `>= 0`. |
| State matrix tests cover all 4 layers | PARTIAL | Four layer-named tests exist: atom `apps/catalog/test/widget_test.dart:113-137`, molecule `:139-193`, organism `:195-216`, template `:218-237`. Only molecule enumerates multiple state cases; atom/template are presence checks, not Task 1106 matrix coverage. |

## Six Axiom Compliance

| # | Axiom | Status | Evidence |
|---:|---|---|---|
| 1 | Analyzer Integrity | **FAIL** | Analyzer returned **3 info-level issues** at `apps/catalog/test/widget_test.dart:246-248`. `analysis_options.yaml` explicitly enables `prefer_const_constructors` at `apps/catalog/analysis_options.yaml:3-7`; no justified suppression exists. |
| 2 | Lifecycle Safety | **PASS** | `apps/catalog/lib` + `apps/catalog/test` contain **0** controllers/subscriptions/timers/listener registrations/dispose obligations. Reviewed gallery source contains **2** `DSTabController` fields (`design_system_gallery_sections.dart:2630`, `:2710`), **2** `addListener` calls (`:2674`, `:2741`), and **2** matching controller disposals (`:2677-2680`, `:2744-2747`). Classification: SAFE. |
| 3 | Dependency Direction | **PARTIAL** | Runtime app imports only Flutter + public UI barrel at `apps/catalog/lib/main.dart:1-2`. Test imports the public barrel at `apps/catalog/test/widget_test.dart:12` but also uses an implementation import at `:13-14` to access `ds_operational_state.dart`. That is a boundary leak in a consumer app test. Classification: MODERATE. |
| 4 | UI Accessibility | **PARTIAL** | Task is mainly test/registry work. Catalog app/test declare **0** interactive widgets and **0** `Semantics` widgets. Gallery source contains **8** callback-style interactive demo entries and **8** `semanticLabel` occurrences, but **0** `Semantics(` widgets in the reviewed gallery source. High-text-scale proof tolerates any overflow at `apps/catalog/test/widget_test.dart:285-287`. Classification: MODERATE. |
| 5 | Proof Reality | **PARTIAL** | `flutter test` proves **14/14 pass**, but some tests are not proving the promised contracts: high text scale uses `overflowCount >= 0` at `apps/catalog/test/widget_test.dart:285-287`; responsive tests assert section renderability/ListView presence rather than breakpoint adaptation at `:300-428`; duplicate-ID proof is section-only at `:53-64`. Classification: MODERATE. |
| 6 | Release Security | **PASS** | `apps/catalog/lib` + `apps/catalog/test` contain **0** `print(`, **0** `debugPrint(`, and **0** obvious API-key/token/secret/password matches. Task does not alter release signing, permissions, endpoints, or obfuscation config. Classification: SAFE. |

## Findings

### High

1. **[HIGH] Analyzer Integrity is still broken by 3 info-level issues.**  
   Evidence: `flutter analyze lib/ test/` reports `prefer_const_constructors` at `apps/catalog/test/widget_test.dart:246`, `:247`, `:248`; lint is enabled at `apps/catalog/analysis_options.yaml:3-7`.  
   **Recommendation**: make the high-text-scale wrapper const where legal:
   ```dart
   await tester.pumpWidget(
     const MaterialApp(
       home: Scaffold(
         body: MediaQuery(
           data: MediaQueryData(textScaler: TextScaler.linear(2.0)),
           child: DesignSystemGalleryPage(),
         ),
       ),
     ),
   );
   ```
   Then rerun `flutter analyze lib/ test/` from `apps/catalog` and require 0 issues.

2. **[HIGH] High-text-scale proof is vacuous and allows unlimited overflow.**  
   Evidence: `apps/catalog/test/widget_test.dart:274-287` computes `overflowCount` and asserts `greaterThanOrEqualTo(0)`. That passes for 0, 13, or 130 overflows.  
   **Recommendation**: install `FlutterError.onError` before the initial `pumpWidget`, fail on `RenderFlex overflowed` and `RenderBox was not laid out`, and assert `overflowCount == 0`. Remove the approximate `~13` comment at `:284` because exact-count policy forbids approximations in proof claims.

3. **[HIGH] Formatting gate is not clean.**  
   Evidence: `dart format --set-exit-if-changed lib/ test/` from `apps/catalog` reported `Formatted test/widget_test.dart` and `Formatted 2 files (1 changed)`.  
   **Recommendation**: run formatting intentionally, inspect the diff, and rerun `dart format --set-exit-if-changed lib/ test/` until it exits cleanly with no changed files.

### Medium

4. **[MEDIUM] Duplicate-ID proof covers section IDs only, not component/case IDs from the task objective.**  
   Evidence: registry has **10** section IDs at `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_registry.dart:50-115`; test asserts `dsGallerySectionIds` uniqueness at `apps/catalog/test/widget_test.dart:53-64`. `grep` found **0** component/case ID registry or test matches in the gallery/test surface.  
   **Recommendation**: add a component/case registry, for example `DSGalleryCaseSpec(sectionId, id, label, builder)`, expose `dsGalleryCaseIds`, and add a test asserting global uniqueness for `'$sectionId/$caseId'` or globally stable case IDs.

5. **[MEDIUM] State matrix coverage is nominal, not complete.**  
   Evidence: four layer-named tests exist, but atom `apps/catalog/test/widget_test.dart:113-137` checks component presence plus one disabled chip label; template `:218-237` checks preview names/descriptions; only molecule `:139-193` enumerates empty/loading/error/disabled/stale/degraded/excluded; organism `:195-216` iterates operational labels but not default/loading/empty/error/degraded/disabled/long-text/narrow/high-scale cases.  
   **Recommendation**: define exact per-layer case lists and assert each applicable Task 1106 case renders: default, loading, empty, error/degraded, disabled, long text, narrow, and high text scale. If a case is not applicable to a layer, encode that exemption in the test data with a reason.

6. **[MEDIUM] Responsive tests still do not prove adaptation.**  
   Evidence: compact/expanded tests at `apps/catalog/test/widget_test.dart:300-390` assert all section headings render and no `RenderFlex overflowed` string was captured; the final viewport test at `:408-438` asserts `ListView` exists at 800px and 1400px.  
   **Recommendation**: assert a measurable breakpoint contract: section card width changes with viewport, Wrap row count changes, sidebar/template geometry changes, or a public breakpoint/layout mode value changes between 800px and 1400px.

7. **[MEDIUM] Consumer test uses an implementation import.**  
   Evidence: `apps/catalog/test/widget_test.dart:13-14` imports `package:warp_prism_ui/src/tokens/ds_operational_state.dart` despite the package barrel at `packages/warp_prism_ui/lib/warp_prism_ui.dart:15-21` stating consumer apps should use Prism names.  
   **Recommendation**: expose the needed operational-state label through the public API, or add a public `PrismOperationalState` helper/extension exported by `warp_prism_ui.dart`; remove the `src/` import.

### Low

8. **[LOW] Changelog evidence is stale after the latest fixes.**  
   Evidence: `docs/changelog/2026-06-09-task-1305-catalog-contract-expansion.md:15-31` still says the test expanded to **10** contract tests and duplicate proof checks headings, while current test declarations are **14** and section-ID registry proof exists.  
   **Recommendation**: update the changelog after final gate success with the exact test count, registry proof, and analyzer/test outputs.

## Exit Condition Assessment

| Exit Condition | Status | Evidence |
|---|---|---|
| `apps/catalog/test/widget_test.dart` verifies all sections render | PASS | Registry-backed render test at `apps/catalog/test/widget_test.dart:77-91`; page consumes registry at `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_page.dart:32-35`. |
| Duplicate IDs checked | PARTIAL | Section IDs only at `apps/catalog/test/widget_test.dart:53-64`; no component/case IDs. |
| At least 4 state matrix tests, one per layer | PARTIAL | Four tests exist at `apps/catalog/test/widget_test.dart:113-237`, but not all prove state matrices. |
| At least 1 responsive layout test exists | PARTIAL | Tests exist at `apps/catalog/test/widget_test.dart:300-438`, but adaptation is not measured. |
| Local changelog entry added | PASS | `docs/changelog/2026-06-09-task-1305-catalog-contract-expansion.md` exists; content is stale. |
| Completion Evidence filled | PASS / STALE | `docs/tasks/02-doing/1305-warp-prism-catalog-contract-expansion.md:126-140` is filled, but its old `10/10` test claim is stale relative to current **14/14** output and current analyzer failure. |

## Path to 100

1. Fix `apps/catalog/test/widget_test.dart:246-248` const-constructor analyzer infos; rerun `flutter analyze lib/ test/` to 0 issues.
2. Run `dart format --set-exit-if-changed lib/ test/` from `apps/catalog` until it exits cleanly without changing files.
3. Replace the high-text-scale assertion at `apps/catalog/test/widget_test.dart:285-287` with an exact no-overflow assertion and capture `FlutterError.onError` before the first pump.
4. Remove the implementation import at `apps/catalog/test/widget_test.dart:13-14` by exporting a public Prism operational-state label helper or extension.
5. Add component/case stable IDs and a duplicate-ID test over those IDs, not just section IDs.
6. Expand the four state-matrix tests so each layer enumerates exact applicable cases for default/loading/empty/error-degraded/disabled/long-text/narrow/high-scale, with explicit exemptions where a case is impossible.
7. Strengthen responsive tests to compare compact vs expanded geometry or public breakpoint behavior.
8. Update the changelog and task completion evidence with exact current counts: tests declared, tests passed, analyzer issue count, and formatting status.
9. Re-run from `apps/catalog` with repo-local temp/cache only: `flutter analyze lib/ test/`, `dart format --set-exit-if-changed lib/ test/`, and `flutter test`. Optional: regenerate `coverage/lcov.info` only after the first three gates pass.

## Routing

Score **66/100** is below the requested **90** threshold. I did **not** move the task to `docs/tasks/03-review/`. The task remains in `docs/tasks/02-doing/` with a path-to-100 ledger entry.
