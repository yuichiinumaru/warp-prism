# Task 1815: IDS Candidate Kernel (Selection/Inspection/Query)

> **Priority**: 🔴 P0 · **Type**: `feature`
> **Origin**: EPIC-20 (S20-01 kernel half + S20-02 + S20-03) · Source-Reality Review 2026-09-01 · **Scope amended 2026-09-01 per Task 1814 inventory evidence + independent review endorsement**
> **Blocks**: Task 1817, Task 1820
> **Depends on**: Task 1814 (interaction inventory — COMPLETED 2026-09-01, review PASS)

## Milestone Alignment

- **Target milestone**: M01 — Warp Prism v2: L1 Integration-Capable (`docs/milestones.md`)
- **Capability / Gate advanced**: 20-B IDS candidate kernel (the interaction-semantics layer of L1)
- **Strategic why**: L1 needs a reusable interaction vocabulary above ADS; the kernel is the substrate 1817 proves and 1820 binds.
- **Consequence if absent**: interaction semantics stay ad-hoc per component (>100 `selected` usages persist); 1820 has nothing to bind.

## Scope Amendment (evidence-driven, 2026-09-01)

Task 1814's inventory (independently reviewed PASS) found: **Selection RECURRENCE_PROVEN** (20+ impls, 4 payload classes, 3 app domains), **Inspection RECURRENCE_PROVEN** (6 impls, observatory + gallery), **Query RECURRENCE_PROVEN** (6+ impls across cybercore live-log filtering + observatory workspace search = 2 distinct domains). **Command-intent is DEFERRED** (3 divergent shapes, gallery-only, zero app adoption — candidate ledger). The kernel therefore admits **Selection + Inspection + Query**. Command-intent stays OUT of the kernel until recurrence evidence exists (2 distinct consumers/domains per AGENTS.md §5).

## Non-Goals

- **Do not**: implement this inside `warp_prism_ui` — the IDS kernel lives in its own `packages/warp_prism_interaction/` package (presentation purity law).
- **Do not**: build a framework/Redux/state-management system — kernel primitives only.
- **Do not**: admit Command-intent, Navigation-intent, or Viewport-state — they are DEFERRED by inventory evidence (candidate ledger, see `docs/architecture/interaction-inventory.md` §7).
- **Do not**: tag anything STABLE — all primitives EXPERIMENTAL until 1817's promotion review.

## Boundary-Check Numbering Note

"Check 13" (`warp_prism_interaction is pure Dart`) follows the numbering plan in the source-reality review §F (checks 10–17: 10 = rehex advisory, 11 = ui↔FRB, 12 = runtime Flutter-free, 13 = interaction pure Dart, 14 = bindings not imported by ui, 15 = adapter isolation, 16 = domain leakage, 17 = generated files). The authoritative numbered list lives in `docs/architecture/layer-contracts-v2.md` (Task 1811 output); if numbering drifts, that doc governs.

## Objective

Implement the candidate Interaction Design System (IDS) kernel in a dedicated package `packages/warp_prism_interaction/` (pure Dart core + optional Flutter gestures adapter), containing ONLY primitives with validated recurrence evidence from Task 1814: Selection, Inspection, Query (see Scope Amendment). State machine vocabulary and normalized input contract included.

## Background Context

### What already exists

- `DSInteractiveSurface` = per-widget mechanics only (focus, keyboard, semantics, cursor, touch target) — reuse as mechanics layer (`ds_interactive_surface.dart:16-145`).
- Selection is ad-hoc (>100 `selected` usages, 10+ bespoke callback patterns); only `DSWorkflowSelection` is a dedicated payload class (`ds_workflow_canvas_stage.dart:370-402`).
- No shared selection/inspection model exists.
- Task 1814 provides the empirical interaction inventory.

### What is missing or broken

- No shared Selection/Inspection state model.
- No interaction state machine vocabulary (idle/active/busy/disabled/error/success).
- No input contract (pointer/keyboard/a11y → intent mapping).

## Subtasks

- [ ] **Read before modifying**: `ds_interactive_surface.dart`, `graph_canvas.dart`, `workflow_canvas_stage.dart`, `log_viewer.dart`, `execution_console.dart`, `docs/architecture/interaction-inventory.md` (output of Task 1814).
- [ ] **Create `packages/warp_prism_interaction/`** package (pure Dart core, no Flutter dependency in core; gestures adapter in separate file if needed).
- [ ] **Define Selection model**: shared selection state (single/multi-select), selection bus, selection payload. Experimental status.
- [ ] **Define Inspection model**: inspection intent, inspection payload. Experimental status.
- [ ] **Define Query**: query state model (search/filter intent, query payload, result-set reference). Experimental status. (Command-intent is DEFERRED per inventory evidence — do not implement it.)
- [ ] **Define state machine vocabulary**: idle/active/busy/disabled/error/success + transitions.
- [ ] **Define input contract**: pointer/keyboard/a11y → normalized intent schema.
- [ ] **Add boundary harness check**: `warp_prism_interaction is pure Dart` (PHASED — add when package exists).
- [ ] **Lifecycle tagging**: all primitives tagged EXPERIMENTAL (not STABLE barrel).
- [ ] **Simplify pass**: remove unnecessary complexity.
- [ ] **Regression verification**: run validation commands.

## Validation Commands

```bash
flutter analyze packages/warp_prism_interaction
flutter test packages/warp_prism_interaction
dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .
```

## Where

| File | Purpose |
|---|---|
| `packages/warp_prism_interaction/` | Create — experimental IDS kernel |
| `packages/warp_prism_interaction/lib/src/selection/` | Selection model |
| `packages/warp_prism_interaction/lib/src/inspection/` | Inspection model |
| `packages/warp_prism_interaction/lib/src/query/` | Query model (search/filter semantics) |
| `packages/warp_prism_interaction/lib/src/state_machine/` | State machine vocabulary |
| `packages/warp_prism_interaction/lib/src/input/` | Input contract |

## Exit Conditions

- [ ] Package created with pure Dart core (Flutter only where gestures required).
- [ ] Selection, Inspection, Query primitives implemented with state machine vocabulary.
- [ ] Input contract defines pointer/keyboard/a11y → intent mapping.
- [ ] All primitives tagged EXPERIMENTAL (not in stable public barrel).
- [ ] Boundary harness check 13 ready to enable.
- [ ] Local changelog entry added.

## Completion Evidence

- **Files created**: `packages/warp_prism_interaction/` (31 files: pubspec, analysis_options, README, public barrel, 5 src modules with sub-barrels, 6 test suites). Registered in root pubspec workspace.
- **Public API** (all @experimental-tagged): Selection (SelectionMode/Source, immutable SelectionState<T> single/multi/toggle/anchor, SelectionChangeEvent, SelectionNotifier bus); Inspection (Intent, Lifecycle proposed/active/dismissed, Payload, Notifier); Query (Intent with structured filters-as-data, ResultReference, Status idle/running/complete/error/cancelled, Controller with cancellation + out-of-order token protection); State machine (InteractionState enum + TransitionTable + StateMachine with illegal-transition rejection); Input contract (sealed InputIntent: Pointer/Keyboard/A11y + InputNormalizer interface, pure-data descriptors — no flutter import).
- **Scope amendment honored**: Selection+Inspection+Query admitted; Command-intent/Navigation/Viewport NOT implemented (deferred per inventory §7).
- **Tests or validation commands**:
  - `dart analyze .` → No issues found!
  - `dart test .` → **46 tests, all passed** (13 selection, 8 inspection, 11 query, 6 state machine, 7 input, 1 purity)
  - `dart test test/purity_test.dart` → passed (0 package:flutter imports in lib/)
  - `grep -rc "package:flutter" lib/` → 0 files
  - boundary harness → **8/8 PASS, 0 FAIL** (no regression)
- **Local changelog entry**: pending parent publication
- **Executor**: gt-builders-engineer-flutter (builder session, 2026-09-01)
- **Completion date**: 2026-09-01
- **Review trail**: 2026-09-01 independent review FAIL (typedefs missing @experimental) → remediated (5 files: SelectionListener/InspectionListener/QueryListener typedefs + inspectionTransitionTable/queryTransitionTable consts annotated; full package sweep) → focal re-review PASS (38/38 public declarations annotated; dart analyze clean; 46/46 tests pass).
