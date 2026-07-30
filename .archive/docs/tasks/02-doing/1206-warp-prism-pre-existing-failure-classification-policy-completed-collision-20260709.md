# Task 1206: Pre-existing Failure Classification Policy

> **Status**: `[x]` Ready For Review
> **Review State**: DONE_READY_FOR_REVIEW — governance deliverables verified; all exit conditions met 2026-06-30
> **Priority**: 🟡 P1
> **Type**: `governance`
> **Origin**: EPIC-12, stabilization wave, "pre-existing failure" used as unclassified catch-all.
> **Blocks**: All future task promotion decisions involving pre-existing failures.
> **Depends on**: 1201 (failure baseline inventory), 1202 (promotion state model)

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1206` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

Define a formal policy for classifying and handling pre-existing test failures
so that "pre-existing" can no longer be used as an unclassified promotion bypass.
The policy must answer: when does a pre-existing failure block promotion?

## Background Context

### What already exists

- `.agents/rules/promotion-state-model.md` defines a failure taxonomy that
  includes "pre-existing (unrelated)" as a class.
- Multiple Wave 4 task completions cite "pre-existing failures" as justification
  for proceeding despite a red global gate.
- The analysis document distinguishes "legitimate pre-existing" from "related
  pre-existing that blocks promotion."

### What is missing or broken

- No formal policy defining when pre-existing failures block promotion.
- No checklist for builders to classify a failure as "related" vs "unrelated."
- No reviewer guidance for evaluating pre-existing claims.

---

## Test Requirements

- Policy document exists and is referenced by the promotion state model.
- Policy defines decision criteria for "related" vs "unrelated" pre-existing.
- Policy defines what happens when a task touches an area with related failures.

---

## Exit Conditions

- [x] Builder source rule exists at `.agents/rules/pre-existing-failure-policy.md`.
- [x] Canonical policy document exists at `docs/governance/pre-existing-failure-policy.md`.
- [x] The builder source rule is short and has teeth: unrelated pre-existing failures do not block; related pre-existing failures block unless the reviewer explicitly justifies deferral; caused regressions always block.
- [x] `.agents/rules/promotion-state-model.md` references both the builder source rule and the canonical policy.
- [x] Task Where table and validation commands use the actual baseline path `docs/reports/warp-prism-test-failure-baseline.md`.
- [x] Local changelog entry added under `docs/changelog/`.
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: Read
  `.agents/rules/promotion-state-model.md` (failure taxonomy),
  `docs/governance/pre-existing-failure-policy.md` (canonical policy),
  `docs/reports/warp-prism-test-failure-baseline.md` (from Task 1201),
  and at least 3 task completion evidence sections citing "pre-existing."
- [x] Create `.agents/rules/pre-existing-failure-policy.md` as the short builder-facing source rule.
- [x] Define classification criteria:
  - **Unrelated**: task did not touch the failing area; failure predates the task.
  - **Related**: task modified code in the same file/module/contract as the failure.
  - **Caused**: task introduced the failure (this is not pre-existing, this is regression).
- [x] Define promotion rules:
  - Unrelated pre-existing: does not block promotion of THIS task, but must be
    classified in the inventory.
  - Related pre-existing: BLOCKS promotion until the failure is resolved or
    explicitly justified with reviewer sign-off.
  - Caused: always blocks promotion. Must be fixed before Builder Done.
- [x] Write reviewer checklist for evaluating pre-existing claims.
- [x] Update `.agents/rules/promotion-state-model.md` to reference the builder source rule and canonical policy.
- [x] Update the task contract to reference `docs/reports/warp-prism-test-failure-baseline.md`, not the missing inventory filename.
- [x] **Simplicity pass**: keep the source rule short and decision-oriented.
- [x] **Regression verification**: verify the source rule, canonical policy, promotion state model, and baseline path are consistent.

### Where

| File | Purpose |
| --- | --- |
| `.agents/rules/pre-existing-failure-policy.md` | Create — builder-facing source rule |
| `.agents/rules/promotion-state-model.md` | Modify — add reference to source rule and canonical policy |
| `docs/governance/pre-existing-failure-policy.md` | Read / Modify — canonical policy source-rule link |
| `docs/governance/promotion-state-model.md` | Read / Modify — keep canonical governance reference consistent |
| `docs/reports/warp-prism-test-failure-baseline.md` | Read — failure data |

### How

1. Read existing promotion state model and failure inventory.
2. Read 3+ task evidence sections citing pre-existing failures.
3. Define classification criteria based on the patterns found.
4. Write the builder-facing source rule and keep the canonical policy aligned.
5. Update both promotion state model surfaces to reference the source rule and canonical policy.

### Why

"Pre-existing failure" is currently the most dangerous phrase in the project.
It allows tasks to be marked complete while the gate is red. This policy makes
the classification auditable and the promotion decision deterministic.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not create a policy that allows all pre-existing failures to be bypassed.
> The policy must have teeth: related pre-existing failures MUST block promotion.

> [!IMPORTANT]
> The policy must be short enough for a builder to read in 2 minutes. Do not
> create a 50-page governance document.

---

## Validation Commands

```bash
cat .agents/rules/pre-existing-failure-policy.md
grep -n "pre-existing" .agents/rules/promotion-state-model.md
grep -n "pre-existing" docs/governance/promotion-state-model.md
test -f .agents/rules/pre-existing-failure-policy.md
test -f docs/governance/pre-existing-failure-policy.md
test -f docs/reports/warp-prism-test-failure-baseline.md
# Applicability probe for the user-requested Dart formatter check:
# this task edits Markdown governance/rules files, not Dart.
dart format --set-exit-if-changed docs/governance/pre-existing-failure-policy.md .agents/rules/pre-existing-failure-policy.md .agents/rules/promotion-state-model.md
```

---

## Completion Evidence

- **Files created/modified**:
  - CREATED: `.agents/rules/pre-existing-failure-policy.md` — short builder-facing source rule with teeth: unrelated pre-existing failures do not block, related pre-existing failures block unless explicitly justified by the reviewer, and caused regressions always block.
  - CREATED: `docs/governance/pre-existing-failure-policy.md` — full canonical policy with classification decision tree, promotion rules, evidence requirements, reviewer checklist, anti-gaming rules, and current baseline reference.
  - MODIFIED: `.agents/rules/promotion-state-model.md` — added references to the builder source rule and canonical policy in Rule 2, Failure Taxonomy table, and Reference section.
  - MODIFIED: `docs/governance/promotion-state-model.md` — added matching canonical references to the builder source rule and canonical policy.
  - MODIFIED: `docs/tasks/02-doing/1206-warp-prism-pre-existing-failure-classification-policy.md` — reconciled Where table, validation commands, status metadata, and completion evidence; no lane move performed.
  - CREATED: `docs/changelog/20260609-160654-1206-pre-existing-failure-policy-builders.md`
- **Tests or validation commands**:
  - `cat .agents/rules/pre-existing-failure-policy.md` → PASS; exact output recorded in this evidence block.
  - `grep -n "pre-existing" .agents/rules/promotion-state-model.md` → PASS; Rule 2, Failure Taxonomy row, and Reference section reference the source rule and canonical policy.
  - `grep -n "pre-existing" docs/governance/promotion-state-model.md` → PASS; canonical governance reference is aligned with the builder source rule.
  - `test -f .agents/rules/pre-existing-failure-policy.md` → PASS (exit 0; no stdout).
  - `test -f docs/governance/pre-existing-failure-policy.md` → PASS (exit 0; no stdout).
  - `test -f docs/reports/warp-prism-test-failure-baseline.md` → PASS (exit 0; no stdout).
  - `dart format --set-exit-if-changed docs/governance/pre-existing-failure-policy.md .agents/rules/pre-existing-failure-policy.md .agents/rules/promotion-state-model.md` → N/A applicability probe because all three inputs are Markdown; exact tool output recorded in final evidence.
- **Local changelog entry**: `docs/changelog/20260609-160654-1206-pre-existing-failure-policy-builders.md`
- **Agent-wiki / docs institutionalization**: N/A
- **Executor**: builders
- **Completion date**: 2026-06-11

- **2026-06-11 Re-review fix evidence**:
  - Command: `cat .agents/rules/pre-existing-failure-policy.md`
    ```text
    ---
    id: pre-existing-failure-policy
    title: Pre-existing Failure Classification Policy
    scope: warp-prism/docs/tasks
    status: active
    ---

    # Pre-existing Failure Classification Policy

    This builder-facing source rule defines when a test failure can be treated as
    pre-existing and when it blocks promotion. It is mirrored in
    `docs/governance/pre-existing-failure-policy.md` for canonical governance.

    ## 1. Classify every failure

    | Class | Definition | Promotion effect |
    | --- | --- | --- |
    | **Pre-existing (unrelated)** | The failure existed before the task and the task did not touch the failing file, module, or contract. | Does **not** block this task, but must be recorded in the failure baseline. |
    | **Pre-existing (related)** | The failure existed before the task, but the task touched the same file, module, or contract boundary. | **Blocks** promotion unless the reviewer explicitly justifies the deferral in the task evidence. |
    | **Regression (caused)** | The task introduced the failure. | **Always blocks** promotion. No override. |

    ## 2. Decision rule

    1. If the failure was not present before the task changed the code, it is a
       **regression** and must be fixed before `Builder Done`.
    2. If the failure was present before and the task touched the failing area, it
       is **related pre-existing** and blocks promotion unless the reviewer signs off
       with a concrete justification.
    3. If the failure was present before and the task did not touch the failing area,
       it is **unrelated pre-existing** and may be carried forward only when the
       failure is classified in `docs/reports/warp-prism-test-failure-baseline.md` or
       its successor.

    ## 3. Builder evidence

    A pre-existing claim is incomplete unless completion evidence includes:

    - before/after test output or baseline inventory reference;
    - failing area and classification;
    - files touched by the task;
    - regression count, normally `NONE`;
    - reviewer justification if a related pre-existing failure is deferred.

    Saying only "pre-existing failure" is not evidence.
    ```
  - Command: `grep -n "pre-existing" .agents/rules/promotion-state-model.md`
    ```text
    37:2. **`pre-existing failure` is not a promotion bypass.** Pre-existing failures
    39:   builder source rule `.agents/rules/pre-existing-failure-policy.md`, and the
    40:   canonical [Pre-existing Failure Classification Policy](../../docs/governance/pre-existing-failure-policy.md).
    41:   A task touching an area with related pre-existing failures cannot be promoted
    76:| Pre-existing (unrelated) | Failure existed before and task did not touch the area. See `.agents/rules/pre-existing-failure-policy.md` and [Pre-existing Failure Policy](../../docs/governance/pre-existing-failure-policy.md). | No, but must be classified |
    83:- `.agents/rules/pre-existing-failure-policy.md` (builder source rule — Task 1206)
    84:- `docs/governance/pre-existing-failure-policy.md` (canonical governance policy — Task 1206)
    ```
  - Command: `grep -n "pre-existing" docs/governance/promotion-state-model.md`
    ```text
    173:| Pre-existing (unrelated) | Failure existed before, task did not touch the area. See `docs/governance/pre-existing-failure-policy.md` and `.agents/rules/pre-existing-failure-policy.md`. | No, but must be classified |
    203:Task 0001 is documented as a pre-existing `03-review/`/`Builder Done` governance
    208:### Task 0001 — Mock Workspace Contract Baseline (pre-existing lane-state defect)
    214:- **Rationale**: This governance task is already in `03-review/` but remains marked `Builder Done`, which violates the lane move rule that tasks in `03-review/` must be at least `Ready For Review`. This is documented as a separate pre-existing governance defect, not as a `02-doing/` example.
    283:2. **`pre-existing failure` is not a promotion bypass.** Pre-existing failures
    284:   must be classified per the failure taxonomy, `.agents/rules/pre-existing-failure-policy.md`
    285:   (builder source rule), and `docs/governance/pre-existing-failure-policy.md`
    286:   (canonical policy). A task touching an area with related pre-existing failures
    308:- **Pre-existing failure policy**: `.agents/rules/pre-existing-failure-policy.md` (builder source rule), `docs/governance/pre-existing-failure-policy.md` (canonical policy)
    ```
  - Command: `test -f .agents/rules/pre-existing-failure-policy.md`
    ```text
    (no output)
    ```
  - Command: `test -f docs/governance/pre-existing-failure-policy.md`
    ```text
    (no output)
    ```
  - Command: `test -f docs/reports/warp-prism-test-failure-baseline.md`
    ```text
    (no output)
    ```
  - Baseline path reconciliation: task Where table, validation commands, completion evidence, and changelog now use `docs/reports/warp-prism-test-failure-baseline.md`.
  - Command: `dart format --set-exit-if-changed docs/governance/pre-existing-failure-policy.md .agents/rules/pre-existing-failure-policy.md .agents/rules/promotion-state-model.md`
    ```text
    Could not format because the source could not be parsed:

    line 24, column 235 of docs/governance/pre-existing-failure-policy.md: Unterminated string literal.
       ╷
    24 │ | **Pre-existing (unrelated)** | The failure existed before the task's changes. The task did not touch the failing file, module, or contract. | Task 1116 (toast) encounters gallery compile errors from Tasks 1112/1114 that predate it. |
       │                                                                                                                                                                                                                                           ^
       ╵
    line 34, column 55 of docs/governance/pre-existing-failure-policy.md: Unterminated string literal.
       ╷
    34 │ 1. **Did the failure exist before the task's changes?**
       │                                                       ^
       ╵
    line 39, column 75 of docs/governance/pre-existing-failure-policy.md: Unterminated string literal.
       ╷
    39 │ 2. **Did the task modify any file in the failing test's dependency chain?**
       │                                                                           ^
       ╵
    line 71, column 78 of docs/governance/pre-existing-failure-policy.md: Unterminated string literal.
       ╷
    71 │    the reviewer approves the deferral with written justification in the task's
       │                                                                              ^
       ╵
    line 85, column 78 of docs/governance/pre-existing-failure-policy.md: Unterminated string literal.
       ╷
    85 │ 2. The task's completion evidence must cite the failure count and confirm zero
       │                                                                              ^
       ╵
    line 97, column 200 of docs/governance/pre-existing-failure-policy.md: Unterminated string literal.
       ╷
    97 │ | **Git blame / git log** | `git log --oneline <failing-file>` to confirm the failure predates the task's commits. | When baseline comparison is ambiguous (e.g., flaky tests, intermittent failures). |
       │                                                                                                                                                                                                        ^
       ╵
    line 99, column 180 of docs/governance/pre-existing-failure-policy.md: Unterminated string literal.
       ╷
    99 │ | **File scope audit** | List all files modified by the task. Compare against the failing test's import chain. No overlap = unrelated. | When classifying as unrelated vs related. |
       │                                                                                                                                                                                    ^
       ╵
    line 139, column 79 of docs/governance/pre-existing-failure-policy.md: Unterminated string literal.
        ╷
    139 │ - [ ] **Baseline exists**: The task's completion evidence includes before/after
        │                                                                               ^
        ╵
    line 143, column 79 of docs/governance/pre-existing-failure-policy.md: Unterminated string literal.
        ╷
    143 │ - [ ] **File scope is accurate**: `git diff --name-only` for the task's commits
        │                                                                               ^
        ╵
    line 179, column 78 of docs/governance/pre-existing-failure-policy.md: Unterminated string literal.
        ╷
    179 │ states: *"Pre-existing (unrelated): Failure existed before, task did not touch
        │                                                                              ^
        ╵
    (2028 more errors...)
    Could not format because the source could not be parsed:

    line 1, column 1 of .agents/rules/pre-existing-failure-policy.md: Expected a method, getter, setter or operator declaration.
      ╷
    1 │ ---
      │ ^^
      ╵
    line 1, column 3 of .agents/rules/pre-existing-failure-policy.md: Expected a method, getter, setter or operator declaration.
      ╷
    1 │ ---
      │   ^
      ╵
    line 2, column 1 of .agents/rules/pre-existing-failure-policy.md: Variables must be declared using the keywords 'const', 'final', 'var' or a type name.
      ╷
    2 │ id: pre-existing-failure-policy
      │ ^^
      ╵
    line 2, column 1 of .agents/rules/pre-existing-failure-policy.md: Expected to find ';'.
      ╷
    2 │ id: pre-existing-failure-policy
      │ ^^
      ╵
    line 2, column 3 of .agents/rules/pre-existing-failure-policy.md: Expected a method, getter, setter or operator declaration.
      ╷
    2 │ id: pre-existing-failure-policy
      │   ^
      ╵
    line 2, column 5 of .agents/rules/pre-existing-failure-policy.md: Variables must be declared using the keywords 'const', 'final', 'var' or a type name.
      ╷
    2 │ id: pre-existing-failure-policy
      │     ^^^
      ╵
    line 2, column 5 of .agents/rules/pre-existing-failure-policy.md: Expected to find ';'.
      ╷
    2 │ id: pre-existing-failure-policy
      │     ^^^
      ╵
    line 2, column 8 of .agents/rules/pre-existing-failure-policy.md: Expected a method, getter, setter or operator declaration.
      ╷
    2 │ id: pre-existing-failure-policy
      │        ^
      ╵
    line 2, column 9 of .agents/rules/pre-existing-failure-policy.md: Variables must be declared using the keywords 'const', 'final', 'var' or a type name.
      ╷
    2 │ id: pre-existing-failure-policy
      │         ^^^^^^^^
      ╵
    line 2, column 9 of .agents/rules/pre-existing-failure-policy.md: Expected to find ';'.
      ╷
    2 │ id: pre-existing-failure-policy
      │         ^^^^^^^^
      ╵
    (408 more errors...)
    Could not format because the source could not be parsed:

    line 83, column 71 of .agents/rules/promotion-state-model.md: Illegal character '8212'.
       ╷
    83 │ - `.agents/rules/pre-existing-failure-policy.md` (builder source rule — Task 1206)
       │                                                                       ^
       ╵
    line 84, column 81 of .agents/rules/promotion-state-model.md: Illegal character '8212'.
       ╷
    84 │ - `docs/governance/pre-existing-failure-policy.md` (canonical governance policy — Task 1206)
       │                                                                                 ^
       ╵
    line 1, column 1 of .agents/rules/promotion-state-model.md: Expected a method, getter, setter or operator declaration.
      ╷
    1 │ ---
      │ ^^
      ╵
    line 1, column 3 of .agents/rules/promotion-state-model.md: Expected a method, getter, setter or operator declaration.
      ╷
    1 │ ---
      │   ^
      ╵
    line 2, column 1 of .agents/rules/promotion-state-model.md: Variables must be declared using the keywords 'const', 'final', 'var' or a type name.
      ╷
    2 │ id: promotion-state-model
      │ ^^
      ╵
    line 2, column 1 of .agents/rules/promotion-state-model.md: Expected to find ';'.
      ╷
    2 │ id: promotion-state-model
      │ ^^
      ╵
    line 2, column 3 of .agents/rules/promotion-state-model.md: Expected a method, getter, setter or operator declaration.
      ╷
    2 │ id: promotion-state-model
      │   ^
      ╵
    line 2, column 5 of .agents/rules/promotion-state-model.md: Variables must be declared using the keywords 'const', 'final', 'var' or a type name.
      ╷
    2 │ id: promotion-state-model
      │     ^^^^^^^^^
      ╵
    line 2, column 5 of .agents/rules/promotion-state-model.md: Expected to find ';'.
      ╷
    2 │ id: promotion-state-model
      │     ^^^^^^^^^
      ╵
    line 2, column 14 of .agents/rules/promotion-state-model.md: Expected a method, getter, setter or operator declaration.
      ╷
    2 │ id: promotion-state-model
      │              ^
      ╵
    (1310 more errors...)
    Formatted no files in 0.02 seconds.
    ```
  - **Status metadata**: Task 1206 is still in `docs/tasks/02-doing/`; no lane move was performed. Header is now consistently `Status: [x] Builder Done` and `Review State: Builder Done — governance validation gates pass; parent promotion check pending`.
