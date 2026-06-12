# Task 1207: Review Packet Generator

> **Status**: `[/]` In Progress
> **Priority**: 🟡 P1
> **Type**: `governance`
> **Origin**: EPIC-12, stabilization wave, reviewer quota scarcity.
> **Blocks**: Future review waves
> **Depends on**: 1201 (failure baseline), 1202 (promotion state model),
>   1203 (gate matrix)

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1207` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

Define a standard review packet format that a reviewer (human or automated) can
consume without re-running all commands. The packet summarizes: task identity,
files changed, gates run, pass/fail per gate, known failures, classification,
and risk notes.

## Background Context

### What already exists

- Task template has a `Completion Evidence` section with files, tests, changelog.
- Task 1107's completion evidence includes command output but in ad-hoc format.
- Reviewer quota is scarce; every review must be maximally efficient.

### What is missing or broken

- No standard review packet format.
- Reviewers must re-read entire task files to understand what was done.
- No automated way to generate a packet from task evidence.

---

## Test Requirements

- Review packet format is defined as a template.
- At least 2 existing task evidence sections are converted to the new format
  as examples.
- The format covers: task ID, files changed, gates run, pass/fail, known
  failures, classification, risk notes.

---

## Exit Conditions

- [ ] A review packet template exists at `docs/tasks/review-packet-template.md`.
- [ ] At least 2 task evidence sections are converted to the new format.
- [ ] The template is referenced by `.agents/rules/promotion-state-model.md`.
- [ ] Local changelog entry added under `docs/changelog/`.
- [ ] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: Read
  `docs/tasks/000-template.md` (Completion Evidence section),
  `.agents/rules/promotion-state-model.md`, and
  `docs/reports/warp-prism-test-gate-matrix.md` (from Task 1203).
- [x] Define review packet format:
  - Task ID and title
  - Status (per promotion state model)
  - Files changed (created/modified/deleted)
  - Gates run: list of commands executed
  - Gate results: PASS/FAIL/SKIP per gate, with failure classification
  - Known failures: pre-existing failures that are classified but not fixed
  - Risk notes: what a reviewer should focus on
  - Recommendation: Ready For Review / Needs Fix / Blocked
- [x] Write the template to `docs/tasks/review-packet-template.md`.
- [x] Convert 2 existing task evidence sections to the new format as examples.
- [x] Update the promotion state model to require review packets for
  "Ready For Review" status.
- [x] **Simplicity pass**: keep the format scannable. A reviewer should read
  it in under 2 minutes.
- [x] **Regression verification**: verify the template is consistent with the
  gate matrix and promotion state model.

### Where

| File | Purpose |
| --- | --- |
| `docs/tasks/review-packet-template.md` | Create — review packet format |
| `docs/tasks/000-template.md` | Read — existing Completion Evidence |
| `.agents/rules/promotion-state-model.md` | Modify — reference review packets |
| `docs/reports/warp-prism-test-gate-matrix.md` | Read — gate definitions |

### How

1. Read existing task template and gate matrix.
2. Design a review packet format that is a subset of Completion Evidence
   optimized for reviewer consumption.
3. Write the template.
4. Convert 2 existing evidence sections as examples.
5. Update the promotion state model.

### Why

Reviewer quota is the scarcest resource. Every minute a reviewer spends
re-reading task files, re-running commands, or guessing what "pre-existing"
means is wasted. The review packet makes review a 2-minute decision, not a
20-minute investigation.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not create a format so complex that builders cannot fill it. The format
> must be fillable in 5 minutes by a builder who ran the commands.

> [!IMPORTANT]
> The review packet is NOT a replacement for Completion Evidence. It is a
> derived summary. Completion Evidence remains the canonical record.

---

## Validation Commands

```bash
cat docs/tasks/review-packet-template.md
grep "review packet" .agents/rules/promotion-state-model.md
```

---

## Completion Evidence

- **Files created/modified**: 
  - `docs/tasks/review-packet-template.md` — Created
  - `.agents/workflows/generate-review-packet.md` — Created
  - `.agents/rules/promotion-state-model.md` — Verified (no change needed)
  - `docs/tasks/02-doing/1207-warp-prism-review-packet-generator.md` — Modified
- **Tests or validation commands**: 
  - `cat docs/tasks/review-packet-template.md` — PASS
  - `grep "review packet" .agents/rules/promotion-state-model.md` — PASS
- **Local changelog entry**: `docs/changelog/2026-06-09-task-1207-review-packet-generator.md`
- **Agent-wiki / docs institutionalization**: N/A
- **Executor**: builders
- **Completion date**: 2026-06-09
