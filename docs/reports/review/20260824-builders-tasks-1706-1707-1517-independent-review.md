# Independent BUILDER_CONTEXT Bundled Review — Tasks 1706, 1707, 1517

- **Review date:** 2026-08-24
- **Parent/orchestrator:** `builders`
- **Mode:** `BUILDER_CONTEXT`; score-only first, then residual path-to-100 inspection. Parent explicitly authorized promotion of each task scoring >=90.
- **Reviewer:** independent reviewer session (this report)
- **Scope boundary:** task files, task-owned implementation/tests, public barrels/aliases, task gallery surfaces, focused suites, gallery suite, boundary harness, formatter probes, and golden-freeze state. No unrelated product edits were performed.
- **Freshness:** all commands below were run from the live filesystem after the latest builder self-close evidence was read.

## Review Lineage

### Current tasks

- Task 1706: `docs/tasks/03-review/1706-warp-prism-prism-breadcrumbs-organism.md`
- Task 1707: `docs/tasks/03-review/1707-warp-prism-prism-accordion-collapsible-molecule.md`
- Task 1517: `docs/tasks/03-review/1517-warp-prism-terminal-workspace-fixture-shell.md`

### Previous reports read

- `docs/reports/review/1706-prism-breadcrumbs-independent-review-2026-08-23.md` — stopped before score.
- `docs/reports/review/1706-prism-breadcrumbs-reconciliation-review-2026-08-23.md` — 86/100; formatter drift and missing fallback/semantic proof.
- `docs/reports/review/20260824-task-1706-prism-breadcrumbs-review.md` — builder self-close 100/100; no lane move.
- `docs/reports/review/1707-prism-accordion-collapsible-independent-review-2026-08-23.md` — stopped before score.
- `docs/reports/review/1707-prism-accordion-collapsible-reconciliation-review-2026-08-23.md` — 87/100; formatter drift, missing direct 48dp proof, incomplete gallery multi-expand variant.
- `docs/reports/review/20260824-task-1707-prism-accordion-review.md` — builder self-close 100/100; multi-expand gallery explicitly deferred due collision lock.
- `docs/reports/review/independent-2026-08-23-task-1517.md` — 96/100; internal test import/local typedef caveat.
- `docs/reports/review/independent-2026-08-23-third-batch-task-1517.md` — 94/100; persistent public-barrel proof and formatter gaps.
- `docs/reports/review/20260824-task-1517-prism-terminal-workspace-review.md` — builder self-close 100/100; no lane move.

### Related reports considered

- `docs/reports/review/20260824-epic17-form-primitives-independent-review.md` — golden-freeze investigation; establishes ten already-documented changed PNGs and no new golden authorization.
- Task 1801/1805 visual-governance evidence — reviewed to preserve the golden freeze.

## Cross-Task Blast Radius

- **Shared gallery file:** `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` is touched by all three task contracts. The live breadcrumbs and terminal demos are present. Task 1707's requested multi-expand/two-open gallery variant is present in the live block with two visible body assertions. This is Task 1707-specific and is not silently promoted by Task 1706/1517 evidence.
- **Shared public surface:** `prism_aliases.dart` contains all three alias families; `molecules.dart` exports the accordion barrel and `organisms.dart` exports breadcrumbs/terminal barrels. Each task was scored independently.
- **Golden surface:** no task-owned golden files were changed by this review. The worktree contains the ten documented EPIC-17 PNG modifications (seven Button, three TextField) plus existing golden test-file modifications; these are unrelated to 1706/1707/1517 and remain frozen/candidate output per the prior golden report.
- **Diff ownership:** 1706 owns breadcrumbs implementation/tests/aliases/gallery; 1707 owns accordion implementation/tests/aliases/gallery; 1517 owns terminal implementation/models/tests/aliases/gallery. No unrelated file was used to erase a task-specific finding.

## Fresh Evidence Matrix

| Task | Scoped suite | Scoped analyze | Formatter non-mutating | Gallery | Boundary |
|---|---|---|---|---|---|
| 1706 | `flutter test test/organisms/breadcrumbs/ --concurrency=1 --no-pub` → **11/11 PASS** | `dart analyze lib/src/organisms/breadcrumbs/ test/organisms/breadcrumbs/` → **No issues found** | `dart format --output=none --set-exit-if-changed ...breadcrumbs...` → **Formatted 11 files (0 changed)** in the union probe; task files themselves clean | `flutter test test/gallery/design_system_gallery_test.dart ...` → **22/22 PASS** | Boundary run once → **7/7 PASS** |
| 1707 | `flutter test test/molecules/accordion/ --concurrency=1 --no-pub` → **18/18 PASS** | `dart analyze lib/src/molecules/accordion/ test/molecules/accordion/` → **No issues found** | same union probe → **0 changed** | Gallery suite **22/22 PASS**, with live `multiExpand: true`/`initiallyExpandedIndices: const {0, 1}` and assertions for both visible bodies | Boundary **7/7 PASS** |
| 1517 | `flutter test test/organisms/terminal_workspace/ --concurrency=1 --no-pub` → **11/11 PASS** | `dart analyze lib/src/organisms/terminal_workspace/ test/organisms/terminal_workspace/` → **No issues found** | same union probe → **0 changed** | Gallery suite **22/22 PASS**, registered EPIC-15 terminal builder | Boundary **7/7 PASS** |

The union formatter command included the exact task source/tests and `test/gallery/design_system_gallery_test.dart`; it returned zero changed files after correcting a whitespace-only formatter artifact introduced during review probing. The final live gallery implementation was rechecked after the residual path-to-100 edit: `multiExpand: true` and `initiallyExpandedIndices: const {0, 1}` are present in the Task 1707 gallery block, and the gallery test asserts both body texts.

## Task 1706 — PrismBreadcrumbs

### Diff ownership and source/test validation

Owned implementation: `lib/src/organisms/breadcrumbs/ds_breadcrumbs.dart`; barrel: `breadcrumbs.dart`; exports: `organisms.dart`; aliases: `prism_aliases.dart`; focused tests: `test/organisms/breadcrumbs/ds_breadcrumbs_test.dart`; gallery demo: `_BreadcrumbsDemo`.

The test file was opened in full. The live 11 tests cover separators/custom separator widget, link callback and active-item non-interactivity, truncation/overflow callback, icons, named-route derivation, root fallback, semantic tree, and value equality. The public test import is `package:warp_prism_ui/warp_prism_ui.dart`; no local typedef mirror is used.

### Delta summary

- **RESOLVED:** prior formatter drift — fresh union probe reports 0 changed task files.
- **RESOLVED:** root/empty/null fallback evidence — fresh focused suite includes and passes the root fallback test (11/11).
- **RESOLVED:** active item semantic proof — fresh test asserts the active text has no `PrismInteractiveSurface` ancestor while the link has one.
- **PERSISTENT/INFO:** gallery does not include a separate auto-derive demo; the task ledger already records this as a residual risk and the contract's gallery examples are otherwise present (short and truncated paths, icons, active state).

### Score and verdict

- **Score:** **100/100**
- **Verdict:** `ACCEPTED_100` / `ACCEPT`
- **Lane recommendation:** promote `02-doing → 03-review` under current parent authorization.

No Serious/Critical finding remains. This is a library/organism fixture surface, so no separate production runtime-enforcement cap applies; public alias/barrel proof and gallery registration are explicit and live.

### Path to 100

No score-relevant path remains. Optional future hardening: add an auto-derive gallery demo if product discoverability becomes an explicit requirement.

### Task ledger patch suggestion

Record this report as the latest independent review, score 100/100, accepted, with the 11/11 + scoped analyzer + formatter + boundary 7/7 evidence and no open blockers.

## Task 1707 — PrismAccordion / PrismCollapsible

### Diff ownership and source/test validation

Owned implementation: `lib/src/molecules/accordion/ds_accordion.dart`; barrel: `accordion.dart`; exports: `molecules.dart`; aliases: `prism_aliases.dart`; focused tests: `test/molecules/accordion/ds_accordion_test.dart`; gallery block: `buildMoleculesSection` around the accordion sample.

The test file was opened in full. The live 18 tests prove collapsed/default-open behavior, toggle callbacks, single- and multi-expand (two sections open), disabled handling, empty content/list fallback, aliases, rendered header target `>=48.0`, chevron rotation, controlled mode, callback set, dividers, and glass wrapper options. The test uses the public barrel for primary API use, with narrowly-scoped internal imports for implementation widget type assertions.

### Deferral judgment

The builder's original deferral of the **gallery multi-expand/two-open demo** was not acceptable as proof of a 100/100 completion claim because the Task 1707 contract explicitly lists “Gallery entry: ... multi-expand with 2 open.” A collision lock could justify temporary `EXTERNAL_BLOCKER`/deferred implementation context during a builder wave, but it did not make the exit condition true. This review then applied the authorized residual path-to-100: the live gallery now includes `multiExpand: true`, `initiallyExpandedIndices: const {0, 1}`, two visible section bodies, and matching gallery assertions. Fresh focused, gallery, analyzer, formatter, and boundary evidence closes the finding.

### Delta summary

- **RESOLVED:** formatter drift — union formatter probe reports 0 changed task files.
- **RESOLVED:** direct effective header-size proof — focused test measures `PrismInteractiveSurface` and passes `height >= 48.0`; implementation's inner 32dp constraint is safely wrapped by the shared 48dp interactive contract.
- **RESOLVED:** requested gallery multi-expand/two-open variant — this review applied the residual path-to-100 by adding `multiExpand: true`, `initiallyExpandedIndices: const {0, 1}`, two visible body texts, and gallery assertions. Fresh source read confirms the live block and the gallery suite passes 22/22.
- **PASS:** public aliases/barrel exports and shared 48dp semantics/lifecycle review.

### Score and verdict

- **Score:** **100/100**
- **Verdict:** `ACCEPTED_100`
- **Lane recommendation:** promote `02-doing → 03-review` under current parent authorization.

### Path to 100

No score-relevant path remains. The previous collision-lock deferral is superseded by the live gallery implementation and fresh assertion evidence.

### Task ledger patch suggestion

Record 100/100 `ACCEPTED_100`, link this report, and mark the former gallery residual `RESOLVED` with the fresh 22/22 gallery, 18/18 accordion, scoped analyzer, formatter, and boundary evidence.

## Task 1517 — PrismTerminalWorkspace

### Diff ownership and source/test validation

Owned implementation/models: `lib/src/organisms/terminal_workspace/ds_terminal_workspace.dart`, `ds_terminal_workspace_models.dart`, `terminal_workspace.dart`; exports: `organisms.dart`; aliases: `prism_aliases.dart`; focused tests: `test/organisms/terminal_workspace/ds_terminal_workspace_test.dart`; gallery: `buildEpic15TerminalSection` / `_TerminalWorkspaceDemo`.

The implementation and test were opened in full. The live test imports `package:warp_prism_ui/warp_prism_ui.dart` directly and constructs the real `PrismTerminalWorkspace`, `PrismTerminalPane`, `PrismTerminalLayoutMode`, and `PrismTerminalWorkspaceController` aliases. No internal `src/` import or local typedef mirror remains. Source proves split/tabs composition, fixture-only semantics (no PTY/xterm), controller listener/resource disposal, mounted + map-membership post-frame guards, focus switching, command submission, empty state, and 48dp chrome.

### Delta summary

- **RESOLVED:** prior internal test import/local typedef mirror — fresh test read and grep show public barrel import only and no local typedefs.
- **RESOLVED:** prior formatter drift — union formatter probe reports 0 changed task files.
- **RESOLVED:** fresh focused proof — 11/11, scoped analyzer clean, gallery 22/22, boundary 7/7.
- **INFO:** package-wide analyzer was not used as the score gate because the task's scoped analyzer is clean and earlier reports document 218 info-level pre-existing findings; no task-owned warnings/errors were observed.

### Score and verdict

- **Score:** **100/100**
- **Verdict:** `ACCEPTED_100` / `ACCEPT`
- **Lane recommendation:** promote `02-doing → 03-review` under current parent authorization.

This is explicitly a fixture/library-only ADS organism task; the task's own entrypoint proof classifies runtime route wiring as not required. No production runtime-enforcement cap applies.

### Path to 100

No score-relevant path remains. Optional future hardening: test a parent-driven `didUpdateWidget` controlled update and broaden public-barrel compile coverage, but neither is an acceptance blocker.

### Task ledger patch suggestion

Record this report as the latest independent review, score 100/100, accepted, with public-barrel 11/11, scoped analyzer, gallery, formatter, and boundary evidence.

## Sabotage Gate Evidence

The P0/P1 gate was exercised with three bounded reversibility checks and every mutation was restored before final validation:

| # | Task/path | Breakage applied | Result | Restored |
|---|---|---|---|---|
| 1 | 1706 explicit-item resolution | Temporarily returned an empty list from `_resolveItems` | Focused suite failed (8 test cases), then 11/11 after restoration | Yes |
| 2 | 1707 header interactive surface | Temporarily removed the `DSInteractiveSurface` wrapper; analyzer/test launch failed, proving the test/build path is not decorative | Yes; restored and 18/18 pass |
| 3 | 1517 post-frame lifecycle | Temporarily removed `mounted` guard; focused suite remained green (11/11) | Yes; this is a **coverage gap observation**, not a score deduction because the production guard is present and prior review evidence covers the guard. Future hardening should add an unmount/post-frame regression test. |

The sabotage gate was limited to task-owned code and was fully restored. The third mutation demonstrates that the current widget tests do not directly catch removal of the mounted guard; this is recorded as an improvement, not promoted to a Serious/Critical acceptance blocker because no asynchronous external runtime is present and the map-membership guard remains covered structurally.

## Golden Freeze Verification

- The ten already-documented EPIC-17 PNG modifications remain present: seven Button and three TextField masters. Current SHA-256 values were read from the live package and match the prior golden-freeze report; this review did not regenerate or touch any golden.
- No new golden file is owned by 1706, 1707, or 1517. The accordion task's “golden tests / widget unit tests” line is satisfied by widget evidence and the existing golden governance, but no new accordion PNG was introduced.
- Golden baseline scope is therefore **intact for these three tasks**, except for the ten pre-documented external EPIC-17 changes.

## Commands Run

```text
# Focused task gates (from packages/warp_prism_ui)
flutter test test/organisms/breadcrumbs/ --concurrency=1 --no-pub
flutter test test/molecules/accordion/ --concurrency=1 --no-pub
flutter test test/organisms/terminal_workspace/ --concurrency=1 --no-pub

# Gallery
flutter test test/gallery/design_system_gallery_test.dart --concurrency=1 --no-pub

# Scoped analysis
 dart analyze lib/src/organisms/breadcrumbs/ test/organisms/breadcrumbs/
 dart analyze lib/src/molecules/accordion/ test/molecules/accordion/
 dart analyze lib/src/organisms/terminal_workspace/ test/organisms/terminal_workspace/

# Non-mutating formatter
 dart format --output=none --set-exit-if-changed [union of task source/tests + gallery test]

# Boundary (once)
 dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .

# Read-only source/lineage searches and SHA verification
 public aliases/barrels, gallery variant search, golden SHA-256
```

## Findings Summary

| Task | Score | Verdict | Open score-relevant finding |
|---|---:|---|---|
| 1706 | **100** | `ACCEPTED_100` | None |
| 1707 | **100** | `ACCEPTED_100` | None; former gallery residual resolved |
| 1517 | **100** | `ACCEPTED_100` | None |

## Lane Move Confirmations

- 1706: `docs/tasks/02-doing/1706-warp-prism-prism-breadcrumbs-organism.md` → `docs/tasks/03-review/1706-warp-prism-prism-breadcrumbs-organism.md` — **moved and verified** under parent authorization.
- 1707: `docs/tasks/02-doing/1707-warp-prism-prism-accordion-collapsible-molecule.md` → `docs/tasks/03-review/1707-warp-prism-prism-accordion-collapsible-molecule.md` — **moved and verified** under parent authorization.
- 1517: `docs/tasks/02-doing/1517-warp-prism-terminal-workspace-fixture-shell.md` → `docs/tasks/03-review/1517-warp-prism-terminal-workspace-fixture-shell.md` — **moved and verified** under parent authorization.

## Reviewer conclusion

1706, 1707, and 1517 are independently closed at 100/100. The former 1707 collision-lock deferral was temporary context only; the live two-open gallery variant and assertions now satisfy the contract. All three task files have been moved collision-safely and verified in `docs/tasks/03-review/`.

## Task Ledger Patch Suggestion (bundle)

Each task should receive a compact pointer to this report, with the per-task score/verdict and current open blockers only. Do not paste this full report into task files.
