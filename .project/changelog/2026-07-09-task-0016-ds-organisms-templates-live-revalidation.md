---
date: 20260709-061347
timestamp: 20260709-061347
agent: builders
task: "0016"
description: "Task 0016 — DS Organisms/Templates live revalidation and test import fix"
is_rebuild_safe: true
scope: "design-system"
type: "fix"
---

# Task 0016 — DS Organisms/Templates Live Revalidation

## What changed
- Verified live Flutter SDK availability (3.44.1 / Dart 3.12.1).
- Confirmed organism/template constructor contracts are already aligned:
  - Templates use `DSShell` / `DSSidebar` / `DSTopbar` with `content`, `selectedId`, `showSearch`/`searchBar`.
  - `CanvasTemplate` and `TimelineTemplate` remain co-located in `master_detail_template.dart` and exported via `templates.dart`.
  - `DSGraphCanvas` delegates to composable graph layers with stable legacy API.
- Fixed `test/organisms/organisms_layout_test.dart` imports: public barrel is Prism*-only; tests now import internal `src/organisms` + `src/tokens` barrels (same pattern as templates/molecules tests).
- Live scoped validation green:
  - `flutter test test/organisms/organisms_layout_test.dart test/templates/templates_contract_test.dart` → 20/20 passed
  - scoped `dart analyze` on core organism/template files → 0 errors/warnings

## Why
Task 0016 was previously closed without executable Flutter validation (SDK missing). Live revalidation unblocked promotion to review and fixed a residual compile failure in the organisms layout test caused by Prism public-API hardening.
