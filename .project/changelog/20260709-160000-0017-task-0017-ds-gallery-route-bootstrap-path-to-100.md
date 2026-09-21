---
date: 20260709-160000
timestamp: 20260709-160000
project: ganthritor
agent: builders
task: "0017"
description: "Task 0017 — Design System Gallery Route Bootstrap (path-to-100, builder self-review)"
is_rebuild_safe: true
scope: "design-system"
type: "feature"
---

# Task 0017 — Design System Gallery Route Bootstrap (path-to-100)

## Summary

Re-validated the Design System Gallery route bootstrap end-to-end after the
Task 1304 path-to-100 cleanup. Flutter SDK is now available; previous
"BLOCKED: Flutter SDK not installed" exit conditions are now exercised with
real analyzer + test evidence. Required `ds_compat` shim was wired into
seven product pages that still use `DS*` identifiers so the router import
graph can compile under the Prism-only public barrel.

## Changes

- `apps/observatory/lib/features/governance/presentation/governance_overview_page.dart`
  — added `import 'package:warp_prism_observatory/src/ds_compat.dart';`.
- `apps/observatory/lib/features/governance/presentation/widgets/governance_boundary_legend.dart`
  — added `ds_compat` import.
- `apps/observatory/lib/features/governance/presentation/widgets/fan_in_hotspots_panel.dart`
  — added `ds_compat` import.
- `apps/observatory/lib/features/governance/presentation/widgets/governance_issue_filters.dart`
  — added `ds_compat` import.
- `apps/observatory/lib/features/governance/presentation/widgets/governance_issue_group.dart`
  — added `ds_compat` import.
- `apps/observatory/lib/features/governance/presentation/widgets/governance_story_summary.dart`
  — added `ds_compat` import.
- `apps/observatory/lib/features/governance/presentation/widgets/review_pressure_panel.dart`
  — added `ds_compat` import.
- `apps/observatory/lib/features/shell/shell_state_handler.dart` — added
  `ds_compat` import.

No gallery or DS layer code touched. Imports are additive and preserve the
Prism-only public contract via the existing observatory-local compat layer
(unchanged from Task 1408 compat shim).

## Validation (scoped, OOM-safe)

```text
cd packages/warp_prism_ui
flutter analyze lib/src/gallery/ lib/warp_prism_ui.dart lib/src/prism_aliases.dart test/gallery/
  → No issues found! (0 errors, 0 infos)

flutter test test/gallery/design_system_gallery_test.dart
  → 00:19 +13: All tests passed!

cd apps/observatory
flutter analyze lib/app/router.dart lib/app/app.dart lib/main.dart test/app/app_bootstrap_test.dart
  → 1 issue found (prefer_const_constructors in lib/app/app.dart:27:20 — pre-existing info, unrelated to gallery)

flutter test test/app/app_bootstrap_test.dart
  → 00:01 +3: All tests passed!
```

## Exit-condition evidence

- [x] `lib/main.dart`, `lib/app/app.dart`, `lib/app/router.dart` exist from
      Task 0011 and are reused unchanged.
- [x] `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_page.dart`
      + `design_system_gallery_sections.dart` linked via
      `lib/warp_prism_ui.dart` public barrel (Prism* names).
- [x] Gallery demonstrates tokens, atoms, molecules, organisms, and templates
      (10 sections in `dsGallerySections` registry).
- [x] `app_bootstrap_test.dart` (3 tests) + `design_system_gallery_test.dart`
      (13 tests) pass under `flutter test`.
- [x] `flutter analyze` passes for the scoped surface (0 errors).
- [x] Changelog note added under `docs/changelog/`.

## Notes for reviewer

- Reviewer agents are unavailable this cycle; the builder applied the
  self-review gate (Law 3.5) and re-checked scope: only `ds_compat` imports
  were added, no semantic or behavioral changes to gallery or DS code.
- The Observatory still uses private `DS*` APIs in product pages via
  `apps/observatory/lib/src/ds_compat.dart`. A full migration to `Prism*`
  is a future task (see `Task 1408`); that migration is out of scope for
  Task 0017.

**Author**: builders
