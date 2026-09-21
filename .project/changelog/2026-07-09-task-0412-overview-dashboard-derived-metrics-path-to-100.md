---
date: 20260709-154330
timestamp: 20260709-154330
agent: builders
task: "0412"
description: "Task 0412 — Overview Dashboard Derived Metrics (path-to-100)"
is_rebuild_safe: true
---

# Task 0412 — Overview Dashboard Derived Metrics (path-to-100)

> **Date**: 2026-07-09
> **Project**: warp-prism
> **Task**: 0412
> **Type**: feature
> **Author**: builders

## What Changed

Closed the residual Task 0412 gap: Overview shell no longer simulates empty
workspace data. It now derives metrics from
`workspaceSnapshotAsyncProvider` + `workspaceDiagnosticsAsyncProvider` via
`OverviewProvider`, matching the product contract that totals and operational
risk are repository/provider-backed.

Also fixed analyzer infos in overview tests and added shell wiring tests.

## Files Changed

- **MODIFIED** `apps/observatory/lib/app/pages/overview_page.dart` — rewired
  `OverviewPageShell` as a `ConsumerWidget` over real workspace providers
  (forced metrics/loading/error hooks retained for tests only)
- **CREATED** `apps/observatory/test/features/overview/overview_shell_test.dart`
  — shell wiring tests (forced metrics, loading, error, zero-data)
- **MODIFIED** `apps/observatory/test/features/overview/overview_provider_test.dart`
  — removed unnecessary import and leading-underscore local helper

## Validation (scoped, OOM-safe)

```bash
# from apps/observatory/
dart format --set-exit-if-changed lib/features/overview/ lib/app/pages/overview_page.dart test/features/overview/
dart analyze lib/features/overview/ lib/app/pages/overview_page.dart test/features/overview/
flutter test test/features/overview/ --reporter compact
```

Results:

- format: pass (0 changed after final pass)
- analyze: No issues found
- tests: **18/18 passed**

## Notes

- Derivation remains outside the widget tree (`OverviewProvider` /
  `OverviewMetrics`).
- Design-system composition uses `PrismMetricTile` / `PrismStoryPanel`.
- Prior “Flutter SDK not installed” blocker was environment-stale; Flutter
  3.44.1 / Dart 3.12.1 are available in this session.
