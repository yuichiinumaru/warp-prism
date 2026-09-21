---
date: 20260718-052041
timestamp: 20260718-052041
project: "warp-prism"
agent: gt-flutter-engineer
task: "1302"
description: "Live re-audit public barrel — 274 Prism + 4 gallery (closed +11 drift after 263 freeze)"
is_rebuild_safe: true
scope: "warp-prism-ui/barrel"
type: "governance"
---

# Task 1302: Public Barrel Live Re-Audit (+11 post-263)

## Summary

Prior same-day path-to-100 freeze claimed **263** Prism / **267** total. Live
`prism_aliases.dart` now has **273 typedef + 1 extension = 274** Prism symbols
(+11). Regenerated `docs/design/public-barrel-audit.md` with set equality proof.

## Live Findings (2026-07-18 session 2)

- **Barrel exports**: still 4 (`prism_aliases` + 3 gallery; `hide DSGallery*`)
- **Prism API**: **274** (273 typedef + 1 extension)
  - Production: 265
  - Experimental drag-drop: 7 (live surface: DraggableCard/DropTarget/events/intents/payload)
  - Gallery Prism aliases: 2
- **Non-Prism gallery entrypoints**: **4**
- **Total public top-level**: **278**
- **DS* layer barrels exported**: 0
- **Source ↔ audit set equality**: 0 missing, 0 extra
- **Boundary harness**: **7/7 PASS**
- **Scoped analyze** (`warp_prism_ui.dart` + `prism_aliases.dart`): No issues

## +11 symbols since 263 freeze

`PrismKeyboardCheatsheet`, `PrismKeyboardCheatsheetFixtures`,
`PrismKeyboardShortcut`, `PrismKeyboardShortcutGroup`,
`PrismMediaDetailFixtures`, `PrismMediaDetailItem`, `PrismMediaDetailOverlay`,
`PrismScaleMeasureBar`, `PrismScaleMeasureBarFixtures`, `PrismScaleSegment`,
`PrismToastRiskTier`

## Supersedes

| Prior claim (session 1) | Live session 2 |
|---|---|
| 263 Prism / 267 total | **274 Prism / 278 total** |
| typedef 262 | **273** |
| Experimental drag 5 (stale names) | **7** live drag surface |
| harness 7/7 | **7/7** (re-proved) |

## Guardrails Honored

- No export removals; no Dart production code changed
- Four-export barrel retained
- DSGallery* remains hidden
---
