# Task 1208: Existing Task Lane Reconciliation and Review Backlog Snapshot

> **Status**: `[x]` Builder Done
> **Review State**: Builder Done — completion evidence filled; gate verification pending
> **Priority**: 🔴 P0
> **Type**: `governance`
> **Origin**: EPIC-12, stabilization wave, 79 tasks in `02-doing/` with ambiguous status.
>   Analysis document identifies this as critical: the promotion state model cannot
>   deliver value if the existing backlog is not classified.
> **Blocks**: Future review waves, all tasks transitioning from `02-doing/` to `03-review/`
> **Depends on**: 1202 (promotion state model), 1201 (failure baseline inventory)

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1208` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

Classify every task currently in `docs/tasks/02-doing/` using the new promotion
state model. Produce a Review Backlog Snapshot that tells the project: which
tasks are Ready For Review, which are Package Gate Failed, which are Needs Repair,
and which are Superseded. This is the equivalent of applying new law to pending cases.

## Background Context

### What already exists

- 95 current tasks in `docs/tasks/02-doing/` as of the 2026-06-11 refresh.
  The original 79-task backlog from 2026-06-09 is historical context.
- Many have `Status: [x] Done` but are still in `02-doing/`.
- Some have completion evidence but the package gate was red.
- Some have `Status: [ ]` Open inside `02-doing/` (lane violation).
- Some have `[/]` and `[~]` markers without canonical meaning.
- `.agents/rules/promotion-state-model.md` defines formal states (Task 1202).
- `docs/reports/warp-prism-test-failure-baseline.md` maps known failures
  (Task 1201).
- `docs/governance/test-gate-matrix.md` defines required gates per task type
  (Task 1203).

### What is missing or broken

- No classification of existing tasks using the new promotion states.
- "Done" in `02-doing/` could mean anything from "builder ran one local test"
  to "all gates pass, awaiting reviewer."
- No way to know which tasks can move to `03-review/` without re-reading each one.
- The 95-task live backlog creates cognitive ambiguity: "is it done or isn't it?"

---

## Test Requirements

- Every task in `02-doing/` has a `Review State` field (from the promotion
  state model).
- A snapshot report lists all tasks grouped by classification.
- Classifications are consistent with the failure baseline inventory.

---

## Exit Conditions

- [x] A report exists at `docs/reports/warp-prism-review-backlog-snapshot.md`
  listing every task in `02-doing/` with its classification.
- [x] Each task in `02-doing/` has a `Review State` annotation in its file header.
- [x] Classification uses these categories (from the analysis document):
  - **DONE_READY_FOR_REVIEW**: evidence filled, validation commands captured,
    no known blocker except reviewer quota.
  - **PARTIAL_BLOCKED**: implementation done, analyze/test blocked or failing.
  - **NEEDS_REPAIR**: evidence contradicts code, imports broken, guardrails violated.
  - **SUPERSEDED**: task stale/obsolete.
- [~] At least 5 tasks are reclassified from `02-doing/` to `03-review/` if
  they qualify as DONE_READY_FOR_REVIEW. **Deferred**: anti-hallucination guardrail
  prohibits lane moves without user approval. Conservative 2026-06-11 refresh maps
  0 current `02-doing/` tasks to DONE_READY_FOR_REVIEW; 3 tasks remain Open with
  lane mismatch; 92 tasks are PARTIAL_BLOCKED. The 02-doing lane contains 95 tasks
  after Task 1205 was promoted to 03-review by its own reviewer-approved
  remediation; this task did not perform that lane move.
- [x] Local changelog entry added under `docs/changelog/`.
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: Read
  `.agents/rules/promotion-state-model.md`,
  `docs/reports/warp-prism-test-failure-baseline.md` (from Task 1201),
  and `docs/governance/test-gate-matrix.md` (from Task 1203).
- [x] List all files in `docs/tasks/02-doing/`.
- [x] For each task file, read the header (Status, Completion Evidence, validation
  commands) and classify:
  - If `Status: [x]` and evidence is filled and validation commands show PASS →
    DONE_READY_FOR_REVIEW.
  - If `Status: [x]` but package gate is red per failure inventory →
    PARTIAL_BLOCKED.
  - If evidence contradicts code or imports are broken → NEEDS_REPAIR.
  - If task is obsolete or superseded by stabilization wave → SUPERSEDED.
  - If `Status: [ ]` or `[/]` → remains In Progress (no classification needed).
- [x] Add `> **Review State**: <classification>` to each classified task header.
- [x] Write the snapshot report to `docs/reports/warp-prism-review-backlog-snapshot.md`
  with tables grouped by classification.
- [~] For tasks classified as DONE_READY_FOR_REVIEW, move them to `03-review/`
  (or propose the move if lane changes need user approval).
- [x] **Simplicity pass**: classification is based on header evidence, not deep
  code review. The goal is triage, not final review.
- [x] **Regression verification**: verify the snapshot count matches the `02-doing/`
  file count.

### Where

| File | Purpose |
| --- | --- |
| `docs/reports/warp-prism-review-backlog-snapshot.md` | Modify — backlog snapshot |
| `.agents/rules/promotion-state-model.md` | Read — state definitions |
| `docs/reports/warp-prism-test-failure-baseline.md` | Read — failure data |
| `docs/governance/test-gate-matrix.md` | Read — gate requirements |
| `docs/tasks/02-doing/*.md` | Read / Modify — add or repair Review State annotations |

### How

1. Read the promotion state model and failure inventory.
2. List all 95 current tasks in `02-doing/`.
3. For each, read the header and classify.
4. Add `Review State` annotation.
5. Write the snapshot report.
6. Propose lane moves for DONE_READY_FOR_REVIEW tasks.

### Why

The analysis document says: "a árvore está semanticamente confusa" (the tree is
semantically confused). 79 tasks with `[x] Done` in `02-doing/` means the
promotion state model has no real impact until it is applied to existing cases.
This task is the bridge between the new governance model and the existing backlog.
The 2026-06-11 refresh uses the live 95-task `02-doing/` filesystem count and
the canonical failure/gate evidence paths.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not move tasks from `02-doing/` to `03-review/` without user approval.
> This task classifies and proposes; it does not execute lane changes unilaterally.

> [!IMPORTANT]
> Classification is triage, not review. A task classified as DONE_READY_FOR_REVIEW
> still needs a reviewer to verify correctness. The classification says "no known
> blocker," not "verified correct."

---

## Validation Commands

```bash
ls docs/tasks/02-doing/*.md | wc -l
python - <<'PY'
from pathlib import Path
import re, sys
files = sorted(Path('docs/tasks/02-doing').glob('*.md'))
failures = []
for path in files:
    lines = path.read_text(errors='replace').splitlines()[:15]
    count = sum(1 for line in lines if re.match(r'^>\s+\*\*Review State\*\*:', line))
    if count != 1:
        failures.append((str(path), count))
if failures:
    print('HEADER_REVIEW_STATE_CHECK: FAIL')
    for path, count in failures:
        print(f'{path}: header_review_state_count={count}')
    sys.exit(1)
print(f'HEADER_REVIEW_STATE_CHECK: OK total_files={len(files)} every_file_has_exactly_one_header_review_state=True')
PY
dart format --set-exit-if-changed docs/reports/warp-prism-review-backlog-snapshot.md docs/changelog/2026-06-09-task-1208-existing-task-lane-reconciliation.md
test -f docs/reports/warp-prism-test-failure-baseline.md
test -f docs/governance/test-gate-matrix.md
rg "DONE_READY_FOR_REVIEW|PARTIAL_BLOCKED|NEEDS_REPAIR|SUPERSEDED" docs/reports/warp-prism-review-backlog-snapshot.md
```

---

## Completion Evidence

- **Files created/modified**:
  - MODIFIED: `docs/reports/warp-prism-review-backlog-snapshot.md` — refreshed to 95 current `02-doing/` tasks, task-contracted category mapping, canonical evidence paths, and header-aware validation proof.
  - MODIFIED: `docs/changelog/2026-06-09-task-1208-existing-task-lane-reconciliation.md` — refreshed counts and evidence.
  - MODIFIED: 18 task headers in `docs/tasks/02-doing/*.md` — added missing header-level `Review State` to 12 tasks and corrected stale Open/Doing classifications for 6 evidence-backed EPIC-13/EPIC-14 tasks; no lane files were moved by Task 1208. Task 1205 was moved to `03-review/` by its own approved remediation, not by this reconciliation task.
- **Tests or validation commands**:
  - `ls docs/tasks/02-doing/*.md | wc -l` → `95`
  - Header-aware check → `HEADER_REVIEW_STATE_CHECK: OK total_files=95 every_file_has_exactly_one_header_review_state=True`
  - `dart format --set-exit-if-changed docs/reports/warp-prism-review-backlog-snapshot.md docs/changelog/2026-06-09-task-1208-existing-task-lane-reconciliation.md` → Markdown applicability probe; Dart formatter could not parse Markdown and formatted no files in 0.01 seconds.
  - `test -f docs/reports/warp-prism-test-failure-baseline.md` → PASS (exit 0; no stdout)
  - `test -f docs/governance/test-gate-matrix.md` → PASS (exit 0; no stdout)
  - `rg "DONE_READY_FOR_REVIEW|PARTIAL_BLOCKED|NEEDS_REPAIR|SUPERSEDED" docs/reports/warp-prism-review-backlog-snapshot.md` → category mapping present; exact output recorded by final validation.
- **Classification distribution**:
  - `DONE_READY_FOR_REVIEW`: 0 tasks
  - `PARTIAL_BLOCKED`: 92 tasks
  - `NEEDS_REPAIR`: 3 tasks
  - `SUPERSEDED`: 0 tasks
  - Promotion-state counts: Blocked 47; Builder Done 25; Package Gate Failed 18; Doing 2; Open 3.
- **Local changelog entry**: `docs/changelog/2026-06-09-task-1208-existing-task-lane-reconciliation.md`
- **Agent-wiki / docs institutionalization**: `docs/reports/warp-prism-review-backlog-snapshot.md`
- **Executor**: builders
- **Completion date**: 2026-06-11

---
## Review Ledger

### 2026-06-11 — gt-build-review
**Score**: 68/100 — Debt
**Verdict**: REJECTED → stays in `02-doing`
**Diagnostics**: Flutter analyze N/A | Dart format N/A | Flutter test N/A | governance file/count checks FAIL
**Report**: `docs/reports/build-gate-review/1208-review.md`
**Patches applied**: none — score below 90
**Findings**:
1. Live `docs/tasks/02-doing/` count was `95`; the stale report claimed `92` and the review note cited `98`.
2. 12 current task headers lacked a header-level `Review State` annotation; exactly one was added to each missing file.
3. 6 evidence-backed EPIC-13/EPIC-14 tasks still had stale `Open` classifications despite filled completion evidence; these were conservatively moved to `Builder Done`, `Doing`, or `Package Gate Failed` without lane movement.
4. Snapshot evidence paths were reconciled to `docs/reports/warp-prism-test-failure-baseline.md` and `docs/governance/test-gate-matrix.md`.
5. Snapshot category mapping now uses `DONE_READY_FOR_REVIEW`, `PARTIAL_BLOCKED`, `NEEDS_REPAIR`, and `SUPERSEDED` alongside promotion-state labels.
6. Validation proof now uses a header-aware script that scans only the first 15 lines of each task file and requires exactly one `> **Review State**:` line.
**Path to 100**:
1. Re-run reconciliation against the live `02-doing` lane; live count is 95 after Task 1205's own lane move to `03-review/`.
2. Add exactly one header-level `> **Review State**:` annotation to every current `02-doing` task.
3. Refresh the backlog snapshot totals, tables, anomalies, and priority order to match the live lane.
4. Resolve evidence-path drift by using actual canonical paths: `docs/reports/warp-prism-test-failure-baseline.md` and `docs/governance/test-gate-matrix.md`.
5. Add the required category mapping alongside promotion states: `DONE_READY_FOR_REVIEW`, `PARTIAL_BLOCKED`, `NEEDS_REPAIR`, `SUPERSEDED`.
6. Replace brittle grep count proof with a header-aware validation script and record fresh outputs.
7. Explicitly distinguish Task 1205's own approved lane move from Task 1208's lane-neutral reconciliation work.
---
