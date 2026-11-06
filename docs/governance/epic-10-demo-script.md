# EPIC 10 — Observatory Demo Walkthrough Script

> **Status**: v2.0 — live monorepo narrative contract (Task 1050 repair)
> **Generated**: 2026-06-07 · **Rewritten**: 2026-07-09 against `apps/observatory`
> **Purpose**: Single-source walkthrough that ties EPIC 10 acceptance questions to **file-backed, routable** surfaces
> **Anti-hallucination**: Every beat cites a real route + host file. Speculative copy is labeled **(illustrative)**. Fixture counts are from `apps/observatory/assets/mock_workspace/` as of 2026-07-09 and may drift.

---

## Live product spine (monorepo)

| Layer | Path |
|-------|------|
| App entry | `apps/observatory/lib/main.dart` → `ProviderScope` + `WarpPrismApp` |
| App shell | `apps/observatory/lib/app/app.dart`, `apps/observatory/lib/app/app_shell.dart` |
| Router | `apps/observatory/lib/app/router.dart` — `GoRouter` + `StatefulShellRoute` |
| Design system | `packages/warp_prism_ui/` — public API `Prism*` via `package:warp_prism_ui/warp_prism_ui.dart` |
| Mock corpus | `apps/observatory/assets/mock_workspace/` |

### Canonical shell routes

| Route | Workspace | Host widget | Feature module |
|-------|-----------|-------------|----------------|
| `/overview` | Overview | `OverviewPageShell` | `features/overview/` |
| `/map` | Map | `MapPageShell` → `MapWorkspacePage` | `features/map/` |
| `/operate` | Operate | `OperatePage` → `OperateWorkspaceView` | `features/operate/` |
| `/history` | History | `HistoryPageShell` → `HistoryWorkspacePage` | `features/history/` |
| `/governance` | Governance | `GovernanceOverviewPage` | `features/governance/` |

### Additional live routes (outside primary shell nav)

| Route | Host | Notes |
|-------|------|-------|
| `/assets/:assetId` | `AssetDetailPage` | Universal asset detail |
| `/asset/:id` | redirect | Legacy alias → `/assets/:id` |
| `/design-system` | `DesignSystemGalleryPage` | DS proof surface |
| `/workspace-snapshot` (+ deep-links) | `WorkspaceSnapshotPage` | Read-only scanner |
| `/` | redirect | → `/overview` |

### Fixture snapshot (mock workspace, 2026-07-09)

Counts are **filesystem inventory** of `apps/observatory/assets/mock_workspace/`, not runtime graph projections:

| Kind | Count | Evidence |
|------|------:|----------|
| Agents | 9 | `.opencode/agents/*.md` |
| Skill families (top-level dirs + `SKILL.md`) | 13 | `.opencode/skills/` |
| Workflow files | 11 | `.opencode/workflows/` |
| Task markdown files | 22 | `.project/tasks/**` (lanes 00–04) |
| Changelog files | 36 | `docs/changelog/` |

Runtime UI may show different totals after parsing, edge inference, and filtering — prefer on-screen metrics during a live demo.

---

## Narrative Spine

The demo answers five questions in shell order (plus Overview as optional cold open). Each question maps to a **live route**, a host surface, and a `PrismStoryPanel` (or feature story host that wraps it).

| # | Question | Route | Primary host | Story surface | Maturity |
|---|----------|-------|--------------|---------------|----------|
| 0 | (Optional cold open) Where am I? | `/overview` | Overview metrics + Current Story | `PrismStoryPanel` in `overview_page.dart` | **Live** |
| 1 | What exists? | `/map` | Catalog tabs + Graph | Map catalog/graph/inspector (no dedicated story panel yet) | **Live** |
| 2 | What matters now? | `/operate` | Lane board + task detail | `_OperateStoryPanel` → `PrismStoryPanel` | **Live** |
| 3 | Why did this change? | `/history` | Story / Impact views | `HistoryStoryView` → `PrismStoryPanel` | **Live** |
| 4 | What is risky? | `/governance` | Diagnostics + issue groups | `GovernanceStorySummary` → `PrismStoryPanel` | **Live** |
| 5 | How do assets connect? | `/map` (Graph tab) + `/assets/:id` | Graph canvas + inspector / asset detail | Relationship edges from `EdgeKind` | **Live** |

### Anti-Hallucination Note

- Shell, router, pages, and SDK **exist**. Do not claim missing `main.dart`, missing routes, Next.js README, or blocked Flutter tooling.
- Host story panels today mostly map into `PrismStoryInsight` (text/detail/value/color). The extended model `PrismStoryNarrativeInsight` (`evidence`, `riskLevel`, `connection`) is **rendered by** `PrismStoryPanel` / `DSStoryPanel` when provided; product hosts may still pass base insights only — upgrading hosts is optional follow-on work, not a demo blocker.
- Configuration snippets below marked **(illustrative)** show how a host *could* pass full narrative layers; they are not a claim that every host already constructs `PrismStoryNarrativeInsight`.

---

## Beat 0 — Overview (optional cold open)

**Route**: `/overview`  
**Core question**: What is the workspace story at a glance?  
**Host**: `apps/observatory/lib/features/overview/overview_page.dart` — `PrismStoryPanel` titled **Current Story**, footer with asset/edge totals from derived metrics.

**Demo talk track**:
1. Land on Overview after `flutter run` on `apps/observatory`.
2. Point at metric tiles, then **Current Story** narrative panel.
3. Use sidebar to walk Map → Operate → History → Governance.

---

## Beat 1 — Map: "What exists?"

**Route**: `/map`  
**Core question**: How many agents, skills, workflows, and tasks are in the workspace?  
**Host**: `MapPageShell` → `MapWorkspacePage`  
**Subviews (tabs)**: Agents · Skills · Workflows · Graph  
**Panels**: `MapCatalogPanel`, `MapGraphPanel`, `MapInspectorPanel`, `MapStatePanel`  
**Files**: `apps/observatory/lib/app/pages/map_page.dart`, `apps/observatory/lib/features/map/`

**Demo talk track**:
1. Open **Agents** — show 9 mock agents (fixture inventory).
2. Open **Skills** — 13 skill families under mock `.opencode/skills/`.
3. Open **Workflows** — 11 workflow files.
4. Select an asset — inspector / selection controller shows detail.
5. Switch to **Graph** to set up Beat 5 (connections).

**Story panel configuration** (illustrative — Map does not currently embed a dedicated `PrismStoryPanel`; use catalog counts + inspector instead):

```dart
// Illustrative narrative payload for a future Map story strip or DS gallery demo.
// Prefer Prism* public API.
PrismStoryPanel(
  title: 'Workspace Map',
  subtitle: 'What exists in the ASW Observatory',
  icon: Icons.map_outlined,
  accentColor: PrismColors.accentCyan,
  insights: [
    PrismStoryNarrativeInsight(
      text: '9 specialized agents in the mock corpus',
      detail: 'Orchestrators + domain specialists under .opencode/agents/',
      value: '9',
      evidence: 'apps/observatory/assets/mock_workspace/.opencode/agents/',
      riskLevel: PrismInsightRiskLevel.none,
      connection: 'agents → skills via EdgeKind.uses / references',
    ),
    PrismStoryNarrativeInsight(
      text: '13 skill families (top-level mock skills)',
      detail: 'Each family ships SKILL.md; subskills may expand the graph',
      value: '13',
      evidence: 'apps/observatory/assets/mock_workspace/.opencode/skills/',
      riskLevel: PrismInsightRiskLevel.none,
      connection: 'skills → workflows via EdgeKind.contains / dependsOn',
    ),
    PrismStoryNarrativeInsight(
      text: '11 workflow files in the mock harness',
      detail: 'Parsed into workflow assets on the Map catalog',
      value: '11',
      evidence: 'apps/observatory/assets/mock_workspace/.opencode/workflows/',
      riskLevel: PrismInsightRiskLevel.low,
      connection: 'workflows participate in dependsOn / uses edges',
    ),
  ],
)
```

**Fallback**: If graph canvas is empty/loading, stay on catalog tabs and cite fixture paths above. Do not invent counts.

---

## Beat 2 — Operate: "What matters now?"

**Route**: `/operate`  
**Core question**: What work is active, blocked, or ready for review?  
**Host**: `OperatePage` → `OperateWorkspaceView`  
**Story**: `_OperateStoryPanel` builds `PrismStoryPanel` from `OperateStoryDiagnostics` (`operate_storytelling.dart`)  
**Files**: `apps/observatory/lib/app/pages/operate_page.dart`, `apps/observatory/lib/features/operate/`

**Demo talk track**:
1. Show lane board (canonical lanes from task projection).
2. Point at **Operational Risk** story panel (review pressure, blockers, proof gaps — derived, not freeform prose).
3. Open a task detail for lane/status/proof fields.

**Live host behavior**: Insights are mapped to `PrismStoryInsight` with risk-tinted colors (`_toStoryInsight`). Risk severity enum on Operate side is `StoryRiskLevel` (parallel vocabulary to `PrismInsightRiskLevel`).

**Story panel configuration** (illustrative full narrative layers for DS contract / future host upgrade):

```dart
PrismStoryPanel(
  title: 'Active Operations',
  subtitle: 'What matters right now',
  icon: Icons.dashboard_outlined,
  accentColor: PrismColors.accentAmber,
  insights: [
    PrismStoryNarrativeInsight(
      text: 'Review queue pressure from projected tasks',
      detail: 'Derived by operate_storytelling from lane stacks',
      evidence: 'apps/observatory/lib/features/operate/operate_storytelling.dart',
      riskLevel: PrismInsightRiskLevel.medium,
      connection: 'review-lane tasks → proof / dependency edges',
    ),
    PrismStoryNarrativeInsight(
      text: 'Blocker clusters share unresolved dependsOn targets',
      detail: 'Clusters group tasks by missing or open dependency IDs',
      evidence: 'apps/observatory/lib/features/operate/operate_storytelling.dart',
      riskLevel: PrismInsightRiskLevel.high,
      connection: 'task.dependsOn → workspace assets',
    ),
    PrismStoryNarrativeInsight(
      text: 'Operate board is routable and fixture-backed',
      detail: 'OperatePage wires workspace snapshot → OperateWorkspaceView',
      evidence: 'apps/observatory/lib/app/pages/operate_page.dart',
      riskLevel: PrismInsightRiskLevel.none,
      connection: 'shell nav index 2 → /operate',
    ),
  ],
)
```

---

## Beat 3 — History: "Why did this change?"

**Route**: `/history`  
**Core question**: What changed recently, why, and with what proof?  
**Host**: `HistoryPageShell` → `HistoryWorkspacePage`  
**Story**: `HistoryStoryView` groups changelog entries into `PrismStoryPanel` per project  
**Impact**: `HistoryImpactView` for change → task → workflow style linkage  
**Files**: `apps/observatory/lib/app/pages/history_page.dart`, `apps/observatory/lib/features/history/`

**Demo talk track**:
1. Open History story mode — one panel per project group.
2. Expand/entry list in panel footer for concrete changelog items.
3. Switch to Impact view when showing causality (Beat 5 support).

**Story panel configuration** (illustrative; live host builds insights from `ProjectStoryGroup` metadata):

```dart
PrismStoryPanel(
  title: 'Change History',
  subtitle: 'Why things changed',
  icon: Icons.history_outlined,
  accentColor: PrismColors.accentViolet,
  insights: [
    PrismStoryNarrativeInsight(
      text: 'Changelog corpus is fixture-backed under mock docs/changelog',
      detail: '36 files inventoried; runtime timeline groups by project',
      value: '36',
      evidence: 'apps/observatory/assets/mock_workspace/docs/changelog/',
      riskLevel: PrismInsightRiskLevel.none,
      connection: 'changelog → task via EdgeKind.changedBy',
    ),
    PrismStoryNarrativeInsight(
      text: 'History story panels are computed, not freeform marketing copy',
      detail: 'Entry counts, change types, impact tags from frontmatter',
      evidence: 'apps/observatory/lib/features/history/presentation/widgets/history_story_view.dart',
      riskLevel: PrismInsightRiskLevel.none,
      connection: 'HistoryStoryView → PrismStoryPanel',
    ),
  ],
)
```

**Linked timeline**: Prefer live History UI (`DSTimeline*` / history controller) over inventing entries. Grouped timeline organisms live in `packages/warp_prism_ui/`.

---

## Beat 4 — Governance: "What is risky?"

**Route**: `/governance`  
**Core question**: What is canonical, generated, stale, or blocking?  
**Host**: `GovernanceOverviewPage`  
**Story**: `GovernanceStorySummary` → `PrismStoryPanel` **Risk Stories** with drill-down footer  
**Supporting panels**: fan-in hotspots, issue filters/groups, boundary legend, review pressure  
**Files**: `apps/observatory/lib/features/governance/presentation/`

**Demo talk track**:
1. Open Governance — show risk stories derived from diagnostics.
2. Call out orphan / stale / proof-gap / hotspot stories as present in data.
3. Drill into an affected asset via story footer when IDs exist.
4. Optional: open `/assets/:assetId` for universal detail.

**Story panel configuration** (illustrative; live stories use `GovernanceRiskStory` + `PrismStoryInsight`):

```dart
PrismStoryPanel(
  title: 'Governance Diagnostics',
  subtitle: 'What is risky or stale',
  icon: Icons.shield_outlined,
  accentColor: PrismColors.statusError,
  insights: [
    PrismStoryNarrativeInsight(
      text: 'Risk stories are diagnostic-derived',
      detail: 'Orphans, stale refs, proof gaps, hotspots — not static boilerplate claims',
      evidence: 'apps/observatory/lib/features/governance/presentation/widgets/governance_story_summary.dart',
      riskLevel: PrismInsightRiskLevel.medium,
      connection: 'story.involvedAssetIds → GovernanceDrilldownTarget',
    ),
    PrismStoryNarrativeInsight(
      text: 'Canonicality is a first-class provenance model',
      detail: 'parentCanonical, childLocal, generated, appendOnly, archive, mock',
      evidence: 'apps/observatory/lib/data/models/workspace_graph.dart',
      riskLevel: PrismInsightRiskLevel.none,
      connection: 'Canonicality → provenance pills / boundary legend',
    ),
    PrismStoryNarrativeInsight(
      text: 'README is Flutter monorepo documentation',
      detail: 'Melos workspace; not Next.js boilerplate',
      evidence: 'README.md',
      riskLevel: PrismInsightRiskLevel.none,
      connection: 'contributors land on Melos + apps/observatory',
    ),
  ],
)
```

---

## Beat 5 — Connections: "How do assets relate?"

**Route**: `/map` (Graph tab) and/or `/assets/:assetId`  
**Core question**: Can the user trace a path from a task to the skill that governed it, to the workflow that executed it?  
**Host**: `MapGraphPanel` + `MapInspectorPanel`; asset detail feature  
**Model**: `EdgeKind` in `apps/observatory/lib/data/models/workspace_graph.dart`

**Edge kinds (live enum)**:

| EdgeKind | Meaning |
|----------|---------|
| `contains` | super-skill → sub-skill, skill → skill-local workflow |
| `routesTo` | gateway skill → sub-skill or workflow |
| `dependsOn` | task/workflow/agent → skill/rule/script/reference |
| `references` | generic cross-reference |
| `changedBy` | changelog → task |
| `proves` | task → evidence |
| `uses` | agent → skill/workflow |

**Demo talk track**:
1. From Map Graph, select a node and read edges in the inspector.
2. Open `/assets/:assetId` for universal detail sections.
3. Optionally return to History Impact for change → task story.

**Story panel configuration** (illustrative):

```dart
PrismStoryPanel(
  title: 'Asset Connections',
  subtitle: 'Navigable causality across the workspace',
  icon: Icons.hub_outlined,
  accentColor: PrismColors.accentGold,
  insights: [
    PrismStoryNarrativeInsight(
      text: 'Seven typed edge kinds connect the graph backbone',
      detail: 'contains, routesTo, dependsOn, references, changedBy, proves, uses',
      evidence: 'apps/observatory/lib/data/models/workspace_graph.dart',
      riskLevel: PrismInsightRiskLevel.none,
      connection: 'EdgeKind is the relational vocabulary for Map + detail',
    ),
    PrismStoryNarrativeInsight(
      text: 'Changelog entries can link back to motivating tasks',
      detail: 'changedBy edge type',
      evidence: 'apps/observatory/lib/data/models/workspace_graph.dart',
      riskLevel: PrismInsightRiskLevel.none,
      connection: 'History Impact + graph projection share the same backbone',
    ),
  ],
)
```

---

## Narrative Contract Summary

Public API (prefer in apps and docs):

| Public name | Implementation |
|-------------|----------------|
| `PrismStoryPanel` | `DSStoryPanel` |
| `PrismStoryInsight` | `DSStoryInsight` |
| `PrismStoryNarrativeInsight` | `DSStoryNarrativeInsight` |
| `PrismInsightRiskLevel` | `InsightRiskLevel` |
| `PrismStoryCardQuick` | `DSStoryCardQuick` |

Four narrative layers on `PrismStoryNarrativeInsight`:

| Layer | Field | Purpose | Panel rendering |
|-------|-------|---------|-----------------|
| **Insight** | `text`, `detail`, `value`, `color` | What the data says | Always |
| **Evidence** | `evidence` | Where to verify | Shown as `Evidence: …` when non-null |
| **Risk** | `riskLevel` | Gap severity (`none`…`critical`) | Badge when not `none`; tints indicator |
| **Connection** | `connection` | Relational / blocking context | Shown as `Connection: …` when non-null |

Regression: `packages/warp_prism_ui/test/story_panel_narrative_test.dart` (model + widget pump for rendered layers).

---

## Workspace-to-Question Mapping

| Workspace | Route | Questions answered | Primary surface | Secondary surface |
|-----------|-------|--------------------|-----------------|-------------------|
| Overview | `/overview` | Cold open / totals | Metrics + Current Story | — |
| Map | `/map` | What exists? How do assets relate? | Catalog + Graph | Inspector, `/assets/:id` |
| Operate | `/operate` | What matters now? | Lane board | Operational Risk story, task detail |
| History | `/history` | Why did this change? | History story panels | Impact view |
| Governance | `/governance` | What is risky? What is stale? | Risk Stories + diagnostics | Drill-down, asset detail |

---

## Fallback Notes

1. **Loading / error / empty**: Shell handlers (`ShellStateHandler`, map state panel) cover async load — demo should show loading briefly then fixture data; if empty, say so rather than inventing assets.
2. **Host insight type**: Feature hosts may still emit `PrismStoryInsight` only; full evidence/risk/connection UI requires `PrismStoryNarrativeInsight` instances. DS panel supports both.
3. **Counts drift**: Fixture inventory above is a point-in-time directory count; always prefer UI metrics when demoing.
4. **Out of scope for this script**: Claiming live backend mutation, CyberCore as the ASW shell, or root-level `lib/` as the app (app code lives under `apps/observatory/lib/`).
5. **Design system gallery**: `/design-system` remains a valid offline proof surface for `PrismStoryPanel` if product data is unavailable.
)
