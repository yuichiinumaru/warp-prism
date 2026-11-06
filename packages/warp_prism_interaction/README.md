# warp_prism_interaction

> **Status**: EXPERIMENTAL (candidate Interaction Design System kernel)
> **Layer**: IDS (pure Dart interaction semantics)
> **Charter / Governance**: `.project/architecture/layer-contracts.md` · `.project/architecture/package-topology.md`

## Overview

`warp_prism_interaction` provides framework-agnostic interaction semantics and state models for Warp Prism operational user interfaces. It sits between presentation components (`warp_prism_ui`) and runtime contracts (`warp_prism_runtime`).

## Admitted Scope (Recurrence-Proven)

Per empirical interaction inventory (`.project/architecture/interaction-inventory.md` §2, §7):

- **Selection model** (`lib/src/selection/`): Immutable `SelectionState<T>` (single / multiple / none), `SelectionChangeEvent<T>`, anchor tracking, and `SelectionNotifier<T>` bus. Subsumes local, controlled, and controller-driven selection patterns.
- **Inspection model** (`lib/src/inspection/`): `InspectionIntent<T>`, `InspectionPayload<T>`, `InspectionLifecycle` (`proposed`, `active`, `dismissed`), and `InspectionNotifier<T>`.
- **Query model** (`lib/src/query/`): `QueryIntent` (raw search string + structured filters as pure data), `QueryStatus` (`idle`, `running`, `complete`, `error`, `cancelled`), `QueryResultReference<T>`, and `QueryController<T>`.
- **State machine vocabulary** (`lib/src/state_machine/`): `InteractionState` enum, `InteractionTransitionTable`, and `InteractionStateMachine` with explicit validation and rejection of illegal state transitions.
- **Normalized input contract** (`lib/src/input/`): `InputIntent` hierarchy (`PointerIntent`, `KeyboardIntent`, `A11yIntent`), `InputModifiers`, and `InputNormalizer` mapping raw descriptions to semantic intents.

## Deferred Primitives (Candidate Ledger)

The following candidates remain deferred until ≥2 distinct consumers / domains exhibit recurrence:
- **Command-intent**: 3 divergent gallery-only implementations; zero application adoption.
- **Navigation-intent**: Reduces to item selection + application-owned routing (`GoRouter`).
- **Viewport-state**: Spatial camera, temporal window, and virtualization offsets are presentation mechanics local to specific widgets (`GraphCanvas`, `VirtualScroll`), not shared IDS semantics.

## Invariants & Purity

- **Pure Dart Core**: `lib/` has zero dependencies on `package:flutter`, `dart:ui`, or native FFI.
- **Lifecycle**: All public declarations carry `EXPERIMENTAL` status until formal promotion review.
