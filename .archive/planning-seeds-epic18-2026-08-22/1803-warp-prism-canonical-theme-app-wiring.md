# Task 1803 — Canonical ThemeData and App Host Wiring

> **Planning Status**: Proposed — executable after Tasks 1801 and 1802
> **Priority**: P0
> **Type**: app integration/theme composition
> **Parent**: EPIC-18
> **Depends on**: Tasks 1800, 1801, 1802
> **Blocks**: Tasks 1805–1806

## Objective

Create one canonical Warp Prism theme composition and wire every visual validation host to
it. The Catalog must no longer use bare `ThemeData.dark()`, and Observatory must no
longer force JetBrains Mono across all UI roles.

## Scope

- shared theme factory or equivalent in `warp_prism_ui`
- `apps/catalog/lib/main.dart`
- `apps/observatory/lib/app/app.dart`
- `apps/cybercore/lib/main.dart`
- deterministic test/demo hosts

## Required Behavior

- Black-obsidian scaffold and surfaces are the default structural theme.
- Approved blue is action/focus/highlight-only.
- CyberCore may install the teal extension explicitly.
- Observatory does not require or silently install CyberCore teal.
- Normal UI typography and technical typography use separate roles.
- Material color scheme does not make blue a page background.

## Acceptance Criteria

- [ ] All three app roots consume the canonical theme composition or an explicitly
      documented product skin derived from it.
- [ ] Catalog screenshot is representative of the shipped visual system.
- [ ] Observatory screenshot is representative of the shipped visual system.
- [ ] CyberCore screenshot proves its opt-in skin behavior without changing Observatory.
- [ ] Theme tests assert black background at root/scaffold/surface levels.
- [ ] Theme tests assert no global mono font assignment.
- [ ] App smoke tests pass with real host wiring.
