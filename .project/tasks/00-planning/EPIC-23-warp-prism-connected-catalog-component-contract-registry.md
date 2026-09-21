# EPIC 23 — Warp Prism Connected Catalog + Component Contract Registry

> **Planning Status**: **CONDITIONAL / PARTIALLY PROVABLE** (reclassified 2026-08-31 source-reality review). Split:
> - **23A — Minimal Connected Catalog Proof** (component + interaction declaration + runtime requirement + fake adapter + live FRB adapter, for ONE or few cases): promotable after 22-D.
> - **23B — Generalization** (full registry, manifest exporter, generalized resolver metadata, tri-state-everything): **DEFERRED post-pilot** — zero consumers today; catalog is currently a theme-switching showcase.
> NOT executable.
> **Priority**: 23A 🟡 P1 · 23B ⚪ deferred
> **Depends on**: EPIC-22 (22-D) for 23A; first real pilot + harvest for 23B.

---

## 1. Objective

Make component metadata first-class: every public Prism component carries
explicit visual/interaction/runtime requirements, supported adapters, and
state matrix — and the Catalog evolves from "static showcase" into a
"contract laboratory" (still fixture-backed by default).

## 2. Stories (v8)

| Story | Title | Key deliverable |
|---|---|---|
| S23-01 | Component Contract Schema | component → IDS primitive → runtime contract → fixture/adapter refs; tri-state tag; declaration-only |
| S23-02 | Catalog Upgrade Reuse-First | tri-state Static/Interactive/Connected; reuse-first search order; recurrence evidence |
| S23-03 | Manifest Export | machine-readable manifest; version pins; declared input to EPIC-25 resolver (deferred) |
| S23-04 | Fake-Engine Integration | every Connected entry has passing fake engine; catalog runs on fakes in CI without Rust toolchain |

## 3. Out of Scope

- Real customer backends (Connected mode is optional demo, not production).
- Auto-generated binding code.
- Any direct FRB code in `warp_prism_ui`.

## 4. Exit Conditions

- [ ] Schema doc committed + 3–5 exemplars drafted as validation targets.
- [ ] Catalog tri-state proof documented.
- [ ] Manifest resolution rules accepted by product/owner.
- [ ] CI runs catalog fully on fakes (no Rust toolchain required).
