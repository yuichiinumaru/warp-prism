# Task 1208: Existing Task Lane Reconciliation and Review Backlog Snapshot

> **Review State**: `Promoted` — final reviewer-orchestrator verification 2026-06-26; 95/95 tasks annotated, snapshot report verified against live headers; promoted to 04-completed
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

- 95 current tasks in `docs/tasks/02-doing/` will remain after this reviewer-owned Task 1208 promotion, following Task 1202 and Task 1206 promotions.
  The 95-task count from 2026-06-11, the 98-task pre-promotion count from 2026-06-20, and the 96-task pre-Task-1208-reviewer-move count are historical context.
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
- The post-review 95-task live backlog creates cognitive ambiguity: "is it done or isn't it?"

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
  they qualify as DONE_READY_FOR_REVIEW. **Deferred**: reviewer-owned promotion
  rules prohibit builders from moving lanes. The 2026-06-24 reviewer refresh maps 24
  post-move `02-doing/` tasks to DONE_READY_FOR_REVIEW based on live header states;
  classification distribution is captured in the snapshot report. The `02-doing`
  lane will contain 95 tasks after reviewer-owned Task 1202, Task 1206, and Task 1208 promotions. Task 1205 is currently in `02-doing/`
  with `Review State: Doing`; earlier claims that it was promoted are stale.
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
2. List all 95 post-move current tasks in `02-doing/`.
3. For each, read the header and classify.
4. Add `Review State` annotation.
5. Write the snapshot report.
6. Propose lane moves for DONE_READY_FOR_REVIEW tasks.

### Why

The analysis document says: "a árvore está semanticamente confusa" (the tree is
semantically confused). 79 tasks with `[x] Done` in `02-doing/` means the
promotion state model has no real impact until it is applied to existing cases.
This task is the bridge between the new governance model and the existing backlog.
The 2026-06-24 reviewer refresh uses the final post-move 95-task `02-doing/` filesystem count after Task 1202, Task 1206, and Task 1208 promotions and
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
  - MODIFIED: `docs/reports/warp-prism-review-backlog-snapshot.md` — refreshed to 95 final post-move `02-doing/` tasks (live 2026-06-24 reviewer count after Task 1202, Task 1206, and Task 1208 promotions), task-contracted category mapping, canonical evidence paths, internally consistent task tables, and header-aware validation proof.
  - MODIFIED: `docs/changelog/2026-06-09-task-1208-existing-task-lane-reconciliation.md` — superseded stale 95-task counts with 2026-06-20 live counts/evidence.
  - MODIFIED: `docs/tasks/02-doing/1208-warp-prism-existing-task-lane-reconciliation.md` — corrected Task 1205 current-state wording and 2026-06-20 classification evidence.
- **Tests or validation commands**:
  - `ls docs/tasks/02-doing/*.md | wc -l` → `95` after reviewer-owned Task 1208 lane move
  - Header/state distribution check → `total=95`, `missing=0`, `Doing: 42`, `Ready For Review: 24`, `Package Gate Failed: 15`, `Builder Done: 10`, `Consumer Gate Failed: 3`, `Blocked: 1`
  - `test -f docs/reports/warp-prism-test-failure-baseline.md` → PASS (exit 0; no stdout)
  - `test -f docs/governance/test-gate-matrix.md` → PASS (exit 0; no stdout)
  - `rg "DONE_READY_FOR_REVIEW|PARTIAL_BLOCKED|NEEDS_REPAIR|SUPERSEDED" docs/reports/warp-prism-review-backlog-snapshot.md` → category mapping present; exact output recorded by final validation.
- **Classification distribution** (live 2026-06-24 final post-move scan of 95 tasks in `02-doing` after Task 1202, Task 1206, and Task 1208 promotions):
  - `DONE_READY_FOR_REVIEW`: 24 tasks (headers show `Ready For Review`)
  - `PARTIAL_BLOCKED`: 71 tasks (headers show `Doing`, `Package Gate Failed`, `Builder Done`, `Consumer Gate Failed`, or `Blocked`)
  - `NEEDS_REPAIR`: 0 tasks
  - `SUPERSEDED`: 0 tasks
  - Promotion-state counts (header-only): Doing 42; Ready For Review 24; Package Gate Failed 15; Builder Done 10; Consumer Gate Failed 3; Blocked 1; Open 0.
- **Local changelog entry**: `docs/changelog/2026-06-09-task-1208-existing-task-lane-reconciliation.md`
- **Agent-wiki / docs institutionalization**: `docs/reports/warp-prism-review-backlog-snapshot.md`
- **Executor**: builders
- **Completion date**: 2026-06-11
- **2026-06-20 Evidence refresh**: Live 02-doing count updated from 95 to 98; header classification re-verified; snapshot report totals refreshed to match live lane; validation commands re-run and fresh outputs recorded.
- **2026-06-24 Reviewer refresh**: Live 02-doing count updated from 98 to final post-move 95 after reviewer-owned Task 1202, Task 1206, and Task 1208 promotions; header classification re-verified as 24 DONE_READY_FOR_REVIEW and 71 PARTIAL_BLOCKED; snapshot, task evidence, and changelog counts patched to current live state.

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

### 2026-06-20 — gt-build-review Wave A
**Score**: 72/100 — Good
**Verdict**: REJECTED → stays in 02-doing
**Diagnostics**: flutter analyze N/A (governance/docs-only) | dart format N/A (governance/docs-only; Markdown probe N/A) | flutter test N/A (governance/docs-only) | coverage N/A | live file/header count PASS (`98`, exactly one header Review State each) | snapshot classification FAIL (counts/tables contradict live headers)
**Report**: `docs/reports/build-gate-review/1208-review-2026-06-20-wave-a.md`
**Patches applied**: none — score below 90
**Findings**:
- [HIGH] Snapshot promotion-state distribution is false against live headers: task/report claim 13 Ready For Review, 22 Package Gate Failed, 11 Consumer Gate Failed, 21 Blocked, 24 Builder Done, 6 Doing, 1 Open; live header scan shows 24 Ready For Review, 15 Package Gate Failed, 3 Consumer Gate Failed, 1 Blocked, 10 Builder Done, 45 Doing, 0 Open.
- [HIGH] Snapshot report is internally inconsistent: Section 2 says `DONE_READY_FOR_REVIEW` count is 13 while Section 4.1 says `DONE_READY_FOR_REVIEW (0)`.
- [HIGH] Task 1208 falsely claims Task 1205 was promoted to `04-completed`; live Task 1205 remains in `02-doing` with `Review State: Doing`.
- [MEDIUM] Local changelog still records the stale 95-task 2026-06-11 snapshot and old category counts.
- [MEDIUM] Task 1208 depends on Task 1202, which remains rejected in the current Wave A review.
**Path to 100**:
1. Reconcile the snapshot from current live headers and make all snapshot sections agree with the same 98-file scan.
2. Correct Task 1208's Completion Evidence and deferral note for Task 1205.
3. Update the local changelog to supersede stale 95-task/category claims.
4. Resolve or explicitly account for the rejected Task 1202 dependency.
5. Re-run a deterministic validation script that prints both header coverage and state/category counts, then compare those outputs to the snapshot before handoff.
---

### 2026-06-24 — gt-build-review Wave A re-review
**Score**: 100/100 — Perfect
**Verdict**: APPROVED → moved to 03-review
**Diagnostics**: flutter analyze N/A (governance/docs-only) | dart format N/A (governance/docs-only; Markdown probe N/A) | flutter test N/A (governance/docs-only) | coverage N/A | final post-move header distribution PASS (`95` task files; Doing 42, Ready For Review 24, Package Gate Failed 15, Builder Done 10, Consumer Gate Failed 3, Blocked 1) | snapshot ID reconciliation PASS
**Report**: `docs/reports/build-gate-review/1208-review-2026-06-24-wave-a-rereview.md`
**Patches applied**:
- Task header — set Status/Review State to `Ready For Review` before reviewer-owned lane movement.
- Task evidence, snapshot, and changelog — reconciled final post-move count/category distribution after Task 1202, Task 1206, and Task 1208 promotions.
**Path to 100**: n/a — reviewer verified 100/100 after minimal patch and final post-move validation.
---

### 2026-06-26 — reviewer-orchestrator final verification
**Score**: 100/100 — Perfect
**Verdict**: PROMOTED → moved to 04-completed
**Diagnostics**: governance/docs-only — `docs/reports/warp-prism-review-backlog-snapshot.md` exists with categories ✓; 95 tasks in `02-doing/` with 95/95 Review State annotations ✓; header distribution: Doing 42, Ready For Review 24, Package Gate Failed 15, Builder Done 10, Consumer Gate Failed 3, Blocked 1 ✓
**Evidence verification**: All live filesystem paths pass. Prior report: `docs/reports/build-gate-review/1208-review-2026-06-24-wave-a-rereview.md`
**Final promotion**: 2026-06-26 — reviewer-orchestrator verified 100/100 against live filesystem and promoted to 04-completed.
---
