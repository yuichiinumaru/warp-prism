# Task 1850: Descriptor-driven disclosure form pattern (F-21)

> **Epic:** `EPIC-P2-staged` (Story P2-A). **Source:** backlog F-21 card (§2) + WB-U9/EV-M3/FG descriptor seams (§1 S11).
> **State:** Materialized in `00-planning/`; no HOLD — no hard prerequisite. Promotable to `01-open` when the P2 wave reaches it (sequencing preference, not a gate).
> **Mandate note:** Single-consumer (Warpblade `GenerationDrawer`) → EXPERIMENTAL extension pattern under MISSION §3.1.

## Outcome and boundaries

Establish the descriptor-driven disclosure form as a `DSAccordion` + `DSSelect` extension pattern: Warpblade `GenerationDrawer` (3-level disclosure, descriptor-iterated controls skipping `prompt`, uint + `FormatException` handling, route-preview slot) generalized to injected descriptors. No new form primitive; descriptor schema stays product-local (domain-leakage law).

Scope: extension pattern + reference composition + suite. Non-goals: descriptor-schema ownership, prompt/computation logic, route-preview implementation.

## Success and verification

- Reference form builds 3-level disclosure purely from injected descriptors; `prompt`-skip, uint-parse-failure, and preview-slot behaviours covered by suite.
- Parse/validation failures render fail-closed with reason (F-02 vocabulary); no stack-trace render (leak-negative).
- Boundary clearance: ADS-only, no runtime/adapter imports.

## Where

| Surface | Evidence / anchor |
|---|---|
| Warpblade donor (report-grade) | `GenerationDrawer` `:5-552`, uint handling `:81-134` (re-verify at promotion — U-REV) |
| Prism extension target | `DSAccordion`, `DSSelect` (existing ADS); proof-lab reference |
| Layer law | `.project/architecture/layer-contracts.md` §§1, 4–5 |

## Work

- [ ] Re-verify donor paths at execution time; record revision state.
- [ ] Author extension pattern (descriptor → accordion/select wiring, skipped-key rule, parse-failure presentation).
- [ ] Reference composition + suite (disclosure depth, descriptor iteration, failure presentation, determinism).
- [ ] Run validation below; keep EXPERIMENTAL (no barrel export).

## Validation

```bash
flutter analyze packages/warp_prism_ui
flutter test packages/warp_prism_ui/test/boundaries/boundary_test.dart
flutter test <new-suite-path>
```

Expected: analyze clean; boundary + new suite green.

## Gates

- No declared prerequisite. Sequencing preference only: after P1 filter/form work (F-12) so per-type-editor conventions align — do not dress as a blocking gate.
- MISSION §6 gates 2–7 before STABLE; second-host adoption before STABLE.
- Parallelizable with: 1849, 1852-disposition-read, 1885-construction (disjoint writesets).
