---
type: fix
title: "task-1302-public-barrel-refresh"
agent: builders
created: 2026-06-25T19:03:03
date: 2026-06-25
---

# task-1302-public-barrel-refresh

Task 1302 fix pass regenerated docs/design/public-barrel-audit.md against the current four-file public barrel. Current counts: 127 public top-level symbols total; 121 Prism API symbols from src/prism_aliases.dart (120 typedef aliases plus PrismOperationalStateUI); 6 gallery-only symbols from the three gallery exports. Boundary harness passes 6/6 with 0 violations. Analyzer remains red with 590 pre-existing package issues (11 warnings, 579 info, 0 errors); no Dart code changed.
