# HOLD-warp-prism-bridge-surface-request (EPIC-A S2)

> **Planning Status**: Strategically Deferred
> **Promotion Gate**: written response from Sentry governance AND Hyperion governance on the requested minimal surface (even "declined with reason" unblocks — the gate is an answer, not a yes).
> **Reason held**: the surface is consumer-owned (`docs/bridge/README.md` §1: "the consumer repository is the source of truth"); Prism side cannot write it, only request it. Drafting the request now is cheap; sending it is a governance act outside this pass.
> **Promotion target**: `01-open` when both answers recorded (then the request package is sent via consumer governance channels).
> **Type**: `governance` | **Origin**: Phase 1 inventory G2 + review PASS `ses_edbfcec4dffeX44ZMBOaLDsRWR`
> **Depends on**: Phase 1 PASS (met) | **Blocks**: recurrence re-detection over Sentry/Hyperion

---

## Objective

Produce the minimal bridge-surface request package for Sentry and Hyperion: exactly what documentation surface Prism needs for recurrence detection (capability list + source paths + disposition-relevant semantics), why, and in what format — so consumer governance can answer, decline, or defer with full context and minimal effort.

## Background Context

### What already exists

- `docs/bridge/README.md` — bridge law: read-only Prism access, consumer-owned docs, disposition vocabulary (§3), recurrence rule (§4), staleness reconciliation (§5).
- `docs/bridge/warpblade/ads-debt.md` + `docs/bridge/tempest/ads-debt.md` — the two working examples of the requested shape (dated 2026-09-13).
- `docs/bridge/sentry/` — empty (0 entries). No `docs/bridge/hyperion/` (absent by design).
- Sentry reality (parent-verified): Rust-only, 3 crates, no FRB, no Flutter (Slice 0 guard rail). Hyperion reality: planning-only, `docs/warp-prism-conditions.md` exists (190 lines, scopes Hyperion to consuming `warp_prism_ui` organisms).

### What is missing

- A bounded request: what Sentry should document (ports/components/fixtures as harvest surface? or "no UI surface, close the row"?), and what Hyperion should document (conditions doc is a start — what turns it into a classifiable surface?).
- Explicit statement that "no surface" is an acceptable answer (UNKNOWN stays UNKNOWN; absence is data).

## Test Requirements

- The package fits on one request per consumer (bounded; no fishing expedition).
- Each requested item maps to a Phase 1 matrix column (consumer/capability/evidence/semantics/recurrence/disposition).
- The package states what Prism will do with each possible answer (surface / decline / defer).

## Exit Conditions

- [ ] Request package completed in this file (`## Specification`).
- [ ] Cited-path sweep passes (bridge paths + consumer condition docs resolve via authorized routes only).
- [ ] No consumer repository or doc mutated (read-only; violation = FAIL).
- [ ] No bridge content copied into Warp Prism.
- [ ] Completion Evidence filled before handoff.

## Details

### What

Subtasks:

- [ ] **Read existing code before modifying**: `docs/bridge/README.md` (full), both `ads-debt.md` (shape reference), `hyperion/docs/warp-prism-conditions.md` (via authorized route), Phase 1 inventory §2 + §6 (G2).
- [ ] Draft the Sentry request (minimal harvest surface for a Rust-only Slice-0 product: ports? components? or explicit no-UI-surface closure?).
- [ ] Draft the Hyperion request (what turns conditions prose into a classifiable surface).
- [ ] Draft the answer-handling table (surface→classify; decline→record reason; defer→record date).
- [ ] **Simplicity pass**: cut any requested item with no mapped matrix column.
- [ ] **Regression verification**: cited-path sweep; zero consumer writes (prove with `git status` clean on consumer paths — read-only).

### Where

| File | Purpose |
|---|---|
| `docs/bridge/README.md` | Read — bridge law + vocabulary |
| `docs/bridge/warpblade/ads-debt.md` | Read — shape example |
| `docs/bridge/tempest/ads-debt.md` | Read — shape example |
| Phase 1 inventory (§2, §6 G2) | Read — what recurrence needs |
| This file (`## Specification`) | Create — the request package lives here |

### How

1. Read bridge law first; the request must obey §1 (consumer-owned) and §4 (recurrence rule).
2. Keep each consumer request independently sendable (one may answer while the other defers).
3. Record "no surface" as a first-class acceptable answer with its matrix consequence.

### Why

Without Sentry/Hyperion surfaces, recurrence detection is blind on half the consumer family, and every future harvest risks single-consumer extraction dressed as recurrence.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not mutate any consumer repository or doc. Do not copy bridge content into Warp Prism. Absence of an answer is BLOCKED-on-external, not FAIL of this task's drafting half.

---

## Validation Commands

```bash
ls docs/bridge/README.md docs/bridge/warpblade/ads-debt.md docs/bridge/tempest/ads-debt.md .project/reports/architects/future-capability-program-inventory-2026-10-10.md
```

Code gates do not apply to this prose request package; on promotion the executor adds package-appropriate exits if any code ships (none expected).

---

## Specification

*(To be written on promotion-approach: Sentry request, Hyperion request, answer-handling table.)*

---

## Completion Evidence

- **Files created/modified**: (executor fills)
- **Tests or validation commands**: (commands + PASS/FAIL)
- **Local changelog entry**: (path)
- **Executor**: —
- **Completion date**: —
