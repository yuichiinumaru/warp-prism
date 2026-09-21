# Drain Analysis 2026-06-20 — Batch 3c UI Returned Components

> Source: `gt-mechanical-investigator` task `ses_11c828dc0ffewwMp7p0uhdU0AL`.
> Scope: `02-doing/1116`, `1117`, `1119`, `1120`.
> Status: PARTIAL-COMPLETE — subagent read all 4 task files and associated initial + 2026-06-18 review reports; 2026-06-19 reports were referenced but not read before step limit.

## Task Matrix

| Task | Priority | Status / Review State | Latest Known Score | Verdict | Key Blockers | Recommended Action |
| --- | --- | --- | ---: | --- | --- | --- |
| `1116` Notification Toast System | P1 | Doing | 82 | REJECTED_TO_DOING | Rejected `1105/1107` prerequisites; `DSToastEntry` lacks `onAction`/`dismissOnAction`; stale-index timer bug. | `fixer_then_review` after prerequisites. |
| `1117` Graph Visualization Refactor | P1 | Doing | 66 | REJECTED_TO_DOING | Rejected `1105/1107` and unapproved `0512`; 18 analyzer issues; `layoutEngine` and `nodeSpacing` ignored; zero Semantics widgets. | `fixer_then_review`, likely after graph/map dependency state resolved. |
| `1119` Health Dashboard Components | P1 | Doing | 76 | REJECTED_TO_DOING | Rejected `1105/1107`; 9 analyzer infos; gallery case commented; `DSStatusGrid` lazy rendering defeated; missing keyboard activation. | `fixer_then_review` after prerequisites. |
| `1120` Drag and Drop Task Board | P1 | Doing | 58 | REJECTED_TO_DOING | Rejected `1105/1107`; 21 analyzer issues; vacuous drag tests; `DSDropTarget` missing `onMove`; no keyboard/semantics path. | `fixer_then_review` after prerequisites. |

## Where / Domains

| Task | Primary Files / Domains |
| --- | --- |
| `1116` | `packages/warp_prism_ui/lib/src/molecules/ds_toast.dart`, `ds_toast_manager.dart`, toast tests; molecules, timers, async lifecycle. |
| `1117` | `packages/warp_prism_ui/lib/src/organisms/graph/`, `ds_graph_canvas.dart`; graph visualization, layout engine, accessibility. |
| `1119` | `ds_sparkline.dart`, `ds_uptime_bar.dart`, `ds_health_card.dart`, `ds_status_grid.dart`; health dashboard atoms/molecules/organisms. |
| `1120` | `ds_draggable_card.dart`, `ds_drop_target.dart`, `ds_lane_board.dart`; drag/drop, lane board, keyboard accessibility. |

## Cross-Cutting Pattern

All four tasks share root blockers: `1105` and `1107` remain rejected. Component promotion gates depend on upstream design-system policy/workspace tooling. Do not send these directly to review before upstreams are revalidated or formally decoupled.

## Collision / Bundle Guidance

- `1116` can be isolated from graph/health/drag code except shared DS token/test infrastructure.
- `1117` may conflict with map/graph tasks such as `0512` and should be serialized with graph-canvas changes.
- `1119` and `1120` are separate component domains but share analyzer/accessibility patterns; may run in parallel after prerequisites if no shared files.
- All four need strict `flutter analyze` including info-level issues and accessibility/touch/keyboard review.
