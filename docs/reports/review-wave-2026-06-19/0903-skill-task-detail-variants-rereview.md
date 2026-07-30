# Review Report: Task 0903 — Skill And Task Detail Variants — 2026-06-19

## Review Lineage

- **Current task**: Task 0903 (`0903-warp-prism-skill-task-detail-variants`); live path resolved from filesystem at `docs/tasks/03-review/0903-warp-prism-skill-task-detail-variants.md`.
- **Previous reports read**:
  - `docs/reports/build-gate-review/0903-review.md` — previous score `100/100`; rechecked against live analyzer/test/runtime wiring evidence.
- **Related reports considered**:
  - `docs/reports/build-gate-review/0902-review.md` — descriptor contract dependency.
  - `docs/reports/build-gate-review/0905-review.md` — shell/consumer integration dependency.
- **Review mode**: `re-review` under reviewer profile `reviewers`.

## Score And Verdict

- **Score**: `74/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Axiom Compliance

| Axiom | Status | Evidence |
| --- | --- | --- |
| 1. Analyzer Integrity | FAIL | Scoped asset-detail analysis reports `44 issues`, including unused imports and const/deprecated-member infos in Task 0903 presentation/test files. |
| 2. Lifecycle Safety | PASS | Skill/task variant files create `0` controllers/subscriptions/timers/listeners; `0` disposals required. |
| 3. Dependency Direction | PASS | Presentation imports domain descriptor and UI primitives; domain/application do not import presentation. |
| 4. UI Accessibility | PARTIAL | Variants rely on `DSDetailInspector`; Task 0903 files themselves add `0` explicit `Semantics` widgets and do not prove all close/link affordances meet 48x48 semantics. |
| 5. Proof Reality | PARTIAL | `skill_task_detail_widgets_test.dart` passes `14` tests, but tests manually construct descriptors and do not prove mapper-produced descriptors or production surfaces mount the variants. |
| 6. Release Security | PASS | No secrets, release config, signing, permissions, or debug print paths introduced. |

## Delta Summary

### Resolved Since Previous Review
- `RESOLVED`: Flutter SDK is available. `flutter test test/features/asset_detail/skill_task_detail_widgets_test.dart` runs and passes `14` tests.
- `RESOLVED`: Task 0903 changelog evidence exists at `docs/changelog/20260607-222636-0903-2026-06-07-task-0903-skill-task-detail-variants-repair-bot.md`.

### Persistent Findings
- `PERSISTENT`: Analyzer is not clean in scoped asset-detail files.

### Regressions
- `REGRESSION`: Previous report accepted runtime readiness, but live production code has `0` production `AssetDetailView(` callers outside its own declaration/dispatcher branch.

### New Findings
- `NEW`: Skill/task detail variants are implemented and dispatchable in tests, but unmounted in the production route/shell. The app route uses placeholder `AssetDetailPage`; Map uses `MapInspectorPanel`; History/Operate/Governance do not use `AssetDetailView` for skill/task.
- `NEW`: Widget tests use handcrafted `AssetDetailDescriptor` fixtures instead of descriptors emitted by `asset_detail_mapper.dart`, so they cannot catch mapper/view contract drift.

### Evidence Gaps / External Blockers
- `EVIDENCE_GAP`: No test opens a real skill/task asset from Map or Operate and asserts `SkillDetailView`/`TaskDetailView` is the rendered production detail.
- `EXTERNAL_BLOCKER`: none.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | REGRESSION | CRITICAL | Open | Skill/task variants are dead/unmounted in production; no production route/shell/consumer calls `AssetDetailView` with real descriptors. | 2026-06-19 | `apps/observatory/lib/features/asset_detail/presentation/asset_detail_view.dart:35-50`; grep found `AssetDetailView(` only in declaration/tests/own dispatcher. |
| F2 | EVIDENCE_GAP | MODERATE | Open | Widget tests manually build descriptors, bypassing the shared mapper/controller contract. | 2026-06-19 | `apps/observatory/test/features/asset_detail/skill_task_detail_widgets_test.dart:44-246` |
| F3 | PERSISTENT | MODERATE | Open | Analyzer integrity fails in scoped asset-detail analysis. | 2026-06-19 | command output: `44 issues found` |
| F4 | NEW | LOW | Open | Task 0903 completion evidence claims all validation commands passed, while task body still says regression verification is blocked by Flutter SDK. | 2026-06-19 | `docs/tasks/03-review/0903-warp-prism-skill-task-detail-variants.md:51-54`, `69`, `119` |

## Evidence Reviewed

- **Task file**: `docs/tasks/03-review/0903-warp-prism-skill-task-detail-variants.md`.
- **Previous report**: `docs/reports/build-gate-review/0903-review.md`.
- **Source/test files**:
  - `apps/observatory/lib/features/asset_detail/presentation/skill_detail_view.dart`
  - `apps/observatory/lib/features/asset_detail/presentation/task_detail_view.dart`
  - `apps/observatory/lib/features/asset_detail/presentation/asset_detail_view.dart`
  - `apps/observatory/lib/features/asset_detail/presentation/detail_section_builder.dart`
  - `apps/observatory/test/features/asset_detail/skill_task_detail_widgets_test.dart`
- **Runtime wiring proof**: `AssetDetailView` dispatches skill/task in code, but no production caller mounts it. Therefore runtime wiring for Task 0903 is not proven.
- **Lifecycle count**: `0` controllers/subscriptions/timers/listeners in Task 0903 presentation files; `0` missing disposals.
- **Accessibility count**: Task 0903 presentation files add `0` explicit `Semantics`; interactive close behavior is delegated to `DSDetailInspector` via `onClose`.
- **Commands run**:
  - `HOME=... PUB_CACHE=... dart format --output=none --set-exit-if-changed lib test` — PASS, `142 files (0 changed)`.
  - `HOME=... PUB_CACHE=... flutter analyze` — FAIL, `378 issues found`.
  - `HOME=... PUB_CACHE=... flutter analyze lib/app/router.dart lib/app/pages/asset_detail_page.dart lib/app/asset_selection_controller.dart lib/features/asset_detail test/app/asset_detail_route_test.dart test/features/asset_detail` — FAIL, `44 issues found`.
  - `HOME=... PUB_CACHE=... flutter test test/features/asset_detail/skill_task_detail_widgets_test.dart` — PASS, `14` tests.
  - Combined asset-detail test command — PASS, `112` tests.
- **Commands not run and why**: none relevant to Task 0903.

## Path To 100

1. Mount `AssetDetailView` in the production detail flow used by `/assets/:assetId` and by the shared responsive detail consumer.
2. Add a mapper-to-view integration test: construct a `WorkspaceAsset(kind: AssetKind.skill)` and `WorkspaceAsset(kind: AssetKind.task)`, run `buildAssetDetailDescriptor`, render `AssetDetailView`, and assert the skill/task panels.
3. Add a production surface test that taps a skill/task in Map/Operate and proves the universal skill/task detail variant renders instead of `MapInspectorPanel` or placeholder content.
4. Clean Task 0903 scoped analyzer warnings/info to `0`.
5. Normalize task evidence so validation status no longer contradicts the now-installed SDK.

## Task Ledger Patch Suggestion

```markdown
| 2026-06-19 | reviewers | 74/100 | REJECTED_TO_DOING | `docs/reports/review-wave-2026-06-19/0903-skill-task-detail-variants-rereview.md` |

### Latest Review Notes
- `REGRESSION/CRITICAL`: skill/task variants exist but are unmounted in production; `AssetDetailView` has `0` production callers.
- `EVIDENCE_GAP/MODERATE`: tests manually construct descriptors instead of proving mapper-produced descriptors render.
- `PERSISTENT/MODERATE`: scoped asset-detail analyzer reports `44` issues.
```
