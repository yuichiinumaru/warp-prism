# Task 1826: HealthSourceBinding (Contracts → UI Closure)

> **Priority**: 🟡 P1 · **Type**: `feature`
> **Origin**: Task 1821 named gap (HealthSource has no UI binding) + Task 1825 open item
> **Blocks**: 1830 check 16/17 closure sanity (binding completeness)
> **Depends on**: Task 1820 (Bindings Proof PASS)

## Milestone Alignment

- **Target milestone**: M01 — Warp Prism v2: L1 Integration-Capable (`docs/milestones.md`)
- **Capability / Gate advanced**: closes the last contracts→UI surface gap — HealthSource currently has only fake + FRB consumption, zero binding-level projection.
- **Strategic why**: 1821's honest gap ("HealthSource fails Item 4 per-contract") and 1825's open item both require this binding for the runtime layer to be fully demonstrable in the UI.
- **Consequence if absent**: HealthSource remains the thinnest contract — no Prism presentation mapping, weakest of the 4.

## Objective

Create `HealthSourceBinding` in `packages/warp_prism_bindings/` projecting the `HealthSource` runtime contract (snapshot/watch/freshness) into Prism health-cell view-models consumable by `PrismProviderHealthMatrix`-style surfaces, matching the established binding pattern (view-models out, presentation policies stay in widgets).

## Scope

- Read `packages/warp_prism_bindings/lib/src/graph_source_binding/` + `event_stream_binding/` for the established pattern (deterministic projection, `notifyListeners`, disposal).
- Read `packages/warp_prism_runtime/lib/src/health_source/` (contract + models).
- Implement: `HealthSourceBinding` (snapshot→view-model map, watch→incremental refresh, freshness display data, worst-state rollup reuse), view-model type, lifecycle/disposal.
- Tests: fake-driven (warp_prism_testkit FakeHealthSource) — ≥8 tests, mirror the existing binding suites' rigor.
- Purge law: no polling/retry in the binding (composition-owned).
- @experimental on all publics.

## Validation Commands

```bash
cd packages/warp_prism_bindings && flutter analyze . && flutter test .
cd ../.. && dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .   # 13/13
```

## Where

| File | Purpose |
|---|---|
| `packages/warp_prism_bindings/lib/src/health_source_binding/` | Create — binding + view-model |
| `packages/warp_prism_bindings/test/` | Extend — health binding tests |

## Exit Conditions

- [ ] HealthSourceBinding implemented (snapshot + watch + freshness projection).
- [ ] ≥8 tests pass via fakes.
- [ ] Zero polling/retry owned by the binding.
- [ ] Boundary harness 13/13 still PASS.
- [x] Local changelog entry proposed in packet.

## Completion Evidence

- **Files created**: packages/warp_prism_bindings/lib/src/health_source_binding/{health_source_binding,health_source_view_model}.dart + test/health_source_binding_test.dart; barrel + boundary_isolation_test extended.
- **Public API** (@experimental on all): HealthSourceBinding (initialize/refresh/checkFreshness/dispose + viewModel/lastSnapshot/status/error/isStale/isFresh/cells/providers/modelStream/snapshotStream), HealthSourceViewModel (fromSnapshot factory, cellById/cellsForProvider/cellsForDimension, toProviderHealthProviders/Cells projection), HealthSourceBindingStatus, HealthSourceMappers (HealthState↔PrismOperationalState, cell→PrismProviderHealthCell).
- **Contracts→UI closure**: all 4 runtime contracts now have bindings (EventStream, GraphSource, AsyncCommand, HealthSource — the 1821 named gap closed). Layer law: bindings MAY import ui (GraphSourceBinding precedent; layer-contracts §2).
- **Tests**: flutter analyze clean; flutter test = **43/43** (10 new: initial projection, watch refresh, rollup, freshness/stale, watch-error resilience, disposal, empty snapshot).
- **Purge law**: grep Timer.periodic|retry in binding = 0.
- **Local changelog entry**: pending parent publication
- **Executor**: gt-builders-engineer-flutter (2026-09-02)
- **Completion date**: 2026-09-02
- **Review trail**: bundled independent review (post-L1 wave) **PASS 98/100** — pattern conformance, layer legality confirmed, watch-error resilience verified, 43/43 re-run.
