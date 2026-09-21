---
date: 20260711-120000
timestamp: 20260711-120000
project: warp-prism
agent: gt-flutter-engineer
task: "1507"
description: "Add PrismTimeMachineScrubber density histogram + playback organism"
is_rebuild_safe: true
---

# Task 1507: PrismTimeMachineScrubber Organism

## Summary

Implemented `DSTimeMachineScrubber` with public alias `PrismTimeMachineScrubber` —
density histogram, playhead scrubber, and timer-based play/pause transport over
fixture time series. Distinct from `PrismTimeline` / `DSTimeline` event lists
(list = narrative; scrubber = temporal control / as-of range). ADS-first:
gallery + tests only; no Observatory route rewrite, no live feeds.

## Changes

- Created `packages/warp_prism_ui/lib/src/organisms/time_machine_scrubber/`:
  - `ds_time_machine_scrubber.dart` — models (`DSTimeDensityBucket`,
    `DSTimeDensitySeverity`), histogram painter, scrub gestures, transport
    (skip / play-pause / live), as-of range callbacks, a11y labels
  - `time_machine_scrubber.dart` — barrel export
- Exported from `organisms.dart` (append-only)
- Aliased in `prism_aliases.dart`:
  - `PrismTimeMachineScrubber`, `PrismTimeDensityBucket`,
    `PrismTimeDensitySeverity` (dartdoc notes pairing with `PrismTimeline`)
- Minimal gallery case under Organisms with 24h fixture density
- Widget tests: render, scrub, play/pause, empty, min/max bounds, controlled
  playhead, a11y, domain helper, public model aliases

## Verification

```bash
cd packages/warp_prism_ui
dart analyze lib/src/organisms/time_machine_scrubber lib/src/organisms/organisms.dart \
  lib/src/prism_aliases.dart lib/src/gallery/design_system_gallery_sections.dart \
  test/organisms/time_machine_scrubber
# → No issues found

flutter test test/organisms/time_machine_scrubber/
# → All tests passed (10)

dart run test/boundaries/boundary_test.dart
# → Boundary harness: 6/6 PASS
```
