# Task 1810: Charter v2 + ADR + AGENTS Alignment

> **Priority**: 🔴 P0 · **Type**: `governance`
> **Origin**: EPIC-19 (S19-01) · Source-Reality Review 2026-09-01
> **Blocks**: None (parallel root; 1811–1814 proceed independently)
> **Depends on**: None (root task)

## Milestone Alignment

- **Target milestone**: M01 — Warp Prism v2: L1 Integration-Capable (`docs/milestones.md`)
- **Capability / Gate advanced**: 19-A foundation — charter/ADR supersession record (prerequisite for all v2 layers)
- **Strategic why**: without an amended charter, every v2 layer (IDS/Runtime/FRB) contradicts the bootstrap-era "no runtime integration" clause; the ADR records the monorepo-level supersession once, in its canonical home.
- **Consequence if absent**: v2 work rests on a stale mission statement; future agents re-litigate the supersession and may treat runtime work as out-of-scope.

## Objective

Amend `docs/design/charter.md` in place to reflect the Warp Prism v2 mission (compositional ADS + IDS + Runtime Integration System with Rust golden path), record the supersession of bootstrap out-of-scope restrictions at monorepo level, and align AGENTS.md §1 scope text — without altering higher-law governance, lane authority, lifecycle, or promotion rules.

## Background Context

### What already exists

- `docs/design/charter.md` — active charter (requires amendment, not parallel).
- `docs/design/black-obsidian-visual-contract.md` — live visual canon.
- `AGENTS.md` §1 — scope text already updated 2026-09-01 to reflect v2 mission.
- `PrismTokenRegistry`, `DSTheme.dark()`, Rajdhani + JetBrainsMono bundling — all landed via EPIC-18.

### What is missing or broken

- Charter text still describes the old "read-only Flutter observatory prototype" mission.
- No Architecture Decision Record captures the v2 supersession of the bootstrap-era "MUST NOT do runtime integration" clause at monorepo level.
- AGENTS.md §1 identity line is already current (2026-09-01) — this task only verifies it; it does not re-edit it.

## Subtasks

- [ ] **Read before modifying**: `docs/design/charter.md`, `AGENTS.md`, `docs/governance/promotion-state-model.md`.
- [ ] **Draft amended charter** in place: new mission statement, ADS+IDS+Runtime triad, Rust golden path as replaceable adapter, supersession note for bootstrap `out-of-scope` at monorepo level, preservation of `warp_prism_ui` purity.
- [ ] **Record ADR** (Context/Decision/Consequences) inside charter or `docs/architecture/adr/`.
- [ ] **Verify AGENTS.md** metadata line (Project + Last Updated 2026-09-01) — already updated, treat as verification-only (do not re-edit).
- [ ] **Do not**: alter lane authority, promotion rules, protected-files list, or parent/child symlink rules.
- [ ] **Simplify pass**: remove unnecessary complexity introduced by this task.
- [ ] **Regression verification**: run validation commands below.

## Validation Commands

```bash
grep -E "compositional|ADS|IDS|Runtime Integration System" docs/design/charter.md
grep -E "Last Updated.*2026-09-01" AGENTS.md
flutter analyze packages/warp_prism_ui
```

## Where

| File | Purpose |
|---|---|
| `docs/design/charter.md` | Amend in place — mission, supersession, preservation |
| `AGENTS.md` | Read / Verify only (§1 metadata already up to date) |
| `docs/architecture/adr/` (if exists) | Record ADR if separate from charter |

## Exit Conditions

- [ ] Charter states v2 mission: visual vocabulary + interaction vocabulary + backend-agnostic runtime contracts with Rust as first-class replaceable adapter.
- [ ] Supersession note: bootstrap `MUST NOT do runtime integration` clause remains invariant *only* for `warp_prism_ui`, superseded at monorepo level.
- [ ] Preservation invariant stated: Prism* public API, DS internal namespace, ADS gallery, package purity, golden/semantics/boundary gates, fixture-first mode preserved.
- [ ] AGENTS.md §1 metadata verified.
- [ ] No governance, lane, or promotion rules altered.
- [ ] Local changelog entry added.

## Completion Evidence

- **Files created/modified**: `docs/design/charter.md` (amended in place: v2 mission + tattoos verbatim + §3.3 supersession/preservation invariants + ADR-0001 (Context/Decision/Consequences) + provenance ledger; 189 lines)
- **Tests or validation commands**:
  - `grep -c "compositional design and integration system"` → 2
  - `grep -c "Rust-first integration golden path"` → 3
  - `grep -cE "supersession|supersed"` → 5
  - `grep -E "Last Updated" AGENTS.md` → `> **Last Updated**: 2026-09-01` (verified, not edited)
  - `wc -l docs/design/charter.md` → 189
- **AGENTS.md verification**: §1 header Project + Last Updated 2026-09-01 + v2 scope text confirmed current — verification-only satisfied, zero edits to AGENTS.md
- **Local changelog entry**: pending parent publication (entry text in builder packet)
- **Executor**: gt-builders-engineer-flutter (builder session, 2026-09-01)
- **Completion date**: 2026-09-01
