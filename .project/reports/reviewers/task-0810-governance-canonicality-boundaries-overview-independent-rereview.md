# Review Report: Task 0810 — Governance Canonicality Boundaries Overview — 2026-07-09

## Review Lineage

- **Current task**: Task 0810 (`warp-prism-governance-canonicality-boundaries-overview`); live path at review start: `docs/tasks/03-review/0810-warp-prism-governance-canonicality-boundaries-overview.md`
- **Previous reports read**:
  - `docs/reports/build-gate-review/0810-review.md` — 100/100 (2026-06-13; SDK-blocked, unproven production path)
- **Related reports considered**:
  - Task 0314 independent re-review (diagnostics/metrics services **91**)
  - Overview shell pattern (`OverviewPageShell` watches `workspaceDiagnosticsAsyncProvider`) as contrast
- **Review mode**: `re-review` (independent; adversarial production-path audit)
- **Reviewer**: independent reviewers wave 2026-07-09

## Score And Verdict

- **Score**: `72/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED` (partial): Widget implementation exists with Prism* API, six-class legend, read-only banner, fixture-driven **13/13** tests green live.
- `RESOLVED` (partial): Scoped analyze 0 errors on overview/legend/tests; local changelog present.
- `RESOLVED`: Historical SDK EXTERNAL_BLOCKER gone — tests executable.

### Persistent Findings

- None from a prior independent code score (build-gate was soft 100).

### Regressions

- None vs prior soft approval — **production path was never proven** and remains broken.

### New Findings

- `NEW` **HIGH / Serious**: Product route `/governance` instantiates `const GovernanceOverviewPage()` with **no `summary`**, so the live app always renders empty state ("No governance data"). There is **no** `GovernancePageShell` (or equivalent) watching `workspaceMetricsAsyncProvider` / `workspaceDiagnosticsAsyncProvider` / graph snapshot to build `CanonicalityBoundarySummary`. Contrast: History uses `HistoryPageShell` + `historyTimelineAsyncProvider`.
- `NEW` **HIGH**: No non-test adapter constructs `CanonicalityBoundarySummary.counts` from Task 0314 outputs or graph canonicality tallies. Tests inject hard-coded fixture maps — widgets do not "render counts from the diagnostics service" on any production entrypoint.
- `NEW` (Debt): `dart format` would reformat `governance_overview_page.dart` and `governance_boundary_legend.dart`.
- `NEW` (Low): leftover `lib/app/pages/governance_page.dart` is still a "coming soon" placeholder (unused by router but stale).

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP` closed as **defect**: production wiring missing (not an external infra blocker).

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | NEW | High | Open | `/governance` never supplies summary → permanent empty | this review | `router.dart:82-83`; `GovernanceOverviewPage` null/empty branch |
| F2 | NEW | High | Open | No metrics/diagnostics → `CanonicalityBoundarySummary` adapter | this review | no producers under `lib/` except tests |
| F3 | NEW | Low | Open | Format drift on overview/legend | this review | `dart format --set-exit-if-changed` exit 1 |
| F4 | NEW | Low | Open | Stale placeholder `GovernancePage` | this review | `lib/app/pages/governance_page.dart` |

## Exit Conditions (task contract)

| # | Condition | Met? | Live proof |
| --- | --- | --- | --- |
| 1 | Overview renders boundary metrics from diagnostics service | **NO** (production) / **PARTIAL** (widget+fixtures) | Route empty; tests inject summary |
| 2 | Provenance/legend for required classes | **YES** (widget) | legend six classes + tests |
| 3 | Widget tests counts/read-only/legend | **YES** | **13/13** PASS |
| 4 | Scoped analyze | **YES** | 0 errors |
| 5 | `governance_boundaries_overview_test.dart` | **YES** | 13/13 |
| 6 | Changelog | **YES** | `docs/changelog/2026-07-09-task-0810-…md` |

## Axiom Compliance (Flutter 6)

| Axiom | Status | Notes |
| --- | --- | --- |
| Analyzer Integrity | PASS (scoped files) | 0 errors; INFO prefer_const elsewhere |
| Lifecycle Safety | PASS | Stateless presentational page |
| Dependency Direction | PASS | feature consumes diagnostics models |
| UI Accessibility | PASS (scoped) | legend Semantics; read-only banner text |
| Proof Reality | **FAIL** | Widget tests pass but **lie about product wiring**; route never feeds data |
| Release Security | PASS | read-only surface intent preserved |

## Evidence Reviewed

- `lib/app/router.dart` governance branch
- `lib/features/governance/presentation/governance_overview_page.dart`
- `lib/features/governance/presentation/widgets/governance_boundary_legend.dart`
- `lib/app/pages/overview_page.dart` (working shell contrast)
- `lib/data/providers/workspace_providers.dart` (diagnostics/metrics providers exist but unused by governance route)
- Tests: `governance_boundaries_overview_test.dart` (13)

## Commands Run

```bash
cd apps/observatory
flutter test --concurrency=1 --no-pub \
  test/features/governance/governance_boundaries_overview_test.dart
# EXIT=0 +13

dart analyze lib/features/governance/presentation/governance_overview_page.dart \
  lib/features/governance/presentation/widgets/governance_boundary_legend.dart \
  test/features/governance/governance_boundaries_overview_test.dart
# No issues found (or INFO-only in broader set)

# Static proof of dead route:
# router.dart: builder: (context, state) => const GovernanceOverviewPage(),
# Grep: CanonicalityBoundarySummary constructed only in tests + class def
```

## Path To 100

1. **Add `GovernancePageShell` (ConsumerWidget)** that:
   - watches `workspaceGraphAsyncProvider` or metrics + `workspaceDiagnosticsAsyncProvider`;
   - maps asset `canonicality` tallies → `CanonicalityBoundarySummary.counts` (six keys);
   - attaches `DiagnosticsReport.diagnostics` (and optional hotspots);
   - handles loading/error/empty like Overview/History shells.
2. **Wire router**: `/governance` → shell (not bare `const GovernanceOverviewPage()`).
3. **Add regression test**: ProviderScope + fake/real snapshot proves non-empty counts on shell (not only fixture-injected page).
4. `dart format` touch set; remove or archive unused `GovernancePage` placeholder.
5. Re-run scoped analyze + boundaries + smoke shell tests.

## Task Ledger Patch Suggestion

- Latest: **72/100** REJECTED_TO_DOING — this report.
- Previous: build-gate 100 unproven (2026-06-13); builder self 100 (2026-07-09) superseded.
- Lane: **return to `docs/tasks/02-doing/`**.
