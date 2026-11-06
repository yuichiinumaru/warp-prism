---
epic_id: EPIC-P0-trust-core
story_id: P0-S02
title: "Command registry + decision-review spine"
status: active
task_ids: [1870, 1871]
---

# Story P0-S02: Command Registry + Decision-Review Spine

> **Type**: `STORY` (scoped slice — **not** an executable task)
> **Epic**: [EPIC-P0-trust-core](../epics/EPIC-P0-trust-core.md)
> **Home**: `.project/tasks/stories/P0-S02-command-review-spine.md` (non-lane)
> **Source**: backlog seams S2 (registry+self-doc+dispatch) + S6 (review+bounded repair); F-03 (I=100) + F-04 (I=100).

## Objective

Commands become enumerable, self-describing, eligibility-checked intent objects with a guarded dispatch router — and the decisions agents/proposals produce become reviewable on a single surface (inspector + evidence + caller-diff + caller-action-bar) with bounded repair. Registry feeds review: every reviewed action resolves eligibility through F-01 and renders indeterminacy through F-02.

## Scope

### In scope

- IDS `CommandIntent` registry + runtime `describe()` self-doc seam + router molecule with edit-focus guard (Task 1870).
- `PrismDecisionReviewSurface` organism + bounded-repair molecule + verdict pass-through invariant (Task 1871).
- Chord collision/precedence, enumeration stability, keyboard-only path, tooltip-reason per verdict.

### Out of scope

- Authority semantics (P0-S01 — consumed, not rebuilt); palette visual restyle beyond eligibility/disabled-reason propagation.
- Proposal computation, prompt enhancement models, approval policy — product-local.

## Tasks (canonical)

- Task 1870
- Task 1871

Frontmatter `task_ids` matches this list.

## Path projection (generated)

<!-- task-path-sync:start -->
| ID | Title | Path |
|----|-------|------|
| 1870 | Command registry + self-doc catalog + dispatch router (F-03) | [1870](../01-open/1870-warp-prism-command-registry-selfdoc-dispatch.md) |
| 1871 | Decision-review surface + bounded repair (F-04) | [1871](../01-open/1871-warp-prism-decision-review-bounded-repair.md) |
<!-- task-path-sync:end -->

## Acceptance (story level)

- [ ] Both tasks closed with independent review; registry enumeration stable across runs; unknown≠pass proven by suite.
- [ ] Host proof on ≥2 hosts for the review surface (backlog gate), WB + CC for the router.
- [ ] No STABLE/barrel promotion — both land EXPERIMENTAL.
