---
name: rust-provenance
description: Source absorption map and compatibility notes for rust bootstrap.
---

# Rust Harness Provenance

## Source Absorption Map

| Source | Classification | What was taken | Status |
|--------|---------------|----------------|--------|
| `.agents/skills/code-quality/sub-skills/rust/SUBSKILL.md` | `COPY_ADAPTER` | Core axioms, 5-phase review protocol, tool integration table, scoring reference | Adapted into `rust/sub-skills/review/SUBSKILL.md`. Original remains intact for compatibility. |
| `.agents/skills/code-quality/references/rust-rules.md` | `PATTERN_ONLY` | 179 rules across 14 categories (leonardomso) | Referenced in-place; not copied. Rust-harness subskills point to the original location. |
| `.agents/skills/code-quality/references/scoring-rubric.md` | `DO_NOT_IMPORT` | 0-100 scoring rubric | Cross-language asset owned by code-quality. Referenced, not imported. |
| `.agents/skills/go/SKILL.md` | `PATTERN_ONLY` | Lobe Gateway structure, decision tree, loading matrix, governance | Structural reference for SKILL.md shape. No Go content imported. |
| `.agents/skills/flutter/SKILL.md` | `PATTERN_ONLY` | Source harvest pattern, reference corpus index, operating rules | Structural reference for SKILL.md shape. No Flutter content imported. |

## Compatibility Strategy

### During Bootstrap Phase

- `code-quality/sub-skills/rust/SUBSKILL.md` remains the active
  compatibility source for all existing references.
- `rust/sub-skills/review/SUBSKILL.md` is an adapted copy with
  expanded content but does NOT replace the original.
- Both paths provide equivalent core doctrine (axioms, phases, tools).
- Loading either path gives a complete Rust review protocol.

### After Routing Refactor (Task AD-ganthritor-code-quality-language-routing-refactor)

- `code-quality` decision tree will route Rust → `rust`
- `code-quality/sub-skills/rust/` will become a compatibility adapter
  with `implementation_kind: adapter` or `legacy-wrapper`
- `rust` becomes the primary Rust doctrine owner

### What Must NOT Happen Before Routing Refactor

1. Do not delete `code-quality/sub-skills/rust/SUBSKILL.md`
2. Do not modify `code-quality/SKILL.md` routing
3. Do not change `code-quality` triggers
4. Do not break any existing path that points to the old location

## Domain Subskill Provenance

| Subskill | Primary source | Secondary sources | New content |
|----------|---------------|-------------------|-------------|
| `review` | `code-quality/sub-skills/rust/SUBSKILL.md` | `rust-rules.md`, `scoring-rubric.md` | Expanded Phase 2 (JoinHandle tracking), Phase 3 (API design checks), provenance notes |
| `unsafe-soundness` | `code-quality/sub-skills/rust` Phases 1, 5 | Rust Reference (unsafe), Miri docs | SAFETY comment contract, FFI checklist, Send/Sync audit template, strict provenance, Kani examples |
| `async-concurrency` | `code-quality/sub-skills/rust` Phase 2 | Tokio documentation, Alice Ryhl's blog | Drop-Proof pattern, select! audit checklist, mutex-across-await rules, JoinSet patterns, CancellationToken |
| `error-handling` | `code-quality/sub-skills/rust` Phase 3 (partial) | `rust-rules.md` err-* rules | Complete error type design guide, library vs application strategy, panic boundaries, audit checklist |
| `testing-verification` | `code-quality/sub-skills/rust` Phase 5 (partial) | `rust-rules.md` test-* rules | Test organization, proptest, Kani harness patterns, criterion benchmarks, coverage measurement, isolation rules |

## Created

- **Date**: 2026-06-11
- **Agent**: gt-architects-architect-general (architects profile)
- **Task**: Task AD-ganthritor-rust-bootstrap
