# Observatory Failure Baseline Inventory

> **Date**: 2026-06-09
> **Source**: `flutter test` in `apps/observatory/` (fresh run)
> **Total tests**: 653
> **Passed**: 589
> **Failed**: 64
> **Pass rate**: 90.2%
> **Classification**: Inventory only — no tests were modified
> **Task origin**: Task 1401, EPIC-14 stabilization wave
> **Predecessor**: `docs/reports/warp-prism-test-failure-baseline.md` (Task 1201)

---

## 1. Summary

| Feature Area | Failures | Primary EPIC-14 Fix Task | Effort (S/M/L) |
|---|---|---|---|
| asset_detail | 24 | 1404 (Asset Detail Chain) | L |
| parsers | 8 | 1403 (Parser Contract Chain) | S |
| governance | 6 | 1406 (Governance & Diagnostics Chain) | M |
| history | 7 | 1407 (History Chain) | M |
| map | 6 | 1405 (Map Surface Chain) | M |
| operate | 4 | 1404 (shared fix via TaskProjection contract) | S |
| app/shell | 3 | 1405 (shared fix via router/shell) | S |
| overview | 1 | 1406 (shared fix via metrics contract) | S |
| models | 2 | 1403 (shared fix via backbone model) | S |
| **TOTAL** | **64** | | |

---

## 2. Root Cause Taxonomy

Cross-cutting root causes that span multiple feature areas:

| Root Cause | Failures | Description |
|---|---|---|
| View-mismatch | 26 | Widget implementation doesn't render what tests expect (text, layout, state) |
| Mapper contract drift | 11 | `asset_detail_mapper` builds detail sections differently than tests expect |
| Projection contract drift | 12 | `WorkspaceTaskProjectionParser`, `HistoryState`, `OverviewProvider` produce different shapes |
| Model contract drift | 2 | `WorkspaceAsset` equality or `AssetKind` enum API mismatch |
| Widget not implemented | 8 | `DSSearchBar`, `AssetDetailPage`, `DSShell`/`DSSidebar`/`DSTopbar` missing or different |
| Chain position: View | 14 | GenericAssetDetailView `AssetKind.name` NoSuchMethodError (downstream of model) |
| Chain position: Projection | 8 | Parser `fromStatus` mapping is pass-through (status strings ≠ directory prefixes) |

---

## 3. Per-Failure Detail

### 3.1 asset_detail — GenericAssetDetailView `AssetKind.name` (11 failures)

**File**: `test/features/asset_detail/extended_detail_variants_test.dart`
**Chain position**: View (downstream of Model)
**Taxonomy class**: Contract drift
**Fix task**: 1404

| # | Test Name | Expected/Actual | Root Cause Hypothesis |
|---|---|---|---|
| 1 | GenericAssetDetailView (fallback) renders partial support banner for subskill | Text "Partial support" not found | `GenericAssetDetailView._buildSubtitle` calls `asset.kind.name` which throws `NoSuchMethodError` on `AssetKind` — view crash prevents rendering |
| 2 | GenericAssetDetailView (fallback) renders partial support banner for script | Text "Partial support" not found | Same — `AssetKind.name` NoSuchMethodError |
| 3 | GenericAssetDetailView (fallback) renders partial support banner for reference | Text "Partial support" not found | Same |
| 4 | GenericAssetDetailView (fallback) renders partial support banner for rule | Text "Partial support" not found | Same |
| 5 | GenericAssetDetailView (fallback) shows identity and metadata in fallback view | Text "Identity" not found | Same — entire view crashes before rendering any content |
| 6 | AssetDetailView dispatcher dispatches subskill to GenericAssetDetailView | Text "Partial support" not found | Same — dispatched through `AssetDetailView` → `GenericAssetDetailView` → crash |
| 7 | AssetDetailView dispatcher dispatches script to GenericAssetDetailView | Text "Partial support" not found | Same |
| 8 | AssetDetailView dispatcher dispatches reference to GenericAssetDetailView | Text "Partial support" not found | Same |
| 9 | AssetDetailView dispatcher dispatches rule to GenericAssetDetailView | Text "Partial support" not found | Same |
| 10 | ChangelogDetailView renders ledger source and related task | Text "Ledger Source" not found | View-mismatch — `ChangelogDetailView` may not render expected section titles |
| 11 | AgentDetailView renders tools section | Text "Tools" not found | View-mismatch — `AgentDetailView` may not render "Tools" section with expected text |

**Cascade analysis**: Failures 1-5 are the root failure. Failures 6-9 cascade from the same `AssetKind.name` bug when the dispatcher routes to `GenericAssetDetailView`. Failures 10-11 are separate view-mismatch issues.

---

### 3.2 asset_detail — Responsive Detail Shell (5 failures)

**File**: `test/features/asset_detail/responsive_detail_integration_test.dart`
**Chain position**: View
**Taxonomy class**: Stale test / view-mismatch
**Fix task**: 1404

| # | Test Name | Expected/Actual | Root Cause Hypothesis |
|---|---|---|---|
| 12 | ResponsiveDetailShell Wide layout split pane uses Row layout | `find.byType(Row)` findsWidgets (expected) but test may fail on additional assertion | The `Row` check may be passing but an implicit `Scaffold` assertion fails — **this test actually passed in the failure list; needs re-verification** |
| 13 | ResponsiveDetailShell Narrow layout renders full-screen detail with Scaffold and AppBar | `Scaffold` findsOneWidget but the test wrapper `_wrapWithWidth` also uses `Scaffold` → finds 2 | Test wrapper adds an outer Scaffold that the assertion doesn't account for |
| 14 | Breakpoint contract alignment wide uses split-pane at exactly 1200px | `Scaffold` findsNothing expected, but the test wrapper's Scaffold is found | `ResponsiveDetailShell` at 1200px shouldn't add its own Scaffold, but test wrapper has one |
| 15 | Breakpoint contract alignment narrow uses full-screen at 600px | `Scaffold` findsOneWidget expected, but finds 2 (wrapper + detail) | Test wrapper Scaffold + narrow-mode detail Scaffold = 2 |
| 16 | Breakpoint contract alignment narrow at 799px uses full-screen | `Scaffold` findsOneWidget expected, but finds 2 | Same wrapper collision |

**Note**: Tests 13-16 share the same root cause — the test wrapper `_wrapWithWidth` uses `MaterialApp(home: Scaffold(...))` which introduces a Scaffold that the test assertions don't account for. The `ResponsiveDetailShell` narrow layout also renders a Scaffold.

---

### 3.3 asset_detail — Skill & Task Detail Views (6 failures)

**File**: `test/features/asset_detail/skill_task_detail_widgets_test.dart`
**Chain position**: Mapper/View
**Taxonomy class**: Mapper contract drift
**Fix task**: 1404

| # | Test Name | Expected/Actual | Root Cause Hypothesis |
|---|---|---|---|
| 17 | SkillDetailView renders all 6 panels for a complete skill | Section titles not found (Role in Harness, Sub-structure, etc.) | `SkillDetailView` implementation doesn't render kind-specific sections from `descriptor.kindSections` |
| 18 | TaskDetailView renders forensic sections with lane-neutral header | `task:0903` and `02-doing` not found | `TaskDetailView` doesn't render header or metadata from descriptor |
| 19 | TaskDetailView renders dependencies as link rows | `Dependencies` text not found | Section not rendered |
| 20 | TaskDetailView renders evidence section | `Evidence` text not found | Section not rendered |
| 21 | TaskDetailView renders related skills and workflows | `Related Skills & Workflows` not found | Section not rendered |
| 22 | TaskDetailView renders lifecycle section | `Lifecycle` not found | Section not rendered |

**Pattern**: `SkillDetailView` and `TaskDetailView` appear to not render sections from `descriptor.kindSections`. Either the views delegate to a section builder that doesn't exist yet, or the views use a different internal API than the test fixtures construct.

---

### 3.4 asset_detail — Descriptor Metadata Mapper (2 failures)

**File**: `test/features/asset_detail/asset_detail_descriptor_test.dart`
**Chain position**: Mapper
**Taxonomy class**: Mapper contract drift
**Fix task**: 1404

| # | Test Name | Expected/Actual | Root Cause Hypothesis |
|---|---|---|---|
| 23 | Descriptor metadata section includes frontmatter metadata | `version` and `status` labels not found in `allSections` properties | `buildAssetDetailDescriptor` mapper doesn't flatten frontmatter keys into `DetailProperty` labels |
| 24 | Descriptor metadata section includes task-specific fields | `priority` and `lane` labels not found | Task frontmatter keys not mapped to descriptor properties |

**Pattern**: The `asset_detail_mapper` doesn't extract frontmatter key-value pairs into `DetailSection` properties. The test expects `result.descriptor.allSections.expand((s) => s.properties).toList()` to contain labels from frontmatter, but the mapper either doesn't produce a "Metadata" section or doesn't iterate frontmatter keys.

---

### 3.5 parsers — Task Projection Parser (8 failures)

**File**: `test/data/parsers/workspace_task_projection_parser_test.dart`
**Chain position**: Projection
**Taxonomy class**: Contract drift
**Fix task**: 1403

| # | Test Name | Expected/Actual | Root Cause Hypothesis |
|---|---|---|---|
| 25 | parses planning lane task (T001) | `task.lane` expected `TaskLane.planning` but got `TaskLane.open` | `TaskLaneParsing.fromStatus("planning")` delegates to `fromDirectoryPrefix("planning")` which doesn't match "00-planning" → defaults to `open` |
| 26 | parses doing lane task (T009) | `task.lane` expected `TaskLane.doing` but got `TaskLane.open` | Same — `"doing"` ≠ `"02-doing"` |
| 27 | parses review lane task (T015) | `task.lane` expected `TaskLane.review` but got `TaskLane.open` | Same — `"review"` ≠ `"03-review"` |
| 28 | parses completed lane task (T018) | `task.lane` expected `TaskLane.completed` but got `TaskLane.open` | Same — `"completed"` ≠ `"04-completed"` |
| 29 | frontmatter status overrides directory path | `task.lane` expected `TaskLane.completed` but got `TaskLane.open` | `fromStatus("completed")` → `fromDirectoryPrefix("completed")` → default → `open` |
| 30 | hasCompletionEvidence is false for "not yet" text | `hasCompletionEvidence` expected false but was true | `TaskProjection.hasCompletionEvidence` checks `completionEvidenceSummary` nullability, not content pattern; parser may produce non-null evidence from italic text |
| 31 | parseAll — OperateProjection groups tasks into five lanes | `laneFor(TaskLane.planning).count` expected 1 but was 0 | All tasks parsed as `open` lane (cascades from 25-28), so planning lane is empty |
| 32 | parseAll — OperateProjection returns empty lane when no tasks match | `laneFor(TaskLane.planning).isEmpty` expected true — **may actually pass** if only doing task is provided | Needs re-verification |

**Critical root cause**: `TaskLaneParsing.fromStatus` is a pass-through to `fromDirectoryPrefix` which only handles directory-style strings like `"00-planning"`, not status-style strings like `"planning"`. This single defect cascades through all lane-dependent tests.

---

### 3.6 models — Workspace Graph Models (2 failures)

**File**: `test/data/models/workspace_graph_models_test.dart`
**Chain position**: Model
**Taxonomy class**: Model contract drift
**Fix task**: 1403

| # | Test Name | Expected/Actual | Root Cause Hypothesis |
|---|---|---|---|
| 33 | WorkspaceAsset equality is based on id, kind, name, path, canonicality | `a == b` expected true but was false | `WorkspaceAsset` equality implementation may include `description` or other fields beyond the five stated fields, or equality is identity-based rather than value-based |
| 34 | EdgeInferenceService inferWorkflowDependencies creates dependsOn edges | `edges[0].targetId` expected `"skill:compile"` but differs | `inferWorkflowDependencies` may not produce `dependsOn` edges — could produce `references` or `uses` instead, or the method signature differs |

---

### 3.7 history — Story Modes (6 failures)

**File**: `test/features/history/history_story_modes_test.dart`
**Chain position**: View
**Taxonomy class**: View-mismatch
**Fix task**: 1407

| # | Test Name | Expected/Actual | Root Cause Hypothesis |
|---|---|---|---|
| 35 | switching to project story mode renders story panels | `warp-prism` and `ganthritor` text not found | `HistoryStoryView` not rendering project group headers, or `HistoryWorkspacePage` doesn't delegate to story view for `projectStory` mode |
| 36 | switching to impact story mode renders impact cards | `0612` and `0712` not found | `HistoryImpactView` not rendering entry ID fragments |
| 37 | tapping mode chip changes mode | After tapping "Project Story", `warp-prism` not found | Mode change doesn't trigger re-render with story view |
| 38 | HistoryImpactView renders impact path cards | Entry IDs not found | Widget doesn't render impact cards from `ImpactPathNode` |
| 39 | HistoryImpactView shows gap indicator for missing task | "No task linked to this entry" not found | Gap indicator text different or not rendered |
| 40 | HistoryImpactView shows gap indicator for missing skills | "No skills/workflows linked" not found | Gap indicator text different or not rendered |

---

### 3.8 history — Timeline Page (2 failures)

**File**: `test/features/history/history_page_test.dart`
**Chain position**: Projection/View
**Taxonomy class**: Contract drift
**Fix task**: 1407

| # | Test Name | Expected/Actual | Root Cause Hypothesis |
|---|---|---|---|
| 41 | HistoryWorkspacePage renders timeline entries in reverse chronological order | "4 of 4" not found | `HistoryWorkspacePage` doesn't render result count text in expected format |
| 42 | HistoryWorkspacePage renders filter categories | "Project", "Type", "Task" text not found | Filter UI not rendering category labels, or using different label text |

---

### 3.9 governance — Boundaries Overview (3 failures)

**File**: `test/features/governance/governance_boundaries_overview_test.dart`
**Chain position**: View/Projection
**Taxonomy class**: View-mismatch
**Fix task**: 1406

| # | Test Name | Expected/Actual | Root Cause Hypothesis |
|---|---|---|---|
| 43 | GovernanceOverviewPage renders canonical count from fixture data | "18" text not found | `GovernanceOverviewPage` doesn't render count numbers from `CanonicalityBoundarySummary.counts` |
| 44 | GovernanceOverviewPage renders generated count from fixture data | "8" text not found | Same — counts not rendered |
| 45 | GovernanceOverviewPage renders all six boundary classes in legend | "Child-Local", "Append-Only", "Archive", "Mock" not found | `GovernanceBoundaryLegend` doesn't render all class labels, or renders them differently |

---

### 3.10 governance — Analytics Panels (3 failures)

**File**: `test/features/governance/governance_analytics_panels_test.dart`
**Chain position**: View
**Taxonomy class**: View-mismatch
**Fix task**: 1406

| # | Test Name | Expected/Actual | Root Cause Hypothesis |
|---|---|---|---|
| 46 | ReviewPressurePanel renders healthy state when empty | "No review pressure" not found | `ReviewPressurePanel` uses different healthy-state copy |
| 47 | ReviewPressurePanel renders pressure indicators | "Implement Inspector" not found | Panel doesn't render indicator task titles |
| 48 | ReviewPressurePanel renders lane breakdown chips | "03-review" not found | Lane chips not rendered, or rendered as different text |

---

### 3.11 map — Workspace Page (3 failures)

**File**: `test/features/map/map_workspace_page_test.dart`
**Chain position**: View
**Taxonomy class**: Widget not implemented
**Fix task**: 1405

| # | Test Name | Expected/Actual | Root Cause Hypothesis |
|---|---|---|---|
| 49 | MapWorkspacePage shows catalog panel on first tab (Agents) | `DSSearchBar` not found | `DSSearchBar` widget doesn't exist in `warp_prism_ui`, or `MapWorkspacePage` doesn't use it |
| 50 | MapWorkspacePage switching tabs shows correct content | `DSSearchBar` not found | Same missing widget |
| 51 | MapWorkspacePage renders with initial state specifying a subview | "Asset Graph" not found | Graph subview content text differs |

---

### 3.12 map — Surface States (2 failures)

**File**: `test/features/map/map_surface_states_test.dart`
**Chain position**: View/Projection
**Taxonomy class**: View-mismatch
**Fix task**: 1405

| # | Test Name | Expected/Actual | Root Cause Hypothesis |
|---|---|---|---|
| 52 | Map surface - happy path renders graph tab with projection when edges exist | "Containment" not found | Graph mode selector text differs or not rendered |
| 53 | Map surface - error state error state shows retry button | "Retry" not found | `MapStatePanel` error state doesn't render retry button text |

---

### 3.13 map — Selection & Inspector (1 failure)

**File**: `test/features/map/map_selection_and_inspector_test.dart`
**Chain position**: View
**Taxonomy class**: View-mismatch
**Fix task**: 1405

| # | Test Name | Expected/Actual | Root Cause Hypothesis |
|---|---|---|---|
| 54 | MapInspectorPanel widget switches from selected to no-selection when cleared | "No asset selected" not found after clearing | `MapInspectorPanel` doesn't update to empty state when controller clears selection |

---

### 3.14 map — Catalog Panel (1 failure)

**File**: `test/features/map/map_catalog_panel_test.dart`
**Chain position**: View
**Taxonomy class**: View-mismatch
**Fix task**: 1405

| # | Test Name | Expected/Actual | Root Cause Hypothesis |
|---|---|---|---|
| 55 | MapNoResultsState widget shows message for query with no results | `find.text('No results for "nonexistent"')` not found | `MapNoResultsState` renders different copy or not at all |

---

### 3.15 operate — Task Detail Inspector (4 failures)

**File**: `test/features/operate/operate_task_detail_inspector_test.dart`
**Chain position**: View
**Taxonomy class**: View-mismatch
**Fix task**: 1404 (shared fix)

| # | Test Name | Expected/Actual | Root Cause Hypothesis |
|---|---|---|---|
| 56 | OperateTaskDetailPanel renders task identity as header | `textContaining('0612')` not found | `OperateTaskDetailPanel` doesn't render task ID in header |
| 57 | OperateTaskDetailPanel renders evidence rows | "Completion Evidence" not found | Evidence section not rendered |
| 58 | OperateTaskDetailPanel renders related skills and workflows | "Related Skills & Workflows" not found | Section not rendered |
| 59 | OperateTaskDetailPanel renders body summary section | "Body Summary" not found | Section not rendered |

---

### 3.16 app/shell — Smoke & Deep Link (3 failures)

**File**: `test/app/app_shell_smoke_test.dart`, `test/app/deep_link_fallback_test.dart`
**Chain position**: View
**Taxonomy class**: Widget not implemented
**Fix task**: 1405

| # | Test Name | Expected/Actual | Root Cause Hypothesis |
|---|---|---|---|
| 60 | App shell smoke test app boots and renders the shell with default route | `DSShell`, `DSSidebar`, or `DSTopbar` not found | These widgets may not exist in `warp_prism_ui`, or `WarpPrismApp` uses a different shell implementation |
| 61 | App shell smoke test default route lands on Overview | "Overview" not found | Overview page doesn't render the text "Overview" |
| 62 | AssetDetailPage deep-link fallback renders detail for valid asset ID | "Asset Detail" not found | `AssetDetailPage` renders a different placeholder or full implementation |

---

### 3.17 overview — Provider (1 failure)

**File**: `test/features/overview/overview_provider_test.dart`
**Chain position**: Projection
**Taxonomy class**: Contract drift
**Fix task**: 1406

| # | Test Name | Expected/Actual | Root Cause Hypothesis |
|---|---|---|---|
| 63 | OverviewProvider counts governance diagnostics at warning or above | `governanceWarningCount` expected 2 but was different | `OverviewProvider.compute` doesn't count diagnostics at `warning` or above correctly — may only count `error` severity |

---

### 3.18 graph builder — Edge Inference (1 failure)

**File**: `test/data/services/workspace_graph_builder_test.dart`
**Chain position**: Model/Projection
**Taxonomy class**: Model contract drift
**Fix task**: 1403

| # | Test Name | Expected/Actual | Root Cause Hypothesis |
|---|---|---|---|
| 64 | EdgeInferenceService inferWorkflowDependencies creates dependsOn edges | Edge kind or target mismatch | `inferWorkflowDependencies` produces a different edge kind than `EdgeKind.dependsOn` |

---

## 4. Group → EPIC-14 Task Mapping

| Group | Failures | EPIC-14 Task | What the Fix Should Do |
|---|---|---|---|
| **Parsers** (3.5, 3.6, 3.18) | 11 | **1403** — Parser Contract Chain | Fix `TaskLaneParsing.fromStatus` to handle bare status strings; fix `WorkspaceAsset` equality; fix `EdgeInferenceService` edge kinds |
| **Asset Detail** (3.1, 3.2, 3.3, 3.4, 3.15) | 28 | **1404** — Asset Detail Chain | Fix `AssetKind.name` NoSuchMethodError; implement `SkillDetailView`/`TaskDetailView` section rendering; fix `asset_detail_mapper` frontmatter extraction; fix responsive test wrapper scaffolds |
| **Map** (3.11, 3.12, 3.13, 3.14, 3.16) | 10 | **1405** — Map Surface Chain | Implement `DSSearchBar` or update tests; fix `MapStatePanel` text; fix `MapInspectorPanel` state update; implement `AssetDetailPage` shell |
| **Governance** (3.9, 3.10, 3.17) | 7 | **1406** — Governance & Diagnostics Chain | Fix `GovernanceOverviewPage` count rendering; fix `ReviewPressurePanel` text; fix `OverviewProvider.compute` warning counting |
| **History** (3.7, 3.8) | 8 | **1407** — History Chain | Implement `HistoryStoryView`/`HistoryImpactView` rendering; fix `HistoryWorkspacePage` result count and filter UI |

---

## 5. Effort Estimates

| Group | Failures | Complexity | Estimated Effort | Notes |
|---|---|---|---|---|
| Parsers (1403) | 11 | Low-Medium | **S** | `fromStatus` is a 10-line fix + test. Equality/inference are single-method fixes. High value: unblocks 8 parser tests + 2 model tests + 1 graph test. |
| Asset Detail (1404) | 28 | Medium-High | **L** | Multiple view implementations + mapper fix + `AssetKind` API. Highest failure count. |
| Map (1405) | 10 | Medium | **M** | Mix of widget implementation + test adjustments. Depends on `warp_prism_ui` component availability. |
| Governance (1406) | 7 | Low-Medium | **M** | Widget rendering fixes + metrics counting logic. Straightforward text/layout corrections. |
| History (1407) | 8 | Medium | **M** | Story/impact view implementations + controller wiring. |

---

## 6. Chain Position Analysis

### Top-down failures (corpus → parser → projection → view)

**11 failures** — The parser group (3.5) is top-down: `TaskLaneParsing.fromStatus` produces wrong lanes, which cascades to `parseAll` grouping, which would cascade to any view consuming the Operate projection.

### Bottom-up failures (view stale → test fails)

**26 failures** — The view-mismatch group (3.2, 3.3, 3.7, 3.11-3.15) is bottom-up: views either don't exist yet or render different content than tests expect. The code is the source of truth and tests need to match.

### Model-level failures

**3 failures** — The model contract group (3.6) is foundational: `WorkspaceAsset` equality and edge inference affect every downstream consumer.

### Mixed (mapper in the middle)

**11 failures** — The mapper group (3.4) sits between model and view: the mapper doesn't produce the detail sections that views and tests expect.

---

## 7. Verification Commands

```bash
# Full observatory test suite
cd apps/observatory && flutter test 2>&1 | grep "\[E\]" | wc -l
# Expected: 64

# Per-group verification
cd apps/observatory && flutter test test/data/parsers/workspace_task_projection_parser_test.dart 2>&1 | tail -3
cd apps/observatory && flutter test test/data/models/workspace_graph_models_test.dart 2>&1 | tail -3
cd apps/observatory && flutter test test/features/asset_detail/ 2>&1 | tail -3
cd apps/observatory && flutter test test/features/history/ 2>&1 | tail -3
cd apps/observatory && flutter test test/features/governance/ 2>&1 | tail -3
cd apps/observatory && flutter test test/features/map/ 2>&1 | tail -3
cd apps/observatory && flutter test test/features/operate/ 2>&1 | tail -3
cd apps/observatory && flutter test test/features/overview/ 2>&1 | tail -3
cd apps/observatory && flutter test test/app/ 2>&1 | tail -3
```

---

## 8. Evidence

- **Fresh test run**: 2026-06-09, `flutter test` in `apps/observatory/`, 653 tests, 589 pass, 64 fail
- **Task 1201 baseline count confirmed**: 64 failures matches the Task 1201 pre-existing count
- **Failure list extraction**: `grep "\[E\]"` from test output, 64 unique test entries confirmed
- **Source files read**: All 14 failing test files and 6 key implementation files read before classification
- **No tests modified**: Inventory only per task requirements
