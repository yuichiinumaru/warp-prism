# Review Report: Task 0810 — Governance Canonicality Boundaries Overview — 2026-06-19

## Review Lineage

- **Current task**: Task 0810 (`0810-warp-prism-governance-canonicality-boundaries-overview`); live path resolved from filesystem search under `docs/tasks/`.
- **Previous reports read**:
  - `docs/reports/build-gate-review/0810-review.md` — claimed `100/100`, approved.
- **Related reports considered**:
  - `docs/reports/build-gate-review/0811-review.md` through `0813-review.md` — downstream Governance panels/storytelling depend on the same runtime route and diagnostics contract.
  - Task 0314 ledger in `docs/tasks/02-doing/0314-warp-prism-derived-metrics-governance-diagnostics.md` — current dependency is rejected to doing with `52/100` and unresolved diagnostic-category/proof issues.
- **Review mode**: `re-review`.

## Score And Verdict

- **Score**: `55/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Axiom Compliance

| Axiom | Status | Evidence |
| --- | --- | --- |
| Analyzer Integrity | FAIL | `flutter analyze --no-pub` from `apps/observatory` found **378 issues**. Governance test files contribute info-level lint issues, and the package gate is not zero-warning. |
| Lifecycle Safety | PASS | Governance files create **0** `TextEditingController`, **0** `ScrollController`, **0** `AnimationController`, **0** `StreamSubscription`, **0** `Timer`, **0** listeners, and contain **0** `dispose()` methods under `apps/observatory/lib/features/governance/`. No disposal-sensitive resource is introduced. |
| Dependency Direction | PARTIAL | UI imports data model types directly at `apps/observatory/lib/features/governance/presentation/governance_overview_page.dart:11`, but the larger blocker is missing provider/service wiring, not a domain/data import cycle. |
| UI Accessibility | PARTIAL | Task 0810 interactive widgets: **0**. Semantics widgets in Task 0810 production scope: **1** (`governance_boundary_legend.dart:93`). Count cards at `governance_overview_page.dart:254-281` are not interactive, but metric/legend color states are still conveyed partly by color and labels rather than audited WCAG contrast. |
| Proof Reality | FAIL | Completion evidence says **12** test cases at task line 113; live file contains **13** test cases in `governance_boundaries_overview_test.dart` lines 61, 69, 78, 87, 96, 110, 126, 138, 150, 162, 173, 186, 197. Focused four-file governance run produced **80 tests, 1 failure** due Task 0812; package analyzer failed. |
| Release Security | PASS | No secrets, release config, signing, permissions, or network behavior touched in Task 0810 files. `print`/`debugPrint` count in Task 0810 production scope: **0**. |

## Delta Summary

### Resolved Since Previous Review
- `RESOLVED`: Flutter SDK is now available locally (`Flutter 3.44.1`, Dart `3.12.1`), so the earlier “SDK not installed” rationale is no longer true for this review environment.

### Persistent Findings
- `PERSISTENT`: Analyzer/package gate is not passing. Prior report marked analyzer as external; live command now proves the package still fails analyzer integrity.

### Regressions
- `REGRESSION`: Previous report accepted runtime consumption of diagnostics, but the live router still instantiates `const GovernanceOverviewPage()` with no summary or provider at `apps/observatory/lib/app/router.dart:83-84`, so the production Governance route renders the empty state instead of diagnostic counts.

### New Findings
- `NEW`: Self-reported test count is false: task says **12** tests, live file has **13** test cases.
- `NEW`: Dependency Task 0314 is currently back in `02-doing` with `52/100`, so this task's stated dependency on Task 0314 is not satisfied.

### Evidence Gaps / External Blockers
- `EVIDENCE_GAP`: No runtime proof exists that route-level Governance consumes `WorkspaceDiagnosticsService`, `DiagnosticsReport`, or `GovernanceViewModel`.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | REGRESSION | CRITICAL | Open | Governance route is wired to an empty, nullable page instead of diagnostic data. Users navigating to `/governance` see `No governance data`; canonicality counts are test-only unless manually injected. | 2026-06-19 | `apps/observatory/lib/app/router.dart:83-84`, `apps/observatory/lib/features/governance/presentation/governance_overview_page.dart:48`, `:61-64`, `:70-75` |
| F2 | NEW | CRITICAL | Open | Task 0314 dependency is not approved and lives in `02-doing` with current review score `52/100`; Task 0810 depends on its diagnostics at task lines 9, 39, 82-83, 99. | 2026-06-19 | `docs/tasks/03-review/0810-warp-prism-governance-canonicality-boundaries-overview.md:9`, `:39`, `:82-83`, `:99`; `docs/tasks/02-doing/0314-warp-prism-derived-metrics-governance-diagnostics.md:132-147` |
| F3 | PERSISTENT | MODERATE | Open | Analyzer integrity is not satisfied. The command found **378** package issues; Task 0810 cannot claim package-level zero-warning status. | 2026-06-13 | command output: `flutter analyze --no-pub` |
| F4 | NEW | LOW | Open | Completion evidence overstates/incorrectly counts tests: task line 113 says **12** test cases, live test file contains **13** test cases. | 2026-06-19 | `docs/tasks/03-review/0810-warp-prism-governance-canonicality-boundaries-overview.md:113`; `apps/observatory/test/features/governance/governance_boundaries_overview_test.dart:61-197` |

## Evidence Reviewed

- Task file: `docs/tasks/03-review/0810-warp-prism-governance-canonicality-boundaries-overview.md`.
- Previous report: `docs/reports/build-gate-review/0810-review.md`.
- Dependency context: `docs/tasks/02-doing/0314-warp-prism-derived-metrics-governance-diagnostics.md`, `docs/tasks/00-planning/EPIC-08-warp-prism-governance-surface.md`, `docs/tasks/00-planning/EPIC-09-warp-prism-universal-asset-detail.md`.
- Source/test files: `governance_overview_page.dart`, `governance_boundary_legend.dart`, `governance_boundaries_overview_test.dart`, `router.dart`, `workspace_diagnostics_service.dart`, `workspace_view_models.dart`, `governance_diagnostics.dart`.
- Runtime wiring proof: `/governance` is registered at `router.dart:83-84` and constructs `const GovernanceOverviewPage()` with no `summary`; `GovernanceOverviewPage.build` chooses empty state when `summary == null` at `governance_overview_page.dart:61-64`. `grep` found **0** production calls to `CanonicalityBoundarySummary` outside this page/test and **0** production providers passing diagnostics into the page.
- Commands run:
  - `flutter --version` — PASS, Flutter `3.44.1`, Dart `3.12.1`.
  - `dart --version` — PASS, Dart `3.12.1`.
  - `flutter analyze --no-pub && flutter test --no-pub ...governance...` — FAIL at analyzer, **378 issues**, tests not reached by chained command.
  - `flutter test --no-pub test/features/governance/governance_boundaries_overview_test.dart test/features/governance/governance_issue_panels_test.dart test/features/governance/governance_analytics_panels_test.dart test/features/governance/governance_drilldown_storytelling_test.dart` — FAIL, **80 tests run**, **79 passed**, **1 failed**.
- Commands not run and why: full `flutter test` not run because focused governance tests already produced a task-scope failure.

## Path To 100

1. First resolve Task 0314 to `>=90/100` and add a typed diagnostic contract for canonicality counts/high fan-in that does not misuse `brokenEdge`.
2. Wire `/governance` to live diagnostics: create/read the existing workspace provider/view-model and pass a non-null `CanonicalityBoundarySummary` (or replace the local summary class with a service-owned DTO) into `GovernanceOverviewPage`.
3. Add a route/widget test that pumps the real `/governance` route and asserts the diagnostics service fixture counts appear without manually constructing `GovernanceOverviewPage(summary: ...)`.
4. Fix analyzer issues in the Governance tests/scope and then rerun `flutter analyze --no-pub` and the focused governance test command with zero failures.
5. Correct the task evidence test count from **12** to **13** or adjust the test suite/evidence so self-reported proof matches the live filesystem.

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
- **Score**: `55/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Full report**: `docs/reports/review-wave-2026-06-19/0810-governance-canonicality-boundaries-overview-review.md`
- **Lane outcome**: `returned to doing`
- **Task reference**: Task 0810 (`0810-warp-prism-governance-canonicality-boundaries-overview`)

#### Current Open Blockers

- `REGRESSION`: `/governance` constructs `const GovernanceOverviewPage()` with no diagnostic summary, so route-level runtime shows empty state instead of counts.
- `NEW`: Task 0314 dependency is currently rejected to doing at `52/100`.
- `PERSISTENT`: `flutter analyze --no-pub` reports **378** issues.
- `NEW`: Completion evidence says **12** tests, live Task 0810 test file has **13** test cases.

#### Path-to-100 Summary

- Approve/fix Task 0314 first.
- Wire the Governance route to service/provider diagnostics and add route-level proof.
- Fix analyzer/test evidence and correct self-reported test counts.

### Previous Reports

- `2026-06-13` — `100/100` — `docs/reports/build-gate-review/0810-review.md`
  - **Carried forward**: analyzer/package gate was not clean.
  - **Resolved since**: Flutter SDK is available in this review environment.
  - **Regression guard**: route-level diagnostics consumption must be proven, not only widget-constructor fixtures.
```
