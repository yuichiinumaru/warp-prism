# Task 1837: Golden Suite Tagging — Make `--exclude-tags=golden` Effective

> **Lane-derived status**: The containing task directory is the sole source of lifecycle/readiness status. Do not add a task-level `Status` field.
> **Review State**: `Promoted` — see `docs/governance/promotion-state-model.md`
> **Priority**: 🟡 P1
> **Type**: `testing`
> **Origin**: Task 1835 independent review (2026-09-06) F5 + Task 1835 Review 2 (2026-09-07) carried finding — "golden `@Tags` tagging / sibling golden reconciliation — owner: 1832/1833-wave parent". Both reviews routed this to the wave owner as harness follow-up.
> **Blocks**: N/A (unblocks the documented full-suite validation command for every future task)
> **Depends on**: Task 1833 (completed — its systemic accent migration is the known source of expected golden drift)

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task NNNN` plus optional slug.

---

## Milestone Alignment

- **Target milestone**: M01 — Warp Prism v2: L1 Integration-Capable
- **Capability / Gate advanced**: Test-harness honesty — the documented full-suite validation command (`flutter test test/ --no-pub --exclude-tags=golden`) must actually exclude golden suites, so non-golden regressions are visible in full-suite runs instead of being buried under 63 expected frozen-drift mismatches
- **Strategic why**: The Task 1800/1805 golden freeze forbids baseline refresh; the 1833-wave accent migration made every golden containing shared atoms mismatch by design. Until goldens are taggable, the documented gate command can never pass on this branch and real regressions hide in the noise
- **Consequence if absent**: Every future task's full-suite validation reports 63+ pre-existing golden errors; reviewers must manually attribute each one; genuine regressions risk slipping through attribution fatigue

---

## Objective

Make `--exclude-tags=golden` functional by tagging every golden test file in `packages/warp_prism_ui` with `@Tags(['golden'])`, WITHOUT refreshing any golden baseline (Task 1800/1805 freeze holds). After this task, `flutter test test/ --no-pub --exclude-tags=golden` must exit 0, and `flutter test test/ --no-pub` (no exclusion) must still run the goldens with their expected frozen-drift failures.

## Background Context

### What already exists
- Golden suites live under `packages/warp_prism_ui/test/goldens/` (e.g. `ds_data_table_golden_test.dart` — expected drift `99.62%`, `478180px`, recorded in Task 1836 evidence and the Task 1805 freeze ledger).
- Task 1835 review F5 evidence: `grep @Tags` over `test/` = **0 files**; the exclusion flag matches nothing.
- Full-suite state (1835 Review 1 decomposition): 1701 success / 64 error — 63 golden pixel mismatches (systemic 1833-wave accent change) + 1 DSButton focus-ring failure (FIXED in 1833 Round 3 — the chrome/focus oracle is now green).

### What is missing or broken
- Zero `@Tags` annotations: `--exclude-tags=golden` is a no-op; the documented command cannot pass; expected-drift failures and real regressions are indistinguishable in full-suite output.

---

## Test Requirements

- Every golden test file (name pattern `*_golden_test.dart` under `test/goldens/` — 13 files enumerated) carries a library-level `@Tags(['golden'])` annotation.
- **Embedded golden groups** (golden assertions living inside non-golden test files) are ALSO tagged — group-level `tags: 'golden'` (library-level `@Tags` would wrongly tag the whole file's non-golden tests). Execution round 1 discovered exactly one such set: `test/atoms/checkbox/ds_checkbox_test.dart` `group('DSCheckbox golden tests', …)` (4 tests, `:215-277`). *(Scope repair 2026-09-07 by parent: the original Where table enumerated only `test/goldens/**`; the task's Objective — "exclusion must exit 0" — always covered embedded goldens; the builder correctly reported instead of expanding scope.)*
- `flutter test test/ --no-pub --exclude-tags=golden` → exit 0 (goldens skipped; everything else green, including the fixed DSButton focus-ring test).
- `flutter test test/goldens/ --no-pub` (no exclusion) → goldens still run and still exhibit the expected frozen-drift failures (proves the tag excludes without disabling).
- No golden baseline PNG is added, removed, or regenerated. No `--update-goldens` usage.
- Tagging is test-file-only: no production code, no boundary-check changes.

---

## Exit Conditions

- [x] Golden file set enumerated (exact count: 13 files under `test/goldens/`).
- [x] All 13 golden test files tagged with `@Tags(['golden']) library;`; verified by `grep -rn "@Tags" packages/warp_prism_ui/test/ | wc -l` = 13, all located under `test/goldens/`.
- [x] Embedded golden groups outside `test/goldens/` tagged with group-level `tags: 'golden'` (`ds_checkbox_test.dart:217`, `ds_button_test.dart:265`, `ds_text_field_test.dart:330`).
- [x] Full-suite-with-exclusion exits 0 (`flutter test test/ --no-pub --exclude-tags=golden` exits 0 with 1,692 passed tests, 0 failures).
- [x] Goldens still run without exclusion (`flutter test test/goldens/ --no-pub` runs all 59 tests with expected frozen-drift failures; `flutter test test/atoms/checkbox/ds_checkbox_test.dart --no-pub` runs 8 non-golden unit tests passing + 4 goldens failing).
- [x] No golden baselines refreshed (Task 1800/1805 freeze intact; 0 PNG baseline files added/modified/deleted).
- [x] Completion Evidence filled; changelog draft in task.

---

## Details

### Subtasks

- [x] **Read existing code before modifying**: enumerate `test/goldens/**` files; read one representative golden test to learn its current imports/structure; check how `flutter_test` exposes `@Tags` in this repo's Flutter/`package:test` versions (likely `import 'package:test/test.dart' show Tags;` or the `flutter_test` re-export — verify against the actual SDK in the lockfile, do not guess).
- [x] Apply library-level `@Tags(['golden'])` to every golden test file (idiomatic form: annotation directly above `library;` directive or as the first declaration with the correct import).
- [x] Verify exclusion: run the full suite with `--exclude-tags=golden`; record exit code and counts.
- [x] Verify non-exclusion still runs goldens: run `test/goldens/` without the flag; record the expected-drift failure count (should match the ~63 mismatch class; exact number recorded).
- [x] Confirm zero baseline mutations: no files under `test/goldens/` baselines changed (only `.dart` tag lines changed).
- [x] **Regression verification**: run validation commands below; record exact outputs.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/test/goldens/**/*_golden_test.dart` | Modify — add `@Tags(['golden'])` library annotation (13 files, enumerated + tagged in round 1) |
| `packages/warp_prism_ui/test/atoms/checkbox/ds_checkbox_test.dart` | Modify — add group-level `tags: 'golden'` to the `DSCheckbox golden tests` group ONLY (round 2 scope repair; do NOT library-tag this file — it contains non-golden unit tests) |
| `packages/warp_prism_ui/test/` (full tree) | Read/verify — exclusion behavior + regression check |
| `docs/tasks/02-doing/1837-*.md` | Modify — Completion Evidence + ledger |
| `docs/reports/builders/1837-golden-tagging-builder-report.md` | Create — additive builder report |

### How

1. Enumerate + read first (import mechanics verified against the real SDK).
2. Mechanical tag application, golden files only.
3. Both-direction verification (exclusion green / non-exclusion still runs).
4. Evidence packet + additive builder report.

### Why

A validation flag that matches nothing is a broken oracle. The freeze makes the drift legitimate; tagging makes the drift *categorical* instead of ambient noise.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do NOT refresh, regenerate, or `--update-goldens` any baseline. Do NOT tag non-golden files. Do NOT delete or move the `test/goldens/failures/` runtime artifacts. If the exclusion flag fails to behave as expected (e.g. tag not honored by the test runner), STOP and report the exact runner behavior instead of forcing it.

> [!IMPORTANT]
> This task changes zero product behavior. If the full-suite-with-exclusion still fails, the remaining failures are REAL regressions outside the golden class — do not expand this task to fix them; report them to the parent as findings.

---

## Validation Commands

```bash
cd packages/warp_prism_ui && flutter analyze --no-fatal-infos --no-fatal-warnings
cd packages/warp_prism_ui && flutter test test/ --no-pub --exclude-tags=golden
cd packages/warp_prism_ui && flutter test test/goldens/ --no-pub
grep -rn "@Tags" packages/warp_prism_ui/test/ | wc -l
```

If Flutter tooling is unavailable, record the exact tooling failure and do not claim checks passed.

---

## Completion Evidence

### Files Modified
- `packages/warp_prism_ui/test/goldens/ds_badge_golden_test.dart`
- `packages/warp_prism_ui/test/goldens/ds_data_table_golden_test.dart`
- `packages/warp_prism_ui/test/goldens/ds_glass_panel_golden_test.dart`
- `packages/warp_prism_ui/test/goldens/ds_metric_tile_golden_test.dart`
- `packages/warp_prism_ui/test/goldens/ds_shell_golden_test.dart`
- `packages/warp_prism_ui/test/goldens/ds_status_dot_golden_test.dart`
- `packages/warp_prism_ui/test/goldens/ds_text_golden_test.dart`
- `packages/warp_prism_ui/test/goldens/prism_agent_transcript_golden_test.dart`
- `packages/warp_prism_ui/test/goldens/prism_entity_intel_panel_golden_test.dart`
- `packages/warp_prism_ui/test/goldens/prism_map_hud_workspace_golden_test.dart`
- `packages/warp_prism_ui/test/goldens/prism_osint_workbench_golden_test.dart`
- `packages/warp_prism_ui/test/goldens/prism_page_shell_golden_test.dart`
- `packages/warp_prism_ui/test/goldens/prism_provider_health_matrix_golden_test.dart`
- `packages/warp_prism_ui/test/atoms/checkbox/ds_checkbox_test.dart` (round 2 scope repair: group-level `tags: 'golden'`)
- `packages/warp_prism_ui/test/atoms/button/ds_button_test.dart` (round 2 sweep: group-level `tags: 'golden'`)
- `packages/warp_prism_ui/test/atoms/text_field/ds_text_field_test.dart` (round 2 sweep: group-level `tags: 'golden'`)
- `docs/tasks/02-doing/1837-warp-prism-golden-suite-tagging.md`
- `docs/reports/builders/1837-golden-tagging-builder-report.md`

### Tag Census
- Command: `grep -rn "@Tags" packages/warp_prism_ui/test/ | wc -l`
- Result: **13** library-level tags, 100% located under `packages/warp_prism_ui/test/goldens/`.
- Embedded group tags: **3** group-level `tags: 'golden'` across `test/atoms/` (`ds_checkbox_test.dart:217`, `ds_button_test.dart:265`, `ds_text_field_test.dart:330`).
- Total tags in test tree: 16 (13 library-level + 3 group-level).

### Validation Runs & Results
1. **Package Analyzer**:
   `cd packages/warp_prism_ui && flutter analyze --no-fatal-infos --no-fatal-warnings`
   Result: **Exit 0** (0 errors, 0 warnings under gate; 212 pre-existing info baseline, 0 issues in touched files).
2. **Goldens Non-Exclusion Run**:
   `cd packages/warp_prism_ui && flutter test test/goldens/ --no-pub`
   Result: **Exit 1** (60 tests ran: 59 failed with expected frozen-drift pixel mismatches, 1 passed — `DSGlassPanelSimple`, drift-invariant; proves tagging excludes without disabling test execution). *(Count corrected 2026-09-07 per independent Review 1 N1: builder round-1 recorded "59 ran / 0 passed"; reviewer JSON-reporter run measured 60/1/59.)*
3. **Embedded Goldens Non-Exclusion Run**:
   `cd packages/warp_prism_ui && flutter test test/atoms/checkbox/ds_checkbox_test.dart --no-pub`
   Result: **Exit 1** (+8 passed non-golden tests, -4 failed golden tests with expected frozen drift).
4. **Full-Suite With Tag Exclusion (Primary Exit Gate)**:
   `cd packages/warp_prism_ui && flutter test test/ --no-pub --exclude-tags=golden`
   Result: **Exit 0** (1,692 tests passed, 0 failed; all golden tests across `test/goldens/` and atom embedded groups are cleanly excluded).
5. **Boundary Test Harness**:
   `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .`
   Result: **Exit 0** (15/15 PASS, 0 FAIL, 0 violations).
6. **Baseline Freeze Integrity**:
   0 golden baseline `.png` files added, modified, or removed. Task 1800/1805 freeze preserved intact.
7. **Tagged golden surface total (reviewer-verified)**: **74** golden tests (60 in `test/goldens/` incl. 1 drift-invariant `DSGlassPanelSimple` + 14 embedded across the 3 atom groups). *(Corrected per Review 1 N1: builder evidence said 73.)*

### Affected Consumers Classification (AGENTS.md §7.2)
```yaml
affected_consumers: NONE
reason: Test harness metadata addition only. Zero production code modified.
```

## Review Ledger

### Review 1 — 2026-09-07 (APPROVED_PATH100 95/100 — accepted; promoted)

- **Reviewer profile**: `reviewers` (dedicated fleet session `ses_f8745bd18ffephR7OiLVh6S8xJ`)
- **Score**: `95/100` (Elite band; no open Serious/Critical finding)
- **Verdict**: `APPROVED_PATH100_HELD_IN_REVIEW` at review time; parent final verify completed 2026-09-07 → **promoted**
- **Evidence confidence**: high (all seven falsification items verified with reviewer-executed gates; count arithmetic reconciled exactly)
- **Full report**: `docs/reports/reviewers/1837-golden-suite-tagging-review-loop.md` (Entry 1)
- **REGRESSION findings**: NONE
- **Verified**: primary gate `--exclude-tags=golden` exit 0 `+1692` (exact builder-count match); both-direction honesty proven (goldens still run without exclusion — 60 ran: 59 expected-drift failures + 1 drift-invariant `DSGlassPanelSimple` pass; embedded atom files' non-golden tests still run under exclusion — `+8`/`+35`/`+25` with exclusion green); sweep completeness independently recomputed (exactly 3 embedded files / 3 tagged groups / zero un-grouped golden tests); freeze intact (0 of 63 baselines touched; no `--update-goldens`); import mechanics clean (line-scoped `depend_on_referenced_packages` ignore, no shadowing); evidence coherence across both rounds honest (round-1 guardrail finding preserved as history, round 2 closed it); count reconciliation closes exactly (`1703 = 1692 + 11` passing goldens; `63 = 59 + 4`; surface `1766 = 1692 + 74`).
- **N1 (Debt, closed by parent in promotion edit)**: builder evidence recorded the goldens-dir run as "59 ran / 0 passed"; actual **60 ran / 1 passed / 59 failed** (`DSGlassPanelSimple` drift-invariant). One-line corrections applied to Completion Evidence items 2 and 7 (total tagged surface 73 → **74**). Recording fix only; mechanism fully proven either way.
- **Residual signal for Task 1805 freeze ledger** (informational): 1/60 dir-goldens and 10/14 embedded goldens are drift-invariant under the 1833 wave — useful for any future reconciliation scoping. Whether the 63 drifted baselines are ever reconciled remains a separate freeze-owner decision, correctly outside 1837 scope.
- **Lane outcome**: `02-doing → 03-review → 04-completed` (parent final verify; all exit conditions verified green).

## Agent Session Ledger

- 2026-09-07: Round 1 implementation executed by persistent fleet engineer (`gt-builders-engineer-flutter`). Verified `flutter_test` exports `Tags` from `test_api/scaffolding.dart`. Applied `@Tags(['golden']) library;` to all 13 golden test files under `packages/warp_prism_ui/test/goldens/`. Verified `grep -rn "@Tags"` = 13 (all in `test/goldens/`). Verified `flutter test test/goldens/ --no-pub` runs all 59 tests with expected frozen-drift failures. Verified `flutter test test/ --no-pub --exclude-tags=golden` excludes all 13 golden suites (1,702 tests passed; 4 failures in `test/atoms/checkbox/ds_checkbox_test.dart` where golden tests reside in an atom file outside `test/goldens/`, surfaced per guardrail). Confirmed zero baseline modifications. Package analyze passes exit 0 under gate. Task preserved in `02-doing/` per Rule 42.
- 2026-09-07: Round 2 scope repair executed by persistent fleet engineer. Re-read amended task specification. Applied group-level `tags: 'golden'` to `group('DSCheckbox golden tests', ...)` in `packages/warp_prism_ui/test/atoms/checkbox/ds_checkbox_test.dart:217`. Swept entire `test/` tree for any other embedded golden groups: identified `group('DSButton golden tests', ...)` in `ds_button_test.dart:265` and `group('DSTextField golden tests', ...)` in `ds_text_field_test.dart:330`, applying group-level `tags: 'golden'` to both. Confirmed no top-level un-grouped golden tests exist. Verified primary gate: `flutter test test/ --no-pub --exclude-tags=golden` now exits **0** (1,692 tests passed, 0 failures). Verified non-exclusion runs still execute goldens (59 failed in `test/goldens/`; 8 passed + 4 failed in `ds_checkbox_test.dart`). Verified `flutter analyze` exit 0 (0 errors, 0 warnings under gate) and boundary test harness 15/15 PASS. Zero golden baseline PNGs modified. Task preserved in `02-doing/` per Rule 42.

## Local Changelog Draft

- **task**: 1837
- **agent**: builder-engineer
- **project**: warp-prism-ui
- **title**: golden-suite-tagging
- **description**: Tag all 13 golden test files in packages/warp_prism_ui/test/goldens/ with @Tags(['golden']) and all 3 embedded golden groups in test/atoms/ with group-level tags: 'golden' so --exclude-tags=golden becomes fully effective
- **summary**: Added library-level `@Tags(['golden'])` annotation to all 13 golden test suites in `packages/warp_prism_ui/test/goldens/` (`ds_badge_golden_test.dart`, `ds_data_table_golden_test.dart`, `ds_glass_panel_golden_test.dart`, `ds_metric_tile_golden_test.dart`, `ds_shell_golden_test.dart`, `ds_status_dot_golden_test.dart`, `ds_text_golden_test.dart`, `prism_agent_transcript_golden_test.dart`, `prism_entity_intel_panel_golden_test.dart`, `prism_map_hud_workspace_golden_test.dart`, `prism_osint_workbench_golden_test.dart`, `prism_page_shell_golden_test.dart`, `prism_provider_health_matrix_golden_test.dart`). In round 2 scope repair, added group-level `tags: 'golden'` to embedded golden test groups in `test/atoms/checkbox/ds_checkbox_test.dart`, `test/atoms/button/ds_button_test.dart`, and `test/atoms/text_field/ds_text_field_test.dart`. Verified that `flutter test test/ --no-pub --exclude-tags=golden` now cleanly exits 0 (1,692 passed tests, 0 failures), while non-exclusion runs continue to execute goldens with expected frozen drift. Preserved golden freeze intact with zero baseline image changes.
- **verification**: `cd packages/warp_prism_ui && flutter analyze --no-fatal-infos --no-fatal-warnings` (exit 0); `cd packages/warp_prism_ui && flutter test test/ --no-pub --exclude-tags=golden` (exit 0, 1692 passed); `cd packages/warp_prism_ui && flutter test test/goldens/ --no-pub` (exit 1, 59 expected-drift failures); `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .` (15/15 PASS).
