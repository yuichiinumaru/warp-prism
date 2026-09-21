---
date: 20260709-211955
timestamp: 20260709-211955
agent: gt-flutter-engineer
task: "0810-0813"
description: "Governance path-to-100 — GovernancePageShell + metrics/diagnostics wiring, filters, review pressure, GoRouter drill-down"
is_rebuild_safe: true
---

# Tasks 0810–0813 path-to-100 — Governance production shell wiring

**Date**: 2026-07-09
**Tasks**: 0810, 0811, 0812, 0813
**Type**: feature / path-to-100 remediation
**Lane**: left in `docs/tasks/02-doing/` (not promoted)

## Summary

Closed the shared production-path gap that caused independent re-reviews to
reject 0810–0813: `/governance` now hosts `GovernancePageShell`, which builds
`CanonicalityBoundarySummary` from Task 0314 graph + diagnostics providers.
Issue filters, review-pressure analytics, risk storytelling, and GoRouter
drill-down are composed on the live overview surface (Prism* API).

## Changes

### Added
- `apps/observatory/lib/features/governance/presentation/governance_page_shell.dart`
  - `buildCanonicalityBoundarySummary` adapter (six-class tallies from graph)
  - `GovernancePageShell` watching `workspaceGraphAsyncProvider` +
    `workspaceDiagnosticsAsyncProvider` with loading/error/forced test hooks
- `apps/observatory/test/features/governance/governance_page_shell_test.dart`
  - adapter unit tests, forced shell states, ProviderScope non-empty counts,
    composed filters (Ledger Gaps), review-pressure composition, GoRouter
    `/assets/:assetId` drill-down

### Modified
- `apps/observatory/lib/features/governance/presentation/governance_overview_page.dart`
  - Stateful filter host (`GovernanceIssueFilters` + local `GovernanceFilterState`)
  - `ReviewPressurePanel` composed from live diagnostics
  - Existing stories / issue groups / fan-in / drill-down retained
- `apps/observatory/lib/app/router.dart` — `/governance` → `GovernancePageShell`
- Format hygiene on governance presentation widgets

### Archived
- `apps/observatory/lib/app/pages/governance_page.dart` (stale “coming soon”
  placeholder) →
  `.archive/apps/observatory/lib/app/pages/governance_page-placeholder-20260709.dart`

## Verification

```bash
cd apps/observatory
flutter test --concurrency=1 --no-pub test/features/governance/
# → 104/104 PASS

flutter analyze --no-pub \
  lib/features/governance lib/app/router.dart \
  test/features/governance/governance_page_shell_test.dart
# → 0 errors / 0 warnings (info-only prefer_const)
```

## Path-to-100 mapping

| Task | Prior blocker | Remediation |
|------|---------------|-------------|
| 0810 | null summary on route | Shell + adapter + provider test |
| 0811 | filters not on product surface | Filters + local state on overview |
| 0812 | ReviewPressurePanel unmounted | Composed on overview |
| 0813 | no live GoRouter drill proof | Shell route + drill-down widget test |
