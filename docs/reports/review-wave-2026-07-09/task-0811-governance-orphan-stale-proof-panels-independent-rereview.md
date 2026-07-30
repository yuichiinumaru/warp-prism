# Review Report: Task 0811 — Governance Orphan Stale Proof Panels — 2026-07-09

## Review Lineage

- **Current task**: Task 0811 (`warp-prism-governance-orphan-stale-proof-panels`); live path at review start: `docs/tasks/03-review/0811-warp-prism-governance-orphan-stale-proof-panels.md`
- **Previous reports read**:
  - `docs/reports/build-gate-review/0811-review.md` — 100/100 (2026-06-13; SDK-blocked; changelog pending note)
- **Related reports considered**:
  - Task 0810 independent re-review this wave (dead `/governance` route — shared product path)
  - Task 0314 diagnostics independent re-review (detectors including changelog-without-task)
- **Review mode**: `re-review` (independent; production-path + composition audit)
- **Reviewer**: independent reviewers wave 2026-07-09

## Score And Verdict

- **Score**: `76/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED` (widget/service layer): Four risk groups (orphan / stale / proof / changelog-without-task via `missingDependency`) with title, category, severity, explanation; Prism* UI.
- `RESOLVED`: Service `_detectChangelogWithoutTaskLink` emits `DiagnosticCategory.missingDependency` — live diagnostics tests green.
- `RESOLVED`: Filter model + `GovernanceIssueFilters` covered by widget tests (**26** panel suite + service suite = **46/46** live).
- `RESOLVED`: Scoped analyze 0 errors; local changelog present; SDK blocker gone.

### Persistent Findings

- None from prior independent rejection artifact.

### Regressions

- None.

### New Findings

- `NEW` **HIGH**: Risk panels only appear inside `GovernanceOverviewPage` when `summary.diagnostics` is non-empty. Production route always constructs overview **without summary** (`router.dart` → `const GovernanceOverviewPage()`), so **panels never render in the product** (shared with Task 0810 shell gap).
- `NEW` **MEDIUM/Debt**: `GovernanceIssueFilters` is **not composed** into `GovernanceOverviewPage` (or any other lib consumer). Filters exist only as isolated widgets + unit/widget tests — product surface has **no category/severity segmentation UI** despite exit text claiming filtering for issue groups.
- `NEW` (Low): prefer_const infos on issue group/filters; format would touch `governance_issue_group.dart`.

### Evidence Gaps / External Blockers

- Production empty route is a **code defect**, not EXTERNAL_BLOCKER. Partial ownership: shell wiring is 0810-primary; 0811 must still compose filters into the risk-panel surface and prove end-to-end with diagnostics.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | NEW | High | Open | Issue panels unreachable on live `/governance` | this review | overview null summary; router no shell |
| F2 | NEW | Medium | Open | Filters never mounted in product UI | this review | `GovernanceIssueFilters` only referenced in its file + tests |
| F3 | RESOLVED | — | Closed | changelog-without-task detector | builder pass | `workspace_diagnostics_service.dart` + test |
| F4 | NEW | Low | Open | Format/const hygiene | this review | analyze INFO; format exit 1 |

## Exit Conditions (task contract)

| # | Condition | Met? | Live proof |
| --- | --- | --- | --- |
| 1 | Risk panels render four groups from 0314 diagnostics | **PARTIAL** | widgets+`buildIssueGroups` YES; production path NO |
| 2 | Category/severity filtering covered by tests | **PARTIAL** | tests YES; product composition NO |
| 3 | Each issue: title, category, severity, explanation | **YES** | issue row widgets + tests |
| 4 | Scoped analyze 0 errors | **YES** | live |
| 5 | issue panels + diagnostics tests | **YES** | **46/46** PASS |
| 6 | Changelog | **YES** | `docs/changelog/2026-07-09-task-0811-…md` |

## Axiom Compliance (Flutter 6)

| Axiom | Status | Notes |
| --- | --- | --- |
| Analyzer Integrity | PASS (scoped) | 0 errors |
| Lifecycle Safety | PASS | filter state would be local if composed; currently unused |
| Dependency Direction | PASS | derivation stays in diagnostics service |
| UI Accessibility | PARTIAL | issue rows use Semantics when drilldown; filter chips need composition proof |
| Proof Reality | **FAIL** | suites prove isolated widgets; not product wiring/composition |
| Release Security | PASS | read-only diagnostics presentation |

## Evidence Reviewed

- `governance_issue_group.dart` (`buildIssueGroups` four categories)
- `governance_issue_filters.dart` (orphan from product tree)
- `governance_overview_page.dart` issue panel section (no filters)
- `workspace_diagnostics_service.dart` changelog-without-task
- Tests: `governance_issue_panels_test.dart`, `workspace_diagnostics_service_test.dart`
- Router / 0810 dead-path interaction

## Commands Run

```bash
cd apps/observatory
flutter test --concurrency=1 --no-pub \
  test/features/governance/governance_issue_panels_test.dart \
  test/data/services/workspace_diagnostics_service_test.dart
# EXIT=0 +46 All tests passed!

# Composition proof (negative):
# rg GovernanceIssueFilters lib/ → only governance_issue_filters.dart
# router /governance → const GovernanceOverviewPage()
```

## Path To 100

1. Coordinate with Task 0810 shell: overview must receive live `diagnostics` so issue groups appear.
2. Make overview (or a dedicated risk-panels host) a **StatefulWidget** that owns `GovernanceFilterState`, mounts `GovernanceIssueFilters`, and filters `buildIssueGroups` results without re-deriving findings.
3. Add a composed widget test: overview/shell with mixed diagnostics **shows four groups**, toggles Ledger Gaps filter, and hides non-matching rows.
4. Format + const hygiene on issue group/filters.
5. Re-run panels + diagnostics + composed tests.

## Task Ledger Patch Suggestion

- Latest: **76/100** REJECTED_TO_DOING — this report.
- Previous: build-gate 100 unproven (2026-06-13); builder self 100 (2026-07-09) superseded.
- Lane: **return to `docs/tasks/02-doing/`**.
- **Regression guards**: keep four distinct categories (do not collapse); keep service-owned derivation; keep changelog-without-task → `missingDependency`.
