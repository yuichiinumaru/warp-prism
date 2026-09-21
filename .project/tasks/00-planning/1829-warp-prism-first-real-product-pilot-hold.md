# Task 1829: First Real Product Pilot — OmniRoute Provider Vertical

> **Priority**: 🔴 P0 · **Type**: `governance`
> **Origin**: MISSION.md §25 (First Real Product Pilot) + §28 (Automatic Maturity Progression) + EPIC-OR-01 (Provider Pilot as first post-L1 real consumer)
> **Blocks**: Pilot Harvest → L2 Rewrite-Capable gate
> **Depends on**: **Parent/operator authorization** — pilot modifies/serves a real product (OmniRoute), which per AGENTS.md + EPIC-OR precedent (OR-01 precedent) requires parent-repo governance lane open + explicit user authorization. L1 gate complete (1825 PASS) provides the substrate.

## Milestone Alignment

- **Target milestone**: M01 → pilot harvest → L2 evaluation (`docs/milestones.md` post-L1)
- **Capability / Gate advanced**: the only remaining human-gated work — first real product consumer proving L1 contracts in production.
- **Consequence if absent**: L2 gate cannot open (MISSION.md §46 requires one real product vertical + pilot harvest).

## Status

```
HOLD — awaiting parent task governance
```

This task exists to materialize the pilot work explicitly (not to bypass its authorization). It cannot enter `01-open` until:
1. Parent/operator formally authorizes the OmniRoute Provider Pilot per the same OR-01 governance pattern.
2. The consumer scope (which OmniRoute vertical: provider health surface, catalog view, or graph workbench) is selected by the product owner.
3. The pilot's baseline dataset/credentials/env belongs to the operator (OmniRoute requires live parent infra).

## Scope on Activation

- Vertical bounded to ONE OmniRoute surface (provider health / provider catalog / provider workbench — decided at selection by product owner).
- Consumes ALL FOUR runtime contracts through Frb adapters: EventStream, HealthSource, GraphSource, AsyncCommand.
- Exercises IDS Selection/Inspection with real product data; exercises bindings projection.
- Harvest checklist §Part 2 of 1825 report drives the pilot-proof evaluation.

## Completion Evidence

- **[HOLD]** — materialized as HOLD (not execution-ready) per the operator gate.

---

> **Note**: Task identity `1829` — this is the pilot vertical-gating record, not the pilot execution task; execution follows only after operator authorization and consumer selection.