# Task 1407: Legacy Test Retirement or Rewrite Audit

> **Status**: `[ ]` Open
> **Review State**: Open — unstarted task; lane mismatch (should be in 01-open/)
> **Priority**: 🟡 P1
> **Type**: `governance`
> **Origin**: EPIC-14, stabilization wave, some tests may be testing outdated
>   architecture rather than current behavior.
> **Blocks**: Final Observatory gate green status
> **Depends on**: 1403, 1404, 1405, 1406 (all reconciliations should be done first)

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

- [ ] A report exists at `docs/reports/warp-prism-observatory-test-retirement-audit.md`
  listing every remaining failing test with decision and justification.
- [ ] Archived tests are moved or marked.
- [ ] Tests classified as "keep" have a fix task (could be this task or a follow-up).
- [ ] Local changelog entry added under `docs/changelog/`.
- [ ] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [ ] **Read existing code before modifying**: Read all remaining failing
  Observatory tests after Tasks 1403-1406 are complete.
- [ ] For each failing test, decide:
  - **Keep + fix**: test tests current behavior, just needs fixing.
  - **Rewrite**: test tests relevant behavior but implementation is obsolete.
  - **Archive**: test tests architecture that no longer exists.
- [ ] Write the retirement audit report.
- [ ] Move/archive tests as decided.
- [ ] **Simplicity pass**: archive means move, not delete.
- [ ] **Regression verification**: run Observatory tests and verify remaining
  failures are only in archived/deferred tests.

### Where

| File | Purpose |
| --- | --- |
| `docs/reports/warp-prism-observatory-test-retirement-audit.md` | Create — retirement audit |
| `apps/observatory/test/` (remaining failures) | Read — classify each |

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

## Completion Evidence

- **Files created/modified**: [list]
- **Tests or validation commands**: [commands and PASS/FAIL]
- **Local changelog entry**: [path]
- **Agent-wiki / docs institutionalization**: [path or N/A]
- **Executor**: [agent]
- **Completion date**: [YYYY-MM-DD]
