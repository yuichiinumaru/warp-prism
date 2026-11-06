# Task Template — Warp Prism

> **Required**: Every executable Warp Prism task in `01-open/` or later lanes
> must use this template or preserve all required sections. Minimum length: 50
> lines.
>
> **Lane semantics (reconciled with AGENTS.md §3.1, 2026-09-01)**:
> `00-planning/` may contain BOTH planning artifacts (EPIC/PLAN/CANDIDATE/etc.)
> AND numbered/materialized Tasks intentionally HOLD/not-ready — a dependency,
> external gate, or promotion condition is unmet. `01-open/` means
> **executable NOW**: every hard dependency satisfied, no known blocker, scope
> and non-goals explicit, architecture dispositioned, writeset identifiable,
> validation commands known. A numbered Task keeps its identity when moving
> between lanes; the lane is the only readiness source.
>
> **Milestone Alignment**: every numbered/materialized Task must carry a
> `## Milestone Alignment` section (Target milestone / Capability-Gate advanced
> / Strategic why / Consequence if absent — see the `docs/tasks/AGENTS.md`
> shared baseline and `docs/milestones.md`).

---

# Task NNNN: [Descriptive Task Name]

> **Lane-derived status**: The containing task directory is the sole source of lifecycle/readiness status (`00-planning/`, `01-open/`, `02-doing/`, `03-review/`, or `04-completed/`). Do not add a task-level `Status` field; record richer state in the body or Review Trail.
> **Review State**: `Open` | `Doing` | `Builder Done` | `Package Gate Failed` | `Consumer Gate Failed` | `Ready For Review` | `Review Approved` | `Promoted` | `Superseded` | `Blocked` — see `docs/governance/promotion-state-model.md`
>
> Review State describes the review/progress sub-state; it does not replace or duplicate the containing lane.
> **Priority**: 🔴 P0 | 🟡 P1 | 🟢 P2 | ⚪ P3
> **Type**: `feature` | `remediation` | `verification` | `testing` | `governance` | `housekeeping` | `ux-polish`
> **Origin**: [prompt/research/draft/report/user request/task audit]
> **Blocks**: [Task NNNN or N/A]
> **Depends on**: [Task NNNN or N/A]

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task NNNN` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.
> Lanes such as `02-doing` and `03-review` are mutable status, not identity.

---

## Milestone Alignment

- **Target milestone**: [milestone ID in `docs/milestones.md`]
- **Capability / Gate advanced**: [gate or capability this task advances]
- **Strategic why**: [why this is necessary now for the milestone]
- **Consequence if absent**: [what breaks or stays unverified without it]

---

## Objective

[Describe the concrete outcome. A new agent should know exactly what success
looks like after reading this section.]

## Background Context

### What already exists

- [List current files, fixtures, UI surfaces, or docs.]

### What is missing or broken

- [List concrete gaps with paths whenever possible.]

---

## Test Requirements

- [Measurable requirement 1.]
- [Measurable requirement 2.]
- [Measurable requirement 3.]

---

## Exit Conditions

- [ ] [Binary artifact condition.]
- [ ] [Relevant Flutter/Dart validation command passes.]
- [ ] [Relevant fixture/docs validation command passes.]
- [ ] Local changelog entry added under `docs/changelog/`.
- [ ] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [ ] **Read existing code before modifying**: [List files to read.]
- [ ] [Atomic subtask with observable result.]
- [ ] [Atomic subtask with observable result.]
- [ ] **Simplicity pass**: remove unnecessary complexity introduced by this task.
- [ ] **Regression verification**: run the validation commands listed below.

### Where

| File | Purpose |
| --- | --- |
| `path/to/file.dart` | Read / Modify / Create — why |
| `path/to/test.dart` | Read / Modify / Create — why |

### How

1. [Step 1.]
2. [Step 2.]
3. [Step 3.]

### Why

[Explain why this task is necessary and what breaks if it is not done.]

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not mark this task complete without running the validation commands and
> filling Completion Evidence.

> [!IMPORTANT]
> Preserve Warp Prism read-only mock-observatory semantics unless this task
> explicitly changes the product contract.

---

## Validation Commands

```bash
flutter analyze
flutter test
```

If Flutter tooling is unavailable in the execution environment, record the exact
tooling failure and do not claim those checks passed.

---

## Completion Evidence

- **Files created/modified**: [list]
- **Tests or validation commands**: [commands and PASS/FAIL]
- **Local changelog entry**: [path]
- **Agent-wiki / docs institutionalization**: [path or N/A]
- **Executor**: [agent]
- **Completion date**: [YYYY-MM-DD]
