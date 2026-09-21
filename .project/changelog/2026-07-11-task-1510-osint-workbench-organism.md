---
date: 20260711-180000
timestamp: 20260711-180000
project: warp-prism
agent: gt-flutter-engineer
task: "1510"
description: "Add PrismOsintWorkbench tabbed recon organism (fixtures + map handoff)"
is_rebuild_safe: true
---

# Task 1510: PrismOsintWorkbench Organism

## Summary

Implemented `DSOsintWorkbench` with public alias `PrismOsintWorkbench` —
tabbed recon workbench with tool registry, query submit, session history,
structured fixture results, and optional map handoff when a result carries
geo coordinates. Fixture/in-memory adapters only; no live OSINT APIs, API
keys, or MapLibre. Harvests **mode contract** from Osiris `OsintPanel` /
ShadowBroker `ReconPanel` — not megafile structure. ADS-first gallery +
tests; no product route coupling.

## Changes

- Created `packages/warp_prism_ui/lib/src/organisms/osint_workbench/`:
  - `ds_osint_workbench.dart` — tool/result/history/handoff models,
    `DSOsintFixtures` resolvers, workbench UI
  - `osint_workbench.dart` — barrel export
- Exported from `organisms.dart` (append-only)
- Aliased `PrismOsintWorkbench`, `PrismOsintTool`, `PrismOsintResult`,
  `PrismOsintResultField`, `PrismOsintHistoryEntry`, `PrismOsintMapHandoff`,
  `PrismOsintFixtures`, `PrismOsintFixtureResolver` in `prism_aliases.dart`
- Minimal gallery case under Organisms (DNS + IP + WHOIS fixtures; map handoff
  status line documents no live keys)
- Widget tests: tool tabs, submit, empty results, history re-run, map handoff,
  loading, a11y

## Verification

```bash
cd packages/warp_prism_ui
dart analyze lib/src/organisms/osint_workbench test/organisms/osint_workbench
# → No issues found!

flutter test test/organisms/osint_workbench/
# → All tests passed (12)

dart run test/boundaries/boundary_test.dart
# → Boundary harness: 6/6 PASS
```
