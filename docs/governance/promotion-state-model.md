# Promotion State Model — Warp Prism Governance

> **Authority**: Canonical governance reference for task promotion lifecycle.
> **Source rule**: `.agents/rules/promotion-state-model.md`
> **Scope**: All executable tasks under `.project/tasks/`.
> **Created**: 2026-06-09
> **Task origin**: Task 1202

This document formalizes the promotion state model for Warp Prism executable
tasks. It replaces the previous ambiguous `[x] Done` which could mean anything
from "builder ran a local test" to "reviewer approved." Every executable task
flows through these states before it can be considered promoted.

---

## 1. States

| State | Marker | Meaning |
|-------|--------|---------|
| **Open** | `[ ]` | Task is defined and in `01-open/`. No work started. Ready for builder pickup. |
| **Doing** (`In Progress` legacy alias) | `[/]` | Executor actively working. Task is in `02-doing/`. Implementation underway. Use `Doing` for new task headers. |
| **Builder Done** | `[x]` Builder Done | Implementation complete. Local tests pass. Changelog added. Completion evidence filled. Package gate and consumer gate not yet verified. |
| **Package Gate Failed** | `[/]` Package Gate Failed | Builder done, but package-level `flutter test` or `flutter analyze` fails in the owning package. Failure is classified per the failure taxonomy. |
| **Consumer Gate Failed** | `[/]` Consumer Gate Failed | Package gate passes, but at least one consumer app (`apps/observatory`, `apps/catalog`, `apps/cybercore`) fails after the change. |
| **Ready For Review** | `[x]` Ready For Review | All required gates pass (per gate matrix). Review packet generated. Waiting for independent reviewer. |
| **Review Approved** | `[x]` Review Approved | Independent reviewer confirmed correctness, test quality, and promotion criteria. Ready to move to `04-completed/`. |
| **Promoted** | `[x]` Promoted | Moved to `04-completed/`. All exit conditions satisfied. Definition of Done checklist all checked. Terminal state. |
| **Superseded** | `[~]` | Task is obsolete. Superseded by another task or architectural decision. Terminal state. |
| **Blocked** | `[!]` | Cannot proceed due to external dependency (e.g., Flutter SDK unavailable, prerequisite task incomplete, upstream blocker). Can transition back to any active state once unblocked. |

`Doing` is the canonical active-work state for the `[/]` marker and canonical
alias for the previous `In Progress` label. `In Progress` is retained only as a
legacy alias while existing task files are reconciled; it is not a distinct
promotion state.

---

## 2. Transitions

```
                    ┌─────────────┐
                    │  Superseded │  (terminal)
                    └──────▲──────┘
                           │
┌──────┐  pickup   ┌──────┴──────┐  done   ┌──────────────┐
│ Open ├──────────►│    Doing    ├────────►│ Builder Done  │
└──────┘           └──────┬──────┘         └───┬───┬───┬───┘
                          │                    │   │   │
                    blocked                    │   │   │
                          │                    │   │   │
                          ▼                    │   │   │
                    ┌──────────┐               │   │   │
                    │ Blocked  │◄──────────────┘   │   │
                    └────┬─────┘  pkg gate fail    │   │
                         │                         │   │
                         └─► back to Doing/Builder │   │
                                                  │   │
                    ┌─────────────────────────────┘   │
                    │ consumer gate fail               │
                    ▼                                  │
              ┌─────────────────────┐                 │
              │ Consumer Gate Failed │                │
              └──────────┬──────────┘                 │
                         │ fix + re-gate              │
                         └──► Builder Done            │
                                                     │
              ┌──────────────────────────────────────┘
              │ gates pass + packet ready
              ▼
        ┌──────────────────┐
        │ Ready For Review  │
        └────────┬─────────┘
                 │ reviewer approves
                 ▼
        ┌──────────────────┐
        │ Review Approved   │
        └────────┬─────────┘
                 │ move to 04-completed/
                 ▼
        ┌──────────────────┐
        │    Promoted       │  (terminal)
        └──────────────────┘
```

### Transition Table

| From | To | Condition |
|------|----|-----------|
| **Open** | **Doing** | Executor picks up the task and starts work. |
| **Doing** | **Builder Done** | Implementation complete, local tests pass, changelog added, completion evidence filled. |
| **Doing** | **Blocked** | External dependency prevents progress (SDK, upstream, environment). |
| **Doing** | **Superseded** | Architectural decision or task redesign makes this task obsolete. |
| **Builder Done** | **Package Gate Failed** | Package-level `flutter test` or `flutter analyze` fails. Failure classified per taxonomy. |
| **Builder Done** | **Consumer Gate Failed** | Package gate passes but consumer app fails after the change. |
| **Builder Done** | **Ready For Review** | All required gates pass. Review packet exists. |
| **Package Gate Failed** | **Builder Done** | Fix applied, package gate re-passes. |
| **Package Gate Failed** | **Blocked** | Failure requires external dependency resolution. |
| **Consumer Gate Failed** | **Builder Done** | Fix applied, consumer gate re-passes. |
| **Consumer Gate Failed** | **Blocked** | Consumer failure requires upstream fix. |
| **Ready For Review** | **Review Approved** | Independent reviewer confirms correctness and quality. |
| **Ready For Review** | **Builder Done** | Reviewer finds issues, sends back for rework. |
| **Review Approved** | **Promoted** | Task moved to `04-completed/`. All DoD checklist items satisfied. |
| **Review Approved** | **Builder Done** | Post-approval issue discovered before lane move. |
| **Any active state** | **Superseded** | Task made obsolete by architectural decision at any point. |
| **Blocked** | **Doing** | Blocker resolved, work resumes. |
| **Blocked** | **Builder Done** | Blocker resolved and implementation was already complete. |

---

## 3. Gate Definitions

### Package Gate

The **Package Gate** verifies that the owning package compiles, analyzes, and
tests cleanly after the task's changes.

**Concrete checks**:
- `flutter analyze` in the owning package returns zero errors.
- `flutter test` in the owning package passes (all tests, no regressions).
- No new warnings introduced by the task's changes.

**Scope**: The owning package is the Melos workspace member (e.g.,
`packages/warp_prism_ui`, `apps/observatory`) whose files were modified by the
task. If a task modifies files in multiple packages, all modified packages must
pass.

**Who runs it**: The builder, before declaring `Builder Done`. The gate result
is recorded in the task's completion evidence.

### Consumer Gate

The **Consumer Gate** verifies that downstream consumer applications still
compile and test after the task's changes propagate through package imports.

**Concrete checks**:
- Each consumer app listed in the gate matrix for the task type runs
  `flutter analyze` and `flutter test` without new failures.
- Consumer apps are: `apps/observatory`, `apps/catalog`, `apps/cybercore`.

**Scope**: Only consumer apps that import the modified package(s) need to be
checked. The gate matrix (see below) specifies which consumers are required
per task type.

**Who runs it**: The builder, after the package gate passes. If the consumer
gate fails, the task enters `Consumer Gate Failed` and the builder must fix
the issue before re-gating.

### Gate Matrix

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
| Governance | optional | N/A | N/A | N/A |

### Failure Taxonomy

| Class | Meaning | Blocks Promotion? |
|-------|---------|:-----------------:|
| Broken compile | File does not compile | Yes, always |
| Contract drift | API signature/export mismatch | Yes, if related to the task |
| Stale test | Test expects old behavior, code is correct | No, if classified; fix in follow-up |
| Real regression | Task broke something that was working | Yes, always |
| Async/flaky | Timer, overlay, or lifecycle fragility | Yes, until deterministic |
| Semantics drift | Labels, roles, or accessibility expectations stale | Yes, if interactive component |
| Missing fixture | Test data absent or malformed | Yes, if parser/test depends on it |
| Pre-existing (unrelated) | Failure existed before, task did not touch the area. See `docs/governance/pre-existing-failure-policy.md` and `.agents/rules/pre-existing-failure-policy.md`. | No, but must be classified |

---

## 4. Mapping to Current Lanes

The promotion state model maps to the existing lane structure but adds
intra-lane states that the lanes alone cannot express.

| Lane | States That Can Occur Here | Notes |
|------|---------------------------|-------|
| `00-planning/` | *(no promotion states)* | Planning artifacts are not executable tasks. |
| `01-open/` | **Open** | Tasks here are definitionally Open. |
| `02-doing/` | **Doing**, **Builder Done**, **Package Gate Failed**, **Consumer Gate Failed**, **Blocked**, **Superseded** | This is the primary working lane. Multiple promotion states coexist here. |
| `03-review/` | **Ready For Review**, **Review Approved** | Tasks here must be at least Ready For Review. |
| `04-completed/` | **Promoted** | Only Promoted tasks belong here. |

### Critical Insight: Lane ≠ State

A task in `02-doing/` could be in any of six different promotion states. The
lane tells you *where* the task file lives; the state tells you *what
condition* the task is in. This is why the `Review State` field was added to
the task template — it makes the state visible without requiring agents to
infer it from context.

---

## 5. Annotated Examples

The following examples reconcile the promotion state model with the live lanes.
Task 0001 is documented as a pre-existing `03-review/`/`Builder Done` governance
defect. Task 1201 and Task 1205 are now documented as current `03-review/`/`Ready
For Review` examples. The remaining examples are current `02-doing/` examples and
include Task 1101 as the current `Open` lane mismatch example.

### Task 0001 — Mock Workspace Contract Baseline (pre-existing lane-state defect)

- **Current lane**: `.project/tasks/03-review/0001-warp-prism-mock-workspace-contract-baseline.md`
- **Current status marker**: `[x]` Done (legacy marker); **Review State**: `Builder Done`
- **Promotion state**: **Builder Done**
- **Evidence**: `test -f .project/tasks/03-review/0001-warp-prism-mock-workspace-contract-baseline.md` passes; `test ! -e .project/tasks/02-doing/0001-warp-prism-mock-workspace-contract-baseline.md` passes; `rg -n "Review State" .project/tasks/03-review/0001-warp-prism-mock-workspace-contract-baseline.md` reports `Builder Done`.
- **Rationale**: This governance task is already in `03-review/` but remains marked `Builder Done`, which violates the lane move rule that tasks in `03-review/` must be at least `Ready For Review`. This is documented as a separate pre-existing governance defect, not as a `02-doing/` example.

### Task 0010 — Foundation Audit Analyzer Baseline

- **Current lane**: `.project/tasks/02-doing/0010-warp-prism-foundation-audit-analyzer-baseline.md`
- **Current status**: `[x]` Done
- **Promotion state**: **Blocked**
- **Rationale**: This verification task is in `02-doing/` with completion
  evidence, but its validation commands are blocked because the Flutter SDK is
  not installed. Under the promotion model, it cannot advance to `Ready For
  Review` until the package gate blocker is resolved or explicitly classified.

### Task 0011 — Bootstrap Main Router Shell

- **Current lane**: `.project/tasks/02-doing/0011-warp-prism-bootstrap-main-router-shell.md`
- **Current status**: `[x]` Done
- **Promotion state**: **Builder Done**
- **Rationale**: This feature task created `main.dart`, `app.dart`, and
  `router.dart`. The app compiles and the shell boots. Package gate
  (`flutter analyze`, `flutter test`) should have been run but the task
  was never advanced through review. It sits in Builder Done.

### Task 0312 — Read-Only Mock Workspace Repository

- **Current lane**: `.project/tasks/02-doing/0312-warp-prism-read-only-mock-workspace-repository.md`
- **Current status**: `[x]` Completed
- **Promotion state**: **Builder Done**
- **Rationale**: This data-layer feature created the repository interface
  and mock workspace loading. The task type is "Parser/data layer" which
  requires local proof + package proof + app-specific consumer proof per the
  gate matrix. Without documented gate evidence, the task is Builder Done
  — not Ready For Review.

### Task 0510 — Map Workspace Scaffold

- **Current lane**: `.project/tasks/02-doing/0510-warp-prism-map-workspace-scaffold.md`
- **Current status**: `[x]` Done
- **Promotion state**: **Builder Done**
- **Rationale**: This feature task created the Map route scaffold and
  subview switching. As an app-route task type, it requires local proof +
  package proof + app-specific consumer proof + boundary test. Without
  documented gate passes and a review packet, it remains Builder Done.

### Task 1101 — Charter And Naming Convergence

- **Current lane**: `.project/tasks/02-doing/1101-warp-prism-charter-and-naming-convergence.md`
- **Current status**: `[ ]` Open
- **Promotion state**: **Open**
- **Rationale**: This task is in `02-doing/` but its header still says
  `Review State: Open — unstarted task; lane mismatch (should be in 01-open/)`.
  Under the promotion model, it should be in `01-open/` until a builder picks it
  up. This is the current lane/state mismatch example that the model surfaces.

### Task 1205 — Boundary Test Harness

- **Current lane**: `.project/tasks/03-review/1205-warp-prism-boundary-test-harness.md`
- **Current status**: `[x]` Ready For Review
- **Promotion state**: **Ready For Review**
- **Rationale**: This task is in `03-review/` and its header says
  `Review State: Ready For Review`. It is no longer a `02-doing/` lane mismatch
  example; earlier evidence that described Task 1205 as `Open` is superseded.

### Task 1201 — Test Failure Baseline Inventory

- **Current lane**: `.project/tasks/03-review/1201-warp-prism-test-failure-baseline-inventory.md`
- **Current status**: `[x]` Ready For Review
- **Promotion state**: **Ready For Review**
- **Rationale**: This governance task is in `03-review/` and its header says
  `Review State: Ready For Review`. It is no longer a `02-doing/` lane mismatch
  example; earlier evidence that described Task 1201 as `Open` is superseded.


---

## 6. Rules

1. **Never mark a task `Promoted` if the package gate is red.** Package-level
   `flutter test` passing is a minimum requirement for promotion.
2. **`pre-existing failure` is not a promotion bypass.** Pre-existing failures
   must be classified per the failure taxonomy, `.agents/rules/pre-existing-failure-policy.md`
   (builder source rule), and `docs/governance/pre-existing-failure-policy.md`
   (canonical policy). A task touching an area with related pre-existing failures
   cannot be promoted until those failures are resolved or explicitly justified
   with reviewer sign-off.
3. **`Builder Done` is the default initial completion state.** When a builder
   finishes work, the task enters `Builder Done`. Promotion requires additional
   gates per the gate matrix.
4. **State transitions are additive with controlled rollback.** A task can move
   forward through states. Going backward (e.g., from `Ready For Review` to
   `Builder Done`) is allowed when a reviewer discovers an issue.
5. **Review packets are required for `Ready For Review`.** Without a review
   packet, a task stays in `Builder Done`. Builders must fill the canonical
   template at `.project/tasks/review-packet-template.md` (workflow:
   `.agents/workflows/generate-review-packet.md`) before claiming
   `Ready For Review`.
6. **Lane moves are state-gated.** A task cannot move to `03-review/` unless it
   is in `Ready For Review` state. It cannot move to `04-completed/` unless it
   is in `Review Approved` state.
7. **Blocked tasks must document the blocker.** A task in `Blocked` state must
   record what external dependency prevents progress and what would unblock it.

---

## 7. References

- **Source rule**: `.agents/rules/promotion-state-model.md`
- **Pre-existing failure policy**: `.agents/rules/pre-existing-failure-policy.md` (builder source rule), `docs/governance/pre-existing-failure-policy.md` (canonical policy)
- **Task template**: `.project/tasks/000-template.md` (includes `Review State` field)
- **Review packet template**: `.project/tasks/review-packet-template.md` (canonical format — Task 1207)
- **Review packet workflow**: `.agents/workflows/generate-review-packet.md` (Task 1207)
- **Task governance**: `.agents/rules/task-governance.md`
- **Definition of Done**: `.agents/rules/definition-of-done.md`
- **EPIC-12 tasks**: 1201 (failure inventory), 1202 (this model), 1203 (gate
  matrix), 1206 (failure classification), 1207 (review packets)
