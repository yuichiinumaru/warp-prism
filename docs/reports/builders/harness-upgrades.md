# Harness Upgrade Log — Builder Orchestrator

> **Purpose**: Track recurring failure patterns during review-fix cycles and
> propose skill/workflow/rule upgrades when the same mistake is likely to recur.
> **Updated**: 2026-06-11

---

## Wave 0 — 1308 Review

**Status**: Complete
**Tasks**: 1308 (Toast Async Lifecycle Stabilization)
**Final score**: 100/100
**Rounds**: 3 review/fix cycles (63 → 57 → 100)

### Review / Fix Ping-Pong

| Round | Score | Verdict | Primary Findings |
| --- | ---: | --- | --- |
| 1 | 63 | REJECTED | Analyzer red, semantics excluded, fakeAsync contract unmet, touch target too small, stale overlay, missing action tests, protected file drift |
| 2 | 57 | REJECTED | Semantics duplication regression from fix, stale Completion Evidence, stale changelog, analyzer baseline not classified |
| 3 | 100 | APPROVED | All findings resolved; package analyzer 467 issues classified as pre-existing external blocker |

### Observations

1. **Semantics fixes are high-risk without regression tests**
   - Round 1 fix removed global `ExcludeSemantics` but introduced duplicate semantics nodes.
   - Round 2 caught this with a semantics label count test.
   - **Harness implication**: Flutter reviewer axiom checks should explicitly require tests to assert semantics label counts, not just presence.

2. **Completion Evidence drifts whenever test counts change**
   - Task claimed 33/33 tests after the suite grew to 38 tests.
   - Evidence must be mechanically refreshed after every fix round, not copied from prior evidence.
   - **Harness implication**: build-review should add a sub-skill/check to compare claimed test counts against actual output.

3. **Changelog stale claims are common**
   - Changelog still referenced `AGENTS.md` / `.gitignore` changes after they were reverted or split out.
   - **Harness implication**: reviewer should compare changelog claims against actual file changes and task `Where` table.

4. **Protected file scope drift needs explicit governance approval**
   - Task 1308 modified `AGENTS.md` and `.gitignore` outside its `Where` table.
   - **Harness implication**: code-quality-harness should flag any change outside task `Where` as a finding unless the task explicitly approves the scope change.

5. **Analyzer baseline classification is essential**
   - `flutter analyze lib/` still reports 467 pre-existing issues.
   - Without classification, package gate remains red even when task-owned files are clean.
   - **Harness implication**: build-review should require a formal analyzer baseline report for any task that cannot clear package-level analyzer due to pre-existing issues.

---

## Wave 1 — EPIC-12 Governance

**Status**: Pending
**Tasks**: 1201, 1202, 1203, 1204, 1205, 1206, 1208
**Observations**: —

---

## Wave 2 — EPIC-13 ADS Stabilization

**Status**: Pending
**Tasks**: 1304, 1303, 1307, 1309, 1302, 1301, 1305, 1306
**Observations**: —

---

## Recurring Patterns

| Pattern | Frequency | Affected Tasks | Proposed Upgrade |
|---------|-----------|----------------|------------------|
| Semantics fixes without count tests | 1 | 1308 | Add flutter-harness axiom: semantics label count assertions for every semantics fix |
| Completion Evidence stale test counts | 1 | 1308 | Add verification-gate check: compare evidence claims against actual command output |
| Changelog stale claims | 1 | 1308 | Add review check: changelog claims must match actual file changes |
| Protected file scope drift | 1 | 1308 | Add code-quality-harness rule: flag changes outside task `Where` table |
| Analyzer baseline missing | 1 | 1308 | Add build-review requirement: formal analyzer baseline report for pre-existing issues |

---

## Proposed Skill/Workflow Upgrades

| Skill/Workflow | Issue | Proposed Change | Priority |
|----------------|-------|-----------------|----------|
| `flutter-harness` | Semantics fixes can introduce duplicate nodes | Add explicit requirement for label-count assertions, not just label presence | High |
| `code-quality-harness/verification-gate` | Completion Evidence can stale-copy old test counts | Add automated evidence count comparison against command output | High |
| `gt-build-review` | Reviewers should catch stale changelog claims | Add changelog-to-diff consistency check | Medium |
| `gt-build-review` | Protected files outside `Where` table slip through | Add explicit scope drift finding template | High |
| `code-quality-harness` | Package analyzer failures need formal classification | Add analyzer baseline report template for pre-existing failures | High |
