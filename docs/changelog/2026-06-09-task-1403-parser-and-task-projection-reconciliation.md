# Task 1403: Parser and Task Projection Reconciliation

## Why
Task 1401 identified 8 parser test failures and 3 model/graph test failures (11 total) in the data layer. Task 1402 confirmed the root cause: `TaskLaneParsing.fromStatus()` was a pass-through to `fromDirectoryPrefix()`, so bare status strings like `"planning"` didn't match `"00-planning"` and all tasks defaulted to `TaskLane.open`.

## Changed
- Fixed `TaskLaneParsing.fromStatus()` in `task_contracts.dart` to handle bare status strings (`planning`, `open`, `doing`, `review`, `completed`) before falling back to directory-prefix parsing
- Fixed `TaskProjection.hasCompletionEvidence` in `task_projection.dart` to strip markdown emphasis markers (`*`) before checking for "not yet" placeholder text
- Fixed `WorkspaceAsset.==` in `workspace_graph.dart` to match the documented contract (equality based on id, kind, name, path, canonicality only — not description, tags, triggers)
- Fixed test data in `workspace_graph_builder_test.dart`: `inferWorkflowDependencies` test was passing already-prefixed `skill:compile` values (should be raw `compile`); `groups assets by kind` assertion was checking wrong counts (1 skill/1 task when sample has 2 skills/2 tasks)

## Evidence
- `flutter test test/data/parsers/workspace_task_projection_parser_test.dart` → 24/24 PASS
- `flutter test test/data/models/workspace_graph_models_test.dart` → 27/27 PASS
- `flutter test test/data/services/workspace_graph_builder_test.dart` → 27/27 PASS
- All 78 data-layer tests pass with zero failures
- `dart analyze` → 367 info-level issues (same as baseline, no new warnings)
- Fixes 12 of 64 pre-existing test failures (18.75% reduction)
