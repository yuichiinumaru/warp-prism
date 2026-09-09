# EPIC 25 — Warp Prism Rewrite Resolver Strategy (Research-Only / Deferred)

> **Planning Status**: **RESEARCH INTENT** (reconfirmed 2026-09-01). Maturity ladder (corrected A1): L0 ADS (done) → L1 Integration-Capable (EPIC-19..22; exit = 22-D Integration Readiness gate) → L2 Rewrite-Capable (one successful REAL product pilot + post-pilot harvest; exit = Rewrite Readiness gate) → L3 Rewrite Factory (only AFTER L2, extracted from it). Never implement L3 machinery to reach L2. The first real pilot must precede the L2 gate.
> **Priority**: ⚪ P3
> **Depends on**: L2 evidence (first pilot + harvest).

---

## 1. Objective

Capture the *definition* of a rewrite resolver (capability manifests → Warp
Prism matches → gaps) while refusing to schedule actual rewrite work until
real pilots exist. Per the transcript's own maturity ladder: Level 3
(Rewrite Factory) must be extracted FROM Level-2 experience, never planned in
advance.

## 2. Stories (v8)

| Story | Title | Key deliverable |
|---|---|---|
| S25-01 | Freeze Criteria | prerequisites list; forbids implementation before EPIC-22 parity gates |
| S25-02 | Capability Manifest Spec | research spec; census-scoped; reuses EPIC-23 manifest concepts |
| S25-03 | Resolver Outline | failure → candidate → isolated trial → independent verify → governed promotion |
| S25-04 | Escape Hatch | external-service/legacy-only/drop criteria; bypass clause cross-refs |

## 3. Out of Scope

- Any active OmniRoute rewrite effort (belongs to parent/other repos' lanes — see EPIC-OR anchors).
- Bootstrapping agents/plugins to auto-generate rewrites.
- Any DSH/Cordis/Cersei implementation work (those repos' lanes only).

## 4. Exit Conditions

- [ ] Resolver requirements documented as research notes.
- [ ] Hard dependency recorded: "not started until integration-lab + contract proofs exist".
- [ ] All four stories tagged research-only with no code deliverables.
