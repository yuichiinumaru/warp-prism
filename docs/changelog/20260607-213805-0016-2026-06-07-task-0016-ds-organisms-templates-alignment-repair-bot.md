---
date: 20260607-213805
timestamp: 20260607-213805
agent: repair-bot
task: "0016"
description: "Task 0016 — DS Organisms and Templates Alignment"
is_rebuild_safe: true
scope: "design-system"
type: "feature"
---

# Task 0016 — DS Organisms and Templates Alignment

## What changed
- Verified all organism/template API alignment is complete (DSShell, DSSidebar, DSTopbar naming and constructor contracts)
- Confirmed `MasterDetailTemplate` correctly uses canonical organism constructors with proper parameter names (`content`, `selectedId`, `searchBar`, `showSearch`)
- Confirmed `CanvasTemplate` and `TimelineTemplate` share the same sidebar/topbar/selectedIndex pattern for API coherence
- Confirmed `ds_graph_canvas.dart` uses correct `DSColors` token references (no broken tokens)
- Confirmed all barrel exports (organisms.dart, templates.dart) are coherent and complete
- Created widget tests proving shell/organism composition: `test/design_system/organisms/organisms_layout_test.dart`
- Created widget tests proving template composition: `test/design_system/templates/templates_contract_test.dart`

## Why
The draft.md identified compile-breaking API drift between organisms and templates (wrong class casing, wrong parameter names, missing token references). Prior tasks (0012, 0015) fixed the actual code. This task verified the alignment is complete and added widget tests proving that templates compose organisms correctly without adapters, which is the core contract requirement for future feature screens.
