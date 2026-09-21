---
type: review
title: "task-0011-bootstrap-router-shell-review"
agent: reviewers
created: 2026-06-30T19:34:54
date: 2026-06-30
---

# task-0011-bootstrap-router-shell-review

Task 0011 reviewed from docs/tasks/03-review/0011-warp-prism-bootstrap-main-router-shell.md. Score 42/100 REJECTED. Evidence: apps/observatory flutter analyze reports 1126 issues; flutter test test/app/app_shell_smoke_test.dart fails during loading because app bootstrap imports package:warp_prism_ui/warp_prism_ui.dart but uses hidden DS* names (DSSidebarItem, DSColors, DSShellResponsive, DSSidebar, DSTopbar, DSTypography, DSSpacing, DSBreakpoints). Public UI barrel exports Prism* aliases only. dart format --output=none --set-exit-if-changed on task paths reports lib/app/pages/map_page.dart would change. Lifecycle count in observatory lib: TextEditingController creations 1/disposals 1; AnimationController creations 1/disposals 1; TabController creations 2/disposals 2; addListener 1/removeListener 1; StreamSubscription 0; Timer 0. Moved task back to 02-doing after adding compact Review Ledger.
