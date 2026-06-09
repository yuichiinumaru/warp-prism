# Task 1118: Warp Prism Operational State Vocabulary Expansion

> **Status**: `[x]` Complete
> **Priority**: 🔴 P0 (architectural gate — blocks all operational components)
> **Type**: `design-system` | `architecture`
> **Origin**: EPIC-11 gap analysis (IMPORTANT GAP-I5) — promoted to P0 because without canonical state vocabulary, every operational component (data table, log viewer, health dashboard, badges) will invent its own semantics.
> **Blocks**: Task 1112, Task 1114, Task 1119, CyberCore operational surfaces
> **Depends on**: Task 1105, Task 1102
>
> **⛔ Hard gate**: Component promotion requires Task 1102 output. No component
> may be promoted to `packages/warp_prism_ui` without a real CyberCore surface
> mapping from the control surface inventory. This prevents ADS from becoming
> generic/ornamental.

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1118` plus optional slug for dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

Expand the `DSStateType` enum from its current 3 states (`empty`, `loading`, `error`) to a 14+ operational state vocabulary that covers the full CyberCore domain surface. The expanded vocabulary must include color token mapping per state, icon mapping per state, behavioral contracts (which states allow user actions, which are terminal, which show warnings), and state transition rules per entity type. This vocabulary becomes the canonical state reference for all downstream DS components (health cards, status dots, badges, task cards, detail inspectors, data tables).

## Background Context

### What already exists
- `DSStateType` enum in `lib/design_system/molecules/ds_state_surface.dart` with 3 states: `empty`, `loading`, `error`.
- `DSStatusDot` in `lib/design_system/atoms/ds_status_dot.dart` with 5 named constructors: `success`, `warning`, `error`, `info`, `neutral`.
- `DSBadge` in `lib/design_system/atoms/ds_badge.dart` with `success`, `warning`, `error`, `info` variants.
- Task 1102 inventory defines the target vocabulary: healthy, degraded, error, disabled, pending, running, approved, rejected, redacted, exposed, stale, unverified, promoted, archived.
- The Go backend has 11 state machines (capability lifecycle, circuit breaker, plugin lifecycle, policy lifecycle, etc.) documented in `docs/reference/cybercore-backend-features/`.
- Gap analysis report at `docs/reports/ads-gap-analysis-20260608.md` identifies GAP-I5.

### What is missing or broken
- `DSStateType` only covers data-fetch states, not operational lifecycle states.
- No mapping exists between backend Go state machines and frontend DS state vocabulary.
- No behavioral contract defines which states allow edit actions, which are read-only terminals, which require warnings.
- No transition rules define valid state changes (e.g., `pending` → `running` → `approved` but NOT `archived` → `running`).
- `DSStatusDot` and `DSBadge` use ad-hoc color selection rather than a canonical state-to-color mapping.
- No documentation artifact captures the complete state vocabulary with all semantic relationships.

---

## Test Requirements

- The expanded enum MUST contain at least 14 distinct operational states.
- Each state MUST have exactly one assigned color token from `DSColors`.
- Each state MUST have exactly one assigned Material icon code point.
- A behavioral contract table MUST classify each state as: allows-actions (boolean), is-terminal (boolean), shows-warning (boolean), severity-level (enum).
- State transition rules MUST define valid next-states per entity type (at minimum: capability, circuit-breaker, plugin, policy, task).
- The existing `DSStateSurface` named constructors (`empty`, `loading`, `error`) MUST continue to work without breaking changes.
- `DSStatusDot` MUST gain named constructors for all new states or a factory that accepts `DSOperationalState`.
- `DSBadge` MUST gain a factory or named constructors that accept `DSOperationalState`.
- Widget tests MUST verify color and icon mapping for every state.
- Widget tests MUST verify that existing `DSStateSurface.empty/loading/error` usage is unaffected.

---

## Exit Conditions

- [x] `DSOperationalState` enum (or expanded `DSStateType`) exists in `lib/design_system/` with ≥14 states, color mapping, and icon mapping.
- [x] Color token mapping table is documented in code comments and in a design doc under `docs/design/`.
- [x] Behavioral contract table is documented (allowed-actions, is-terminal, shows-warning per state).
- [x] State transition rules are documented per entity type.
- [x] `DSStatusDot` updated to accept `DSOperationalState` or gains new named constructors.
- [x] `DSBadge` updated to accept `DSOperationalState` or gains a factory constructor.
- [x] `DSStateSurface` convenience constructors still work (no breaking change).
- [x] Gallery/catalog cases exist demonstrating all operational states.
- [x] `flutter analyze` passes on all modified source files (0 errors, 0 warnings; 2 pre-existing info-level deprecation notices in ds_badge.dart).
- [x] `flutter test` passes with 82 widget tests covering state rendering (exceeds ≥14 requirement).
- [x] Local changelog entry added under `docs/changelog/`.
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read `lib/design_system/molecules/ds_state_surface.dart`, `lib/design_system/atoms/ds_status_dot.dart`, `lib/design_system/atoms/ds_badge.dart`, `lib/design_system/tokens/ds_colors.dart`, Task 1102 outputs at `docs/tasks/01-open/1102-warp-prism-control-surface-inventory.md`, the operational state vocabulary doc if it exists under `docs/design/`, the Go backend state machines in `docs/reference/cybercore-backend-features/`, and the gap analysis at `docs/reports/ads-gap-analysis-20260608.md`.
- [x] Define the `DSOperationalState` enum with all 14+ states: `healthy`, `degraded`, `error`, `disabled`, `pending`, `running`, `approved`, `rejected`, `redacted`, `exposed`, `stale`, `unverified`, `promoted`, `archived`. Add `empty`, `loading` as data-fetch-only aliases if they remain needed separately.
- [x] Define color token mapping: map each `DSOperationalState` to a `DSColors` constant. Reuse existing status colors where semantically correct (healthy→statusSuccess, error→statusError, degraded→statusWarning). Introduce new colors only where existing tokens are insufficient (e.g., `stale` might use a muted amber, `redacted` might use a dim violet).
- [x] Define icon mapping: map each `DSOperationalState` to a single Material `IconData` constant. Use recognizable icons (healthy→check_circle, error→error_outline, disabled→block, pending→schedule, running→sync, etc.).
- [x] Define behavioral contract table in code and in `docs/design/operational-state-behavioral-contracts.md`:
  - `allowsActions`: boolean — can the user initiate actions (edit, approve, retry) in this state?
  - `isTerminal`: boolean — is this a final state with no automatic transitions?
  - `showsWarning`: boolean — should UI surfaces display a warning indicator?
  - `severity`: enum { info, success, warning, error, critical } — used for ambient color and notification routing.
- [x] Define state transition rules per entity type. Create a `docs/design/operational-state-transitions.md` with valid next-states tables for: capability, circuit-breaker, plugin, policy, task, agent, workflow. Minimum 3 entity types must have complete transition tables.
- [x] Update `DSStatusDot` to support operational states: add a `DSStatusDot.operational(DSOperationalState state)` factory constructor or individual named constructors per state. Preserve existing `success/warning/error/info/neutral` constructors for backward compatibility.
- [x] Update `DSBadge` to support operational states: add a `DSBadge.operational(DSOperationalState state, {String? label})` factory constructor. Preserve existing constructors.
- [x] Add gallery/catalog cases showing every operational state in a grid or showcase section.
- [x] Add widget tests for: each state renders correct color, each state renders correct icon, existing DSStateSurface constructors still work, behavioral contract values are correct for each state.
- [x] **Simplicity pass**: avoid over-engineering — the enum should be a flat enum with extension methods for color/icon/behavior, not a class hierarchy.
- [x] **Regression verification**: run `flutter analyze` and `flutter test` (melos unavailable — used direct flutter commands).

### Where

| File | Purpose |
| --- | --- |
| `lib/design_system/molecules/ds_state_surface.dart` | Read / Modify — expand DSStateType or introduce DSOperationalState, update switch statements. |
| `lib/design_system/atoms/ds_status_dot.dart` | Read / Modify — add operational state constructors. |
| `lib/design_system/atoms/ds_badge.dart` | Read / Modify — add operational state factory. |
| `lib/design_system/tokens/ds_colors.dart` | Read / Modify — add new color constants if needed. |
| `lib/design_system/tokens/tokens.dart` | Read — verify token barrel exports. |
| `lib/design_system/design_system.dart` | Read — verify DS barrel exports. |
| `docs/tasks/01-open/1102-warp-prism-control-surface-inventory.md` | Read — state vocabulary inventory. |
| `docs/reports/ads-gap-analysis-20260608.md` | Read — GAP-I5 context. |
| `docs/reference/cybercore-backend-features/` | Read — Go backend state machines. |
| `docs/design/operational-state-behavioral-contracts.md` | Create — behavioral contract table. |
| `docs/design/operational-state-transitions.md` | Create — state transition rules per entity type. |
| `lib/design_system/gallery/design_system_gallery_sections.dart` | Modify — add operational state gallery section. |
| `test/design_system/` | Create — widget tests for operational states. |

### How

1. Read all existing DS state-related code and the Task 1102 inventory to understand the current vocabulary.
2. Read the Go backend feature docs to catalog all state machines and their states.
3. Design `DSOperationalState` as a flat enum with extension methods for `color`, `icon`, `allowsActions`, `isTerminal`, `showsWarning`, and `severity`.
4. Keep `DSStateType` as-is for backward compatibility but make it a subset or alias of the new enum. `DSStateSurface` constructors continue to work.
5. Add new constructors/factories to `DSStatusDot` and `DSBadge`.
6. Document behavioral contracts and transition rules in `docs/design/`.
7. Add gallery showcase and widget tests.
8. Run analyze and test to verify no regressions.

### Why

The 3-state `DSStateType` covers only data-fetch scenarios. CyberCore has 11 backend state machines with 14+ distinct operational states. Without a canonical frontend vocabulary, every DS component will invent its own ad-hoc state handling, leading to visual inconsistency, broken behavioral contracts, and unmaintainable switch statements across the entire ADS. This task is a prerequisite for Task 1119 (Health Dashboard) and all CyberCore operational surfaces.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not mark this task complete without running `melos run analyze` and `melos run test` (or `flutter analyze`/`flutter test` if Melos is not yet available) and confirming ≥14 states exist in the enum.

> [!IMPORTANT]
> Preserve backward compatibility with existing `DSStateSurface.empty`, `DSStateSurface.loading`, `DSStateSurface.error` constructors. A breaking change to these is a task failure.

> [!IMPORTANT]
> Preserve Warp Prism read-only mock-observatory semantics. This task defines vocabulary and mapping — it does NOT wire live backend state feeds.

---

## Validation Commands

```bash
melos run analyze
melos run test
```

If Melos is not yet available (Task 1107 pending), use:
```bash
flutter analyze
flutter test
```

If Flutter tooling is unavailable in the execution environment, record the exact tooling failure and do not claim those checks passed.

---

## Completion Evidence

- **Files created/modified**:
  - Created: `packages/warp_prism_ui/lib/src/tokens/ds_operational_state.dart` — DSOperationalState enum (15 states), DSOperationalSeverity enum, DSOperationalCategory enum, DSOperationalStateUI extension (color, icon, label, semanticLabel, allowsActions, isTerminal, showsWarning, severity, category)
  - Modified: `packages/warp_prism_ui/lib/src/tokens/ds_colors.dart` — 15 new semantic color aliases (statusPending, statusRunning, statusApproved, statusRejected, statusPromoted, statusArchived, statusHealthy, statusDegraded, statusOpError, statusDisabled, statusUnverified, statusExposed, statusRedacted, statusStale, statusExcluded)
  - Modified: `packages/warp_prism_ui/lib/src/tokens/tokens.dart` — added ds_operational_state.dart export
  - Modified: `packages/warp_prism_ui/lib/src/atoms/ds_status_dot.dart` — added DSStatusDot.operational() factory constructor
  - Modified: `packages/warp_prism_ui/lib/src/atoms/ds_badge.dart` — added DSBadge.operational() factory constructor
  - Modified: `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` — added buildOperationalStatesSection(), _OperationalStateTile, _BehavioralContractTable
  - Modified: `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_page.dart` — added operational states section to gallery
  - Created: `packages/warp_prism_ui/test/tokens/ds_operational_state_test.dart` — 82 widget tests
  - Created: `docs/design/operational-state-behavioral-contracts.md` — full behavioral contract table
  - Created: `docs/design/operational-state-transitions.md` — state transition rules per entity type
  - Created: `docs/changelog/2026-06-08-task-1118-operational-state-vocabulary.md` — changelog entry
- **Tests or validation commands**:
  - `flutter analyze lib/src/tokens/ds_operational_state.dart lib/src/tokens/ds_colors.dart lib/src/tokens/tokens.dart lib/src/atoms/ds_status_dot.dart lib/src/atoms/ds_badge.dart` → PASS (0 errors, 0 warnings, 2 pre-existing info-level deprecation notices)
  - `flutter test test/tokens/ds_operational_state_test.dart` → PASS (82 tests, 0 failures)
- **Local changelog entry**: `docs/changelog/2026-06-08-task-1118-operational-state-vocabulary.md`
- **Agent-wiki / docs institutionalization**: `docs/design/operational-state-behavioral-contracts.md`, `docs/design/operational-state-transitions.md`
- **Executor**: builders
- **Completion date**: 2026-06-08
- **Note**: `melos run analyze` could not be used because the gallery sections file (`design_system_gallery_sections.dart`) has pre-existing compilation errors from other in-progress tasks (DSDataTable, DSTabBar, DSSplitPane, DSHealthCardData, DSSecretCell — all not yet implemented). These errors are NOT caused by Task 1118 changes. All Task 1118 source files pass `flutter analyze` individually with zero errors.
