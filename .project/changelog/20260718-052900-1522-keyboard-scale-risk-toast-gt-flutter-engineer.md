---
date: 20260718-052900
timestamp: 20260718-052900
project: warp-prism
agent: gt-flutter-engineer
task: "1522"
description: "Optional keyboard cheatsheet + scale measure bar + risk toast variant"
is_rebuild_safe: true
---

# Task 1522: Optional Keyboard Cheatsheet + Scale Bar + Risk Toast

## Summary

Wave I polish pack: `PrismKeyboardCheatsheet` overlay, `PrismScaleMeasureBar` molecule (not organism), and `DSToastRiskTier` / `DSToastEntry.risk` on the existing toast manager (no second stack). Gallery + Prism aliases + fixture tests.

## Changes

- **Organism**: `keyboard_cheatsheet/` — shortcut groups, keycaps, escape/backdrop dismiss, a11y dismiss label.
- **Molecule**: `ds_scale_measure_bar.dart` — read-only map scale chrome; classification documented as molecule.
- **Toast**: `DSToastRiskTier` + `DSToastEntry.risk` risk badge/region chrome via existing `DSToast`/`DSToastManager`.
- Exports: organisms barrel, molecules barrel, `prism_aliases.dart` (`PrismKeyboard*`, `PrismScale*`, `PrismToastRiskTier`).
- Gallery: Wave I polish section + toast risk demos.

## Verification

- `dart analyze` (owned surfaces): No issues found
- `flutter test test/organisms/keyboard_cheatsheet/`: PASS
- `flutter test test/molecules/ds_scale_measure_bar_test.dart`: PASS
- `flutter test test/molecules/ds_toast_risk_variant_test.dart`: PASS
- Boundary harness: **7/7 PASS**
