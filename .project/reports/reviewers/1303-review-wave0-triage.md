# Build-Gate Review: 1303 — Component Contract Reconciliation (Wave 0 Triage)

**Date**: 2026-06-17
**Reviewer**: independent reviewer subagent (`reviewers`)
**Task file**: `docs/tasks/03-review/1303-warp-prism-component-contract-reconciliation.md`

## Score: 62/100 — Debt

## Diagnostics

| Command | Result | Details |
|---------|--------|---------|
| `flutter test test/atoms/atoms_contract_test.dart test/molecules/molecules_contract_test.dart test/templates/templates_contract_test.dart test/molecules/operational_components_test.dart test/state_surface_test.dart` from `packages/warp_prism_ui` | FAIL / ENVIRONMENT-WORKSPACE BLOCKER | Package resolution aborted before tests: `apps/observatory/tmp/pub-cache/hosted/pub.dev/flutter_lints-4.0.0/pubspec.yaml is included in the workspace ... but does not have resolution: workspace`. No fresh contract-test pass was produced. |
| Task-scoped `dart analyze --format=machine ...` | FAIL | Three warnings: unused imports in `test/state_surface_test.dart:12-13` and `test/templates/templates_contract_test.dart:5`; three additional deprecated-member hints at `test/state_surface_test.dart:482`, `:505`, `:532`. |
| Full package gate | NOT RUN | The task header itself states the full package gate was not rerun in this refresh; the targeted test command could not resolve the workspace. |

## Contract Evidence

- All four contract tests and the relevant barrels listed in the task `Where` table were read.
- Existing prior review packet at `docs/reports/build-gate-review/1303-review.md` records a historical 850-test package pass and targeted 197-test pass from 2026-06-12, but this is stale evidence for the current filesystem.
- Task 1301 dependency is live in `03-review/` with `Review State: Ready For Review`; Task 1201 is likewise present in `03-review/` as the baseline dependency.
- Changelog entry exists at `docs/changelog/20260609-230000-1303-component-contract-reconciliation-builders.md`.

## Findings

### High
- [HIGH] Task is not Ready For Review under the live lane/state contract — `docs/tasks/03-review/1303-warp-prism-component-contract-reconciliation.md:3-4`.
  - Evidence: the task is in `03-review/`, but both Status and Review State remain `Builder Done`; the Review State explicitly says the full package gate was not rerun. Local governance requires `Ready For Review` before entering `03-review/` (`.agents/rules/task-governance.md:89-95`).
  - Impact: this is a direct promotion-gate violation and independently requires routing back to `02-doing/`.

### High
- [HIGH] Fresh targeted contract-test proof is unavailable.
  - Evidence: the required scoped Flutter test command failed during package resolution because an in-repository pub cache under `apps/observatory/tmp/pub-cache/hosted/pub.dev/flutter_lints-4.0.0/` is being included by the root workspace without `resolution: workspace`.
  - Impact: the four mandatory contract-test exit conditions cannot be freshly verified; the 2026-06-12 report is historical evidence, not a current pass.

### Medium
- [MEDIUM] Task-scoped analyzer surface is no longer clean.
  - Evidence: live `dart analyze --format=machine` reports unused imports at `packages/warp_prism_ui/test/state_surface_test.dart:12-13` and `packages/warp_prism_ui/test/templates/templates_contract_test.dart:5`, plus deprecated `SemanticsNode.hasFlag` usage at `state_surface_test.dart:482`, `:505`, and `:532`.
  - Impact: current evidence contradicts the task's and prior report's claim of zero task-scoped analyzer warnings.

## Patches Applied

- None. Score is below 90; fixes must return to the builder lane.

## Verdict

REJECTED → moved from `docs/tasks/03-review/` back to `docs/tasks/02-doing/`.

## Path to 100

1. Repair or isolate the in-repository `apps/observatory/tmp/pub-cache` workspace contamination without using external directories, then prove package resolution succeeds.
2. Remove the three unused imports and replace deprecated `SemanticsNode.hasFlag` assertions with the current `flagsCollection` API.
3. Rerun all four task-required contract tests plus `test/state_surface_test.dart`; capture exact pass counts.
4. Rerun the full `packages/warp_prism_ui` package gate (`flutter analyze` and `flutter test`) or classify only genuinely unrelated baseline issues with fresh exact output.
5. Update Status/Review State to canonical `Ready For Review`, refresh Completion Evidence/review packet, and only then move the task back to `03-review/`.
