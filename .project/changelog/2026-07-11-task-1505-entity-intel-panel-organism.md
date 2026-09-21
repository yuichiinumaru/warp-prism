---
date: 20260711-120000
timestamp: 20260711-120000
project: warp-prism
agent: gt-flutter-engineer
task: "1505"
description: "Add PrismEntityIntelPanel pluggable dossier registry organism"
is_rebuild_safe: true
---

# Task 1505: PrismEntityIntelPanel Organism

## Summary

Implemented `DSEntityIntelPanel` with public alias `PrismEntityIntelPanel` —
pluggable dossier registry host that resolves a body builder by selection type.
Composes the `DSDetailInspector` header pattern (optional full inspector wrap),
fixture models for ≥2 dossier types, gallery case, and widget tests. Mode
contract only — **not** a structural port of NewsFeed / OsintPanel megafiles.
ADS-first; no product route coupling.

## Changes

- Created `packages/warp_prism_ui/lib/src/organisms/entity_intel_panel/`:
  - `ds_entity_intel_panel.dart` — selection model, dossier registration,
    panel host, empty/unknown states, pin/close a11y, fixtures
  - `entity_intel_panel.dart` — barrel export
- Created `packages/warp_prism_ui/test/organisms/entity_intel_panel/entity_intel_panel_test.dart`
- Exported from `organisms.dart` (append-only; concurrent organism exports preserved)
- Aliased `PrismEntityIntelPanel`, `PrismEntitySelection`, `PrismEntityIntelDossier`,
  `PrismEntityIntelBodyBuilder`, `PrismEntityIntelFixtures` in `prism_aliases.dart`
- Minimal gallery case under Organisms (≥2 types: agent + region, plus empty/unknown)

## Verification

```bash
cd packages/warp_prism_ui
dart analyze lib/src/organisms/entity_intel_panel lib/src/organisms/organisms.dart \
  lib/src/prism_aliases.dart lib/src/gallery/design_system_gallery_sections.dart \
  test/organisms/entity_intel_panel
# → No issues found

flutter test test/organisms/entity_intel_panel/
# → All tests passed (11)

dart run test/boundaries/boundary_test.dart
# → Boundary harness: 6/6 PASS
```
