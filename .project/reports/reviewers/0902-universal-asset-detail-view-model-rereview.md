# Review Report: Task 0902 — Universal Asset Detail View Model — 2026-06-19

## Review Lineage

- **Current task**: Task 0902 (`0902-warp-prism-universal-asset-detail-view-model`); live path resolved from filesystem at `docs/tasks/03-review/0902-warp-prism-universal-asset-detail-view-model.md`.
- **Previous reports read**:
  - `docs/reports/build-gate-review/0902-review.md` — previous score `100/100`; runtime consumption and SDK-blocker claims re-checked against live filesystem.
- **Related reports considered**:
  - `docs/reports/build-gate-review/0901-review.md` — route contract prerequisite.
  - `docs/reports/build-gate-review/0903-review.md` and `0904-review.md` — presentation variants expected to consume the descriptor.
- **Review mode**: `re-review` under reviewer profile `reviewers`.

## Score And Verdict

- **Score**: `68/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Axiom Compliance

| Axiom | Status | Evidence |
| --- | --- | --- |
| 1. Analyzer Integrity | FAIL | Scoped asset-detail analysis reports `44 issues`; full app analysis reports `378 issues`. |
| 2. Lifecycle Safety | PASS | Task 0902 creates `0` disposable controllers/subscriptions/timers/listeners; `0` missing disposals. |
| 3. Dependency Direction | PARTIAL | Domain/application imports point toward data/domain/presentation correctly, but the application mapper/controller are not consumed by production presentation route/shell code. |
| 4. UI Accessibility | N/A | Task 0902 is domain/application descriptor logic, not direct UI. |
| 5. Proof Reality | FAIL | Completion evidence claims a Riverpod controller, but `asset_detail_controller.dart` is pure functions/classes and contains `0` Riverpod providers/`Notifier`s. Tests pass but do not prove presentation consumption. |
| 6. Release Security | PASS | No secrets, release config, signing, permissions, or debug print paths changed in this scope. |

## Delta Summary

### Resolved Since Previous Review
- `RESOLVED`: Flutter SDK is installed; the old external-blocker narrative is not valid for this review wave.
- `RESOLVED`: `docs/changelog/20260607-222401-0902-2026-06-07-task-0902-universal-asset-detail-view-model-repair-bot.md` exists for Task 0902 changelog evidence.

### Persistent Findings
- `PERSISTENT`: Analyzer is not clean in the asset-detail scope.

### Regressions
- `REGRESSION`: Previous report accepted “controller exposes async descriptor” and “presentation contract” as complete; live code does not provide a Riverpod/async descriptor provider and is not wired into production views.

### New Findings
- `NEW`: Descriptor mapper/controller are test-only in live production code. Searches found `resolveAssetDetail(` and `buildAssetDetailDescriptor(` only in `asset_detail_controller.dart`, `asset_detail_mapper.dart`, and tests; no route/shell/consumer surface calls them.
- `NEW`: Completion evidence claims `asset_detail_controller.dart` is a Riverpod controller, but it imports no `flutter_riverpod` and declares no provider.

### Evidence Gaps / External Blockers
- `EVIDENCE_GAP`: Widget tests for Tasks 0903/0904 hand-build descriptors instead of proving mapper-produced descriptors render correctly.
- `EXTERNAL_BLOCKER`: none.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | REGRESSION | CRITICAL | Open | Mapper/controller are not consumed by production route, shell, or presentation surfaces; descriptor pipeline is effectively unmounted outside tests. | 2026-06-19 | `apps/observatory/lib/features/asset_detail/application/asset_detail_controller.dart:25-39`, `80-140`; grep found no production callers outside application file/tests. |
| F2 | REGRESSION | MODERATE | Open | Claimed Riverpod async controller is not implemented; file has pure functions/classes and `0` providers. | 2026-06-19 | `apps/observatory/lib/features/asset_detail/application/asset_detail_controller.dart:1-140`; task claim at `docs/tasks/03-review/0902-warp-prism-universal-asset-detail-view-model.md:112` |
| F3 | EVIDENCE_GAP | MODERATE | Open | Tests prove mapper outputs in isolation, but presentation tests construct descriptors manually and do not prove mapper-to-view compatibility. | 2026-06-19 | `apps/observatory/test/features/asset_detail/skill_task_detail_widgets_test.dart:44-246`; `apps/observatory/test/features/asset_detail/extended_detail_variants_test.dart:43-363` |
| F4 | PERSISTENT | MODERATE | Open | Analyzer integrity is not clean for asset-detail source/tests. | 2026-06-19 | `flutter analyze ... lib/features/asset_detail ...` reported `44 issues`. |

## Evidence Reviewed

- **Task file**: `docs/tasks/03-review/0902-warp-prism-universal-asset-detail-view-model.md`.
- **Previous report**: `docs/reports/build-gate-review/0902-review.md`.
- **Source/test files**:
  - `apps/observatory/lib/features/asset_detail/domain/asset_detail_descriptor.dart`
  - `apps/observatory/lib/features/asset_detail/application/asset_detail_mapper.dart`
  - `apps/observatory/lib/features/asset_detail/application/asset_detail_controller.dart`
  - `apps/observatory/test/features/asset_detail/asset_detail_descriptor_test.dart`
  - `apps/observatory/test/features/asset_detail/skill_task_detail_widgets_test.dart`
  - `apps/observatory/test/features/asset_detail/extended_detail_variants_test.dart`
- **Runtime wiring proof**: Descriptor mapper has no production caller. Presentation views consume `AssetDetailDescriptor`, but no production surface builds that descriptor through `resolveAssetDetail`/`buildAssetDetailDescriptor`.
- **Lifecycle count**: `0` disposable controllers/subscriptions/timers/listeners in Task 0902 files; `0` missing disposals.
- **Commands run**:
  - `dart --version` — PASS.
  - `flutter --version` — PASS.
  - `HOME=... PUB_CACHE=... dart format --output=none --set-exit-if-changed lib test` — PASS, `142 files (0 changed)`.
  - `HOME=... PUB_CACHE=... flutter analyze` — FAIL, `378 issues found`.
  - `HOME=... PUB_CACHE=... flutter analyze lib/app/router.dart lib/app/pages/asset_detail_page.dart lib/app/asset_selection_controller.dart lib/features/asset_detail test/app/asset_detail_route_test.dart test/features/asset_detail` — FAIL, `44 issues found`.
  - `HOME=... PUB_CACHE=... flutter test test/features/asset_detail/asset_detail_descriptor_test.dart` — PASS, `26` tests.
  - Combined asset-detail test command — PASS, `112` tests.
- **Commands not run and why**: none relevant to Task 0902.

## Path To 100

1. Implement a real Riverpod descriptor provider/controller that accepts selected `assetId`, watches the normalized graph/load-state provider, and emits loading/error/data/fallback descriptor states.
2. Wire production presentation (`/assets/:assetId`, `AssetDetailConsumer`, and any surface detail panel) to the provider/controller rather than hand-built or placeholder details.
3. Add tests that render `AssetDetailView` from descriptors produced by `buildAssetDetailDescriptor` for agent/skill/task/workflow/changelog/secondary kinds.
4. Clean all `44` scoped analyzer issues in asset-detail source/tests.
5. Preserve the Task 0902 changelog file as current evidence and update the task ledger with this report.

## Task Ledger Patch Suggestion

```markdown
| 2026-06-19 | reviewers | 68/100 | REJECTED_TO_DOING | `docs/reports/review-wave-2026-06-19/0902-universal-asset-detail-view-model-rereview.md` |

### Latest Review Notes
- `REGRESSION/CRITICAL`: mapper/controller are not consumed by production route/shell/presentation surfaces.
- `REGRESSION/MODERATE`: claimed Riverpod async controller is not implemented; `asset_detail_controller.dart` contains `0` providers.
- `EVIDENCE_GAP/MODERATE`: widget tests manually construct descriptors instead of proving mapper-produced descriptors render.
- `PERSISTENT/MODERATE`: scoped asset-detail analyzer has `44` issues.
```
