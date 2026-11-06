# Task 1852: Energy-curve editor disposition (F-23) — HOLD

> **Epic:** `EPIC-P2-staged` (Story P2-A). **Source:** backlog F-23 card (§2) + TP U-08 + Macro P2-7.
> **State:** HOLD in `00-planning/`. **Unlock condition:** architecture-owner disposition on whether topology-only `DSGraphCanvas` can carry the energy-curve editor or a new primitive is justified (crate-boundary justification required). Single-consumer + insufficient-substrate = genuine technical unknown, not a sequencing preference.
> **Mandate note:** CANDIDATE P2. Under MISSION §3.1 recurrence no longer gates absorption, but the substrate question must be answered before any build.

## Outcome and boundaries

Produce a recorded architecture disposition (not an implementation): can TP `SongBlueprintWidget` (energy bar + drag sliders + preset toolbar) be expressed over `DSGraphCanvas` topology + injected curve model, or does it require a new Prism primitive? Either outcome closes this task; a build task is explicitly out of scope here and materializes only on a build disposition.

Scope: donor re-read, substrate capability test (spike-allowed, proof-lab only), disposition record with justification. Non-goals: any STABLE/EXPERIMENTAL widget, preset-toolbar absorption, musical-math ownership (stays local).

## Success and verification

- Disposition answers: sufficient (with named extension points) or insufficient (with the missing capability precisely named + crate-boundary justification sketched).
- Evidence: spike demonstrating the binding or the exact failure point; no donor domain math ported into Prism.
- Decision recorded where the architecture lane can consume it (reference, don't duplicate).

## Where

| Surface | Evidence / anchor |
|---|---|
| Tempest donor (report-grade) | `SongBlueprintWidget` — energy bar + drag sliders + preset toolbar (re-scan at promotion — U-ARITH/U-REV) |
| Substrate under test | `DSGraphCanvas`, `GraphEdge`, `WorkflowCanvasStage` (existing) |
| Layer law | `.project/architecture/layer-contracts.md` §§5, 7 (no consumer domain types; model separation) |

## Work

- [ ] Re-read donor widget at execution time; record revision state.
- [ ] Probe `DSGraphCanvas` against curve-editing needs (continuous value lane vs topology nodes) in proof-lab spike.
- [ ] Write disposition: sufficient/insufficient + precise rationale + recommended next task shape (or explicit reject-with-reason).
- [ ] No barrel, no export, no host proof — disposition only.

## Validation

```bash
flutter analyze packages/warp_prism_ui
flutter test packages/warp_prism_ui/test/boundaries/boundary_test.dart
```

Expected: analyze clean; spike (if any) confined to proof-lab; disposition references real probe evidence, not prose preference.

## Gates

- Declared prerequisite: none beyond architecture-lane attention — the HOLD is the missing disposition itself.
- If disposition is build: successor build task requires Task 1874 (F-07) commit-invariant alignment (Set|Scrub typing for drag edits) and second-consumer or macro-review decision before STABLE.
- Parallelizable with: 1850, 1885-construction (disjoint writesets; this task is read-mostly).
