# Task 1887: Sealed decision views + phase rail + epistemic lens (F-26) — HOLD

> **Epic:** `EPIC-P2-staged` (Story P2-C). **Source:** backlog F-26 card (§2) + Macro §4.5 Sentry W1/W3/W5/W10/W11/W14 rows.
> **State:** HOLD in `00-planning/`. **Unlock conditions:** (1) Task 1871 (F-04 decision-review surface) + Task 1872 (F-05 provenance/lineage) landed EXPERIMENTAL — these views render over them (whole-outcome premise); (2) a real host route identified for at least the phase-rail/episode views (Sentry has no Flutter surface — backlog U-SENTRY; CC/TP review hosts are candidate second proof, to be confirmed at promotion).
> **Mandate note:** Sentry is request-only signal, never host proof. Decision/episode/hypothesis models stay in Sentry core; Prism renders views only.

## Outcome and boundaries

Render Sentry-requested views as ADS compositions over landed trust primitives: dual-authority panes + advisory framing (W1), lens badge (W3), episode closure (W5), hypothesis card (W10), SEAL legal-act marker (W11), phase rail (W14). All compositional: sealed mode = absence-of-affordance (F-05 rule), verdict pass-through integrity (F-04 rule — unknown≠pass), witness/provenance badges (F-05). Lens ontology is domain-heavy → needs second-consumer evidence before STABLE; ship lens badge EXPERIMENTAL only.

Scope: view compositions + suite over F-04/F-05 seams. Non-goals: any Sentry domain model in Prism (domain-leakage law), clock/five-clock ontology (W4 belongs to F-07 clocks, not here), STABLE promotion without a real host.

## Success and verification

- Each view renders from injected view-models with zero Sentry types in Prism packages (boundary check).
- Sealed views expose no action affordances (sealed-rendering conformance); verdict pass-through never renders unknown as pass; tooltip-reason per verdict (F-04 gate inherited).
- Lens badge ships EXPERIMENTAL with recorded second-consumer debt.

## Where

| Surface | Evidence / anchor |
|---|---|
| Request source (DECLARED, report-grade) | Macro §4.5 W1/W3/W5/W10/W11/W14 rows; `sentry-requests-prism-verification-2026-10-20.md` (re-check at promotion) |
| Composed contracts | F-04 `PrismDecisionReviewSurface`, F-05 badges/lineage + sealed rule (the HOLD) |
| Candidate host routes | CC/TP review surfaces (to be confirmed — U-SENTRY) |
| Layer law | `.project/architecture/layer-contracts.md` §§4–5 (no consumer domain types, bidirectional) |

## Work

- [ ] Confirm F-04/F-05 seams at execution time; build strictly against their injected models.
- [ ] Implement views (dual-authority, advisory framing, lens badge, episode closure, hypothesis card, SEAL marker, phase rail) with no Sentry-type leakage.
- [ ] Suite: sealed-absence, pass-through integrity, badge correctness, determinism; a11y announcements.
- [ ] Run validation below; keep EXPERIMENTAL; record host-route + lens second-consumer debt.

## Validation

```bash
flutter analyze packages/warp_prism_ui
flutter test packages/warp_prism_ui/test/boundaries/boundary_test.dart
flutter test <new-suite-path>
```

Expected: analyze clean; boundary check 14 (no consumer domain types) green; suite green.

## Gates

- Declared prerequisites: F-04 + F-05 EXPERIMENTAL landings.
- STABLE gates: real host route exercised (AGENTS §7.1) + second-consumer evidence for lens + MISSION §6 gates 2–7.
- Parallelizable with: 1888 once both unblocked (distinct views, disjoint writesets); coordinate shared-registry edits in task order.
