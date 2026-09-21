# Review Report: Task 0905 — Responsive Detail Shell Integration — 2026-06-19

## Review Lineage

- **Current task**: Task 0905 (`0905-warp-prism-responsive-detail-shell-integration`); live path resolved from filesystem at `docs/tasks/03-review/0905-warp-prism-responsive-detail-shell-integration.md`.
- **Previous reports read**:
  - `docs/reports/build-gate-review/0905-review.md` — previous score `100/100`; rechecked against live router/shell/map/history/operate/governance wiring and tests.
- **Related reports considered**:
  - `docs/reports/build-gate-review/0901-review.md` through `0904-review.md` — route, descriptor, and variants must be integrated by this task.
  - `docs/reports/review-wave-2026-06-19/0901-asset-detail-route-contract-rereview.md` through `0904-agent-workflow-changelog-detail-variants-rereview.md` — current upstream defects.
- **Review mode**: `re-review` under reviewer profile `reviewers`.

## Score And Verdict

- **Score**: `54/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Axiom Compliance

| Axiom | Status | Evidence |
| --- | --- | --- |
| 1. Analyzer Integrity | FAIL | Scoped asset-detail analysis reports `44 issues`; full app analysis reports `378 issues`. |
| 2. Lifecycle Safety | PASS | `ResponsiveDetailShell` creates `1` `AnimationController` and disposes `1`; `0` missing disposals. |
| 3. Dependency Direction | PARTIAL | Shell presentation imports are layer-appropriate, but consumer surfaces bypass the universal descriptor/variant stack. |
| 4. UI Accessibility | PARTIAL | Narrow close button has `1` explicit `Semantics`; medium scrim is a `GestureDetector` with `0` semantic label/button role; touch-target/focus behavior is only partially proven. |
| 5. Proof Reality | FAIL | Responsive tests pass `25` tests for shell mechanics, but the task requires Map, Operate, History, and Governance consumer integration; live code only partially wires Map/History and bypasses universal variants. |
| 6. Release Security | PASS | No secrets, release config, signing, permissions, or debug print paths introduced. |

## Delta Summary

### Resolved Since Previous Review
- `RESOLVED`: Flutter SDK is available. `flutter test test/features/asset_detail/responsive_detail_integration_test.dart` passes `25` tests.
- `RESOLVED`: `ResponsiveDetailShell` lifecycle is safe: `1` `AnimationController` created and disposed.
- `RESOLVED`: Task 0905 changelog evidence exists at `docs/changelog/20260607-222528-0000-2026-06-07-task-0905-responsive-detail-shell-integration-repair-bot.md`.

### Persistent Findings
- `PERSISTENT`: Analyzer is not clean in scoped asset-detail files.

### Regressions
- `REGRESSION`: Previous report accepted “consumer screens use shared detail contract” as complete; live code does not integrate Operate or Governance, and Map/History do not use the universal descriptor/variant route.

### New Findings
- `NEW`: `AssetDetailConsumer` is used only by Map (`apps/observatory/lib/features/map/map_workspace_page.dart:125-140`). Operate and Governance have `0` `AssetDetailConsumer`/`ResponsiveDetailShell` usages.
- `NEW`: History uses `ResponsiveDetailShell` but passes a local `_buildDetailPanel` (`history_page.dart:264-275`, `296-357`) instead of `AssetDetailView`/universal descriptor.
- `NEW`: Map uses `AssetDetailConsumer`, but the detail builder returns `MapInspectorPanel`, not `AssetDetailView` or descriptor-based universal variants (`map_workspace_page.dart:134-138`).
- `NEW`: Canonical `/assets/:assetId` route is outside the responsive shell and renders placeholder `AssetDetailPage`, so narrow/medium/wide route behavior is not actually proven for deep links.

### Evidence Gaps / External Blockers
- `EVIDENCE_GAP`: No tests prove route-synchronized open/close/back behavior in the production router across wide/medium/narrow widths.
- `EXTERNAL_BLOCKER`: none.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | REGRESSION | CRITICAL | Open | Required consumer surfaces are not integrated: Operate and Governance have `0` shared responsive detail usages; Map/History are partial and bypass universal variants. | 2026-06-19 | `apps/observatory/lib/features/map/map_workspace_page.dart:125-140`; `apps/observatory/lib/features/history/presentation/history_page.dart:264-275`; grep found no Operate/Governance usages. |
| F2 | REGRESSION | CRITICAL | Open | Shared responsive shell does not render universal `AssetDetailView`; Map renders `MapInspectorPanel`, History renders local `DSDetailInspector`. | 2026-06-19 | `apps/observatory/lib/features/map/map_workspace_page.dart:134-138`; `apps/observatory/lib/features/history/presentation/history_page.dart:296-357` |
| F3 | NEW | CRITICAL | Open | Deep-linked `/assets/:assetId` route is not integrated with responsive detail shell and renders placeholder page. | 2026-06-19 | `apps/observatory/lib/app/router.dart:97-102`; `apps/observatory/lib/app/pages/asset_detail_page.dart:83-103` |
| F4 | NEW | MODERATE | Open | Medium overlay scrim is an unlabeled `GestureDetector`; only narrow back button has explicit semantics. | 2026-06-19 | `apps/observatory/lib/features/asset_detail/presentation/responsive_detail_shell.dart:138-151`, `190-199` |
| F5 | PERSISTENT | MODERATE | Open | Scoped analyzer integrity fails with `44` issues. | 2026-06-19 | analyzer command output |
| F6 | EVIDENCE_GAP | MODERATE | Open | Responsive tests validate generic placeholders but not production route/controller/descriptor synchronization. | 2026-06-19 | `apps/observatory/test/features/asset_detail/responsive_detail_integration_test.dart:43-65`, `67-677` |

## Evidence Reviewed

- **Task file**: `docs/tasks/03-review/0905-warp-prism-responsive-detail-shell-integration.md`.
- **Previous report**: `docs/reports/build-gate-review/0905-review.md`.
- **Source/test files**:
  - `apps/observatory/lib/features/asset_detail/presentation/responsive_detail_shell.dart`
  - `apps/observatory/lib/features/asset_detail/presentation/asset_detail_consumer.dart`
  - `apps/observatory/lib/features/asset_detail/presentation/asset_detail_view.dart`
  - `apps/observatory/lib/features/map/map_workspace_page.dart`
  - `apps/observatory/lib/features/history/presentation/history_page.dart`
  - `apps/observatory/lib/features/operate/operate_workspace_view.dart`
  - `apps/observatory/lib/features/governance/presentation/governance_overview_page.dart`
  - `apps/observatory/lib/app/router.dart`
  - `apps/observatory/lib/app/pages/asset_detail_page.dart`
  - `packages/warp_prism_ui/lib/src/templates/master_detail_template.dart`
  - `packages/warp_prism_ui/lib/src/organisms/ds_shell.dart`
  - `apps/observatory/test/features/asset_detail/responsive_detail_integration_test.dart`
- **Runtime wiring proof**:
  - `ResponsiveDetailShell` exists and passes shell mechanics tests.
  - `AssetDetailConsumer` is consumed by Map only.
  - History uses `ResponsiveDetailShell` but not universal descriptor/variant detail.
  - Operate and Governance do not use shared responsive asset detail.
  - `/assets/:assetId` route bypasses responsive shell and descriptor/variant views.
- **Lifecycle count**: `1` `AnimationController` created in `responsive_detail_shell.dart:65-68`; `1` disposed at `responsive_detail_shell.dart:93-95`; `0` missing disposals.
- **Accessibility count**: `2` interactive controls in `ResponsiveDetailShell` (`1` medium scrim `GestureDetector`, `1` narrow `IconButton`); `1` explicit `Semantics` wrapper; `1` unlabeled scrim.
- **Commands run**:
  - `HOME=... PUB_CACHE=... dart format --output=none --set-exit-if-changed lib test` — PASS, `142 files (0 changed)`.
  - `HOME=... PUB_CACHE=... flutter analyze` — FAIL, `378 issues found`.
  - `HOME=... PUB_CACHE=... flutter analyze lib/app/router.dart lib/app/pages/asset_detail_page.dart lib/app/asset_selection_controller.dart lib/features/asset_detail test/app/asset_detail_route_test.dart test/features/asset_detail` — FAIL, `44 issues found`.
  - `HOME=... PUB_CACHE=... flutter test test/features/asset_detail/responsive_detail_integration_test.dart` — PASS, `25` tests.
  - Combined asset-detail test command — PASS, `112` tests.
- **Commands not run and why**: none relevant to Task 0905.

## Path To 100

1. Route `/assets/:assetId` through the real descriptor provider and `AssetDetailView`; document how deep links pick a full-screen/shell mode by width.
2. Update Map, Operate, History, and Governance to use one shared consumer contract (`AssetDetailConsumer` or equivalent) that renders `AssetDetailView` from a descriptor rather than surface-local inspectors.
3. Replace History local changelog `_buildDetailPanel` with `ChangelogDetailView` via the universal descriptor path.
4. Add integration tests for all four consumer surfaces: Map skill open, Operate task open, History changelog open, Governance diagnostic asset open; each must assert open/close and correct variant dispatch.
5. Add router-responsive tests for `/assets/:assetId` at 600, 1000, and 1200 px proving narrow full-screen, medium overlay, and wide split-pane behavior.
6. Add semantic label/button role to the medium scrim or provide an accessible close control in the overlay drawer; prove it in a semantics test.
7. Clean scoped analyzer issues to `0` warnings/info.

## Task Ledger Patch Suggestion

```markdown
| 2026-06-19 | reviewers | 54/100 | REJECTED_TO_DOING | `docs/reports/review-wave-2026-06-19/0905-responsive-detail-shell-integration-rereview.md` |

### Latest Review Notes
- `REGRESSION/CRITICAL`: Map/History are only partial; Operate/Governance do not use the shared responsive asset detail shell.
- `REGRESSION/CRITICAL`: responsive shell renders local inspectors/placeholders, not universal `AssetDetailView` from descriptors.
- `NEW/CRITICAL`: `/assets/:assetId` route bypasses responsive shell and renders placeholder `AssetDetailPage`.
- `NEW/MODERATE`: medium scrim has no semantic label/button role.
- `PERSISTENT/MODERATE`: scoped asset-detail analyzer reports `44` issues.
```
