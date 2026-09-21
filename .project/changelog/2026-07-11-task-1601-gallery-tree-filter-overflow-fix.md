---
date: 20260711-163149
timestamp: 20260711-163149
agent: builders
task: "1601"
description: "Changelog — Task 1601 path-to-100 (gallery/catalog overflow fix)"
is_rebuild_safe: true
---

# Changelog — Task 1601 path-to-100 (gallery/catalog overflow fix)

> **Date**: 2026-07-11  
> **Task**: 1601 — Catalog / Gallery Showability Verify + Polish  
> **Trigger**: Independent review S=81 — gallery 15/17 + catalog 8/9 red (stale CE)

## Summary

Fixed Organisms gallery demo overflow that broke gallery smoke and catalog high-text-scale proofs after EPIC-15/16 densified organism fixtures.

## Changes

- **Gallery DSTree fixture** (`design_system_gallery_sections.dart`): wrap expanded provider-tree demo in `SingleChildScrollView` inside the fixed `height: 280` glass viewport so 7+ rows (minHeight 40) no longer RenderFlex-overflow.
- **Gallery FilterWorkbench fixture**: raise demo host to `720×480` for 2.0 text-scale headroom.
- **DSFilterWorkbench organism**: scroll header + criteria together; keep Apply/Clear footer pinned — prevents fixed chrome from exceeding host height at large text scales.

## Validation (live 2026-07-11)

| Command | Result |
| --- | --- |
| `cd packages/warp_prism_ui && flutter test test/gallery/` | **PASS** EXIT 0 — **17/17** |
| `cd packages/warp_prism_ui && flutter test test/organisms/filter_workbench/` | **PASS** EXIT 0 — **10/10** |
| `cd apps/catalog && flutter test` | **PASS** EXIT 0 — **9/9** |
| `cd apps/catalog && dart analyze` | **PASS** — No issues found |
| `dart analyze lib/src/gallery lib/src/organisms/filter_workbench test/gallery` | **PASS** — No issues found |

## Non-goals

- No Widgetbook, no teal rebrand, no registry section id changes, no git, no lane move to `03-review` by executor.
