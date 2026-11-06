---
date: 20260927-040000
timestamp: 20260927-040000
project: "warp-prism"
agent: "orchestrator-fenix"
task: "epoch-reset"
description: "Epoch reset part 1 (governance, unsealed): archived 36 stale planning artifacts (EPIC-00..26, EPIC-OR, 1100, 1829, PLAN-03, PLAN-task1807, ROADMAP, STORIES, CANDIDATE, parent-tasks, epics/, docs/ads-to-ids.md) with manifest; rewrote MISSION.md (superseded L0-L3/Rewrite-Factory), amended AGENTS.md (scope, §7.0 temporary brand law, §8, §10.1, §15), rewrote README.md; created docs/architecture/layer-contracts.md, docs/bridge/README.md; synthesized cross-consumer gap matrix (5 two-consumer harvest candidates); repaired onboarding workflow stale refs; regenerated tasklist (199 tasks, 3 open); materialized Tasks 1839/1840/1841. Builders for 1839/1840 provider-blocked (3x each) — awaiting operator CLI fallback. Persistence BLOCKED: seal reports 899MiB blob via retargeted `references` symlink (pre-existing, outside authority)."
is_rebuild_safe: true
---

# Epoch Reset Part 1: Reconcile, Declutter, Inventory, Plan (unsealed)

## Summary

Executed the user-authorized bounded architecture/governance reset up to the
persistence gate. Seven parallel read-only investigators inventoried Warp Prism
ADS, IDS/runtime/bindings/FRB/Rust, Warpblade, Tempest, Sentry, Hyperion, and
the historical corpus. Independent review returned AMEND 88/100 (F1–F9); all
mechanical findings remediated except F7, which is materialized as Task 1841.
A first review pass (BLOCKED 42/100) was set aside after citation audit proved
fabricated line references.

## Changes

- Archived 36 planning artifacts → `.archive/` + `.project/archive/epoch-reset-manifest.md`.
- `MISSION.md`: rewritten (348 lines; L0–L3 + Rewrite Factory superseded in §11).
- `AGENTS.md`: amended (consumer family, §7.0 temporary brand law per owner order, §8 onboard, §10.1 program target, §15 stop conditions, fixed broken rule/session paths).
- `README.md`: rewritten as arrival page.
- `docs/architecture/layer-contracts.md`: created (normative matrix + 16-check harness list).
- `docs/bridge/README.md`: created (harvest loop + classification vocabulary).
- `docs/reports/2026-09-27-cross-consumer-gap-matrix.md`: created (28-row matrix, 5 harvest candidates, conflicting-semantics section).
- `docs/design/charter.md`: refreshed to v2.1 (consumer family, real topology).
- `.agents/workflows/wp-warp-prism-onboarding.md`: repaired stale MISSION sections, layer-contracts path, tasklist path, report/session paths.
- `.project/tasks/tasklist.md`: regenerated (Open 3, Review 4, Planning 2, Completed 191).
- Tasks materialized in `01-open/`: 1839 (brand rename), 1840 (StatusTicker overflow + ListTile warnings, from operator live run), 1841 (doc-comment path sweep).
- Session ledger updated with 12 epoch-reset sessions.

## Validation

- Light verification pass by grep: zero dead planning paths in tasklist (EPIC-18 row is live), zero stale `docs/reports/1805` paths, zero archived-EPIC citations in current-authority docs, all manifest section pointers resolve, all onboarding/AGENTS referenced paths exist.
- Flutter/Dart test suites NOT run in this pass (governance-only mutations + provider-blocked builders).

## Open blockers

1. **Persistence**: `seal_checkpoint inspect` → BLOCKED (`blob-size`: ~899 MiB blob swept via the retargeted `references` symlink, a pre-existing worktree change from 2026-09-23 outside this pass's authority). Nothing sealed. Operator action required.
2. **Builders**: Tasks 1839/1840 sessions failed 3× on provider errors. Operator CLI fallback required (see reset report).
3. **Human gates (unchanged)**: Task 1805 visual sign-off; Task 1816 follows it.
