# Task 1860: PrismFilterBuilder organism plus PrismToolbarPanel framework

Change only the filter/toolbar seam in `warp_prism_ui`: add EXPERIMENTAL
organism `PrismFilterBuilder` (nested AND/OR, per-type editors,
debounce-commit+flush) and framework `PrismToolbarPanel`
(button→popover→typed-panel→reanchor) anchored on the partial
`PrismFilterWorkbench`. Success is the stated observable behavior, verified
by the relevant checks.

## Outcome and boundaries

- **Authorized outcome**: reusable filter + toolbar-panel framework exists as
  EXPERIMENTAL with fake model + per-type editor suite + determinism proof.
  Lands on real anchors: logs/timelines/status grids, Tempest library/models
  screens, Command-center session list, Warpblade takes.
- **Subject**: `warp_prism_ui` organism/framework layer. No new table, grid,
  board, list, or tree primitive — composition over `DSDataTable`,
  `DSVirtualList`, `DSLogViewer`, `DSFilterChipGroup`, `DSAssetCard`.
- **Constraints**: UI stays Flutter-only, no FRB/runtime/bindings/adapter
  imports; no consumer domain types; filter *semantics* that are reusable
  intent go to IDS only where genuinely generic (query intent exists —
  extend it only with evidence, else keep predicate types caller-supplied).
  Determinism: debounce-commit+flush must be clock-injectable, no unbounded
  waits. a11y: editor semantics + focus + announcements.
- **Non-goals**: no query-framework redesign; no audition/compare matrix
  (P2 F-20); no descriptor form (P2 F-21); no STABLE/barrel in this task.

## Context / reliance

- Source evidence: backlog F-12 card (donor HIGH H5 nested AND/OR +
  per-type editors + debounce-commit+flush; H7
  button→popover→typed-panel→reanchor; Macro C9; FG corroboration).
- Existing anchor: `packages/warp_prism_ui/lib/src/organisms/filter_workbench/`
  (partial — extend, don't fork). IDS query intent:
  `packages/warp_prism_interaction/lib/src/query/`.
- MISSION §3.1/§11.4; layer-contracts §§1, 4–5; MISSION §6 gates apply.

## Where

| Path | Role | Notes |
|---|---|---|
| `packages/warp_prism_ui/lib/src/organisms/filter_workbench/ds_filter_workbench.dart` | Extend | Partial anchor; read before mutation |
| `packages/warp_prism_ui/lib/src/organisms/data_table/` | Compose | Read sort/cell conventions; no new table primitive |
| `packages/warp_prism_ui/lib/src/organisms/virtual_scroll/` | Compose | Reference for bounded grid composition |
| `packages/warp_prism_ui/lib/src/molecules/ds_filter_chip_group.dart` | Compose | Chip vocabulary reuse |
| `packages/warp_prism_interaction/lib/src/query/` | Read | Query-intent seam; extend only with evidence |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Read-only | No export added (EXPERIMENTAL) |
| `packages/warp_prism_ui/test/boundaries/boundary_test.dart` | Gate | Layer purity harness |
| `apps/catalog/lib/` | Proof lab | EXPERIMENTAL gallery entries |

## Work / responsibility

- [ ] Read filter-workbench anchor, query intent, and data-table/virtual
  composition conventions before mutation.
- [ ] Specify filter model (group tree, per-type editors, debounce-commit +
  explicit flush, caller-supplied predicate kinds) + toolbar-panel framework
  states (closed→popover→typed-panel→reanchor).
- [ ] Implement organism + framework + fake model + per-type editor suite +
  determinism (injected clock) + a11y conformance.
- [ ] Fixed-viewport goldens for builder + panel; prove no animation-dependent
  capture.
- [ ] Gallery entries under EXPERIMENTAL; run full validation below.

## Success and verification

- Fake model + per-type editor suite green; debounce-commit+flush
  deterministic under injected clock; enumeration stable.
- Host proof: Tempest library/models route + Command-center session list
  composed in host exercise — interact, no framework errors / ErrorWidget /
  RenderFlex overflow, theme/focus intact.
- MISSION §6: items 1 (mandate + Macro C9), 2–4 (fake + conformance +
  boundary), 5 (host proof), 7 (independent review). Item 6 n/a.
- Format/analyze/boundary/barrel checks clean.

**Validation commands**:

```sh
dart format --set-exit-if-changed packages/warp_prism_ui/lib packages/warp_prism_interaction/lib
flutter analyze packages/warp_prism_ui packages/warp_prism_interaction
flutter test packages/warp_prism_ui/test/boundaries/boundary_test.dart
flutter test packages/warp_prism_ui
```

## Evidence / assessment

- Bind results here: suite + golden paths, host-exercise evidence per host,
  review verdict. Missing host proof blocks STABLE only.

**Parallelizable with**: Task 1858 (banner), Task 1861 (meter) — disjoint
writesets within `warp_prism_ui` at distinct seams; shared guards
(`prism_aliases.dart`, barrels, gallery registry) are read-only in this task.

## Parent verification — 2026-11-01 (builders lane, post-worker return)

- **Worker**: `gtb-engineer-flutter` via User-authorized `opencode run` (`opencode-go/muse-spark-1.3-contributor`), shell `sh_197164539001rm9de3KKXGG5hP` + 3 same-session resumes (`ses_e68e9ba2dffezZmgrXfJUwZVsu`). Handoff `status: complete` received in final resume; full packet in shell outputs (not copied here).
- **Filesystem check**: 4 new lib files (model/editors/builder/toolbar) + 4 new test files + 4 golden PNGs present; `boundary_test.dart` additive-only (3 `filter_1860_*`); 1861's meter/fader files untouched; no barrel/alias exports (grep over 3 barrels empty).
- **Parent re-run (fresh, after return, post footer Row→Wrap fix)**: `dart format` on 9 touched paths → 0 changed exit 0; per-file suites → **29 + 8 + 6 + 3 = 46/46 pass, exit 0 each** (worker packet said toolbar 9/9; actual is 8/8 — count drift only, zero failures); pure-dart boundary harness → **63/63 PASS exit 0**.
- **Not re-run by parent**: full UI suite (worker ran it in-wave; re-proof belongs to independent review).
- **Known residuals**: real-display host substituted with headless sweep (limitation recorded); 195px `DSDataTable` overflow is host-composition width law (routes scroll horizontally; builder footer wraps) — recorded as reusable finding; gallery wiring deferred to promotion (worker drafted+removed a catalog module that would violate the no-src-import boundary rule).
- **Lane**: stays in `02-doing/`; submission move belongs to the authorized actor after independent review. Independent review (MISSION §6 gate 7) still required — NOT self-granted.

## Review Ledger — 2026-11-06 (independent bundled review, BUILDER_CONTEXT)

- **Reviewer**: fresh `gtr-reviewer-flutter` session `ses_e5189151effeLEom6J55hHEubr` (independent — did not build). Report: `.project/reports/reviewers/1860-warp-prism-filter-builder-toolbar-panel-review-loop.md` (created; no prior entries existed).
- **Verdict at review**: FAIL (82/100 diagnostic) — single trivial task-owned defect RT-1860-01: `unused_import` warning at `filter_builder_1860_test.dart:13` in a file this task created. All else proven (46/46, format clean, boundary 81/81, lifecycle clean, EXPERIMENTAL holds).
- **Fix applied 2026-11-06 (parent tiny unblocker; delegation overhead exceeded the one-line work after two silent worker failures this wave)**: deleted line 13 (`import 'package:flutter/services.dart';`) — pre-deletion grep confirmed zero `services.*` usage in the file.
- **Re-proof (parent, exact reviewer prescription)**: `dart analyze` on the file → No issues found, exit 0; task suites 40/40 (29+8+3) + golden 6/6 → all pass, exit 0.
- **Next**: confirmatory delta re-review of RT-1860-01 by the same reviewer. No promotion claimed. Independent review (MISSION §6 gate 7) still required — NOT self-granted.

## Promotion — 2026-11-06 (parent closeout batch)

- Independent acceptance: FAIL RT-1860-01 then delta PASS; one-line import fix, analyzer clean, suites 46/46 (see Review Ledger above for report path).
- Lane: promoted to `04-completed` by parent (orchestrator-karax). No product files changed in promotion.
- Promotion changelog entry: `.project/changelog/20261106-235900-1860-warp-prism-filter-builder-toolbar-panel-promoted-orchestrator-karax.md`. Canonical index/views rebuild pending (changelog tool unreachable this session; no hand-edits to generated surfaces).
