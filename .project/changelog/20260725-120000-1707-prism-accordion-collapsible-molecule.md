---
date: 20260725-120000
timestamp: 20260725-120000
project: warp-prism
agent: builders
task: "1707"
description: "Implement DSAccordion / PrismAccordion collapsible molecule with obsidian glass panel, title header, icon rotation animation, content slot, single/multiple section expansion modes, and disabled section support"
is_rebuild_safe: true
---

# Task 1707: PrismAccordion Molecule Implementation

## Summary

Implemented `DSAccordion` / `PrismAccordion` collapsible molecule in `warp_prism_ui` for collapsible content section display, supporting single and multi-expand modes, animated chevron rotation (180° via `AnimatedRotation`), `AnimatedSize` content expansion, disabled section support, empty content fallback state surface, and gallery demonstrations.

## Changes

- Created `packages/warp_prism_ui/lib/src/molecules/accordion/ds_accordion.dart` (`DSAccordion` widget + `DSAccordionItem` model + `DSAccordionSection` typedef).
- Created barrel file `packages/warp_prism_ui/lib/src/molecules/accordion/accordion.dart`.
- Re-exported accordion barrel from `packages/warp_prism_ui/lib/src/molecules/molecules.dart`.
- Registered `typedef PrismAccordion = DSAccordion;`, `typedef PrismAccordionItem = DSAccordionItem;`, and `typedef PrismAccordionSection = DSAccordionSection;` in `packages/warp_prism_ui/lib/src/prism_aliases.dart`.
- Updated public barrel audit table in `docs/design/public-barrel-audit.md`.
- Added interactive gallery demonstration in `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`.
- Added comprehensive unit and widget tests in `packages/warp_prism_ui/test/molecules/accordion/ds_accordion_test.dart`.

## Verification

- `cd packages/warp_prism_ui && dart analyze lib/src/molecules/accordion/ test/molecules/accordion/`: 0 issues found.
- `cd packages/warp_prism_ui && flutter test test/molecules/accordion/ --concurrency=1 --no-pub`: All 8 tests passed.
- `cd packages/warp_prism_ui && dart run tool/verify_public_barrel_audit.dart`: Public barrel audit lock: PASS.
