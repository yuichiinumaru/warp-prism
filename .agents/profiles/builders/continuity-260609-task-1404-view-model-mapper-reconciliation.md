# Task 1404 — View-model and Mapper Contract Reconciliation

> **Date**: 2026-06-09
> **Task**: 1404
> **Status**: Builder Done
> **Executor**: builders

## Summary

Fixed 2 data-layer test failures in `apps/observatory/`:
1. `workspace_diagnostics_service_test.dart` — "no-warning baseline produces empty report"
2. `overview_provider_test.dart` — "counts governance diagnostics at warning or above"

## Root Causes

### Diagnostics test fixture drift

`_buildHealthyGraph()` had task 1003 in review lane with `proofState: ProofState.none`, but the "no-warning baseline" test expected zero error diagnostics. The `WorkspaceDiagnosticsService._detectProofGaps()` correctly flagged it. Fix: changed task 1003 to `proofState: ProofState.complete` (healthy graph means complete proof).

### Overview provider early-return bug

`OverviewProvider.compute()` called `_countGovernanceWarnings(diagnostics)` *after* the `assets.isEmpty` early return, so governance warnings were never counted when assets was empty. The test passed empty assets + diagnostics and expected `governanceWarningCount == 2`, got 0. Fix: moved governance counting before the early return; renamed `_emptyMetrics()` → `_emptyMetricsWithGov(int)`.

## Metrics

| Metric | Before (post-1403) | After |
|---|---|---|
| Pass | 600 | 602 |
| Fail | 53 | 51 |
| Baseline (pre-1401) | 64 | — |

Cumulative reduction from baseline: 13 failures fixed.
