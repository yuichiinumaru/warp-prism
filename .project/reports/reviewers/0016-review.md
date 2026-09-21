# Wave 0 Review: Task 0016 — DS Organisms and Templates Alignment

**Date**: 2026-06-17
**Reviewer profile**: `reviewers`
**Task file reviewed**: `docs/tasks/03-review/0016-warp-prism-ds-organisms-templates-alignment.md`
**Score**: 62/100 — Debt
**Verdict**: REJECTED → return to `02-doing`

## Findings

- **HIGH — Cross-lane dependency not approved**: Task 0016 declares `Depends on: Task 0012, Task 0015`; live Task 0015 is still in `docs/tasks/02-doing/0015-warp-prism-ds-atoms-molecules-normalization.md` with latest review score `76/100` and `REJECTED_TO_DOING` at lines 152-174. Task 0016 uses atom/molecule surfaces (`DSSearchBar`, `DSFilterChipGroup`, `DSStateSurface`, atoms/tokens) and cannot be proven independent of the rejected primitive layer.
- **HIGH — Analyzer gate is not clean in exact task scope**: `flutter analyze --no-pub` over the exact Where-table organism/template files plus the task tests reports `38 issues found`, including `unused_import` warning at `test/templates/templates_contract_test.dart:5:8`, deprecated `withOpacity` calls, missing const constructors, and `prefer_final_fields` in `master_detail_template.dart:106:8`. This contradicts the task exit condition `flutter analyze passa`.
- **MEDIUM — Completion/review evidence is stale/inflated**: Task evidence claims Flutter SDK was not installed and later previous ledger claims `100/100`; current SDK evidence exists and analyzer fails. The prior report also points to `docs/changelog/2026-06-07-task-0016-ds-organisms-templates-alignment.md`, but live changelog evidence is `docs/changelog/20260607-213805-0016-2026-06-07-task-0016-ds-organisms-templates-alignment-repair-bot.md`.

## Commands Run

From `packages/warp_prism_ui/` with `TMPDIR`, `HOME`, and `PUB_CACHE` constrained inside the repo:

| Command | Result |
| --- | --- |
| `flutter analyze --no-pub lib/src/organisms/organisms.dart lib/src/organisms/ds_shell.dart lib/src/organisms/ds_sidebar.dart lib/src/organisms/ds_topbar.dart lib/src/organisms/ds_graph_canvas.dart lib/src/organisms/ds_lane_board.dart lib/src/organisms/ds_timeline.dart lib/src/organisms/ds_detail_inspector.dart lib/src/organisms/ds_story_panel.dart lib/src/templates/templates.dart lib/src/templates/master_detail_template.dart test/organisms/organisms_layout_test.dart test/templates/templates_contract_test.dart` | FAIL — 38 issues found |
| `dart format --output=none --set-exit-if-changed lib/src/organisms lib/src/templates test/organisms/organisms_layout_test.dart test/templates/templates_contract_test.dart` | PASS — 42 files, 0 changed |
| `flutter test --no-pub test/organisms/organisms_layout_test.dart test/templates/templates_contract_test.dart` | PASS — 20 tests, 0 failed |

## Path to 100

1. Finish and approve Task 0015 first, or narrow Task 0016 evidence to prove independence from the rejected atom/molecule layer.
2. Clear all exact-scope analyzer diagnostics, at minimum the `unused_import` warning in `test/templates/templates_contract_test.dart:5:8` and the 37 organism/template lint/deprecation diagnostics.
3. Update task evidence/report links to live changelog and live SDK command output.
4. Re-run analyzer, format, and targeted organism/template widget tests and record exact output.

## Routing

Task moved back to `docs/tasks/02-doing/0016-warp-prism-ds-organisms-templates-alignment.md` after ledger annotation.
