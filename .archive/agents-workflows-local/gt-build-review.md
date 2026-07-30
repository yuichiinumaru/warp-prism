---
name: gt-build-review
description: |
  Single-task build-gate review workflow. Reviews ONE task with zero tolerance,
  loads code-quality-harness then flutter-harness, uses the unified scoring rubric,
  and enforces strict score-based routing. Sequential processing only — one
  task fully completed before starting the next.
triggers:
  - build review
  - build gate
  - task review
  - flutter task review
  - dart task review
  - review single task
  - monorepo review
---

# Build-Gate Review — Single Task

> **Purpose**: Review exactly ONE implemented task against its acceptance contract
> with zero tolerance for errors, guesswork, laziness, phantom completion, or
> regression. Produce a complete report in `docs/reports/build-gate-review/`.

---

## Absolute Rules (Non-Negotiable)

1. **One task at a time.** If assigned multiple tasks, finish task N completely
   (including patches, report, and lane movement) before starting task N+1.
   No exceptions. No "I'll batch them." No "they're similar so I'll combine."
   One task. Fully done. Then the next.

2. **Use the skills.** Load `code-quality-harness` first. Then load `flutter-harness`.
   Actually execute their phases, sub-skills, and scoring rubric. Loading them
   into context and then ignoring them is a violation.

3. **Zero tolerance.** Do not excuse, overlook, rationalize, or soften findings.
   A bug is a bug. A race is a race. A swallowed error is a swallowed error.
   "It works in practice" is not a defense. "It's just a test helper" is not a
   defense. Score what exists, not what was intended.

4. **No guesswork.** If you cannot verify something, say so explicitly. Do not
   assume code works because it looks right. Do not assume tests pass because
   they passed last time. Run the commands. Read the output.

5. **No phantom completion.** A task is not "done" because its checkboxes say
   `[x]`. A task is not "done" because the implementation exists. A task is done
   when every exit condition is verified, every axiom passes, every diagnostic
   is green, and the score reflects reality.

6. **Reports are mandatory.** Every review produces a complete report in
   `docs/reports/build-gate-review/`. No exceptions. No "it was simple enough
   to skip the report." The report IS the evidence.

---

## Scoring System

Use the unified scoring rubric from `code-quality-harness`:

| Range | Level | Criteria |
|-------|-------|----------|
| 0-30  | **Critical** | Safety axiom violations, security vulnerabilities, memory unsafety |
| 31-50 | **Serious** | Logic races (TOCTOU), unchecked boundaries, silent error swallowing |
| 51-70 | **Debt** | Non-idiomatic patterns, missing type hints, suboptimal data structures |
| 71-85 | **Good** | Safe and performant, minor improvements possible |
| 86-99 | **Elite** | Everything audited, excellent coverage, documented proofs |
| 100   | **Perfect** | Structurally proven correct, all invariants type-encoded |

---

## Decision Rule (Score-Based Routing)

### If S >= 90 — APPROVED

The reviewer SHALL:
1. Identify every finding that prevents a score of 100.
2. Apply patches to fix those findings. The reviewer applies the patches — not
   a builder, not the orchestrator, not anyone else.
3. Re-run all diagnostics (`flutter analyze`, `dart format`, `flutter test`)
   to confirm patches did not introduce regressions.
4. Re-score. If the new score is 100, proceed. If still < 100, patch again.
   Repeat until 100 or until findings are genuinely non-patchable (document why).
5. Write the full report to `docs/reports/build-gate-review/`.
6. Add a Review Ledger to the task file with: score, diagnostics, patches
   applied, verdict, and link to the full report.
7. Move the task file from `docs/tasks/02-doing/` to `docs/tasks/03-review/`.

**There is no "already 93, no patch needed." If it's not 100, patch it.**

### If S < 90 — REJECTED

The reviewer SHALL:
1. Document every finding with file:line evidence.
2. Write the full report to `docs/reports/build-gate-review/`.
3. Add a footer Review Ledger to the task file with: score, exact rejection
   reasons, file:line evidence, and concrete path to 100.
4. Do NOT move the task file. It stays in `docs/tasks/02-doing/`.
5. Do NOT apply patches. When S < 90, the fixes are large enough to require
   a builder, not a reviewer.

---

## Workflow — Single Task Review

### Phase 0: Load Skills (MANDATORY — DO FIRST)

```
1. Load skill: code-quality-harness
2. Load skill: flutter-harness
3. Read the loaded skills' scoring rubric, axioms, and sub-skill index
4. Confirm you understand the axioms before proceeding
```

**Validation**: You have both skills loaded and can reference their axioms,
sub-skills, and scoring rubric. If you cannot, stop and load them again.

### Phase 1: Read the Task Contract

```
1. Read the task file from docs/tasks/02-doing/<task>.md
2. Extract:
   - Objective (what must be true when done)
   - Where section (which files, what actions)
   - Subtasks (checkbox list)
   - Exit conditions (acceptance criteria)
3. Treat these as the AUTHORITATIVE contract. Not the assessment report.
   Not your assumptions. The task file IS the contract.
```

**Validation**: You can state the task's objective, exit conditions, and which
files are involved.

### Phase 2: Locate and Read Implementation

```
1. Read every file listed in the Where section
2. Read neighboring files in the same packages
3. Read test files for those packages
4. Read any domain types, interfaces, or kernel contracts referenced
```

**Validation**: You have read all implementation and test files. You know what
code exists and what code does not.

### Phase 3: Run Diagnostics (ALL MANDATORY)

Run each command. Record the output. Do not skip any.

```bash
# 1. Static analysis
flutter analyze lib/

# 2. Dart format check
dart format --set-exit-if-changed lib/ test/

# 3. Unit + widget tests
flutter test

# 4. Coverage (if tests exist)
flutter test --coverage
# Then inspect: coverage/lcov.info or use genhtml
```

For Melos monorepo projects, run within the relevant package:
```bash
cd packages/<package> && flutter analyze lib/ && flutter test
# Or from root:
melos exec -- flutter analyze
melos exec -- flutter test
```

If any diagnostic FAILS, that is an automatic finding. Do not continue past a
failure — document it and factor it into the score.

**Validation**: You have exact output from all diagnostic commands. No
"PASS" without evidence. No "I ran it earlier" — run it NOW.

### Phase 4: Axiom Verification

Check each axiom with file:line evidence. Do not mark ✅ without citing the
specific code that satisfies the axiom.

| # | Axiom | What to Check |
|---|-------|---------------|
| 1 | **Widget Lifecycle** | Every `AnimationController`, `ScrollController`, `TextEditingController`, `StreamSubscription` is created in `initState` and disposed in `dispose`. No leaked controllers. No `setState` after `dispose`. |
| 2 | **Provider Scoping** | Riverpod providers are scoped correctly. No global state leaks between widgets. No `ref.watch` in `build` of non-consumer widgets. `ref.read` used only in callbacks, not in build. |
| 3 | **Const Constructors** | All widgets that can be `const` are `const`. `prefer_const_constructors` and `prefer_const_literals_to_create_immutables` are satisfied. No unnecessary rebuilds from missing const. |
| 4 | **Semantic Labels** | All interactive widgets (`GestureDetector`, `InkWell`, `IconButton`, `Checkbox`, etc.) have `Semantics` wrapper or `semanticLabel`/`semanticHint` properties. Screen reader traversal is complete. |
| 5 | **Type Safety** | No `dynamic` casts without null checks. No `as` casts without prior `is` check. No force-unwraps (`!`) on nullable types without documented invariant. All `switch` on enums are exhaustive. |

### Phase 5: Warp Prism Checks

| Check | What to Verify |
|-------|---------------|
| Read-only contract | No live API calls, no mutation endpoints, no write operations. Fixture-backed only. |
| DS*/Prism* boundary | Consumer apps (`apps/*`) use `Prism*` aliases. Internal `DS*` names stay inside `packages/warp_prism_ui/lib/src/`. No `DS*` in app-level imports. |
| Mock workspace fixtures | Data comes from `assets/mock_workspace/` or `assets/cybercore_fixtures/`. No hardcoded inline data that should be fixtures. |
| Melos package boundary | `packages/warp_prism_ui/` has zero imports from `apps/`. `apps/` only import via `package:warp_prism_ui/warp_prism_ui.dart`. No cross-app imports. |
| Operational state vocabulary | All state-dependent widgets use `DSOperationalState` (15 states). No ad-hoc boolean/string state for operational semantics. |
| Design token usage | All colors from `DSColors`, spacing from `DSSpacing`, radii from `DSRadii`, typography from `DSTypography`. No hardcoded hex values, no magic numbers for spacing. |
| Gallery coverage | Every new DS component has a gallery entry in `packages/warp_prism_ui/lib/src/gallery/`. |
| Test coverage | Every new widget has at least one widget test. Interactive widgets have interaction tests. State-dependent widgets test all operational states. |

### Phase 6: Exit Condition Verification

For each exit condition in the task file:
1. Find the code that satisfies it
2. Find the test that proves it
3. If neither exists, it is an unmet exit condition — a finding

Do not mark an exit condition as met because "the code looks like it should."
Find the proof or mark it unmet.

### Phase 7: Score Assignment

Using the unified rubric from Phase 0, assign a score S (0-100).

Factor in:
- Every Critical finding: -20 to -40 points
- Every High finding: -10 to -20 points
- Every Medium finding: -3 to -10 points
- Every Low finding: -1 to -3 points
- Unmet exit conditions: -15 to -30 points each
- Missing tests for claimed functionality: -10 to -20 points
- Diagnostic failures (flutter analyze, dart format, test failures): -15 to -25 points each

Be precise. "Around 70" is not a score. 68 is a score. 72 is a score.

### Phase 8: Report and Route

#### If S >= 90:

1. **Patch**: Apply every fix needed to reach 100. Do not skip any.
2. **Re-run diagnostics**: Confirm patches are clean (`flutter analyze`, `flutter test`, `dart format`).
3. **Re-score**: Confirm score is now 100.
4. **Write report**: `docs/reports/build-gate-review/<task-id>-review.md`
5. **Add Review Ledger** to task file.
6. **Move task**: `docs/tasks/02-doing/<task>.md` → `docs/tasks/03-review/<task>.md`

#### If S < 90:

1. **Do NOT patch**. Fixes are a builder's job.
2. **Write report**: `docs/reports/build-gate-review/<task-id>-review.md`
3. **Add footer Review Ledger** to task file with:
   - Score and level
   - Every finding with file:line evidence
   - Concrete path to 100 (what a builder must do)
4. **Do NOT move task**. It stays in `docs/tasks/02-doing/`.

---

## Report Format

Every report goes to `docs/reports/build-gate-review/<task-id>-review.md`:

```markdown
# Build-Gate Review: <task-id> — <task-title>

**Date**: <ISO-8601>
**Reviewer**: gt-build-review workflow
**Task file**: docs/tasks/02-doing/<task>.md (or 03-review/ if approved)

## Score: <S>/100 — <Level>

## Diagnostics

| Command | Result | Details |
|---------|--------|---------|
| flutter analyze | PASS/FAIL | ... |
| dart format | PASS/FAIL | ... |
| flutter test | PASS/FAIL | ... |
| coverage | X.X% | ... |

## Axiom Compliance

| # | Axiom | Status | Evidence |
|---|-------|--------|----------|
| 1 | Widget Lifecycle | ✅/❌ | file:line |
| 2 | Provider Scoping | ✅/❌ | file:line |
| 3 | Const Constructors | ✅/❌ | file:line |
| 4 | Semantic Labels | ✅/❌ | file:line |
| 5 | Type Safety | ✅/❌ | file:line |

## Warp Prism Checks

| Check | Status | Evidence |
|-------|--------|----------|
| Read-only contract | ✅/❌ | ... |
| DS*/Prism* boundary | ✅/❌ | ... |
| Mock workspace fixtures | ✅/❌ | ... |
| Melos package boundary | ✅/❌ | ... |
| Operational state vocabulary | ✅/❌ | ... |
| Design token usage | ✅/❌ | ... |
| Gallery coverage | ✅/❌ | ... |
| Test coverage | ✅/❌ | ... |

## Exit Conditions

| # | Condition | Met? | Evidence |
|---|-----------|------|----------|
| 1 | ... | ✅/❌ | ... |

## Findings

### Critical (if any)
- [CRITICAL] <finding> — `file:line`

### High (if any)
- [HIGH] <finding> — `file:line`

### Medium (if any)
- [MEDIUM] <finding> — `file:line`

### Low (if any)
- [LOW] <finding> — `file:line`

## Patches Applied (if S >= 90)

- `file:line` — what was changed and why

## Verdict

APPROVED → moved to docs/tasks/03-review/ | REJECTED → stays in docs/tasks/02-doing/

## Path to 100 (if S < 90)

1. ...
2. ...
```

---

## Review Ledger (in Task File)

Add this to the task file after review:

```markdown
---
## Review Ledger

### <date> — gt-build-review
**Score**: <S>/100 — <Level>
**Verdict**: APPROVED → 03-review | REJECTED → stays in 02-doing
**Diagnostics**: flutter analyze <PASS/FAIL> | dart format <PASS/FAIL> | flutter test <PASS/FAIL> | coverage <X.X%>
**Report**: docs/reports/build-gate-review/<task-id>-review.md
**Patches applied**: <list or "none">
**Path to 100**: <list or "n/a — already 100">
---
```

---

## Sequential Processing Rule

When assigned multiple tasks:

```
FOR each task in assigned order:
  1. Execute full workflow (Phases 0-8) for this task
  2. Confirm report written
  3. Confirm task moved (if approved) or annotated (if rejected)
  4. ONLY THEN start next task
```

Do NOT:
- Start task 2 before task 1 is fully complete
- "Batch" diagnostic commands across tasks
- Skip report writing to "save time"
- Move to the next task because "I'm almost done with this one"

---

## Checklist for Parent (Before Dispatching)

When dispatching a reviewer with this workflow:

- [ ] Specify exact task file path(s)
- [ ] If multiple tasks, specify the ORDER to process them
- [ ] Remind: one task fully done before starting the next
- [ ] Remind: S >= 90 means reviewer patches to 100 THEN moves
- [ ] Remind: S < 90 means reviewer does NOT patch, just annotates
- [ ] Remind: report is mandatory for every task
