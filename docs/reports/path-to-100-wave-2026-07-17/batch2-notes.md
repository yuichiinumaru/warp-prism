# Path-to-100 Wave — Batch 2 Notes (0410–0810)

**Date**: 2026-07-18  
**Builder**: PATH-TO-100 (parent agentID=builders)  
**Policy**: Apply residuals; live gates; leave tasks in `03-review`; no git/tasklist; no `04-completed` move.

## Return table

| task | residual_fixed | exits | remaining |
| --- | --- | --- | --- |
| **0410** | Production `appRouter` route-table unit test + `WarpPrismApp` landing `/overview`; deep-link `/assets/:id` via production router | analyze app clean; `test/app/` green incl. new production_router tests | none material |
| **0411** | Documented product residual only | shell responsive suite green | Optional wide inspector pane (`showInspector: false`); Material bottom nav for compact (product-owned) |
| **0412** | `overview_provider_path_test` — loading/success/error without forced* flags | overview suite green | none |
| **0413** | Empty corpus → `ShellStateHandler.buildEmpty`; deep-link production router proof | shell + overview + production router green | none material |
| **0512** | MapPageShell injects `workspaceGraphAsyncProvider` edges; `MapWorkspaceState.graphEdges` / `resolvedGraphEdges`; builder-edge regression tests; format panel test | map suite **108**; analyze map clean; FORMAT_EXIT=0 | none |
| **0513** | MapInspectorPanel doc as unit-adapter; page-level selection → AssetDetailView title proof (no MapInspectorPanel) | map selection suite green | optional dual-origin graph-tap widget (controller dual-origin already proven) |
| **0514** | `MapSurfaceState.emptyFamily` + catalog orchestration; Completion Evidence count **108** | map suite **108** | none |
| **0610** | Shared `inferLaneFromPath` (path-wins); format parser; production markdown path uses same rule | operate path-wins tests green; FORMAT_EXIT=0 | none |
| **0611** | Deep bridge via `_taskBody` + `extractBodyFields` (sections/rows/exit); path-wins on board bridge | operate board suite green | prefer_const infos on operate views (INFO only) |
| **0612** | Confirmed production uses universal AssetDetailView (detail wired); panel remains unit adapter | operate detail tests green | none (evolved detail path) |
| **0613** | Blocker derivation counts only unresolved deps; completed+verified/complete deps excluded; regression tests | storytelling suite green | none |
| **0710** | Corpus validators reconfirmed by adjacent history suite; residual was optional INFO only | history/data suites green | optional parser-test INFO nits |
| **0711** | `dart format` history_repository + workspace_providers | FORMAT_EXIT=0 | none |
| **0712** | `_ModeChip` Semantics(button/selected/label) + min 48×48; const loading/empty | history UI suite green | none |
| **0713** | Shares mode-chip fix; const impact empty surface | history UI suite green | none |
| **0810** | prefer_const hygiene on governance widgets; drill-down path decode assertion | governance **104** | none |

## Live gates (this wave)

| Gate | Result |
| --- | --- |
| `flutter analyze lib/app lib/features/{map,history,overview,governance}` | **No issues found** |
| `flutter test test/features/map/` | **+108** |
| `flutter test test/features/operate/` + overview + history (prior batch) | **+255** focused multi-suite |
| `flutter test test/features/governance/` | **+104** |
| `flutter test test/app/ test/features/shell/` | **+67** |
| Residual format dirt files | **FORMAT_EXIT=0** |

## Key code touchpoints

- `lib/data/parsers/workspace_task_projection_parser.dart` — public `inferLaneFromPath` + `extractBodyFields`
- `lib/data/parsers/workspace_markdown_parser.dart` — path-wins + `_taskBody`
- `lib/features/operate/operate_projection_builder.dart` — deep bridge
- `lib/features/operate/operate_storytelling.dart` — unresolved blockers only
- `lib/app/pages/map_page.dart` + `map_workspace_state.dart` — builder edges
- `lib/features/map/widgets/map_state_panel.dart` — `emptyFamily`
- `lib/features/history/presentation/history_page.dart` — mode chip a11y
- `lib/app/pages/overview_page.dart` — empty ShellStateHandler
- New tests: `production_router_test.dart`, `overview_provider_path_test.dart`, `map_graph_builder_edges_test.dart`, `operate_path_wins_lane_test.dart`

## Changelog

`docs/changelog/2026-07-18-path-to-100-batch2-0410-0810.md`
