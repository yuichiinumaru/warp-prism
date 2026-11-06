# Task 1867: Harness upgrades — layer-table compaction, two-tier capture, drain/cancel, junk sweeps, toast policy

Change only the harness/testkit/host-exercise seam: (a) compact the 16
hand-written boundary assertions toward the generated layer table + generic
upward rule; (b) two-tier capture (chrome-free deterministic render goldens +
windowed chrome screenshot + structured inspect) with bounded waits and
visible-window errors; (c) frame-boundary drain + cooperative-cancel
placement for FRB adapter work + standing junk/adversarial sweep on every
IDS/runtime suite with mechanism-mirrored filenames + stable test-id
convention; (d) toast policy (cap/sticky/action/hand-back/
onDismiss-only-on-close) in `PrismToastManager`. Land first where
independent. Success is the stated observable behavior.

## Outcome and boundaries

- **Authorized outcome**: (a) layer-table compaction: generated table is the
  single source, all greens held, generic upward rule proven; (b) two-tier
  capture documented + reference-passing on at least one golden and one
  windowed capture; drain/cancel placement proven for the FRB adapter path;
  (c) junk/adversarial sweep green on every IDS + runtime suite with stable
  test-ids and mirrored filenames; (d) toast policy implemented + conformance
  green (cap, sticky, action, hand-back, onDismiss-only-on-close).
- **Subject**: boundary harness + testkit + host-exercise + toast manager.
  No widget new-primitive work.
- **Constraints**: every existing suite stays green through migration
  (migration is mechanical, verified per step). Determinism: bounded waits
  only; no animation-dependent goldens. Toast changes never alter job-banner
  semantics (Task 1858 owns the job vocabulary). Layer-contracts §10: same
  task updates harness + owner doc row.
- **Non-goals**: no contract change (except Task 1859's executor concept,
  owned there); no golden-baseline freeze litigation (Task 1816 owns the
  freeze dispute); no new host-exercise product coverage beyond the capture
  tiers.

## Context / reliance

- Source evidence: backlog F-19 card (donor A1 `layers.rs:8-75` TABLE +
  direct-deps + fail-closed → 16-check compaction; A4/A5/A6 two-tier capture
  + frame-drain + cooperative cancel; FG-U8/B6 junk sweeps + mirrored names +
  stable ids + `tab_to`-by-name; EV-M2 toast policy; Macro §6 gates +
  UNKNOWN-4 host-proof debt).
- Score rationale: impact 60 on leverage — scheduled first where
  independent (layer-table + junk nets are 1-session wins per backlog §7).
- MISSION §§6 (evidence gates stand), 9 (format/analyze/boundary/barrel/
  determinism/a11y/host/review); layer-contracts §10.

## Where

| Path | Role | Notes |
|---|---|---|
| `packages/warp_prism_ui/test/boundaries/boundary_test.dart` | Extend | 16-check compaction target; read all checks first |
| `.project/architecture/layer-contracts.md` | Extend | Same-task §10 row update for any new/changed check |
| `packages/warp_prism_testkit/lib/src/` | Extend | Junk-sweep + mirrored-filename + stable-id conventions |
| `packages/warp_prism_interaction/` | Sweep target | Junk/adversarial sweep over IDS suites (read-only src, new tests) |
| `packages/warp_prism_runtime/` | Sweep target | Junk/adversarial sweep over runtime suites |
| `packages/warp_prism_host_exercise/lib/` | Extend | Two-tier capture entrypoints (smoke/crawl/fuzz adjacency) |
| `packages/warp_prism_ui/lib/src/molecules/ds_toast_manager.dart` | Extend | Toast policy home |
| `packages/warp_prism_ui/lib/src/molecules/ds_toast.dart` | Reference | Toast chrome conventions |
| `apps/catalog/lib/` | Proof lab | Capture-tier gallery determinism where applicable |

## Work / responsibility

- [ ] Read all 16 boundary checks + §10 table + testkit conventions + toast
  manager + host-exercise entrypoints before mutation.
- [ ] (a) Compact layer table: collapse hand-written assertions toward the
  generated table + generic upward rule; keep every green green.
- [ ] (b) Land two-tier capture reference + drain/cancel placement proof for
  the FRB adapter path.
- [ ] (c) Run junk/adversarial sweep across IDS + runtime suites; mirror
  filenames to mechanisms; stabilise test-ids.
- [ ] (d) Implement toast policy + conformance (cap/sticky/action/hand-back/
  onDismiss-only-on-close).
- [ ] Run FULL validation below; bind every output.

## Success and verification

- All pre-existing suites green after migration (no red masked as
  pre-existing without classification evidence).
- Capture determinism: same input ⇒ same output; bounded waits; windowed
  capture errors visible, never silent.
- Toast conformance green incl. hand-back + cap behaviour.
- MISSION §6: item 4 (boundary harness itself improved + green), item 7
  (review); items 2–3 where new suites added; item 5 where capture tiers
  touch host exercise; item 6 for the FRB drain/cancel leg.
- Format/analyze/boundary/barrel clean.

## Parent verification — 2026-11-01 (builders lane, post-worker return)

- **Worker**: `gtb-engineer-flutter` via User-authorized `opencode run` (`opencode-go/muse-spark-1.3-contributor`), shell `sh_197c80153001NLENjgIO5krwN` + text-only handoff extract `sh_197df2437001EmR3N4b0yU0Vne`. Handoff `status: partial` = all four parts landed + proven on own suites; full-UI sweep shows only the 63 pre-existing environmental golden mismatches.
- **Parent re-run (fresh, after return, tree quiet — Fase 0 siblings run greps only)**: `dart` boundary harness → **81/81 PASS exit 0** (5 new 1867 checks green, 76 legacy intact); toast conformance → **8/8 pass**; IDS junk suites → **28/28 pass**; runtime junk suites → **16/16 pass**; host_exercise → **17/17 pass**; `dart format` on 5 touched paths → 0 changed; `dart analyze` interaction+runtime+testkit+junk+capture → No issues found; `flutter analyze` on seam files → zero errors/warnings (infos only).
- **Scope discipline confirmed**: no product-widget edits (remaining tree M's are whitespace-only reformats or other waves' landed work — verified by diff inspection); layer-contracts.md §10 edit is task-authorized (task Where table + layer-contracts §10 self-update law); no contract change, no job-banner semantic change.
- **Known residuals**: full-UI +2207 with 63 pre-existing environmental golden pixel diffs (none in touched surfaces; golden-freeze dispute belongs to Task 1816, not litigated here); harness_catalog rebuild/validate numbers stand from prior waves (tool absent in runtimes).
- **Lane**: stays in `02-doing/`; submission move belongs to the authorized actor after independent review. Independent review (MISSION §6 gate 7) still required — NOT self-granted.

## Review Ledger — 2026-11-06 (independent bundled review, BUILDER_CONTEXT)

- **Reviewer**: fresh `gtr-reviewer-flutter` session `ses_e519a6438ffeiur7fRB9no1jas` (independent — did not build). Report: `.project/reports/reviewers/1867-warp-prism-harness-upgrades-capture-nets-toast-review-loop.md` (Entry 1, new file).
- **Verdict**: PASS (86/100 diagnostic). No remediation.
- **Accepted evidence**: format 312 files 0-changed; interaction+runtime analyze clean; testkit+interaction+runtime 445; host_exercise 17; toast 8/8; boundary 81/81 (5 new checks, 76 legacy held); toast lifecycle clean (timers id-captured/cancelled, mounted guards, dispose teardown); capture bounded; junk nets fail-closed; EXPERIMENTAL containment; owns §10 rows 17–20.
- **Lane**: stays in `02-doing/` pending closeout mechanics. No promotion claimed.

**Validation commands**:

```sh
dart format --set-exit-if-changed packages/warp_prism_ui/lib packages/warp_prism_testkit/lib packages/warp_prism_host_exercise/lib packages/warp_prism_interaction/lib packages/warp_prism_runtime/lib
flutter analyze packages/warp_prism_ui packages/warp_prism_testkit packages/warp_prism_host_exercise
dart analyze packages/warp_prism_interaction packages/warp_prism_runtime
flutter test packages/warp_prism_ui/test/boundaries/boundary_test.dart
flutter test packages/warp_prism_testkit packages/warp_prism_interaction packages/warp_prism_runtime
flutter test packages/warp_prism_ui packages/warp_prism_host_exercise
```

## Evidence / assessment

- Bind results here: per-leg outputs (table compaction diff, capture paths,
  sweep report, toast suite), full test logs, review verdict. Any held-green
  regression is a finding, not a footnote.

**Parallelizable with**: everything — but its conventions (filenames,
test-ids, capture tiers) are read-only inputs to siblings once landed;
land early, announce the convention commit, then let siblings follow.
Shared-write guard: this task owns `boundary_test.dart` + §10 rows for the
tranche.

## Promotion — 2026-11-06 (parent closeout batch)

- Independent acceptance: PASS 86/100; 445 + 17 + 8/8 green, boundary 81/81, toast lifecycle clean (see Review Ledger above for report path).
- Lane: promoted to `04-completed` by parent (orchestrator-karax). No product files changed in promotion.
- Promotion changelog entry: `.project/changelog/20261106-235900-1867-warp-prism-harness-upgrades-capture-nets-toast-promoted-orchestrator-karax.md`. Canonical index/views rebuild pending (changelog tool unreachable this session; no hand-edits to generated surfaces).
