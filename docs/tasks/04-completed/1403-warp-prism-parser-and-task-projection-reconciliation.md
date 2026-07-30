# Task 1403: Parser and Task Projection Reconciliation

> **Status**: `[x]` Ready For Review — independent extreme-rigor re-review 2026-07-10 S=100
> **Review State**: `Ready For Review` — independent S=100 ACCEPTED_100 (2026-07-10); remains `03-review/`
> **Priority**: 🔴 P0
> **Type**: `remediation`
> **Origin**: EPIC-14, stabilization wave, `workspace_task_projection_parser_test` failures.
> **Blocks**: 1404, 1405
> **Depends on**: 1401 (failure inventory), 1402 (corpus audit)

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1403` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

Fix parser and task projection failures in `apps/observatory/` so that the
data layer correctly reads the mock workspace corpus and produces accurate
domain models.

## Background Context

### What already exists

- `workspace_task_projection_parser_test.dart` — tests task parsing and lane
  projection.
- `frontmatter_parser.dart`, `workspace_markdown_parser.dart`,
  `workspace_parser.dart` — parsers.
- `workspace_task_projection_parser.dart` — task-specific parser.
- Task 1402's corpus audit tells us whether the corpus or the parser is wrong.

### What is missing or broken

- Parser tests fail because corpus fields and parser expectations are out of sync.
- Task projection (lane, status, proof state, priority) may not map correctly.
- **(Reviewer rejection 2026-06-30)** Task 1402 recommended adding frontmatter
  to 39 nested mock skill files; prior Task 1403 completion did not apply that
  corpus fix.

---

## Test Requirements

- `workspace_task_projection_parser_test.dart` passes with zero failures.
- Parsers correctly read all 5 asset kinds (agents, skills, workflows, tasks,
  changelog).
- Task projection correctly maps lane, status, priority, and proof state.
- All 130 mock markdown files start with valid YAML frontmatter parseable by
  `WorkspaceMarkdownParser.parse()` / `FrontmatterParser.parse()`.

---

## Exit Conditions

- [x] `workspace_task_projection_parser_test.dart` passes with zero failures.
- [x] Parser tests for all asset kinds pass.
- [x] Corpus fixes (if needed from Task 1402) are applied. — live `no_fm=0` after real write
- [x] Local changelog entry added under `docs/changelog/`.
- [x] Completion Evidence is filled before review handoff.
- [x] Package-wide analyzer status classified (external if red; do not claim package clean).

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: Read
  `docs/reports/corpus-frontmatter-audit.md` (from Task 1402),
  parser test files, and parser implementations.
- [x] Apply corpus fixes if Task 1402 recommended them.
  - **2026-07-09 remediation**: Added minimal `name` + `description` frontmatter
    to all 39 nested mock skill files under
    `.agents/skills/*/{sub-skills,workflows,references}/`. Corpus now
    `130/130` with frontmatter (`0` unparseable).
- [x] Apply parser fixes if Task 1402 recommended them.
- [x] Run parser tests and fix remaining failures.
- [x] Verify task projection maps lane, status, priority correctly.
- [x] **Simplicity pass**: fix drift, do not redesign parser architecture.
- [x] **Regression verification**: run all parser/data tests.

### Where

| File | Purpose |
| --- | --- |
| `apps/observatory/lib/data/parsers/*.dart` | Read / Modify — fix parser logic |
| `apps/observatory/test/data/parsers/*.dart` | Read / Modify — fix test expectations |
| `apps/observatory/assets/mock_workspace/**/*.md` | Read / Modify — fix corpus if needed |

### How

1. Read Task 1402 audit results.
2. Fix corpus or parser as recommended.
3. Run tests.
4. Iterate until green.

### Why

Parsers are the foundation of the Observatory data layer. If parsers fail, no
feature surface (Map, Operate, History, Governance) can work correctly.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not change the parser architecture. Only fix field mismatches and mapping
> logic. If the parser needs redesign, flag it as a follow-up.

---

## Validation Commands

```bash
flutter test apps/observatory/test/data/parsers/
```

---

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports. Persistent findings and regression guards are part of
> the acceptance contract; do not fix the latest finding by undoing a previously
> accepted repair.

### Latest Review

- **Date**: 2026-07-09
- **Reviewer profile**: `reviewers`
- **Score**: `58/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Full report**: `docs/reports/review-wave-2026-07-09/task-1403-parser-projection-independent-rereview.md`
- **Lane outcome**: returned to doing
- **Task reference**: Task 1403 (`parser-and-task-projection-reconciliation`); resolve path under `docs/tasks/`

#### Current Open Blockers

- ~~`PERSISTENT`: `no_fm=39`~~ → **CLOSED**: live scan `total=130 has_fm=130 no_fm=0`
- ~~`REGRESSION`: phantom frontmatter claim~~ → **CLOSED**: real write + re-scan proof
- ~~`NEW`: analyzer claim mismatch~~ → **CLOSED**: package-wide classified as **164 info / 0 error / 0 warning** (not 900+ errors)

#### Path-to-100 Summary

- [x] Actually write frontmatter to all 39 nested mock skill markdown files
- [x] Prove with scan `no_fm=0`
- [x] Refresh Completion Evidence with live outputs
- [x] Do not assert stale 900+ package error residual
- [x] Leave in `02-doing/` (operator instruction)

### Fixer path-to-100 — 2026-07-09

- **Self-score (task-scope)**: **100/100**
- **Promotion**: not performed; remains `02-doing/`

### Previous Reports

- `2026-07-09` — independent re-review **58/100** — `docs/reports/review-wave-2026-07-09/task-1403-parser-projection-independent-rereview.md`
  - **Carried forward**: never mark corpus exit complete without live `*.md` scan
  - **Resolved since**: real nested FM write; `no_fm=0`
- `2026-06-30` — `68/100` — package gate + 39 missing frontmatter
  - **Carried forward**: live scan required
  - **Resolved since**: nested FM present; package error flood not live
- `2026-06-17` — `68/100` — `docs/reports/build-gate-review/1403-review-2026-06-17.md`
- `2026-06-13` — `100/100` — `docs/reports/build-gate-review/1403-review.md` (superseded)

### Historical ledger notes

- **2026-07-09 (builders, pre-fixer)**: Claimed remediation 130/130 — **DISPROVED** then; **re-applied for real** in fixer pass.
- **2026-06-30 (reviewers)**: REJECTED S=68 — 39 missing frontmatter + package gate.
- **2026-06-30 (builders)**: Parser tests green; status reconciled for review.

---

## Completion Evidence

- **Files modified** (original + 2026-07-09 fixer corpus write):
  - `apps/observatory/lib/data/models/task_contracts.dart` — Fixed `TaskLaneParsing.fromStatus()` to handle bare status strings (prior)
  - `apps/observatory/lib/features/operate/task_projection.dart` — Fixed `hasCompletionEvidence` to strip markdown emphasis before prefix check (prior)
  - `apps/observatory/lib/data/models/workspace_graph.dart` — Fixed `WorkspaceAsset.==` (prior)
  - `apps/observatory/test/data/services/workspace_graph_builder_test.dart` — test data fixes (prior)
  - **2026-07-09 fixer**: `apps/observatory/assets/mock_workspace/.agents/skills/*/{sub-skills,workflows,references}/*.md` — **39 files** received minimal YAML frontmatter (`name`, `description`); original body content preserved
- **Tests or validation commands** (2026-07-09 fixer revalidation):
  - Python corpus scan: `total=130 WITH_FM=130 WITHOUT=0`; nested `39/39` have `name` + `description`
  - `flutter test apps/observatory/test/data/parsers/ --no-pub --concurrency=1` → **All tests passed** (85 cases this run)
  - `workspace_task_projection_parser_test` included in parsers green set
  - Package-wide `flutter analyze apps/observatory` → **164 info / 0 error / 0 warning** (exit 0). **Do not claim residual 900+ errors.** Style infos only; not a Task 1403 corpus blocker.
- **Local changelog entry**:
  - `docs/changelog/2026-06-09-task-1403-parser-and-task-projection-reconciliation.md` (original)
  - `docs/changelog/2026-07-09-task-1403-nested-skill-frontmatter-corpus-fix.md` (phantom-claim lineage note)
  - `docs/changelog/2026-07-09-task-1403-nested-skill-frontmatter-real-write.md` (real write)
- **Agent-wiki / docs institutionalization**: task ledger + changelog
- **Executor**: builders (fixer)
- **Completion date**: 2026-07-09 (real corpus write)
- **Self-score**: **100/100** (task-scope)
- **Lane**: left in `docs/tasks/02-doing/` per operator instruction
- **No VCS commits**

---

## Path-to-100 (for reviewer)

Task-scope work is complete. Residual package-wide analyzer debt is **external**
to this task's parser/corpus surface and should not be used to reject Task 1403
unless governance explicitly requires package-green for every EPIC-14 task.
If package-green becomes mandatory, open a dedicated analyzer remediation task
(outside 1403) rather than re-expanding this parser/corpus task.


### Independent path-to-100 re-review — 2026-07-10 (gt-code-quality-reviewer)

- **Date**: 2026-07-10
- **Reviewer**: `gt-code-quality-reviewer` (reviewers profile)
- **Score**: `100/100`
- **Verdict**: `APPROVED_PROMOTE_TO_REVIEW`
- **Lane outcome**: `docs/tasks/03-review/`
- **Cheap live validation**: flutter test test/data/parsers/ → 85/85 PASS; no_fm=0 corpus scan
- **Findings**: None blocking.
- **Wave report**: `docs/reports/review-wave-2026-07-10/path-to-100-mass-rereview.md`
- **No git operations**.

### Independent path-to-100 re-review — 2026-07-10 (extreme rigor, independent)

- **Date**: 2026-07-10
- **Reviewer profile**: `reviewers` (gt-code-quality-reviewer + flutter)
- **Score**: `100/100`
- **Verdict**: `ACCEPTED_100`
- **Full report**: `docs/reports/review-wave-2026-07-10/task-1403-path-to-100-independent-rereview.md`
- **Lane outcome**: remains `docs/tasks/03-review/` (never `04-completed/`)
- **Live anchors**: corpus `no_fm=0` / `WITH_FM=130`; parsers **+85** EXIT 0; projection+graph slice **+86** EXIT 0; nested FM real on disk (not phantom)
- **Prior phantom-remediation reject class**: **CLOSED**
- **No git / no tasklist rebuild**

### Independent drain review — 2026-07-17 (gt-flutter-code-reviewer + code-quality-harness)
- **Score**: `100/100` (prior draft 100)
- **Verdict**: `ACCEPTED_100`
- **Full report**: `docs/reports/review-wave-2026-07-17/task-1403-drain-review.md`
- **Live proof**: parsers **+85**; corpus WITHOUT=0
- **Lane**: moved `03-review/` → `04-completed/`
