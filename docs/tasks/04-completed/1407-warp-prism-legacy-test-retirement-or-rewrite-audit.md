# Task 1407: Legacy Test Retirement or Rewrite Audit

> **Review State**: In Review (`03-review/`) — APPROVED_TO_REVIEW by gt-code-quality-reviewer; full suite re-proof **+736 PASS**
> **Priority**: 🟡 P1
> **Type**: `governance`
> **Origin**: EPIC-14, stabilization wave, some tests may be testing outdated
>   architecture rather than current behavior.
> **Blocks**: Final Observatory gate green status
> **Depends on**: 1403, 1404, 1405, 1406 (all reconciliations should be done first)
> **Latest review**: `docs/reports/build-gate-review/1407-review-2026-07-09-independent.md` — **100/100**

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1407` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

After all Observatory reconciliations (1403-1406), audit remaining failing tests
and decide: keep, correct, rewrite, or archive. Some tests may be testing
an architecture that no longer exists.

## Background Context

### What already exists

- After Tasks 1403-1406, some tests may still fail.
- These remaining failures may be: tests that test the old architecture, tests
  with expectations that were never updated after model changes, or genuine
  regressions that need deeper fixes.

### What is missing or broken

- No retirement/rewrite audit for Observatory tests.
- Stale tests consume CI time and produce noise.

---

## Test Requirements

- Every remaining failing test is classified: keep (fix), rewrite, or archive.
- Archived tests are moved to a clearly marked directory or marked with
  `// ARCHIVED` comments.

---

## Exit Conditions

- [x] A report exists at `docs/reports/warp-prism-observatory-test-retirement-audit.md`
  listing every remaining failing test with decision and justification.
- [x] Archived tests are moved or marked.
  *(Zero archives — none of the residual failures test dead product architecture.
  Documented in the audit report §6.)*
- [x] Tests classified as "keep" have a fix task (could be this task or a follow-up).
  *(F-1407-02 fixed earlier; F-1407-03 workspace_snapshot DS*→Prism* migration
  applied in residual path-to-100 pass on 2026-07-09.)*
- [x] Local changelog entry added under `docs/changelog/`.
  *(Local draft note only — not changelog-engine published:
  `docs/changelog/2026-07-09-task-1407-workspace-snapshot-prism-migration.md`.)*
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: Read all remaining failing
  Observatory tests after Tasks 1403-1406 are complete.
- [x] For each failing test, decide:
  - **Keep + fix**: test tests current behavior, just needs fixing.
  - **Rewrite**: test tests relevant behavior but implementation is obsolete.
  - **Archive**: test tests architecture that no longer exists.
- [x] Write the retirement audit report.
- [x] Move/archive tests as decided.
  *(None archived; rewrite + keep+fix applied where in-scope.)*
- [x] **Simplicity pass**: archive means move, not delete.
- [x] **Regression verification**: run Observatory tests and verify remaining
  failures are only in archived/deferred tests.
  *(Post residual migration: `flutter test apps/observatory/` → **+736 PASS**,
  0 fails. F-1407-03 resolved.)*
- [x] **F-1407-03 residual**: migrate `lib/features/workspace_snapshot/**`
  from hidden `DS*` constructors to public `Prism*` APIs; re-prove page suite.

### Where

| File | Purpose |
| --- | --- |
| `docs/reports/warp-prism-observatory-test-retirement-audit.md` | Create — retirement audit |
| `apps/observatory/test/` (remaining failures) | Read — classify each |
| `apps/observatory/test/app/app_bootstrap_test.dart` | Rewrite — bootstrap smoke |
| `apps/observatory/test/data/parsers/workspace_task_projection_parser_test.dart` | Keep+fix — CWD corpus path |
| `apps/observatory/test/features/workspace_snapshot/workspace_snapshot_page_test.dart` | Keep+fix — re-enabled after Prism migration |
| `apps/observatory/lib/features/workspace_snapshot/**` | Migrate DS* → Prism* consumer APIs |
| `docs/changelog/2026-07-09-task-1407-workspace-snapshot-prism-migration.md` | Local changelog draft |

### How

1. Run Observatory tests after 1403-1406.
2. Classify each remaining failure.
3. Write report.
4. Archive as needed.

### Why

A test that tests dead architecture is noise, not signal. Removing it (via
archive) makes the test suite a more accurate reflection of product health.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Archive, never delete. Archived tests go to `.archive/tests/` or are marked
  with `// ARCHIVED — reason: ...`. The archive protocol (never delete) applies.

> [!IMPORTANT]
> If a test is testing something relevant but failing because of a real bug,
  classify it as "keep + fix," not "archive."

---

## Validation Commands

```bash
flutter test apps/observatory/
cat docs/reports/warp-prism-observatory-test-retirement-audit.md
```

---

## Classification summary (executor)

| ID | Failure | Decision | Action |
|---|---|---|---|
| F-1407-01 | `app_bootstrap_test.dart` load + stale `/design-system` home | **REWRITE** | Rewrote to theme + gallery isolation smoke |
| F-1407-02 | `workspace_task_projection_parser_test` committed lane corpus | **KEEP + fix** | Multi-candidate CWD path resolution |
| F-1407-03 | `workspace_snapshot_page_test.dart` load (DS* compile) | **KEEP + fix** | Migrated `lib/features/workspace_snapshot/**` to Prism*; suite green |

Archives: **0**.

---

## Changelog Draft

> Local ledger only — **not** published via the parent/child changelog engine.
> Path: `docs/changelog/2026-07-09-task-1407-workspace-snapshot-prism-migration.md`

- **What**: Resolve F-1407-03 by migrating workspace_snapshot production UI from
  hidden `DS*` names to public `Prism*` aliases; re-enable page widget suite.
- **Why**: Public barrel no longer exports `DS*`; residual compile hole blocked
  page tests and any suite that transitively imports the product router graph.
- **Impact**: Observatory `flutter test apps/observatory/` → **+736 / 0 fails**.
- **Out of scope**: No git commit; no engine `CHANGELOG.md` publish; no
  self-promote to `03-review/`.

---

## Completion Evidence

- **Files created/modified**:
  - `docs/reports/warp-prism-observatory-test-retirement-audit.md` — create (audit) + residual update
  - `apps/observatory/test/app/app_bootstrap_test.dart` — rewrite
  - `apps/observatory/test/data/parsers/workspace_task_projection_parser_test.dart` — CWD fix
  - `apps/observatory/test/features/workspace_snapshot/workspace_snapshot_page_test.dart` — re-enabled (annotation cleared)
  - `apps/observatory/lib/features/workspace_snapshot/workspace_snapshot_page.dart` — DS*→Prism*
  - `apps/observatory/lib/features/workspace_snapshot/widgets/*.dart` — DS*→Prism* (11 widget/page files)
  - `apps/observatory/lib/features/workspace_snapshot/workspace_snapshot_provider.dart` — doc only
  - `docs/changelog/2026-07-09-task-1407-workspace-snapshot-prism-migration.md` — local draft
  - `docs/tasks/02-doing/1407-warp-prism-legacy-test-retirement-or-rewrite-audit.md` — this evidence
- **Tests or validation commands**:
  - Baseline (pre-action): `flutter test apps/observatory/` → **+728 −3**
  - After test-only keep/rewrite: **+732 −1** (residual F-1407-03 load)
  - After F-1407-03 Prism migration (2026-07-09 residual pass):
    - `flutter test apps/observatory/test/features/workspace_snapshot/` → **+29 PASS**
    - `flutter test apps/observatory/` → **+736 PASS** (0 fails)
  - `cat docs/reports/warp-prism-observatory-test-retirement-audit.md` → report present
- **Local changelog entry**: `docs/changelog/2026-07-09-task-1407-workspace-snapshot-prism-migration.md` (draft only; engine not published)
- **Agent-wiki / docs institutionalization**: N/A
- **Executor**: gt-flutter-engineer
- **Completion date**: 2026-07-09
- **Self-score (task scope)**: Builder Done — audit + keep/rewrite + F-1407-03 migration complete; package suite green; left in `02-doing` without self-promote (review packet / Ready For Review not claimed)

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
- **Full report**: `docs/reports/review-wave-2026-07-09/task-1407-legacy-test-audit-independent-rereview.md`
- **Lane outcome**: remains in `03-review/` (never 04-completed by reviewer)
- **Task reference**: Task 1407 (`warp-prism-legacy-test-retirement-or-rewrite-audit`)

#### Current Open Blockers

- None (task-scope). Optional full product-router boot smoke is polish, not exit.

#### Path-to-100 Summary

- Already 100/100 task-scope. No code work required for this task ID.

### Previous Reports

- `2026-07-09` — `100/100` — `docs/reports/build-gate-review/1407-review-2026-07-09-independent.md`
  - **Carried forward**: none blocking
  - **Resolved since**: re-proved +736; 0 DS*; monorepo-root parser CWD PASS
  - **Regression guard**: full `flutter test apps/observatory/` green; zero `DS*` under `workspace_snapshot/**`; archives remain 0 unless product route retired
- `2026-06-13` — historical PENDING exits — `docs/reports/build-gate-review/1407-review.md` (superseded)
- Audit deliverable: `docs/reports/warp-prism-observatory-test-retirement-audit.md`

- **2026-07-09 (independent re-review, reviewers)**: **100/100** — `ACCEPTED_100` hold in `03-review/`. Report: `docs/reports/review-wave-2026-07-09/task-1407-legacy-test-audit-independent-rereview.md`. Fresh: full suite **+736**; snapshot **+29**; parser monorepo-root PASS; **0** DS*; analyze 0 error/0 warning. Blockers: none.
- **2026-07-09 independent re-review (gt-code-quality-reviewer)**: **100/100** — `APPROVED_TO_REVIEW`. Report: `docs/reports/build-gate-review/1407-review-2026-07-09-independent.md`. Moved `02-doing/` → `03-review/`.
- **2026-07-09 (gt-flutter-engineer, residual path-to-100)**: Prism migration; full suite **+736 PASS**. Left in `02-doing/` without self-promote.
- **2026-07-09 (gt-flutter-engineer)**: Builder execution complete. Audit at `docs/reports/warp-prism-observatory-test-retirement-audit.md`.

### Independent drain review — 2026-07-17 (gt-flutter-code-reviewer + code-quality-harness)
- **Score**: `99/100` (prior draft 100)
- **Verdict**: `ACCEPTED_WITH_PATH_TO_100`
- **Full report**: `docs/reports/review-wave-2026-07-17/task-1407-drain-review.md`
- **Live proof**: audit report present; full suite **+778** (audit freezes +736 — currency polish)
- **Lane**: moved `03-review/` → `04-completed/`

---

### 2026-07-18 — builders path-to-100 residual batch5

| Field | Value |
| --- | --- |
| **Wave** | path-to-100-wave-2026-07-17 / batch5 |
| **Executor** | builders (parent agentID=builders) |
| **Lane** | remain `docs/tasks/03-review/` (no lane move; no git/tasklist) |
| **Notes** | `docs/reports/path-to-100-wave-2026-07-17/batch5-notes.md` |

**Residuals applied**: audit §0 footnote for 2026-07-17 re-proof currency (**+778** live; historical +736 freeze retained).
**Remaining**: none method/classification residual.



---

### 2026-07-18 — independent path100 re-review (BATCH R5 / reviewers)

| Field | Value |
| --- | --- |
| **Score** | 100/100 |
| **Verdict** | ACCEPTED_COMPLETED |
| **path-to-100 applied** | YES |
| **Lane** | `04-completed/` |
| **Report** | `docs/reports/review-wave-2026-07-18/task-1407-path100-rereview.md` |
| **Top finding** | None |
| **Exits** | audit report present; classifications intact; +778 currency footnote |
| **Reviewer** | independent (parent agentID=reviewers) |
| **Prior treated as** | draft — live re-proved after batch5 residual wave |
