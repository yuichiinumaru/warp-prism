# Task 1847: Reconcile recurrence-gate language in governance docs to the full-coverage mandate

> **Priority**: 🔴 P0 (governance prerequisite for the absorption program) | **Type**: `remediation` | `docs`
> **Origin**: MISSION.md §3.1 + §11.4 amendment (product-owner decision, 2026-10-19). Parent re-attestation 2026-10-20 confirmed the contradictions below at current lines.
> **Depends on**: nothing (independent). **Blocks**: honest law for the absorption program (Fase 1 researchers must not read recurrence-gated law).
> **Writeset constraint**: 4 documentation files + this task + changelog entry. No source, no tests, no lane moves by this executor.
> **parallel-safe**: yes — disjoint from all `02-doing`/`03-review` writesets (source/test files) and from rem-0004 (layer-contracts §2; this task touches §9 only).
> **Gortex gate**: `GORTEX_SKIP(not-code-child)` — documentation-only remediation; no child-code mutation.

---

## Finding (re-attested evidence, 2026-10-20)

`MISSION.md` §3.1 (full-coverage mandate) supersedes recurrence as a gate to
extraction/promotion for mandate-covered components. Three docs still state
recurrence as a gate, so a reader following them would wrongly reject
single-consumer UI components:

1. **`.project/architecture/layer-contracts.md:185`** — §9 PROVEN row:
   `≥2 distinct consumers **or** ≥2 distinct domains + fake + suite PASS`.
   This is the normative enforcement reference; it directly contradicts
   MISSION §3.1/§6 item 1 for mandate-covered components.
2. **`docs/bridge/README.md:107,113`** — §2 harvest loop keeps a
   `further recurrence` step and says `Recurrence and proof govern reusable
   promotion`. The loop must reflect macro review + convergence (MISSION §5,
   amended 2026-10-19). §3 vocabulary rows (`CANDIDATE_UPSTREAM`,
   `PRODUCT_SPECIFIC_KEEP_LOCAL`) also need mandate-qualified wording, and the
   §1 bridge table lacks the `command-center` row (symlink live since
   2026-10-19; MISSION §3 now lists it).
3. **`docs/design/component-adaptation.md:52`** — §2 item 5 says missing
   recurrence "can leave a candidate researched or a separately authorized
   experiment unpromoted". Under the mandate this is wrong for
   mandate-covered components: recurrence records priority, never gates
   promotion.

Verified NON-contradictions (do not "fix" what is already correct):

- `docs/design/token-theme-catalog-policy.md` — grep 2026-10-20: no
  recurrence-as-gate language (only `≥24px` WCAG row at :518). **Read the
  promotion-gates sections (§4–§7) once to confirm; if no contradiction,
  touch nothing.**
- Donor-vs-consumer evidence rules (adaptation §1, workflow L54) — donors
  never prove recurrence/demand; that is evidence law, unchanged by the mandate.

## Objective

Make every governance doc a reader would rely on agree with MISSION.md §3.1
without weakening the standing evidence gates (fake/reference, conformance
suite, boundary clearance, host-composition proof, FRB lifecycle proof,
independent review) or the domain-leakage/bypass rules.

## Subtasks

- [ ] **Read before mutating** (all of them, current state): MISSION.md §3.1/§5/§6/§11.4; layer-contracts.md §9 (post-rem-0004 file); docs/bridge/README.md §1/§2/§3; docs/design/component-adaptation.md §2; token-theme-catalog-policy.md §4–§7.
- [ ] **Edit 1 — layer-contracts.md §9 PROVEN row** (`:185`): change Requires to read approximately: `mandate coverage (MISSION.md §3.1) with recorded macro-review decision, OR ≥2 distinct consumers/domains + fake + suite PASS`. Keep STABLE row untouched (evidence gates). Do not touch §2 (rem-0004 owns it) or §10 (rem-0001 row table).
- [ ] **Edit 2 — bridge README**: (a) §2 loop — replace the `further recurrence` step with macro-review/convergence wording matching MISSION §5; (b) `:113` — `Proof governs reusable promotion; recurrence informs unification priority, never gates it (MISSION.md §3.1)`; (c) §3 — qualify `CANDIDATE_UPSTREAM` and `PRODUCT_SPECIFIC_KEEP_LOCAL` per mandate (KEEP_LOCAL valid only for non-UI domain logic, never terminal for a UI component); (d) §1 table — add `command-center` row (`prism-gap-components.md`, live 2026-10-19).
- [ ] **Edit 3 — component-adaptation.md §2 item 5** (`:52`): reconcile to the mandate — recurrence records priority for unification; it does not gate promotion of mandate-covered components; keep the "donors never count as consumers" sentence.
- [ ] **Edit 4 — token policy**: read §4–§7; if and only if a recurrence/`≥2 consumers` gate is found, qualify it per mandate; otherwise no edit (record `NO-OP` with evidence).
- [ ] **Simplicity pass**: no editorializing, no new sections, no history deletion — annotate, don't erase (supersession law).
- [ ] **Regression verification**: re-read each diff; run the validation commands; confirm MISSION §11.4 surfaces all reconciled (or NO-OP with evidence).

## Where

| File | Purpose |
|---|---|
| `.project/architecture/layer-contracts.md` (§9 only, `:185`) | Modify — PROVEN row mandate qualifier |
| `docs/bridge/README.md` (§1 table, §2 loop, §3 vocabulary) | Modify — loop wording, L113 sentence, dispositions, command-center row |
| `docs/design/component-adaptation.md` (§2 item 5) | Modify — mandate reconciliation |
| `docs/design/token-theme-catalog-policy.md` (§4–§7) | Read; edit ONLY if contradiction found |
| `.project/changelog/` | Create — entry |
| `MISSION.md` | **READ ONLY** — authority source; no edit authorized for this task |

## Validation

```bash
grep -n "≥2 distinct consumers" .project/architecture/layer-contracts.md
grep -n "recurrence" docs/bridge/README.md docs/design/component-adaptation.md
grep -rn "command-center" docs/bridge/README.md
```

Expect: layer-contracts PROVEN row now carries the mandate alternative;
remaining "recurrence" mentions are priority/evidence statements, not gates;
command-center row present. Then fill Completion Evidence.

## Anti-Hallucination Guardrails

> [!CAUTION]
> MISSION.md is authority, not a write target. Do not weaken evidence gates,
> domain-leakage, bypass, or donor-evidence rules. Do not edit layer-contracts
> §2/§10 (owned by rem-0004/rem-0001 state). Do not delete history — annotate.

## Completion Evidence

- **Files modified**:
  - `.project/architecture/layer-contracts.md` §9 PROVEN row (already carrying the mandate alternative + reconciliation note; verified, no further edit needed).
  - `docs/bridge/README.md` §3 vocabulary (`PRODUCT_SPECIFIC_KEEP_LOCAL` qualified per mandate) + KEEP_LOCAL paragraph.
  - `docs/design/component-adaptation.md` §2 item 5 (recurrence is priority, not a promotion gate).
  - `.project/changelog/20261029-225442-1847-...-flutter-dart-builder.md` (created by changelog engine).
  - `.project/tasks/01-open/1847-...md` (this evidence).
- **NO-OP (with evidence)**: `docs/design/token-theme-catalog-policy.md` §4–§7 — `grep -n -i "recurrence\\|≥2 distinct\\|distinct consumers"` returned no matches (verified 2026-10-29); no recurrence/≥2-consumers gate present, so no edit made.
- **Edits made**:
  - component-adaptation.md:52-56 — recurrence now described as unification priority only; donors still never count as consumers.
  - bridge README:138 — `PRODUCT_SPECIFIC_KEEP_LOCAL` qualified: non-UI domain logic only; never terminal for a UI component.
  - bridge README:154-159 — KEEP_LOCAL paragraph gains mandate qualifier.
- **Validation commands + results (re-verified 2026-11-01; all edits already in place, NO-OP)**:
  - `grep -n "≥2 distinct consumers" .project/architecture/layer-contracts.md` → exit 0; `:185` PROVEN row carries the mandate alternative; `:191` is the historical note inside the reconciliation blockquote (annotate, not erase).
  - `grep -n "recurrence" docs/bridge/README.md docs/design/component-adaptation.md` → exit 0; exact hits: bridge `:58` (donor route — keep), `:87` (donor apps — keep), `:112-114` (`Proof governs reusable promotion; recurrence informs unification priority and never gates it` — correct), `:189` (do-not-inflate-recurrence — keep), `:208` (upstream-proposal row label — evidence classification, not a gate); adaptation `:23` (donor evidence — keep), `:53` (`Recurrence records unification priority only; it does not gate promotion` — correct). No gate language remains.
  - `grep -rn "command-center" docs/bridge/README.md` → exit 0; exact hit `:34` (bridge row, `prism-gap-components.md` present, symlink live 2026-10-19).
- **Changelog entry path**: `.project/changelog/20261029-225442-1847-reconcile-recurrence-gate-language-in-governance-docs-to-full-coverage-mandate-flutter-dart-builder.md`
- **Independent review**: REQUIRED before any promotion use of these docs.
