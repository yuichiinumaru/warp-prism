# HOLD-warp-prism-review-lifecycle-spec (EPIC-C S1)

> **Planning Status**: Strategically Deferred
> **Promotion Gate**: program acceptance (PLAN doc) + IDS owner review slot (IDS is PROVEN — lifecycle-adjacent changes need owner care, not drive-by spec).
> **Reason held**: strategic sequencing + surface protection — the lifecycle touches the PROVEN interaction layer's conceptual neighborhood; spec must be owner-reviewed before any downstream diff-viewer (C-S2) or conformance work assumes its states.
> **Promotion target**: `01-open` when gate met AND §3.1 readiness holds.
> **Type**: `feature` (spec) | **Origin**: Phase 1 inventory G4 + review PASS `ses_edbfcec4dffeX44ZMBOaLDsRWR`
> **Depends on**: Phase 1 PASS (met) | **Blocks**: `HOLD-warp-prism-diff-viewer-spec`

---

## Objective

Specify the shared command-plan review lifecycle (propose → inspect → confirm/reject, with expiry/withdrawal and override semantics) as IDS-level semantics: states, transitions, terminal-state guards for pending interactions, and the tool-call/artifact envelope it carries — generalizing Warpblade's `ProposalPanel` (467 lines, Rust-computed diff, Accept/Reject, "Keep speech" override, expiry notice) and Tempest's `CommandBarDialog` (385 lines, NL→`StudioActionPlan`, confirm-before-execute) without extracting either widget and without unifying their time ontologies.

## Background Context

### What already exists

- IDS (`warp_prism_interaction`): selection/query/inspection/intent state machine (PROVEN) — the lifecycle composes with these, not inside them.
- `AsyncCommand` (single-flight cancel-and-replace) + `DSToolCallCard` + `DSCommandPalette` — execution half exists; the *proposal* half does not.
- ag-ui prior art: 4-phase tool-call envelope (`Start`→`Args`→`End`→`Result`, `toolCallId`-owned), `RunStarted/Finished/Error` with `parentRunId`.
- deepchat pattern: `finalizeAssistantMessageBlocks` terminal-state guards (never finalize while a permission/question/tool-call is pending).

### What is missing

- Named lifecycle states + transition table + terminal-state guards (the deepchat-guard pattern, generalized).
- The envelope: what a proposal carries (plan ref, diff ref, provenance, expiry, override policy).
- Explicit non-goals: no time-ontology unification, no widget extraction, no NLE/DAW verb semantics.

## Test Requirements

- Both consumer implementations map onto the lifecycle without residue (every Warpblade/Tempest proposal state has a lifecycle home, or the residue is named as product-local).
- Terminal-state guards cover: pending permission, pending question, in-flight tool call, expired proposal.
- The spec states what is product-local per consumer (what stays out).

## Exit Conditions

- [ ] Lifecycle states + transition table + guards + envelope completed (`## Specification`).
- [ ] Both-consumer mapping table completed (no silent residue).
- [ ] Cited-path sweep passes.
- [ ] No IDS source modified (spec only; PROVEN surface untouched).
- [ ] No consumer widget extracted or copied.
- [ ] Completion Evidence filled.

## Details

### What

Subtasks:

- [ ] **Read existing code before modifying**: `warp_prism_interaction` intent/state-machine sources, `AsyncCommand` contract, ag-ui `events.ts` envelope (via `references/...`, bounded), deepchat `messageBlocks.ts` guards (bounded), Warpblade `proposal_panel.dart` + Tempest `command_bar_dialog.dart` (via authorized consumer routes — record route used), Phase 1 inventory §2.1 row 4 + §2.3 conflicts.
- [ ] Draft states + transition table + terminal guards.
- [ ] Draft the proposal envelope (plan/diff/provenance/expiry/override fields).
- [ ] Build the both-consumer mapping table; name every residue as product-local with reason.
- [ ] Write explicit non-goals (ontologies, widgets, verbs).
- [ ] **Simplicity pass**: cut states no consumer mapping needs.
- [ ] **Regression verification**: cited-path sweep; IDS untouched (prove via `git status` on interaction package).

### Where

| File | Purpose |
|---|---|
| `packages/warp_prism_interaction/lib/` | Read — compose-with surface (do not modify) |
| `packages/warp_prism_runtime/lib/src/async_command/` | Read — execution half to compose with |
| ag-ui `events.ts`, deepchat `messageBlocks.ts` (via `references/...`) | Read — envelope + guard patterns, bounded reads |
| Consumer `proposal_panel.dart` / `command_bar_dialog.dart` | Read — via authorized routes only; record route |
| This file (`## Specification`) | Create — lifecycle spec lives here |

### How

1. Map both consumers FIRST (evidence before abstraction); any state serving only one consumer is product-local by default.
2. Guards before transitions (pending-interaction safety is the load-bearing property).
3. Non-goals are normative text, not footnotes.

### Why

Command-plan review is the strongest upstream candidate (two substantial implementations, Rust-computed diffs on one side) — and the easiest to get wrong by extracting widgets instead of lifecycle. The spec fixes the layer (IDS semantics, not ADS widgets) before any code exists to argue with.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not modify IDS sources. Do not extract/copy consumer widgets. Do not unify time ontologies (§2.3 register — that is a defect, not compression). Record the consumer access route used.

---

## Validation Commands

```bash
ls packages/warp_prism_interaction/lib packages/warp_prism_runtime/lib .project/reports/architects/future-capability-program-inventory-2026-10-10.md .project/tasks/00-planning/PLAN-warp-prism-future-capability-program.md
```

Code gates do not apply to this prose spec; on promotion the executor adds package-appropriate exits for any shipped contract/fake/suite code.

---

## Specification

*(To be written on promotion-approach: states, transition table, terminal guards, envelope, both-consumer mapping, non-goals.)*

---

## Completion Evidence

- **Files created/modified**: (executor fills)
- **Tests or validation commands**: (commands + PASS/FAIL)
- **Local changelog entry**: (path)
- **Executor**: —
- **Completion date**: —
