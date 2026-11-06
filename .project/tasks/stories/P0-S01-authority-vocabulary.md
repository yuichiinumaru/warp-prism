---
epic_id: EPIC-P0-trust-core
story_id: P0-S01
title: "Authority + honest-unknown vocabulary"
status: active
task_ids: [1868, 1869]
---

# Story P0-S01: Authority + Honest-Unknown Vocabulary

> **Type**: `STORY` (scoped slice — **not** an executable task)
> **Epic**: [EPIC-P0-trust-core](../epics/EPIC-P0-trust-core.md)
> **Home**: `.project/tasks/stories/P0-S01-authority-vocabulary.md` (non-lane)
> **Source**: backlog seams S1 (gate+authority) + S4-core (unknown vocabulary); F-01 (I=125) + F-02 (I=125).

## Objective

Every Prism-mediated action resolves to an explicit authority outcome (allow/constrain/deny with reason — disabled-with-reason, never hidden), and every indeterminate state renders as unknown/abstained and fails closed. These two semantics are the foundation the rest of P0 composes on (F-04 review integrity, F-07 gated verbs, F-09 loading landings all consume them).

## Scope

### In scope

- IDS `ActionAvailability`/`CapabilityState` pure-Dart semantics + `PrismActionGate` molecule (Task 1868).
- `DSStateType` extension + IDS inspection/query `unknown` + `abstained/notAttempted` states + fail-closed rendering rule (Task 1869).
- Fail-closed conformance suites and determinism exclusions for both.

### Out of scope

- Command registry (P0-S02), review surface (P0-S02), provenance (P0-S03) — they consume this story's contracts.
- Product-side capability evaluation, causation computation, daemon wiring — product-local.

## Tasks (canonical)

- Task 1868
- Task 1869

Frontmatter `task_ids` matches this list.

## Path projection (generated)

<!-- task-path-sync:start -->
| ID | Title | Path |
|----|-------|------|
| 1868 | Capability-gated action + authority outcome (F-01) | [1868](../01-open/1868-warp-prism-capability-gated-action-authority.md) |
| 1869 | Honest-unknown + abstention vocabulary, fail-closed rendering (F-02) | [1869](../01-open/1869-warp-prism-honest-unknown-abstention-vocabulary.md) |
<!-- task-path-sync:end -->

## Acceptance (story level)

- [ ] Both tasks closed with independent review; IDS purity + boundary harness green.
- [ ] Unknown-rendered-as-success and hidden-as-inapplicable defects have failing-first conformance coverage.
- [ ] F-01 eligibility shape and F-02 vocabulary frozen enough for P0-S02/P0-S04 construction to proceed on contract.
