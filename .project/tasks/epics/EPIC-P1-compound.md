---
epic_id: EPIC-P1
title: "P1 compound wave — jobs, runtime bindings, filter/meter/numeric, convergence, proofs, composer, harness"
status: active
owner_lane: architects
story_ids: [P1-S01, P1-S02, P1-S03]
task_ids: [1858, 1859, 1860, 1861, 1881, 1882, 1883, 1884, 1866, 1867]
---

# EPIC P1: P1 Compound Wave (F-10..F-19)

> **Type**: `EPIC` (living program — **not** an executable task)
> **Status**: Active
> **Home**: `.project/tasks/epics/EPIC-P1-compound.md` (non-lane)
> **Template**: `.project/tasks/templates/epic.md`

---

## Objective

Land the P1 tranche of the final upgrade backlog
(`.project/research/final-upgrade-backlog-2026-11-01.md`, F-10..F-19):
jobs + runtime bindings, filter/toolbar + meter/fader + numeric EXPERIMENTAL,
token/shell + session/panel convergence sweeps, Graph/Health first-host proofs,
composer EXPERIMENTAL, and the harness upgrades that de-risk everything else.
Every mandate-covered UI component is absorbed or unified per MISSION §3.1 +
§11.4; recurrence prioritizes but never gates; evidence gates §6 items 2–7
stand on every item.

## Non-goals

- No P0 rework (F-01..F-09 live in their own program); P1 tasks inherit P0
  contracts read-only and never relitigate them.
- No `warp_prism_av` / `warp_prism_audio_ui` package split in this wave —
  build inside existing owners; split only when an import graph forces it.
- No time-ontology unification, no rational-time type, no DSP calibration /
  painters in Prism, no app-root absorption, no persistence, no flag-day
  migration (see backlog §6).
- No STABLE promotion inside this epic: every new primitive enters
  EXPERIMENTAL (spec + fake + suite, no barrel export) and advances only via
  MISSION §6 gates.
- No speculative templates/scaffolds; no transitive-coverage claims for
  either layer checker; no zero-copy claims without measured product evidence.

## Stories

| Story ID | Title | File |
|----------|-------|------|
| P1-S01 | Jobs + runtime executor and stream/health bindings | [P1-S01-jobs-runtime.md](../stories/P1-S01-jobs-runtime.md) |
| P1-S02 | Filter builder + meter/fader + numeric EXPERIMENTAL | [P1-S02-filter-meter-numeric.md](../stories/P1-S02-filter-meter-numeric.md) |
| P1-S03 | Convergence sweeps + graph/health proofs + composer + harness | [P1-S03-convergence-proofs-harness.md](../stories/P1-S03-convergence-proofs-harness.md) |

## Tasks (canonical, rollup)

IDs only — canonical homes are the stories.

- Task 1858 (F-10 job banner + terminal receipt)
- Task 1859 (F-11 AsyncJobExecutor + terminality + stream/health binding)
- Task 1860 (F-12 filter builder + toolbar-panel framework)
- Task 1861 (F-13 meter + fader strip + canvas-host contract)
- Task 1881 (F-14 numeric field EXPERIMENTAL + Set|Scrub typing)
- Task 1882 (F-15 token + shell convergence sweep)
- Task 1883 (F-16 session/list/detail + event-stream + panel convergence)
- Task 1884 (F-17 Graph/Health first-host proofs, DAG-gated)
- Task 1866 (F-18 composer organism EXPERIMENTAL)
- Task 1867 (F-19 harness upgrades: layer-table + capture + drain/cancel + junk sweeps + toast policy)

## Path projection (generated)

<!-- task-path-sync:start -->
| ID | Title | Path |
|----|-------|------|
| 1858 | PrismJobBanner molecule with staged progress, cancel, and terminal receipt | [1858](../01-open/1858-warp-prism-job-banner-receipt.md) |
| 1859 | AsyncJobExecutor identity plus terminality standard and EventStream/HealthSource bindings | [1859](../01-open/1859-warp-prism-async-job-executor-bindings.md) |
| 1860 | PrismFilterBuilder organism plus PrismToolbarPanel framework | [1860](../01-open/1860-warp-prism-filter-builder-toolbar-panel.md) |
| 1861 | PrismMeter atom plus PrismFaderStrip molecule and canvas-host contract | [1861](../01-open/1861-warp-prism-meter-fader-canvas-host.md) |
| 1881 | PrismNumericField atom EXPERIMENTAL with Set\|Scrub commit typing | [1881](../01-open/1881-warp-prism-numeric-field-experimental.md) |
| 1882 | Token and shell convergence sweep onto Prism primitives | [1882](../01-open/1882-warp-prism-token-shell-convergence.md) |
| 1883 | Session/panel/screen convergence onto existing Prism compositions | [1883](../01-open/1883-warp-prism-session-panel-convergence.md) |
| 1884 | Graph/Health first-host proofs, DAG-gated (no host means HOLD with evidence) | [1884](../01-open/1884-warp-prism-graph-health-first-host-proofs.md) |
| 1866 | PrismComposer organism EXPERIMENTAL (autogrow, mentions, attachments, drafts) | [1866](../01-open/1866-warp-prism-composer-experimental.md) |
| 1867 | Harness upgrades — layer-table compaction, two-tier capture, drain/cancel, junk sweeps, toast policy | [1867](../01-open/1867-warp-prism-harness-upgrades-capture-nets-toast.md) |
<!-- task-path-sync:end -->

## Success picture

- [ ] All ten tasks carry fake/reference + conformance suite, boundary
  clearance, and independent review (MISSION §6 items 2–4, 7).
- [ ] Host-composition proof exists wherever a change can materially affect a
  real host (M §6 item 5); FRB lifecycle proof wherever the FRB boundary is
  crossed (M §6 item 6).
- [ ] F-14 / F-18 remain EXPERIMENTAL with no barrel export until a second
  host adopts; F-17 stays HOLD-gated until a real DAG host exists.
- [ ] F-15 / F-16 converge Tempest tokens/shell and session/panel surfaces
  onto existing Prism primitives with real-host exercise evidence.
- [ ] F-19 harness items land first where independent; no existing suite goes
  red through migration.

## Notes

- Source law: backlog `§2` detail cards (F-10..F-19) + `§7` build order;
  macro-review clusters C2/C5/C6/C8/C9/C10; MISSION §§3.1, 4–7, 11.4;
  layer-contracts §§1–10.
- Sibling-safe parallelism: F-10 ∥ F-12 ∥ F-13 disjoint owners; F-11 runtime
  independent of ADS lanes; shared-write guards (`PrismTokenRegistry`, skins,
  `prism_aliases.dart`, barrels, `boundary_test.dart`, gallery registry,
  `layer-contracts.md`, `component-catalog.md`) keep one owner per invariant.
- F-17's blocking premise (no observed consumer DAG surface) is sourced, not
  invented; the task records the HOLD condition and validates it at kickoff.
