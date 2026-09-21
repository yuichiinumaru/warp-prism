# Review Report: Task 0904 — Agent Workflow Changelog Detail Variants — 2026-06-19

## Review Lineage

- **Current task**: Task 0904 (`0904-warp-prism-agent-workflow-changelog-detail-variants`); live path resolved from filesystem at `docs/tasks/03-review/0904-warp-prism-agent-workflow-changelog-detail-variants.md`.
- **Previous reports read**:
  - `docs/reports/build-gate-review/0904-review.md` — previous score `100/100`; rechecked against live runtime wiring, analyzer, and test evidence.
- **Related reports considered**:
  - `docs/reports/build-gate-review/0902-review.md` — descriptor/mapper dependency.
  - `docs/reports/build-gate-review/0903-review.md` — dispatcher precedent.
  - `docs/reports/build-gate-review/0905-review.md` — shell integration dependency.
- **Review mode**: `re-review` under reviewer profile `reviewers`.

## Score And Verdict

- **Score**: `72/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Axiom Compliance

| Axiom | Status | Evidence |
| --- | --- | --- |
| 1. Analyzer Integrity | FAIL | Scoped asset-detail analysis reports `44 issues`; full app analysis reports `378 issues`. |
| 2. Lifecycle Safety | PASS | Agent/workflow/changelog/generic variant files create `0` controllers/subscriptions/timers/listeners; `0` missing disposals. |
| 3. Dependency Direction | PASS | Presentation variants import domain descriptor and UI primitives only; no reverse imports into domain/data. |
| 4. UI Accessibility | PARTIAL | Generic fallback has visible partial-support banner, but Task 0904 variant files add `0` explicit `Semantics`; link/close semantics are delegated and not proven in these tests. |
| 5. Proof Reality | PARTIAL | `extended_detail_variants_test.dart` passes `27` tests, but all main variant descriptors are handcrafted fixtures; production runtime does not mount `AssetDetailView`. |
| 6. Release Security | PASS | No secrets, release config, signing, permissions, or debug print paths introduced. |

## Delta Summary

### Resolved Since Previous Review
- `RESOLVED`: Flutter SDK is available. `flutter test test/features/asset_detail/extended_detail_variants_test.dart` passes `27` tests.
- `RESOLVED`: Task 0904 changelog evidence exists at `docs/changelog/20260607-222646-0904-2026-06-07-task-0904-agent-workflow-changelog-detail-variants-repair-bot.md`.

### Persistent Findings
- `PERSISTENT`: Analyzer is not clean in scoped asset-detail files.

### Regressions
- `REGRESSION`: Previous report approved “dispatcher extended for all 9 asset kinds” as if runtime-ready. Dispatcher code exists, but no production route/shell/consumer invokes it.

### New Findings
- `NEW`: Agent/workflow/changelog/generic variants are dead/unmounted in production for the same reason as Task 0903: the router renders placeholder `AssetDetailPage`, Map renders `MapInspectorPanel`, and History renders local `DSDetailInspector` instead of `ChangelogDetailView`.
- `NEW`: History has a separate changelog detail implementation (`history_page.dart:296-357`) that duplicates universal changelog detail concerns and bypasses `ChangelogDetailView`.

### Evidence Gaps / External Blockers
- `EVIDENCE_GAP`: No test proves a real agent/workflow/changelog asset from the normalized graph goes through mapper -> `AssetDetailView` -> correct variant in a production consumer.
- `EXTERNAL_BLOCKER`: none.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | REGRESSION | CRITICAL | Open | Agent/workflow/changelog/generic variants are not mounted in production; `AssetDetailView` has no production callers. | 2026-06-19 | `apps/observatory/lib/features/asset_detail/presentation/asset_detail_view.dart:40-50`; grep result shows no production `AssetDetailView(` caller. |
| F2 | NEW | MODERATE | Open | History uses widget-local changelog detail instead of universal changelog variant, duplicating section assembly contrary to EPIC 09 intent. | 2026-06-19 | `apps/observatory/lib/features/history/presentation/history_page.dart:264-275`, `296-357` |
| F3 | EVIDENCE_GAP | MODERATE | Open | Extended variant tests manually construct descriptors instead of exercising `asset_detail_mapper.dart`. | 2026-06-19 | `apps/observatory/test/features/asset_detail/extended_detail_variants_test.dart:43-363` |
| F4 | PERSISTENT | MODERATE | Open | Scoped asset-detail analyzer reports `44` issues. | 2026-06-19 | analyzer command output |
| F5 | NEW | LOW | Open | Task body exit conditions still list widget tests/analyze/changelog unchecked/blocking despite completion evidence claiming them. | 2026-06-19 | `docs/tasks/03-review/0904-warp-prism-agent-workflow-changelog-detail-variants.md:52-56`, `119-123` |

## Evidence Reviewed

- **Task file**: `docs/tasks/03-review/0904-warp-prism-agent-workflow-changelog-detail-variants.md`.
- **Previous report**: `docs/reports/build-gate-review/0904-review.md`.
- **Source/test files**:
  - `apps/observatory/lib/features/asset_detail/presentation/agent_detail_view.dart`
  - `apps/observatory/lib/features/asset_detail/presentation/workflow_detail_view.dart`
  - `apps/observatory/lib/features/asset_detail/presentation/changelog_detail_view.dart`
  - `apps/observatory/lib/features/asset_detail/presentation/generic_asset_detail_view.dart`
  - `apps/observatory/lib/features/asset_detail/presentation/asset_detail_view.dart`
  - `apps/observatory/lib/features/history/presentation/history_page.dart`
  - `apps/observatory/test/features/asset_detail/extended_detail_variants_test.dart`
- **Runtime wiring proof**: Dispatcher supports all 9 `AssetKind` values in `asset_detail_view.dart:35-50`, but no production surface invokes the dispatcher; History uses a separate detail builder.
- **Lifecycle count**: `0` controllers/subscriptions/timers/listeners in Task 0904 variant files; `0` missing disposals.
- **Accessibility count**: Task 0904 variant files add `0` explicit `Semantics`; generic fallback banner is visible text, not an interactive control.
- **Commands run**:
  - `HOME=... PUB_CACHE=... dart format --output=none --set-exit-if-changed lib test` — PASS, `142 files (0 changed)`.
  - `HOME=... PUB_CACHE=... flutter analyze` — FAIL, `378 issues found`.
  - `HOME=... PUB_CACHE=... flutter analyze lib/app/router.dart lib/app/pages/asset_detail_page.dart lib/app/asset_selection_controller.dart lib/features/asset_detail test/app/asset_detail_route_test.dart test/features/asset_detail` — FAIL, `44 issues found`.
  - `HOME=... PUB_CACHE=... flutter test test/features/asset_detail/extended_detail_variants_test.dart` — PASS, `27` tests.
  - Combined asset-detail test command — PASS, `112` tests.
- **Commands not run and why**: none relevant to Task 0904.

## Path To 100

1. Mount `AssetDetailView` in the real route/shell detail flow so agent/workflow/changelog/secondary kinds dispatch through the universal variants.
2. Replace `HistoryWorkspacePage._buildDetailPanel` with the universal changelog descriptor + `AssetDetailView` path, or explicitly wrap it through the shared `AssetDetailConsumer` and descriptor provider.
3. Add mapper-to-view tests for agent, workflow, changelog, and secondary kinds using `buildAssetDetailDescriptor` output rather than handwritten descriptor fixtures.
4. Add a production integration test proving `/assets/agent:*`, `/assets/workflow:*`, `/assets/changelog:*`, `/assets/script:*` render the correct variant/fallback.
5. Clean scoped asset-detail analyzer issues to `0` warnings/info and update the task ledger.

## Task Ledger Patch Suggestion

```markdown
| 2026-06-19 | reviewers | 72/100 | REJECTED_TO_DOING | `docs/reports/review-wave-2026-06-19/0904-agent-workflow-changelog-detail-variants-rereview.md` |

### Latest Review Notes
- `REGRESSION/CRITICAL`: agent/workflow/changelog/generic variants are implemented but unmounted in production.
- `NEW/MODERATE`: History still uses a widget-local changelog detail builder instead of `ChangelogDetailView`.
- `EVIDENCE_GAP/MODERATE`: tests use handcrafted descriptors and do not prove mapper-to-variant compatibility.
- `PERSISTENT/MODERATE`: scoped asset-detail analyzer reports `44` issues.
```
