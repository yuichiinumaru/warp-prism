# Review Report: Task 0019 — Preset Workspace Snapshot Starter — 2026-06-17

## Review Lineage

- **Current task**: Task 0019 (`0019-warp-prism-preset-workspace-snapshot-starter`); live path initially `docs/tasks/03-review/0019-warp-prism-preset-workspace-snapshot-starter.md`, routed back to `docs/tasks/02-doing/0019-warp-prism-preset-workspace-snapshot-starter.md`.
- **Previous reports read**:
  - `docs/reports/build-gate-review/0019-warp-prism-preset-workspace-snapshot-starter.md` — prior `100/100`, accepted blocked SDK proof.
- **Related reports/tasks considered**:
  - Task 0011 latest ledger: `docs/reports/review-wave-3/0011-review.md` — `68/100`, rejected to doing.
  - Task 0017 current cascade report: `docs/reports/review-wave-cascade/0017-review.md` — rejected to doing.
- **Review mode**: cascade re-review / prerequisite and live-gate check.

## Score And Verdict

- **Score**: `64/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Delta Summary

### Resolved Since Previous Review
- `RESOLVED`: Targeted scanner/enhanced snapshot tests run and pass under live SDK: `flutter test --no-pub test/data/sources/preset_local_workspace_source_test.dart test/features/workspace_snapshot/workspace_snapshot_enhanced_test.dart` reported `34 passed`.

### Persistent Findings
- `PERSISTENT`: Prior report treated unavailable analyzer/test evidence as pass-equivalent.

### Regressions
- `REGRESSION`: Both declared prerequisites are currently rejected to doing.

### New Findings
- `NEW`: Live analyzer proof for the workspace snapshot surface fails with warnings/infos.

### Evidence Gaps / External Blockers
- `EVIDENCE_GAP`: Task file still names pre-monorepo root paths (`lib/...`, `test/...`) while the live source is in `apps/observatory/`.

## Findings

| ID | Class | Severity | Status | Summary | Evidence |
| --- | --- | --- | --- | --- | --- |
| F1 | REGRESSION | High | Open | Rejected prerequisites block approval. | Task 0019 declares `Depends on: Task 0011, Task 0017` at `docs/tasks/03-review/0019-warp-prism-preset-workspace-snapshot-starter.md:9`; Task 0011 is `68/100` / `REJECTED_TO_DOING` at `docs/tasks/02-doing/0011-warp-prism-bootstrap-main-router-shell.md:139-153`; Task 0017 is rejected in `docs/reports/review-wave-cascade/0017-review.md`. |
| F2 | EVIDENCE_GAP | Medium | Open | Analyzer exit condition is not satisfied on live workspace snapshot files. | Command `flutter analyze --no-pub lib/features/workspace_snapshot lib/data/sources/preset_local_workspace_source.dart lib/data/models/workspace_snapshot.dart test/features/workspace_snapshot test/data/sources/preset_local_workspace_source_test.dart` in `apps/observatory/` failed with `42 issues found`, including unused-import warnings such as `apps/observatory/lib/features/workspace_snapshot/widgets/agent_list_panel.dart:10`. |

## Evidence Reviewed

- Task files: Task 0019, Task 0011, Task 0017.
- Source/test files: `apps/observatory/lib/data/sources/workspace_source.dart`, `apps/observatory/lib/data/sources/preset_local_workspace_source.dart`, `apps/observatory/lib/data/models/workspace_snapshot.dart`, `apps/observatory/lib/features/workspace_snapshot/workspace_snapshot_page.dart`, widget panels, provider, scanner tests.
- Runtime wiring proof: `apps/observatory/lib/app/router.dart:117-121` registers `/workspace-snapshot` to `WorkspaceSnapshotPage`; provider uses `String.fromEnvironment('ASW_WORKSPACE_ROOT', defaultValue: '..')` at `apps/observatory/lib/features/workspace_snapshot/workspace_snapshot_provider.dart:16-25`.
- Commands run:
  - Analyzer command above in `apps/observatory/` — failed, `42 issues found`.
  - Targeted snapshot tests above in `apps/observatory/` — passed, `34 passed`.

## Path To 100

1. Resolve and approve Task 0011 and Task 0017 first.
2. Clear workspace snapshot analyzer warnings/infos for the exact live surface.
3. Update task evidence/Where paths to current `apps/observatory/` monorepo locations.
4. Re-run exact analyzer and scanner/page tests; paste fresh command output.

## Task Ledger Patch Suggestion

Add/update Task 0019 Review Ledger with this latest report, `64/100`, `REJECTED_TO_DOING`, blockers F1-F2, and the path-to-100 above.
