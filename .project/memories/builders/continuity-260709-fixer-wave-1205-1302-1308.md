---
type: continuity
profile: builders
date: 2026-07-09
tasks: [1205, 1302, 1308]
---

# Continuity — Builder Fixer Wave 1205 / 1302 / 1308

## Current Focus

Path-to-100 remediation for three sequential tasks rejected to `02-doing` on
2026-07-09 independent re-review. **Left in `02-doing`** (no promotion this pass).

## Outcomes

| Task | Prior score | Fix | Ready? |
|---|---|---|---|
| 1205 boundary harness | 86 | Live analyze exit 0 / 158 INFO; evidence 6/6 not 4/4 | YES |
| 1302 public barrel audit | 84 | Manifest + counts: `PrismInsightRiskLevel`; 127/129 | YES |
| 1308 toast lifecycle | 87 | Timer re-resolve by id; pause-on-hover test 41/41 ×3; package EXTERNAL | YES |

## Key paths

- Tasks: `docs/tasks/02-doing/1205-…`, `1302-…`, `1308-…`
- Changelogs: `docs/changelog/20260709-221609-1205-…`, `…-1302-…`, `…-1308-…`
- Manifest: `docs/design/public-barrel-audit.md`
- Toast: `packages/warp_prism_ui/lib/src/molecules/ds_toast_manager.dart`
- Archived: `.archive/docs/tasks/04-completed/1308-…-stale-pre-timer-id-fix-20260709.md`

## Regression guards

- Do not re-claim 880/468 ERROR for package analyze without a live re-run
- Do not re-state 4/4 boundary checks (live is 6/6)
- Do not drop `PrismInsightRiskLevel` from the public barrel manifest
- Do not re-capture list `idx` inside toast Timer callbacks
- Leave package-wide non-toast analyzer residual as EXTERNAL (do not expand 1308 scope)
