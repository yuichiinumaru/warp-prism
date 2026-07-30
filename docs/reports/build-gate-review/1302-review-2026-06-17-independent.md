# Build-Gate Review: Task 1302 — Public Barrel Audit — 2026-06-17

## Review Lineage

- **Current task**: Task 1302 (`docs/tasks/03-review/1302-warp-prism-public-barrel-audit.md` at review time).
- **Previous reports read**: `docs/reports/build-gate-review/1302-review.md` — prior 100/100 approval claim.
- **Related dependencies checked**: Task 1301 was re-reviewed in this wave and rejected to `02-doing`.
- **Review mode**: independent live re-review.

## Score And Verdict

- **Score**: `58/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: return to `02-doing`.

## Delta Summary

### Persistent / New Findings

- `NEW`: The public barrel audit report no longer matches the live public barrel structure.
- `NEW`: The boundary harness fails the public-barrel DS leakage check.
- `NEW`: The direct dependency Task 1301 is rejected in this same review wave.

## Findings

| ID | Class | Severity | Status | Summary | Evidence |
| --- | --- | --- | --- | --- | --- |
| F1 | NEW | High | Open | The definitive manifest is not definitive against the live barrel. | `docs/design/public-barrel-audit.md:12-24` says the public barrel exports 9 sub-barrels including tokens/atoms/molecules/organisms/templates. Live `packages/warp_prism_ui/lib/warp_prism_ui.dart:21-32` exports only `src/prism_aliases.dart`, `DSOperationalStateUI`, and three gallery files. |
| F2 | NEW | High | Open | The public-barrel boundary is currently red. | Live boundary command returned `5/6 PASS` with `[FAIL] Public barrel hides DS* names from consumers`; violation is `warp_prism_ui.dart:27`, where `DSOperationalStateUI` is exported. |
| F3 | NEW | High | Open | Task 1302 depends on Task 1301, but Task 1301 is not currently accepted. | Task 1302 declares `Depends on: 1301` at `docs/tasks/03-review/1302-warp-prism-public-barrel-audit.md:9`; Task 1301 was scored `72/100` in `docs/reports/build-gate-review/1301-review-2026-06-17-independent.md` and returned to `02-doing`. |

## Evidence Reviewed

- Task file: `docs/tasks/03-review/1302-warp-prism-public-barrel-audit.md`.
- Audit report: `docs/design/public-barrel-audit.md`.
- Source files: `packages/warp_prism_ui/lib/warp_prism_ui.dart`, `packages/warp_prism_ui/test/boundaries/boundary_test.dart`.
- Dependency review: `docs/reports/build-gate-review/1301-review-2026-06-17-independent.md`.

## Commands Run

```bash
HOME="$PWD/tmp/home" PUB_CACHE="$PWD/tmp/pub-cache" TMPDIR="$PWD/tmp" dart packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .
# Boundary Test Harness (pure Dart)
# Checks: 5/6 PASS
# [FAIL] Public barrel hides DS* names from consumers
#   - warp_prism_ui.dart:27: Exporting DS sub-barrel violates Prism* namespace
```

## Path To 100

1. First complete Task 1301's public-barrel namespace fix and get the boundary harness to `6/6 PASS`.
2. Regenerate `docs/design/public-barrel-audit.md` from the live `packages/warp_prism_ui/lib/warp_prism_ui.dart` export graph.
3. Reconcile the report's barrel-structure section, symbol counts, and validation block with the actual current export list.
4. Rerun boundary harness and any chosen manifest-count extraction; record exact current output in Task 1302 evidence and changelog.

## Task Ledger Patch Suggestion

Applied to the task file during reconciliation.
