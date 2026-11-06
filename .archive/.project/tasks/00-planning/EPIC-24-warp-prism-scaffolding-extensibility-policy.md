# EPIC 24 — Warp Prism Scaffolding & Extensibility Policy

> **Planning Status**: **HOLD / POLICY INTENT** (reclassified 2026-08-31). Policy text stays as law-in-waiting; ZERO executable tasks — nothing to scaffold, zero recurrences exist. Crystallization rule governs: first occurrence → local implementation; second recurrence → candidate abstraction; multiple stable recurrences → primitive/template candidate. Promote only after first-pilot harvest.
> **Priority**: ⚪ P3 (hold)
> **Depends on**: harvest/retrospective of first real pilots (post 22-D + pilot).

---

## 1. Objective

Declare a *policy* for scaffolding — not the scaffolder itself: templates and
generators appear only after multiple real, cross-domain integrations exist
(crystallization, not speculation), and they must reinforce existing purity
rules rather than bypass them.

## 2. Stories (v8)

| Story | Title | Key deliverable |
|---|---|---|
| S24-01 | Iron Policies | boundaries/purity as iron; FRB = transport not ontology; root-hygiene; preservation; parent-canonical skills; template crystallization rule |
| S24-02 | Promotion Formula & Pipelines | ≥2 distinct consumers OR 2 distinct domains; candidate stage; all 5 promotion pipelines verbatim with step arrows (Visual 8 / Interaction 7 / Runtime 7 / Bridge 4 / Performance 4) |
| S24-03 | Anti-Fragile Guardrails | generators scaffold contract+fake+suite before adapter; generated ui fails CI on dart:io/Riverpod/GoRouter/FRB imports; tri-state awareness |
| S24-04 | Narrow Scoping | single capability per proposal; backend-agnostic proof; Domain Leakage Rule rejection |

## 3. Out of Scope

- Implementing a `prism` CLI.
- Aggressive scaffolding for product code.
- FRB/Rust-generated outputs as shipped features.

## 4. Exit Conditions

- [ ] Policy document + acceptance criteria published.
- [ ] All 5 pipelines verbatim in policy doc.
- [ ] No generated code until promotion criteria satisfied (hard boundary).
- [ ] No changes to existing packages as part of this epic.
