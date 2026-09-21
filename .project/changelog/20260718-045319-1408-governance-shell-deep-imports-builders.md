---
date: 20260718-045319
timestamp: 20260718-045319
project: "warp-prism"
agent: gt-flutter-engineer
task: "1408"
description: "Migrate 5 residual deep relative imports in governance_page_shell"
is_rebuild_safe: true
scope: "apps/observatory/imports"
type: "housekeeping"
---

# Task 1408: Governance Shell Deep Relative Import Residual

## Summary

Drain review (74/100) found **5** deep relative imports (`../../../data/...`)
reintroduced in
`apps/observatory/lib/features/governance/presentation/governance_page_shell.dart`.
Migrated all five to `package:warp_prism_observatory/...` URIs.

## Changes

```dart
// before → after (5 lines)
import 'package:warp_prism_observatory/data/models/governance_diagnostics.dart';
import 'package:warp_prism_observatory/data/models/workspace_graph.dart';
import 'package:warp_prism_observatory/data/providers/workspace_providers.dart';
import 'package:warp_prism_observatory/data/services/workspace_diagnostics_service.dart';
import 'package:warp_prism_observatory/data/services/workspace_graph.dart';
```

## Proof (2026-07-18)

- `rg "import '\.\./\.\./\.\." apps/observatory/lib/features/` → **0**
- Package URI targets for all 5 paths: **exist** under `apps/observatory/lib/`
- `flutter analyze …/governance_page_shell.dart` → **No issues found!**
- `flutter test apps/observatory/test/features/governance/` → **+104 All tests passed!**
- Boundary harness (shared): **7/7 PASS**
- Package-style inventory: **88** import lines / **42** files in `lib/features/`
- Allowed residual: 3× shallow `../../data/` map-root imports (simplicity pass)

## Regression

**None** — import-scope only; no behavior change.
---