---
date: 20260929-153400
timestamp: 20260929-153400
project: "warp-prism"
agent: "gt-builders-engineer-flutter"
task: "1840"
description: "Task 1840 — eliminated the 16px RenderFlex bottom overflow in the _StatusTickerDemo gallery fixture and the 3 ListTile ink-visibility warnings; both were demo/host-composition defects, not DSStatusTicker widget defects. DSStatusTicker left unmodified."
is_rebuild_safe: true
---

# Task 1840: catalog-statusticker-overflow-listtile-warnings

## Summary

Both reported defects were reproduced verbatim and attributed to their owning
gallery section, then classified and fixed at the correct layer.

The committed gallery suite calls `_suppressGalleryDemoNoise()`
(`test/gallery/design_system_gallery_test.dart:539-557`), which filters exactly
these two message classes, so a green suite proved nothing. Reproduction used a
throwaway harness that swept `dsGallerySections`, pumped each builder in a
`SingleChildScrollView`, and captured `FlutterError.onError` **per section**.

Verbatim reproduction (before):

```
A RenderFlex overflowed by 16 pixels on the bottom.
ListTile background color or ink splashes may be invisible.  (x3)
```

Attribution:

```
1840|section=epic15-stage-chrome|A RenderFlex overflowed by 16 pixels on the bottom.
1840|section=epic15-stage-relations|ListTile background color or ink splashes may be invisible.
1840|section=epic15-stage-relations|ListTile background color or ink splashes may be invisible.
1840|section=epic15-stage-relations|ListTile background color or ink splashes may be invisible.
```

## Changes

- **`design_system_gallery_sections.dart:3059` (defect 1 — demo sizing).**
  `SizedBox(height: 120, width: 640, child: _StatusTickerDemo())` → `SizedBox(width: 640, …)`.
  The hard box was authored to the demo's *content* height (120) while omitting
  the demo's own `EdgeInsets.all(8)` padding, leaving the `Column` 104px for
  120px of content. The demo has only fixed-height children, so it now sizes
  intrinsically and renders at its natural 120px — the height originally
  intended. Nothing is clipped, and the defect class is removed rather than
  re-tuned to a new magic number.
- **`design_system_gallery_sections.dart:6205` (defect 2 — demo host
  composition).** The layer-registry `ListView` gained its own
  `Material(type: MaterialType.transparency)` so `SwitchListTile.adaptive` paints
  its background and ink splashes on a Material at the right layer, instead of
  on the distant Scaffold Material occluded by the enclosing coloured glass
  `DecoratedBox`. Glass appearance is unchanged.
- **Not modified:** `packages/warp_prism_ui/lib/src/organisms/status_ticker/ds_status_ticker.dart`.
  `DSStatusTicker` self-bounds via `SizedBox(height: widget.height)` and honours
  its documented contract (default 48 = WCAG min target); no widget-layer defect
  was proven.

## Verification

- [x] Unsuppressed per-section sweep at 1400x2400: 4 errors before → **0 after**
- [x] Sibling sweep, all 24 registry sections at the default catalog viewport
      `1280x800`: `epic15-stage-chrome` and `epic15-stage-relations` clean
- [x] Content integrity after fix: 2 tickers render at 622x36 (the requested
      `height: 36`, unclipped), both captions present, all 3 layer labels and 3
      switch tiles present, 0 errors
- [x] `dart format --set-exit-if-changed` on the touched file: exit 0 (0 changed)
- [x] `dart analyze` (`packages/warp_prism_ui`): exit 0 — 212 issues, all `info`
- [x] `flutter test --no-pub` (`packages/warp_prism_ui`): `+1703 -63` — **identical
      to the pre-change A/B baseline**, i.e. zero regressions. The 63 failures are
      pre-existing (golden/environment) and unrelated.
- [x] `flutter analyze` (`apps/catalog`): `No issues found!` exit 0
- [x] `flutter test --no-pub` (`apps/catalog`): 4 failures, all proven pre-existing
      by A/B revert (identical counts before/after). All 4 are
      `PathNotFoundException` in `_persist` — `apps/catalog/docs/` does not exist,
      so trace artifacts cannot be written to the pre-relocation
      `docs/reports/host-exercise/traces/` path. Unrelated to this task.
- [x] `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .`:
      15/15 PASS exit 0
- [ ] **Host proof NOT run** — `flutter run -d linux` requires a display/GPU host
      and is operator-side. Headless `flutter_tester` evidence stands in; the
      operator should confirm at the default viewport.

## Sibling finding (reported, deliberately NOT fixed — out of writeset)

`health-dashboard` section: `A RenderFlex overflowed by 7.3 pixels on the bottom.`

- Widget: `Column`, `mainAxisSize: min`, `BoxConstraints(w=204.0, h=124.7)`
- Location: `packages/warp_prism_ui/lib/src/molecules/ds_health_card.dart:82:14`
- Only reproduces at the default catalog viewport `1280x800`; clean at 1400x2400
- Cause: `DSHealthCard` in a molecule file, outside Task 1840's writeset.
  Route as follow-up work; do not fix here.
