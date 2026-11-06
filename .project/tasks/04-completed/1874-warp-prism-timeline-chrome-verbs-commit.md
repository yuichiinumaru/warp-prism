# Task 1874: Timeline chrome + IDS verbs + commit invariant (F-07)

> **Epic**: [EPIC-P0-trust-core](../epics/EPIC-P0-trust-core.md) · **Story**: [P0-S04](../stories/P0-S04-shell-timeline-transport.md)
> **Source**: `.project/research/final-upgrade-backlog-2026-11-01.md` F-07 (I=60, seam S7) — WB-U3, TP U-04, EV-11, FG-U4 (B1 one-gesture-one-undo + `Set|Scrub` typing), Macro P1-2/P1-8/C3, gap-matrix §3.
> **Priority**: P0 · **Depends on**: Task 1875 formatter seam + Task 1868 gating (construction on frozen interfaces may start; integration waits). **Parallelizable with**: Task 1871.

Highest-coupling cluster in P0. WB `TimelineStrip` (1s ticks, 52px lanes, 48px min-target, `pixelsPerSecond` ctor-only, seek delegated to `timeline_intents.dart`) proves semantics-outside-widget; TP `StudioTimelineLane`+`MusicalRuler`+painters prove the second ontology. Donor B1 (`right.rs:26-57` one-undo-step + `FieldEdit Set|Scrub`) supplies the shared commit invariant. Validate on the WB side first (weaker layout).

## Outcome and boundaries

Land organism `PrismMultitrackTimeline` (`PrismTimeRuler` + `PrismTrackLane` + playhead) + IDS `TimelineIntent` verbs over an injected model + cross-cluster commit invariant (one-gesture-one-history-step, live-vs-committed typed `Set|Scrub`). Domain painters/math (musical grid, DSP, NLE models, quantisation) stay product-local. Two-ontology conformance: seconds AND bars/beats. EXPERIMENTAL, no barrel export.

Non-goals: time-ontology unification; musical math, calibration, painters, DAW orchestration (product-local); numeric-field widget (P1 F-14, consumes the commit invariant); no STABLE promotion.

## Where

| Path | Why |
|---|---|
| `packages/warp_prism_ui/lib/src/organisms/ds_timeline.dart` | Existing timeline base — extension/composition site (read before mutating) |
| `packages/warp_prism_interaction/lib/src/` | New `TimelineIntent` verbs module (pure-Dart law) |
| `packages/warp_prism_ui/lib/src/organisms/` | New `PrismTimeRuler`/`PrismTrackLane`/playhead homes |
| `packages/warp_prism_ui/test/boundaries/boundary_test.dart` | Purity check in-task |
| `docs/bridge/warpblade/ads-debt.md` | WB `TimelineStrip` + `timeline_intents.dart` citations — re-verify live |
| `docs/bridge/tempest/ads-debt.md` | TP lane/ruler/painter citations — re-verify live |

## Work

- [ ] Re-verify both ontology donors live (WB strip geometry + intent delegation; TP lane/ruler) and record the two-ontology requirement exactly.
- [ ] Implement IDS verbs + commit invariant (`Set|Scrub` typing, one-gesture-one-history-step); conformance suite: two-ontology (seconds AND bars/beats render + convert deterministically), pixel↔time determinism (fixed geometry ⇒ fixed mapping).
- [ ] Implement timeline chrome over the injected model; gating of verbs through 1868's outcome type; formatters through 1875's injected seam — no local time ontology.
- [ ] Fake/reference (injected-model stub) + suite green; WB-side validation first, then TP studio route.
- [ ] Format/analyze clean; boundary green; host proof WB + TP (backlog gate).

## Success and verification

Success = timeline chrome renders both ontologies, verbs are pure-Dart and gated, commit invariant holds (one gesture ⇒ one history step), pixel↔time deterministic, MISSION §6 gates (2)(3)(4)(5 WB+TP)(7 review) hold. Barrel/API-freeze deferred.

```bash
dart format --set-exit-if-changed packages/warp_prism_interaction/lib/src packages/warp_prism_ui/lib/src/organisms
flutter analyze packages/warp_prism_interaction packages/warp_prism_ui
flutter test packages/warp_prism_interaction/test packages/warp_prism_ui/test/organisms packages/warp_prism_ui/test/boundaries/boundary_test.dart
```

Expected evidence: green suites with two-ontology + determinism tests, WB-first then TP host logs, reviewer verdict.

## Context / reliance

Blocked on 1875 (formatter seam) + 1868 (gating) for integration; interface-stable construction may proceed. U-IDS review input (verbs/commit in IDS — batched review). U-ARITH note: Tempest 43/50-vs-39+12 inventory gap must be reconciled at execution time before this task promotes (re-scan Tempest, record the 4-row disposition).

## Parent verification — 2026-11-01 (builders lane, post-worker return)

- **Worker**: `gtb-engineer-flutter` via User-authorized `opencode run` (`opencode-go/muse-spark-1.3-contributor`), shell `sh_197020f5100136l7u0CJTF91Nh`. Handoff `status: complete` received; full packet in shell output (not copied here).
- **Filesystem check**: IDS `timeline/` (intent + model) + 20-test suite, UI `organisms/timeline/` (ruler + lane + multitrack) + 14-test suite present; `boundary_test.dart` additive-only (4 `timeline_1874_*`); 1871's files untouched (its `ds_detail_inspector.dart` M carries no timeline markers — 1871's active work); no barrel/alias exports (grep over 4 barrels empty).
- **Parent re-run (fresh, after return, with 1871 still active in tree)**: `dart format` on 7 touched paths → 0 changed exit 0; intent suite → **20/20 pass exit 0**; multitrack UI suite → **14/14 pass exit 0**; pure-dart boundary harness → **47/47 PASS exit 0** (44 + 1871's 3 landed checks, no interference).
- **Not re-run by parent**: full interaction 253 + organisms 801 (worker-fresh green output accepted as evidence input; re-proof belongs to independent review).
- **Known residuals**: real-host WB/TP exercise substituted with headless sweep (sibling repos outside workspace boundary; exact limitation recorded); Tempest 4-row arithmetic reconciled doc-internally (43 current ✓, 45 planned vs cited 50, 88 total ✓) with live re-scan deferred to pre-promotion; donor citations INHERITED-REPORT.
- **Lane**: stays in `02-doing/`; submission move belongs to the authorized actor after independent review. Independent review (MISSION §6 gate 7) still required — NOT self-granted.

## Review Ledger — 2026-11-06 (independent review, BUILDER_CONTEXT)

- **Reviewer**: fresh `gtr-reviewer-flutter` session `ses_e51b2a451ffeb2Z8G8XtGq5Ev3` (independent — did not build). Report: `.project/reports/reviewers/20261106-005505-review-task-1874-timeline-chrome-verbs-commit.md`.
- **Verdict**: PASS (90/100 diagnostic). No remediation requested.
- **Accepted evidence**: format 171 files 0-changed; IDS 20/20 + UI 14/14; interaction full 281/281; organisms+molecules 1381/1381; boundary 81/81 (4× `timeline_1874_*`); interaction analyzer clean; UI analyzer zero errors (same unrelated 1860 warning); EXPERIMENTAL containment; one-gesture-one-step at verb/model/widget levels; UI/interaction mirror documented with parity.
- **Residuals (non-blocking)**: real WB/TP host proof owed before STABLE; Tempest inventory live re-scan deferred to pre-promotion; donor citations INHERITED-REPORT (behavior re-proven live).
- **Cross-task**: blast radius minimal/isolated vs 1871 (distinct writesets, shared boundary green, frozen shared foundations consumed read-only).
- **Lane**: stays in `02-doing/` pending closeout mechanics. No promotion claimed.

## Promotion — 2026-11-06 (parent closeout batch)

- Independent acceptance: PASS 90/100; IDS 20/20 + UI 14/14 + supersets green, boundary 81/81 (see Review Ledger above for report path).
- Lane: promoted to `04-completed` by parent (orchestrator-karax). No product files changed in promotion.
- Promotion changelog entry: `.project/changelog/20261106-235900-1874-warp-prism-timeline-chrome-verbs-commit-promoted-orchestrator-karax.md`. Canonical index/views rebuild pending (changelog tool unreachable this session; no hand-edits to generated surfaces).
