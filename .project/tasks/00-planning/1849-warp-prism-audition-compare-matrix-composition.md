# Task 1849: Audition/compare matrix composition (F-20) — HOLD

> **Epic:** `EPIC-P2-staged` (Story P2-A). **Source:** backlog F-20 card (§2) + S11-matrix seam (§1).
> **State:** HOLD in `00-planning/`. **Unlock condition:** Task 1868 (F-01) + Task 1871 (F-04) + Task 1872 (F-05) each landed at least EXPERIMENTAL with stable injected-model seams, so this composition has contracts to compose over.
> **Mandate note:** Single-consumer (Warpblade) → ships as EXPERIMENTAL guidance under MISSION §3.1; STABLE only on second descriptor-host adoption.

## Outcome and boundaries

Produce an EXPERIMENTAL composition-guidance package for the audition/compare matrix: Warpblade `TakeTilesPanel` (vertical list, no thumbs/drag/zoom — corrected claims honoured) + `_CompareStrip` SAME|DIFFER + Regenerate-lineage, expressed strictly as composition over `DSVirtualGrid` + `DSLaneBoard` + the F-01 gate + F-04 review framing + F-05 badges. No new table/grid/board primitive (backlog S11 rule). Domain take/generation models stay product-local per domain-leakage law.

Scope: guidance doc + reference composition + one conformance suite. Non-goals: grid virtualization internals, thumbnail pipelines, generation routing, any new `Prism*` primitive beyond compositional wiring.

## Success and verification

- Reference matrix renders injected takes with per-row F-01 gating, SAME|DIFFER strip via F-05, and repair entry via F-04 framing; unknown take state renders fail-closed (F-02 vocabulary), never as success.
- One suite green: gated-row propagation, compare-strip correctness, deterministic ordering, a11y row announcements.
- Boundary clearance: no new layer imports; composition lives in ADS or proof-lab only.

## Where

| Surface | Evidence / anchor |
|---|---|
| Warpblade donor (report-grade) | `TakeTilesPanel` `:139-591`, `_CompareStrip` `:653-741`, Regenerate-lineage `:324-436` (re-verify paths at promotion — backlog U-REV) |
| Prism composition target | `packages/warp_prism_ui/lib/` guidance + proof-lab; `DSVirtualGrid`, `DSLaneBoard` (existing) |
| Composed contracts | Tasks 1868/1871/1872 outputs: `PrismActionGate`, `PrismDecisionReviewSurface`, `PrismLineageStrip` (must exist first — the HOLD) |
| Layer law | `.project/architecture/layer-contracts.md` §§1, 4–5 |

## Work

- [ ] Re-verify Warpblade donor paths/lines at execution time; record revision state (U-REV).
- [ ] Author composition guidance + reference implementation over injected take view-models (no Warpblade types in Prism — layer law §4.6).
- [ ] Port `_CompareStrip` SAME|DIFFER semantics onto F-05 lineage; wire row actions through F-01 with reasons.
- [ ] Ship one conformance suite (gating × compare × determinism × a11y); keep EXPERIMENTAL (no barrel export).
- [ ] Run validation below; record host-proof debt: needs Warpblade weaker-layout exercise before STABLE.

## Validation

```bash
flutter analyze packages/warp_prism_ui
flutter test packages/warp_prism_ui/test/boundaries/boundary_test.dart
flutter test <new-suite-path>
```

Expected: analyze clean; boundary + new suite green; no `DS*` leakage, no consumer-type import.

## Gates

- Declared prerequisite: Tasks 1868 + 1871 + 1872 EXPERIMENTAL landings (whole-outcome premise — composition is meaningless without them).
- MISSION §6 gates 2–7 before any STABLE promotion; second descriptor host before STABLE.
- Parallelizable with: 1850 (disjoint writeset) once unblocked; NOT with 1887/1888 on shared `component-catalog.md` edits (coordinate order).
