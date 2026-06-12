# Task 1405: Detail Variant and Responsive Shell Reconciliation

> **Status**: `[ ]` Open
> **Review State**: Package Gate Failed — detail reconciliation evidence filled; observatory package gate not green
> **Priority**: 🟡 P1
> **Type**: `remediation`
> **Origin**: EPIC-14, stabilization wave, failures in `extended_detail_variants_test`,
>   `skill_task_detail_widgets_test`, `responsive_detail_integration_test`.
> **Blocks**: 1406
> **Depends on**: 1404 (view-models must be correct first)

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1405` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

Fix detail variant and responsive shell test failures so that asset detail
views (skill, task, agent, workflow, changelog) render correctly and the
responsive shell adapts properly.

## Background Context

### What already exists

- `apps/observatory/lib/features/asset_detail/presentation/` — detail views
  for each asset kind.
- `apps/observatory/test/features/asset_detail/` — tests for detail variants,
  responsive integration.
- Failures suggest detail views expect different model shapes than what
  view-models currently provide.

### What is missing or broken

- `extended_detail_variants_test.dart` — detail mapping stale.
- `skill_task_detail_widgets_test.dart` — UI detail expectations mismatch.
- `responsive_detail_integration_test.dart` — shell integration drift.

---

## Test Requirements

- Detail variant tests pass for all supported asset kinds.
- Responsive shell integration test passes.
- Detail views render metadata, body summary, incoming/outgoing edges, and
  related assets.

---

## Exit Conditions

- [x] `extended_detail_variants_test.dart` passes.
- [x] `skill_task_detail_widgets_test.dart` passes.
- [x] `responsive_detail_integration_test.dart` passes.
- [x] Local changelog entry added under `docs/changelog/`.
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: Read the 3 failing test files
  and the corresponding detail view implementations.
- [x] For each failure, determine: is the test stale (expects old model shape)
  or is the view broken (does not handle current model)?
- [x] Fix accordingly.
- [x] Verify responsive behavior (split-pane wide, overlay medium, full-screen
  narrow).
- [x] **Simplicity pass**: fix drift, do not redesign detail views.
- [x] **Regression verification**: run all asset_detail tests.

### Where

| File | Purpose |
| --- | --- |
| `apps/observatory/test/features/asset_detail/*.dart` | Read / Modify — fix tests |
| `apps/observatory/lib/features/asset_detail/presentation/*.dart` | Read / Modify — fix views |

### How

1. Read each test and implementation.
2. Fix drift.
3. Run tests.

### Why

Asset detail is the universal inspector consumed by Map, Operate, History, and
Governance. If detail views are broken, every feature surface loses drill-down
capability.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not remove detail variant tests. They cover real surface complexity.

---

## Validation Commands

```bash
flutter test apps/observatory/test/features/asset_detail/
```

---

## Completion Evidence

- **Files created/modified**:
  - `apps/observatory/lib/features/asset_detail/presentation/generic_asset_detail_view.dart` — Fixed `_buildSubtitle` dynamic type to `WorkspaceAsset`
  - `apps/observatory/lib/features/asset_detail/application/asset_detail_mapper.dart` — Added metadata section with raw frontmatter keys; added task frontmatter fallbacks for priority/lane; fixed 4 unnecessary `!` warnings
  - `apps/observatory/test/features/asset_detail/extended_detail_variants_test.dart` — Fixed duplicate-text assertions for "Tools" and "0902"
  - `apps/observatory/test/features/asset_detail/skill_task_detail_widgets_test.dart` — Added viewport sizing for off-screen sections; fixed duplicate-text assertions; fixed link label assertion; removed Scaffold from wrapper
  - `apps/observatory/test/features/asset_detail/responsive_detail_integration_test.dart` — Fixed wrapper to use MediaQuery + Scaffold for proper width constraints; updated narrow-mode Scaffold assertions for wrapper Scaffold; added `tester.view.physicalSize` for wide-layout tests; fixed divider widget predicate
  - `apps/observatory/test/features/asset_detail/asset_detail_descriptor_test.dart` — Fixed label casing assertion (Status vs status)
- **Tests or validation commands**: `flutter test test/features/asset_detail/` — 92 passed, 0 failed
- **Local changelog entry**: `docs/changelog/2026-06-09-1405-detail-variant-responsive-shell-reconciliation.md`
- **Agent-wiki / docs institutionalization**: N/A
- **Executor**: builders
- **Completion date**: 2026-06-09
