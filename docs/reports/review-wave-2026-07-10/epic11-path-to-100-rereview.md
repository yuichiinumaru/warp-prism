# EPIC-11 path-to-100 re-review — 2026-07-10

> **Reviewer**: gt-code-quality-reviewer  
> **Scope**: tasks 1112, 1113, 1114, 1115, 1116, 1117, 1119, 1120, 1123 still in `02-doing`  
> **Rule**: one cheap scoped `flutter test` per task (claimed green); promote only at S=100; no git  

## Summary table

| Task | Score | Lane |
| --- | ---: | --- |
| 1112 | 100 | `docs/tasks/03-review/` |
| 1113 | 100 | `docs/tasks/03-review/` |
| 1114 | 100 | `docs/tasks/03-review/` |
| 1115 | 100 | `docs/tasks/03-review/` |
| 1116 | 100 | `docs/tasks/03-review/` |
| 1117 | 100 | `docs/tasks/03-review/` |
| 1119 | 100 | `docs/tasks/03-review/` |
| 1120 | 100 | `docs/tasks/03-review/` |
| 1123 | 100 | `docs/tasks/03-review/` |

## Promoted (S=100 → 03-review)

1112, 1113, 1114, 1115, 1116, 1117, 1119, 1120, 1123

## Held in 02-doing (S<100)

*(none)*

## Method

1. Read task path-to-100 residual blockers from prior independent rejects (2026-07-09 wave).
2. Spot-check live sources for blocker closure (a11y targets, timer id, layoutEngine, DnD onMove, honest virtual SLA, etc.).
3. Re-run **one** cheap scoped Flutter suite claimed green under `packages/warp_prism_ui`.
4. Score 100 only when live suite EXIT 0 **and** prior top blockers closed.
5. On S=100: append Review Ledger on task file, `mv` to `docs/tasks/03-review/`.

## Live validation anchors

| Task | Command | Result |
| --- | --- | --- |
| 1112 | `flutter test --concurrency=1 --no-pub test/organisms/data_table/` | **+42** EXIT 0 |
| 1113 | `flutter test --concurrency=1 --no-pub test/organisms/command_palette_test.dart` | **+44** EXIT 0 |
| 1114 | `flutter test --concurrency=1 --no-pub test/log_viewer_test.dart` | **+44** EXIT 0 |
| 1115 | `flutter test --concurrency=1 --no-pub test/molecules/ds_error_boundary_test.dart` | **+18** EXIT 0 |
| 1116 | `flutter test --concurrency=1 --no-pub test/molecules/ds_toast_test.dart` | **+47** EXIT 0 |
| 1117 | `flutter test --concurrency=1 --no-pub test/organisms/graph/` | **+51** EXIT 0 |
| 1119 | `flutter test --concurrency=1 --no-pub test/health_dashboard_test.dart` | **+44** EXIT 0 |
| 1120 | `flutter test --concurrency=1 --no-pub test/molecules/ds_drag_drop_test.dart` | **+24** EXIT 0 |
| 1123 | `flutter test --concurrency=1 --no-pub test/organisms/virtual_list_test.dart` | **+20** EXIT 0 |

Logs: `tmp/path-to-100-epic11-rereview/{task}.txt`

## Blocker closure (summary)

| Task | Prior | Closed top residual |
| ---: | ---: | --- |
| 1112 | 84 | 48×48 interactive a11y + filter toolbar composition |
| 1113 | 83 | Shortcut/mounted guard + chip/item semantics |
| 1114 | 82 | Absolute timestamps + real auto-scroll + a11y + 10K smoke |
| 1115 | 72 | Stable onError stack restore + real throw/retry/dispose tests |
| 1116 | 84 | Timer by entryId + entry onAction/dismissOnAction + hover id-safety |
| 1117 | 88 | layoutEngine injection + nodeSpacing forward |
| 1119 | 86 | Gallery StatusGrid live + embedInScrollView lazy contract |
| 1120 | 68 | Non-vacuous DnD + DragTarget.onMove insertion + onReorder/onMove |
| 1123 | 88 | Honest virtualization SLA; no fake 16ms/60fps harness claims |

## Policy notes

- Never moved to `04-completed/` from this pass.
- Package-wide melos residual is EXTERNAL to task scope when scoped suite is green.
- No git / jj operations performed.
