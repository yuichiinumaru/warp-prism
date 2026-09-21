# Build-Gate Review: Task 1307 — Accessibility and Semantics Reconciliation

**Date**: 2026-06-17
**Reviewer**: reviewers / Wave 0 package-gate triage
**Task file reviewed**: `docs/tasks/03-review/1307-warp-prism-accessibility-and-semantics-reconciliation.md`

## Score: 78/100 — Good

## Findings

### HIGH — Required dependency Task 1303 is not satisfied/live-approved

- **Evidence**: Task 1307 declares `Depends on: 1303` at task line 9. Live Task 1303 is in `docs/tasks/02-doing/1303-warp-prism-component-contract-reconciliation.md` with `Review State: Builder Done` and a 2026-06-17 rejection ledger (score 62/100) citing workspace contamination and scoped analyzer failures.
- **Impact**: Task 1307 cannot be independently promoted while its explicit contract-reconciliation prerequisite is back in active remediation. Accessibility assertions may be invalidated by unresolved component contract changes.
- **Path to 100**: Complete and independently approve Task 1303, then rerun Task 1307's scoped and package gates against that settled component contract.

### HIGH — Scoped analyzer gate remains red in the files this task owns

- **Evidence**: Fresh `flutter analyze --no-pub` over Task 1307 implementation/test scope reports **67 issues**, including deprecated `withOpacity` calls in `ds_chip.dart:192,196,243`, `ds_asset_card.dart:34,37,73`, `ds_filter_chip_group.dart:81,84,121,148`, `ds_shell.dart:171`, `ds_sidebar.dart:188,249,252`, and `ds_topbar.dart:167,208`; plus const/deprecation debt in the accessibility test itself. This directly contradicts Completion Evidence line 125's broad `flutter analyze → 0 errors` completion framing and prior path-to-100 requirements.
- **Impact**: Analyzer Integrity is not a merely unrelated package-wide failure: current diagnostics include task-touched implementation and proof files. Under `.agents/rules/pre-existing-failure-policy.md`, related pre-existing failures block promotion unless explicitly justified by a reviewer; no defensible deferral exists for scoped lint/deprecation debt in the task's own surfaces.
- **Path to 100**: Clear all analyzer findings in the exact Task 1307 scope, including modern semantics/color APIs and const fixes, then rerun scoped analyzer with zero issues. Separately baseline unrelated package analyzer debt if it remains.

### MEDIUM — “All interactive components” exit condition is still broader than the proof

- **Evidence**: Exit condition line 54 claims all interactive components have semantic labels. The live accessibility test covers a bounded set: chip, filter chip, sidebar, topbar action, search controls, asset card, removable action, and shell focus. It does not provide a package-wide inventory mapping every interactive declaration under `packages/warp_prism_ui/lib/src` to a semantic-label assertion. The prior review report already classified this as an evidence gap; no inventory artifact was added.
- **Impact**: The completion claim exceeds the tested contract. Passing 20 tests does not prove package-wide accessibility coverage.
- **Path to 100**: Either narrow the task/exit condition to the explicitly audited surfaces or add an inventory-backed test/report covering every interactive package component and its semantics evidence.

### LOW — Three audited controls still expose sub-48dp hit regions

- **Evidence**: `DSChip` uses heights 24/28/32 at `ds_chip.dart:147-156`; `_FilterChip` uses height 28 at `ds_filter_chip_group.dart:112-115`; `DSTopbarAction` uses `DSSpacing.iconButtonSize` (40) at `ds_topbar.dart:201-202`. These were repeatedly identified in prior review ledgers and remain unresolved.
- **Impact**: Compact controls remain harder to activate for motor-impaired/touch users and fall below the task's accessibility intent.
- **Path to 100**: Preserve compact visuals inside minimum 48x48 interactive wrappers and add widget-size regression assertions.

## Live Diagnostics

| Command | Result | Details |
|---|---:|---|
| `flutter test --no-pub test/accessibility/` | PASS | `+20: All tests passed!`; includes real full-shell Tab/Shift+Tab focus identity/order proof at test lines 583-652. |
| Scoped `flutter analyze --no-pub ...` | FAIL | 67 issues in Task 1307 implementation/test scope. |
| Scoped `dart format --output=none --set-exit-if-changed ...` | PASS | 8 files, 0 changed. |
| Normal package commands | BLOCKED BEFORE EXECUTION | Root workspace discovery includes `apps/observatory/tmp/pub-cache/.../flutter_lints-4.0.0/pubspec.yaml` without `resolution: workspace`. This workspace blocker is unrelated, but does not excuse scoped analyzer failures. |

## Exit Conditions

| Condition | Result | Evidence |
|---|---:|---|
| Accessibility test passes | PASS | Fresh 20/20 run. |
| All interactive components have semantic labels | FAIL / evidence gap | Bounded audited set only; no package-wide inventory proof. |
| Focus traversal tests pass for shell navigation | PASS | Full `DSShell` test asserts primary focus/order and reverse traversal at test lines 583-652; keyboard activation at 654-688. |
| Changelog entry | PASS | `docs/changelog/2026-06-09-task-1307-accessibility-semantics-reconciliation.md` exists. |
| Completion Evidence filled | PARTIAL | Filled, but stale relative to current 20-test suite and scoped analyzer output. |

## Failure Classification

- **Unrelated external**: normal Flutter invocation is blocked before execution by root workspace/cache contamination.
- **Related/blocking**: 67 scoped analyzer findings affect Task 1307's own implementation and test files.
- **Dependency blocker**: Task 1303 is live in `02-doing/` after independent rejection.

## Verdict

NEEDS FIX. Score 78/100. Move Task 1307 from `03-review/` back to `02-doing/` under the orchestration routing contract.
