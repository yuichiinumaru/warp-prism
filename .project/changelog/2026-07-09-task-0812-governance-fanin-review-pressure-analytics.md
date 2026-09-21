---
date: 20260709-190000
timestamp: 20260709-190000
agent: builders
task: "0812"
description: "Task 0812 path-to-100 — governance fan-in + review-pressure analytics validated"
is_rebuild_safe: true
---

# Task 0812 path-to-100 — Governance fan-in & review pressure analytics

**Date**: 2026-07-09
**Task**: 0812-warp-prism-governance-fanin-review-pressure-analytics
**Type**: feature completion / path-to-100

## Summary

Closed the validation path for Governance analytics panels. Implementation already
existed under `apps/observatory/`; this pass migrated presentation widgets to the
public `Prism*` API, fixed critical-hub risk copy, aligned tests with lane-chip
duplication, and ran live Flutter analyze/test gates (prior closeout was blocked
by a stale “Flutter SDK not installed” claim).

## Changes

### Modified
- `apps/observatory/lib/features/governance/presentation/widgets/fan_in_hotspots_panel.dart`
  - Prism* tokens/components
  - Risk explanation uses real edge count + ratio (no false `N× threshold` wording)
  - Threshold read from diagnostics context with service-default fallback only
  - Drill-down hook retained for Task 0813 consumers
- `apps/observatory/lib/features/governance/presentation/widgets/review_pressure_panel.dart`
  - Prism* tokens/components
  - Lane pressure derived from proof-gap diagnostics + Operate lane vocabulary
  - Wrap-based lane chips for overflow safety
- `apps/observatory/test/features/governance/governance_analytics_panels_test.dart`
  - Stronger riskExplanation assertions
  - Lane breakdown expectation allows chip + row label duplication

## Verification (scoped, OOM-safe; from `apps/observatory/`)

```bash
flutter analyze --no-pub \
  lib/features/governance/presentation/widgets/fan_in_hotspots_panel.dart \
  lib/features/governance/presentation/widgets/review_pressure_panel.dart \
  test/features/governance/governance_analytics_panels_test.dart
# no errors/warnings (info-only prefer_const in tests)

flutter test --concurrency=1 --no-pub \
  test/features/governance/governance_analytics_panels_test.dart
# 19/19 passed
```

## Notes

- High fan-in continues to use `DiagnosticCategory.brokenEdge` as the shared key
  with Task 0314 diagnostics and Governance VMs (intentional contract).
- Review pressure is projected from `DiagnosticCategory.proofGap` records that
  already carry `taskLane` / proof state from the diagnostics service.
- Flutter 3.44.1 / Dart 3.12.1 available.
