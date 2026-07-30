# Build-Gate Review: 1307 — Accessibility and Semantics Reconciliation

**Date**: 2026-06-12  
**Reviewer**: Implacable Flutter Reviewer / gt-build-review  
**Task file**: `docs/tasks/02-doing/1307-warp-prism-accessibility-and-semantics-reconciliation.md`  
**Review mode**: build-gate re-review after builder fixes  
**Final score**: **85/100 — Good**  
**Verdict**: **REJECTED — stays in `docs/tasks/02-doing/`**

## Executive Verdict

Task 1307 is materially improved but still not build-gate approved.

Accepted fixes:

- `DSAssetCard` has real semantics at `packages/warp_prism_ui/lib/src/molecules/ds_asset_card.dart:43-56`.
- `DSChip.removable` has independent remove-action semantics and a 48x48 remove target at `packages/warp_prism_ui/lib/src/atoms/ds_chip.dart:280-304`.
- The targeted accessibility suite passes: `flutter test test/accessibility/` → **20/20 PASS**.
- The full package suite now passes: `flutter test` → **871/871 PASS**.

Approval blockers:

1. Analyzer Integrity is still false: `flutter analyze lib/` reports **450 issues**.
2. Shell focus traversal tests exist, but they still do not prove traversal order or focused node identity.
3. The package-wide “all interactive components have semantic labels” claim remains unproven by inventory-backed tests.
4. Three directly audited touch targets remain below 48x48: `DSChip`, `_FilterChip`, and `DSTopbarAction`.

No reviewer patch was applied because the score is below the user-specified `>= 90` patch threshold.

## Diagnostics

All commands were run from `packages/warp_prism_ui` with temp/cache constrained inside the repo via `TMPDIR=/home/sephiroth/working/ganthritor/warp-prism/tmp` and `PUB_CACHE=/home/sephiroth/working/ganthritor/warp-prism/tmp/pub-cache`.

| Command | Result | Evidence |
|---|---:|---|
| `flutter test test/accessibility/` | PASS | **20/20** tests passed. |
| `flutter test` | PASS | **871/871** tests passed. Boundary harness printed **6/6 PASS, 0 FAIL, 0 violations**. |
| `flutter analyze lib/` | FAIL | **450 issues found**. Includes 1 warning (`unused_local_variable`) plus info-level lint/deprecation issues. Task-touched examples remain in `ds_asset_card.dart`, `ds_filter_chip_group.dart`, `ds_shell.dart`, `ds_sidebar.dart`, and `ds_topbar.dart`. |
| `dart format --set-exit-if-changed lib/ test/` | PASS | `Formatted 126 files (0 changed)`. |
| `dart pub outdated` | INFO | **7 dependencies constrained** below resolvable versions; **3 upgradable dependencies locked** by `pubspec.lock`. |
| Codegen check | PASS / N/A | `packages/warp_prism_ui/**/*.g.dart` = 0 files; `packages/warp_prism_ui/**/*.freezed.dart` = 0 files. No generated Dart drift surface found. |
| Suppression check | PASS | `packages/warp_prism_ui/analysis_options.yaml:1-7` has no `ignore:` / `ignore_for_file` suppressions. |

## Six-Axiom Compliance

| # | Axiom | Status | Evidence |
|---:|---|---|---|
| 1 | Analyzer Integrity | **FAIL** | `flutter analyze lib/` reports **450 issues**. Axiom requires zero warnings and zero info-level issues. `analysis_options.yaml:1-7` includes `flutter_lints` plus `prefer_const_constructors`, `prefer_const_declarations`, and `avoid_print`; no documented suppressions found. |
| 2 | Lifecycle Safety | **PASS for task scope** | Exact task-scoped disposable count: **6 created, 6 disposed**. `DSChip` 1 `FocusNode` (`ds_chip.dart:145`) disposed at `:181-183`; `_FilterChip` 1 `FocusNode` (`ds_filter_chip_group.dart:69`) disposed at `:71-74`; `DSSearchBar` 1 `TextEditingController` + 1 `FocusNode` (`ds_search_bar.dart:35-43`) disposed at `:63-67`; `_SidebarItemWidget` 1 `FocusNode` (`ds_sidebar.dart:176`) disposed at `:178-181`; `DSTopbarAction` 1 `FocusNode` (`ds_topbar.dart:156`) disposed at `:158-161`. `DSSearchBar` has **2** listeners (`ds_search_bar.dart:44-52`), both callbacks guard `mounted`. |
| 3 | Dependency Direction | **PASS** | Task-scoped implementation imports only Flutter/services and local DS layers: `ds_chip.dart:1-3`, `ds_filter_chip_group.dart:1-3`, `ds_search_bar.dart:1-3`, `ds_asset_card.dart:1-3`, `ds_shell.dart:1-2`, `ds_sidebar.dart:1-4`, `ds_topbar.dart:1-4`. Full test output boundary harness: **6/6 PASS, 0 violations**. |
| 4 | UI Accessibility | **PARTIAL** | Fixed: `DSAssetCard` semantics (`ds_asset_card.dart:43-56`), removable-chip remove semantics and 48x48 target (`ds_chip.dart:280-304`), search text-field semantics (`ds_search_bar.dart:92-95`), search clear/filter button semantics and 48x48 targets (`ds_search_bar.dart:174-190`), sidebar item semantics (`ds_sidebar.dart:208-215`), topbar action semantics (`ds_topbar.dart:177-180`). Gaps: shell traversal proof remains vacuous (`design_system_accessibility_test.dart:437-602`); `DSChip` heights are 24/28/32 (`ds_chip.dart:147-156`), `_FilterChip` height is 28 (`ds_filter_chip_group.dart:112-115`), `DSTopbarAction` is 40x40 (`ds_topbar.dart:201-202`). |
| 5 | Proof Reality | **PARTIAL** | Targeted suite passes **20/20** and full suite passes **871/871**. Real `DSAssetCard` assertions exist at `design_system_accessibility_test.dart:186-328`; real removable-chip assertions exist at `:376-434`. Shell focus tests exist at `:437-602`, but contain **0** `FocusManager`, **0** `primaryFocus`, **0** `hasFocus` assertions, and **0** traversal-order assertions. |
| 6 | Release Security | **PARTIAL** | Task-scoped files contain no API keys, tokens, network calls, persistence writes, `print()`, or `debugPrint()` calls. Android R8/ProGuard and release obfuscation/split-debug-info were not verified because Task 1307 is package-scoped accessibility remediation. |

## Required Key Diagnostics

| User diagnostic | Status | Evidence |
|---|---|---|
| `flutter test test/accessibility/` all pass | **PASS** | **20/20** passed. |
| `flutter test` expect 871 pass | **PASS** | **871/871** passed. |
| Check `DSAssetCard` has semantics | **PASS** | `Semantics(label: semanticLabel, button: isInteractive, enabled: isInteractive, selected: selected, explicitChildNodes: true)` at `ds_asset_card.dart:43-49`; visual subtree excluded at `:55-56`. |
| Check shell focus traversal tests exist | **PARTIAL** | Tests exist at `design_system_accessibility_test.dart:437-602`, but they do not prove focus traversal. They send Tab/Shift+Tab at `:591-597` and assert only that sidebar semantics still render at `:600-601`. |
| Check `DSChip.removable` has semantics | **PASS** | Independent `Semantics(label: 'Remove ${widget.label}', button: true, enabled: widget.enabled)` at `ds_chip.dart:280-284`; 48x48 target at `:285-286`; regression test at `design_system_accessibility_test.dart:376-434`. |

## Exact Counts Audited

### Lifecycle resources in task-scoped implementation files

| File | Resource creations | Disposal evidence | Classification |
|---|---:|---|---|
| `lib/src/atoms/ds_chip.dart` | 1 `FocusNode` (`:145`) | 1 `_focusNode.dispose()` (`:181-183`) | SAFE |
| `lib/src/molecules/ds_filter_chip_group.dart` | 1 `FocusNode` (`:69`) | 1 `_focusNode.dispose()` (`:71-74`) | SAFE |
| `lib/src/molecules/ds_search_bar.dart` | 1 `TextEditingController` + 1 `FocusNode` (`:35-43`); 2 listeners (`:44-52`) | `_controller.dispose()` + `_focusNode.dispose()` (`:63-67`); both listener callbacks check `mounted` | SAFE |
| `lib/src/molecules/ds_asset_card.dart` | 0 disposable resources | N/A | SAFE |
| `lib/src/organisms/ds_shell.dart` | 0 disposable resources | N/A | SAFE |
| `lib/src/organisms/ds_sidebar.dart` | 1 `FocusNode` (`:176`) | 1 `_focusNode.dispose()` (`:178-181`) | SAFE |
| `lib/src/organisms/ds_topbar.dart` | 1 `FocusNode` (`:156`) | 1 `_focusNode.dispose()` (`:158-161`) | SAFE |

**Total audited lifecycle resources**: **6** disposable resources created, **6** disposed, **0** lifecycle leaks.  
**Total audited listeners**: **2** listeners attached, **2** callbacks guarded by `mounted`, **0** use-after-unmount findings.

### Interactive semantics in directly audited Task 1307 scope

| Surface | Interactive declaration/instance count audited | Semantic coverage | Classification |
|---|---:|---|---|
| `DSChip` main chip | 1 main `GestureDetector` declaration (`ds_chip.dart:226-228`) | Outer `Semantics(label: widget.label, button: isInteractive, selected: widget.selected, enabled: widget.enabled)` (`ds_chip.dart:207-213`) | SAFE for label; LOW for 24/28/32 hit height |
| `DSChip.removable` remove action | 1 trailing `InkWell` declaration (`ds_chip.dart:289-301`) | `Semantics(label: 'Remove ${widget.label}', button: true, enabled: widget.enabled)` (`ds_chip.dart:280-284`) plus 48x48 target (`:285-286`) | SAFE |
| `DSFilterChipGroup` item chip | 1 `_FilterChip` `GestureDetector` declaration (`ds_filter_chip_group.dart:107-109`) | `Semantics(label: widget.option.label, button: true, selected: widget.isSelected)` (`ds_filter_chip_group.dart:89-94`) | SAFE for label; LOW for 28 hit height |
| `DSSearchBar` text input | 1 `TextField` declaration (`ds_search_bar.dart:95-112`) | `Semantics(textField: true, label: widget.placeholder ?? 'Search query')` (`ds_search_bar.dart:92-95`) | SAFE in code; PARTIAL in tests |
| `DSSearchBar` clear/filter buttons | 2 `_IconButton` call sites (`ds_search_bar.dart:116-124`, `:135-139`) using 1 `InkWell` implementation (`:182-188`) | `_IconButton` `Semantics(button: true, enabled: onTap != null, label: semanticLabel)` (`:174-178`) plus 48x48 target (`:178-180`) | SAFE in code; PARTIAL in tests |
| `DSSidebar` item | 1 item `GestureDetector` declaration (`ds_sidebar.dart:232-234`) | `Semantics(label: semanticLabel, hint: semanticHint, button: true, selected: widget.isSelected, enabled: true)` (`ds_sidebar.dart:208-215`) | SAFE for label; MODERATE proof gap for shell traversal |
| `DSTopbarAction` | 1 `GestureDetector` declaration (`ds_topbar.dart:197-199`) | `Semantics(label: widget.tooltip ?? 'Action button', button: true)` (`ds_topbar.dart:177-180`) | SAFE for label; LOW for 40x40 hit target |
| `DSAssetCard` | 1 `GestureDetector` declaration (`ds_asset_card.dart:49-50`) | `Semantics(label: '$kind asset: $name', button/enabled/selected)` (`ds_asset_card.dart:43-48`) plus `ExcludeSemantics` (`:55-56`) | SAFE |

**Direct task/test interactive coverage count**: **9** audited surfaces. Classification: **5 SAFE**, **3 SAFE-in-code with PARTIAL/LOW proof or hit-target debt**, **1 MODERATE proof gap**.  
**Raw package-wide grep count**: **126** raw matches for `GestureDetector|InkWell|IconButton|TextButton|ElevatedButton|OutlinedButton|RawGestureDetector|TextField|DSTopbarAction|DSChip|DSSearchBar|DSAssetCard` under `packages/warp_prism_ui/lib/src`. This raw count includes docs, aliases, call sites, and declarations; it is not a verified accessibility inventory.  
**Package-wide `Semantics(` count**: **63** raw matches under `packages/warp_prism_ui/lib/src`.

## Findings

### Critical

None in task-scoped implementation.

### High

- **[HIGH] [PERSISTENT] Analyzer Integrity is false, so Axiom 1 fails.**  
  Evidence: `flutter analyze lib/` reports **450 issues**. Task-touched examples include `packages/warp_prism_ui/lib/src/molecules/ds_asset_card.dart:34`, `:37`, `:73`, `:138`; `packages/warp_prism_ui/lib/src/molecules/ds_filter_chip_group.dart:81`, `:84`, `:121`, `:148`; `packages/warp_prism_ui/lib/src/organisms/ds_shell.dart:171`, `:182`, `:184`, `:185`; `packages/warp_prism_ui/lib/src/organisms/ds_sidebar.dart:37`, `:39`, `:40`, `:119`, `:122`, `:188`, `:249`, `:252`; `packages/warp_prism_ui/lib/src/organisms/ds_topbar.dart:36`, `:38`, `:39`, `:109`, `:111`, `:167`, `:208`.  
  Recommendation: replace task-touched `withOpacity` calls with `withValues`, add requested `const` constructors/literals, then burn down or formally baseline remaining package issues until `flutter analyze lib/` returns zero warnings and zero info-level issues.

### Medium

- **[MEDIUM] [PERSISTENT] Shell focus traversal tests exist but are not real traversal proof.**  
  Evidence: `packages/warp_prism_ui/test/accessibility/design_system_accessibility_test.dart:437-480` checks only that shell/sidebar/topbar semantics render. `:482-555` instantiate `DSSidebar`, not `DSShell`, and acquire focus by tap before key events. `:557-602` sends Tab and Shift+Tab at `:591-597`, then asserts only that `Navigation sidebar` still renders at `:600-601`. Grep found **0** `FocusManager`, **0** `primaryFocus`, **0** `hasFocus` assertions, and **0** traversal-order assertions in the accessibility test file.  
  Recommendation: replace the current `DSShell — Focus Traversal` group with tests that instantiate full `DSShell`, traverse exclusively via keyboard, and assert focused widget/semantics identity after each Tab and Shift+Tab step for sidebar item → search `TextField` → topbar action/content. Reset activation counters immediately before Enter/Space and assert each key activates exactly once.

- **[MEDIUM] [EVIDENCE_GAP] “All interactive components have semantic labels” remains unproven package-wide.**  
  Evidence: Task 1307 directly audits **9** interactive surfaces, while raw package grep returned **126** matches for interactive/component terms and **63** `Semantics(` calls under `lib/src`. The test suite does not contain assertions for `DSSearchBar` clear/filter button labels (`Clear search query`, `Open search filters`) despite code labels at `ds_search_bar.dart:116-139` and `:174-178`.  
  Recommendation: either narrow the claim to the 9 Task 1307 surfaces and assert all 9 labels/flags explicitly, or create an inventory-backed package accessibility test that maps each interactive declaration/call site to semantic label and touch-target evidence.

### Low

- **[LOW] [PERSISTENT] Three directly audited touch targets remain below 48x48.**  
  Evidence: `DSChip` visual heights are **24/28/32** at `packages/warp_prism_ui/lib/src/atoms/ds_chip.dart:147-156`; `_FilterChip` height is **28** at `packages/warp_prism_ui/lib/src/molecules/ds_filter_chip_group.dart:112-115`; `DSTopbarAction` is **40x40** via `packages/warp_prism_ui/lib/src/organisms/ds_topbar.dart:201-202` and `DSSpacing.iconButtonSize`.  
  Recommendation: wrap compact visuals in a minimum **48x48** hit region while preserving compact inner visuals; add `tester.getSize(...)` assertions for each target.

- **[LOW] [DEPENDENCY HYGIENE] Dependencies are constrained below newer resolvable versions.**  
  Evidence: `dart pub outdated` reports **7** dependencies constrained below a resolvable version and **3** upgradable dependencies locked by `pubspec.lock`.  
  Recommendation: do not change versions inside Task 1307 unless explicitly authorized; open/follow a dependency maintenance task to update constraints and validate downstream app compatibility.

## Resolved Prior Findings

| Prior finding | Current status | Evidence |
|---|---|---|
| `DSAssetCard` raw `GestureDetector` had no semantics. | **RESOLVED** | `packages/warp_prism_ui/lib/src/molecules/ds_asset_card.dart:43-56`; tests at `packages/warp_prism_ui/test/accessibility/design_system_accessibility_test.dart:186-328`. |
| `DSChip.removable` trailing remove action had no independent semantics or 48x48 target. | **RESOLVED** | `packages/warp_prism_ui/lib/src/atoms/ds_chip.dart:280-304`; test at `packages/warp_prism_ui/test/accessibility/design_system_accessibility_test.dart:376-434`. |
| Full package `flutter test` was failing. | **RESOLVED** | `flutter test` now passes **871/871**. |
| Shell focus traversal was unproven. | **PERSISTENT** | Tests at `packages/warp_prism_ui/test/accessibility/design_system_accessibility_test.dart:437-602` still perform **0** focus identity/traversal order assertions. |

## Patches Applied

None. Score is **85/100**, below the user-specified `>= 90` threshold for reviewer patching.

## Path to 100

1. Fix `DSShell — Focus Traversal` tests at `packages/warp_prism_ui/test/accessibility/design_system_accessibility_test.dart:437-602` so they assert actual focus identity and traversal order inside full `DSShell` for sidebar item → search `TextField` → topbar action/content, plus reverse traversal.
2. Rewrite Enter/Space activation tests to acquire focus by keyboard traversal inside `DSShell`; reset counters immediately before each key event; assert Enter increments exactly once and Space increments exactly once.
3. Add explicit semantics assertions for `DSSearchBar` clear/filter buttons and an inventory-backed assertion table for the 9 directly audited Task 1307 interactive surfaces.
4. Add 48x48 hit-region wrappers and size tests for `DSChip`, `_FilterChip`, and `DSTopbarAction`.
5. Clear task-touched analyzer issues in `ds_asset_card.dart`, `ds_filter_chip_group.dart`, `ds_shell.dart`, `ds_sidebar.dart`, and `ds_topbar.dart`; then reduce package analyzer output from **450 issues** to **0**.
6. Re-run from `packages/warp_prism_ui`: `flutter analyze lib/`, `dart format --set-exit-if-changed lib/ test/`, `flutter test test/accessibility/`, `flutter test`, and `dart pub outdated`; update the Review Ledger with exact outputs.

## Build-Gate Decision

**REJECTED.** Do **not** move Task 1307 to `docs/tasks/03-review/` until the focus proof gap and analyzer gate are resolved or formally scoped/baselined by project governance.
