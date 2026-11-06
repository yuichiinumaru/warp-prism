# HOLD-warp-prism-host-proof-protocol (EPIC-A S1)

> **Planning Status**: Strategically Deferred
> **Promotion Gate**: program acceptance (`PLAN-warp-prism-future-capability-program.md`) + host-exercise owner bandwidth + one cooperating consumer host identified (Warpblade or Tempest governance).
> **Reason held**: spec-first sequencing — the protocol must exist before any candidate (G4–G7) can claim host proof; no consumer commitment yet; writing it now would guess host constraints.
> **Promotion target**: `01-open` when gate met AND `AGENTS.md` §3.1 readiness holds.
> **Type**: `governance` | **Origin**: Phase 1 inventory G1 + review PASS `ses_edbfcec4dffeX44ZMBOaLDsRWR`
> **Depends on**: Phase 1 PASS (met) | **Blocks**: promotion of C-S1, D-S1, D-S2, E-S1 host-proof claims

---

## Objective

Specify the host-composition proof protocol that every future extraction candidate (G4–G7) must satisfy: which hosts, which routes, which interactions, which viewports, which error classes fail the gate, and what artifact proves it — per `AGENTS.md` §7.1 (affected-host evidence is mandatory for shared UI changes).

## Background Context

### What already exists

- `packages/warp_prism_host_exercise` — SMOKE/CRAWL/FUZZ/REPLAY runner, strict `FlutterError`-throwing oracle, 15-pattern destructive-action policy, `ExerciseTrace` JSON with replay command.
- `apps/catalog/test/host_exercise/` + cybercore/observatory host adapters.
- `AGENTS.md` §7.1 proof ladder (launch real host → primary route → meaningful interaction → framework/runtime errors → viewports → theme/focus/navigation propagation).

### What is missing

- No per-candidate proof profile: which candidate needs which host, route, interaction depth, and viewport matrix.
- No failure taxonomy binding oracle classes (missing-ancestor, overflow, route, error-boundary, stale theme) to candidate risk.
- No artifact standard for "host proof" attached to a promotion claim.

## Test Requirements

- The protocol names at least one real host per candidate class (UI surface, runtime contract, FRB projection).
- Every proof step is replayable via a recorded `ExerciseTrace` + deterministic replay command.
- The protocol distinguishes package-local green from host-composition green (the G0 trap) in writing.

## Exit Conditions

- [ ] Protocol doc section completed in this file (`## Specification` below).
- [ ] Cited-path existence sweep passes (all `Where` read-paths resolve).
- [ ] No move to `01-open` until the Promotion Gate is met.
- [ ] Completion Evidence filled before review handoff.

## Details

### What

Subtasks:

- [ ] **Read existing code before modifying**: `packages/warp_prism_host_exercise/lib/src/runner/exercise_runner.dart`, `lib/src/oracle/error_oracle.dart`, `lib/src/safety/action_policy.dart`, `AGENTS.md` §7.1, Phase 1 inventory §2.1 + §6 (G1).
- [ ] Draft per-candidate proof profiles (candidate × host × route × interaction × viewport × oracle classes).
- [ ] Draft the host-proof artifact standard (trace + replay command + viewport matrix + sign-off).
- [ ] Draft the package-local-vs-host truth table (what each evidence class proves and does not prove).
- [ ] **Simplicity pass**: remove protocol steps no candidate needs.
- [ ] **Regression verification**: cited-path sweep; no consumer repo touched.

### Where

| File | Purpose |
|---|---|
| `packages/warp_prism_host_exercise/lib/src/runner/exercise_runner.dart` | Read — modes + host-callback contract |
| `packages/warp_prism_host_exercise/lib/src/oracle/error_oracle.dart` | Read — error classes to bind |
| `AGENTS.md` (§7.1) | Read — evidence law to operationalize |
| `.project/reports/architects/future-capability-program-inventory-2026-10-10.md` (§2.1, §6) | Read — candidate list (G4–G7) |
| This file (`## Specification`) | Create — the protocol lives here until promotion |

### How

1. Read all `Where` read-paths; record any unreadable path as UNKNOWN, do not infer.
2. Write profiles smallest-first (one candidate class fully, then generalize only on evidence).
3. Bind each profile step to an oracle class or justify its absence.
4. Self-check template completeness (≥50 lines, binary exits).

### Why

Without this protocol, every future candidate re-litigates "what counts as host proof," and package-local green keeps masquerading as composition truth — the exact G0 failure mode.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not mark complete without the cited-path sweep and a filled Specification.
> Never claim a consumer host cooperates until its governance confirms in writing.

---

## Validation Commands

```bash
# cited-path existence sweep (all must resolve; no output = fail closed, investigate)
ls packages/warp_prism_host_exercise/lib/src/runner/exercise_runner.dart packages/warp_prism_host_exercise/lib/src/oracle/error_oracle.dart AGENTS.md .project/reports/architects/future-capability-program-inventory-2026-10-10.md
```

Code gates (`flutter analyze/test`) do not apply to this prose spec; upon promotion to `01-open`, the executor adds package-appropriate exits. Record tooling unavailability literally, never as PASS.

---

## Specification

*(To be written on promotion-approach. Must contain: per-candidate proof profiles, artifact standard, package-local-vs-host truth table.)*

---

## Completion Evidence

- **Files created/modified**: (executor fills)
- **Tests or validation commands**: (commands + PASS/FAIL)
- **Local changelog entry**: (path)
- **Executor**: —
- **Completion date**: —
