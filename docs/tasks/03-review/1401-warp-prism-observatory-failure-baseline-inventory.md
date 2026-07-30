# Task 1401: Observatory Failure Baseline Inventory

> **Status**: `[x]` Ready For Review — formal independent accept 2026-07-18 (**100/100**)
> **Review State**: Formal accept **100/100** — promoted to `03-review/` (gt-flutter-code-reviewer)
> **Priority**: 🔴 P0
> **Type**: `governance`
> **Origin**: EPIC-14, stabilization wave, Observatory failures in `apps/observatory/`.
> **Blocks**: 1402, 1403, 1404, 1405, 1406, 1407
> **Depends on**: 1201 (failure taxonomy definitions), 1202 (promotion state model)

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1401` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

Create a detailed inventory of Observatory test failures, classified
by chain position (corpus, parser, projection, mapper, view, test stale,
compile) and taxonomy class. This is the Observatory-specific counterpart
of Task 1201.

> Live 2026-07-09 note: the original “64 runtime failures” framing is
> **historical**. Current baseline is dominated by **compile/load** failures
> from incomplete `DS*` → `Prism*` design-system public API migration.

## Background Context

### What already exists

- Task 1201 creates a monorepo-wide failure inventory. This task dives deeper
  into the Observatory-specific failures.
- Known failing areas (historical names retained): `workspace_task_projection_parser_test`,
  `extended_detail_variants_test`, `skill_task_detail_widgets_test`,
  `history_story_modes_test`, `responsive_detail_integration_test`,
  `operate_task_detail_inspector_test`, plus additional failures in providers,
  repositories, and workspace snapshot tests.

### What is missing or broken

- No Observatory-specific failure inventory with chain position classification.
- No understanding of whether failures are top-down (corpus wrong → parser
  fails) or bottom-up (view stale → test fails).

---

## Test Requirements

- Inventory covers every failing test/suite in `apps/observatory/`.
- Each failure is classified by chain position AND taxonomy class.
- The inventory distinguishes top-down vs bottom-up failures.

---

## Exit Conditions

- [x] Observatory-specific failure inventory created at
  `docs/reports/observatory-failure-baseline.md` with per-failure detail.
- [x] Each failure has file, test/suite name, taxonomy class, chain position, and
  root cause hypothesis. — **live residual: none** (F01 history selection-sync stamped historical/remediated 2026-07-18).
- [x] Local changelog entry added under `docs/changelog/`.
- [x] Completion Evidence is filled before review handoff.
- [x] Live 2026-07-18 re-run evidence matches inventory (0 non-success; +810 formal re-review; **126 INFO**).
- [x] Deterministic JSON / saved-log extraction method documented (not only `[E]` grep).
- [x] Explicit files-read list present in the inventory.
- [x] Responsive-detail “needs re-verification” note reconciled with live evidence.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: Read
  `docs/reports/warp-prism-failure-baseline-inventory.md` (from Task 1201),
  `.agents/rules/promotion-state-model.md`, and
  `apps/observatory/test/` directory structure.
- [x] Run Observatory diagnostics (scoped per-suite JSON + analyzer) and capture all failures.
- [x] For each failure, identify the chain position:
  - **Corpus**: mock workspace files have wrong format/fields.
  - **Parser**: parser expects different frontmatter shape.
  - **Projection**: parser output → domain model mapping is broken.
  - **Mapper**: domain model → presentation model mapping is broken.
  - **View**: presentation widget expects different shape.
  - **Test stale**: code is correct, test expectation is old.
  - **Compile**: file does not compile / suite fails to load.
- [x] Write the Observatory section of the inventory report.
- [x] **Simplicity pass**: hypotheses, not certainties. The reconciliation
  tasks (1403-1406) will verify.
- [x] **Regression verification**: verify inventory matches test output.
- [x] **2026-07-09 path-to-100 refresh**: replace stale 653/589/64 claims with live scoped inventory.

### Where

| File | Purpose |
| --- | --- |
| `docs/reports/observatory-failure-baseline.md` | Refreshed 2026-07-18 — 0 residual / 44 suites / +810 / **126 INFO** |
| `apps/observatory/test/` | Read — suite universe 44; full package + history residual reconfirm |
| `packages/warp_prism_ui/lib/warp_prism_ui.dart` | Read — public barrel hides DS\* (historical compile context) |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Read — Prism\* public aliases |
| `docs/changelog/2026-07-18-task-1401-observatory-failure-baseline-path-to-100.md` | Created — path-to-100 changelog |

### How

1. Run scoped Observatory suite inventory + analyzer.
2. Classify each non-success suite by chain position.
3. Rewrite inventory to current reality; mark 2026-06-09 counts historical.

### Why

The Observatory failures are a vertical chain. Without understanding the chain
position of each failure, builders might fix views when the problem is in
parsers, or fix parsers when the problem is in the corpus. Live 2026-07-09
evidence shows the dominant break is now design-system public API compile debt,
not the historical 64-runtime table.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Classify as "hypothesis" unless you have read both the test and the
> implementation. Do not guess chain position from test name alone.

---

## Validation Commands

```bash
# Preferred current method (scoped, JSON):
flutter analyze apps/observatory
find apps/observatory/test -name '*_test.dart' | sort | while read f; do
  flutter test "$f" --reporter=json >"/tmp/$(basename "$f" .dart).json" || true
done

# Historical full-suite command (heavier; do not treat [E] grep as sole truth):
flutter test apps/observatory/
```

---

## Completion Evidence

### 2026-07-18 Path-to-100 residual close (gt-archivist)

- **Why**: Drain review 2026-07-17 (`86/100` REJECTED_TO_DOING) — inventory still claimed 1 suite / 2 history selection-sync errors while product was green.
- **Files created/modified**:
  - `docs/reports/observatory-failure-baseline.md` (rewritten current baseline = 0 non-success)
  - `docs/changelog/2026-07-18-task-1401-observatory-failure-baseline-path-to-100.md`
  - this task ledger
- **Tests or validation commands (live 2026-07-18, exact)**:

```text
find apps/observatory/test -name '*_test.dart' | wc -l
→ 44

flutter test apps/observatory --concurrency=2 --no-pub
→ +808: All tests passed!  # path-to-100 closeout same day
# formal re-review live re-run 2026-07-18 later same day:
→ +810: All tests passed!

flutter test apps/observatory/test/features/history/history_story_modes_test.dart --no-pub
→ +31: All tests passed!

flutter analyze apps/observatory --no-pub
→ 127 issues found. (0 error / 0 warning / 127 info; exit 0)
  # expert re-stamp same day: 126 INFO (0 error / 0 warning; exit 0)
```

- Saved logs: `tmp/1401-full-suite.out`, `tmp/1401-analyze.out`, `tmp/1401-suite-list.txt`
- F01 (`history_story_modes` selection sync ×2) → **historical/remediated** in inventory §1.4
- Suite universe **44** (4 new vs prior 40): `production_router_test`, `map_graph_builder_edges_test`, `operate_path_wins_lane_test`, `overview_provider_path_test`
- Historical `653/589/64`, mid-wave `12/1042`, fixer `1 residual/816/164` labeled historical only
- **Local changelog entry**: `docs/changelog/2026-07-18-task-1401-observatory-failure-baseline-path-to-100.md` (prior 1401 changelogs retained)
- **Executor**: gt-archivist (builders wave)
- **Completion date**: 2026-07-18
- **Lane**: left in `docs/tasks/02-doing/` per operator instruction (no promotion)
- **No VCS commits**
- **Self-score**: **100/100** inventory honesty (package green accurately recorded)

### Prior 2026-07-09 fixer re-run (SUPERSEDED as current residual)

- Inventory then claimed **40** suites / **39** green / **1** residual (`history_story_modes` 2 errors) / **816** / analyzer **164 INFO**
- Superseded by 2026-07-18 zero-residual re-run above
- Changelogs retained: `2026-07-09-task-1401-observatory-failure-baseline-fixer-rerun.md`, mid-wave refresh, 2026-06-09 original

---

## Path-to-100 Refresh — 2026-06-30

- **Verifier**: builders (gt-evidence-refresher pass)
- **Live file check**: `test -f docs/reports/observatory-failure-baseline.md` → EXISTS (411 lines)
- **Live changelog check**: `test -f docs/changelog/2026-06-09-task-1401-observatory-failure-baseline.md` → EXISTS (32 lines)
- **Report sections**: 30 top-level sections confirmed via `grep -c "## "`
- **Exit conditions**: All 4/4 `[x]` — verified file on disk, per-failure detail present, changelog exists, evidence filled
- **Subtasks**: All 6/6 `[x]`
- **Header/status**: Updated to `Ready for Review` (was `Builder Done`)
- **No stale counts or lane references found** — evidence was current
- **Score**: 95/100 — all substantive deliverables present and verified; 5-point deduction for stale header before this refresh

> **STATUS (historical 2026-06-30)**: Ready for independent review. All exit conditions met. Evidence refreshed 2026-06-30. **Superseded by 2026-07-09 refresh after review rejection.**

---

## Review Ledger — 2026-06-30 — reviewers

- **Verdict**: FAIL / returned to `02-doing/`.
- **Score**: 42/100.
- **Reviewer**: reviewers.
- **Commands run**:
  - `flutter --version` → Flutter 3.44.1 / Dart 3.12.1 available.
  - `dart --version` → Dart 3.12.1 available.
  - `flutter test apps/observatory/` → FAIL: `+472 -14`; compile/load failures dominate current Observatory baseline.
  - `flutter test apps/observatory/ --reporter=json | python3 -c ...` → FAIL summary: 26 error events, 14 non-success `testDone` records, including 13 load/compile failures and 1 runtime widget-test failure.
  - `flutter analyze apps/observatory` → FAIL: 1126 issues, including undefined design-system symbols.
  - `dart format --output=none --set-exit-if-changed docs/reports/observatory-failure-baseline.md docs/tasks/03-review/1401-warp-prism-observatory-failure-baseline-inventory.md docs/changelog/2026-06-09-task-1401-observatory-failure-baseline.md` → invalid check target for Markdown; Dart formatter parsed no files and modified nothing.
- **Axiom compliance**:
  - Analyzer Integrity: FAIL — live analyzer reports 1126 issues.
  - Lifecycle Safety: N/A for this inventory-only task; no lifecycle-bearing production code changed here.
  - Dependency Direction: PARTIAL — no direct violation in the inventory, but current compile failures block package-level proof.
  - UI Accessibility: N/A for this inventory-only task.
  - Proof Reality: FAIL — task claims 653 tests / 589 pass / 64 fail, but live evidence is `+472 -14` with compile/load failures; report also omits current compile-failure files.
  - Release Security: N/A for this inventory-only task.
- **Findings**:
  - CRITICAL — `docs/reports/observatory-failure-baseline.md:3-8` and task evidence claim a 2026-06-09 fresh run with 653 total / 589 pass / 64 fail, but live `flutter test apps/observatory/` now fails at `+472 -14`; the inventory is no longer a truthful baseline.
  - CRITICAL — report verification recipe expects counting `[E]` lines, but current failures include compile/load failures such as `responsive_detail_integration_test.dart:523` (`DSBreakpoints` undefined) and design-system symbol compile errors in asset_detail presentation files; `[E]` counting is not sufficient proof.
  - MODERATE — report says all 14 failing test files and 6 implementation files were read, but the report does not enumerate those 20 paths, so the anti-hallucination evidence is not independently auditable.
  - MODERATE — report records one responsive-detail test as “may actually pass / needs re-verification,” yet exit conditions were marked complete; unresolved re-verification contradicts a complete baseline.
- **Required fixes before re-review**:
  1. Re-run `flutter test apps/observatory/` and update `docs/reports/observatory-failure-baseline.md` to match current live failure counts, including compile/load failures.
  2. Replace `[E]`-line counting with a deterministic JSON or saved-log extraction method that records failing file, test/load name, error class, chain position, taxonomy, and root-cause hypothesis.
  3. Add an explicit “files read” evidence list naming every failing test file and implementation file used for classification.
  4. Reconcile the responsive-detail “needs re-verification” note with live evidence before marking exit conditions complete again.
  5. Refresh task Completion Evidence and changelog after the report is current.
- **Profile entry**: `.agents/profiles/reviewers/review-260630191103-task-1401-observatory-failure-baseline-review.md`.

---

## Path-to-100 Refresh — 2026-07-09 — builders

- **Mode**: honest inventory remediation after package-gate rejection (no product code changes).
- **Why previous evidence failed**: claimed 653/589/64 runtime baseline; live package was compile-dominated.
- **Commands re-run (exact)**:
  1. `flutter analyze apps/observatory` → `1042 issues found.` (921 error / 7 warning / 114 info)
  2. Per-suite `flutter test apps/observatory/test/**/*_test.dart --reporter=json` for all **37** suites
  3. Targeted runtime re-check: `operate_storytelling_test` name filter for PrismStoryPanel risk story → RenderFlex overflow 4.5px
  4. Barrel/alias inspection: `packages/warp_prism_ui/lib/warp_prism_ui.dart`, `.../prism_aliases.dart`
- **Live inventory summary written into report**:
  - 25 fully green suites / 472 green tests
  - 12 non-success suite outcomes (11 compile/load + 1 runtime)
  - Dominant root cause: Observatory still references hidden `DS*` symbols after Prism public API migration
  - Historical parser/history/map runtime clusters largely green now
- **Reviewer required fixes disposition**:
  1. Live suite inventory updated — **done**
  2. JSON extraction method documented — **done**
  3. Files-read list enumerated — **done**
  4. Responsive-detail re-verified as compile/load fail on `DSBreakpoints` — **done**
  5. Task evidence + refresh changelog — **done**
- **Self-score**: **100/100 as honest inventory** (not as package health; package remains red by design of this task scope).
- **No VCS commits performed.**

> **STATUS**: Ready for independent review. Live baseline inventory matches scoped diagnostics captured 2026-07-09.

---

## Post-Promotion Evidence — 2026-07-09

1. `test -f docs/tasks/03-review/1401-warp-prism-observatory-failure-baseline-inventory.md` → `IN_REVIEW: OK`
2. `test ! -f docs/tasks/02-doing/1401-warp-prism-observatory-failure-baseline-inventory.md` → `NOT_IN_DOING: OK`
3. Header status: Ready for independent review (not Doing / Completed / Open).
4. Inventory report current path: `docs/reports/observatory-failure-baseline.md` (rewritten 2026-07-09; historical 653/589/64 superseded).
5. Changelog validation (separate from tasklist):
   - `test -f docs/changelog/2026-07-09-task-1401-observatory-failure-baseline-refresh.md` → EXISTS
   - historical original retained: `docs/changelog/2026-06-09-task-1401-observatory-failure-baseline.md`
6. Generated indexes: not required for this inventory-only docs task; no skill/agent index mutation.
7. Older 02-doing proofs and 2026-06-30 path-to-100 claims are historical/superseded by the 2026-07-09 refresh block above.

Live diagnostic anchors reused for review:

```text
flutter analyze apps/observatory
→ 1042 issues found. (921 error / 7 warning / 114 info)

per-suite flutter test --reporter=json over 37 suites
→ 25 fully green (472 tests); 12 non-success (11 compile/load + 1 runtime)
```

> **SUPERSEDED 2026-07-09 independent re-review**: live is **39/39 green / 736
> passes / 0 fails** and analyzer **164 info-only**. See Review Ledger below.

---

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports. Persistent findings and regression guards are part of
> the acceptance contract.

### Latest Review

- **Date**: 2026-07-09
- **Reviewer profile**: `reviewers`
- **Score**: `38/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Full report**: `docs/reports/review-wave-2026-07-09/task-1401-failure-baseline-independent-rereview.md`
- **Lane outcome**: returned to doing
- **Task reference**: Task 1401 (`1401-warp-prism-observatory-failure-baseline-inventory`)

#### Current Open Blockers

- ~~`PERSISTENT`/`NEW`: Inventory claims 12 non-success / 472 green~~ → **CLOSED** by fixer re-run inventory (39 green / 1 residual runtime suite; 816 green successes)
- ~~`NEW`: Analyzer claim 1042~~ → **CLOSED** (report records 164 info-only)
- ~~`NEW`: Dominant DS* compile root cause~~ → **CLOSED** (labeled obsolete)
- ~~`NEW`: Suite universe 37 vs 39~~ → **CLOSED** (inventory now lists **40** suites including governance_page_shell / overview_shell / workspace_snapshot_page)
- `RESIDUAL` (documented, not inventory staleness): `history_story_modes_test` 2 runtime failures — follow-up outside pure inventory if product wants full green

#### Path-to-100 Summary

- [x] Re-run per-suite JSON + analyze
- [x] Rewrite `docs/reports/observatory-failure-baseline.md` to **this run’s** measured baseline
- [x] Keep historical 64-runtime and mid-wave 12-compile sections labeled historical only
- [x] Include full suite universe (40)
- [x] Refresh Completion Evidence + changelog with exact live counts
- [x] Leave task in `02-doing/` (operator instruction; no auto-promotion)

### Fixer path-to-100 — 2026-07-09

- **Self-score (task-scope inventory honesty)**: **100/100**
- **Not claimed**: full package test green (1 residual suite / 2 tests)
- **Promotion**: not performed; remains `02-doing/`

### Previous Reports

- `2026-07-09` — independent re-review **38/100** — `docs/reports/review-wave-2026-07-09/task-1401-failure-baseline-independent-rereview.md`
  - **Carried forward**: Proof Reality requires live re-run before claims
  - **Resolved since**: inventory rewritten to measured 40-suite baseline
  - **Regression guard**: never re-assert reviewer +736 without a matching re-run
- `2026-07-09` — builder self 100/100 mid-wave (invalidated; claimed 12/1042)
  - **Carried forward**: JSON method, files-read structure
  - **Resolved since**: false 12-compile baseline removed
- `2026-06-30` — `42/100` — task ledger independent rejection
  - **Carried forward**: Proof Reality staleness class
  - **Resolved since**: 653/589/64 and 12-compile not presented as current
  - **Regression guard**: re-run before every promotion; do not trust prior wave counts
- `2026-06-17` — `70/100` — `docs/reports/build-gate-review/1401-review-2026-06-17-independent.md`
- `2026-06-13` — `100/100` — `docs/reports/build-gate-review/1401-review-round3.md` (historical soft approval)
- `2026-06-12` — `78/100` — `docs/reports/build-gate-review/1401-review.md`


### Independent path-to-100 re-review — 2026-07-10 (gt-code-quality-reviewer)

- **Date**: 2026-07-10
- **Reviewer**: `gt-code-quality-reviewer` (reviewers profile)
- **Score**: `100/100`
- **Verdict**: `APPROVED_PROMOTE_TO_REVIEW`
- **Lane outcome**: `docs/tasks/03-review/`
- **Cheap live validation**: history_story_modes Selection sync → still 0 pass / 2 fail (matches inventory residual); analyzer exit 0 INFO-only class; report present
- **Findings**: None for inventory scope. Residual 2 runtime failures correctly documented as follow-up (not claimed green).
- **Wave report**: `docs/reports/review-wave-2026-07-10/path-to-100-mass-rereview.md`
- **No git operations**.

### Independent path-to-100 re-review — 2026-07-10 (extreme rigor, independent)

- **Date**: 2026-07-10
- **Reviewer profile**: `reviewers` (gt-code-quality-reviewer + flutter)
- **Score**: `98/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Full report**: `docs/reports/review-wave-2026-07-10/task-1401-path-to-100-independent-rereview.md`
- **Lane outcome**: remains `docs/tasks/03-review/` (never `04-completed/`)
- **Live anchors**:
  - Suite universe **40/40** matches inventory
  - Residual **1** suite / **2** errors in `history_story_modes_test` reconfirmed (JSON 30 success + 2 error; same signatures)
  - Analyzer class INFO-only EXIT 0; live magnitude **155** vs report **164** (optional currency refresh)
  - Phantom 12-fail / 1042-error class remains **CLOSED**
- **Open (non-blocking)**: optional refresh of analyzer INFO count + green suite pass totals for perfect currency
- **No git / no tasklist rebuild**

### Independent drain review — 2026-07-17 (gt-flutter-code-reviewer + code-quality-harness)
- **Score**: `86/100` (prior draft 98) — **REJECTED_TO_DOING**
- **Verdict**: `REJECTED_TO_DOING`
- **Full report**: `docs/reports/review-wave-2026-07-17/task-1401-drain-review.md`
- **Top finding**: inventory current residual claims 2 history selection-sync errors; live suite **0 residual** (`history_story_modes` +31; full observatory **+778**)
- **Lane**: moved `03-review/` → `02-doing/`
- **Path to 100**: rewrite current-baseline residual to 0 non-success; stamp F01 historical; refresh totals/INFO counts

### 2026-07-18 — path-to-100 residual close (gt-archivist)

- **Disposition of drain residuals**:
  1. Current residual → **0 non-success** (F01 historical)
  2. Suite universe → **44** listed
  3. Full suite → **+808 All tests passed**
  4. Analyzer INFO → **127** (still INFO-only / exit 0)
  5. CE + changelog refreshed with exact live counts
- **Self-score**: **100/100** inventory honesty
- **Promotion**: not performed; remains `02-doing/`

### 2026-07-18 — Expert path-to-100 (gt-flutter-expert / builders)

- **Score before**: `86/100` (drain)
- **Score after fix**: `100/100`
- **Full report**: `docs/reports/review/expert-2026-07-18-task-1401.md`
- **Live re-stamp**: suite universe **44/44** matches disk; residual **0**; analyzer **126 INFO** (0/0; exit 0)
- **Fix**: inventory + CE INFO currency 127→126; expert re-stamp notes
- **Lane**: remains `docs/tasks/02-doing/` (no promote)
- **Open blockers**: none for inventory honesty

### 2026-07-18 — Formal independent re-review (gt-flutter-code-reviewer / builders)

- **Score**: `100/100`
- **Verdict**: `ACCEPT` / `APPROVED_PROMOTE_TO_REVIEW`
- **Full report**: `docs/reports/review/formal-2026-07-18-task-1401.md`
- **Lane outcome**: `docs/tasks/03-review/`
- **Validation**: live re-verify on filesystem + scoped/package gates (see report)
- **Open blockers**: none
- **Path-to-100 this review**: re-stamped full suite +808→**+810**; residual 0; suites 44/44; analyzer 126 INFO
