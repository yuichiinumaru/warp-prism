# HOLD-warp-prism-data-plane-contract-spec (EPIC-E S1)

> **Planning Status**: Strategically Deferred
> **Promotion Gate**: program acceptance (PLAN doc) + 03-review Task 1844 (`adapter-frb-hardening`) resolved (coordination gate, not dependency: shared `warp_prism_adapter_frb` writeset — sequence after, do not collide).
> **Reason held**: writeset coordination + contract-surface risk — the data-plane contract projects through the adapter currently under hardening review; spec must target the post-1844 surface, and a new runtime contract type needs a settled transport neighbor.
> **Promotion target**: `01-open` when gate met AND §3.1 readiness holds.
> **Type**: `feature` (spec) | **Origin**: Phase 1 inventory G7 + review PASS `ses_edbfcec4dffeX44ZMBOaLDsRWR`
> **Depends on**: Phase 1 PASS (met); sequences after 1844 | **Blocks**: none (leaf)

---

## Objective

Specify the data-plane transfer + ownership contract missing from `warp_prism_runtime`: declared transfer semantics (copy vs move vs borrow-view vs shared-handle), ownership/lifetime rules across the FRB boundary, rate/size declarations, and the hard prohibition (a data plane MUST NOT be modeled as a high-rate stream of semantic events — layer-contracts §8) — covering Warpblade's `textureId`+metadata pattern and Tempest's peak-pyramid/FFT native doctrine at contract level, with transport vocabulary (FRB zero-copy/codecs, `StreamSink`) confined to the adapter projection.

## Background Context

### What already exists

- layer-contracts §8: control plane (small/low-rate/semantic → runtime contracts) vs data plane (high-rate/large-payload → MUST declare transfer + ownership). Rule declared, type missing.
- FRB transport facts: zero-copy big arrays, multiple codecs, `RustStreamSink<T>` pass-sink-before-access, explicit bridge-stream cancellation.
- `warp_bridge_core`: zero-dep transport-independent domain; `warp_bridge_frb`: FRB+tokio transport owner — the projection seam already exists structurally.
- sim method (reference only): `ExecutionContext` pause/snapshot/resume vocabulary (`pauseKind: human|time`) — state-holding across suspension, not data transfer; method inspiration only.

### What is missing

- The contract type: transfer verbs, ownership states, lifetime rules, size/rate declarations, error classes (transfer-failed, ownership-violated, stale-handle).
- The control/data boundary test: mechanical criterion distinguishing "model with runtime contracts" from "declare transfer semantics or stay product-local."
- Projection rules: what the FRB adapter owns (DTO mapping, handle tables, cancellation) vs what the contract owns (semantics only, zero Flutter/FRB imports — purity preserved).

## Test Requirements

- Warpblade texture pattern AND Tempest peak/FFT doctrine both expressible in the contract without residue, or residue named product-local with reason.
- The high-rate-semantic-events antipattern is inexpressible (prove by construction: no field carries unbounded event-rate semantics).
- Contract purity holds: zero `package:flutter`, zero FRB imports (same bar as the four existing contracts — boundary-test-extendable).
- 1844's post-review adapter surface is the projection target (sequence, not parallel).

## Exit Conditions

- [ ] Transfer verbs + ownership/lifetime + declarations + error classes completed (`## Specification`).
- [ ] Control/data boundary test written (mechanical criterion).
- [ ] Projection rules (contract vs adapter ownership split) written.
- [ ] Both-domain expressibility check completed (texture + peaks/FFT).
- [ ] Cited-path sweep passes.
- [ ] No runtime/adapter source modified (spec only).
- [ ] 1844 resolution recorded (resolved version noted; spec targets post-1844 surface).
- [ ] Completion Evidence filled.

## Details

### What

Subtasks:

- [ ] **Read existing code before modifying**: layer-contracts §8, all four runtime contracts (purity bar to match), `warp_bridge_core` vs `warp_bridge_frb` split, FRB `stream_sink.dart` (transport facts, bounded), sim `executor/types.ts` pause/snapshot (vocabulary only, bounded), 1844 review file (post-resolution surface), Phase 1 inventory §2.3 (plane split) + §6 (G7).
- [ ] Draft transfer verbs + ownership/lifetime + size/rate declarations + error classes.
- [ ] Draft the mechanical control/data boundary test.
- [ ] Draft contract-vs-adapter projection rules (purity preserved both sides).
- [ ] Run the both-domain expressibility check; name residue product-local.
- [ ] Record 1844's resolution and the targeted post-1844 surface.
- [ ] **Simplicity pass**: cut verbs/declarations neither domain exercises.
- [ ] **Regression verification**: cited-path sweep; runtime + adapter untouched.

### Where

| File | Purpose |
|---|---|
| `.project/architecture/layer-contracts.md` (§8) | Read — the declared rule to type |
| `packages/warp_prism_runtime/lib/src/` (all four contracts) | Read — purity bar + composition neighbors |
| `rust/warp_bridge_core/` vs `rust/warp_bridge_frb/src/api.rs` | Read — structural projection seam |
| FRB `stream_sink.dart` (via `references/...`) | Read — transport facts, bounded |
| `.project/tasks/03-review/1844-warp-prism-adapter-frb-hardening.md` | Read — post-resolution surface to target |
| This file (`## Specification`) | Create — contract spec lives here |

### How

1. Boundary test first (control-vs-data criterion gates everything else).
2. Purity is non-negotiable: the contract imports neither Flutter nor FRB — same mechanical bar as siblings.
3. Both domains before verbs (texture + peaks/FFT expressibility check precedes verb finalization).
4. 1844 status is read at execution time, not assumed now — record the version seen.

### Why

Heavy data (texture frames, peak pyramids, FFT) is where untyped bridges rot into JSON-string fallbacks and where high-rate semantic-event modeling silently reintroduces the coupling the transport split was built to kill. The contract makes transfer/ownership explicit before either failure mode gets a second implementation.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not model the data plane as high-rate semantic events (layer-contracts §8 forbids it). Do not import Flutter/FRB into the contract design. Do not collide with 1844's writeset — sequence after resolution. Record 1844's actual resolution; do not assume it.

---

## Validation Commands

```bash
ls packages/warp_prism_runtime/lib rust/warp_bridge_core .project/architecture/layer-contracts.md .project/tasks/00-planning/PLAN-warp-prism-future-capability-program.md
```

Code gates do not apply to this prose spec; on promotion the executor adds package-appropriate exits (contract + fake + suite + purity test, per layer law "add its check here and to the harness in the same task").

---

## Specification

*(To be written on promotion-approach: transfer verbs, ownership/lifetime, declarations, error classes, boundary test, projection rules, expressibility check, 1844 record.)*

---

## Completion Evidence

- **Files created/modified**: (executor fills)
- **Tests or validation commands**: (commands + PASS/FAIL)
- **Local changelog entry**: (path)
- **Executor**: —
- **Completion date**: —
