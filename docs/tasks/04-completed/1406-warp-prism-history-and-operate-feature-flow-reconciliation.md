# Task 1406: History and Operate Feature Flow Reconciliation

> **Review State**: Ready For Review — code quality S=100 (2026-07-09); scoped
>   history+operate 119/119 green; format patched by reviewer
> **Priority**: 🟡 P1
> **Type**: `remediation`
> **Origin**: EPIC-14, stabilization wave, failures in `history_story_modes_test`
>   and `operate_task_detail_inspector_test`.
> **Blocks**: 1407
> **Depends on**: 1404 (view-models), 1405 (detail views)

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1406` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

Fix History and Operate feature test failures so that story modes, filters,
inspector, and task detail views work correctly with the current data contracts.

## Background Context

### What already exists

- `apps/observatory/lib/features/history/` — history page, controller, view
  modes, story/impact views.
- `apps/observatory/lib/features/operate/` — operate workspace view, filters,
  storytelling, task detail panel/mapper.
- `history_story_modes_test.dart` — failures in story mode expectations.
- `operate_task_detail_inspector_test.dart` — failures in task detail inspector.

### What is missing or broken

- History story modes may expect different data shapes.
- Operate task detail inspector may expect different task projection fields.
- Feature tests may be stale after data model changes in earlier waves.

---

## Test Requirements

- `history_story_modes_test.dart` passes.
- `operate_task_detail_inspector_test.dart` passes.
- History story modes render correctly.
- Operate inspector shows task metadata, commands, evidence, dependencies.

---

## Exit Conditions

- [x] `history_story_modes_test.dart` passes.
- [x] `operate_task_detail_inspector_test.dart` passes.
- [x] Local changelog entry added under `docs/changelog/`.
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: Read the 2 failing test files
  and the corresponding feature implementations.
- [x] For each failure, determine: stale test or broken feature.
- [x] Fix accordingly.
- [x] **Simplicity pass**: fix drift, do not redesign features.
- [x] **Regression verification**: run history and operate tests.

### Where

| File | Purpose |
| --- | --- |
| `apps/observatory/test/features/history/history_story_modes_test.dart` | Read / Modify — fix test |
| `apps/observatory/test/features/operate/operate_task_detail_inspector_test.dart` | Read / Modify — fix test |
| `apps/observatory/lib/features/history/` | Read / possibly modify |
| `apps/observatory/lib/features/operate/` | Read / possibly modify |

### How

1. Read each test and implementation.
2. Fix drift.
3. Run tests.

### Why

History and Operate are two of the four main Observatory surfaces. If their
tests fail, the Observatory cannot claim to be a functioning prototype.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not redesign the features. Only fix the contract drift between data layer
  and feature UI.

---

## Validation Commands

```bash
flutter test apps/observatory/test/features/history/
flutter test apps/observatory/test/features/operate/
```

---

## Completion Evidence

- **Files created/modified**:
  - `apps/observatory/lib/features/history/presentation/history_page.dart` — package: imports; removed deep relative `../../asset_detail`
  - `apps/observatory/lib/features/history/presentation/history_controller.dart` — package: import for view mode
  - `apps/observatory/lib/features/history/presentation/widgets/history_story_view.dart` — package: import for controller
  - `apps/observatory/lib/features/history/presentation/widgets/history_impact_view.dart` — package: import for controller
  - `apps/observatory/lib/features/operate/operate_task_detail_panel.dart` — package: feature imports
  - `apps/observatory/lib/features/operate/operate_task_detail_mapper.dart` — package: feature imports
  - `apps/observatory/lib/features/operate/operate_workspace_view.dart` — package: feature imports
  - `apps/observatory/lib/features/operate/operate_workspace_view_model.dart` — package: feature imports
  - `apps/observatory/lib/features/operate/operate_storytelling.dart` — package: feature imports
  - `docs/changelog/2026-07-09-task-1406-history-operate-feature-flow-reconciliation.md` — local note
  - Tests: no assertion changes required (already aligned with post-1403/1404 contracts)
- **Tests or validation commands**:
  - `cd apps/observatory && flutter test test/features/history/ test/features/operate/` → **PASS** (119/119)
  - Named suites: `history_story_modes_test.dart` PASS; `operate_task_detail_inspector_test.dart` PASS
- **Local changelog entry**: `docs/changelog/2026-07-09-task-1406-history-operate-feature-flow-reconciliation.md`
- **Agent-wiki / docs institutionalization**: N/A
- **Executor**: gt-flutter-engineer
- **Completion date**: 2026-07-09

### Reconciliation findings

| Area | Determination | Action |
| --- | --- | --- |
| History story/impact modes | Feature + tests already match `HistoryEntry.resolvedSkills/Workflows` and complete-path = task + skill/workflow | Verify only; no behavior redesign |
| Operate inspector sections | Mapper still emits 7 Prism sections; panel uses PrismDetailInspector | Verify only |
| Import boundaries | Deep relative import into asset_detail from history_page; relative feature imports in operate | Converted to `package:warp_prism_observatory/...` |

---

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports. Persistent findings and regression guards are part of
> the acceptance contract.

### Latest Review

- **Date**: 2026-07-09
- **Reviewer profile**: `reviewers` (independent re-review; gt-flutter-code-reviewer + gt-code-quality-reviewer)
- **Score**: `100/100`
- **Verdict**: `ACCEPTED_100`
- **Full report**: `docs/reports/review-wave-2026-07-09/task-1406-history-operate-independent-rereview.md`
- **Lane outcome**: remains in `03-review/` (never 04-completed by reviewer)
- **Task reference**: Task 1406 (`warp-prism-history-and-operate-feature-flow-reconciliation`)

#### Current Open Blockers

- None (task-scope). Package info-level `prefer_const_*` style debt is EXTERNAL.

#### Path-to-100 Summary

- Already 100/100 task-scope. No code work required for this task ID.

### Previous Reports

- `2026-07-09` — `100/100` — `docs/reports/build-gate-review/1406-review-2026-07-09.md`
  - **Carried forward**: none blocking
  - **Resolved since**: re-proved 119/119; format 0 changed; zero relative imports
  - **Regression guard**: history+operate trees must stay green; no relative `../` under history/operate
- `2026-06-13` — historical 100/100 placeholders — `docs/reports/build-gate-review/1406-review.md` (superseded)

- **2026-07-09 (independent re-review, reviewers)**: **100/100** — `ACCEPTED_100` hold in `03-review/`. Report: `docs/reports/review-wave-2026-07-09/task-1406-history-operate-independent-rereview.md`. Fresh: history+operate **119/119**; named **44**; format 0 changed; zero relative imports. Blockers: none.
- **2026-07-09 (gt-code-quality-reviewer)**: **APPROVED — S=100/100 (task-scope).** Fresh `flutter test test/features/history/ test/features/operate/` → **119/119** twice (pre/post format). Named suites PASS. Format patch on 6 files. Report: `docs/reports/build-gate-review/1406-review-2026-07-09.md`. Moved `02-doing/` → `03-review/`.
- **2026-06-13 (gt-build-review)**: Prior 100/100 with unverified placeholders — superseded by 2026-07-09 independent re-proof.

### Independent drain review — 2026-07-17 (gt-flutter-code-reviewer + code-quality-harness)
- **Score**: `100/100` (prior draft 100)
- **Verdict**: `ACCEPTED_100`
- **Full report**: `docs/reports/review-wave-2026-07-17/task-1406-drain-review.md`
- **Live proof**: history **+53**, operate **+66**; selection-sync green
- **Lane**: moved `03-review/` → `04-completed/`
