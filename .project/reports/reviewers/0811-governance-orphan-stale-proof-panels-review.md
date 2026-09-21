# Review Report: Task 0811 — Governance Orphan Stale Proof Panels — 2026-06-19

## Review Lineage

- **Current task**: Task 0811 (`0811-warp-prism-governance-orphan-stale-proof-panels`); live path resolved from filesystem search under `docs/tasks/`.
- **Previous reports read**:
  - `docs/reports/build-gate-review/0811-review.md` — claimed `100/100`, approved, but noted changelog pending.
- **Related reports considered**:
  - `docs/reports/build-gate-review/0810-review.md`, `0812-review.md`, `0813-review.md` — same Governance feature chain and route wiring.
  - Task 0314 ledger in `docs/tasks/02-doing/0314-warp-prism-derived-metrics-governance-diagnostics.md` — dependency currently rejected to doing at `52/100`.
- **Review mode**: `re-review`.

## Score And Verdict

- **Score**: `45/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Axiom Compliance

| Axiom | Status | Evidence |
| --- | --- | --- |
| Analyzer Integrity | FAIL | `flutter analyze --no-pub` from `apps/observatory` found **378 issues**. Governance tests contribute info-level lint issues. |
| Lifecycle Safety | PASS | Governance scope creates **0** controllers/subscriptions/timers/listeners and contains **0** `dispose()` methods. `GovernanceIssueFilters` is stateless and stores no controller. |
| Dependency Direction | PARTIAL | Presentation widgets import `GovernanceDiagnostic` directly from data models at `governance_issue_group.dart:11` and `governance_issue_filters.dart:11`. No cycle found, but no approved Task 0314 service contract exists. |
| UI Accessibility | FAIL | Task 0811 production interactive elements: **8** `GestureDetector` tap targets in `governance_issue_filters.dart` (**7** filter chips plus **1** clear action). Task 0811 production `Semantics` widgets: **0**. Chip padding is `DSSpacing.sm/xs` at lines 228-231, with no explicit 48x48 dp minimum. |
| Proof Reality | FAIL | Task requires changelog-without-task evidence gaps at lines 21 and 39, but implementation creates **4** groups: orphan, stale, proof gap, and high fan-in (`governance_issue_group.dart:45-94`). It creates **0** changelog-link-gap group. Changelog evidence is still pending at task line 114 and no `docs/changelog/*0811*.md` exists. |
| Release Security | PASS | No secrets, signing, permissions, release config, `print`, or `debugPrint` in Task 0811 production files. |

## Delta Summary

### Resolved Since Previous Review
- `RESOLVED`: Flutter SDK is available locally for this review (`Flutter 3.44.1`, Dart `3.12.1`).

### Persistent Findings
- `PERSISTENT`: Prior report line 62 already marked changelog as pending; live filesystem still has **0** Task 0811 changelog entries.
- `PERSISTENT`: Analyzer gate is not clean.

### Regressions
- `REGRESSION`: Previous report accepted all exit conditions, but live implementation does not implement the required changelog-without-task/ledger-link-gap category.

### New Findings
- `NEW`: Governance issue panels are not consumed by the production `/governance` page or any other runtime page. `grep` found `buildIssueGroups(` only in its declaration and tests.
- `NEW`: Interactive filter chips have no semantic labels and no minimum touch target guarantee.

### Evidence Gaps / External Blockers
- `EVIDENCE_GAP`: Task 0314 dependency remains unapproved, so the claimed diagnostics-service source of truth is unstable.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | REGRESSION | CRITICAL | Open | Required changelog-without-task / ledger-link-gap findings are missing. The widget replaces that category with “High Fan-In Hotspots,” which belongs to Task 0812, not Task 0811. | 2026-06-19 | `docs/tasks/03-review/0811-warp-prism-governance-orphan-stale-proof-panels.md:21`, `:39`; `apps/observatory/lib/features/governance/presentation/widgets/governance_issue_group.dart:41-94` |
| F2 | NEW | CRITICAL | Open | Issue panels are dead runtime code: `/governance` creates only `GovernanceOverviewPage`, and that page never imports/renders `GovernanceIssueGroup` or `GovernanceIssueFilters`. | 2026-06-19 | `apps/observatory/lib/app/router.dart:83-84`; `apps/observatory/lib/features/governance/presentation/governance_overview_page.dart:12`, `:78-100`; grep found no production calls to `buildIssueGroups(` |
| F3 | NEW | MODERATE | Open | Filter controls are interactive but inaccessible. There are **8** tap handlers and **0** Semantics widgets in Task 0811 files. | 2026-06-19 | `apps/observatory/lib/features/governance/presentation/widgets/governance_issue_filters.dart:86-121`, `:133-159`, `:166-175`, `:223-255` |
| F4 | PERSISTENT | MODERATE | Open | Changelog is missing despite an exit condition requiring it. | 2026-06-13 | `docs/tasks/03-review/0811-warp-prism-governance-orphan-stale-proof-panels.md:52`, `:114`; `docs/reports/build-gate-review/0811-review.md:62`; glob `docs/changelog/*0811*.md` returned **0** files |
| F5 | NEW | CRITICAL | Open | Dependency Task 0314 is in `02-doing` with open blockers, so Task 0811 cannot honestly claim service-sourced diagnostics. | 2026-06-19 | `docs/tasks/03-review/0811-warp-prism-governance-orphan-stale-proof-panels.md:9`, `:47`; `docs/tasks/02-doing/0314-warp-prism-derived-metrics-governance-diagnostics.md:132-147` |
| F6 | PERSISTENT | MODERATE | Open | Analyzer integrity is not satisfied: **378** issues. | 2026-06-13 | command output: `flutter analyze --no-pub` |

## Evidence Reviewed

- Task file: `docs/tasks/03-review/0811-warp-prism-governance-orphan-stale-proof-panels.md`.
- Previous report: `docs/reports/build-gate-review/0811-review.md`.
- Source/test files: `governance_issue_group.dart`, `governance_issue_filters.dart`, `governance_issue_panels_test.dart`, `governance_overview_page.dart`, `router.dart`, `governance_diagnostics.dart`, `workspace_diagnostics_service.dart`.
- Runtime wiring proof: no production caller renders `GovernanceIssueGroup`/`GovernanceIssueFilters`; `/governance` is wired to `const GovernanceOverviewPage()` at `router.dart:83-84`; `GovernanceOverviewPage` imports only `governance_boundary_legend.dart` and never issue panels.
- Interactive/accessibility count: **8** `GestureDetector` tap targets in Task 0811 production file; **0** `Semantics` widgets.
- Commands run:
  - `flutter --version` — PASS.
  - `dart --version` — PASS.
  - `flutter analyze --no-pub && flutter test --no-pub ...governance...` — FAIL at analyzer, **378** issues.
  - `flutter test --no-pub test/features/governance/governance_boundaries_overview_test.dart test/features/governance/governance_issue_panels_test.dart test/features/governance/governance_analytics_panels_test.dart test/features/governance/governance_drilldown_storytelling_test.dart` — FAIL, **80 tests run**, **79 passed**, **1 failed** in Task 0812 analytics test; Task 0811 tests were among the passing tests in this run.
- Commands not run and why: full package `flutter test` not run because focused governance run already failed.

## Path To 100

1. Restore Task 0811 category coverage: add a dedicated changelog-without-task/ledger-link-gap group from a service-owned diagnostic category; do not use `DiagnosticCategory.brokenEdge` as a substitute.
2. Wire `GovernanceIssueGroup` and `GovernanceIssueFilters` into the real Governance route/page using diagnostics from the approved Task 0314 service contract.
3. Replace `GestureDetector` chips/clear text with accessible controls (`FilterChip`, `ActionChip`, `InkWell` inside `Semantics(button: true, label: ...)`) and enforce 48x48 dp hit regions.
4. Add route-level tests proving `/governance` renders orphan, stale, proof-gap, and changelog-link-gap findings from diagnostics without constructing widgets in isolation.
5. Add the missing Task 0811 changelog entry and rerun `flutter analyze --no-pub` plus the focused Task 0811 test file.

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

- **Date**: 2026-06-19
- **Reviewer profile**: `reviewers`
- **Score**: `45/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Full report**: `docs/reports/review-wave-2026-06-19/0811-governance-orphan-stale-proof-panels-review.md`
- **Lane outcome**: `returned to doing`
- **Task reference**: Task 0811 (`0811-warp-prism-governance-orphan-stale-proof-panels`)

#### Current Open Blockers

- `REGRESSION`: Missing changelog-without-task/ledger-link-gap issue group; implementation substituted high fan-in.
- `NEW`: Issue panels/filters are not rendered by the production Governance route.
- `NEW`: **8** interactive filter tap targets have **0** Semantics wrappers and no 48x48 dp guarantee.
- `PERSISTENT`: Changelog entry is still missing.
- `EVIDENCE_GAP`: Task 0314 dependency remains rejected to doing.

#### Path-to-100 Summary

- Add service-backed changelog-link-gap diagnostics/group.
- Wire panels into `/governance` with route-level tests.
- Fix accessibility and analyzer/changelog proof.

### Previous Reports

- `2026-06-13` — `100/100` — `docs/reports/build-gate-review/0811-review.md`
  - **Carried forward**: missing changelog and analyzer externalization.
  - **Resolved since**: Flutter SDK is available locally.
  - **Regression guard**: Task 0811 must render four required risk categories, not borrow Task 0812 hotspot semantics.
```
