---
date: 20260709-160908
timestamp: 20260709-160908
agent: builders
task: "0811"
description: "Task 0811: Governance Orphan/Stale/Proof Panels — Live Validation"
is_rebuild_safe: true
---

# Task 0811: Governance Orphan/Stale/Proof Panels — Live Validation

> **Task**: 0811  
> **Agent**: builders  
> **Date**: 2026-07-09  
> **Type**: feature

## Summary

Verified and hardened Governance risk panels for orphan assets, stale
references, proof gaps, and changelog-without-task (ledger-link) gaps.
Replaced the incorrect fan-in fourth panel with ledger-link gaps (fan-in
belongs to Task 0812). Migrated panel widgets to Prism* public API.

## What Changed

- `apps/observatory/lib/features/governance/presentation/widgets/governance_issue_group.dart`
  — four risk categories; Prism* tokens; asset title + category/severity + explanation per issue
- `apps/observatory/lib/features/governance/presentation/widgets/governance_issue_filters.dart`
  — category/severity chips including Ledger Gaps; Prism* API
- `apps/observatory/lib/data/services/workspace_diagnostics_service.dart`
  — `_detectChangelogWithoutTaskLink` via `DiagnosticCategory.missingDependency`
- `apps/observatory/test/features/governance/governance_issue_panels_test.dart`
  — 26 tests for groups, filters, ledger gaps
- `apps/observatory/test/data/services/workspace_diagnostics_service_test.dart`
  — changelog-without-task detection test

## Verification

- `flutter analyze` (scoped changed files) → 0 errors (info-level const lints only)
- `flutter test test/features/governance/governance_issue_panels_test.dart test/data/services/workspace_diagnostics_service_test.dart` → **All tests passed** (46)

## Notes

- Fan-in hotspots remain under Task 0812 analytics panels (`brokenEdge` category).
- Ledger-link gaps reuse `missingDependency` rather than inventing a new enum value.
