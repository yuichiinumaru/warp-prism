# Post-Wave A Sanity Audit

> **Date**: 2026-06-29
> **Owner**: builders
> **Scope**: Read-only audit after partial/failed Wave A multi-task builder dispatch.
> **Rule**: No broad Flutter/Dart/Melos/build/test/analyze/coverage commands were run by this audit. Evidence is from task files, reports, and code reads.

---

## Executive Verdict

Wave A should **not** be sent to reviewers yet. The multi-task builder approach produced incomplete or unreliable results across most packs. Some code appears usable, but task evidence, task state, and review readiness are inconsistent.

Use the Wave A output as **draft investigation only**. Continue with smaller specialized builders, preferably **1 task per builder** or **2 tightly-coupled tasks max**, then launch reviewers after each mini-pack reaches coherent evidence.

---

## Pack Summary

| Pack | Tasks | Verdict | Why |
| --- | --- | --- | --- |
| A1 — Observatory parser/corpus | `1401`, `1402`, `1403` | **Partially reusable** | 1401/1402 reports coherent; 1403 code changes present and internally consistent, but task status is contradictory and lacks Review Ledger. |
| A4 — Foundation/router | `0010`–`0013` | **Partially reusable** | Source tree is coherent, but task docs have path drift and possible scope creep/orphan pages. Needs focused review/repair. |
| A5 — Legacy DS baseline | `0014`–`0018` | **Needs split** | All task Where/evidence paths drift from old `lib/design_system` to `packages/warp_prism_ui/lib/src`; 0016 has unchecked subtasks despite Done. |
| A8 — Map | `0510`–`0514` | **Redo with focused fixes** | No credible post-review builder fix detected. Known failures remain: missing graph panel test, graph overflow, production data wiring, false checked boxes. |
| A9 — Operate/DnD | `0610`–`0613`, `1120` | **Redo with focused fixes** | Empty builder result; integration gaps remain: `/operate` placeholder, inspector not wired, missing changelogs, vacuous DnD tests. |
| A10 — History/narrative | `0710`–`0713`, `1050` | **Needs targeted workflows fix** | Clear partial edit: `ImpactPathNode.resolvedWorkflows` exists but is always `const []`; `ChangelogMetadata` lacks workflows. |

---

## Detailed Findings

### A1 — Observatory parser/corpus (`1401`, `1402`, `1403`)

Useful evidence:

- `docs/reports/observatory-failure-baseline.md` is coherent with `1401` and records the historical 64-failure inventory.
- `docs/reports/corpus-frontmatter-audit.md` is coherent with `1402`, including 130 files scanned and 39 missing frontmatter entries.
- `1403` code changes appear present and consistent:
  - `task_contracts.dart` includes a `fromStatus()` switch for bare status strings.
  - `task_projection.dart` strips markdown emphasis before checking completion evidence.
  - `workspace_graph.dart` equality is narrowed to stable identity/canonical fields.
  - `workspace_graph_builder_test.dart` verifies raw skill names are prefixed by inference.

Problems:

- `1403` task header says `[ ] Open` while Review State says `Builder Done — status marker is stale`.
- `1401`, `1402`, `1403` lack Review Ledger sections.
- `corpus-frontmatter-audit.md` contains self-correction prose that reads like a draft.

Next action:

- Builder should handle `1403` alone: fix task status/evidence ledger, verify the three narrow parser/model/service tests, then mark Ready For Review if green.
- `1401` and `1402` may need evidence-polish/review-packet only, not code changes.

Safe validation candidates:

```bash
cd apps/observatory && flutter test --concurrency=1 --no-pub test/data/parsers/workspace_task_projection_parser_test.dart
cd apps/observatory && flutter test --concurrency=1 --no-pub test/data/models/workspace_graph_models_test.dart
cd apps/observatory && flutter test --concurrency=1 --no-pub test/data/services/workspace_graph_builder_test.dart
```

---

### A4 — Foundation/router (`0010`–`0013`)

Useful evidence:

- `apps/observatory/lib/main.dart`, `app/app.dart`, `app/router.dart`, and `app/app_shell.dart` exist and are coherent.
- Router references resolve to real classes.
- README is coherent and current for the Melos monorepo.

Problems:

- Task docs still reference old paths such as `lib/main.dart` instead of `apps/observatory/lib/main.dart`.
- `apps/observatory/lib/app/router.dart` is much richer than the original minimum bootstrap task scope.
- `apps/observatory/lib/app/pages/history_page.dart` and `governance_page.dart` look orphaned because router uses feature-module pages.
- Some task evidence claims Flutter SDK absence, which is stale.

Next action:

- Split into:
  1. `0010`/`0013` docs/evidence reconciliation.
  2. `0011` app shell/router review/fix.
  3. `0012` API normalization evidence refresh.

Safe validation candidates:

```bash
rg 'Ds[A-Z]' apps/observatory/lib packages/warp_prism_ui/lib
# optional narrow, if needed:
cd apps/observatory && flutter test --concurrency=1 --no-pub test/app/app_shell_smoke_test.dart
```

---

### A5 — Legacy DS baseline (`0014`–`0018`)

Useful evidence:

- Actual DS implementation exists under `packages/warp_prism_ui/lib/src`.
- Inventory exists: `docs/reports/warp-prism-ds-inventory.md`.
- Accessibility guide exists: `docs/guides/warp-prism-design-system-accessibility.md`.
- DSGlassPanelVariant exists.

Problems:

- All five task files have path drift: `lib/design_system` / `test/design_system` paths do not exist.
- `0016` has unchecked subtasks while status is Done.
- Changelog filenames in task evidence mismatch real files.
- Gallery section file is large and should not be reopened broadly unless task-specific.

Next action:

- Do not mass-repair all 0014–0018 at once.
- Use `gt-evidence-refresher` or a builder for path/evidence reconciliation first.
- Then reviewers can validate against already-stabilized EPIC-13 UI work.

Safe validation candidates:

```bash
flutter test --concurrency=1 --no-pub packages/warp_prism_ui/test/tokens/
flutter test --concurrency=1 --no-pub packages/warp_prism_ui/test/atoms/
flutter test --concurrency=1 --no-pub packages/warp_prism_ui/test/molecules/
flutter test --concurrency=1 --no-pub packages/warp_prism_ui/test/organisms/
flutter test --concurrency=1 --no-pub packages/warp_prism_ui/test/templates/
flutter test --concurrency=1 --no-pub packages/warp_prism_ui/test/accessibility/
```

---

### A8 — Map (`0510`–`0514`)

Problems still present:

- No evidence of real post-review builder fixes.
- `map_graph_panel_test.dart` is missing despite being required by Task `0512`.
- `map_graph_panel.dart` has graph toolbar overflow at compact width.
- Production `/map` route creates provider state without loading repo-backed assets.
- `map_catalog_panel_test.dart` expects `Clear filters` text that is absent.
- Changelog entries missing for `0510`, `0511`, `0512`.
- Task checkboxes/evidence claim passing gates that review reports contradicted.

Next action:

- Focused builder 1: `0512` graph overflow + missing graph panel test.
- Focused builder 2: `0510` production data load + route/provider wiring.
- Focused builder 3: `0511` catalog no-results/clear filters semantics.
- Then `0513` and `0514` can be refreshed.

Safe validation candidates:

```bash
flutter test --concurrency=1 --no-pub apps/observatory/test/features/map/map_graph_projection_test.dart
flutter test --concurrency=1 --no-pub apps/observatory/test/features/map/map_catalog_panel_test.dart
flutter test --concurrency=1 --no-pub apps/observatory/test/features/map/map_surface_states_test.dart
```

---

### A9 — Operate/DnD (`0610`–`0613`, `1120`)

Problems still present:

- `0610` and `0611` have no review reports.
- `0612` rejected 58/100; `0613` rejected 76/100; `1120` rejected 58/100.
- `/operate` route still renders placeholder `OperatePage` instead of `OperateWorkspaceView`.
- `OperateTaskDetailPanel` exists but is never instantiated by `OperateWorkspaceView`.
- `operate_task_detail_inspector_test.dart` has two known failures.
- Changelog files claimed by `0610`–`0612` and `1120` are missing.
- DnD tests are structurally passing but behaviorally weak/vacuous.

Next action:

- Focused builder 1: `0612` wire inspector into board and fix two inspector tests.
- Focused builder 2: `0610`/`0611` review/evidence refresh after route/board wiring.
- Focused builder 3: `1120` harden drag/drop behavior tests and add missing DSDropTarget `onMove`/insertion-index semantics if required.
- `0613` should wait until `0612` is accepted.

Safe validation candidates:

```bash
flutter test --concurrency=1 --no-pub apps/observatory/test/features/operate/operate_board_surface_test.dart
flutter test --concurrency=1 --no-pub apps/observatory/test/features/operate/operate_task_detail_inspector_test.dart
flutter test --concurrency=1 --no-pub apps/observatory/test/features/operate/operate_storytelling_test.dart
flutter test --concurrency=1 --no-pub packages/warp_prism_ui/test/molecules/ds_drag_drop_test.dart
```

---

### A10 — History/narrative (`0710`–`0713`, `1050`)

Critical issue:

- Tasks require `skills/workflows` history impact chain support, but `ChangelogMetadata` has `skills` only and no `workflows` field.
- `ImpactPathNode.resolvedWorkflows` exists, but `history_controller.dart` always sets it to `const []`.
- No tests assert workflows are parsed or rendered.

Next action:

- Focused builder: add end-to-end workflow support for history impact path:
  1. `ChangelogMetadata.workflows` field.
  2. Parser/repository support for frontmatter workflows if fixtures contain it.
  3. `toImpactPathNodes()` resolution.
  4. UI rendering and tests.
- `1050` should wait until history chain semantics are coherent, unless it is demo-copy-only.

Safe validation candidates:

```bash
flutter test --concurrency=1 --no-pub apps/observatory/test/features/history/history_story_modes_test.dart
flutter test --concurrency=1 --no-pub apps/observatory/test/features/history/history_page_test.dart
```

---

## Recommended Next Builder Wave

Do not repeat 5-task mega-packs. Recommended smaller Wave B0:

1. `1403` only — parser/status/evidence reconciliation.
2. `0512` only — map graph overflow + graph panel test.
3. `0612` only — operate inspector wiring + two failing tests.
4. `0710/0711` together — changelog workflows model/parser support.
5. `0014/0015` together — evidence path reconciliation against current UI package.

This is five parallel specialized builders with low overlap and high unblock value.

After those return coherently, run a review wave for just those fixed tasks.
