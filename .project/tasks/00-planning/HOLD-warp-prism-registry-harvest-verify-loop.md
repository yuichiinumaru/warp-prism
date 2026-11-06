# HOLD-warp-prism-registry-harvest-verify-loop (EPIC-B S2)

> **Planning Status**: Strategically Deferred
> **Promotion Gate**: `HOLD-warp-prism-component-registry-schema` (B-S1) accepted — schema + worked examples exist and are stable.
> **Reason held**: dependency — the loop harvests into a schema that does not exist yet; designing the loop first forces schema guesses that B-S1 exists to settle.
> **Promotion target**: `01-open` when gate met AND §3.1 readiness holds.
> **Type**: `feature` (spec) | **Origin**: Phase 1 inventory G3 + review PASS `ses_edbfcec4dffeX44ZMBOaLDsRWR`
> **Depends on**: HOLD-warp-prism-component-registry-schema | **Blocks**: verification of C/D/E specs

---

## Objective

Design the harvest→validate→write loop that keeps the registry (§B-S1 schema) true without hand-maintenance: what source is scanned (Dart const registry? analyzer AST? both?), what validation rejects a regeneration, what the verify step checks (gallery drift-guard precedent), and how staleness is detected and reported — modeled on ivisa's `harvest.ts` → Zod-validate → write + `verify_components.py` oracle, adapted to Dart/Prism (no ts-morph, no Storybook, no copied code).

## Background Context

### What already exists

- B-S1 schema (this task's input; gated on it).
- Drift-guard precedent: gallery tests consume `dsGallerySections` "to prevent drift" (registry file comments).
- ivisa method (reference only): `harvest.ts` scans component dirs → extracts JSDoc + Props interface → collects stories → Zod-validates → writes JSON; `verify_components.py` navigates Storybook stories via Playwright and classifies console/page errors.
- Prism-side verify precedent: `warp_prism_host_exercise` strict oracle (different target — hosts, not registry — but the fail-loud philosophy transfers).

### What is missing

- Harvest source decision (const-registry projection vs analyzer AST vs hybrid) with recorded reason.
- Validation rules (what rejects a regeneration: schema violation? dropped component? unlisted contract?).
- Staleness detection (how a stale registry announces itself: version.hot? CI check? test?).
- Frequency/ownership (who runs the loop: CI? catalog owner? release gate?).

## Test Requirements

- The loop is reproducible from source by a second agent following only the spec (no tribal knowledge).
- Every ivisa-method element has a disposition: adopt / adapt (Dart equivalent) / drop (reason).
- The design states what happens on each failure class (schema violation, dropped entry, stale projection) — fail-loud, never silent.

## Exit Conditions

- [ ] Loop design + failure table completed (`## Specification`).
- [ ] Cited-path sweep passes.
- [ ] No implementation shipped (design only; code is a future promotion).
- [ ] No gallery/host-exercise writesets touched.
- [ ] Completion Evidence filled.

## Details

### What

Subtasks:

- [ ] **Read existing code before modifying**: B-S1 HOLD (`## Specification` — the schema this loop feeds), gallery drift-guard tests, host-exercise oracle (fail-loud precedent), ivisa `harvest.ts` + `verify_components.py` (method reference, bounded reads), Phase 1 inventory §3.1 (ivisa row).
- [ ] Decide harvest source (projection vs AST vs hybrid) with recorded evidence-based reason.
- [ ] Specify validation rules (reject classes + messages).
- [ ] Specify staleness detection + loop ownership/frequency.
- [ ] Write the failure table (failure class → detection → response → owner).
- [ ] **Simplicity pass**: cut loop stages no failure class needs.
- [ ] **Regression verification**: cited-path sweep; B-S1 read, not rewritten.

### Where

| File | Purpose |
|---|---|
| `.project/tasks/00-planning/HOLD-warp-prism-component-registry-schema.md` | Read — the schema this loop feeds (do not rewrite it) |
| Gallery drift-guard tests (`packages/warp_prism_ui/test/`) | Read — existing verify precedent |
| `packages/warp_prism_host_exercise/lib/src/oracle/error_oracle.dart` | Read — fail-loud philosophy precedent |
| ivisa `harvest.ts`, `verify_components.py` (via `references/...`) | Read — method reference, bounded reads only |
| This file (`## Specification`) | Create — loop design lives here |

### How

1. Read B-S1 fully first; any schema ambiguity is a B-S1 question, not a loop improvisation — record and stop that branch.
2. Prefer projection (const registry is already machine-consumable inside Dart) unless evidence shows AST needed; record the decision.
3. Every failure class gets detection + response + owner, or it is cut.

### Why

A registry without a truth-maintenance loop rots into a second, contradictory source of taxonomy — worse than no registry. The loop is the G3 deliverable's load-bearing half.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not ship implementation. Do not copy ivisa code (method only). Do not rewrite B-S1 from this task — send schema questions back to B-S1.

---

## Validation Commands

```bash
ls .project/tasks/00-planning/HOLD-warp-prism-component-registry-schema.md .project/tasks/00-planning/PLAN-warp-prism-future-capability-program.md .project/reports/architects/future-capability-program-inventory-2026-10-10.md
```

Code gates do not apply to this prose design; on promotion the executor adds package-appropriate exits for any shipped loop code.

---

## Specification

*(To be written on promotion-approach: harvest-source decision, validation rules, staleness design, failure table.)*

---

## Completion Evidence

- **Files created/modified**: (executor fills)
- **Tests or validation commands**: (commands + PASS/FAIL)
- **Local changelog entry**: (path)
- **Executor**: —
- **Completion date**: —
