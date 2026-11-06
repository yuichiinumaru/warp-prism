# Task 1870: Command registry + self-doc catalog + dispatch router (F-03)

> **Epic**: [EPIC-P0-trust-core](../epics/EPIC-P0-trust-core.md) · **Story**: [P0-S02](../stories/P0-S02-command-review-spine.md)
> **Source**: `.project/research/final-upgrade-backlog-2026-11-01.md` F-03 (I=100, seam S2) — WB-U7, TP U-06, CC W4, EV-H4, FG-U1 (A2 self-doc `describe()`), Macro P1-1/C5.
> **Priority**: P0 · **Parallelizable with**: Task 1873 after 1868's eligibility shape freezes (different writesets; shared IDS-review batch).

IDS has no command module (live: only `input/inspection/query/selection/state_machine`); `DSCommand` has shortcut hints but no registry/applicability/index. Donor A2 (`control.rs:221-226` returning `{id,label,params,menu,shortcut,undoable}`) proves the drift-proof shape; the keyboard guard stays presentation while eligibility stays IDS.

## Outcome and boundaries

Land IDS `CommandIntent` registry (identity/label/chord/applicability/enabled-reason/enumeration) with Figcraft self-doc seam (`describe()`, non-drift), the runtime `describe()` seam, `DSCommandPalette`/`DSToolStripSlideout` extension for disabled-reason propagation, and a router molecule with edit-focus guard (palette stays presentation). Chord collision/precedence + enumeration stability + keyboard-only path proven by suite. EXPERIMENTAL, no barrel export.

Non-goals: visual restyle of the palette beyond reason propagation; command *execution* backends and product command tables (product-local); toolbar-panel framework (P1 F-12); no STABLE promotion.

## Where

| Path | Why |
|---|---|
| `packages/warp_prism_interaction/lib/src/` | New command module home (beside `input/`, `selection/`, `state_machine/`); pure-Dart law applies |
| `packages/warp_prism_ui/lib/src/organisms/command_palette/ds_command_palette.dart` | `DSCommand` (`:28`) + palette — extension site for registry/applicability |
| `packages/warp_prism_ui/lib/src/organisms/command_palette/command_palette.dart` | Public barrel side of the palette |
| `packages/warp_prism_runtime/` | `describe()` seam home (presentation-free law holds) |
| `packages/warp_prism_ui/test/boundaries/boundary_test.dart` | New-module purity check in-task |
| `docs/bridge/warpblade/ads-debt.md` | WB `keyboard_shortcuts.dart:62-64` guard citation — re-verify live |

## Work

- [ ] Inventory live IDS modules + `DSCommand` shape; re-verify donor A2 shape and WB guard citation (record INHERITED-REPORT provenance where unreadable).
- [ ] Implement IDS registry: identity, label, chord, applicability predicate, enabled-reason, stable enumeration; collision/precedence rules.
- [ ] Implement runtime `describe()` seam + router molecule with edit-focus guard; keyboard-only path test (every registered command reachable and its disabled reason announced).
- [ ] Fake/reference + conformance suite: enumeration stability across runs, chord-collision determinism, disabled-reason propagation end-to-end (IDS eligibility ⇒ palette render).
- [ ] Eligibility resolves through Task 1868's outcome type — consume its frozen interface; do not re-invent availability.
- [ ] Format/analyze clean; boundary green; host proof WB + CC (router exercised on a real host route with a chord conflict and a disabled-with-reason command).

## Success and verification

Success = registry enumerates stably, collisions resolve deterministically, disabled reasons propagate to the palette, keyboard-only path complete, MISSION §6 gates (2)(3)(4)(5 WB+CC)(7 review) hold. Barrel/API-freeze deferred.

```bash
dart format --set-exit-if-changed packages/warp_prism_interaction/lib/src packages/warp_prism_ui/lib/src/organisms/command_palette
flutter analyze packages/warp_prism_interaction packages/warp_prism_ui packages/warp_prism_runtime
flutter test packages/warp_prism_interaction/test packages/warp_prism_ui/test/organisms packages/warp_prism_ui/test/boundaries/boundary_test.dart
```

Expected evidence: green suites with enumeration-stability + collision tests, host logs for WB and CC routes, reviewer verdict.

## Context / reliance

Consumes Task 1868's eligibility interface (construction on the frozen interface may proceed; integration waits for 1868's implementation). U-IDS review input (registry in IDS — batch with 1868/1873/1874 proposals). Feeds Task 1871 (review surface dispatches through this registry).

## Parent verification — 2026-11-01 (builders lane, post-worker return)

- **Worker**: `gtb-engineer-flutter` via User-authorized `opencode run` (`opencode-go/muse-spark-1.3-contributor`), shell `sh_196e52b7c002NXvRxnz0g0h0Ub`. Handoff `status: complete` received; full packet in shell output (not copied here).
- **Filesystem check**: new IDS `interaction/src/command/` (6 files), runtime `describe/` seam, `ds_command_router.dart` molecule present; palette + tool-strip edits additive; `boundary_test.dart` additive-only (7 `registry_1870_*`); 1875's transport files untouched; no barrel/alias exports.
- **Parent re-run (fresh, after return)**: `dart format` on new lib paths → 0 changed exit 0; pure-dart boundary harness → **33/33 PASS exit 0** (the `command_context.dart` doc-comment leak flagged mid-wave was fixed by the worker before handoff); `flutter test interaction/test + runtime/test` → **229 pass exit 0** (matches worker's 221+8); new UI suites (router + disabled-reason + host-composition) → **20 pass exit 0**.
- **Not re-run by parent**: full organisms 747 green (worker-fresh output accepted as evidence input; re-proof belongs to independent review).
- **Known residuals**: real-host WB/CC exercise substituted with headless composition sweep (sibling repos outside workspace boundary + headless env; exact limitation recorded); small-viewport `_CategoryChips` overflow proven pre-existing via control-vs-treatment pumps (palette-owner follow-up, out of scope).
- **Lane**: stays in `02-doing/`; submission move belongs to the authorized actor after independent review. Independent review (MISSION §6 gate 7) still required — NOT self-granted.

## Review Ledger — 2026-11-06 (independent bundled review, BUILDER_CONTEXT)

- **Reviewer**: fresh `gtr-reviewer-flutter` session `ses_e51da4820ffebdCKhZVV4JlJNR` (independent — did not build). Report: `.project/reports/reviewers/20261106-000803-review-task-1870-command-registry-selfdoc-dispatch.md` (includes the 1868–1870 cross-task blast-radius assessment).
- **Verdict**: AMEND (83/100 diagnostic). No code change requested.
- **Accepted package evidence**: format 32 files 0-changed; task-exact suites 1214 pass; focused analyzer on touched paths clean; EXPERIMENTAL containment (no barrel/alias exports); registry consumes 1868's authority vocabulary without reimplementation; shared boundary run 81/81 PASS (reviewer-executed, current tree).
- **Blockers (no builder remediation requested)**:
  - B1 (external): task-required real WB+CC host proof (chord conflict + disabled-with-reason on a real route) unavailable — consumers outside the workspace boundary.
  - B2 (baseline owner): literal three-package `flutter analyze` exits non-zero on the pre-existing 226-issue baseline; focused touched-path analysis is clean and no diagnostic is assigned to this task. Disposition belongs to the analyzer-baseline owner.
- **Lane**: stays in `02-doing/` pending B1/B2 disposition or an authorized acceptance decision. No promotion claimed.

## Gate update — 2026-11-06

- B2's literal gate is now green: package-wide `dart analyze` exits 0 (225 infos, 0 warnings/errors) after the 1860 import fix. B2 collapses to a non-blocking baseline-hygiene note for the baseline owner. B1 (external CC/WB host proof) is the sole remaining acceptance item.
