---
date: 20261011-043721
timestamp: 20261011-043721
project: warp-prism
agent: builder-engineer
task: "rem-0001"
description: "Boundary harness row-16 enforcement (16/16 checks), domain-regex extension (Warpblade/Tempest), and layer-contracts §10 per-row status column"
is_rebuild_safe: true
---

# Task rem-0001: Boundary harness row-16 enforcement + domain regex + §10 status column

## Summary

Closed three mechanical law-vs-harness gaps in one coherent unit (source: Inv-1
findings Gaps 1, 2, 5):

1. **Row 16 is now enforced.** `boundary_test.dart` gained check #16,
   `warp_prism_bindings does not import FRB generated surfaces`
   (`_checkBindingsNoFrbGenerated`), mirroring check #15's scan logic scoped to
   `packages/warp_prism_bindings/lib`. The bindings projection seam can no
   longer silently import `src/rust/` or `frb_generated` surfaces.
2. **Domain regex extended.** Check #14's regex now includes `Warpblade` and
   `Tempest`, matching the MUST-NOT law text (`layer-contracts.md` §4.6) that
   already names them. Zero live hits — latent gap closed, no behavior change
   on current source.
3. **§10 reconciled.** The 16-row check list is now a table with a per-row
   enforcement-status column (all `ENFORCED`); the row-16 `DOCUMENTATION ONLY`
   marker is gone and the 2026-09-28 drift note records the column's recovery.

## Changes

| File | Change |
| --- | --- |
| `packages/warp_prism_ui/test/boundaries/boundary_test.dart` | +`BoundaryCheck` #16 in registry; +`_checkBindingsNoFrbGenerated()`; domain regex `(Ganthritor\|Cersei\|OmniRoute\|CyberCore)` → `(...\|Warpblade\|Tempest)` |
| `.project/architecture/layer-contracts.md` (§10 only) | numbered list → 16-row table with `Status` column; row-16 marker removed; drift note updated with recovery record |
| `.project/changelog/20261011-043721-rem-0001-boundary-harness-row16-regex-status-builder-engineer.md` | this entry |

No pre-existing check was weakened; no other harness behavior changed
(simplicity pass verified line-by-line against the pre-edit state).

## Verification

| Command | Exit | Result |
| --- | --- | --- |
| `dart packages/warp_prism_ui/test/boundaries/boundary_test.dart` (pre-edit baseline) | 0 | 15/15 PASS |
| same (fixture in place) | 1 | 13/16 PASS — checks #14/#15/#16 each flag the probe fixture (detection proven) |
| same (post-revert, final) | 0 | **16/16 PASS, 0 FAIL, 0 violations** |
| `dart format --output=none --set-exit-if-changed <file>` | 0 | 0 changed |
| `dart analyze <file>` | 0 | No issues found |

Fixture proof: a temporary probe file in `packages/warp_prism_bindings/lib`
carrying an `frb_generated` import and a `Warpblade` token was detected by
checks #14, #15 and #16 in the same run, then deleted in the same change. Bindings
lib restored to `src/` + `warp_prism_bindings.dart` only.

Contention: none — no tool-lock errors encountered; retry protocol not needed.

Independent acceptance: pending (executor is not the reviewer).
