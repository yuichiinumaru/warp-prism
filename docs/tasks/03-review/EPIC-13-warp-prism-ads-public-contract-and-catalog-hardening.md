# EPIC 13 — Warp-Prism ADS Public Contract and Catalog Hardening

> **Planning Status**: Active Epic
> **Executable?**: No — planning artifact only.
> **Promotion Gate**: Promote tasks after EPIC-12 defines the gate matrix and promotion state model.
> **Origin**: Stabilization wave — analysis of 31 `warp_prism_ui` test failures caused by
>   contract drift, gallery compile drift, semantics/state vocabulary drift, and toast async
>   fragility after parallel builder waves.
> **Depends on**: EPIC-01 (ADS), EPIC-12 (gate model), Task 1105 (token/catalog policy).

## Goal

Stabilize `packages/warp_prism_ui` as a governed public contract: resolve the `DS*` vs `Prism*`
namespace split, reconcile component contracts broken by parallel waves, fix gallery compilation,
harden the catalog as a real proof surface, establish golden baselines, and stabilize async
components like Toast. The outcome is a green package gate with boundary tests enforcing purity.

## Source Evidence

- 31 failures in `warp_prism_ui` spanning: `molecules_contract_test` (8 failures),
  `templates_contract_test`, `design_system_gallery_test`, `design_system_accessibility_test`,
  `state_surface_test`, `operational_components_test`, `atoms_contract_test`, `ds_toast_test`
  (7 failures, timing/async).
- `design_system_gallery_sections.dart` has ~200 compilation errors from components added
  out-of-order across parallel waves.
- `DSStateSurface` expanded from 3 to 7 states; old tests expect 3.
- Public barrel exports `DS*` alongside `Prism*` aliases, violating the namespace boundary
  contract.
- Catalog test is smoke-only: `pumpWidget(WarpPrismCatalogApp())` + verify type exists.
- No golden tests exist despite policy (Task 1105) requiring them.

## Scope

- `Prism*` namespace remediation: aliases for all public tokens/state/components, CyberCore
  migrated to `Prism*`, barrel audited.
- Public barrel audit: what is public, what stays in `src/`, what is experimental.
- Component contract reconciliation: atoms, molecules, templates, operational components
  expectations aligned with current implementation.
- Gallery compile cleanup: `design_system_gallery_sections.dart` compiles and all registered
  sections render.
- Catalog contract expansion: all sections registered, no duplicate IDs, state matrix covered,
  layout responsiveness tested, high text scale tested.
- Golden baseline MVP for key atoms, molecules, organisms.
- Accessibility and semantics reconciliation after state vocabulary expansion.
- Toast async lifecycle stabilization (timer, overlay, dispose, queue).
- State vocabulary surface reconciliation (3→7 concrete states, labels, semantics).

## Out of Scope

- Fixing Observatory failures (that is EPIC-14).
- New ADS components or features.
- CyberCore expansion beyond namespace migration.
- Widgetbook adoption (custom catalog remains MVP).

## Candidate Tasks

| Task | Name | Type |
|------|------|------|
| 1301 | Prism Namespace Remediation | remediation |
| 1302 | Public Barrel Audit | governance |
| 1303 | Component Contract Reconciliation | remediation |
| 1304 | Gallery Compile Boundary Cleanup | remediation |
| 1305 | Catalog Contract Expansion | feature |
| 1306 | Golden Baseline MVP | testing |
| 1307 | Accessibility and Semantics Reconciliation | remediation |
| 1308 | Toast Async Lifecycle Stabilization | remediation |
| 1309 | State Vocabulary Surface Reconciliation | remediation |

## Dependencies

- 1301 (Prism namespace) should complete before 1303 (contracts) and 1304 (gallery) because
  namespace cleanup affects exports and test expectations.
- 1304 (gallery) should complete before 1305 (catalog expansion) because the gallery is the
  catalog's source surface.
- 1306 (goldens) depends on 1303 (contracts) being stable.
- 1308 (toast) and 1309 (state vocabulary) can run in parallel with other tasks.

> **Note on task numbering**: The analysis document originally proposed Gallery Compile
> Boundary Cleanup as task 1309 and Catalog Contract Expansion as 1304. During execution,
> Gallery Compile was promoted to 1304 because it is a **real blocker** of the package
> gate (`flutter analyze` and `flutter test` are blocked by gallery compilation errors).
> This reordering shifts Catalog Expansion to 1305 and all subsequent tasks by 1.
> The dependency chain and execution order are unchanged; only the numbering shifted.

## Acceptance Criteria for Epic Completion

- `flutter analyze` in `packages/warp_prism_ui/` passes with zero errors and zero warnings
  (residual info-level acceptable).
- `flutter test` in `packages/warp_prism_ui/` passes with zero failures.
- Public barrel exports only `Prism*` names; `DS*` remains internal/legacy.
- Gallery compiles and all registered sections render without crash.
- Catalog test proves: all sections registered, no duplicate IDs, default/loading/empty/error
  states covered, responsive layout tested.
- At least 5 golden baselines exist for canonical components.
- Toast tests pass deterministically (no timing flakiness).
- `melos run test-boundaries` confirms no `DS*` usage in `apps/cybercore/` and no `src/`
  imports from consumer apps.
- All 31 pre-existing `warp_prism_ui` failures are resolved or explicitly classified with
  justification.
