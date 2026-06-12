# Task 1307: Accessibility and Semantics Reconciliation

> **Status**: `[x]` Builder Done
> **Priority**: 🟡 P1
> **Type**: `remediation`
> **Origin**: EPIC-13, stabilization wave, failures in `design_system_accessibility_test.dart`.
> **Blocks**: Future ADS component promotion
> **Depends on**: 1303 (contract reconciliation), 1309 (state vocabulary)

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1307` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

Fix accessibility and semantics test failures in `packages/warp_prism_ui/` so
that interactive components have correct semantic labels, focus traversal, and
contrast after the state vocabulary expansion.

## Background Context

### What already exists

- `packages/warp_prism_ui/test/accessibility/design_system_accessibility_test.dart`
  validates semantic labels, disabled states, and focus on components like DSChip
  and DSFilterChipGroup.
- Failures likely stem from: renamed semantic properties (e.g.,
  `semanticDescription` → `semanticLabel`), changed state vocabulary affecting
  semantics, and new interactive components without semantics tests.

### What is missing or broken

- Accessibility test expectations are stale after component API changes.
- Some interactive components may lack semantic labels.
- Focus traversal expectations may not match current widget tree.

---

## Test Requirements

- `design_system_accessibility_test.dart` passes with zero failures.
- All interactive components (buttons, chips, cards, search bars, filters)
  have semantic labels.
- Focus traversal is verified for at least the shell, sidebar, and search bar.

---

## Exit Conditions

- [x] `design_system_accessibility_test.dart` passes with zero failures.
- [x] All interactive components have semantic labels (verified by test).
- [x] Focus traversal tests pass for shell navigation.
- [x] Local changelog entry added under `docs/changelog/`.
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: Read
  `packages/warp_prism_ui/test/accessibility/design_system_accessibility_test.dart`
  and the component implementations it tests.
- [x] Identify each failing test and determine root cause (renamed property,
  changed widget tree, missing semantics).
- [x] Fix test expectations to match current implementation.
- [x] If a component is missing semantic labels, add them.
- [x] Verify focus traversal for shell, sidebar, and search bar.
- [x] **Simplicity pass**: fix drift, do not redesign accessibility strategy.
- [x] **Regression verification**: run accessibility tests.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/test/accessibility/design_system_accessibility_test.dart` | Read / Modify — fix expectations |
| `packages/warp_prism_ui/lib/src/atoms/ds_chip.dart` | Read / possibly modify — semantic labels |
| `packages/warp_prism_ui/lib/src/molecules/ds_filter_chip_group.dart` | Read / possibly modify |
| `packages/warp_prism_ui/lib/src/molecules/ds_search_bar.dart` | Read / possibly modify |

### How

1. Read the accessibility test and identify failures.
2. Compare test expectations with current component implementations.
3. Fix accordingly.
4. Run tests.

### Why

Accessibility is a promotion gate per Task 1105. If accessibility tests fail,
no component can be promoted. Fixing these failures unblocks the promotion path.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not remove accessibility tests. If a test is no longer relevant, replace
> it with a relevant one, do not delete it.

---

## Validation Commands

```bash
flutter test packages/warp_prism_ui/test/accessibility/
```

---

## Completion Evidence

- **Files created/modified**:
  - `packages/warp_prism_ui/lib/src/atoms/ds_chip.dart` — added `explicitChildNodes: true` and `ExcludeSemantics` wrapper
  - `packages/warp_prism_ui/lib/src/molecules/ds_filter_chip_group.dart` — added `explicitChildNodes: true` and `ExcludeSemantics` wrapper to `_FilterChip`
  - `packages/warp_prism_ui/lib/src/organisms/ds_sidebar.dart` — added `explicitChildNodes: true` and `ExcludeSemantics` wrapper to `_SidebarItemWidget`
- **Tests or validation commands**:
  - `flutter test test/accessibility/design_system_accessibility_test.dart` → **PASS** (13/13, was 10/13)
  - `flutter analyze` → **0 errors** (pre-existing info/warnings only, none introduced)
- **Root cause**: `Semantics(label: 'X')` wrapping subtrees containing `Text('X')` caused label doubling (`'X\nX'`) due to implicit semantics merging. `find.bySemanticsLabel` does exact matching, so doubled labels failed.
- **Fix pattern**: Standard Flutter `Semantics` + `ExcludeSemantics` pattern — outer `Semantics` provides the label/flags/button state, inner content wrapped in `ExcludeSemantics` prevents the `Text` widget from contributing a duplicate semantics node. Added `explicitChildNodes: true` to prevent child semantics from merging into the parent.
- **Local changelog entry**: `docs/changelog/2026-06-09-task-1307-accessibility-semantics-reconciliation.md`
- **Agent-wiki / docs institutionalization**: recorded via agent-wiki
- **Executor**: builders
- **Completion date**: 2026-06-09
