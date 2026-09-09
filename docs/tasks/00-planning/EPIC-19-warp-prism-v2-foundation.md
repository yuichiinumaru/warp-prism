# EPIC 19 — Warp Prism v2 Foundation

> **Planning Status**: Draft — source-reality reviewed 2026-08-31 (see `docs/reports/warp-prism-v2-source-reality-review-2026-08-31.md`). Verdict: **EXECUTION CANDIDATE** (S19-03 rewritten; S19-04 topology reduced; S19-05 state-based; S19-06 merged with 1805 gate). Awaiting 19-gate sign-off. NOT executable yet.
> **Executable?**: No (planning artifact only).
> **Priority**: 🔴 P0
> **Owner for approval**: Product + Architect orchestrator.
> **Origin**: `docs/ads-to-ids.md` (hypothesis corpus) — falsified against repo reality 2026-08-31.
> **Depends on**: EPIC-18 closure gates ONLY visual-baseline-dependent work (goldens v2, screenshot acceptance, UI-visible acceptance, 19-E baseline freeze). It does NOT gate charter, boundaries, topology, or IDS/runtime planning. 03-review W1 drain (see `PLAN-03-review-drain.md`) must complete before 19-E only, not before 19-A/B/C.
> **Blocks**: EPIC-20 and EPIC-21 (both in PARALLEL after 19-gate), EPIC-22, and any FRB/Rust experiments.

---

## 1. Objective

Institutionally close Warp Prism's v1 epoch by writing the new constitution
(ADS + IDS + Runtime Integration System) without mutating code. Establish the
boundary that `warp_prism_ui` remains visually pure, while new layers for
interaction semantics and runtime contracts are chartered but not built.

**Framing sentences to tattoo verbatim in the Charter (per transcript L13648-L13653):**
- "Warp Prism is a compositional design and integration system for Flutter applications: a visual vocabulary, an interaction vocabulary, and a small set of runtime contracts with a Rust-first integration golden path."
- "It does not implement application backends. It standardizes the interfaces through which applications expose backend capabilities to UI."

## 2. Background Context

### Existing — verified 2026-08-31 (source reality)
- `docs/design/charter.md` ALREADY EXISTS (amend in place, do not create parallel).
- `docs/design/black-obsidian-visual-contract.md` live; `PrismTokenRegistry` + `DSTheme.dark()` full M3 factory + `PrismThemeEditor` + Rajdhani fonts + `apps/*/integration_test/` all LANDED via EPIC-18 work (in `03-review`, drain pending).
- Mature `warp_prism_ui` (flutter-only deps, 1417-line alias file, 100+ Prism typedefs, 7 boundary checks). ~296 public `Prism*` symbols.
- NO rust/, NO interaction/runtime packages, NO skills of its own (parent symlinked). Root has ~22 scratch files (`fix_*/tmp_*/patch_*/append_*/snippet_*/test_*.dart`).

## 3. Stories (validated decomposition — see story packet v8)

| Story | Title | Key deliverable | 2026-08-31 verdict |
|---|---|---|---|
| S19-01 | Charter v2 + ADR | AMEND existing `docs/design/charter.md` in place; tattoos; supersession; preservation | AMEND (charter exists; AGENTS.md edits = protected file, need explicit user authorization) |
| S19-02 | Layer-Contracts Matrix | MUST/MAY/MUST-NOT matrix + Global MUSTs + Domain Leakage Rule + dependency law; phased harness enforcement (3 checks now, 7 later) | ACCEPT |
| S19-03 | Integration-Gateway Policy | **REWRITTEN** (was section/lobe = Ganthritor harness contamination): reusable UI↔runtime semantic → candidate Warp Runtime Contract; domain-specific semantic → MAY remain product-local; bypass is a FEATURE | REJECT-as-was / REWRITE |
| S19-04 | Package Topology Acceptance | Packages naming; Rust = **2 crates** (`rust/warp_bridge_core/` w/ modules command/events/health/graph + `rust/warp_bridge_frb/`); *concept ≠ crate*; Cargo placement = OPEN ADR at 22-B; skill topology → parent handoff | AMEND (topology reduced) |
| S19-05 | State-Based Declutter + Root Hygiene | CURRENT = all non-terminal tasks + active planning + canon + active evidence; HISTORICAL = terminal + superseded + old waves; root sweep of ~22 files; NOT epic-number-based; **does NOT depend on Task 1805** | AMEND (state-based, not number-based) |
| S19-06 | Post-1805 Visual/Baseline Freeze | Baseline freeze happens post-approval, not as parallel artifact; **depends on Task 1805 human visual gate (EXTERNAL HUMAN BLOCKER)** | AMEND (split from 19-D per A2, 2026-09-01) |

## 4. Out of Scope

- Any implementation of IDS/Runtime/FRB.
- Any renaming or reorganizing of existing package structure.
- Any Rust code.
- Any task moves (historical declutter defines rules only).

## 5. Exit Conditions (planning-epic gates)

- [ ] Charter v2 ADR written + product + architect sign-off recorded.
- [ ] Layer-contracts matrix committed under `docs/architecture/`.
- [ ] Integration-gateway policy committed under `docs/governance/`.
- [ ] Package/crate/skill topology accepted; no phantom dirs.
- [ ] Historical-declutter scope documented without moving 126 `04-completed` tasks.
- [ ] Baseline snapshot report exists and is linked from this epic.
- [ ] Explicit statement that EPIC-18 remains parent of visual behavior through its review until closure.

## 6. Validation (planning-only)

- Human/reviewer approval recorded; decision log entry produced.
- No code changes; validated by reading current `docs/design/*`, `docs/architecture/*`, `docs/governance/*`.

## 7. Dependencies / Kill Conditions

- EPIC-18 closure gates ONLY: visual baseline v2, goldens regeneration, screenshot acceptance, UI-visible acceptance, 19-E baseline freeze. Charter/boundaries/topology/IDS-runtime planning proceed independently.
- 03-review W1 drain (esp. Task 1805 human screenshot sign-off) must complete before 19-E only, not before 19-A/B/C.
- Must be promoted only by owner after reasoned acceptance; no auto-start for EPIC-20/21 merely because EPIC-19 exists.
- Open user decisions blocking 19-A: AGENTS.md identity/scope edit authorization (protected file).

## 8. Evidence pointers

- Transcript source: `docs/ads-to-ids.md` (L12192+, L13217+, L13725+, L14383+)
- Current governance: `docs/design/`, `docs/governance/`, `.agents/rules/41-task-artifact-contract.md`
