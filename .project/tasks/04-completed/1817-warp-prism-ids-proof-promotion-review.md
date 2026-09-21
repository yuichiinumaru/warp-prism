# Task 1817: IDS Proof and Promotion Review

> **Priority**: 🟡 P1 · **Type**: `verification`
> **Origin**: EPIC-20 (S20-05) · Source-Reality Review 2026-09-01
> **Blocks**: Task 1825
> **Depends on**: Task 1815 (IDS Candidate Kernel)

## Milestone Alignment

- **Target milestone**: M01 — Warp Prism v2: L1 Integration-Capable (`docs/milestones.md`)
- **Capability / Gate advanced**: 20-C IDS proof + promotion review (input to the 1825 L1 exit gate)
- **Strategic why**: L1 requires the IDS kernel to be proven against ≥2 real consumers, not just implemented; this task produces that proof and the lifecycle verdict.
- **Consequence if absent**: 1825's IDS audit row has no evidence; EXPERIMENTAL primitives would sit unproven at the L1 gate.

## Non-Goals

- **Do not**: promote any primitive to STABLE here — this review may promote EXPERIMENTAL → PROVEN only; STABLE requires the runtime promotion-gate formula (≥2 distinct consumers OR ≥2 distinct domains, via Task 1821's lifecycle rules).
- **Do not**: redesign kernel primitives — findings route back to 1815 remediation, not ad-hoc rearchitecture.

## Objective

Prove the candidate Interaction Design System (IDS) kernel against at least 2 distinct consumers in `warp_prism_ui` / `apps/` (e.g. `PrismWorkflowCanvasStage` selection and `PrismFilterWorkbench` inspection), verify state machine safety and input contract normalization, and assemble the formal evidence packet for promoting kernel primitives from EXPERIMENTAL to PROVEN status.

## Background Context

### What already exists

- `packages/warp_prism_interaction/` — created in Task 1815 with candidate Selection, Inspection, Command-intent primitives, state machine vocabulary, and input contract.
- Task 1814 interaction inventory providing baseline recurrence mapping.
- `warp_prism_ui` components with ad-hoc selection/inspection callbacks.

### What is missing or broken

- Primitives in `warp_prism_interaction` are tagged EXPERIMENTAL with no end-to-end consumer integration proof.
- No formal promotion review validating recurrence across ≥2 distinct consumers OR ≥2 distinct domains.
- No deterministic tests verifying state machine transitions under invalid/interrupted inputs.

## Subtasks

- [ ] **Read before modifying**: `packages/warp_prism_interaction/lib/`, `packages/warp_prism_ui/lib/src/organisms/workflow_canvas/`, `packages/warp_prism_ui/lib/src/organisms/filter_workbench/`, `docs/architecture/interaction-inventory.md`.
- [ ] **Implement integration test proof**: integrate `SelectionModel` and `InspectionModel` into exactly 2 named consumers: `PrismWorkflowCanvasStage` selection and `PrismFilterWorkbench` inspection (both in `packages/warp_prism_ui`), without modifying component presentation contracts.
- [ ] **Verify state machine invariants**: write adversarial test cases in `packages/warp_prism_interaction/test/` asserting: every illegal transition (from the state machine's transition table) is rejected; disabled-state interaction is a no-op; busy-state timeout produces the documented error state. Full transition-table coverage = every (state, event) pair either transitions or is explicitly rejected.
- [ ] **Audit input contract normalization**: verify pointer, keyboard, and a11y events map to identical intent payloads (same equality result) in widget tests on the Linux desktop host (the repo's CI surface); record any platform that cannot be verified in this environment as an explicit residual risk instead of claiming it.
- [ ] **Produce promotion report**: create `docs/reports/1817-ids-kernel-promotion-review.md` evaluating the promotion criteria (recurrence evidence, API stability, zero domain leakage, pure Dart compliance).
- [ ] **Update lifecycle tags**: if criteria are fully met, promote validated primitives to PROVEN status.
- [ ] **Simplify pass**: remove unnecessary complexity.
- [ ] **Regression verification**: run validation commands below.

## Validation Commands

```bash
flutter analyze packages/warp_prism_interaction
flutter test packages/warp_prism_interaction
dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .
```

## Where

| File | Purpose |
|---|---|
| `packages/warp_prism_interaction/test/` | Create — integration and state machine property tests |
| `docs/reports/1817-ids-kernel-promotion-review.md` | Create — promotion review report + evidence |
| `packages/warp_prism_interaction/lib/` | Modify — lifecycle annotations (EXPERIMENTAL → PROVEN) only |
| `packages/warp_prism_ui/lib/src/organisms/workflow_canvas_stage/` | Modify — wire SelectionModel (the 2 named consumers) |
| `packages/warp_prism_ui/lib/src/organisms/filter_workbench/` | Modify — wire InspectionModel (the 2 named consumers) |

## Exit Conditions

- [ ] The 2 named consumers (`PrismWorkflowCanvasStage`, `PrismFilterWorkbench`) proven against IDS kernel primitives.
- [ ] State machine suite passes: every (state, event) pair covered as transition-or-rejection (transition table fully enumerated).
- [ ] Input contract normalization verified on the Linux host for pointer, keyboard, and a11y; unverifiable platforms recorded as residual risk.
- [ ] Promotion review report committed at `docs/reports/1817-ids-kernel-promotion-review.md`.
- [ ] Boundary checks pass cleanly (pure Dart core preserved).
- [ ] Local changelog entry added.

## Completion Evidence

- **Files created/modified**: docs/reports/1817-ids-kernel-promotion-review.md (promotion review report, 184 lines); packages/warp_prism_interaction/test/{consumer_integration_test,state_machine_adversarial_test,input_normalization_test}.dart; packages/warp_prism_ui/test/organisms/ids_kernel_consumer_proof_test.dart (REAL widget proof); packages/warp_prism_ui/pubspec.yaml (dev_dependency only); packages/warp_prism_interaction/lib (EXPERIMENTAL→PROVEN lifecycle annotations); state machine hardening (transitionTo target validation).
- **Tests or validation commands**: warp_prism_interaction dart test = **104 pass** (46 base + 42 adversarial transition-table + 8 input + 6 consumer-sim + 2 target-enforcement); warp_prism_ui flutter test (proof + organism suites) = **34 pass** incl. 7 real-widget consumer proof tests; boundary harness **9/9 PASS**; lib/ purity grep = 0.
- **Real-contract proof results**: WorkflowCanvasStage — single selection lossless 1:1 (PrismWorkflowSelection ↔ SelectionState); multi-selection vs single-slot finding recorded honestly (kernel multi > widget single-slot; binding maps primarySelection). FilterWorkbench — inspection lifecycle clean; reset-requires-cancel finding recorded (onChanged({}) before onReset → binding must cancel before reset per transition table); stale-query gating via correlation tokens verified.
- **Lifecycle promotions**: Selection/Inspection/Query + state machine + input contract → PROVEN (real-consumer evidence); STABLE withheld (1821 gate).
- **Local changelog entry**: pending parent publication
- **Executor**: gt-builders-engineer-flutter (builder + remediation, 2026-09-01)
- **Completion date**: 2026-09-01
- **Review trail**: independent review FAIL (integration proof was kernel-isolation simulation) → remediated (dev-dep seam + real widget proof + state machine hardening + honest report) → focal re-review **PASS** (7/7 real widget tests; lib/ purity 0; 104/104).
