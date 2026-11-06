# EPIC 20 — Warp Prism Interaction Design System (IDS) Kernel

> **Planning Status**: Draft — source-reality reviewed 2026-08-31. Verdict: **EXECUTION CANDIDATE**, runs PARALLEL to EPIC-21 (no conceptual dependency; both hang off the 19-gate; converge at bindings 21-C). NOT executable yet.
> **Priority**: 🔴 P0
> **Origin**: `docs/ads-to-ids.md` hypothesis corpus, falsified 2026-08-31: recurrence evidence exists ONLY for Selection + Inspection (>100 ad-hoc `selected` usages, 10+ bespoke callback patterns, only `DSWorkflowSelection` is a dedicated payload). Query/NavigationIntent/ViewportState have NO recurrence evidence → candidate ledger, not kernel.
> **Depends on**: EPIC-19 gate ONLY (was: EPIC-19 + implicit runtime sequencing — removed 2026-08-31).

---

## 1. Objective

Formalize a **small** IDS package (`warp_prism_interaction`, pure Dart) that captures reusable interaction *semantics* (Selection, Command, Inspect, Query, Navigation, Drag, Viewport) distinct from widget mechanics (`DSInteractiveSurface` etc. stays in `warp_prism_ui`).

## 2. Background

- `warp_prism_ui` already implements interaction mechanics (focus, keyboard, pointer, a11y) inside components.
- Semantics are currently ad-hoc per component; a separate minimal vocabulary prevents each downstream app from re-deriving interactions.
- IDS = semantics vocabulary ONLY. **Not a state-management framework** (no Redux/Riverpod).

## 3. Stories (v8)

| Story | Title | Key deliverable | 2026-08-31 verdict |
|---|---|---|---|
| S20-01 | Interaction Primitive Set | Inventory-driven: kernel admits ONLY recurrence-backed primitives (Selection, Inspection, Command-intent first); Query/Navigation/Viewport → deferred ledger | AMEND (evidence-driven) |
| S20-02 | Interaction State Machine Vocabulary | states/events/transitions/guards/effects; interaction-state vs visual-token separation | ACCEPT |
| S20-03 | Input Contract | pointer/keyboard/a11y modalities, normalized fields, pure Dart, a11y first-class | ACCEPT |
| S20-04 | Counter-Example Matrix | near-misses mapped to correct home (health polling→Runtime; layout→presentation; navigation→app) | ACCEPT |
| S20-05 | Promotion Gate | ≥2 distinct consumers OR 2 distinct domains; candidate stage; Interaction pipeline; lifecycle PROPOSED→EXPERIMENTAL→PROVEN→STABLE | AMEND (lifecycle) |

## 4. Out of Scope

- Runtime contract work (EPIC-21).
- Any Flutter widget implementation inside `warp_prism_ui` in this epic.
- Any Rust/FRB bindings.
- Catalog/gallery mechanical changes.

## 5. Exit Conditions

- [ ] Primitive list + type signatures documented and approved.
- [ ] Lifecycle vocabulary defined and reviewed against live UI/state semantics.
- [ ] Test coverage requirements enumerated (named tests, not code).
- [ ] Promotion rule recorded (≥2 distinct consumers OR 2 distinct domains).
- [ ] Ownership of `warp_prism_interaction` package NAME assigned; creation deferred to first concrete task.

## 6. Dependencies

- EPIC-19 only. No technical dependency on `warp_prism_ui` changes.
