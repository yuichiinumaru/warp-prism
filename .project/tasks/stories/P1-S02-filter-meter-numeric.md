---
epic_id: EPIC-P1
story_id: P1-S02
title: "Filter builder + meter/fader + numeric EXPERIMENTAL"
status: active
task_ids: [1860, 1861, 1881]
---

# Story P1-S02: Filter Builder + Meter/Fader + Numeric EXPERIMENTAL

> **Type**: `STORY` (scoped slice — **not** an executable task)
> **Epic**: [EPIC-P1](../epics/EPIC-P1-compound.md)
> **Home**: `.project/tasks/stories/P1-S02-filter-meter-numeric.md` (non-lane)
> **Template**: `.project/tasks/templates/story.md`

---

## Objective

Deliver the P1 construction primitives with real anchors: filter-builder +
toolbar-panel framework (F-12), meter geometry + fader strip + narrow
canvas-host contract (F-13), and the EXPERIMENTAL numeric field with
`Set|Scrub` commit typing (F-14) — each with fake + per-type conformance,
determinism, and a11y numeric (never colour-only) evidence.

## Scope

### In scope

- F-12: organism `PrismFilterBuilder` (nested AND/OR, per-type editors,
  debounce-commit+flush) + `PrismToolbarPanel` framework
  (button→popover→typed-panel→reanchor) over the `PrismFilterWorkbench`
  anchor. No new table/grid/board primitive.
- F-13: atom `PrismMeter` (injected scale + zone thresholds) + molecule
  `PrismFaderStrip` + narrow generic canvas-host contract (fixed-viewport
  determinism, bounded data, a11y numeric fallback).
- F-14: atom `PrismNumericField` EXPERIMENTAL (`Set|Scrub` in type, quantum,
  modifier rates, release-frame no-op) + ported donor parse table suite.
  No STABLE/barrel until host adoption.

### Out of scope

- Calibration constants, LUFS targets, RMS windowing, FFT/spectral/
  goniometer painters, DSP chains (stay product-local per §4.5).
- Audition/compare matrix and descriptor form (P2 F-20/F-21).
- Any audio type in `warp_prism_ui` (boundary B14/B4 forbid it).

## Tasks (canonical)

**IDs only.** Never write mutable lane paths here.

- Task 1860
- Task 1861
- Task 1881

Frontmatter `task_ids` should match this list when both are used.

## Path projection (generated)

<!-- task-path-sync:start -->
| ID | Title | Path |
|----|-------|------|
| 1860 | PrismFilterBuilder organism plus PrismToolbarPanel framework | [1860](../01-open/1860-warp-prism-filter-builder-toolbar-panel.md) |
| 1861 | PrismMeter atom plus PrismFaderStrip molecule and canvas-host contract | [1861](../01-open/1861-warp-prism-meter-fader-canvas-host.md) |
| 1881 | PrismNumericField atom EXPERIMENTAL with Set\|Scrub commit typing | [1881](../01-open/1881-warp-prism-numeric-field-experimental.md) |
<!-- task-path-sync:end -->

## Acceptance (story level)

- [ ] All listed tasks through review/completed as required by the program
- [ ] Scope frozen or explicit successor story linked
- [ ] F-12 host proof in Tempest library/models route + Command-center
  session list; F-13 fixed-value goldens + host proof in Tempest studio route
- [ ] F-14 ships EXPERIMENTAL proof-lab only, with junk-sweep conformance
  green and zero STABLE/barrel claims
