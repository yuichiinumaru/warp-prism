# Host-Exercise Harness — First Real Detection (Catalog Compact Viewport)

> **Date**: 2026-09-04
> **Detected by**: `warp_prism_host_exercise` THEME MATRIX viewport×recipe spot
> **Status**: OPEN product finding (routed to remediation — NOT fixed by the
> harness task; the harness only detects and preserves evidence)

## Detection

Running the harness viewport matrix (Catalog host, `compact390x844` viewport,
SMOKE mode), the strict error oracle failed the run:

```text
HOST-EXERCISE ORACLE FAILURE (smoke-reset:catalog):
  flutter_errors: 1
  - A RenderFlex overflowed by 285 pixels on the right.
```

At initial reset (before any interaction) the overflow is `90 pixels on the
right`.

## Root cause (render-tree evidence)

`debugDumpRenderTree` at 390×844 pins the culprit:

```text
└─child: RenderFlex#… relayoutBoundary=up7 OVERFLOWING
  creator: Row ← Padding ← DecoratedBox ← Container ← DSGlassPanelSimple
  constraints: BoxConstraints(w=300.0, 0.0<=h<=Infinity)
  size: Size(300.0, 2630.0)
  direction: horizontal
```

The overflowing `Row` is the **Design System Gallery header** at
`packages/warp_prism_ui/lib/src/gallery/design_system_gallery_page.dart:136`
(`_buildHeader`): logo `48px` + `DSSpacing.lg` + `Expanded` title + theme
editor `DSButton`. Under a 390px-wide viewport with `DSSpacing.xxl` (25px)
panel padding, the non-flexible children exceed the ~300px available content
width and the Row has no compact-mode fallback (stacked column, hidden button,
or wrap).

The 285px figure observed during the interactive run is the same Row after
theme-recipe switching re-layout — the defect class is identical.

## Why package tests missed it

- Package widget tests render the gallery at ≥1200px widths (desktop matrix).
- The Catalog capture harness is fixed-viewport 1280×800.
- No existing test mounts the real Catalog app shell at a compact viewport.

This is exactly the oracle-gap class the harness exists to close (same class
as Task 1832's `DSDataTable`/`DSTimeMachineScrubber` fixed-height overflows,
now in the horizontal/compact-width axis of a real host).

## Reproduction

```bash
cd apps/catalog && flutter test test/host_exercise/catalog_theme_matrix_test.dart \
  --plain-name "theme matrix: viewport × recipe spot"
```

Fails on current main-state product code with the oracle message above.

## Disposition

- Harness task does NOT fix product layout (isolation boundary: parallel
  product mission owns `warp_prism_ui` mutations).
- Recommend routing as a narrow remediation task in the 1831–1834 family:
  gallery header compact-width layout contract (collapse to column below
  `PrismBreakpoints.narrow` or equivalent).
- The harness test intentionally remains red in `compact390x844` viewport
  coverage until the product fix lands — this is the calibration control
  proving the harness detects real defects (see calibration report).
