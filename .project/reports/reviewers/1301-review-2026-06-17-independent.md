# Build-Gate Review: Task 1301 — Prism Namespace Remediation — 2026-06-17

## Review Lineage

- **Current task**: Task 1301 (`docs/tasks/03-review/1301-warp-prism-prism-namespace-remediation.md` at review time).
- **Previous reports read**: `docs/reports/build-gate-review/1301-review.md` — prior 100/100 approval claim.
- **Related dependencies checked**: Task 1202 live path is `docs/tasks/02-doing/1202-warp-prism-promotion-state-model-definition.md` with `Review State: Doing` after 2026-06-17 rejection.
- **Review mode**: independent live re-review.

## Score And Verdict

- **Score**: `72/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: return to `02-doing`.

## Delta Summary

### Persistent / New Findings

- `NEW`: The live boundary harness now fails the public-barrel DS leakage check.
- `NEW`: The required dependency Task 1202 is not satisfied; it is back in `02-doing` after independent rejection.

## Findings

| ID | Class | Severity | Status | Summary | Evidence |
| --- | --- | --- | --- | --- | --- |
| F1 | NEW | High | Open | Public barrel still exposes a `DS*` symbol to consumers, contradicting Task 1301's public-barrel exit condition and boundary-harness pass claim. | Live command `dart packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .` returned `Checks: 5/6 PASS` and `[FAIL] Public barrel hides DS* names from consumers`; violation: `warp_prism_ui.dart:27: Exporting DS sub-barrel violates Prism* namespace`. Source line: `packages/warp_prism_ui/lib/warp_prism_ui.dart:27` exports `DSOperationalStateUI`. |
| F2 | NEW | Medium | Open | Prerequisite governance dependency is currently rejected. | Task 1301 declares `Depends on: 1202` at `docs/tasks/03-review/1301-warp-prism-prism-namespace-remediation.md:9`; Task 1202 is live in `docs/tasks/02-doing/1202-warp-prism-promotion-state-model-definition.md:3-4` with `Status: Doing` / `Review State: Doing`. |

## Evidence Reviewed

- Task file: `docs/tasks/03-review/1301-warp-prism-prism-namespace-remediation.md`.
- Source files: `packages/warp_prism_ui/lib/warp_prism_ui.dart`, `packages/warp_prism_ui/lib/src/prism_aliases.dart`, `packages/warp_prism_ui/test/boundaries/boundary_test.dart`.
- Dependency task: `docs/tasks/02-doing/1202-warp-prism-promotion-state-model-definition.md`.

## Commands Run

```bash
HOME="$PWD/tmp/home" PUB_CACHE="$PWD/tmp/pub-cache" TMPDIR="$PWD/tmp" dart packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .
# Boundary Test Harness (pure Dart)
# Checks: 5/6 PASS
# [FAIL] Public barrel hides DS* names from consumers
#   - warp_prism_ui.dart:27: Exporting DS sub-barrel violates Prism* namespace
```

## Path To 100

1. Remove the public `DSOperationalStateUI` leak from `packages/warp_prism_ui/lib/warp_prism_ui.dart`, or provide a Prism-named extension/export strategy that satisfies the boundary harness without exposing `DS[A-Z]` names.
2. Rerun `dart packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .` and record a real `6/6 PASS`.
3. Reconcile Task 1301's dependency on Task 1202: either wait for Task 1202 approval or explicitly narrow why the rejected promotion-state example work is not required for Task 1301's current review.
4. Refresh Completion Evidence and changelog if any public-barrel lines change.

## Task Ledger Patch Suggestion

Applied to the task file during reconciliation.
