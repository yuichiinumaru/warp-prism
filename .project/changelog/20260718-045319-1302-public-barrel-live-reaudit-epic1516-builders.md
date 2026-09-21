---
date: 20260718-045319
timestamp: 20260718-045319
project: "warp-prism"
agent: gt-flutter-engineer
task: "1302"
description: "Live re-audit public barrel after Epic 15/16 — 263 Prism + 4 gallery"
is_rebuild_safe: true
scope: "warp-prism-ui/barrel"
type: "governance"
---

# Task 1302: Public Barrel Live Re-Audit (Epic 15/16)

## Summary

Regenerated `docs/design/public-barrel-audit.md` from live
`packages/warp_prism_ui/lib/src/prism_aliases.dart` after drain review (58/100)
found the manifest frozen at 129 Prism symbols while source held 262+.

## Live Findings (2026-07-18)

- **Barrel exports**: still 4 (`prism_aliases` + 3 gallery; `hide DSGallery*`)
- **Prism API**: **263** (262 typedef + 1 extension)
  - Production: 256
  - Experimental drag-drop: 5
  - Gallery Prism aliases: 2
- **Non-Prism gallery entrypoints**: **4**
  (`DesignSystemGalleryPage`, `dsGallerySections`, `dsGallerySectionIds`,
  `dsGallerySectionTitles`)
- **Total public top-level**: **267**
- **DS* layer barrels exported**: 0
- **Source ↔ audit set equality**: 0 missing, 0 extra
- **Boundary harness**: **7/7 PASS**
- **Scoped analyze** (`warp_prism_ui.dart` + `prism_aliases.dart`): No issues

## Supersedes

| Frozen claim | Live 2026-07-18 |
|---|---|
| 127 / 129 / 131 public | **263 Prism / 267 total** |
| typedef 126–128 | **262** |
| harness 6/6 | **7/7** |
| missing Epic 15/16 organisms | **listed + classified** |

## Guardrails Honored

- No export removals
- Four-export barrel retained
- DSGallery* remains hidden
---