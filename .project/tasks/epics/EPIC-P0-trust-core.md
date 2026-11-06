---
epic_id: EPIC-P0-trust-core
title: "P0 trust core — fail-closed authority, vocabulary, and proof-backed chrome"
status: active
owner_lane: architects
story_ids: [P0-S01, P0-S02, P0-S03, P0-S04]
task_ids: [1868, 1869, 1870, 1871, 1872, 1873, 1874, 1875, 1876]
---

# Epic EPIC-P0-trust-core: P0 Trust Core

> **Type**: `EPIC` (living program — **not** an executable task)
> **Status**: Active
> **Home**: `.project/tasks/epics/EPIC-P0-trust-core.md` (non-lane)
> **Source**: `.project/research/final-upgrade-backlog-2026-11-01.md` F-01–F-09 (§2 rank table + detail cards), seams S1–S4 + S6–S9 (§1)
> **Governing law**: `MISSION.md` §3.1 (full-coverage mandate — absorption default, recurrence = priority not gate) + §6 items 2–7 (evidence gates stand) + §§4–5,7 (layer contracts, leakage, data/control plane). **MISSION WINS** over pre-amendment prose.

## Objective

Land Warp Prism's P0 trust core: every user-facing action carries an explicit capability outcome (allow/constrain/deny, never hidden-as-inapplicable); every indeterminate state renders as unknown/abstained and fails closed; commands are registry-described and dispatch-guarded; decisions are reviewable with bounded repair; provenance is witnessed with sealed-mode honesty; shell focus survives layout transitions; timeline and transport chrome share injected, ontology-free models. Each surface lands EXPERIMENTAL (spec + fake + suite, no barrel export) and advances only through MISSION §6 gates 2–7. Command-center is the designated real-host proof surface; Warpblade validates weaker-layout seams first; Tempest proves studio/meter/lane.

## Non-goals

- No `warp_prism_av` / satellite split in this wave (backlog §6 — build inside existing owners).
- No time-ontology unification (SMPTE vs bars/beats vs wall-clock stay distinct); no rational-time type, NLE models, calibration, DSP, or orchestration in Prism.
- No app-root/router absorption, persistence, daemon wiring, or product orchestration.
- No donor-only STABLE widgets; no flag-day migration; no speculative templates.
- P1 (F-10–F-19) and P2 (F-20–F-27) are explicitly out — they follow under separate stories/epics once this core lands.

## Stories

| Story ID | Title | File |
|----------|-------|------|
| P0-S01 | Authority + honest-unknown vocabulary | [P0-S01-authority-vocabulary.md](../stories/P0-S01-authority-vocabulary.md) |
| P0-S02 | Command registry + decision-review spine | [P0-S02-command-review-spine.md](../stories/P0-S02-command-review-spine.md) |
| P0-S03 | Provenance family + bootstrap landings | [P0-S03-provenance-bootstrap.md](../stories/P0-S03-provenance-bootstrap.md) |
| P0-S04 | Shell router + timeline + transport chrome | [P0-S04-shell-timeline-transport.md](../stories/P0-S04-shell-timeline-transport.md) |

## Tasks (canonical rollup — prefer story attachment)

- Task 1868 (F-01, via P0-S01)
- Task 1869 (F-02, via P0-S01)
- Task 1870 (F-03, via P0-S02)
- Task 1871 (F-04, via P0-S02)
- Task 1872 (F-05, via P0-S03)
- Task 1876 (F-09, via P0-S03)
- Task 1873 (F-06, via P0-S04)
- Task 1874 (F-07, via P0-S04)
- Task 1875 (F-08, via P0-S04)

## Build order and parallelism

```text
1868 (gate) ∥ 1869 (unknown) ∥ 1875 (transport+formatter) — disjoint writesets
  → 1870 (registry, needs F-01 eligibility shape) + 1873 (shell+focus; batched IDS review with 1868/1870)
    → 1872 (witness/sealed) + 1876 (startup/loading, needs F-02 vocabulary)
      → 1871 (review surface, needs F-01 + F-02) + 1874 (timeline, needs F-08 formatter + F-01 gating; validate WB side first)
```

Whole-upstream waiting applies only where the consumer needs the whole outcome: 1871 waits on 1868+1869 contracts (construction may start on their established interface, integration waits); 1874 waits on 1875's formatter seam. Shared-write guards (`PrismTokenRegistry`/skins, `prism_aliases.dart`/barrels, `boundary_test.dart`, gallery registry, `layer-contracts.md`, `component-catalog.md`) — one owner per invariant per task.

## Success picture

- All nine tasks closed with fake/reference + conformance suite green, boundary clearance, host-composition proof on the designated host, and independent review.
- Zero occurrences of the trust defects that motivated the wave: hidden-as-inapplicable actions, unknown-rendered-as-success, unverified-rendered-as-verified, stack-trace bootstrap leaks.
- IDS stays pure Dart; `warp_prism_ui` imports no runtime/FRB/bindings; every new check lands in `boundary_test.dart` in the same task.
- Every surface EXPERIMENTAL with no barrel export until STABLE criteria (boundary + host proof + review + API freeze) are met.

## Notes

- Consumer citations in the backlog are INHERITED-REPORT (revision UNKNOWN) — builders re-verify `path:line` evidence at execution time; contradiction with live source is reported, not silently amended.
- U-IDS (backlog §5): F-01/F-03/F-06/F-07 give the architecture owner four bounded IDS-scope proposals — batch into one IDS review; record accept/reject as review input.
- U-RECON: `layer-contracts.md` §9 PROVEN row is reconciled (Task 1847); bridge README + token-policy docs still state recurrence — tasks cite MISSION §3.1/§6-item-1 on conflict until reconciled.
