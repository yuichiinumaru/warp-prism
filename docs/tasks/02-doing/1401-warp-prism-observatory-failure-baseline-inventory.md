# Task 1401: Observatory Failure Baseline Inventory

> **Status**: `[x]` Builder Done
> **Review State**: Builder Done — observatory failure inventory evidence filled; gate verification pending
> **Priority**: 🔴 P0
> **Type**: `governance`
> **Origin**: EPIC-14, stabilization wave, 64 failures in `apps/observatory/`.
> **Blocks**: 1402, 1403, 1404, 1405, 1406, 1407
> **Depends on**: 1201 (failure taxonomy definitions), 1202 (promotion state model)

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1401` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

Create a detailed inventory of all 64 Observatory test failures, classified
by chain position (corpus, parser, projection, mapper, view, test stale,
compile) and taxonomy class. This is the Observatory-specific counterpart
of Task 1201.

## Background Context

### What already exists

- Task 1201 creates a monorepo-wide failure inventory. This task dives deeper
  into the Observatory-specific failures.
- Known failing files: `workspace_task_projection_parser_test`,
  `extended_detail_variants_test`, `skill_task_detail_widgets_test`,
  `history_story_modes_test`, `responsive_detail_integration_test`,
  `operate_task_detail_inspector_test`, plus additional failures in providers,
  repositories, and workspace snapshot tests.

### What is missing or broken

- No Observatory-specific failure inventory with chain position classification.
- No understanding of whether failures are top-down (corpus wrong → parser
  fails) or bottom-up (view stale → test fails).

---

## Test Requirements

- Inventory covers every failing test in `apps/observatory/`.
- Each failure is classified by chain position AND taxonomy class.
- The inventory distinguishes top-down vs bottom-up failures.

---

## Exit Conditions

- [x] Observatory-specific failure inventory created at
  `docs/reports/observatory-failure-baseline.md` with per-failure detail.
- [x] Each failure has file, test name, taxonomy class, chain position, and
  root cause hypothesis.
- [x] Local changelog entry added under `docs/changelog/`.
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: Read
  `docs/reports/warp-prism-failure-baseline-inventory.md` (from Task 1201),
  `.agents/rules/promotion-state-model.md`, and
  `apps/observatory/test/` directory structure.
- [x] Run `flutter test apps/observatory/` and capture all failures.
- [x] For each failure, identify the chain position:
  - **Corpus**: mock workspace files have wrong format/fields.
  - **Parser**: parser expects different frontmatter shape.
  - **Projection**: parser output → domain model mapping is broken.
  - **Mapper**: domain model → presentation model mapping is broken.
  - **View**: presentation widget expects different shape.
  - **Test stale**: code is correct, test expectation is old.
  - **Compile**: file does not compile.
- [x] Write the Observatory section of the inventory report.
- [x] **Simplicity pass**: hypotheses, not certainties. The reconciliation
  tasks (1403-1406) will verify.
- [x] **Regression verification**: verify inventory matches test output.

### Where

| File | Purpose |
| --- | --- |
| `docs/reports/observatory-failure-baseline.md` | Created — per-failure inventory with chain position and root cause |
| `apps/observatory/test/` | Read — all 14 failing test files |

### How

1. Run Observatory tests.
2. Classify each failure by chain position.
3. Write the section.

### Why

The Observatory failures are a vertical chain. Without understanding the chain
position of each failure, builders might fix views when the problem is in
parsers, or fix parsers when the problem is in the corpus.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Classify as "hypothesis" unless you have read both the test and the
> implementation. Do not guess chain position from test name alone.

---

## Validation Commands

```bash
flutter test apps/observatory/
cat docs/reports/warp-prism-failure-baseline-inventory.md
```

---

## Completion Evidence

- **Files created/modified**: `docs/reports/observatory-failure-baseline.md` (created, 411 lines)
- **Tests or validation commands**:
  - `flutter test apps/observatory/` — 653 tests, 589 pass, 64 fail (matches Task 1201 baseline)
  - `test -f docs/reports/observatory-failure-baseline.md` — PASS
- **Local changelog entry**: `docs/changelog/2026-06-09-task-1401-observatory-failure-baseline.md`
- **Agent-wiki / docs institutionalization**: N/A
- **Executor**: builders
- **Completion date**: 2026-06-09
