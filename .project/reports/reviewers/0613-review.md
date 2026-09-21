# Review Report: Task 0613 — Operate Review and Blocker Storytelling — 2026-06-18

## Review Lineage

- **Current task**: Task 0613 (`0613-warp-prism-operate-review-blocker-storytelling`); reviewed at `docs/tasks/03-review/0613-warp-prism-operate-review-blocker-storytelling.md`.
- **Previous reports read**:
  - `docs/reports/build-gate-review/0613-review.md` — 100/100 Approved.
  - `docs/reports/build-gate-review/0612-review.md` — dependency approval now superseded by current Task 0612 rejection.
- **Related reports considered**:
  - `docs/reports/review-wave-3/0612-review.md` — current dependency review, 58/100 rejected.
- **Review mode**: re-review / final-gate.

## Score And Verdict

- **Score**: `76/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED`: The pure storytelling derivation test is runnable and passes in the live environment: 12/12 focused tests passed.

### Persistent Findings

- `PERSISTENT`: Task evidence still says Flutter SDK validation was deferred, but the SDK is available now.

### Regressions

- None identified.

### New Findings

- `NEW`: Task 0613 depends on Task 0612, which is currently rejected for failing inspector tests and missing board/route wiring. The storytelling layer cannot be accepted as integrated while its required Operate inspector/board dependency is below the score gate.
- `NEW`: The user-facing `/operate` route still renders a placeholder, so the story panel is not reachable from the production route.
- `NEW`: The task promised principal rendering coverage, but the only Task 0613 test file is pure derivation coverage; it does not pump `OperateWorkspaceView` or assert that `DSStoryPanel` appears for risky tasks.
- `NEW`: Focused analyzer reports task-owned issues in the Operate surface.

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: No current widget test proves board/inspector rendering of the story panel.
- `EXTERNAL_BLOCKER`: None for focused proof. Flutter is installed.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | NEW | High | Open | Required dependency Task 0612 is rejected. | Current review | `docs/reports/review-wave-3/0612-review.md`; Task 0613 depends on Task 0612 at `docs/tasks/03-review/0613-warp-prism-operate-review-blocker-storytelling.md:9`. |
| F2 | NEW | High | Open | Storytelling surface is not reachable from `/operate`. | Current review | `/operate` route builds placeholder `OperatePage` at `apps/observatory/lib/app/router.dart:64-67`; placeholder text lives at `apps/observatory/lib/app/pages/operate_page.dart:4-24`. |
| F3 | NEW | Medium | Open | Rendering proof is missing; tests cover only pure diagnostics. | Current review | `apps/observatory/test/features/operate/operate_storytelling_test.dart:43-253`; no `pumpWidget` or `DSStoryPanel` assertion. |
| F4 | NEW | Medium | Open | Task-owned analyzer issues remain. | Current review | Focused analyzer on `operate_storytelling.dart`, `operate_workspace_view.dart`, `operate_workspace_view_model.dart`, and test file reports 23 issues including `operate_workspace_view.dart:12` unused import and `operate_workspace_view_model.dart:189`, `:192`, `:194` curly-brace lints. |

## Evidence Reviewed

- Task files: Task 0613 and dependency Task 0612.
- Source/test files: `apps/observatory/lib/features/operate/operate_storytelling.dart`, `operate_workspace_view.dart`, `operate_workspace_view_model.dart`, `operate_task_detail_panel.dart`, `apps/observatory/lib/app/pages/operate_page.dart`, `apps/observatory/lib/app/router.dart`, `apps/observatory/test/features/operate/operate_storytelling_test.dart`, `operate_task_detail_inspector_test.dart`.
- Runtime wiring proof: partial only. `OperateWorkspaceView` conditionally creates `_OperateStoryPanel` from `state.storyDiagnostics` at `operate_workspace_view.dart:77-80`, but the production route does not instantiate `OperateWorkspaceView`.
- Commands run:
  - `HOME="$PWD/tmp/home" PUB_CACHE="$PWD/tmp/pub-cache" TMPDIR="$PWD/tmp" flutter test --no-pub apps/observatory/test/features/operate/operate_storytelling_test.dart` — PASS, 12 tests.
  - `HOME="$PWD/tmp/home" PUB_CACHE="$PWD/tmp/pub-cache" TMPDIR="$PWD/tmp" flutter analyze --no-pub apps/observatory/lib/features/operate/operate_storytelling.dart apps/observatory/lib/features/operate/operate_workspace_view.dart apps/observatory/lib/features/operate/operate_workspace_view_model.dart apps/observatory/test/features/operate/operate_storytelling_test.dart` — 23 issues.
  - Dependency check: `flutter test --no-pub apps/observatory/test/features/operate/operate_task_detail_inspector_test.dart` — FAIL, `+11 -2` (see Task 0612 report).
- Commands not run: full app suite; focused dependency gate already fails.
- Stale-evidence note: the task’s deferred SDK evidence is stale; Flutter is installed.

## Path To 100

1. Resolve Task 0612 or explicitly redesign Task 0613 so it no longer depends on the blocked inspector/selection contract.
2. Wire the real Operate route to the feature surface containing `_OperateStoryPanel`, or document and test the intended production composition path.
3. Add a widget test that pumps the Operate surface with risky tasks and asserts visible `Operational Risk` / `DSStoryPanel` output plus the main derived insights.
4. Fix task-owned analyzer issues and refresh focused analyzer evidence.
5. Update task Completion Evidence and exit checkboxes with current command outputs; remove the stale SDK blocker and add/waive changelog evidence.

## Task Ledger Patch Suggestion

Add a latest-review entry for 2026-06-18 with score 76/100, verdict `REJECTED_TO_DOING`, this report path, current open blockers F1-F4, and prior `docs/reports/build-gate-review/0613-review.md` as lineage.
