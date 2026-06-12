# Task 1303: Component Contract Reconciliation

> **Status**: `[x]` Builder Done
> **Review State**: Open — unstarted task; lane mismatch (should be in 01-open/)
> **Priority**: 🔴 P0
> **Type**: `remediation`
> **Origin**: EPIC-13, stabilization wave, 8 failures in molecules_contract_test,
>   plus failures in atoms_contract_test, templates_contract_test, operational_components_test.
> **Blocks**: 1304, 1305, 1306
> **Depends on**: 1301 (Prism namespace), 1201 (failure baseline inventory)

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1303` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

Reconcile component contract tests in `packages/warp_prism_ui/` so that test
expectations match the current implementation. This involves fixing API drift
(renamed parameters, changed enums, missing exports) rather than updating tests
to accept broken behavior.

## Background Context

### What already exists

- Contract tests: `atoms_contract_test.dart`, `molecules_contract_test.dart`,
  `templates_contract_test.dart`, `operational_components_test.dart`.
- Failures are caused by: renamed properties (e.g., `semanticDescription` →
  `semanticLabel`), changed enum variants, missing exports, new components
  added without updating contract tests.

### What is missing or broken

- Contract tests expect old API shapes.
- Some exports are missing from barrel files.
- The contract tests are correct in intent (they catch drift) but stale in
  expectation.

---

## Test Requirements

- Contract tests pass for atoms, molecules, templates, and operational components.
- All public classes are exported in their respective barrel files.
- Test expectations match the current API, not a historical API.

---

## Exit Conditions

- [x] `atoms_contract_test.dart` passes with zero failures.
- [x] `molecules_contract_test.dart` passes with zero failures.
- [x] `templates_contract_test.dart` passes with zero failures.
- [x] `operational_components_test.dart` passes with zero failures.
- [x] All public classes are exported in their barrel files.
- [x] Local changelog entry added under `docs/changelog/`.
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: Read all 4 contract test files
  and the corresponding barrel files (atoms.dart, molecules.dart, etc.).
  Read the actual component implementations to understand current API.
- [x] For each failing test, determine: is the test wrong (stale expectation)
  or is the code wrong (missing export/implementation)?
- [x] Fix accordingly: update test expectations or fix missing exports.
- [x] Add any missing barrel exports for new components.
- [x] Run all 4 contract tests and verify zero failures.
- [x] **Simplicity pass**: do not refactor components. Only fix drift.
- [x] **Regression verification**: run `flutter test` in the package.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/test/atoms/atoms_contract_test.dart` | Read / Modify — fix expectations |
| `packages/warp_prism_ui/test/molecules/molecules_contract_test.dart` | Read / Modify — fix expectations |
| `packages/warp_prism_ui/test/templates/templates_contract_test.dart` | Read / Modify — fix expectations |
| `packages/warp_prism_ui/test/molecules/operational_components_test.dart` | Read / Modify — fix expectations |
| `packages/warp_prism_ui/lib/src/atoms/atoms.dart` | Read / Modify — fix missing exports |
| `packages/warp_prism_ui/lib/src/molecules/molecules.dart` | Read / Modify — fix missing exports |
| `packages/warp_prism_ui/lib/src/organisms/organisms.dart` | Read / Modify — fix missing exports |
| `packages/warp_prism_ui/lib/src/templates/templates.dart` | Read / Modify — fix missing exports |

### How

1. Read each contract test and compare expectations with current implementation.
2. Identify the specific drift (renamed parameter, changed enum, missing export).
3. Fix the test or the export.
4. Run the test.
5. Repeat for each contract test.

### Why

Contract tests are the backbone of ADS stability. When they fail, builders
cannot trust that their changes are safe. When they pass incorrectly (because
someone just commented them out), the ADS has no integrity. The goal is green
tests that reflect the real contract.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not update tests to accept broken behavior. If a test catches a real
> regression, fix the code, not the test.

> [!IMPORTANT]
> This task fixes drift. It does NOT redesign APIs. Do not rename components,
> change parameter names, or restructure barrel files beyond fixing missing
> exports.

---

## Validation Commands

```bash
flutter test packages/warp_prism_ui/test/atoms/atoms_contract_test.dart
flutter test packages/warp_prism_ui/test/molecules/molecules_contract_test.dart
flutter test packages/warp_prism_ui/test/templates/templates_contract_test.dart
flutter test packages/warp_prism_ui/test/molecules/operational_components_test.dart
```

---

## Completion Evidence

- **Files created/modified**:
  - `packages/warp_prism_ui/test/atoms/atoms_contract_test.dart` — Fixed AnimatedBuilder count assertion
  - `packages/warp_prism_ui/test/molecules/molecules_contract_test.dart` — Wrapped DSSearchBar tests in Scaffold; updated DSStateType count 3→7
  - `packages/warp_prism_ui/test/templates/templates_contract_test.dart` — Set surface size for detail/search tests; fixed History text count; changed TextField finder to DSSearchBar
  - `packages/warp_prism_ui/test/molecules/operational_components_test.dart` — Fixed Semantics label lookup to use widget predicate
  - `packages/warp_prism_ui/test/state_surface_test.dart` — Updated DSStateType count 3→7
  - `packages/warp_prism_ui/lib/src/molecules/ds_search_bar.dart` — Added controller listener for clear button rebuild
- **Tests or validation commands**:
  - `flutter test test/atoms/atoms_contract_test.dart` — PASS (46 tests)
  - `flutter test test/molecules/molecules_contract_test.dart` — PASS (54 tests)
  - `flutter test test/templates/templates_contract_test.dart` — PASS (8 tests)
  - `flutter test test/molecules/operational_components_test.dart` — PASS (63 tests)
  - `flutter test test/state_surface_test.dart` — PASS (20 tests)
  - `flutter test test/atoms/atoms_contract_test.dart test/molecules/molecules_contract_test.dart test/templates/templates_contract_test.dart test/molecules/operational_components_test.dart test/state_surface_test.dart` — PASS (191 tests, 0 failures)
  - `dart analyze` on all changed files — 0 errors, 0 warnings (3 pre-existing info-level hints)
- **Local changelog entry**: `docs/changelog/20260609-230000-1303-component-contract-reconciliation-builders.md`
- **Agent-wiki / docs institutionalization**: N/A
- **Executor**: builders
- **Completion date**: 2026-06-09
