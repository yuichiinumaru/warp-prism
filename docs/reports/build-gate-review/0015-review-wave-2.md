# Review Report: Task 0015 — DS Atoms and Molecules Normalization — 2026-06-14

## Review Lineage

- **Current task**: Task 0015 (`0015-warp-prism-ds-atoms-molecules-normalization`); live path `docs/tasks/03-review/0015-warp-prism-ds-atoms-molecules-normalization.md`.
- **Previous reports read**:
  - `docs/reports/build-gate-review/0015-review.md` — 100/100, approved, but accepted stale missing-SDK validation and deferred changelog as pass.
- **Related reports considered**:
  - `docs/reports/build-gate-review/0014-review.md` — upstream token contract review.
  - `docs/reports/build-gate-review/0014-review-wave-2.md` — current upstream re-review showing analyzer/naming debt.
  - `docs/reports/warp-prism-ds-inventory.md` — upstream inventory used by this task.
- **Review mode**: `re-review` / final gate.

## Score And Verdict

- **Score**: `76/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

The atom/molecule contract tests pass, and the task did add useful coverage. It still cannot be approved because the package analyzer fails and the atoms/molecules scope contains exactly 52 analyzer issues, including 2 warnings. Task 0015's own exit conditions say analyzer and tests were blocked by missing SDK; current Flutter tooling is available, tests run, and analyzer debt is real.

## Axiom Compliance

| Axiom | Status | Evidence |
| --- | --- | --- |
| Analyzer Integrity | FAIL | `flutter analyze --no-pub` in `packages/warp_prism_ui/` exits 2 with exactly 592 issues: 0 errors, 11 warnings, 581 infos. Atoms/molecules scope has exactly 52 issues: 2 warnings, 50 infos. |
| Lifecycle Safety | PASS | Counted package patterns: TextEditingController creations 2, ScrollController creations 5, AnimationController creations 4, Timer references 2, addListener calls 17, dispose declarations 22, dispose calls 57, mounted checks 11, setState calls 75. No unpaired lifecycle leak was proven in Task 0015's modified/claimed files during this review. DSStatusDot/DSGlowBorder animation controllers are disposed in their state classes; DSSearchBar owns and disposes its controller. |
| Dependency Direction | PASS | Atoms and molecules remain below organisms/templates. Contract tests import package internals, but production package exposes public aliases via `lib/warp_prism_ui.dart:21` -> `src/prism_aliases.dart`. |
| UI Accessibility | PARTIAL | Package count: 55 `Semantics` widgets vs 42 obvious interactive widget constructors (`IconButton` 3, `GestureDetector` 29, `InkWell` 6, `TextButton` 1, `ElevatedButton` 1 in test, `OutlinedButton` 1, `TextField` 2). Task tests assert some semantics, e.g. `DSSearchBar` labels at `test/molecules/molecules_contract_test.dart:25`, `:55`, `:63`, but no exhaustive semantics/touch-target proof exists for every interactive atom/molecule. |
| Proof Reality | PARTIAL | Targeted tests pass: `flutter test --no-pub test/tokens/ds_token_contract_test.dart test/atoms/atoms_contract_test.dart test/molecules/molecules_contract_test.dart` => exactly 136 tests passed. Analyzer fails; old missing-SDK blocker is stale. |
| Release Security | PASS | No secrets, release config changes, prints, network calls, or permissions introduced by Task 0015. |

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED`: Contract test files exist at current paths:
  - `packages/warp_prism_ui/test/atoms/atoms_contract_test.dart`
  - `packages/warp_prism_ui/test/molecules/molecules_contract_test.dart`
- `RESOLVED`: Targeted tests actually run under current SDK and pass as part of the exact 136-test command.
- `RESOLVED`: Public package aliases include atoms/molecules: examples include `PrismStatusDot` at `packages/warp_prism_ui/lib/src/prism_aliases.dart:146-149`, `PrismTaskCard` at `:179`, `PrismAssetCard` at `:182`, `PrismSearchBar` at `:185`, and atom aliases at `:229-392`.

### Persistent Findings

- `PERSISTENT`: Analyzer gate remains open. The task's exit conditions at `docs/tasks/03-review/0015...md:52-53` are unchecked and stale-blocked by missing SDK, but current analyzer runs and fails.
- `PERSISTENT`: Changelog evidence is missing/deferred. Task exit condition at `docs/tasks/03-review/0015...md:54` is unchecked; completion evidence at `:128` says deferred; `docs/changelog/**/*0015*` returned 0 files.

### Regressions

- `REGRESSION`: The previous review accepted as 100/100 despite no actual SDK validation and despite unchecked exit conditions.

### New Findings

- `NEW`: Atoms/molecules scope has exact analyzer debt: 52 issues, including 2 warnings from unused local variables in `test/molecules/ds_drag_drop_test.dart`.
- `NEW`: The task-created tests are useful but not sufficient accessibility proof; they check selected semantic labels/states, not every interactive widget's 48x48 dp touch target and semantics coverage.

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: No clean package analyzer proof.
- `EVIDENCE_GAP`: No exhaustive atom/molecule semantics/touch-target matrix.
- `EXTERNAL_BLOCKER`: None. Flutter/Dart tooling is available.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | PERSISTENT | MODERATE | Open | Analyzer integrity fails package gate and atoms/molecules scope has direct issues. | 2026-06-14 wave-2 | `flutter analyze --no-pub` => 592 issues; atoms/molecules scope exactly 52 issues: 2 warnings, 50 infos. Examples: `test/molecules/ds_drag_drop_test.dart:249:27`, `:262:24` unused locals; `lib/src/atoms/ds_badge.dart:147:26`, `:151:26`; `lib/src/atoms/ds_chip.dart:192:26`, `:196:26`, `:243:45`; `lib/src/atoms/ds_divider.dart:92:26`, `:97:26`; `lib/src/atoms/ds_sparkline.dart:70:7`. |
| F2 | PERSISTENT | LOW | Open | Required changelog evidence is missing/deferred. | Task handoff / 2026-06-13 review missed it | `docs/tasks/03-review/0015...md:54`; `docs/tasks/03-review/0015...md:128`; `docs/changelog/**/*0015*` returned 0 files. |
| F3 | EVIDENCE_GAP | MODERATE | Open | Accessibility proof is partial, not exhaustive across every interactive atom/molecule. | 2026-06-14 wave-2 | Counted 55 `Semantics` widgets and 42 obvious interactive constructors package-wide; examples of tested semantics in `packages/warp_prism_ui/test/molecules/molecules_contract_test.dart:25`, `:55`, `:63`; no matrix proves all 29 `GestureDetector` and 6 `InkWell` instances have semantic labels and 48x48 dp targets. |
| F4 | REGRESSION | LOW | Open | Prior 100/100 approval was based on stale blocked-validation claims rather than current executable proof. | 2026-06-14 wave-2 | `docs/reports/build-gate-review/0015-review.md:28-30` treats analyze/test blocker and deferred changelog as acceptable; current tests run and analyzer fails. |

## Evidence Reviewed

- Task file: `docs/tasks/03-review/0015-warp-prism-ds-atoms-molecules-normalization.md`.
- Previous report: `docs/reports/build-gate-review/0015-review.md`.
- Upstream report/deliverable: `docs/reports/warp-prism-ds-inventory.md`.
- Source/test files:
  - `packages/warp_prism_ui/test/atoms/atoms_contract_test.dart`
  - `packages/warp_prism_ui/test/molecules/molecules_contract_test.dart`
  - `packages/warp_prism_ui/lib/src/prism_aliases.dart`
  - `packages/warp_prism_ui/analysis_options.yaml`
- Runtime wiring proof or non-runtime rationale: package component normalization task. Production app route wiring is not applicable, but package export wiring is proven through `lib/warp_prism_ui.dart:21` and public aliases in `lib/src/prism_aliases.dart`.
- Commands run:
  - `flutter test --no-pub test/tokens/ds_token_contract_test.dart test/atoms/atoms_contract_test.dart test/molecules/molecules_contract_test.dart` from `packages/warp_prism_ui/` — PASS, exactly 136 tests passed.
  - `flutter analyze --no-pub` from `packages/warp_prism_ui/` — FAIL, exactly 592 issues: 0 errors, 11 warnings, 581 infos.
  - Analyzer scope script using `dart analyze --format=machine` — atoms/molecules scope exactly 52 issues: 2 warnings, 50 infos.
  - Lifecycle/accessibility count script — TextEditingController 2, ScrollController 5, AnimationController 4, Timer references 2, addListener 17, dispose declarations 22, dispose calls 57, Semantics widgets 55, obvious interactive constructors 42.
- Commands not run and why:
  - `flutter test test/design_system/atoms test/design_system/molecules` was not run because those paths do not exist in current package layout; actual paths are `test/atoms/atoms_contract_test.dart` and `test/molecules/molecules_contract_test.dart`.

## Path To 100

1. Fix all atoms/molecules analyzer warnings and infos, beginning with direct warnings:
   - Remove or assert `reorderEvent` at `packages/warp_prism_ui/test/molecules/ds_drag_drop_test.dart:249:27`.
   - Remove or assert `moveEvent` at `packages/warp_prism_ui/test/molecules/ds_drag_drop_test.dart:262:24`.
2. Replace deprecated `withOpacity` uses in atom/molecule files with `withValues(alpha: ...)`, including the examples listed in Finding F1.
3. Fix style lints in atom/molecule files: add braces at `packages/warp_prism_ui/lib/src/atoms/ds_sparkline.dart:70:7`; add `const` constructors/literals in the 13 atom/molecule-scope const findings; add a `library;` directive to `test/molecules/ds_drag_drop_test.dart:1:1` if retaining library docs.
4. Build an explicit accessibility matrix for Task 0015: enumerate every interactive atom/molecule instance and test or document its semantic label, keyboard/focus behavior where applicable, and minimum 48x48 dp touch target. At minimum include all production `GestureDetector`, `InkWell`, `IconButton`, `TextButton`, `OutlinedButton`, and `TextField` uses in atoms/molecules.
5. Add Task 0015 changelog evidence under `docs/changelog/` or correct task exit condition text to an explicit blocker.
6. Re-run `flutter analyze --no-pub` in `packages/warp_prism_ui/` and reach 0 errors, 0 warnings, 0 infos.
7. Re-run `flutter test --no-pub test/atoms/atoms_contract_test.dart test/molecules/molecules_contract_test.dart` and record exact pass count.

## Task Ledger Patch Suggestion

```markdown
---

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports. Persistent findings and regression guards are part of
> the acceptance contract; do not fix the latest finding by undoing a previously
> accepted repair.

### Latest Review

- **Date**: 2026-06-14
- **Reviewer profile**: `reviewers`
- **Score**: `76/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Full report**: `docs/reports/build-gate-review/0015-review-wave-2.md`
- **Lane outcome**: `return to doing`
- **Task reference**: Task 0015 (`0015-warp-prism-ds-atoms-molecules-normalization`); resolve current path from `docs/tasks/tasklist.md` or search under `docs/tasks/`

#### Current Open Blockers

- `PERSISTENT`: `flutter analyze --no-pub` in `packages/warp_prism_ui/` fails with 592 issues; atoms/molecules scope has 52 issues including 2 warnings.
- `PERSISTENT`: Required changelog evidence is missing/deferred.
- `EVIDENCE_GAP`: Accessibility proof is partial; every interactive atom/molecule needs semantics and 48x48 dp touch-target proof.
- `REGRESSION`: Previous 100/100 approval relied on stale missing-SDK validation.

#### Path-to-100 Summary

- Clear atoms/molecules analyzer warnings/infos.
- Add exhaustive accessibility matrix/tests for interactive atoms/molecules.
- Add changelog evidence.
- Re-run analyzer and targeted atom/molecule tests with exact output.

### Previous Reports

- `2026-06-13` — `100/100` — `docs/reports/build-gate-review/0015-review.md`
  - **Carried forward**: Atom and molecule contract tests exist and pass under current SDK.
  - **Resolved since**: Targeted tests now actually run as part of a 136-test passing command.
  - **Regression guard**: Do not approve unchecked analyzer/test/changelog exit conditions as 100/100.
```
