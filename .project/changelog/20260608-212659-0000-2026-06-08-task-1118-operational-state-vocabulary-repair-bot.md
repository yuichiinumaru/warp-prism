---
date: 20260608-212659
timestamp: 20260608-212659
agent: repair-bot
task: "1118"
description: "Changelog — 2026-06-08"
is_rebuild_safe: true
---

# Changelog — 2026-06-08

## Task 1118: Operational State Vocabulary Expansion

**Type**: design-system | architecture
**Scope**: `packages/warp_prism_ui` (tokens, atoms, gallery)

### What changed

- **New token file**: `lib/src/tokens/ds_operational_state.dart`
  - `DSOperationalState` enum with 15 states across 4 categories:
    - Lifecycle: pending, running, approved, rejected, promoted, archived
    - Health: healthy, degraded, error, disabled
    - Verification: unverified, exposed, redacted
    - Governance: stale, excluded
  - `DSOperationalSeverity` enum (info, success, warning, error, critical)
  - `DSOperationalCategory` enum (lifecycle, health, verification, governance)
  - `DSOperationalStateUI` extension with color, icon, label, semanticLabel,
    allowsActions, isTerminal, showsWarning, severity, and category getters

- **DSColors expanded**: 15 new semantic color aliases (statusPending, statusRunning,
  etc.) reusing existing palette tokens. No new hex values.

- **DSStatusDot expanded**: New `DSStatusDot.operational(state)` factory constructor
  accepting any `DSOperationalState`. Existing named constructors preserved.

- **DSBadge expanded**: New `DSBadge.operational(state)` factory constructor
  accepting any `DSOperationalState`. Existing named constructors preserved.

- **Gallery expanded**: New "Operational States" section showing all 15 states
  with tiles, badges, status dots, and behavioral contract table.

- **Barrel export**: `ds_operational_state.dart` added to `tokens.dart`.

- **Design docs**:
  - `docs/design/operational-state-behavioral-contracts.md` — full contract table
  - `docs/design/operational-state-transitions.md` — transition rules per entity type

### What did NOT change

- `DSStateType` enum (empty/loading/error) — preserved for backward compatibility.
- `DSStateSurface` — all constructors work as before.
- No breaking changes to any existing API.

### Tests

- `test/tokens/ds_operational_state_test.dart` — 70+ tests covering:
  - Enum completeness (15 states, 4 categories)
  - Color mapping for all 15 states
  - Icon mapping for all 15 states
  - Behavioral contracts (allowsActions, isTerminal, showsWarning, severity)
  - Category classification
  - DSStatusDot.operational() rendering
  - DSBadge.operational() rendering
  - DSColors semantic aliases
  - Backward compatibility with DSStateType, DSStateSurface, DSStatusDot, DSBadge
