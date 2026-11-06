# HOLD-warp-prism-job-progress-spec (EPIC-D S1)

> **Planning Status**: Strategically Deferred
> **Promotion Gate**: program acceptance (PLAN doc). No external dependency; held for strategic sequencing behind the proof protocol (A-S1) so the spec writes its host-proof requirements against the protocol, not against guesses.
> **Reason held**: sequencing — a staged-job spec written without the A-S1 proof profile re-litigates evidence on promotion. Internal spec, queued.
> **Promotion target**: `01-open` when gate met AND §3.1 readiness holds.
> **Type**: `feature` (spec) | **Origin**: Phase 1 inventory G5 + review PASS `ses_edbfcec4dffeX44ZMBOaLDsRWR`
> **Depends on**: Phase 1 PASS (met); sequences after A-S1 | **Blocks**: none (leaf)

---

## Objective

Specify the persistent staged batch-job progress surface: staged states (with per-stage progress + stopwatch semantics), cancellation (cooperative, terminal-state-safe), deterministic completion receipt (SHA-256-class), persistence across navigation (toast ≠ job), and dismissal rules — generalizing Warpblade's `ExportProgressBanner` + `ExportReportBanner` (animated spinner, live frame count, SHA-256 receipt) and Tempest's `ProgressCard` (prepare→chunk→post, progress bar, stopwatch, cancel) without extracting either, and composed with (not inside) `EventStream` + `AsyncCommand`.

## Background Context

### What already exists

- `DSToast`, `DSStateSurface` — transient notification vocabulary (explicitly NOT the model: toast ≠ persistent job).
- `EventStream` (staged emission, backpressure) + `AsyncCommand` (single-flight, cancellation token) — the runtime halves.
- Consumer proof of shape on both sides (banner + receipt; staged card + cancel).

### What is missing

- Named staged-job states + stage-transition rules + cancel semantics + receipt contract.
- Persistence-across-navigation rules (where job state lives while the user navigates: binding-owned, following the `Offset`-ownership precedent).
- Dismissal rules (when a receipt may be dismissed; when a running job forbids it).

## Test Requirements

- Both consumer job surfaces map onto the staged states without residue, or residue is named product-local (frame counts? stopwatch? receipt hash algo?).
- Cancel-while-running and dismiss-while-complete are specified as terminal-state-safe (no cancel past terminal, no dismiss of live jobs).
- The spec states its composition with `EventStream`/`AsyncCommand` (which half owns what) — no parallel job runtime invented.

## Exit Conditions

- [ ] Staged states + cancel + receipt + persistence + dismissal completed (`## Specification`).
- [ ] Both-consumer mapping completed.
- [ ] `EventStream`/`AsyncCommand` composition statement written (no new runtime invented).
- [ ] Cited-path sweep passes.
- [ ] No consumer job code copied.
- [ ] Completion Evidence filled.

## Details

### What

Subtasks:

- [ ] **Read existing code before modifying**: `EventStream` + `AsyncCommand` contracts, `DSToast`/`DSStateSurface` (what exists and why it is insufficient), both consumer job surfaces (authorized routes, record route), A-S1 HOLD (proof-profile shape to target), Phase 1 inventory §2.1 row 7.
- [ ] Draft staged states + transitions + cancel semantics + receipt contract.
- [ ] Draft persistence-across-navigation + dismissal rules (binding-owned state, precedent-cited).
- [ ] Draft the runtime-composition statement.
- [ ] Name product-local residue per consumer.
- [ ] **Simplicity pass**: cut stages/rules no mapping needs.
- [ ] **Regression verification**: cited-path sweep; no new runtime type invented in spec.

### Where

| File | Purpose |
|---|---|
| `packages/warp_prism_runtime/lib/src/event_stream/` + `async_command/` | Read — compose-with halves (do not modify) |
| `packages/warp_prism_ui` toast/state-surface sources | Read — existing vocabulary + its limits |
| Consumer `banners.dart` / `progress_card.dart` | Read — authorized routes only; record route |
| `.project/tasks/00-planning/HOLD-warp-prism-host-proof-protocol.md` | Read — proof-profile shape to satisfy |
| This file (`## Specification`) | Create — job spec lives here |

### How

1. Composition first: state which half owns staging (binding), emission (`EventStream`), execution/cancel (`AsyncCommand`); invent nothing.
2. Terminal-state safety before convenience (cancel/dismiss rules are load-bearing).
3. Residue named per consumer, never silently absorbed.

### Why

Persistent jobs are the operational surface where "toast thinking" causes real harm (lost receipts, un-cancellable renders, dismissed failures). Both consumers already paid for the shape; the shared spec prevents a third local implementation.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not invent a parallel job runtime. Do not copy consumer job code. Do not allow dismissing live jobs in any specified path.

---

## Validation Commands

```bash
ls packages/warp_prism_runtime/lib packages/warp_prism_ui/lib .project/tasks/00-planning/HOLD-warp-prism-host-proof-protocol.md .project/tasks/00-planning/PLAN-warp-prism-future-capability-program.md
```

Code gates do not apply to this prose spec; on promotion the executor adds package-appropriate exits.

---

## Specification

*(To be written on promotion-approach: staged states, cancel/receipt/persistence/dismissal, runtime composition, residue list.)*

---

## Completion Evidence

- **Files created/modified**: (executor fills)
- **Tests or validation commands**: (commands + PASS/FAIL)
- **Local changelog entry**: (path)
- **Executor**: —
- **Completion date**: —
