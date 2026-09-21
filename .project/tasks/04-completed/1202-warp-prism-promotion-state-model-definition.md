# Task 1202: Promotion State Model Definition

> **Review State**: `Promoted` — final reviewer-orchestrator verification 2026-06-26; all evidence paths verified against live filesystem; promoted to 04-completed
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
- [x] Promotion examples are reconciled with live lanes: Task 0001 is in
  `02-doing/` with `Review State: Builder Done` (not a `03-review/` defect);
  Task 0010 and 0011 are `Ready For Review` in `02-doing/`; Task 0312 is
  `Consumer Gate Failed` in `02-doing/`; Task 0510 is `Doing` in `02-doing/`;
  Task 1101 is `Promoted` in `04-completed/`; Task 1201 is `Promoted` in
  `04-completed/` (not a `03-review/` example); Task 1205 is `Doing` in
  `02-doing/` (not `Promoted` in `04-completed/`).
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
  - `docs/tasks/02-doing/0010-warp-prism-foundation-audit-analyzer-baseline.md` — live header shows `Review State: Ready For Review`
  - `docs/tasks/02-doing/0011-warp-prism-bootstrap-main-router-shell.md` — live header shows `Review State: Ready For Review`
  - `docs/tasks/02-doing/0312-warp-prism-read-only-mock-workspace-repository.md` — live header shows `Review State: Consumer Gate Failed`
  - `docs/tasks/02-doing/0510-warp-prism-map-workspace-scaffold.md` — live header shows `Review State: Doing`
  - `docs/tasks/04-completed/1101-warp-prism-charter-and-naming-convergence.md` — live header shows `Review State: Promoted`
  - `docs/tasks/04-completed/1201-warp-prism-test-failure-baseline-inventory.md` — live header shows `Review State: Promoted`
  - `docs/tasks/02-doing/1205-warp-prism-boundary-test-harness.md` — live header shows `Review State: Doing`
- **Tests or validation commands**:
  - `test -f docs/governance/promotion-state-model.md` → `(no output)`
  - `rg "Review State" docs/tasks/000-template.md` → `> **Review State**: \`Open\` | \`Doing\` | \`Builder Done\` | \`Package Gate Failed\` | \`Consumer Gate Failed\` | \`Ready For Review\` | \`Review Approved\` | \`Promoted\` | \`Superseded\` | \`Blocked\` — see \`docs/governance/promotion-state-model.md\``
  - `rg "promotion-state-model\|Promotion States\|Gate Requirements\|Lane Move Rules" .agents/rules/task-governance.md` → `Reference selectors for audits: \`promotion-state-model|Promotion States|Gate Requirements|Lane Move Rules\`.`
  - `rg "^> \*\*Review State\*\*" docs/tasks/02-doing/*.md | wc -l` → `98` (header-only count; avoids body-reference drift; live count at 2026-06-20)
  - `test -f docs/tasks/02-doing/0001-warp-prism-mock-workspace-contract-baseline.md && rg -n "Review State" docs/tasks/02-doing/0001-warp-prism-mock-workspace-contract-baseline.md` → `4:> **Review State**: Builder Done — implementation evidence missing; needs verification`
  - `test -f docs/tasks/02-doing/0010-warp-prism-foundation-audit-analyzer-baseline.md && rg -n "Review State" docs/tasks/02-doing/0010-warp-prism-foundation-audit-analyzer-baseline.md` → `4:> **Review State**: \`Ready For Review\``
  - `test -f docs/tasks/02-doing/0011-warp-prism-bootstrap-main-router-shell.md && rg -n "Review State" docs/tasks/02-doing/0011-warp-prism-bootstrap-main-router-shell.md` → `4:> **Review State**: \`Ready For Review\``
  - `test -f docs/tasks/02-doing/0312-warp-prism-read-only-mock-workspace-repository.md && rg -n "Review State" docs/tasks/02-doing/0312-warp-prism-read-only-mock-workspace-repository.md` → `4:> **Review State**: Consumer Gate Failed`
  - `test -f docs/tasks/02-doing/0510-warp-prism-map-workspace-scaffold.md && rg -n "Review State" docs/tasks/02-doing/0510-warp-prism-map-workspace-scaffold.md` → `4:> **Review State**: Doing`
  - `test -f docs/tasks/04-completed/1101-warp-prism-charter-and-naming-convergence.md && rg -n "Review State" docs/tasks/04-completed/1101-warp-prism-charter-and-naming-convergence.md` → `4:> **Review State**: Promoted`
  - `test -f docs/tasks/04-completed/1201-warp-prism-test-failure-baseline-inventory.md && rg -n "Review State" docs/tasks/04-completed/1201-warp-prism-test-failure-baseline-inventory.md` → `4:> **Review State**: \`Promoted\` — inventory-only governance deliverable accepted and promoted as a dated 2026-06-11 baseline`
  - `test -f docs/tasks/02-doing/1205-warp-prism-boundary-test-harness.md && rg -n "Review State" docs/tasks/02-doing/1205-warp-prism-boundary-test-harness.md` → `4:> **Review State**: \`Doing\` — returned from 2026-06-17 independent review; live boundary harness and Melos boundary entrypoint are not reproducibly green.`
- **2026-06-11 Path-to-100 remediation evidence**:
  - Corrected Task 1202's stale example/evidence language so Task 0001 is no longer described as a `02-doing/` example.
  - Aligned `Doing`/`In Progress` vocabulary in `.agents/rules/promotion-state-model.md`, `docs/governance/promotion-state-model.md`, `.agents/rules/task-governance.md`, and `docs/tasks/000-template.md`; each surface now documents `Doing` as canonical and `In Progress` as a legacy alias only.
  - Documented Task 0001 as a pre-existing `03-review/`/`Builder Done` governance defect in the Task 1202 evidence, governance model examples, and task-governance lane move rules.
  - Refreshed Task 1201 evidence from stale `02-doing/` / `Open` lane-mismatch wording to current `03-review/` / `Ready For Review` wording, replaced the current `Open` lane-mismatch example with Task 1101, and documented Task 1205 as another current `03-review/` / `Ready For Review` example.
  - Reran the governance validation chain and recorded a stable header-only `Review State` count as `95`, replacing the unstable body-reference count.
  - External workspace diagnostics remain red due pre-existing Flutter/Melos issues unrelated to this governance-doc task; the governance validation chain itself passes.
  - Marked the Task 1202 regression-verification subtask `[x]` only after rerunning the validation commands above.
- **2026-06-20 Path-to-100 evidence refresh** (this wave):
  - Refreshed promotion examples against live filesystem: 02-doing count is now 98; Task 0001 is `Builder Done` in 02-doing (not a 03-review defect); Task 0312 is `Consumer Gate Failed` in 02-doing; Task 0510 is `Doing` in 02-doing; Task 0010 and 0011 are `Ready For Review` in 02-doing; Task 1101 is `Promoted` in 04-completed; Task 1201 is `Promoted` in 04-completed (not a 03-review example); Task 1205 is `Doing` in 02-doing (not Promoted in 04-completed).
  - Updated Exit Condition "Promotion examples are reconciled with live lanes" to match current live state.
  - Updated Completion Evidence file list and validation commands with live header states and current counts.
  - Updated header-only Review State count from 95 to 98.
  - Corrected Task 0001 from being documented as a `03-review/`/`Builder Done` pre-existing defect to being correctly identified as a `02-doing/`/`Builder Done` task.
  - Reran validation commands and recorded fresh outputs below.
- **Validation commands re-run 2026-06-20**:
  - `rg "^> \*\*Review State\*\*" docs/tasks/02-doing/*.md | wc -l` → `98`
  - `test -f docs/tasks/02-doing/0001-warp-prism-mock-workspace-contract-baseline.md && rg -n "Review State" docs/tasks/02-doing/0001-warp-prism-mock-workspace-contract-baseline.md` → `4:> **Review State**: Builder Done — implementation evidence missing; needs verification`
  - `test -f docs/tasks/02-doing/0010-warp-prism-foundation-audit-analyzer-baseline.md && rg -n "Review State" docs/tasks/02-doing/0010-warp-prism-foundation-audit-analyzer-baseline.md` → `4:> **Review State**: \`Ready For Review\``
  - `test -f docs/tasks/02-doing/0011-warp-prism-bootstrap-main-router-shell.md && rg -n "Review State" docs/tasks/02-doing/0011-warp-prism-bootstrap-main-router-shell.md` → `4:> **Review State**: \`Ready For Review\``
  - `test -f docs/tasks/02-doing/0312-warp-prism-read-only-mock-workspace-repository.md && rg -n "Review State" docs/tasks/02-doing/0312-warp-prism-read-only-mock-workspace-repository.md` → `4:> **Review State**: Consumer Gate Failed`
  - `test -f docs/tasks/02-doing/0510-warp-prism-map-workspace-scaffold.md && rg -n "Review State" docs/tasks/02-doing/0510-warp-prism-map-workspace-scaffold.md` → `4:> **Review State**: Doing`
  - `test -f docs/tasks/04-completed/1101-warp-prism-charter-and-naming-convergence.md && rg -n "Review State" docs/tasks/04-completed/1101-warp-prism-charter-and-naming-convergence.md` → `4:> **Review State**: Promoted`
  - `test -f docs/tasks/04-completed/1201-warp-prism-test-failure-baseline-inventory.md && rg -n "Review State" docs/tasks/04-completed/1201-warp-prism-test-failure-baseline-inventory.md` → `4:> **Review State**: \`Promoted\` — inventory-only governance deliverable accepted and promoted as a dated 2026-06-11 baseline`
  - `test -f docs/tasks/02-doing/1205-warp-prism-boundary-test-harness.md && rg -n "Review State" docs/tasks/02-doing/1205-warp-prism-boundary-test-harness.md` → `4:> **Review State**: \`Doing\` — returned from 2026-06-17 independent review; live boundary harness and Melos boundary entrypoint are not reproducibly green.`
- **Local changelog entry**: `docs/changelog/2026-06-09-task-1202-promotion-state-model-definition.md`
- **Agent-wiki / docs institutionalization**: `docs/governance/promotion-state-model.md`
- **Executor**: builders (architect)
- **Completion date**: 2026-06-09
- **2026-06-11 Path-to-100 remediation date**: 2026-06-11
- **2026-06-20 Evidence refresh date**: 2026-06-20

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
**Diagnostics**: root `flutter analyze lib/` FAIL/N/A (no root `lib/`) | root `dart format --set-exit-if-changed lib/ test/` FAIL/N/A (no root `lib/` or `test/`) | root `flutter test` FAIL/N/A (no root `test/`) | root `flutter test --coverage` FAIL/N/A (no root `test/`) | `dart run melos exec -- flutter analyze` FAIL (pre-existing workspace debt) | `dart run melos exec -- dart format --output=none --set-exit-if-changed .` FAIL (pre-existing formatting debt) | `dart run melos exec --dir-exists=test -- flutter test` FAIL (observatory pre-existing test failures) | governance validation PASS with a stale body-reference count discrepancy; numeric historical values are retained in the round-2 report only
**Report**: docs/reports/build-gate-review/1202-review-round2.md
**Patches applied**: none — score below 90
**Findings**:
- [NEW/HIGH] Task 1201 live state evidence is stale: this task and changelog still describe Task 1201 as an `Open` lane mismatch, but live `docs/tasks/02-doing/1201-warp-prism-test-failure-baseline-inventory.md` is `Ready For Review`.
- [NEW/MEDIUM] Fresh `rg "Review State" docs/tasks/02-doing/*.md | wc -l` exposed drift in the old body-reference count; Completion Evidence and changelog now use the stable header-only command instead.
- [EXTERNAL_BLOCKER/MEDIUM] Workspace diagnostics remain red due broad existing app/package analyzer, format, and observatory test failures unrelated to this governance-doc task.
**Path to 100**:
1. Update Task 1202, `docs/governance/promotion-state-model.md`, and the Task 1202 changelog so Task 1201 and Task 1205 examples match their current `03-review` / `Ready For Review` live state, or replace the current `Open` lane mismatch with an actually current `02-doing` / `Open` example.
2. Rerun the governance validation chain and record the stable header-only Review State count instead of the old body-reference count.
3. Preserve the resolved Task 0001 correction: Task 0001 remains documented as a separate `03-review`/`Builder Done` pre-existing defect, not a `02-doing` example.
---

### 2026-06-17 — reviewers independent review
**Score**: 84/100 — NEEDS FIX
**Verdict**: REJECTED_TO_DOING
**Report**: `docs/reports/build-gate-review/1202-review-2026-06-17.md`
**Diagnostics**: docs validation checks mostly ran, but live example audit failed; Melos/Dart workspace checks are additionally blocked by nested pub-cache artifacts under `apps/observatory/tmp/pub-cache`.
**Findings**:
- `NEW/HIGH`: current promotion examples have drifted again. Task 1202 still names Task 0312 and Task 0510 as current `02-doing` examples and Task 1101 as an `Open` lane mismatch, but live files show 0312 and 0510 in `03-review`, and Task 1101 in `02-doing` with `Ready For Review`.
- `NEW/MEDIUM`: `docs/governance/promotion-state-model.md` repeats the stale example narratives.
**Path to 100**:
1. Refresh Task 1202's example-task exit condition and completion evidence against the current filesystem.
2. Update `docs/governance/promotion-state-model.md` examples so every example's lane and state match live task headers, or make examples explicitly historical with non-current wording.
3. Update the Task 1202 changelog if it continues to claim current examples/counts.
4. Rerun the stable docs validation chain after edits and record fresh output.
---

### 2026-06-20 — gt-build-review Wave A
**Score**: 82/100 — Good
**Verdict**: REJECTED → stays in 02-doing
**Diagnostics**: flutter analyze N/A (governance/docs-only) | dart format N/A (governance/docs-only) | flutter test N/A (governance/docs-only) | coverage N/A | governance checks PARTIAL (core files/template/task-governance references pass; live example reconciliation fails)
**Report**: `docs/reports/build-gate-review/1202-review-2026-06-20-wave-a.md`
**Patches applied**: none — score below 90
**Findings**:
- [HIGH] Live-lane reconciliation is false: Task 1202 claims Task 0001 is a `03-review/` `Builder Done` defect, Task 1201 is the sole `03-review/` `Ready For Review` example, and Task 1205 is `04-completed/` `Promoted`, but live files show Task 0001 in `02-doing/` as `Builder Done`, Task 1201 in `04-completed/` as `Promoted`, and Task 1205 in `02-doing/` as `Doing`.
- [MEDIUM] Completion Evidence repeats stale live-state paths/states for Task 1201 and Task 1205.
- [MEDIUM] The local changelog repeats outdated current-state narratives and validation outputs.
**Path to 100**:
1. Refresh Task 1202's exit condition and Completion Evidence against the current filesystem for every cited task example.
2. Update `docs/governance/promotion-state-model.md` annotated examples so Task 0001, Task 1201, Task 1205, and any other cited example match live lanes/states or are explicitly labeled as historical examples.
3. Update `docs/changelog/2026-06-09-task-1202-promotion-state-model-definition.md` to remove or supersede stale current-state claims.
4. Re-run and record stable validation commands, including explicit live path/header checks for Task 0001, 0010, 0011, 0312, 0510, 1101, 1201, and 1205.
---

### 2026-06-20 — gt-build-review Wave A re-review
**Score**: 100/100 — Perfect
**Verdict**: APPROVED → moved to 03-review
**Diagnostics**: flutter analyze N/A (governance/docs-only) | dart format N/A (governance/docs-only) | flutter test N/A (governance/docs-only) | coverage N/A | governance checks PASS (`docs/governance/promotion-state-model.md`, `docs/tasks/000-template.md`, `.agents/rules/task-governance.md`, header-only `02-doing` Review State count `98`, and explicit live headers for 0001/0010/0011/0312/0510/1101/1201/1205)
**Report**: `docs/reports/build-gate-review/1202-review-2026-06-20-wave-a-rereview.md`
**Patches applied**:
- `.agents/rules/task-governance.md` — corrected stale Task 0001 `03-review` defect wording to current `02-doing` / `Builder Done` example.
- Task header — set Status/Review State to `Ready For Review` before reviewer-owned lane movement.
**Path to 100**: n/a — reviewer verified 100/100 after the minimal patch.
---

### 2026-06-26 — reviewer-orchestrator final verification
**Score**: 100/100 — Perfect
**Verdict**: PROMOTED → moved to 04-completed
**Diagnostics**: governance/docs-only — file existence for `docs/governance/promotion-state-model.md` ✓, `.agents/rules/promotion-state-model.md` ✓, `docs/tasks/000-template.md` Review State field ✓, `.agents/rules/task-governance.md` ✓
**Evidence verification**: All live filesystem paths pass. Prior report: `docs/reports/build-gate-review/1202-review-2026-06-20-wave-a-rereview.md`
**Final promotion**: 2026-06-26 — reviewer-orchestrator verified 100/100 against live filesystem and promoted to 04-completed.
---
