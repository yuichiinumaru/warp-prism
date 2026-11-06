# HOLD-warp-prism-diff-viewer-spec (EPIC-C S2)

> **Planning Status**: Strategically Deferred
> **Promotion Gate**: `HOLD-warp-prism-review-lifecycle-spec` (C-S1) accepted — states, envelope, and terminal guards stable (the diff viewer is the inspect-step surface of that lifecycle; designing it first guesses the envelope).
> **Reason held**: dependency — inspect-step rendering depends on what a proposal carries (C-S1 envelope) and when it may render it (C-S1 guards).
> **Promotion target**: `01-open` when gate met AND §3.1 readiness holds.
> **Type**: `feature` (spec) | **Origin**: Phase 1 inventory G9 (+G4) + review PASS `ses_edbfcec4dffeX44ZMBOaLDsRWR`
> **Depends on**: HOLD-warp-prism-review-lifecycle-spec | **Blocks**: none (leaf)

---

## Objective

Specify the operational diff-viewer surface (the inspect step of the C-S1 review lifecycle): what diff inputs it accepts (before/after op lists with provenance, Rust-computed or local), how it renders side-by-side with per-op disposition, how it behaves under pending/expired lifecycle states (no rendering past guards), and what stays product-local (Warpblade duration-cut arithmetic, Tempest acoustic-dimension chips).

## Background Context

### What already exists

- C-S1 lifecycle (this task's input; gated on it).
- Warpblade `ProposalDiffSummaryCard` (`proposal_panel.dart:187-250`): side-by-side before/after, removed duration, cut count — Rust-computed `ProposalDiffDto`.
- Tempest `PromptDiffViewer` (in `prompt_enhancer_dialog.dart`): Original vs Enhanced two-column + acoustic chips.
- Prism partial: `DSExecutionConsole` (execution output, not diff inspection).

### What is missing

- Shared diff-input contract (op shape, disposition vocabulary, provenance attachment).
- Rendering rules under lifecycle states (loading/pending/expired/error — the 4-state discipline).
- Explicit product-local residue list per consumer.

## Test Requirements

- Both consumer diff surfaces map onto the input contract without residue, or residue is named product-local.
- Rendering is specified for all four component states (loading/empty/error/data) — no unrenderable lifecycle state.
- The spec forbids rendering past terminal guards (expired/rejected proposals show notice, not diff).

## Exit Conditions

- [ ] Diff-input contract + rendering rules + residue list completed (`## Specification`).
- [ ] Both-consumer mapping completed.
- [ ] Cited-path sweep passes.
- [ ] No consumer diff code copied or extracted.
- [ ] Completion Evidence filled.

## Details

### What

Subtasks:

- [ ] **Read existing code before modifying**: C-S1 HOLD (`## Specification` — envelope + guards this surface obeys), both consumer diff surfaces (authorized routes, record route), `DSExecutionConsole` (what exists), Phase 1 inventory §2.1 rows 5/9.
- [ ] Draft the diff-input contract (op shape, disposition vocabulary, provenance).
- [ ] Draft rendering rules per lifecycle × component state (matrix; guards override rendering).
- [ ] Name product-local residue per consumer with reasons.
- [ ] **Simplicity pass**: cut rendering branches no mapping needs.
- [ ] **Regression verification**: cited-path sweep; C-S1 read, not rewritten.

### Where

| File | Purpose |
|---|---|
| `.project/tasks/00-planning/HOLD-warp-prism-review-lifecycle-spec.md` | Read — envelope + guards obeyed (do not rewrite) |
| Consumer diff surfaces | Read — authorized routes only; record route |
| `packages/warp_prism_ui` execution-console sources | Read — what exists |
| This file (`## Specification`) | Create — diff spec lives here |

### How

1. C-S1 first, always; any envelope question routes back to C-S1 as a recorded question, not a local improvisation.
2. Guards override rendering — an expired proposal never renders a live diff.
3. Residue is named, not silently dropped.

### Why

The diff viewer is the highest-touch surface of the review lifecycle and the easiest place to accidentally extract product semantics (duration arithmetic, acoustic chips). The spec draws the shared/product line before rendering exists.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not copy consumer diff code. Do not render past lifecycle guards. Do not rewrite C-S1 from this task.

---

## Validation Commands

```bash
ls .project/tasks/00-planning/HOLD-warp-prism-review-lifecycle-spec.md .project/tasks/00-planning/PLAN-warp-prism-future-capability-program.md .project/reports/architects/future-capability-program-inventory-2026-10-10.md
```

Code gates do not apply to this prose spec; on promotion the executor adds package-appropriate exits.

---

## Specification

*(To be written on promotion-approach: diff-input contract, rendering matrix, residue list.)*

---

## Completion Evidence

- **Files created/modified**: (executor fills)
- **Tests or validation commands**: (commands + PASS/FAIL)
- **Local changelog entry**: (path)
- **Executor**: —
- **Completion date**: —
