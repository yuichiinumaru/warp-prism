---
epic_id: EPIC-P0-trust-core
story_id: P0-S04
title: "Shell router + timeline + transport chrome"
status: active
task_ids: [1873, 1874, 1875]
---

# Story P0-S04: Shell Router + Timeline + Transport Chrome

> **Type**: `STORY` (scoped slice — **not** an executable task)
> **Epic**: [EPIC-P0-trust-core](../epics/EPIC-P0-trust-core.md)
> **Home**: `.project/tasks/stories/P0-S04-shell-timeline-transport.md` (non-lane)
> **Source**: backlog seams S9 (shell+focus+sidebar) + S7 (timeline+verbs+commit) + S3 (transport+formatter); F-06 (I=60) + F-07 (I=60) + F-08 (I=45).

## Objective

Multi-pane shell routing with Draw-derived focus restoration, timeline chrome with pure-Dart intent verbs under a cross-cluster commit invariant, and transport chrome with injected formatters — three chrome surfaces sharing one discipline: semantics in IDS, mechanics in ADS, domain math/painters product-local.

## Scope

### In scope

- IDS shell-slot machine + focus-return token + `PrismShellRouter` + `PrismSidebar` section-model extension (Task 1873).
- `PrismMultitrackTimeline` (`PrismTimeRuler` + `PrismTrackLane` + playhead) + IDS `TimelineIntent` verbs + one-gesture-one-history-step commit invariant (Task 1874).
- `PrismTransportBar` + `PrismTimecodeBadge`/`PrismTimebaseBadge` + injected `formatTime`/`formatRange` (Task 1875).

### Out of scope

- Time-ontology unification; musical-grid math, DSP/insert chains, calibration, FFT/spectral/goniometer painters — product-local.
- Sidebar drag-orchestration backends, app roots/routers — product-local.
- WB single-column layout is negative evidence for shell (not counted as proof).

## Tasks (canonical)

- Task 1873
- Task 1874
- Task 1875

Frontmatter `task_ids` matches this list.

## Path projection (generated)

<!-- task-path-sync:start -->
| ID | Title | Path |
|----|-------|------|
| 1873 | Shell-slot router + Draw-derived focus + sidebar section model (F-06) | [1873](../01-open/1873-warp-prism-shell-router-focus-sidebar.md) |
| 1874 | Timeline chrome + IDS verbs + commit invariant (F-07) | [1874](../01-open/1874-warp-prism-timeline-chrome-verbs-commit.md) |
| 1875 | Transport bar + injected formatter + timecode badges (F-08) | [1875](../01-open/1875-warp-prism-transport-bar-formatter-badges.md) |
<!-- task-path-sync:end -->

## Acceptance (story level)

- [ ] All three tasks closed with independent review; IDS purity held for slot machine, verbs, commit invariant.
- [ ] Two-ontology conformance (seconds AND bars/beats) + pixel↔time determinism for timeline; formatter-injection + determinism for transport; focus-restoration conformance for shell.
- [ ] Host proof: shell on CC (only real multi-pane host); timeline WB-first then TP; transport both WB + TP.
- [ ] No STABLE/barrel promotion — all land EXPERIMENTAL.
