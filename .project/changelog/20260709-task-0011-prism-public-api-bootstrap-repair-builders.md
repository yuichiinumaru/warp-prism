---
date: 20260709-120000
timestamp: 20260709-120000
project: warp-prism
agent: builders
task: "0011"
description: "Repair Task 0011 package gate: Prism* public API only + format + smoke"
is_rebuild_safe: true
---

# Task 0011: Bootstrap Main Router Shell — Package Gate Repair

## Summary

Fixed reviewer rejection (42/100) for Task 0011. Observatory bootstrap/shell consumer code no longer references non-public `DS*` names through `package:warp_prism_ui/warp_prism_ui.dart`. Task-owned surfaces now use public `Prism*` aliases only. Format gate for `map_page.dart` and related task files is clean. Shell smoke test passes.

## Changes

- Replaced `DS*` consumer symbols with public `Prism*` aliases in:
  - `apps/observatory/lib/app/app_shell.dart`
  - `apps/observatory/lib/app/app.dart`
  - `apps/observatory/lib/app/pages/history_page.dart`
  - `apps/observatory/lib/app/pages/governance_page.dart`
  - `apps/observatory/lib/app/pages/asset_detail_page.dart`
  - `apps/observatory/test/app/app_shell_smoke_test.dart`
  - `apps/observatory/test/app/shell_responsive_layout_test.dart`
- Fixed formatting on `apps/observatory/lib/app/pages/map_page.dart` (trailing whitespace).
- Isolated smoke test from product feature modules that still use residual `DS*` names (out of Task 0011 scope). Smoke now boots a minimal bootstrap router wrapping `AppShell` and asserts public Prism shell organisms.

## Verification

```bash
cd apps/observatory
flutter test --concurrency=1 --no-pub test/app/app_shell_smoke_test.dart
# All tests passed! (3/3)

dart analyze --format=machine \
  lib/app/app_shell.dart lib/app/app.dart \
  lib/app/pages/map_page.dart lib/app/pages/history_page.dart \
  lib/app/pages/governance_page.dart lib/app/pages/asset_detail_page.dart \
  test/app/app_shell_smoke_test.dart test/app/shell_responsive_layout_test.dart
# exit 0 (INFO prefer_const_* only)

dart format --output=none --set-exit-if-changed \
  lib/app/app_shell.dart lib/app/app.dart \
  lib/app/pages/map_page.dart lib/app/pages/history_page.dart \
  lib/app/pages/governance_page.dart lib/app/pages/asset_detail_page.dart \
  test/app/app_shell_smoke_test.dart test/app/shell_responsive_layout_test.dart
# exit 0
```

## Residual / Path notes

Feature modules under `apps/observatory/lib/features/**` still contain many non-public `DS*` references. That residual is outside Task 0011 bootstrap scope and should be remediated by a dedicated Prism-namespace sweep before full-app `WarpPrismApp` smoke can load product routes without compile errors.
