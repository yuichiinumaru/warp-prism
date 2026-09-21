# Task 1835: Builder Iteration Report (Additive)

## Remediation Round 1 — 2026-09-07 (Fleet Engineer)

- **Agent**: `gt-builders-engineer-flutter` (fleet engineer)
- **Objective**: Remediate findings F1, F2, F3, F4 from independent review (2026-09-06, Review 1 score 82/100 FAIL), correct count claims across task documentation, and supersede initial self-review with an honest additive record.
- **Status**: COMPLETE / READY FOR INDEPENDENT RE-REVIEW

### 1. Changes Applied

1. **F1 Remediation — Full Public Surface Enumeration (`PrismSelect` Added)**:
   - `packages/warp_prism_ui/test/meta/material_ancestry_meta_test.dart:420-427`: Added `PrismSelect` specification under molecules:
     ```dart
     WidgetAncestrySpec(
       name: 'PrismSelect',
       builder: () => PrismSelect<String>(
         options: const [PrismSelectItem(value: 'a', label: 'Option A')],
         onChanged: (_) {},
       ),
       expectedClassification: AncestryClassification.selfSufficient,
     )
     ```
   - Verified classification: Bare mount throws zero exceptions (`selfSufficient`). The closed-state trigger is `GestureDetector`-driven and dropdown popup supplies its own `Material(type: MaterialType.transparency)`.
   - Total widget specs: **118** (matching the 118 public names exported by the barrel).
   - Total tests in meta-suite: **123** (5 section-1 tests + 118 section-2 classification tests).

2. **F2 Remediation — Tightened Bare-Phase Oracle**:
   - `packages/warp_prism_ui/test/meta/material_ancestry_meta_test.dart:845-860`: Tightened the `declaredPrerequisite` bare-mount assertion. Replaced loose non-null exception check with an explicit inspection of caught `FlutterErrorDetails`:
     ```dart
     expect(
       caughtErrors.any((d) => d.exceptionAsString().contains('No Material widget found')),
       isTrue,
       reason: '${spec.name} was classified as declaredPrerequisite but did not throw missing Material assertion',
     );
     ```
   - Catches missing Material assertions specifically, preventing unrelated crashes from masquerading as valid declared prerequisites.

3. **F3 Remediation — Controller Lifecycle and Teardown**:
   - `packages/warp_prism_ui/test/meta/material_ancestry_meta_test.dart:196-203, 835-842`: Added `specControllers` tracking list and `trackController` helper. In every testWidgets invocation, an `addTearDown` hook iterates through registered `ChangeNotifier` controllers (`PrismAiAnalystController`, `PrismTerminalWorkspaceController`, `PrismAgentShellPanelController`, `PrismTabController` ×2) and invokes `.dispose()`.

4. **F4 Remediation — PrismThemeEditor Height Bound Placement**:
   - `packages/warp_prism_ui/test/meta/material_ancestry_meta_test.dart:820-828`: Removed `SizedBox(height: 600)` from the builder; moved it into `prerequisiteWrapper: (child) => _materialPrerequisiteWrapper(SizedBox(height: 600, child: child))`. The bare probe now tests `PrismThemeEditor` as directly mounted by a host.

5. **Task & Metric Corrections**:
   - Updated `docs/tasks/02-doing/1835-warp-prism-material-ancestry-meta-test.md`:
     - Denominator updated: 117 → 118 specs (113 `SELF_SUFFICIENT`, 5 `DECLARED_PREREQUISITE`, 0 `UNDOCUMENTED_PREREQUISITE`).
     - Scoped suite test count: 170 → 171 tests passed.
     - Meta-suite test count: 122 → 123 tests passed.
     - Superseded prior `20260906-task-1835-self-review.md` claim of 100/100; recorded honest 2026-09-07 remediation entry in Agent Session Ledger.

### 2. Validation Commands and Results

| Command | Exit Code | Output / Evidence |
|---|---|---|
| `cd packages/warp_prism_ui && flutter analyze --no-fatal-infos --no-fatal-warnings` | **0** | `0 errors, 0 warnings` (clean gate; 212 pre-existing info baseline, 0 in touched files) |
| `cd packages/warp_prism_ui && flutter test test/meta/material_ancestry_meta_test.dart --no-pub --plain-name PrismSelect` | **0** | `+1: All tests passed!` (`PrismSelect` verified `selfSufficient`) |
| `cd packages/warp_prism_ui && flutter test test/meta/material_ancestry_meta_test.dart --no-pub` | **0** | `+123: All tests passed!` |
| `cd packages/warp_prism_ui && flutter test test/meta/material_ancestry_meta_test.dart test/organisms/filter_workbench/filter_workbench_test.dart test/organisms/ai_analyst_panel/ai_analyst_panel_test.dart test/organisms/terminal_workspace/ds_terminal_workspace_test.dart test/molecules/ds_search_bar_material_contract_test.dart --no-pub` | **0** | `+171: All tests passed!` |

### 3. Residual Risks & Epistemic Boundaries

- **Harness golden exclusion (F5 follow-up)**: Sibling golden suites do not declare `@Tags("golden")`, so full-suite runs continue to report sibling golden diffs under current test flags. Sibling goldens remain untouched per Task 1800 freeze.
- **Affected consumers**: Confirmed `NONE` per AGENTS.md §7.2; meta-test is test-only, and 3 latent organism fixes use non-painting `MaterialType.transparency`.
