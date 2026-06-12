# Task 1202: Promotion State Model Definition

> **Status**: `[x]` Builder Done
> **Review State**: `Builder Done` — see `docs/governance/promotion-state-model.md`
> **Priority**: 🔴 P0
> **Type**: `governance`
> **Origin**: EPIC-12, stabilization wave, absence of formal promotion semantics.
> **Blocks**: 1203, 1206, all future task template updates
> **Depends on**: N/A (governance-only, no code dependency)

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1202` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

Formalize the promotion state model as a governance rule and update the task
template and task governance rules to reference it. Replace the ambiguous
`[x] Done` with explicit states that distinguish builder completion from
promotion readiness.

## Background Context

### What already exists

- `.agents/rules/promotion-state-model.md` has been created as part of the
  stabilization wave with states: Open, Doing (canonical; `In Progress` is a
  legacy alias), Builder Done, Package Gate Failed, Consumer Gate Failed,
  Ready For Review, Review Approved, Promoted, Superseded, Blocked.
- `.agents/rules/task-governance.md` has a "Promotion States" section with
  state table, gate requirements, lane move rules, and failure classification.
- `docs/tasks/000-template.md` now includes a `Review State` field that points to
  the promotion state model.

### What remains broken

- The task template now references the promotion state model.
- The task governance rules mention the gate matrix and promotion model.
- The existing backlog still contains ambiguous status markers and lane/state
  mismatches; Task 0001 is a pre-existing `03-review/`/`Builder Done` defect.

---

## Test Requirements

- The promotion state model rule is referenced by the task template.
- The task governance rules mention the gate matrix and promotion model.
- At least 3 existing tasks demonstrate the new status markers as examples.

---

## Exit Conditions

- [x] `docs/governance/promotion-state-model.md` exists with states, transitions,
  gate definitions, and lane mapping.
- [x] `docs/tasks/000-template.md` has `Review State` field referencing the
  promotion state model.
- [x] `.agents/rules/task-governance.md` has "Promotion States" section with
  state table, gate requirements, and lane move rules.
- [x] Promotion examples are reconciled with live lanes: Task 0001 is documented
  as a `03-review/`/`Builder Done` pre-existing defect, and Task 0010 replaces
  the missing `02-doing/0001-*` example; current `02-doing/` examples include
  0010, 0011, 0312, 0510, and the Task 1201 lane mismatch.
- [x] Local changelog entry added under `docs/changelog/`.
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: Read `.agents/rules/promotion-state-model.md`,
  `.agents/rules/task-governance.md`, `docs/tasks/000-template.md`.
- [x] Update `docs/tasks/000-template.md` to add a `Review State` field and
  reference the promotion state model.
- [x] Update `.agents/rules/task-governance.md` to add a section on promotion
  states and required gates.
- [x] Select 3-5 current `02-doing/` examples, including lane mismatch examples,
  and document Task 0001 as a separate `03-review/` pre-existing defect.
- [x] **Simplicity pass**: ensure changes are additive and do not break existing
  task formatting.
- [x] **Regression verification**: verify updated files parse correctly.

### Where

| File | Purpose |
| --- | --- |
| `.agents/rules/promotion-state-model.md` | Read — source state definitions |
| `.agents/rules/task-governance.md` | Modify — add promotion semantics section |
| `docs/tasks/000-template.md` | Modify — add Review State field |
| `docs/tasks/02-doing/` (selected tasks) | Modify — annotate with new status markers |

### How

1. Read the promotion state model, task governance, and task template.
2. Add a `Review State` field to the task template between `Status` and `Priority`.
3. Add a "Promotion States" section to task-governance.md referencing the model.
4. Select 3-5 current `02-doing/` examples, plus document Task 0001 as a
   `03-review/` pre-existing lane-state defect.
5. Verify all files are consistent.

### Why

Without formal promotion semantics, builders mark tasks `[x] Done` and move on.
Reviewers cannot tell which tasks need review, which are blocked by pre-existing
failures, and which are truly promoted. This task fixes the governance layer.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not mark this task complete without verifying the updated files parse
> correctly and the example tasks demonstrate the new markers.

> [!IMPORTANT]
> Preserve existing task content. Only add the new `Review State` field and
> annotations. Do not reformat or restructure existing task content.

---

## Validation Commands

```bash
# Verify files exist and are well-formed
cat .agents/rules/promotion-state-model.md
cat .agents/rules/task-governance.md
grep "Review State" docs/tasks/000-template.md
```

---

## Completion Evidence

- **Files created/modified**:
  - `docs/governance/promotion-state-model.md` — created (canonical governance doc)
  - `docs/tasks/000-template.md` — modified (added `Review State` field and canonical `Doing` wording)
  - `.agents/rules/task-governance.md` — modified (added Promotion States section and lane-state defect guidance)
  - `docs/tasks/02-doing/0010-warp-prism-foundation-audit-analyzer-baseline.md` — annotated `Review State: Blocked` as the replacement `02-doing/` example
  - `docs/tasks/02-doing/0011-warp-prism-bootstrap-main-router-shell.md` — already annotated `Review State: Builder Done`
  - `docs/tasks/02-doing/0312-warp-prism-read-only-mock-workspace-repository.md` — already annotated `Review State: Builder Done`
  - `docs/tasks/02-doing/0510-warp-prism-map-workspace-scaffold.md` — already annotated `Review State: Builder Done`
  - `docs/tasks/02-doing/1201-warp-prism-test-failure-baseline-inventory.md` — already annotated `Review State: Open` lane mismatch
- **Tests or validation commands**:
  - `test -f docs/governance/promotion-state-model.md` → `(no output)`
  - `rg "Review State" docs/tasks/000-template.md` → `> **Review State**: \`Open\` | \`Doing\` | \`Builder Done\` | \`Package Gate Failed\` | \`Consumer Gate Failed\` | \`Ready For Review\` | \`Review Approved\` | \`Promoted\` | \`Superseded\` | \`Blocked\` — see \`docs/governance/promotion-state-model.md\``
  - `rg "promotion-state-model\|Promotion States\|Gate Requirements\|Lane Move Rules" .agents/rules/task-governance.md` → `Reference selectors for audits: \`promotion-state-model|Promotion States|Gate Requirements|Lane Move Rules\`.`
  - `rg "Review State" docs/tasks/02-doing/*.md | wc -l` → `115`
  - `test ! -e docs/tasks/02-doing/0001-warp-prism-mock-workspace-contract-baseline.md` → `(no output)`
  - `test -f docs/tasks/03-review/0001-warp-prism-mock-workspace-contract-baseline.md && rg -n "Review State" docs/tasks/03-review/0001-warp-prism-mock-workspace-contract-baseline.md` → `4:> **Review State**: Builder Done — implementation evidence missing; needs verification`
- **2026-06-11 Path-to-100 remediation evidence**:
  - Corrected Task 1202's stale example/evidence language so Task 0001 is no longer described as a `02-doing/` example.
  - Aligned `Doing`/`In Progress` vocabulary in `.agents/rules/promotion-state-model.md`, `docs/governance/promotion-state-model.md`, `.agents/rules/task-governance.md`, and `docs/tasks/000-template.md`; each surface now documents `Doing` as canonical and `In Progress` as a legacy alias only.
  - Documented Task 0001 as a pre-existing `03-review/`/`Builder Done` governance defect in the Task 1202 evidence, governance model examples, and task-governance lane move rules.
  - Marked the Task 1202 regression-verification subtask `[x]` only after rerunning the validation commands above.
- **Local changelog entry**: `docs/changelog/2026-06-09-task-1202-promotion-state-model-definition.md`
- **Agent-wiki / docs institutionalization**: `docs/governance/promotion-state-model.md`
- **Executor**: builders (architect)
- **Completion date**: 2026-06-09
- **2026-06-11 Path-to-100 remediation date**: 2026-06-11

---
## Review Ledger

### 2026-06-11 — gt-build-review
**Score**: 82/100 — Good
**Verdict**: REJECTED → stays in 02-doing
**Diagnostics**: flutter analyze N/A | dart format N/A | flutter test N/A | governance checks PARTIAL (`docs/governance/promotion-state-model.md` exists; template/governance/changelog references pass; 5-in-02-doing example claim fails) | coverage N/A
**Report**: docs/reports/build-gate-review/1202-review.md
**Patches applied**: none — score below 90
**Findings**:
- Exit condition claiming 5 annotated tasks in `02-doing/` fails: no `docs/tasks/02-doing/0001-*.md` exists; Task 0001 is in `docs/tasks/03-review/0001-warp-prism-mock-workspace-contract-baseline.md` with `Review State: Builder Done`.
- Promotion vocabulary is inconsistent: `.agents/rules/promotion-state-model.md` uses `In Progress`, while `docs/governance/promotion-state-model.md`, `.agents/rules/task-governance.md`, and `docs/tasks/000-template.md` use `Doing`.
- Regression verification subtask remains unchecked despite Completion Evidence claiming validation commands passed.
- Changelog and Completion Evidence repeat the stale Task 0001-in-`02-doing` claim.
**Path to 100 remediation performed**:
1. Reconciled example-task evidence with actual lanes: Task 0001 is documented as a `03-review/`/`Builder Done` pre-existing defect, and Task 0010 replaces the nonexistent `02-doing/0001-*` example.
2. Aligned active-work vocabulary: `Doing` is canonical; `In Progress` is documented as a legacy alias across the promotion model, governance model, task governance, and task template.
3. Resolved Task 0001's lane/state inconsistency by documenting it as a separate pre-existing governance defect rather than claiming it is a `02-doing/` example.
4. Reran the governance validation commands and recorded fresh outputs in this Completion Evidence block.
5. Corrected Completion Evidence and changelog so they no longer claim nonexistent `02-doing/0001-*` evidence.
---

### 2026-06-11 — gt-build-review round 2
**Score**: 88/100 — Elite, below approval threshold
**Verdict**: REJECTED → stays in 02-doing
**Diagnostics**: root `flutter analyze lib/` FAIL/N/A (no root `lib/`) | root `dart format --set-exit-if-changed lib/ test/` FAIL/N/A (no root `lib/` or `test/`) | root `flutter test` FAIL/N/A (no root `test/`) | root `flutter test --coverage` FAIL/N/A (no root `test/`) | `dart run melos exec -- flutter analyze` FAIL (pre-existing workspace debt) | `dart run melos exec -- dart format --output=none --set-exit-if-changed .` FAIL (pre-existing formatting debt) | `dart run melos exec --dir-exists=test -- flutter test` FAIL (observatory pre-existing test failures) | governance validation PASS with stale-count discrepancy (`Review State` count now 116, task/changelog still record 115)
**Report**: docs/reports/build-gate-review/1202-review-round2.md
**Patches applied**: none — score below 90
**Findings**:
- [NEW/HIGH] Task 1201 live state evidence is stale: this task and changelog still describe Task 1201 as an `Open` lane mismatch, but live `docs/tasks/02-doing/1201-warp-prism-test-failure-baseline-inventory.md` is `Ready For Review`.
- [NEW/MEDIUM] Fresh `rg "Review State" docs/tasks/02-doing/*.md | wc -l` returned `116`, but Completion Evidence and changelog still record `115`.
- [EXTERNAL_BLOCKER/MEDIUM] Workspace diagnostics remain red due broad existing app/package analyzer, format, and observatory test failures unrelated to this governance-doc task.
**Path to 100**:
1. Update Task 1202, `docs/governance/promotion-state-model.md`, and the Task 1202 changelog so Task 1201's example matches its current live state, or replace it with an actually current `Open` lane mismatch example.
2. Rerun the governance validation chain and record the current Review State count (`116` as of this review unless it changes again).
3. Preserve the resolved Task 0001 correction: Task 0001 remains documented as a separate `03-review`/`Builder Done` pre-existing defect, not a `02-doing` example.
---
