---
id: promotion-state-model
title: Promotion State Model
scope: warp-prism
status: active
---

# Promotion State Model

This rule defines the formal lifecycle states for Warp Prism executable tasks.
It replaces the previous ambiguous `[x] Done` which could mean anything from
"builder ran a local test" to "reviewer approved."

## State Definitions

`Doing` is the canonical active-work state and canonical alias for the previous
`In Progress` label. `In Progress` is retained only as a legacy alias while
existing task files are reconciled; it is not a distinct promotion state.

| State | Marker | Meaning |
|-------|--------|---------|
| **Open** | `[ ]` | Task is in `01-open/`. No work started. |
| **Doing** (`In Progress` legacy alias) | `[/]` | Executor actively working. In `02-doing/`. Use `Doing` for new task headers. |
| **Builder Done** | `[x]` Builder Done | Implementation complete. Local tests pass. Changelog added. Completion evidence filled. BUT: package gate and/or consumer gate not yet verified. |
| **Package Gate Failed** | `[/]` Package Gate Failed | Builder done, but package-level `flutter test` or `flutter analyze` fails in the owning package. Failure is classified (see failure taxonomy). |
| **Consumer Gate Failed** | `[/]` Consumer Gate Failed | Package gate passes, but at least one consumer app (`apps/observatory`, `apps/catalog`, `apps/cybercore`) fails after the change. |
| **Ready For Review** | `[x]` Ready For Review | All required gates pass (per gate matrix). Review packet generated. Waiting for reviewer. |
| **Review Approved** | `[x]` Review Approved | Independent reviewer confirmed correctness, test quality, and promotion criteria. |
| **Promoted** | `[x]` Promoted | Moved to `04-completed/`. All exit conditions satisfied. Definition of Done checklist all checked. |
| **Superseded** | `[~]` | Task is obsolete. Superseded by another task or architectural decision. |
| **Blocked** | `[!]` | Cannot proceed due to external dependency (e.g., Flutter SDK unavailable, prerequisite task not done). |

## Rules

1. **Never mark a task `Promoted` if the package gate is red.** Package-level
   `flutter test` passing is a minimum requirement for promotion.
2. **`pre-existing failure` is not a promotion bypass.** Pre-existing failures
   must be classified per the failure taxonomy (EPIC-12, Task 1201/1206), the
   builder source rule `.agents/rules/pre-existing-failure-policy.md`, and the
   canonical [Pre-existing Failure Classification Policy](../../docs/governance/pre-existing-failure-policy.md).
   A task touching an area with related pre-existing failures cannot be promoted
   until those failures are resolved or explicitly justified with reviewer sign-off.
3. **`Builder Done` is the default initial completion state.** When a builder
   finishes work, the task enters `Builder Done`. Promotion requires additional
   gates per the gate matrix (EPIC-12, Task 1203).
4. **State transitions are additive.** A task can move forward through the
   states. Going backward (e.g., from `Ready For Review` to `Package Gate Failed`)
   is allowed when a reviewer discovers an issue.
5. **Review packets (EPIC-12, Task 1207) are required for `Ready For Review`.**
   Without a review packet, a task stays in `Builder Done`.

## Gate Matrix (Summary)

| Task Type | Local Proof | Package Proof | Consumer Proof | Boundary Test |
|-----------|:-----------:|:-------------:|:--------------:|:-------------:|
| Docs-only | optional | N/A | N/A | N/A |
| ADS component | required | required | required | required |
| ADS token/theme | required | required | required | required |
| App route | required | required | app-specific | required |
| Parser/data layer | required | required | app-specific | N/A |
| Monorepo migration | required | required | all consumers | required |
| CyberCore fixture | required | required | cybercore | required |
| Performance-sensitive | required + benchmark | required | required | required |

## Failure Taxonomy

| Class | Meaning | Blocks Promotion? |
|-------|---------|:-----------------:|
| Broken compile | File does not compile | Yes, always |
| Contract drift | API signature/export mismatch | Yes, if related to the task |
| Stale test | Test expects old behavior, code is correct | No, if classified; fix test in follow-up |
| Real regression | Task broke something that was working | Yes, always |
| Async/flaky | Timer, overlay, or lifecycle fragility | Yes, until deterministic |
| Semantics drift | Labels, roles, or accessibility expectations stale | Yes, if interactive component |
| Missing fixture | Test data absent or malformed | Yes, if parser/test depends on it |
| Pre-existing (unrelated) | Failure existed before and task did not touch the area. See `.agents/rules/pre-existing-failure-policy.md` and [Pre-existing Failure Policy](../../docs/governance/pre-existing-failure-policy.md). | No, but must be classified |

## Reference

This model is consumed by:
- `.agents/rules/task-governance.md` (task lane rules)
- `docs/tasks/000-template.md` (task template)
- `.agents/rules/pre-existing-failure-policy.md` (builder source rule — Task 1206)
- `docs/governance/pre-existing-failure-policy.md` (canonical governance policy — Task 1206)
- EPIC-12 tasks (1201-1207)
- All future executable tasks promoted after this rule becomes active.
