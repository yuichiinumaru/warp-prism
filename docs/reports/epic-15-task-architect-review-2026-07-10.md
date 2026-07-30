# EPIC-15 Task Architect Review — 2026-07-10

## What landed

| Item | Path / count |
| --- | --- |
| Epic | `docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md` |
| Harvest inputs | `docs/reports/ads-organism-harvest-{unified,shadowbroker,osiris}-2026-07-10.md` |
| Executable tasks | **24** in `docs/tasks/01-open/` — Tasks **1500–1523** |
| Lane | All `Open` / Review State `Open` (not promoted to doing) |

## Structural audit (parent)

| Check | Result |
| --- | --- |
| Template sections (Where, Exit, Validation, Completion Evidence) | **24/24 PASS** |
| ≥50 lines | **24/24 PASS** (144–186 lines) |
| First subtask “Read existing code” | **24/24 PASS** |
| Flutter/Dart gates (not cargo) | **PASS** |
| Origin EPIC-15 + harvest paths | **PASS** |
| ADS-first / no MapLibre / fixture-first | **PASS** (encoded in organism tasks) |
| O-23 MeshComms | Correctly **not tasked** (deferred) |

## Parent improvements applied after architect draft

| Change | Why |
| --- | --- |
| Softened hard deps on Task 1501 for 1503, 1509, 1512, 1514, 1516 | Parallel waves A/B/D/F/G must not serialize on full HUD workspace |
| Task 1519 hard-depends only **A–F** (1501–1513); G–H soft/deferred matrix | Gallery audit must not wait on terminal/agent shells |
| Task 1520 goldens minimum A–F | Same progressive closeout |
| Task 1513 also depends Task 1500 | Inventory lock applies |
| Task 1500 Blocks clarified | Full 1501–1523 set + soft-edge notes |
| Epic candidate table deps updated | Match open-lane truth |

## Recommended start order (unchanged intent)

1. **1500** inventory brief  
2. **Wave A**: 1501 ∥ 1502  
3. **Wave B**: 1503 ∥ 1504  
4. **Wave C**: 1505 ∥ 1506  
5. Then D→E→F→G→H, cross 1519→1520→1521, optional I  

## Verdict

**ACCEPT with notes** — tasks are promotion-ready for builders after Task 1500. Parent review fixed dependency fan-out so EPIC-15 can execute in true waves.

*No tasklist rebuild, no git commit, no 04-completed moves in this session.*
