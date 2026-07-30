# Task 1405: Detail Variant and Responsive Shell Reconciliation

> **Status**: `[x]` Ready For Review
> **Review State**: Held in Review — S=96/100 (2026-07-09 independent re-review); path-to-100
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
  - `apps/observatory/lib/features/asset_detail/presentation/generic_asset_detail_view.dart` — Fixed `_buildSubtitle` dynamic type to `WorkspaceAsset` (prior pass)
  - `apps/observatory/lib/features/asset_detail/application/asset_detail_mapper.dart` — Metadata section + task frontmatter fallbacks (prior pass)
  - `apps/observatory/test/features/asset_detail/extended_detail_variants_test.dart` — Duplicate-text assertions (prior pass)
  - `apps/observatory/test/features/asset_detail/skill_task_detail_widgets_test.dart` — Viewport sizing + assertion drift (prior pass)
  - `apps/observatory/test/features/asset_detail/responsive_detail_integration_test.dart` — Wrapper/MediaQuery fixes (prior pass); **2026-07-09**: replaced stale public-API name `DSBreakpoints` with `PrismBreakpoints` so the suite compiles after Prism barrel policy
  - `apps/observatory/test/features/asset_detail/asset_detail_descriptor_test.dart` — Label casing (prior pass)
- **Tests or validation commands** (2026-07-09, apps/observatory):
  - `flutter test test/features/asset_detail/` — **97 passed, 0 failed** (builder claim)
  - Reviewer re-run (2026-07-09): **100 passed, 0 failed** (`+100: All tests passed!`)
  - `dart analyze lib/features/asset_detail/ test/features/asset_detail/` — 0 errors/warnings (info-only style); reviewer confirmed
- **Local changelog entry**: `docs/changelog/2026-06-09-1405-detail-variant-responsive-shell-reconciliation.md` (existing; no new publish this pass)
- **Agent-wiki / docs institutionalization**: N/A
- **Executor**: gt-flutter-engineer
- **Completion date**: 2026-07-09
- **Review**: gt-code-quality-reviewer S=100/100 → `03-review/` (report: `docs/reports/build-gate-review/1405-review-2026-07-09.md`)

---

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports. Persistent findings and regression guards are part of
> the acceptance contract.

### Latest Review

- **Date**: 2026-07-09
- **Reviewer profile**: `reviewers`
- **Score**: `96/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Full report**: `docs/reports/review-wave-2026-07-09/task-1405-detail-shell-independent-rereview.md`
- **Lane outcome**: remains in review
- **Task reference**: Task 1405 (`detail-variant-and-responsive-shell-reconciliation`)

#### Current Open Blockers

- None for named exit suites (`extended_detail_variants`, `skill_task_detail_widgets`, `responsive_detail_integration` all green inside **100/100** asset_detail run).
- `PERSISTENT` residual: upstream Task 1403 corpus incomplete; synthetic detail proofs do not fully cover live nested nodes.
- `PERSISTENT` residual: `_PartialSupportBanner` ignores `message` (hardcodes “Partial support”).

#### Path-to-100 Summary

- Render banner `message` (or drop unused field); optional live nested-corpus detail proof after 1403; optional test analyzer info cleanup.

### Previous Reports

- `2026-07-09` — `100/100` — `docs/reports/build-gate-review/1405-review-2026-07-09.md`
  - **Carried forward**: unused banner message; package residual EXTERNAL.
  - **Resolved since**: independent re-run still **100/100** asset_detail.
  - **Regression guard**: keep `PrismBreakpoints` / `PrismDetailInspector`; dispose overlay `AnimationController`.
- `2026-06-17` — `86/100` — `docs/reports/build-gate-review/1405-review-2026-06-17.md`
- `2026-06-13` — `100/100` — `docs/reports/build-gate-review/1405-review.md`

### Residual path-to-100 — 2026-07-10 (builders)

_PartialSupportBanner now renders `message` prop (not hardcoded Partial support).

### Independent drain review — 2026-07-17 (gt-flutter-code-reviewer + code-quality-harness)
- **Score**: `98/100` (prior draft 96)
- **Verdict**: `ACCEPTED_WITH_PATH_TO_100`
- **Full report**: `docs/reports/review-wave-2026-07-17/task-1405-drain-review.md`
- **Live proof**: asset_detail **+101**; partial-support banner now uses `message`; 4 test INFO residual
- **Lane**: moved `03-review/` → `04-completed/`

---

### 2026-07-18 — builders path-to-100 residual batch5

| Field | Value |
| --- | --- |
| **Wave** | path-to-100-wave-2026-07-17 / batch5 |
| **Executor** | builders (parent agentID=builders) |
| **Lane** | remain `docs/tasks/03-review/` (no lane move; no git/tasklist) |
| **Notes** | `docs/reports/path-to-100-wave-2026-07-17/batch5-notes.md` |

**Residuals applied**: const-literal cleanups in `extended_detail_variants_test.dart` (`dart fix --apply`) → zero INFO.
**Live**: `dart analyze test/features/asset_detail/extended_detail_variants_test.dart` → **No issues found**.
**Remaining**: none task-scope.



---

### 2026-07-18 — independent path100 re-review (BATCH R5 / reviewers)

| Field | Value |
| --- | --- |
| **Score** | 100/100 |
| **Verdict** | ACCEPTED_COMPLETED |
| **path-to-100 applied** | YES |
| **Lane** | `04-completed/` |
| **Report** | `docs/reports/review-wave-2026-07-18/task-1405-path100-rereview.md` |
| **Top finding** | None |
| **Exits** | asset_detail +105 PASS; analyze 0 issues |
| **Reviewer** | independent (parent agentID=reviewers) |
| **Prior treated as** | draft — live re-proved after batch5 residual wave |
