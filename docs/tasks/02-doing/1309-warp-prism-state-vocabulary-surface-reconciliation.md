# Task 1309: State Vocabulary Surface Reconciliation

> **Status**: `[ ]` Open
> **Priority**: 🟡 P1
> **Type**: `remediation`
> **Origin**: EPIC-13, stabilization wave, DSStateSurface expanded from 3 to 7
>   states, breaking state_surface_test and related tests.
> **Blocks**: 1307 (accessibility), future component promotion
> **Depends on**: 1303 (contract reconciliation)

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1309` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

Reconcile the operational state vocabulary expansion so that DSStateSurface,
its tests, its semantics labels, and the gallery are all consistent with the
expanded state set (7 concrete states).

## Background Context

### What already exists

- Task 1118 expanded operational state vocabulary from 3 to 14+ canonical states.
- `DSStateSurface` now uses 7 concrete states (empty, loading, error, success,
  degraded, disabled, stale — approximate).
- Tests still expect the old 3-state model.
- Semantics labels may reference old state names.

### What is missing or broken

- `state_surface_test.dart` expects old state set.
- Gallery sections may reference old state names.
- Semantic labels may be inconsistent with new vocabulary.

---

## Test Requirements

- `state_surface_test.dart` passes with zero failures.
- All 7 concrete states render correctly.
- Semantic labels match the expanded vocabulary.

---

## Exit Conditions

- [x] `state_surface_test.dart` passes with zero failures.
- [x] All 7 concrete states are tested (render + verify visual).
- [x] Semantics labels match the current operational state enum.
- [x] Gallery section for state surface covers all 7 states.
- [x] Local changelog entry added under `docs/changelog/`.
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: Read
  `packages/warp_prism_ui/lib/src/molecules/ds_state_surface.dart`,
  `packages/warp_prism_ui/lib/src/tokens/ds_operational_state.dart`,
  `packages/warp_prism_ui/test/state_surface_test.dart`.
- [x] Identify every failing assertion and determine: stale expectation or
  real bug.
- [x] Update test expectations to match the 7-state model.
- [x] Verify semantics labels for each state match the enum.
- [x] Update gallery section if it references old state names.
- [x] **Simplicity pass**: update expectations, do not redesign the state model.
- [x] **Regression verification**: run state_surface_test and accessibility tests.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/test/state_surface_test.dart` | Read / Modify — fix expectations |
| `packages/warp_prism_ui/lib/src/molecules/ds_state_surface.dart` | Read — current implementation |
| `packages/warp_prism_ui/lib/src/tokens/ds_operational_state.dart` | Read — state enum |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` | Read / possibly modify |

### How

1. Read the state enum and the state surface implementation.
2. Read the test file and identify each failure.
3. Update test expectations to match the 7-state model.
4. Verify semantics labels.
5. Update gallery if needed.

### Why

The state vocabulary is the foundation of every operational component. If the
tests expect 3 states and the code has 7, no builder can trust state-related
tests. This reconciliation makes the state model trustworthy.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not reduce the state vocabulary back to 3 states. The expansion to 7+
  was intentional. Fix the tests, not the model.

---

## Validation Commands

```bash
flutter test packages/warp_prism_ui/test/state_surface_test.dart
```

---

## Completion Evidence

- **Files created/modified**:
  - `test/state_surface_test.dart` — added 18 new widget tests for all 7 DSStateType variants
  - `lib/src/gallery/design_system_gallery_sections.dart` — expanded State Surfaces section to show all 7 variants
  - `lib/src/gallery/design_system_gallery_page.dart` — removed duplicate `buildOperationalStatesSection()` call
  - `docs/changelog/2026-06-09-task-1309-state-vocabulary-surface-reconciliation-builders.md`
- **Tests or validation commands**:
  - `flutter test test/state_surface_test.dart` — 38 tests, PASS
  - `flutter test test/tokens/ds_operational_state_test.dart test/molecules/operational_components_test.dart` — 133 tests, PASS
  - Combined run of all 3 files — 171 tests, PASS
  - `dart analyze` on all audited/modified files — 0 errors, 0 warnings (333 info-level lints, all pre-existing)
- **Local changelog entry**: `docs/changelog/2026-06-09-task-1309-state-vocabulary-surface-reconciliation-builders.md`
- **Agent-wiki / docs institutionalization**: N/A
- **Executor**: builders
- **Completion date**: 2026-06-09
