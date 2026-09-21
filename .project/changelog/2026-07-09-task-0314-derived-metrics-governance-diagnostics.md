---
date: 20260709-154643
timestamp: 20260709-154643
agent: builders
task: "0314"
description: "Task 0314 — Derived Metrics & Governance Diagnostics (path-to-100)"
is_rebuild_safe: true
---

# Task 0314 — Derived Metrics & Governance Diagnostics (path-to-100)

> **Date**: 2026-07-09
> **Project**: warp-prism
> **Task**: 0314
> **Type**: feature
> **Author**: builders

## What Changed

Revalidated and closed Task 0314 under a live Flutter SDK. The derived metrics
and governance diagnostics service layer already existed under
`apps/observatory/lib/data/services/` and is consumed by workspace providers and
Governance/Overview view models. Prior closeout was blocked only by a stale
"Flutter SDK not installed" environment claim.

No production code changes were required this pass — validation gates now pass
and task evidence/lane/changelog were completed for review promotion.

## Files (canonical implementation)

- `apps/observatory/lib/data/services/workspace_metrics_service.dart`
- `apps/observatory/lib/data/services/workspace_diagnostics_service.dart`
- `apps/observatory/lib/data/models/governance_diagnostics.dart`
- `apps/observatory/lib/data/services/services.dart`
- `apps/observatory/test/data/services/workspace_diagnostics_service_test.dart`
- `docs/tasks/03-review/0314-warp-prism-derived-metrics-governance-diagnostics.md` (promoted)

## Validation (scoped, OOM-safe)

```bash
# from apps/observatory/
flutter analyze lib/data/services lib/data/models/governance_diagnostics.dart \
  test/data/services/workspace_diagnostics_service_test.dart
flutter test test/data/services/workspace_diagnostics_service_test.dart
```

Results:

- analyze: **No issues found**
- tests: **19/19 passed**

## Notes

- Services remain pure/stateless over `WorkspaceGraphResult` (Task 0313).
- High fan-in hotspots currently emit `DiagnosticCategory.brokenEdge` — this is
  the established cross-surface key (service + Governance panels + VMs).
- Flutter 3.44.1 / Dart 3.12.1 available; previous SDK blocker was environment-stale.
