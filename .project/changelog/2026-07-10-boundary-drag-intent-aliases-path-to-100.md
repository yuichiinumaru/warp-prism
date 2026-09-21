---
date: 20260710-182832
timestamp: 20260710-182832
agent: builders
task: "2026"
description: "2026-07-10 — Boundary drag intent aliases (0013 / 1205 / 1302)"
is_rebuild_safe: true
---

# 2026-07-10 — Boundary drag intent aliases (0013 / 1205 / 1302)

## Summary
Added missing public Prism aliases for keyboard DnD intents so the pure-Dart boundary harness returns **6/6 PASS**.

## Changes
- `packages/warp_prism_ui/lib/src/prism_aliases.dart`: `PrismDragReorderIntent`, `PrismDragMoveLaneIntent`
- `docs/design/public-barrel-audit.md`: Prism API count **129** (128 typedef + 1 extension)
- Tasks 0013, 1205, 1302: path-to-100 evidence with live harness stdout

## Validation
```text
dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .
→ Boundary harness: 6/6 PASS
```

## Author
builders (builder-orchestrator parent)
