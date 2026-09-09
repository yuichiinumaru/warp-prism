# Task 1821: Runtime Promotion-Gate Evidence Pack

> **Priority**: 🟡 P1 · **Type**: `verification`
> **Origin**: EPIC-21 (S21-04) · Source-Reality Review 2026-09-01
> **Blocks**: Task 1825
> **Depends on**: Task 1820 (Bindings Proof)

## Milestone Alignment

- **Target milestone**: M01 — Warp Prism v2: L1 Integration-Capable (`docs/milestones.md`)
- **Capability / Gate advanced**: 21-D promotion-gate evidence pack (input to the 1825 L1 exit gate)
- **Strategic why**: L1 must ship contracts with explicit lifecycle status (PROPOSED→EXPERIMENTAL→PROVEN→STABLE); this pack is the auditable record of that classification.
- **Consequence if absent**: 1825's contract-status audit row has no evidence; contracts would sit ambiguously between EXPERIMENTAL and STABLE.

## Objective

Assemble and document the comprehensive promotion evidence pack for the candidate runtime contracts (`EventStream`, `HealthSource`, `GraphSource`, `AsyncCommand`) under the lifecycle progression model (`PROPOSED -> EXPERIMENTAL -> PROVEN -> STABLE`), auditing the 7-item Definition of Done, verifying recurrence evidence, and ensuring complete layer boundary compliance before integration lab execution.

## Background Context

### What already exists

- `packages/warp_prism_runtime/` — runtime contracts (from Task 1819).
- `packages/warp_prism_testkit/` — fakes and contract test suites (from Task 1819).
- `packages/warp_prism_bindings/` — bindings proof (from Task 1820).
- `docs/architecture/layer-contracts-v2.md` — layer laws and promotion criteria.

### What is missing or broken

- No formal promotion-gate evaluation document exists assessing the contracts against the 7-item Definition of Done.
- Contracts currently reside in EXPERIMENTAL status and require formal classification of recurrence and readiness.

## Subtasks

- [ ] **Read before modifying**: `packages/warp_prism_runtime/`, `packages/warp_prism_testkit/`, `packages/warp_prism_bindings/`, `docs/architecture/layer-contracts-v2.md`.
- [ ] **Audit 7-item Definition of Done**:
  1. Contract interface definition is backend-agnostic and presentation-purged.
  2. Contract compliance test suite exists in `warp_prism_testkit`.
  3. In-memory reference fake implementation passes 100% of compliance tests.
  4. At least one UI binding in `warp_prism_bindings` demonstrates practical consumption.
  5. Error, cancellation, and stream lifecycle invariants are verified.
  6. Boundary test verifies zero Flutter/UI imports in runtime and zero domain type leakage.
  7. Lifecycle status and promotion rationale are documented.
- [ ] **Classify contract lifecycle status**: evaluate recurrence evidence for each contract (EventStream, GraphSource, AsyncCommand, HealthSource). Note: single-domain recurrence qualifies for EXPERIMENTAL; ≥2 distinct domains required for STABLE.
- [ ] **Produce evidence report**: create `docs/reports/1821-runtime-contracts-promotion-evidence.md`.
- [ ] **Simplify pass**: remove unnecessary complexity.
- [ ] **Regression verification**: run validation commands below.

## Validation Commands

```bash
flutter analyze packages/warp_prism_runtime packages/warp_prism_testkit packages/warp_prism_bindings
flutter test packages/warp_prism_runtime packages/warp_prism_testkit packages/warp_prism_bindings
dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .
```

## Where

| File | Purpose |
|---|---|
| `docs/reports/1821-runtime-contracts-promotion-evidence.md` | Create — runtime contracts promotion evidence pack |
| `packages/warp_prism_runtime/lib/` | Review / adjust lifecycle annotations if justified |

## Exit Conditions

- [ ] 7-item Definition of Done audited with evidence for each runtime contract.
- [ ] Lifecycle status explicitly classified for all 4 contracts (none prematurely marked STABLE).
- [ ] Boundary tests pass 100% with zero domain leakage.
- [ ] Promotion evidence report committed at `docs/reports/1821-runtime-contracts-promotion-evidence.md`.
- [ ] Local changelog entry added.

## Completion Evidence

- **Files created**: docs/reports/1821-runtime-contracts-promotion-evidence.md (186 lines, file:line-cited). ZERO packages modified (anti-goal honored).
- **Per-contract lifecycle verdicts**: ALL 4 contracts (EventStream, HealthSource, GraphSource, AsyncCommand) → **HOLD @ EXPERIMENTAL**. Rationale: zero app-level contract consumers (grep warp_prism_runtime in apps/*/lib = 0 across 124 dart files); §3.2 PROVEN requires ≥2 distinct CONSUMER applications/domains (1817 precedent counted operational app domains, not in-stack scaffolding); pattern recurrence ≠ contract consumption. AsyncCommand noted as strongest PROVEN candidate post-1824+adoption; HealthSource weakest (no binding, no real surface).
- **7-item DoD audit**: 1-7 all PASS with named gaps: Item 4 per-contract gap (HealthSource has no binding — grep 0); Item 5 named gaps (EventStream pause(resumeSignal)/cancelOnError untested; AsyncCommand re-entrancy/CommandTimeoutError contract-level untested; GraphSource watchUpdates error path; HealthSource watch-error untested); Item 6 boundary 10/10 + domain leakage 0.
- **Cross-cutting finding (routed to 1825)**: packages/warp_prism_adapter_frb/lib/src/*.dart carries ZERO @experimental annotations (vs runtime 47, testkit 8, bindings 11) — layer-law §3.2 unmet in adapter; must be remediated before 1825 check 12. Also routed: whether in-stack architectural domains satisfy §3.2 (1825 gate owner rules).
- **Tests or validation commands**: testkit 53/53 PASS; boundary harness 10/10 PASS; runtime purity 2/2 PASS; bindings 33/33 PASS; grep flutter/dart:ui in runtime lib = 0; domain tokens runtime+testkit = 0; @experimental runtime = 47 (13 files); flutter analyze all 3 packages = No issues found (reviewer-verified).
- **Local changelog entry**: pending parent publication
- **Executor**: gt-architects-architect-general (builder session, 2026-09-01)
- **Completion date**: 2026-09-01
- **Review trail**: independent review **PASS 89/100 CONDITIONAL** — every material claim re-derived and verified (0 app consumers non-vacuous across 124 files; HOLD-at-EXPERIMENTAL confirmed as the only rulable reading — in-stack scaffolding cannot self-certify PROVEN; deferral to 1825 ruled honest, not dodging); HIGH finding: changelog entry missing (parent closeout action); LOW: annotation count 47→46/12-files off-by-one (report footnote), analyze not recorded in §6 (reviewer re-ran: clean).
