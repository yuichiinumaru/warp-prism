---
date: 20260711-120000
timestamp: 20260711-120000
project: warp-prism
agent: gt-flutter-engineer
task: "1506"
description: "Add PrismEntityLocateSearch multi-corpus locate organism (≠ command palette)"
is_rebuild_safe: true
---

# Task 1506: PrismEntityLocateSearch Organism

## Summary

Implemented `DSEntityLocateSearch` with public alias `PrismEntityLocateSearch` —
multi-corpus entity/place locate bar with result list and locate callback.
Emits `PrismLocateResult` (entity id, entity type, optional lat/lng) — explicitly
**not** a `PrismCommandPalette` / command-id clone. Fixture corpora only; no
live geocoder or MapLibre. ADS-first gallery + tests; no product route coupling.

## Changes

- Created `packages/warp_prism_ui/lib/src/organisms/entity_locate_search/`:
  - `ds_entity_locate_search.dart` — corpus/entry/result models, search UI,
    corpus chips, empty/loading states, locate action
  - `entity_locate_search.dart` — barrel export
- Exported from `organisms.dart` (append-only; concurrent organism exports preserved)
- Aliased `PrismEntityLocateSearch`, `PrismLocateCorpus`, `PrismLocateEntry`,
  `PrismLocateResult` in `prism_aliases.dart`
- Minimal gallery case under Organisms (agents + places fixture corpora)
- Widget tests: multi-corpus match, query, select locate payload, clear, empty,
  loading, searchDelay, corpus filter, a11y, false-gap vs `PrismCommand`

## Verification

```bash
cd packages/warp_prism_ui
dart analyze lib/src/organisms/entity_locate_search lib/src/organisms/organisms.dart \
  lib/src/prism_aliases.dart lib/src/gallery/design_system_gallery_sections.dart \
  test/organisms/entity_locate_search
# → No issues found!

flutter test test/organisms/entity_locate_search/
# → All tests passed (12)

dart run test/boundaries/boundary_test.dart
# → Boundary harness: 6/6 PASS
```
