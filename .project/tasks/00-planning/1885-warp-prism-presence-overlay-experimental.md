# Task 1885: Presence overlay EXPERIMENTAL on fake room model (F-24)

> **Epic:** `EPIC-P2-staged` (Story P2-B). **Source:** backlog F-24 card (§2) + EV-H6 donor seam.
> **State:** Materialized in `00-planning/`; construction NOT held (fake-room-model gate allows EXPERIMENTAL build). **STABLE promotion gated:** first real multi-user host must exist (backlog U-DAG; no such host today).
> **Mandate note:** No current multi-user host → EXPERIMENTAL proof-lab only; HOLD STABLE until host adoption.

## Outcome and boundaries

Build `PrismPresenceOverlay` as an EXPERIMENTAL ADS overlay proven against a fake room model: glide scaling, idle-name fold, per-user colour (stable-hash), culling behaviour — with glide/culling determinism proven by suite. No real presence backend, no identity/auth, no networking in Prism; room membership is an injected fake model.

Scope: overlay + fake room model + conformance suite. Non-goals: any backend binding, user identity, STABLE/barrel, host proof (impossible without the host — recorded as debt, not attempted).

## Success and verification

- Overlay renders N injected presences with stable-hash colours, glide transitions, idle fold, and culling past the declared cap — all deterministic under seeded fake (no wall-clock/golden flakiness; indeterminate frames excluded per F-02 determinism rule).
- Suite covers glide determinism, culling order, colour stability across rebuilds, a11y (presence never colour-only).
- Boundary clearance: ADS-only, pure-Dart fake model, no IO/network imports.

## Where

| Surface | Evidence / anchor |
|---|---|
| Donor seam | EV donor H6 (glide scaling, idle fold, per-user colour, culling) — inspiration only, never demand |
| Prism target | `packages/warp_prism_ui/lib/` overlay (EXPERIMENTAL, no barrel export) + proof-lab fake room model |
| Layer law | `.project/architecture/layer-contracts.md` §§1, 4 (ADS presentation-only; no backend logic) |

## Work

- [ ] Define injected presence view-model (stable-hash colour input, idle state, viewport slot) — no identity types.
- [ ] Implement overlay (glide, idle fold, culling) + fake room model with seeded determinism.
- [ ] Conformance suite (glide/culling/colour-stability/a11y); keep EXPERIMENTAL.
- [ ] Run validation below; record STABLE debt: first multi-user host + host-composition proof (AGENTS §7.1).

## Validation

```bash
flutter analyze packages/warp_prism_ui
flutter test packages/warp_prism_ui/test/boundaries/boundary_test.dart
flutter test <new-suite-path>
```

Expected: analyze clean; suite green across repeated runs (seed determinism); boundary clean.

## Gates

- No declared construction prerequisite. STABLE gate (explicit): first multi-user host exists + host-composition proof + MISSION §6 gates 2–7.
- Parallelizable with: 1850, 1852 (disjoint writesets).
