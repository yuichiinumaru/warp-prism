# EPIC 10 — Observatory Demo Walkthrough Script

> **Status**: v1.0 — narrative contract
> **Generated**: 2026-06-07 by Task 1050
> **Purpose**: Single-source walkthrough that ties EPIC 10 acceptance questions to real file-backed surfaces
> **Blocked surfaces**: Marked with ⛔ — no page/route exists yet; narrative contract is ready but host is absent.

---

## Narrative Spine

The demo answers five questions in order. Each question maps to a workspace, a host surface, and a `DSStoryPanel` instance.

| # | Question | Workspace | Host Surface | Status |
|---|----------|-----------|-------------|--------|
| 1 | What exists? | Map | Graph canvas + asset catalog | ⛔ No page |
| 2 | What matters now? | Operate | Lane board + task detail | ⛔ No page |
| 3 | Why did this change? | History | Timeline + changelog story | ⛔ No page |
| 4 | What is risky? | Governance | Diagnostic surface + provenance | ⛔ No page |
| 5 | How do assets connect? | Map (graph) | Relationship graph + pathfinder | ⛔ No page |

### Anti-Hallucination Note

No live page, route, or app shell exists for any workspace. The narrative contract below describes what each surface **should** host once a page is created. The `DSStoryPanel` component and its enhanced `DSStoryNarrativeInsight` model are file-backed and testable without a running app.

---

## Beat 1 — Map: "What exists?"

**Core question**: How many agents, skills, workflows, and tasks are in the workspace?

**Story panel configuration**:
```
DSStoryPanel(
  title: 'Workspace Map',
  subtitle: 'What exists in the ASW Observatory',
  icon: Icons.map_outlined,
  accentColor: DSColors.accentCyan,
  insights: [
    DSStoryNarrativeInsight(
      text: '38 skills across 13 families',
      detail: '12 super-skills, 26 sub-skills',
      value: '38',
      evidence: 'assets/mock_workspace/.agents/skills/',
      riskLevel: InsightRiskLevel.none,
      connection: 'harness-architecture governs all skill families',
    ),
    DSStoryNarrativeInsight(
      text: '9 specialized agents with distinct roles',
      detail: '3 orchestrators, 6 domain specialists',
      value: '9',
      evidence: 'assets/mock_workspace/.agents/agents/',
      riskLevel: InsightRiskLevel.none,
      connection: 'agents → skills via uses edges',
    ),
    DSStoryNarrativeInsight(
      text: '42 workflows across review, build, and governance',
      detail: 'global workflows + skill-local workflows',
      value: '42',
      evidence: 'assets/mock_workspace/.agents/workflows/',
      riskLevel: InsightRiskLevel.low,
      connection: 'workflows → skills via dependsOn edges',
    ),
  ],
)
```

**Fallback**: If graph canvas has not been implemented, show `DSStoryPanel` alone with an explanatory footer noting the graph is blocked.

---

## Beat 2 — Operate: "What matters now?"

**Core question**: What work is active, blocked, or ready for review?

**Story panel configuration**:
```
DSStoryPanel(
  title: 'Active Operations',
  subtitle: 'What matters right now',
  icon: Icons.dashboard_outlined,
  accentColor: DSColors.accentAmber,
  insights: [
    DSStoryNarrativeInsight(
      text: 'EPIC 10 polish is the active wave',
      detail: 'Tasks 1010–1050 covering accessibility, responsiveness, states, performance, narrative',
      evidence: 'docs/tasks/02-doing/',
      riskLevel: InsightRiskLevel.low,
      connection: 'EPIC 10 blocks EPIC 11 (app shell)',
    ),
    DSStoryNarrativeInsight(
      text: 'No app shell or router exists yet',
      detail: 'main.dart, app.dart, router.dart are all absent',
      evidence: 'lib/',
      riskLevel: InsightRiskLevel.critical,
      connection: 'blocks all end-to-end polish verification',
    ),
    DSStoryNarrativeInsight(
      text: 'Flutter SDK is not installed on the build machine',
      detail: 'flutter analyze, flutter test, flutter run all blocked',
      riskLevel: InsightRiskLevel.critical,
      connection: 'blocks all validation commands',
    ),
  ],
)
```

**Fallback**: If lane board is not routable, `DSStoryPanel` serves as a static operations summary.

---

## Beat 3 — History: "Why did this change?"

**Core question**: What changed recently, why, and with what proof?

**Story panel configuration**:
```
DSStoryPanel(
  title: 'Change History',
  subtitle: 'Why things changed',
  icon: Icons.history_outlined,
  accentColor: DSColors.accentViolet,
  insights: [
    DSStoryNarrativeInsight(
      text: 'Design system normalized to 40-file atomic structure',
      detail: 'tokens → atoms → molecules → organisms → templates',
      evidence: 'lib/design_system/',
      riskLevel: InsightRiskLevel.none,
      connection: 'preceded by research.md atomic design recommendation',
    ),
    DSStoryNarrativeInsight(
      text: 'Data model superseded legacy models.dart',
      detail: 'workspace_graph.dart + task_contracts.dart + changelog_contracts.dart',
      evidence: 'lib/data/models/data_models.dart',
      riskLevel: InsightRiskLevel.low,
      connection: 'legacy models.dart kept for parser backward compat',
    ),
  ],
)
```

**Linked timeline**: `DSTimelineGrouped` should show changelog entries grouped by project/milestone. Each entry links back to the motivating task via `changedBy` edge.

---

## Beat 4 — Governance: "What is risky?"

**Core question**: What is canonical, generated, stale, or blocking?

**Story panel configuration**:
```
DSStoryPanel(
  title: 'Governance Diagnostics',
  subtitle: 'What is risky or stale',
  icon: Icons.shield_outlined,
  accentColor: DSColors.statusError,
  insights: [
    DSStoryNarrativeInsight(
      text: 'README.md is stale Next.js boilerplate',
      detail: 'References npm run dev, app/page.tsx from v0',
      evidence: 'README.md',
      riskLevel: InsightRiskLevel.high,
      connection: 'misroutes contributors; needs Flutter replacement',
    ),
    DSStoryNarrativeInsight(
      text: 'textTertiary color fails WCAG AA contrast',
      detail: '#606070 on #050508 yields ~2.7:1 (needs 4.5:1)',
      evidence: 'lib/design_system/tokens/ds_colors.dart',
      riskLevel: InsightRiskLevel.high,
      connection: 'Task 1010 owns the fix',
    ),
    DSStoryNarrativeInsight(
      text: 'No main.dart — app cannot compile',
      detail: 'No app shell, router, or page exists',
      evidence: 'lib/',
      riskLevel: InsightRiskLevel.critical,
      connection: 'blocks all end-to-end verification',
    ),
    DSStoryNarrativeInsight(
      text: 'Breakpoints scattered across 3+ files',
      detail: '1200px, 1000px, 800px hardcoded in shell, templates, timeline',
      evidence: 'lib/design_system/organisms/ds_shell.dart',
      riskLevel: InsightRiskLevel.medium,
      connection: 'Task 1020 centralizes into DSBreakpoints token',
    ),
  ],
)
```

---

## Beat 5 — Connections: "How do assets relate?"

**Core question**: Can the user trace a path from a task to the skill that governed it, to the workflow that executed it?

**Story panel configuration**:
```
DSStoryPanel(
  title: 'Asset Connections',
  subtitle: 'Navigable causality across the workspace',
  icon: Icons.hub_outlined,
  accentColor: DSColors.accentGold,
  insights: [
    DSStoryNarrativeInsight(
      text: 'Task → Workflow → Skill chains are traceable',
      detail: 'dependsOn, uses, contains edges connect all asset kinds',
      evidence: 'lib/data/models/workspace_graph.dart',
      riskLevel: InsightRiskLevel.none,
      connection: '7 edge kinds: contains, routesTo, dependsOn, references, changedBy, proves, uses',
    ),
    DSStoryNarrativeInsight(
      text: 'Changelog entries link back to motivating tasks',
      detail: 'changedBy edge type connects changelog → task',
      evidence: 'lib/data/models/changelog_contracts.dart',
      riskLevel: InsightRiskLevel.none,
      connection: 'Impact story view connects change → task → workflow → skill',
    ),
    DSStoryNarrativeInsight(
      text: 'Governance status is modeled as provenance',
      detail: '6 canonicality values: parentCanonical, childLocal, generated, appendOnly, archive, mock',
      evidence: 'lib/data/models/workspace_graph.dart',
      riskLevel: InsightRiskLevel.none,
      connection: 'DSColors.forCanonicity() maps provenance to color tokens',
    ),
  ],
)
```

---

## Narrative Contract Summary

The `DSStoryPanel` + `DSStoryNarrativeInsight` contract supports four required narrative layers:

| Layer | Field | Purpose |
|-------|-------|---------|
| **Insight** | `text`, `value`, `color` | What the data says |
| **Evidence** | `evidence` (file path or URL) | Where to verify the claim |
| **Risk** | `riskLevel` (none/low/medium/high/critical) | How dangerous the gap is |
| **Connection** | `connection` | How this insight relates to other assets or blocks |

This contract is testable without a running app: the model classes validate structurally, and the `DSStoryPanel` widget renders them via `flutter_test` widget tests.

---

## Workspace-to-Question Mapping

| Workspace | Questions Answered | Primary Surface | Secondary Surface |
|-----------|-------------------|-----------------|-------------------|
| Map | What exists? How do assets relate? | Graph canvas | Asset catalog |
| Operate | What matters now? | Lane board | Task detail |
| History | Why did this change? | Timeline | Changelog story |
| Governance | What is risky? What is stale? | Diagnostic panel | Provenance pills |

---

## Fallback Notes

1. **No app shell**: All beats are currently document-only. `DSStoryPanel` can be tested as a widget but cannot be navigated to.
2. **No Flutter SDK**: Validation commands (`flutter analyze`, `flutter test`) are blocked. Narrative contract is exercised via unit/widget tests once SDK is available.
3. **No pages directory**: All four workspaces (Map, Operate, History, Governance) lack page implementations. The narrative contract is page-independent.
4. **Legacy models.dart**: Still imports Flutter; new code targets `data_models.dart` barrel. No conflict for narrative work.
