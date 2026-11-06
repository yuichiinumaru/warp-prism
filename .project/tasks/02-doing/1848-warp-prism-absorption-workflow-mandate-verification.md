# Task 1848: Verify and reconcile the wp-component-absorption workflow with the full-coverage mandate

> **Priority**: 🟠 High | **Type**: `remediation` | `harness-governance`
> **Origin**: MISSION.md §3.1 + §11.4 (2026-10-19); parent plan Fase 0. This is a **shared-harness asset** (`.opencode/workflows/` mount) — harness-mutation governance applies.
> **Depends on**: nothing. **Blocks**: none (workflow is active; this is a bounded reconciliation, not a redesign).
> **Writeset constraint**: `.opencode/workflows/wp-component-absorption.md` + `.opencode/harness-evolution.md` (append-only) + owner-generated projections via `harness_catalog`. No other files.
> **parallel-safe**: yes — disjoint from Task 1847 writeset and all `02-doing`/`03-review` tasks.
> **Gortex gate**: `GORTEX_SKIP(not-code-child)` — harness/documentation; no child-code mutation.

---

## Finding (parent re-attestation 2026-10-20)

Grep of `.opencode/workflows/wp-component-absorption.md` shows the workflow uses
"recurrence" in four places (`:54`, `:67`, `:102`, `:105`). Reading them in
context:

- `:54` (donors supply ideas, not recurrence/demand) — **correct evidence law; keep.**
- `:67` (Phase 2 exit evidence records "recurrence evidence or UNKNOWN") —
  **recording evidence, not gating; keep, optionally clarify** "(recorded, never
  a gate — MISSION §3.1)".
- `:102` (route check: donor idea with no consumer recurrence → research or
  bounded experiment, not automatic STABLE) — **compatible; promotion gates are
  evidence-based.** Verify the wording still says "no automatic STABLE/export"
  and does NOT say "no absorption".
- `:105` (donor similarity is not recurrence) — **correct; keep.**

**Hypothesis to verify, not assume**: the workflow may already be
mandate-compatible; the live contradiction lives in `bridge §3` vocabulary
(reconciled by Task 1847). This task verifies, and only edits if a residual
gate/ambiguity is found.

## Objective

The active absorption workflow must not (a) gate absorption/extraction on
recurrence, nor (b) contradict MISSION.md §3.1, while preserving donor-evidence
law and promotion evidence gates. If already compatible, record NO-OP with
evidence and only add the one-line clarifier if it materially aids the reader.

## Subtasks

- [x] **Read before mutating**: the full workflow (all 112 lines, current state); MISSION.md §3.1/§5/§6/§11.4; `.opencode/rules/70-harness-mutation-governance.md` + `74-workflow-contract.md`; Task 1847 (to confirm bridge §3 reconciliation it performs).
- [x] **Verify each "recurrence" occurrence** (`:54`, `:67`, `:102`, `:105`) against MISSION §3.1: gate or evidence/priority statement? Record per-line verdict.
- [x] **Edit if needed** (bounded): Phase 2 exit evidence clarifier "(recorded, never a gate — MISSION §3.1)"; any other edit requires a recorded justification. No phase redesign, no new metadata fields beyond `status` semantics already present.
- [x] **Harness ledger**: append one entry to `.opencode/harness-evolution.md` (date, authority = MISSION §3.1 + user-approved Fase 0 plan, exact change or NO-OP, validation).
- [x] **Projections**: rebuild through the owner `harness_catalog(action="rebuild")`; then `harness_catalog(action="validate")`. Record drift count; known pre-existing duplicate-identity errors are NOT this task's failure — do not repair them.
- [x] **Regression verification**: read back the workflow file; confirm donor-evidence law and promotion gates intact; fill Completion Evidence.

## Where

| File | Purpose |
|---|---|
| `.opencode/workflows/wp-component-absorption.md` | Read; bounded edit only if a residual gate/ambiguity is evidenced |
| `.opencode/harness-evolution.md` | Append-only ledger entry (always) |
| `harness_catalog` (rebuild + validate) | Owner-generated projection refresh (always after any source edit) |
| `MISSION.md`, Task 1847 file | READ ONLY — authority/context |

## Validation

```bash
grep -n "recurrence" .opencode/workflows/wp-component-absorption.md
```

Expect: every remaining occurrence is an evidence/priority statement or donor
rule, none gates absorption for mandate-covered components. Workflow source
read-back clean; ledger entry present; validate reports zero NEW
unit-attributable errors (pre-existing duplicates documented as residual).

## Anti-Hallucination Guardrails

> [!CAUTION]
> Shared harness mount — Warp Prism-only asset; do not broaden scope to other
> projects' workflows. Do not rewrite phases or invent new gates. Do not repair
> pre-existing duplicate-identity errors. Independent review before treating
> any edit as released; NO-OP is a valid, evidence-recorded outcome.

## Completion Evidence

- **Per-line verdicts (`:54/:67/:102/:105`)**: `:54` donor-evidence law — KEEP, no edit. `:67` exit evidence ("recurrence evidence or UNKNOWN") — NOT a gate (UNKNOWN allowed); KEEP + one editorial clarifier. `:102` ("no consumer recurrence → research/bounded experiment, not automatic STABLE/export") — promotion evidence gate, does NOT forbid absorption; KEEP, wording verified ("not automatic STABLE/export", no "no absorption"). `:105` donor-similarity rule — KEEP, no edit. Hypothesis CONFIRMED: workflow was already mandate-compatible.
- **Edit made or NO-OP + evidence**: single Rule-70-editorial clarifier at `:67` → "recurrence evidence (recorded, never a gate — MISSION §3.1) or UNKNOWN". Rule-74 §18 ordering/participants/authority/side-effects/retry/terminal/entrypoint/ownership preserved. Read-back verified; donor law (`:54/:105`) and promotion gates (Phase 5 → MISSION §6 + Rule41 §6a) intact.
- **Ledger entry path**: `.opencode/harness-evolution.md` → `## 2026-10-30 — warp-prism — Task 1848: wp-component-absorption mandate-verification clarifier`.
- **Rebuild/validate results**: pre-edit validate `stale/drift 12/errors 8/warnings 12`; post-edit rebuild wrote 12 projections, validate `current/drift 0/errors 8/warnings 12` — the 8 errors byte-identical pre-existing duplicate-identity set (atomic-theme, critique-coordinator, knowledge-small, testing, remediation-small, synthesize, rust-small, security-small). Zero NEW unit-attributable errors.
- **Independent review**: REQUIRED before any released edit — NOT YET OBTAINED (no reviewer dispatch available in this execution context). Task stays in `01-open` for parent-routed review; clarifier is authored-but-unreleased until then.
