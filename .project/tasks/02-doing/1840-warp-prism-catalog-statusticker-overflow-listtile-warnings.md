# Task 1840: Catalog Gallery StatusTicker Overflow + ListTile Ink Warnings

> **Priority**: 🔴 P0 · **Type**: `bugfix` | `flutter` | `host-composition`
> **Origin**: Operator live run 2026-09-27 (`cd apps/catalog && flutter run -d
> linux`): `RenderFlex overflowed by 16 pixels on the bottom` in
> `_StatusTickerDemo` + 3× `ListTile background color or ink splashes may be
> invisible`. Catalog looked otherwise good.
> **Blocks**: Nothing structural. Unblocks clean host-composition evidence for
> the gallery route.
> **Depends on**: Nothing.
> **Collision**: NONE with Task 1839 — grep 2026-09-27 proves 1839 has zero
> matches inside `design_system_gallery_sections.dart`; this task owns that
> file's StatusTicker region plus the `DSStatusTicker` organism source.

## Milestone Alignment

- **Target**: host-composition correctness — a gallery section must not throw
  layout exceptions on a standard desktop viewport.
- **Consequence if absent**: every catalog run opens with a red-striped
  overflow; the gallery cannot serve as visual proof for the affected section.

## Objective

Eliminate the 16px bottom `RenderFlex` overflow in the `_StatusTickerDemo`
gallery section and the three `ListTile` ink-visibility warnings, determine for
each whether the defect is in the **demo sizing** or in the **widget itself**
(`DSStatusTicker` / the ListTile host), fix at the correct layer, and prove a
clean catalog run.

## Background Context

### What already exists

- `_StatusTickerDemo` (`design_system_gallery_sections.dart:6239+`): a
  `ColoredBox` + `Padding` + `Column(crossAxisAlignment: stretch)` showing
  rotate and marquee `DSStatusTicker` modes. The overflowing `RenderFlex` is at
  `design_system_gallery_sections.dart:6251:16`, constrained
  `BoxConstraints(w=624.0, h=104.0)`, inside
  `DSGlassPanelSimple ← _SectionCard`.
- `DSStatusTicker` organism source under
  `packages/warp_prism_ui/lib/src/organisms/` (find exact path before editing).
- The exception trace names `Column ← Padding ← ColoredBox ← _StatusTickerDemo
  ← SizedBox ← Column ← Column ← Padding ← DecoratedBox ← Container ←
  DSGlassPanelSimple ← _SectionCard`.

### What is missing or broken

- The demo column overflows its 104px section-card constraint by 16px.
- Three `ListTile` ink warnings from unidentified gallery sections.

## Subtasks

- [x] **Read before modifying**: `_StatusTickerDemo` full region,
  `DSStatusTicker` source + fixtures (`DSStatusTickerFixtures.mockFeed()`),
  `_SectionCard` sizing contract, and the three ListTile call sites (find them
  first via a widget-tree walk or by running and reading traces).
  *Done — the three ink warnings were **not** the obvious `ListTile` at line
  2543 nor the map-stage `SwitchListTile`; per-section attribution proved they
  all originate from `_MapCanvasStageDemo` (3 layers = 3 tiles).*
- [~] **Reproduce**: ~~`cd apps/catalog && flutter run -d linux`~~ **host proof
  not runnable here** (needs a display/GPU host). Reproduced instead headlessly
  in `flutter_tester` with a per-section unsuppressed `FlutterError.onError`
  capture, which additionally attributed each error to its section. Viewport
  recorded: the default catalog viewport is `1280x800`
  (`ExerciseViewport.desktop1280x800`); reproduction confirmed at 1400x2400 too.
- [x] **Classify per defect**: demo-sizing (fix the demo: bounded height,
  scrollable container, or `Expanded` where the section contract allows) vs
  widget defect (fix `DSStatusTicker` intrinsic sizing; fix ListTile `tileColor`
  vs `selectedTileColor` / missing `Material` ancestor at the right layer).
  Record the classification per defect before fixing.
  *Done — see "Defect Classification (recorded BEFORE fix)". Both are
  demo/host-composition defects. Neither `DSStatusTicker` nor
  `DSMapCanvasStage` is at fault.*
- [x] **Fix the StatusTicker overflow** at the classified layer. Do not clip
  away content to hide the error unless the section contract explicitly bounds
  the demo — prefer making the demo fit the contract or the contract fit the
  content, with reasoning recorded.
  *Done — contract made to fit the content; nothing clipped; reasoning recorded.*
- [x] **Fix the three ListTile ink warnings** at the classified layer.
  *Done — Flutter-prescribed `Material(type: MaterialType.transparency)` wrapper.*
- [x] **Check siblings**: run the full gallery and confirm no other section
  throws layout exceptions at the default catalog viewport. Report any new
  findings as paths, do not widen scope to fix them here.
  *Done — 24 sections swept at 1280x800; 1 new finding reported, not fixed:
  `ds_health_card.dart:82` (7.3px).*
- [x] **Regression verification**: run validation commands below.
  *Done — see the exit-code table under Completion Evidence. Failures recorded
  are proven pre-existing by A/B revert.*
- [x] **Local changelog entry** added.
  *`.project/changelog/20260929-153400-1840-catalog-statusticker-overflow-listtile-warnings-gt-builders-engineer-flutter.md`*

## Validation Commands

```bash
cd packages/warp_prism_ui && dart format --output=none --set-exit-if-changed lib/ test/ && dart analyze
cd packages/warp_prism_ui && flutter test --no-pub
cd apps/catalog && flutter analyze && flutter test --no-pub
```

Plus the host proof (manual, operator-reproducible): `cd apps/catalog &&
flutter run -d linux`, open the gallery, observe zero `RenderFlex` and zero
`ListTile` exceptions in the console at the default viewport. Record viewport
+ console result verbatim.

If Flutter tooling is unavailable in the execution environment, record the exact
tooling failure and do not claim those checks passed.

## Where

| File | Purpose |
|---|---|
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` | Modify — `_StatusTickerDemo` region (~6239+) + ListTile call sites |
| `packages/warp_prism_ui/lib/src/organisms/status_ticker/` | Inspect, modify only if widget-layer defect proven |
| `packages/warp_prism_ui/lib/src/gallery/` (siblings) | Read-only sibling check |

## Non-Goals

- No theme/brand changes (Task 1839 owns those).
- No golden refresh (Task 1800 freeze still active).
- No new widgets, no API redesign.

## Exit Conditions

> Builder-declared status. The builder does **not** grant the final condition —
> independent review is a separate lane (Rule 42).

- [x] Zero `RenderFlex` overflow on the gallery route at the default viewport.
  *Builder evidence: unsuppressed sweep of all 24 sections at `1280x800` returns
  the two fixed sections clean. **Caveat:** one *unrelated* pre-existing
  `health-dashboard` overflow remains (`ds_health_card.dart:82`, 7.3px) and is
  reported as a sibling finding, out of this task's writeset.*
- [x] Zero `ListTile` ink warnings on the gallery route. *(3 → 0)*
- [x] Per-defect classification recorded (demo vs widget).
- [x] All validation commands green (or exact tooling failure recorded).
  *Every command was executed; every non-zero exit is recorded verbatim with an
  A/B revert proof that it is pre-existing.*
- [x] Local changelog entry added.
- [ ] Independent review PASS. *Pending — not self-granted by the builder.*

## Defect Classification (recorded BEFORE fix)

Determined by unsuppressed reproduction. The committed gallery suite calls
`_suppressGalleryDemoNoise()`, which filters exactly these messages
(`packages/warp_prism_ui/test/gallery/design_system_gallery_test.dart:539-557`,
docstring: *"ListTile Material ancestor warnings from glass [DecoratedBox]
hosts"*). A throwaway harness therefore iterated `dsGallerySections`, pumping
each builder inside a `SingleChildScrollView` and capturing
`FlutterError.onError` per section, which attributed every error:

```
1840|section=epic15-stage-chrome|A RenderFlex overflowed by 16 pixels on the bottom.
1840|section=epic15-stage-relations|ListTile background color or ink splashes may be invisible.
1840|section=epic15-stage-relations|ListTile background color or ink splashes may be invisible.
1840|section=epic15-stage-relations|ListTile background color or ink splashes may be invisible.
```

| # | Defect | Section | Owner | Evidence |
|---|---|---|---|---|
| 1 | `A RenderFlex overflowed by 16 pixels on the bottom.` | `epic15-stage-chrome` | **Demo/host sizing** — NOT `DSStatusTicker` | `design_system_gallery_sections.dart:3059` `SizedBox(height: 120, width: 640, child: _StatusTickerDemo())`; the demo's own `EdgeInsets.all(DSSpacing.sm)`=8 reduces the child box to `w=624.0, h=104.0` — an exact match to the reported `BoxConstraints`. Content = 2×labelSmall(10×1.4=14)=28 + 2×`SizedBox(xs=4)`=8 + 2×ticker(`SizedBox(height:36)` + `DSGlassPanel.subtle` `Border.all(width:1)`, which `Container` adds as `decoration.padding` → 38)=76 + `SizedBox(sm=8)`=8 = **120**; 120−104 = **16**. |
| 2 | 3× `ListTile background color or ink splashes may be invisible.` | `epic15-stage-relations` | **Demo/host composition** — NOT `DSStatusTicker`, NOT `DSMapCanvasStage` | `design_system_gallery_sections.dart:6205` `SwitchListTile.adaptive`, one per `DSMapCanvasStageFixtures.defaultLayers()` entry — exactly 3 (`basemap`/`agents`/`alerts`). Each sits in `ListView → Column → DSGlassPanel.subtle` (a coloured `DecoratedBox`) `→ Padding → ColoredBox(obsidianDeep)`, so the nearest `Material` ancestor is far above and the coloured `DecoratedBox` occludes ListTile ink. |

### Why the widget layer is NOT at fault

`DSStatusTicker` self-bounds its height: `ds_status_ticker.dart:527-530` wraps
content in `SizedBox(height: widget.height, …)`, and every child beneath it is
height-bounded (`AnimatedSwitcher`+`Align`, horizontal `SingleChildScrollView`,
`ClipRect`+`OverflowBox`). It honours its documented `height` contract (default
48 = WCAG min target; the demo passes 36) and therefore cannot overflow a
parent. **No widget-layer defect was proven, so `DSStatusTicker` is not
modified by this task.**

### Fix decisions

- **Defect 1 → fix the fixture host contract (contract fits the content).**
  `_StatusTickerDemo` contains only fixed-height children (no `ListView`, no
  `Expanded`), so it is safe to size intrinsically. Dropping the wrong hard
  height and keeping the width renders the block at its natural 120px — exactly
  the height the box intended — clips nothing, and removes the defect class
  rather than re-tuning a magic number that breaks again on any content change.
  *Rejected:* raising the box to 136 — still a hard-coded lie, same class.
- **Defect 2 → fix at the demo host, per the diagnostic's own prescription**
  ("wrap the ListTile in its own Material widget, or remove the background color
  from the intermediate DecoratedBox"). The layer-registry list gets its own
  `Material(type: MaterialType.transparency)`, so ListTile paints on a Material
  at the right layer while the glass panel's appearance is preserved exactly (no
  colour, token, skin, or theme file touched). *Rejected:* removing the
  `DecoratedBox` background — a visual redesign, out of scope.

## Completion Evidence

> **Lane note**: this task was moved `01-open/` → `02-doing/` by the
> task-governance owner (claim recorded under *Lane History*). The builder did
> not perform, and has no authority to perform, any lane movement. The lane was
> left untouched at `02-doing/`; promotion is the governance owner's call.

- **Files created/modified**:
  - `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`
    — two edits only: the `_StatusTickerDemo` call site (line 3059) and the
    layer-registry `ListView` (line 6205).
  - `packages/warp_prism_ui/lib/src/organisms/status_ticker/ds_status_ticker.dart`
    — **NOT modified** (read-only; no widget-layer defect was proven).
  - `.project/tasks/02-doing/1840-…md` — this file (evidence + classification).
  - `.project/changelog/20260929-153400-1840-catalog-statusticker-overflow-listtile-warnings-gt-builders-engineer-flutter.md`
    — new changelog entry.
  - Temporary diagnostic harnesses (2) were created, executed, and removed via
    the `archive` tool; both are preserved under
    `.archive/packages/warp_prism_ui/test/gallery/`. No test file remains in the
    live tree.

- **Repro traces before/after**:
  - BEFORE (unsuppressed per-section sweep, 1400x2400) — 4 errors:
    ```
    1840|section=epic15-stage-chrome|A RenderFlex overflowed by 16 pixels on the bottom.
    1840|section=epic15-stage-relations|ListTile background color or ink splashes may be invisible.
    1840|section=epic15-stage-relations|ListTile background color or ink splashes may be invisible.
    1840|section=epic15-stage-relations|ListTile background color or ink splashes may be invisible.
    ```
    Verbatim Flutter message for the ink warnings:
    > *ListTile background color or ink splashes may be invisible. The ListTile is
    > wrapped in a DecoratedBox that has a background color. Because ListTile
    > paints its background and ink splashes on the nearest Material ancestor,
    > this DecoratedBox will hide those effects. To fix this, wrap the ListTile
    > in its own Material widget, or remove the background color from the
    > intermediate DecoratedBox.*
  - AFTER — the same sweep returns **0 errors** (no `1840|…` lines emitted).
  - Arithmetic confirmation of the 16px, from real token values
    (`DSSpacing.xs=4`, `sm=8`; `DSText.labelSmall` = fontSize 10 × height 1.4 =
    14.0): content = 2×14 + 2×4 + 2×(36 + 1px `Border.all` added by
    `Container` as `decoration.padding`) + 8 = **120**; available
    = 120 − 2×8 = **104**; 120 − 104 = **16**, matching the operator report and
    the reported `BoxConstraints(w=624.0, h=104.0)` exactly.
  - Content-integrity after fix (proves no clipping): 2 tickers render at
    `622.0x36.0` (the demo's requested `height: 36` honoured), captions
    `Rotate (auto · pause on hover)` and `Marquee (seamless track)` both present,
    all 3 layer labels + 3 `SwitchListTile` present, 0 errors.

- **Tests or validation commands** (exact exit codes):

  | Command | Exit | Result |
  |---|---|---|
  | `dart format --output=none --set-exit-if-changed lib/src/gallery/design_system_gallery_sections.dart` | **0** | 0 changed — touched file is format-clean |
  | `dart format --output=none --set-exit-if-changed lib/ test/` (package-wide) | **1** | **PRE-EXISTING**: 56 files unformatted, `design_system_gallery_sections.dart` **not among them**; `--output=none` writes nothing |
  | `cd packages/warp_prism_ui && dart analyze` | **0** | 212 issues, all `info`; 0 errors, 0 warnings |
  | `cd packages/warp_prism_ui && flutter test --no-pub` | **1** | `+1703 -63` — **A/B proven identical to the pre-change baseline** (`+1703 -63` with both edits reverted). Zero regressions. The 63 failures are pre-existing golden/environment failures |
  | `cd apps/catalog && flutter analyze` | **0** | `No issues found!` |
  | `cd apps/catalog && flutter test --no-pub` | **1** | 4 failures, **A/B proven pre-existing** (`+0 -3` on `catalog_revalidation_test.dart` both with and without the fix). All 4 are `PathNotFoundException` in `_persist` — `apps/catalog/docs/` does not exist, so trace artifacts cannot be written to the pre-relocation `docs/reports/host-exercise/traces/` path |
  | `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .` | **0** | 15/15 PASS, 0 violations |
  | `flutter run -d linux` (host proof) | **not run** | Requires a display/GPU host; operator-side. **Not claimed as passing** |

- **Sibling check**: swept all **24** registry sections at the default catalog
  viewport `1280x800` (per `catalog_host.dart` `ExerciseViewport.desktop1280x800`)
  with no error suppression. `epic15-stage-chrome` and `epic15-stage-relations`
  are clean. **One new sibling finding, reported not fixed** (out of writeset):
  - `health-dashboard` — `A RenderFlex overflowed by 7.3 pixels on the bottom.`
    `Column`, `mainAxisSize: min`, `BoxConstraints(w=204.0, h=124.7)`, at
    `packages/warp_prism_ui/lib/src/molecules/ds_health_card.dart:82:14`.
    Only reproduces at `1280x800` (clean at 1400x2400). Lives in a molecule,
    outside this task's writeset — routed as follow-up.

- **Non-goals respected**: no theme/token/skin file touched (Task 1839's surface
  untouched); no golden refresh; no new widgets; no API redesign; no `DSStatusTicker`
  change; no `git`/`jj` invocation; nothing removed except the two scratch
  harnesses, via the `archive` tool.

- **Local changelog entry**:
  `.project/changelog/20260929-153400-1840-catalog-statusticker-overflow-listtile-warnings-gt-builders-engineer-flutter.md`

- **Executor**: `gt-builders-engineer-flutter` (builders lane)
- **Completion date**: 2026-09-29

### Open items for the owner

1. **Host proof outstanding** — a real `flutter run -d linux` pass at the default
   viewport is still required to close the first two exit conditions. Headless
   `flutter_tester` evidence is strong but is not the same gate.
2. **The test suite still hides this class of defect.**
   `_suppressGalleryDemoNoise()` (`design_system_gallery_test.dart:539-557`)
   filters `overflow`, `RenderFlex`, `ListTile background color` and
   `ink splashes may be invisible` globally. Any future gallery layout defect can
   re-enter silently. Narrowing that filter to the specific pre-existing offenders
   would be genuine value, but it lives in a test file outside this task's
   writeset — recommend follow-up.
3. **`catalog_revalidation_test.dart` + `catalog_exercise_test.dart` cannot
   persist traces** — `apps/catalog/docs/` does not exist, so
   `docs/reports/host-exercise/traces/` writes throw. This is a stale path left by
   the `docs/reports/` → `.project/reports/` relocation. Pre-existing and
   unrelated, but it currently makes 4 catalog host-composition tests
   unconditionally red. Recommend follow-up.
4. **Sibling finding** — `ds_health_card.dart:82` overflow at `1280x800` (above).

## Lane History

- **2026-09-29 (claim)**: dispatched to builder `ses_f1ee3073fffeYYUxe5CchM9CJb` after serialized behind 1839 (resource collision: both mutate `packages/warp_prism_ui` + `apps/catalog` build artifacts). Resource released when 1839 completed.
- **2026-09-29 (post-review)**: Review verdict **BLOCKED (45/100)** — evidence-based, code edits verified via `git diff` + independent reproduction at the same BoxConstraint debug path. Stay in `02-doing` awaiting catalog-host proof. **Review evidence: `.project/reports/reviewers/1840-catalog-statusticker-overflow-listtile-warnings-review-loop.md`.**
  - F1 (Serious, evidence gap): host proof `flutter run -d linux` unavailable in headless — unchanged in behavior spec to keep it open but non-disqualifying. Move out if done.
  - F2 (Serious): `design_system_gallery_test.dart:543-556` suppresses `RenderFlex overflow`/ink warnings — prevents regression assertions per host-composition law. **Routed to separate task**.
  - F3-F6 documented on review findings.
  - **Remaining lane acceptance gates: execution of a real catalog host run** + narrowing the test-suppressor to its explicit fixing task. This does not permit acceptance — the current edge state stays BLOCKED until the hardware evidence gameproof is delivered.
