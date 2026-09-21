---
date: 20260718-051900
timestamp: 20260718-051900
project: warp-prism
agent: gt-flutter-engineer
task: "1505"
description: "Path-to-100 PrismEntityIntelPanel format + gallery SelectChip 48dp"
is_rebuild_safe: true
---

# Task 1505: PrismEntityIntelPanel Path-to-100

## Summary

Remediated REJECT 85/100 review findings for `PrismEntityIntelPanel`: format
gate clean on owned surfaces; gallery `_SelectChip` uses
`kMinInteractiveDimension` (48dp). Organism chrome already met 48dp via
IconButtons. Mode/registry contract only — no NewsFeed megafile port.
Revalidated live 2026-07-18.

## Changes

- Gallery `_SelectChip` → `BoxConstraints(minHeight/minWidth: kMinInteractiveDimension)`
- Format pass on entity_intel_panel + shared organism/alias/gallery surfaces

## Verification

```bash
cd packages/warp_prism_ui
dart format --output=none --set-exit-if-changed \
  lib/src/organisms/filter_workbench lib/src/organisms/entity_intel_panel \
  lib/src/organisms/organisms.dart lib/src/prism_aliases.dart \
  lib/src/gallery/design_system_gallery_sections.dart \
  test/organisms/filter_workbench test/organisms/entity_intel_panel
# → Formatted 9 files (0 changed); exit 0

dart analyze lib/src/organisms/entity_intel_panel test/organisms/entity_intel_panel
# → No issues found!

flutter test test/organisms/filter_workbench/ test/organisms/entity_intel_panel/
# → +22: All tests passed! (11 entity intel)

dart run test/boundaries/boundary_test.dart
# → Boundary harness: 7/7 PASS
```
