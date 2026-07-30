---
name: gt-build-orchestrator-rfloop
description: |
  Builder-orchestrator review/fix loop for tasks already selected by a drain or
  wave plan. Dispatches reviewers, routes by score, dispatches fixers for
  rejected tasks, and repeats until reviewer-owned 100/100 promotion or a real
  blocker. This workflow does not perform drain planning.
triggers:
  - build review fix loop
  - rfloop
  - review fix loop
  - builder review loop
---

# Build Orchestrator RFLoop — Review/Fix Loop Only

> **Purpose**: Run the internal builder-lane review/fix loop after tasks have
> been selected by `.agents/workflows/gt-builder-orchestrator-drain.md` or an
> equivalent wave plan.
>
> **Non-goal**: This workflow does not triage all of `02-doing/`, build a global
> dependency plan, or decide the overall drain strategy. It receives a bounded
> set of tasks and drives them through official build-gate review cycles.

---

## Absolute Rules

1. **Use indexed agents only.**
   - Select subagents from `.agents/agents/INDEX.md`.
   - If `.agents/index-agents.md` exists, read it too.
   - Do not use generic/default task agents when a domain-specific agent exists.

2. **No external directories.**
   - NEVER create, read, or write files outside the repository root.
   - NEVER use `/tmp/`, `/temp/`, `~/.cache/`, or any system temporary directory.
   - If temporary files are needed, use `tmp/` inside the repository root.
   - Repeat this rule in every reviewer/fixer prompt.

3. **Reviewers own promotion.**
   - Reviewer subagents following `.agents/workflows/gt-build-review.md` are the
     only agents allowed to move tasks from `02-doing/` to `03-review/`.
   - Parent orchestrator does not move tasks as a substitute for reviewer-owned
     scoring/promotion.

4. **Fixers never promote.**
   - Builder/fixer subagents apply path-to-100 fixes only.
   - They must not move task files to `03-review/`.

5. **Score routing is mandatory.**
   - `S >= 90`: reviewer applies minimal path-to-100 patch, reruns diagnostics,
     rescored to 100, writes report/ledger, then moves to `03-review/`.
   - `S < 90`: reviewer does not patch; writes report/ledger with rejection
     reasons and path-to-100; task stays in `02-doing/`; fixer is dispatched.

6. **Re-review after every fix.**
   - A task fixed by a builder/fixer must be reviewed again by a reviewer
     subagent, even if the fixer claims all issues are resolved.

7. **No maximum rounds.**
   - Repeat review -> fix -> review until reviewer-owned score is 100/100 or a
     real blocker requires user/architecture guidance.

8. **No generated-surface rebuild by subagents.**
   - Reviewers/fixers do not rebuild tasklist/changelog or other centralized
     generated surfaces.
   - Parent orchestrator handles such updates after a wave, if required.

9. **Persist loop outcomes.**
   - Parent records rounds, blockers, and recurring failure patterns in
     `.agents/profiles/builders/` and `docs/reports/builders/harness-upgrades.md`.

---

## Inputs

The parent orchestrator provides a bounded task set, normally from:

```text
.agents/workflows/gt-builder-orchestrator-drain.md
```

Input should include:

- task ids and file paths under `docs/tasks/02-doing/`;
- relevant prior review reports;
- known external blockers/baselines;
- suggested reviewer agents;
- suggested fixer agents;
- file/domain grouping notes;
- any serialization constraints.

---

## Phase 0 — Preflight

Before dispatching reviewers:

1. Read:
   - `.agents/agents/INDEX.md`
   - `.agents/workflows/gt-build-review.md`
   - `.agents/rules/project-boundaries.md`
   - `.agents/rules/task-governance.md`
2. Confirm every task file still exists in `docs/tasks/02-doing/`.
3. Check for duplicates in other lanes:
   - if a task exists in both `02-doing/` and `03-review/`, pause and resolve
     lane inconsistency before dispatch.
4. Group tasks by:
   - domain;
   - files touched;
   - task type;
   - expected reviewer specialization.
5. Create/update loop note:
   - `.agents/profiles/builders/rfloop-YYYYMMDD.md`

---

## Phase 1 — Reviewer Batch Planning

### 1.1 Reviewer selection

Choose the most specific reviewer available:

| Task Surface | Preferred Reviewer |
| --- | --- |
| Flutter/Dart UI, Riverpod, widgets, tests | `gt-flutter-code-reviewer` |
| TypeScript/Node | `gt-ts-code-reviewer` |
| Go | `gt-go-reviewer` |
| Rust | `gt-rust-code-reviewer` |
| Python | `gt-python-reviewer` |
| Database/schema/query | `gt-database-reviewer` |
| Runtime/DevOps | `gt-devops-runtime-reviewer` |
| Security-sensitive | `gt-security-reviewer` plus language reviewer if needed |
| Docs/governance evidence | `gt-architect-reviewer`, `gt-documentation-accuracy-reviewer`, or `gt-evidence-refresher` only when the task is non-code and review is evidence-only |

### 1.2 Batch size

A reviewer may receive up to 5 tasks only when:

- tasks are related or small;
- no cross-task file mutation conflict exists;
- same reviewer specialization applies;
- review can be processed sequentially without ambiguity.

Use fewer tasks when:

- task is high risk;
- prior score < 70;
- task modifies global shell/router/provider/barrel/build config;
- task has unclear external blocker classification.

### 1.3 Sequential processing rule

Even when assigned multiple tasks, reviewer must process exactly one task at a
time:

```text
Task A: read -> verify -> score -> patch if S>=90 -> report -> ledger -> move or reject
Then Task B starts.
```

No mixed reports. No batch score. No moving multiple tasks without individual
reports and ledgers.

---

## Phase 2 — Reviewer Dispatch

Reviewer prompt template:

```text
You are reviewing these tasks sequentially: [task list].

Follow `.agents/workflows/gt-build-review.md` exactly.
Load skills `code-quality-harness` and `flutter-harness` when applicable.

CRITICAL: NEVER use /tmp, /temp, ~/.cache, or any directory outside the repo.
If temporary files are needed, use repo-local tmp/.

Process one task fully before starting the next.

Score routing:
- S >= 90: YOU apply minimal patches to reach 100, rerun diagnostics, write
  report to docs/reports/build-gate-review/, add Review Ledger, and move the
  task from docs/tasks/02-doing/ to docs/tasks/03-review/.
- S < 90: Do NOT patch. Write report and Review Ledger with file:line evidence
  and concrete path-to-100. Do NOT move the task.

Subagents do not rebuild tasklist/changelog.
Return for each task:
- final score
- verdict APPROVED/REJECTED
- report path
- lane result
- path-to-100 if rejected
```

---

## Phase 3 — Route Review Results

After reviewers return, parent records a table:

```markdown
## Review Round <N>
| Task | Reviewer | Score | Verdict | Report | Lane | Next Action |
| --- | --- | ---: | --- | --- | --- | --- |
```

Routing:

### Approved

If reviewer reports 100/100 and task is in `03-review/`:

1. Verify file exists in `03-review/`.
2. Verify no duplicate remains in `02-doing/`.
3. Verify task header says Ready For Review or equivalent.
4. Verify report exists.
5. Mark task complete for internal builder loop.

### Rejected

If score < 90 or task remains in `02-doing/`:

1. Read reviewer report.
2. Extract concrete path-to-100.
3. Assign fixer agent based on task domain.
4. Keep task in `02-doing/`.

### Ambiguous / Empty Reviewer Result

If reviewer returns empty, corrupt, or no report:

1. Do not infer approval.
2. Check live filesystem for report and lane movement.
3. If no valid report exists, re-dispatch reviewer with a smaller batch.
4. If repeated tool/model failures occur, record blocker in rfloop note and ask
   for user guidance before bypassing reviewer ownership.

---

## Phase 4 — Fixer Dispatch For Rejections

### 4.1 Fixer selection

Use the most specific builder/fixer:

| Surface | Preferred Fixer |
| --- | --- |
| Flutter/Dart | `gt-flutter-engineer` |
| TypeScript | `gt-ts-engineer` |
| Go | `gt-go-engineer` |
| Rust | `gt-rust-engineer` |
| Python | `gt-python-engineer` |
| Docs/governance | `gt-evidence-refresher`, `gt-archivist`, `gt-architect` |
| Runtime/DevOps | `gt-devops-engineer` |

### 4.2 Fixer batch size

A fixer may receive up to 5 tasks only when:

- tasks share the same domain/files;
- path-to-100 items are mechanical or related;
- no conflicting edits are expected;
- one specialist can safely handle all tasks.

Use one task per fixer for high-risk/code-heavy work.

### 4.3 Fixer prompt template

```text
You are fixing rejected task(s): [task list].

CRITICAL: NEVER use /tmp, /temp, ~/.cache, or any directory outside the repo.
If temporary files are needed, use repo-local tmp/.

Read the task file(s), prior review report(s), and every file you will edit
before modifying anything.

Apply only the path-to-100 fixes from the reviewer report. Do not move tasks to
03-review. Do not rebuild tasklist/changelog.

For each task, update Completion Evidence if needed and return:
- fixes applied
- files changed
- commands run
- remaining blockers
- notes saved path under .agents/profiles/builders/
```

---

## Phase 5 — Re-review

Every fixed task returns to Phase 1/2 for reviewer re-review.

Rules:

- Fixer claim is not proof.
- Parent visual inspection is not proof.
- Prior review cycles are not proof.
- Only a current reviewer-owned 100/100 with report/ledger/lane movement ends
  the loop.

---

## Phase 6 — Parent Wave Closeout

When the current bounded task set reaches 100/100 or real blockers:

1. Verify lane state:
   - approved tasks in `03-review/`;
   - rejected/blocker tasks remain in `02-doing/` with Review Ledger/path-to-100.
2. Verify no duplicates across lanes.
3. Verify reports exist for every review round.
4. Update `.agents/profiles/builders/rfloop-YYYYMMDD.md` with:
   - rounds;
   - scores;
   - fixers;
   - blockers;
   - final lane state.
5. Update `docs/reports/builders/harness-upgrades.md` with recurring patterns.
6. Return control to drain workflow or parent orchestrator.

---

## Completion Criteria

This rfloop is complete when, for the bounded task set:

- every task has reviewer-owned 100/100 and is in `03-review/`; or
- remaining tasks have documented real blockers requiring user/architecture
  guidance and remain in `02-doing/`.

Never move tasks directly to `04-completed/`.
