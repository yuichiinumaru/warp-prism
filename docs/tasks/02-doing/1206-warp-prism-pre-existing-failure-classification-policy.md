# Task 1206: Pre-existing Failure Classification Policy

> **Status**: `[ ]` Open
> **Review State**: Builder Done — status marker inconsistent with evidence; lane mismatch
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

- [x] A policy document exists at `docs/governance/pre-existing-failure-policy.md`.
- [x] The policy defines: classification criteria, promotion rules, reviewer checklist.
- [x] `.agents/rules/promotion-state-model.md` references the policy.
- [x] Local changelog entry added under `docs/changelog/`.
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: Read
  `.agents/rules/promotion-state-model.md` (failure taxonomy),
  `docs/reports/warp-prism-test-failure-baseline.md` (from Task 1201),
  and at least 3 task completion evidence sections citing "pre-existing."
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
- [x] Update `.agents/rules/promotion-state-model.md` to reference the policy.
- [x] **Simplicity pass**: keep the policy short and decision-oriented.
- [x] **Regression verification**: verify the policy is consistent with the
  promotion state model.

### Where

| File | Purpose |
| --- | --- |
| `.agents/rules/pre-existing-failure-policy.md` | Create — policy document |
| `.agents/rules/promotion-state-model.md` | Modify — add reference to policy |
| `docs/reports/warp-prism-failure-baseline-inventory.md` | Read — failure data |

### How

1. Read existing promotion state model and failure inventory.
2. Read 3+ task evidence sections citing pre-existing failures.
3. Define classification criteria based on the patterns found.
4. Write the policy document.
5. Update the promotion state model to reference it.

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
grep "pre-existing" .agents/rules/promotion-state-model.md
```

---

## Completion Evidence

- **Files created/modified**:
  - CREATED: `docs/governance/pre-existing-failure-policy.md` (full policy with classification decision tree, promotion rules, evidence requirements, reviewer checklist, anti-gaming rules, baseline reference)
  - MODIFIED: `.agents/rules/promotion-state-model.md` (added policy references in Rule 2, Failure Taxonomy table, and Reference section)
  - CREATED: `docs/changelog/20260609-160654-1206-pre-existing-failure-policy-builders.md`
- **Tests or validation commands**:
  - `test -f docs/governance/pre-existing-failure-policy.md` → PASS
  - `grep "pre-existing" .agents/rules/promotion-state-model.md` → 5 matches (Rule 2, taxonomy row, reference link) → PASS
- **Local changelog entry**: `docs/changelog/20260609-160654-1206-pre-existing-failure-policy-builders.md`
- **Agent-wiki / docs institutionalization**: N/A
- **Executor**: builders
- **Completion date**: 2026-06-09
