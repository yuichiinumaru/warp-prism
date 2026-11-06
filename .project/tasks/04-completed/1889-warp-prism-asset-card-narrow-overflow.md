# Task 1889: DSAssetCard narrow-cell vertical overflow (3.3px) at fixed small widths

> **Priority**: P1 (blocks Task 1883 green; narrow-host correctness) · **Type**: `bugfix` | `flutter` | `host-composition`
> **Origin**: Task 1883 fixer wave 2026-11-01 — `session_1883 ... narrow viewport keeps Tempest Library clean` fails on a genuine product-widget overflow, documented with file:line + repro instead of a workaround (parent-authorized scope: fixer forbidden from touching product widgets).
> **Depends on**: nothing (independent). **Blocks**: Task 1883 final green (1 of 23 tests).
> **Writeset constraint**: `packages/warp_prism_ui/lib/src/molecules/ds_asset_card.dart` ONLY (+ its directly-affected widget tests, if any exist). No new widgets, no API redesign, no token/barrel changes.
> **Collision**: check `.project/sessions/sessions.md` builders section before dispatch; this file's writeset must not overlap a concurrent worker's.

## Outcome and boundaries

Fix the 3.3px bottom `RenderFlex` overflow inside `DSAssetCard` internals
(`ds_asset_card.dart:56` `Column`) when the card is laid out in narrow fixed
cells (observed: 212.0×119.8 cell, `Size(212.0, 119.8)`). The card's
name/kind/description/tags stack must fit fixed small cells without overflow;
make content flexible/ellipsized/scrollable rather than clipping away meaning.
Preserve all existing card behavior, chrome, and API (constructor-compatible;
no caller changes required).

Non-goals: no card redesign, no new card variants, no token changes, no
gallery changes, no golden refreshes beyond what this fix strictly requires
(record any golden diff as evidence, do not mass-update goldens).

## Where

| Path | Purpose |
|---|---|
| `packages/warp_prism_ui/lib/src/molecules/ds_asset_card.dart` | Modify — the overflowing `Column` at `:56` and its children sizing only |
| `packages/warp_prism_ui/test/organisms/session_1883_session_panel_convergence_test.dart` | Read-only proof — the failing narrow-viewport test (`narrow viewport keeps Tempest Library clean`); must go green without weakening its fixtures or viewport |
| `packages/warp_prism_ui/test/molecules/` | Read sibling card/asset tests before mutating; extend only if the fix needs direct coverage |
| `packages/warp_prism_ui/test/boundaries/boundary_test.dart` | Gate — purity harness must stay green |

## Work

- [ ] **Read before modifying**: `ds_asset_card.dart` full file (internals stack at `:56`), the failing test's narrow-viewport section, and any existing asset-card widget tests.
- [ ] **Reproduce**: run the failing test and record the exact overflow (`3.3px bottom`, `Size(212.0, 119.8)`) before the fix.
- [ ] **Fix at the widget layer**: make the card content fit fixed small cells (tighter spacing, `Flexible`/`Expanded`, ellipsis, or bounded scroll — smallest change that preserves chrome and API).
- [ ] **Verify no regressions**: full `molecules` + `organisms/session_1883` suites green; boundary harness green.
- [ ] **Record evidence**: overflow before/after, commands + exit codes, residual risks.

## Success and verification

Success = `DSAssetCard` renders in 212px-wide fixed cells with zero
`RenderFlex` overflow, existing card tests still green, and the Task 1883
narrow-viewport test passes unmodified (same fixtures, same viewport).

```bash
dart format --set-exit-if-changed packages/warp_prism_ui/lib/src/molecules/ds_asset_card.dart
flutter analyze packages/warp_prism_ui
flutter test packages/warp_prism_ui/test/organisms/session_1883_session_panel_convergence_test.dart
flutter test packages/warp_prism_ui/test/molecules packages/warp_prism_ui/test/boundaries/boundary_test.dart
```

Expected evidence: `session_1883` 23/23 green, no new analyzer issues on the touched file, boundary still green.

## Parent verification — 2026-11-01 (builders lane, post-worker return)

- **Worker**: `gtb-engineer-flutter` via User-authorized `opencode run` (`opencode-go/muse-spark-1.3-contributor`), shell `sh_197c32466001eBMOTzGUOqa4ZE`. Handoff `status: complete` received; full packet in shell output (not copied here).
- **Filesystem check**: `ds_asset_card.dart` only (5+/4−: 2 gaps sm→xs + rationale comments); no other lib/test touched.
- **Parent re-run (fresh, after return, tree quiet, `--no-pub` — pub network stalls in this env)**: `dart format` → 0 changed; narrow 1883 test file → **23/23 pass exit 0** (the previously failing narrow-viewport test now green unmodified); pure-dart boundary harness → **76/76 PASS**; `flutter analyze` on card file → clean (covered in run below with seam files).
- **Lane**: stays in `02-doing/`; submission move belongs to the authorized actor after independent review. Independent review (MISSION §6 gate 7) still required — NOT self-granted.

## Review Ledger — 2026-11-06 (independent bundled review, BUILDER_CONTEXT)

- **Reviewer**: fresh `gtr-reviewer-flutter` session `ses_e517e97e8ffeIZ1D2JvbZ6cmNN` (independent — did not build). Report: `.project/reports/reviewers/1889-warp-prism-asset-card-narrow-overflow-review-loop.md` (carries once-per-bundle blast-radius section).
- **Verdict**: PASS (90/100 diagnostic). No remediation. Known-required companion of 1883 (accepting 1883 without 1889 leaves the documented 22/23 failure); all other acceptance orders regression-free.
- **Accepted evidence**: task-exact format/analyze clean; 1883 narrow-viewport file unmodified 23/23; molecule siblings 134/134; boundary 81/81; writeset exactly `ds_asset_card.dart` (2 gaps + rationale comments, API/chrome/behavior identical).
- **Residual (non-blocking)**: extreme-narrow/text-scale cells unproven — follow-up on real-host evidence only.
- **Lane**: stays in `02-doing/` pending closeout mechanics. No promotion claimed. Independent review still required — NOT self-granted.

## Context / reliance

Unblocks Task 1883 (F-16) final green: the 1883 seam is otherwise proven
(22/23 + all gates). Feeds nothing else. Minimal fix in the card only;
any broader card-layout redesign is explicitly out of scope — record as
follow-up instead.

## Parent note — 2026-11-01 (builders lane; materialized, not started)

- **Source**: 1883-fixer finding (file:line `ds_asset_card.dart:56`, repro: pump `DSTempestLibraryView` with the `lib-vocals` fixture set at 500×900 in a vertical scroll view; both grid cells overflow identically).
- **Scope guard**: card internals only. If the fix requires touching table/grid/shell/theme files, stop and escalate instead — that is a different task.
- **Lane**: materialized directly in `01-open/` (no dependency, immediately actionable). Claim (`01-open → 02-doing`) happens at parent dispatch.

## Promotion — 2026-11-06 (parent closeout batch)

- Independent acceptance: PASS 90/100; narrow-viewport file 23/23 unmodified, siblings 134/134, boundary 81/81 (see Review Ledger above for report path).
- Lane: promoted to `04-completed` by parent (orchestrator-karax). No product files changed in promotion.
- Promotion changelog entry: `.project/changelog/20261106-235900-1889-warp-prism-asset-card-narrow-overflow-promoted-orchestrator-karax.md`. Canonical index/views rebuild pending (changelog tool unreachable this session; no hand-edits to generated surfaces).
