# Task 1888: Authority explainer + partial-fill remainder views (F-27) — HOLD

> **Epic:** `EPIC-P2-staged` (Story P2-C). **Source:** backlog F-27 card (§2) + Macro W8/W9 rows.
> **State:** HOLD in `00-planning/`. **Unlock condition:** Task 1868 (F-01 capability gate) landed EXPERIMENTAL (explainer renders over the capability gate — whole-outcome premise). The W9 remainder further needs runtime-architect review: `AsyncCommand` remainder/terminal-for-dispatch has a runtime-contract implication, not just ADS presentation.
> **Mandate note:** Sentry request-only; CC/WB gated-action hosts are the real proof surfaces.

## Outcome and boundaries

Render the authority explainer (W8 — why an action is allowed/constrained/denied, over F-01 `ActionAvailability`/`CapabilityState`) and the partial-fill remainder views (W9 — terminal-for-dispatch remainder presentation). Explainer is pure ADS over F-01; remainder ships only with the runtime-review disposition on `AsyncCommand` remainder semantics recorded.

Scope: two view compositions + suite + runtime-review question for remainder. Non-goals: capability evaluation (consumer-side), `AsyncCommand` redesign (review decides; this task records and follows), any Sentry model in Prism.

## Success and verification

- Explainer renders allow/constrain/deny + propagated reason for injected capability states; denied-never-hidden, disabled-with-reason, a11y announced (F-01 gates inherited).
- Remainder views present partial-fill + terminal-for-dispatch honestly (indeterminate excluded from goldens); runtime disposition on remainder semantics recorded before remainder construction.
- Boundary clearance: ADS-only views; any runtime-contract touch requires the review verdict first.

## Where

| Surface | Evidence / anchor |
|---|---|
| Request source (DECLARED, report-grade) | Macro W8/W9 rows (re-check at promotion) |
| Composed contract | F-01 gate + authority outcome (the HOLD) |
| Runtime question | `AsyncCommand` remainder/terminal-for-dispatch — `packages/warp_prism_runtime/` owner + runtime-architect review |
| Proof hosts | CC `_GatedAction` richest impl + WB gates (report-grade; re-verify — U-REV) |
| Layer law | `.project/architecture/layer-contracts.md` §§1–3 (runtime carries semantics, never presentation policy) |

## Work

- [ ] Confirm F-01 seam at execution time; pose remainder question to runtime-architect lane and record disposition.
- [ ] Implement explainer + remainder views over injected models (no consumer/Sentry types).
- [ ] Suite: reason propagation, denied≠hidden, partial-fill honesty, determinism, a11y.
- [ ] Run validation below; keep EXPERIMENTAL; record host-proof debt (CC + WB exercise per AGENTS §7.1).

## Validation

```bash
flutter analyze packages/warp_prism_ui packages/warp_prism_runtime
flutter test packages/warp_prism_ui/test/boundaries/boundary_test.dart
flutter test packages/warp_prism_runtime/test/purity_test.dart
flutter test <new-suite-path>
```

Expected: analyze clean; runtime purity held if remainder touches contracts; suite green.

## Gates

- Declared prerequisites: F-01 EXPERIMENTAL landing; runtime-architect disposition for the W9 remainder half (construction on remainder waits for it).
- STABLE gates: CC + WB host exercise + MISSION §6 gates 2–7.
- Parallelizable with: 1887 once both unblocked (disjoint views); runtime-review question may be posed early, in parallel with any unblocked P2 work.
