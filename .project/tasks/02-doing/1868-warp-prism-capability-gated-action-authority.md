# Task 1868: Capability-gated action + authority outcome (F-01)

> **Epic**: [EPIC-P0-trust-core](../epics/EPIC-P0-trust-core.md) · **Story**: [P0-S01](../stories/P0-S01-authority-vocabulary.md)
> **Source**: `.project/research/final-upgrade-backlog-2026-11-01.md` F-01 (I=125, seam S1) — WB-U1, TP U-06/U-07, CC W1-A/I-1, EV §5-item-6, Macro P0-1/C11.
> **Priority**: P0 · **Parallelizable with**: Task 1869, Task 1875 (disjoint writesets: IDS+gate molecule vs token/molecule vs transport organism).

Four independent re-inventions (WB null-callback sites, CC `_GatedAction`/`PermissionSection`/`AbortSection`, TP `onPressed:null` sites, Sentry W8/W9) prove one missing semantic: an action whose capability is absent must render disabled-with-reason, never hidden-as-not-applicable, and terminal-for-dispatch refusals must carry their reason to the caller.

## Outcome and boundaries

Land IDS `ActionAvailability`/`CapabilityState` (pure Dart, `packages/warp_prism_interaction`) with authority outcome `allow | constrain(reason) | deny(reason)`, plus ADS molecule `PrismActionGate` (`packages/warp_prism_ui`) that presents the outcome: enabled, disabled-with-reason (a11y announced), never hidden. Extends `DSOperationalState` only for the generic allow/constrain/deny vocabulary. Lands EXPERIMENTAL — spec + fake + suite, no barrel export.

Non-goals: capability *evaluation* (product-local); proposal computation; palette/registry work (Task 1870); no STABLE promotion in this task.

## Where

| Path | Why |
|---|---|
| `packages/warp_prism_interaction/lib/src/input/` | Eligibility/availability semantics home (new module beside `input_intent.dart`) |
| `packages/warp_prism_interaction/lib/src/inspection/inspection_state.dart` | Neighbor availability-adjacent state; do not duplicate its vocabulary |
| `packages/warp_prism_ui/lib/src/tokens/ds_operational_state.dart` | Generic allow/constrain/deny extension point |
| `packages/warp_prism_ui/lib/src/molecules/` | `PrismActionGate` molecule home (new file) |
| `packages/warp_prism_ui/test/boundaries/boundary_test.dart` | Add the new contract's purity check in this task (layer law §10) |
| `docs/bridge/command-center/prism-gap-components.md` | Richest donor (`_GatedAction`) — re-verify `control_panel.dart:49-138` citations live; INHERITED-REPORT until read |

## Work

- [ ] Re-verify donor citations live (CC `control_panel.dart` gated-action block; WB/TP null-callback sites are report-grade — confirm shape, record revision-UNKNOWN provenance).
- [ ] Implement IDS availability module: outcome type, reason propagation, denied≠hidden≠enabled invariant; pure-Dart conformance suite (fail-closed: missing capability ⇒ deny-with-reason, never silent enable).
- [ ] Implement `PrismActionGate` molecule: consumes outcome, renders disabled-with-reason with semantics announcement; terminal-for-dispatch refusal surfaces reason.
- [ ] Fake/reference + conformance suite green; determinism (no time/random in outcome resolution).
- [ ] Boundary harness check added; `dart format` + `flutter analyze` clean on touched packages.
- [ ] Host proof: exercise on command-center (richest impl) + Warpblade weaker layout; record real-host evidence per AGENTS §7.1 (interact, no framework errors, focus/theme intact).

## Success and verification

Success = authority outcome exists in IDS with reason propagation, gate molecule renders all three outcomes with a11y announcements, denied is never hidden, and the MISSION §6 gates applicable here hold: (2) fake/reference passing the suite, (3) conformance green, (4) boundary clearance, (5) host-composition proof CC+WB, (7) independent review. STABLE-only gates (barrel/API freeze) are explicitly deferred.

```bash
dart format --set-exit-if-changed packages/warp_prism_interaction/lib packages/warp_prism_ui/lib/src/molecules
flutter analyze packages/warp_prism_interaction packages/warp_prism_ui
flutter test packages/warp_prism_interaction/test packages/warp_prism_ui/test/boundaries/boundary_test.dart
```

Expected evidence: suite output green, boundary harness green, host-exercise log with the affected CC route + interaction, reviewer verdict recorded.

## Context / reliance

Depends on nothing (foundation task). Feed-out: Task 1870 consumes the eligibility shape (construction may start on this task's established interface once frozen; integration waits for its functioning implementation); Task 1871 and Task 1874 consume the outcome type. U-IDS review input: whether availability semantics belong in IDS without making it a state-management framework — batch with F-03/F-06/F-07 proposals into one IDS review.

## Parent verification — 2026-11-01 (builders lane, post-worker return)

- **Worker**: `gtb-engineer-flutter` via User-authorized `opencode run` (`opencode-go/muse-spark-1.3-contributor`), shell `sh_196c9bcac0014soDyZZdM9WpkA`. Handoff `status: complete` received; full packet in shell output (not copied here).
- **Filesystem check**: 6 new files present (`action_availability.dart` + test, `ds_action_authority.dart` + test, `ds_action_gate.dart` + test); `boundary_test.dart` modified additive-only; no barrel/alias exports added (grep over `molecules.dart`/`tokens.dart`/`prism_aliases.dart`/interaction lib empty — EXPERIMENTAL holds).
- **Parent re-run (fresh, after return)**: `dart format --set-exit-if-changed` on the 6 files → 0 changed exit 0; `flutter test packages/warp_prism_interaction/test` → 193 pass exit 0; `dart boundary_test.dart` → 22/22 PASS exit 0 (includes Task 1869 concurrent checks, no interference).
- **Not re-run by parent**: widget suites (gate 16/16, tokens 90/90, molecule-contract 62/62) — worker-fresh green output accepted as evidence input; full re-proof belongs to independent review.
- **Known residual**: real-host CC+WB exercise deferred by worker (hosts outside workspace boundary + headless env); headless sweep 6/6 zero framework errors substituted with exact limitation recorded. Pre-existing `DSButton` Row overflow at 360×640 @2.0× with long labels noted as atom-owner follow-up, out of scope.
- **Lane**: stays in `02-doing/`; submission move belongs to the authorized actor after independent review. Independent review (MISSION §6 gate 7) still required — NOT self-granted.

## Review Ledger — 2026-11-06 (independent bundled review, BUILDER_CONTEXT)

- **Reviewer**: fresh `gtr-reviewer-flutter` session `ses_e51da4820ffebdCKhZVV4JlJNR` (independent — did not build). Report: `.project/reports/reviewers/20261106-000803-review-task-1868-capability-gated-action-authority.md`.
- **Verdict**: AMEND (82/100 diagnostic). No code defect assigned.
- **Accepted package evidence**: format 0-changed; interaction suite 281 pass; focused analyzer on touched paths clean; EXPERIMENTAL containment (no barrel/alias exports); shared boundary run 81/81 PASS (reviewer-executed, current tree).
- **Non-blocking note**: task prose names the molecule `PrismActionGate`; landed implementation/tests consistently use `DSActionGate` and satisfy the presentation contract. Nomenclature only.
- **Blockers (no builder remediation requested)**:
  - B1 (external): task-required real CC+WB host exercise unavailable — named hosts are outside the workspace boundary and this environment is headless. Package/headless evidence explicitly not treated as named-host proof.
  - B2 (baseline owner): literal full-package `flutter analyze` exits non-zero on the pre-existing 226-issue baseline; focused touched-path analysis is clean and no diagnostic is assigned to this task. Disposition belongs to the analyzer-baseline owner, not this builder.
- **Lane**: stays in `02-doing/` pending B1/B2 disposition or an authorized acceptance decision. No promotion claimed.

## Gate update — 2026-11-06

- B2's literal gate is now green: package-wide `dart analyze` exits 0 (225 infos, 0 warnings/errors) after the 1860 import fix. B2 collapses to a non-blocking baseline-hygiene note for the baseline owner. B1 (external CC/WB host proof) is the sole remaining acceptance item.
