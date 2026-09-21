---
date: 20260822-120000
timestamp: 20260822-120000
project: "warp-prism"
agent: "builders"
task: "1802"
description: "Bundled Rajdhani TTFs + OFL.txt license across catalog, observatory, and cybercore apps, updated pubspecs, set DSTypography fontFamilySans to Rajdhani with explicit system fallback chains, fixed Observatory global mono wiring defect, and updated token contract tests."
is_rebuild_safe: true
---

# Task 1802: warp-prism-typography-font-assets

## Summary

Bundled Rajdhani TTFs (300–700 weights) and OFL.txt license file across all three applications (`apps/catalog`, `apps/observatory`, `apps/cybercore`), declared Rajdhani font families in all three app `pubspec.yaml` files, updated `DSTypography.fontFamilySans` to `'Rajdhani'` with explicit system fallback chains (`fontFamilySansFallback` and `fontFamilyMonoFallback`), fixed Observatory root `app.dart` global mono wiring defect by setting `fontFamilySans`, and updated token contract tests to verify font families, fallback contracts, and technical/metrics role allocations.

## Changes

- Bundled `Rajdhani-Light.ttf`, `Rajdhani-Regular.ttf`, `Rajdhani-Medium.ttf`, `Rajdhani-SemiBold.ttf`, `Rajdhani-Bold.ttf` + `OFL.txt` under `assets/fonts/` for `apps/catalog`, `apps/observatory`, and `apps/cybercore`.
- Updated `pubspec.yaml` in `apps/catalog`, `apps/observatory`, and `apps/cybercore` to declare the `Rajdhani` font family and weights.
- Updated `packages/warp_prism_ui/lib/src/tokens/ds_typography.dart`:
  - `fontFamilySans` updated from `'Inter'` to `'Rajdhani'`.
  - Added `fontFamilySansFallback` (`['Roboto', 'Helvetica Neue', 'Arial', 'sans-serif']`) and `fontFamilyMonoFallback` (`['Courier New', 'monospace']`).
  - Added `fontFamilyFallback` to all 18 text styles.
  - Documented role allocation and numeric/metrics technical role decision per Visual Contract §3.1.
- Updated `apps/observatory/lib/app/app.dart`: fixed global mono wiring defect by changing root `fontFamily` from `fontFamilyMono` to `fontFamilySans`.
- Updated `packages/warp_prism_ui/test/tokens/ds_token_contract_test.dart`: updated family assertions ('Rajdhani' / 'JetBrainsMono') and added fallback contract and role separation assertions.

## Verification

- `dart analyze lib/src/tokens/ds_typography.dart test/tokens/ds_token_contract_test.dart` -> PASS (0 issues)
- `flutter test test/tokens/ds_token_contract_test.dart --concurrency=1 --no-pub` -> PASS (40/40 tests)
- `for app in catalog observatory cybercore; do test -f apps/$app/assets/fonts/Rajdhani-Regular.ttf || echo "MISSING $app"; done` -> PASS (all 3 present)
- `flutter test` in `apps/catalog` -> PASS (10/10 tests)
