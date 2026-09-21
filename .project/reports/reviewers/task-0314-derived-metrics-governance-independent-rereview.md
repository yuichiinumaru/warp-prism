# Review Report: Task 0314 — Derived Metrics Governance Diagnostics — 2026-07-09

## Review Lineage

- **Current task**: Task 0314 (`warp-prism-derived-metrics-governance-diagnostics`); live path at review start: `docs/tasks/03-review/0314-warp-prism-derived-metrics-governance-diagnostics.md`
- **Previous reports read**:
  - `docs/reports/build-gate-review/0314-review.md` — 100/100 (SDK-blocked; stale)
  - `docs/reports/build-gate-review/0314-review.md` is the only prior full report found under build-gate; no wave-3 independent rejection file for 0314 (0314 was not in the 0310–0313 sequential rejection packet)
- **Related reports considered**:
  - Task 0313 this wave (graph unit residual 88)
  - Governance feature consumers filtering `DiagnosticCategory` (builder note on `brokenEdge` as fan-in key)
- **Review mode**: `re-review` / first rigorous independent verification with live Flutter gates

## Score And Verdict

- **Score**: `91/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Lane recommendation**: `hold-in-review` (S ≥ 90; never auto-complete to `04-completed`)

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED`: Live validation unblocks historical EXTERNAL_BLOCKER. `flutter test test/data/services/workspace_diagnostics_service_test.dart` → **+20 All tests passed** (builder said 19; live is 20).
- `RESOLVED`: Metrics + diagnostics services present, pure, and consumed by providers/VMs.

### Persistent Findings

- None from a prior independent score with open code defects. Historical build-gate 100 was unproven due to missing SDK.

### Regressions

- None.

### New Findings

- `NEW` / Medium (documented debt): High fan-in hotspots are emitted as `DiagnosticCategory.brokenEdge` rather than a dedicated fan-in category. Builder acknowledges this as intentional cross-surface key. Semantically overloaded; Governance UI must treat `brokenEdge` as fan-in, not only broken links.
- `NEW` / Low: `DiagnosticCategory.reviewPressure` (and several other enum values: `canonicalityDrift`, `staleIndex`, `childParentDrift`) are **never produced** by `WorkspaceDiagnosticsService.analyze`. Enum surface > implemented rules. Not a failure of the four required detectors (orphan, stale, proof gap, high fan-in) which **are** covered.
- `NEW` / Low: Builder claimed 19 tests; live suite has 20 — under-claim, not over-claim.

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: No integration test running metrics/diagnostics over the **real** mock graph load (unit tests use synthetic graphs). Acceptable for this task’s scoped exit conditions.
- Graph double-prefix residual (0313) can create false stale references in integration — external to pure unit tests.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | NEW | Medium | Open | Fan-in uses `brokenEdge` category | this review | `workspace_diagnostics_service.dart:326-327` |
| F2 | NEW | Low | Open | Several DiagnosticCategory values never emitted | this review | No `reviewPressure` emission; only orphan/stale/proofGap/missingDependency/brokenEdge |
| F3 | RESOLVED | High | Closed | SDK/package gates blocked | build-gate 2026-06-13 | Live 20/20 PASS |

## Exit Condition Verification

| Exit condition | Status | Live evidence |
| --- | --- | --- |
| Metrics + diagnostics services under services/ | PASS | `workspace_metrics_service.dart`, `workspace_diagnostics_service.dart` |
| Typed summary/diagnostic results | PASS | `WorkspaceMetricsSummary`, `DiagnosticsReport`, `GovernanceDiagnostic` |
| Scoped analyze without errors | PASS | infos only in related service tests |
| diagnostics service tests 0 failures | PASS | 20/20 |
| Changelog | PASS | `docs/changelog/2026-07-09-task-0314-derived-metrics-governance-diagnostics.md` |
| Required detectors (orphan, stale, proof gap, fan-in) + no-warning baseline | PASS | tests cover positive + empty/healthy |

## Axiom Compliance

| Axiom | Status | Notes |
| --- | --- | --- |
| Analyzer Integrity | PASS (scoped service/test; residual infos elsewhere) | |
| Lifecycle Safety | PASS | Pure stateless services |
| Dependency Direction | PASS | Graph in → summaries out |
| UI Accessibility | N/A | |
| Proof Reality | PASS | Fresh 20/20 matches exits; minor count under-claim |
| Release Security | PASS | Read-only analytics |

## Evidence Reviewed

- Metrics/diagnostics services + governance model
- Full `workspace_diagnostics_service_test.dart`
- Provider/VM consumers of summaries

### Commands run

| Command | Cwd | Result |
| --- | --- | --- |
| `flutter test --concurrency=1 --no-pub test/data/services/workspace_diagnostics_service_test.dart` | `apps/observatory` | +20 All tests passed |
| (shared) services analyze | `apps/observatory` | infos only |

## Path To 100

1. Either introduce a dedicated `highFanIn` category (and migrate UI filters) **or** document `brokenEdge` overload in a durable contract note and add an explicit test that Governance VM `hotspotCount` keys off that category (already partially true).
2. Implement or explicitly defer `reviewPressure` with a tracked follow-up (do not leave silent empty enum values without docs).
3. Optional: one golden metrics snapshot from real mock graph once 0312/1403 corpus residuals stabilize.
4. Align Completion Evidence test count to 20.

## Task Ledger Patch Suggestion

```markdown
## Review Ledger

### Latest Review
- **Date**: 2026-07-09
- **Reviewer profile**: `reviewers`
- **Score**: `91/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Full report**: `docs/reports/review-wave-2026-07-09/task-0314-derived-metrics-governance-independent-rereview.md`
- **Lane outcome**: remain in `03-review`

#### Current Open Blockers
- None for binary exits. Debt: fan-in category overload; unimplemented DiagnosticCategory values.

#### Path-to-100 Summary
- Clarify fan-in category; document or implement remaining categories; optional real-graph golden.

### Previous Reports
- `2026-06-13` — `100/100` — `docs/reports/build-gate-review/0314-review.md` (superseded; SDK blocked)
```
