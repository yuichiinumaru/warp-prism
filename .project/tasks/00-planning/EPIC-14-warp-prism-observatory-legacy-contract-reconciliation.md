# EPIC 14 — Warp-Prism Observatory Legacy Contract Reconciliation

> **Planning Status**: Active Epic
> **Executable?**: No — planning artifact only.
> **Promotion Gate**: Promote tasks after EPIC-12 defines failure taxonomy and EPIC-13 stabilizes
>   the ADS package (since Observatory depends on `warp_prism_ui`).
> **Origin**: Stabilization wave — analysis of 64 Observatory test failures spanning parsers,
>   detail views, history modes, responsive shell, operate inspector, and projection drift.
> **Depends on**: EPIC-03 (data layer), EPIC-12 (gate model), EPIC-13 (ADS stability).

## Goal

Reconcile the vertical contract chain in `apps/observatory/` from corpus/frontmatter through
parsers, projections, view-models, detail views, feature UI, and tests. The goal is not to add
new Observatory features; it is to make the existing Observatory codebase internally consistent
and its test suite green.

## Source Evidence

- 64 failures in `apps/observatory/` spanning:
  - `workspace_task_projection_parser_test.dart` — parser/projection drift
  - `extended_detail_variants_test.dart` — detail mapping stale
  - `skill_task_detail_widgets_test.dart` — UI detail expectations mismatch
  - `history_story_modes_test.dart` — view mode expectations stale
  - `responsive_detail_integration_test.dart` — shell integration drift
  - `operate_task_detail_inspector_test.dart` — detail UI expectations stale
  - Additional failures in providers, repositories, workspace snapshot tests.
- CyberCore did NOT cause these failures: `apps/cybercore` has its own DTOs and fixtures,
  and `apps/observatory` has its own data layer. The failures are internal to Observatory.
- The failure pattern suggests a **vertical chain** breaking:
  `frontmatter/corpus → parser → projection → mapper/view-model → detail view → stale test`.
- ~29 imports in `apps/observatory/` appear to use fragile relative paths that may break
  after Melos migration to `apps/observatory/lib/`.

## Scope

- Failure baseline inventory specific to Observatory (classifying each of the 64 failures
  by chain position: corpus, parser, projection, mapper, view, test stale, compile).
- Corpus/frontmatter contract audit: verify mock workspace markdown files match what parsers
  expect.
- Parser and task projection reconciliation: align frontmatter fields with parser expectations
  and test fixtures.
- View-model and mapper contract reconciliation: verify domain models → presentation models
  mapping is consistent.
- Detail variant and responsive shell reconciliation: verify detail views (skill, task, agent,
  workflow, changelog) match current model shapes.
- History and operate feature flow reconciliation: verify story modes, filters, inspector,
  and task detail views match current data contracts.
- Legacy test retirement or rewrite audit: determine which tests should be kept, corrected,
  rewritten, or archived.
- Observatory package imports cleanup: migrate fragile relative imports to package-style
  imports where beneficial.

## Out of Scope

- New Observatory features or screens.
- Fixing ADS package failures (that is EPIC-13).
- CyberCore changes.
- Mock corpus content changes unless parser audit proves corpus is wrong.

## Candidate Tasks

| Task | Name | Type |
|------|------|------|
| 1401 | Observatory Failure Baseline Inventory | governance |
| 1402 | Corpus and Frontmatter Contract Audit | verification |
| 1403 | Parser and Task Projection Reconciliation | remediation |
| 1404 | View-model and Mapper Contract Reconciliation | remediation |
| 1405 | Detail Variant and Responsive Shell Reconciliation | remediation |
| 1406 | History and Operate Feature Flow Reconciliation | remediation |
| 1407 | Legacy Test Retirement or Rewrite Audit | governance |
| 1408 | Observatory Package Imports Cleanup | housekeeping |

## Dependencies

- 1401 (inventory) should complete first; it informs all other tasks.
- 1402 (corpus audit) should complete before 1403 (parsers) because parser fixes depend on
  knowing whether the corpus or the parser is wrong.
- 1403 (parsers) should complete before 1404 (view-models) and 1405 (detail views) because
  projection/mapper fixes depend on parser output being correct.
- 1406 (history/operate) depends on 1404 and 1405.
- 1407 (test retirement) should be done last, after all reconciliations.
- 1408 (imports cleanup) can run in parallel with other tasks.
- **All tasks in this epic depend on EPIC-13** being at least partially stable, because
  Observatory imports from `warp_prism_ui`.

## Acceptance Criteria for Epic Completion

- `flutter test` in `apps/observatory/` passes with zero failures (or residual failures
  classified and justified).
- All 64 pre-existing Observatory failures are resolved or explicitly classified.
- Parser tests cover representative agents, skills, workflows, tasks, and changelog entries
  with valid and malformed frontmatter.
- Detail views render correctly for all supported asset kinds.
- History story modes and operate inspector work with mock data.
- Fragile relative imports are migrated to package-style imports.
- Stale tests are retired, rewritten, or archived with justification.
