---
date: 20260607-224047
timestamp: 20260607-224047
agent: repair-bot
task: "1025"
description: "Changelog — Task 0411: Shell Navigation And Responsive Frame"
is_rebuild_safe: true
---

# Changelog — Task 0411: Shell Navigation And Responsive Frame

**Date**: 2026-06-07
**Task**: 0411 — Warp Prism Shell Navigation And Responsive Frame
**Type**: feature
**Status**: Done

## Summary

Implemented the shared product shell frame around the router by composing existing design-system organisms into a desktop-first navigation experience with left rail, central content area, right inspector region, and a credible small-layout fallback.

## Files Changed

- **CREATED** `lib/app/app_shell.dart` — shared shell widget:
  - `AppShell` — main shell container wrapping `StatefulShellRoute`
  - `DSShellResponsive` — wide layout with sidebar + topbar + inspector
  - `_CompactShell` — narrow layout with `BottomNavigationBar`
  - Route-derived navigation state via `go_router`'s `StatefulShellRoute.indexedStack`
- **MODIFIED** `lib/app/router.dart` — integrated `AppShell` as the shell builder for all five workspace branches (Overview, Map, Operate, History, Governance)
- **CREATED** `test/app/shell_responsive_layout_test.dart` — responsive layout tests (wide sidebar + narrow bottom nav)
- **CREATED** `test/app/app_shell_smoke_test.dart` — shell smoke test coverage

## Key Decisions

- Reused existing DS organisms (`DSShellResponsive`, sidebar, topbar) instead of building ad-hoc scaffold
- Navigation state is route-derived (via `StatefulShellRoute`) to avoid competing manual index
- Inspector is a shell concern, not Overview-only
- `BottomNavigationBar` for narrow layouts, hiding sidebar entirely
