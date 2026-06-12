# Task 1406: History and Operate Feature Flow Reconciliation

> **Status**: `[ ]` Open
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

- [ ] `history_story_modes_test.dart` passes.
- [ ] `operate_task_detail_inspector_test.dart` passes.
- [ ] Local changelog entry added under `docs/changelog/`.
- [ ] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [ ] **Read existing code before modifying**: Read the 2 failing test files
  and the corresponding feature implementations.
- [ ] For each failure, determine: stale test or broken feature.
- [ ] Fix accordingly.
- [ ] **Simplicity pass**: fix drift, do not redesign features.
- [ ] **Regression verification**: run history and operate tests.

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

- **Files created/modified**: [list]
- **Tests or validation commands**: [commands and PASS/FAIL]
- **Local changelog entry**: [path]
- **Agent-wiki / docs institutionalization**: [path or N/A]
- **Executor**: [agent]
- **Completion date**: [YYYY-MM-DD]
