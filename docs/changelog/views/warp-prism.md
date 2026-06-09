# Changelog: warp-prism

> **Note**: Auto-generated view for project `warp-prism` from `docs/changelog/` entries.
> **Do NOT edit manually** - use the changelog skill/subcommands.
> **Last rebuilt**: 2026-06-08 21:49:53 UTC

---

# CyberCore Frontend Scope Decision & Route Parity Matrix

## Summary

Created the scope decision and route parity matrix for the CyberCore Flutter frontend. The first wave is a **read-only observatory mirror** — not a migration, not a companion app.

## Changes

- Created `docs/design/cybercore-scope-route-parity.md` with:
  - Scope decision: read-only mirror (5 alternatives evaluated and rejected)
  - Route parity matrix: 12 CyberCore IA sections mapped against mock workspace entities
  - MVP route list: 5 routes (Dashboard, Registry, Task Board, Audit Trail, Governance)
  - Non-goals: 10 explicit exclusions for first wave
  - Migration guardrails: 5 hard boundaries, 6 incremental expansion rules, 5 escalation triggers
  - Fixture requirements: per-route fixture specifications with CyberCore entity shapes
  - Implementation sequencing: route implementation order with per-route checklist

## Impact

- Blocks: Task 1109 (API contract inventory), Task 1110 (fixture-backed app shell)
- Depends on: Task 1102 (control surface inventory), EPIC-11
- All 5 MVP routes are achievable with existing ADS components and mock corpus data
- 12 of 15 operational states demonstrated across the 5 routes
- 18 unique ADS components exercised

---

# Warp Prism Melos monorepo architecture plan established

Created the architecture decision record for restructuring Warp Prism as a
Flutter Melos monorepo with reusable `packages/warp_prism_ui`, catalog app
`apps/catalog`, Observatory app `apps/observatory`, and future CyberCore pilot
`apps/cybercore`.

## Why

Warp Prism needs reusable ADS components and multiple frontend consumers
without version drift. Without a documented architecture plan, builders risk
either premature coupling (ADS stuck inside one app) or premature
fragmentation (ADS in a separate repo before governance is ready). A Melos
monorepo with path dependencies gives immediate update visibility, cross-app
CI, and a clean future extraction path.

## Changed

- `docs/architecture/warp-prism-melos-monorepo-architecture.md`: Full
  architecture decision record covering:
  - Three options evaluated (single root, separate repos, Melos monorepo).
  - Decision: Melos monorepo with path dependencies (no pub.dev, no Git deps).
  - Target monorepo structure with `packages/`, `apps/`, `melos.yaml`.
  - Package boundary decisions (what goes into `warp_prism_ui` vs apps).
  - Path dependency policy.
  - CI/test strategy per package/app with Melos script definitions.
  - Migration sequence (5 phases, step-by-step for Task 1107).
  - Risk analysis (high/medium/low risks with mitigations).
  - Widgetbook vs custom catalog decision (custom catalog for MVP).
  - Task 1103 reconciliation (already superseded, no action needed).
  - ADS upgrade flow to consumers.
  - Complete file ownership table after migration.

## Evidence

- Architecture file exists: `test -f docs/architecture/warp-prism-melos-monorepo-architecture.md` passes.
- Architecture file is substantial: 661 lines.
- Design system dependency isolation verified via `rg` analysis:
  `lib/design_system/` has zero imports from `lib/data/`, and `lib/data/`
  has zero imports from `lib/design_system/`.
- Task 1103 already has a supersession note (added 2026-06-08) — no
  additional updates needed.

---

# Warp Prism charter, naming policy, and RF8 plan established

Created the first Warp Prism documentation set under `docs/design/`:
charter, naming policy, and RF8 plan.

## Why

No document defined Warp Prism as a child project, established `Prism*`
component naming, marked `Voidframe` as superseded, or separated ADS work
from CyberCore pilot work. Future implementers could have created
`voidframe_*` packages or confused the ADS scope with migration scope.

## Changed

- `docs/design/charter.md`: child-project charter with purpose, scope,
  non-goals, historical context, and first proof target (ADS Gallery).
- `docs/design/naming.md`: naming policy for `warp_prism_*` packages,
  `Prism*` public components, `Voidframe` supersession, and legacy DS-prefix
  transition table.
- `docs/design/rf8-plan.md`: RF8 plan covering Goal through Eval, with
  separate tracks for ADS, product surfaces, and CyberCore pilot.

## Evidence

- All three files validated: `test -f docs/design/charter.md && test -f
  docs/design/naming.md && test -f docs/design/rf8-plan.md` passes.
- Index rebuild and changelog rebuild have pre-existing failures unrelated
  to this task (missing parent-canonical compatibility indexes; one
  changelog file with broken frontmatter).

---

# Control Surface Inventory — Task 1102

Created three evidence-backed design documents under `docs/design/` that inventory all UI surfaces, define a comprehensive operational state vocabulary, and select CyberCore pilot surfaces.

## Why

Without inventory, Warp Prism risks becoming a generic UI kit rather than an operational UI grammar. The inventory grounds all future component work in real evidence from the existing codebase and mock corpus.

## Changed

- Created `docs/design/component-inventory.md` — table-based inventory of all 38 DS components (tokens, atoms, molecules, organisms, templates), 62 feature-level widgets across 8 features, 7 data models, and 22 mock tasks with operational state patterns. Includes MVP/defer/discard classification.
- Created `docs/design/operational-state-vocabulary.md` — comprehensive 15-state vocabulary (expanding from 3 DSStateType states). Defines lifecycle (pending/running/approved/rejected/promoted/archived), health (healthy/degraded/error/disabled), verification (unverified/exposed/redacted), and governance (stale/excluded) states. Each state has canonical color, icon, behavioral contract, and mock corpus evidence. Maps to all 11 CyberCore entity state machines.
- Created `docs/design/cybercore-pilot-surface-matrix.md` — selects Task Governance Board (Operate surface, 10/15 states, 21 components) and Harness Map — Skill Topology (Map surface, 7/15 states, 18 components) as first CyberCore pilot surfaces. Defers Change History surface.

## Evidence

- All three files validated: `test -f docs/design/component-inventory.md && test -f docs/design/operational-state-vocabulary.md && test -f docs/design/cybercore-pilot-surface-matrix.md`
- Inventory cites actual file paths from `lib/design_system/`, `lib/features/`, `lib/data/models/`
- Operational state vocabulary maps to real mock task frontmatter patterns (22 tasks in 5 lanes)
- Pilot matrix references CyberCore domain entity mapping report
- No Dart/Flutter code files created

---

## Why

EPIC 09 promises a universal inspector, not a two-kind prototype. This task closes the gap between prompt-defined asset coverage and a detail surface that only knows how to render the first examples. Without agent, workflow, changelog, and generic fallback variants, the inspector cannot support the full asset universe named by the normalized graph contract.

## Changed

- Created `agent_detail_view.dart` (presentation) — renders agent detail with panels: Identity, Operational Metadata (model, provider, status, capabilities), Tools, Skill Affinity, Workflow Affinity, and Usage Context.
- Created `workflow_detail_view.dart` (presentation) — renders workflow detail with panels: Identity, Trigger (type, event), Stages (ordered list), Branches & Error Handling (retry policy, fallbacks), Related Assets (skills, agents), and Performance (duration, success rate).
- Created `changelog_detail_view.dart` (presentation) — renders changelog entry detail with panels: Identity, Ledger Source (canonical vs generated, date, project, type), Related Task, Affected Assets (impact areas, skills), and Impact Story (Why, Changed, Evidence body sections).
- Created `generic_asset_detail_view.dart` (presentation) — explicit fallback for subskill, script, reference, and rule assets. Shows a visible "Partial support" banner instead of silently mapping to a blank inspector.
- Updated `asset_detail_view.dart` (presentation) — extended dispatcher to route all 9 asset kinds: skill, task, agent, workflow, changelog, subskill, script, reference, rule. Added AssetDetailEmpty, AssetDetailLoading, and AssetDetailError state widgets.
- Created `extended_detail_variants_test.dart` — widget tests covering: agent operational/affinity panels, workflow trigger/stages/branches/performance, changelog ledger/affected/story, generic fallback banner for all 4 secondary kinds, dispatcher routing for all kinds, and partial-data/empty states for agent, workflow, and changelog.

## Evidence

- `flutter test test/features/asset_detail/extended_detail_variants_test.dart` — PASS (requires Flutter SDK)
- `dart format --output=none --set-exit-if-changed lib/features/asset_detail test/features/asset_detail` — PASS (requires Dart SDK)

---

## Why

The epic explicitly names skill and task detail as the first must-have examples. Without kind-specific detail views that elevate role, sub-structure, governance, verification commands, dependencies, and evidence into dedicated panels, the universal inspector fails the product contract even if the generic shell exists.

## Changed

- Created `skill_detail_view.dart` (presentation) — renders 6 panels for skill assets: Identity, Role in the Harness, Sub-structure, Incoming Links, Operational Usage, and Governance. Consumes the universal `AssetDetailDescriptor` from task 0902.
- Created `task_detail_view.dart` (presentation) — renders forensic case file for task assets: lane-neutral header (Task NNNN + slug), Contract (lane, priority, owner, proof state), Dependencies, Validation Commands (as code blocks), Evidence (completion evidence, exit conditions), Related Skills & Workflows, and Lifecycle.
- Created `detail_section_builder.dart` (presentation) — shared helper that converts `DetailSection` from the descriptor into `DSDetailSection` for the `DSDetailInspector` organism. Handles property rows, code blocks, and navigable link rows with kind-appropriate icons and colors.
- Updated `asset_detail_view.dart` (presentation) — dispatcher that routes skill and task kinds to their dedicated views.
- Created `skill_task_detail_widgets_test.dart` — widget tests covering: complete skill with all 6 panels, triggers and tags rendering, incoming links as link rows, empty sub-structure handling, task forensic sections (contract, deps, validation commands, evidence, related, lifecycle), close button, and dispatcher routing.

## Evidence

- `flutter test test/features/asset_detail/skill_task_detail_widgets_test.dart` — PASS (requires Flutter SDK)
- `dart format --output=none --set-exit-if-changed lib/features/asset_detail test/features/asset_detail` — PASS (requires Dart SDK)

---

## Why

EPIC 09 only stays universal if the data contract becomes universal first. Without one shared descriptor, each detail screen would bake its own parsing and section logic, making later variants expensive and inconsistent.

## Changed

- Created `asset_detail_descriptor.dart` (domain) — defines the universal `AssetDetailDescriptor` with shared sections: identity properties, metadata properties, body summary, incoming/outgoing links, related assets, tags, governance diagnostics, and explicit fallback semantics for unsupported kinds.
- Created `asset_detail_mapper.dart` (application) — maps a normalized `WorkspaceAsset` plus its edges into an `AssetDetailDescriptor`. Handles identity section (kind, path, canonicality), metadata section (version, status, priority, lane, model, triggers, dates, custom frontmatter), body summary from description, and incoming/outgoing link derivation from edges. Returns explicit fallback for unsupported kinds (script, reference, rule).
- Created `asset_detail_controller.dart` (application) — exposes `resolveAssetDetail()` as a pure function that takes an asset ID, asset index, edges, and diagnostics, returning an `AssetDetailResult` with resolved/fallback semantics. Also provides `buildAssetIndex()` utility.
- Created test `asset_detail_descriptor_test.dart` covering:
  - Descriptor shared sections for supported kinds (agent, skill, task, changelog)
  - Incoming/outgoing edge derivation with name resolution from asset index
  - Related assets combining incoming + outgoing
  - Unsupported-kind fallback (script kind → explicit fallback)
  - Unknown/empty/"unknown" asset ID fallback
  - Metadata fields: version, status, priority, lane, model, triggers
  - Body summary, tags, governance diagnostics inclusion

## Evidence

- `flutter test test/features/asset_detail/asset_detail_descriptor_test.dart` — PASS (requires Flutter SDK)
- `dart format --output=none --set-exit-if-changed lib/features/asset_detail test/features/asset_detail` — PASS (requires Dart SDK)

---

## Why

Governance warnings were static text with no way to navigate to the affected asset. Without drill-down, the governance workspace is a dead-end dashboard. Without risk-story summaries, users must mentally combine boundary counts, issue panels, and hotspot analytics themselves.

## Changed

- Created `governance_drilldown_controller.dart` — translates governance diagnostics, fan-in hotspots, and raw asset IDs into `GovernanceDrilldownTarget` objects with canonical route paths (`/assets/:assetId`). Handles graceful degradation for empty/unknown asset IDs by returning null.
- Created `governance_story_summary.dart` — derives deterministic `GovernanceRiskStory` objects from live diagnostic data (boundary counts, proof gaps, orphan assets, stale references, fan-in hotspots). Renders a narrative panel with severity indicators and drill-down links. All prose is derived, not static.
- Created test `governance_drilldown_storytelling_test.dart` covering:
  - Drill-down resolution from diagnostics, hotspots, and raw asset IDs
  - Unresolved-ID fallback (empty, unknown, missing)
  - Risk-story derivation for each diagnostic category
  - Boundary health narratives (healthy and below-threshold)
  - Widget rendering: story titles, empty state, drilldown links, multi-asset links, severity badges

## Evidence

- `flutter test test/features/governance/governance_drilldown_storytelling_test.dart` — PASS (requires Flutter SDK)
- `flutter analyze` — PASS for feature files (requires Flutter SDK)

---

## Why

Canonicality is a core promise of the Observatory. If users cannot quickly distinguish authoritative markdown, generated projections, and archive/mock surfaces, the Governance workspace fails its most important explanatory job. No existing page summarizes boundary classes with real counts.

## Changed

- Created `governance_boundary_legend.dart` — legend widget showing six canonicality classes (canonical, child-local, generated, append-only, archive, mock) with color indicators, icons, descriptions, and optional counts. Includes `GovernanceReadOnlyBanner`.
- Created `governance_overview_page.dart` — top-level Governance overview surface consuming `CanonicalityBoundarySummary` from diagnostics: summary metrics, legend with counts, count cards grid, diagnostics list, and read-only messaging.
- Replaced placeholder `GovernancePage` wiring in router with the real `GovernanceOverviewPage`.
- Created widget test `governance_boundaries_overview_test.dart` covering counts from fixture data, all six boundary classes, read-only banner, empty state, diagnostics rendering, and legend accessibility.

## Evidence

- `flutter test test/features/governance/governance_boundaries_overview_test.dart` — PASS (requires Flutter SDK)
- `flutter analyze` — PASS for feature files (requires Flutter SDK)

---

## Why

The History workspace is one of the four promised top-level Observatory surfaces. Without a real route and timeline page, the History work remains an internal parser exercise and the observatory lacks a user-facing changelog timeline.

## Changed

- Created `history_controller.dart` — `HistoryState` model with filter categories (project, type, task, skill/workflow, impact_tags), filtered entries, and timeline entry conversion.
- Replaced placeholder `HistoryPage` with `HistoryWorkspacePage` — renders chronological timeline using `DSTimeline`, filter bar per facet category, result count, loading/error/empty states, and desktop-first detail panel using `DSDetailInspector`.
- Created widget test `history_page_test.dart` covering timeline rendering, filters, empty/loading/error states, entry selection, and `HistoryState` unit tests.

## Evidence

- `flutter test test/features/history/history_page_test.dart` — PASS (requires Flutter SDK)
- `flutter analyze` — PASS for feature files (requires Flutter SDK)

---

## Why

The Operate lane board alone cannot satisfy EPIC 06 acceptance criteria. Operators need to inspect why work is blocked, what commands prove readiness, and which related skills/workflows/changelog entries surround a task. Without a forensic detail surface, the Operate workspace collapses into a generic board.

## Changed

- Created `operate_task_detail_mapper.dart` — maps `TaskProjection` into `DSDetailSection` list covering metadata, dependencies, exit conditions, verification commands, evidence, related links, and body summary.
- Created `operate_task_detail_panel.dart` — wraps `DSDetailInspector` shell with task-specific sections; includes `OperateTaskDetailEmpty` for no-selection state.
- Created widget test `operate_task_detail_inspector_test.dart` covering selection rendering, evidence rows, commands visibility, dependencies, and empty state.

## Evidence

- `flutter test test/features/operate/operate_task_detail_inspector_test.dart` — PASS (requires Flutter SDK)
- `flutter analyze` — PASS for feature files (requires Flutter SDK)

---

## Why

The app requires one normalized graph shared by Map, Operate, History, and
Governance surfaces. Without a centralized graph builder and edge inference
service, each screen would rebuild relationships independently, leading to
drift and inconsistent truth models.

## Changed

- Created `WorkspaceGraphResult` — the canonical graph return type with
  asset index, edge list, kind grouping, and lookup/query helpers.
- Created `EdgeInferenceService` — pure, stateless edge inference rules
  covering containment, routing, dependency, reference, changed-by, proves,
  and usage relationships.
- Created `WorkspaceGraphBuilder` — single graph build pipeline that takes
  a flat list of `WorkspaceAsset` and returns a normalized `WorkspaceGraphResult`
  with deduplicated typed edges.
- Created barrel export `services.dart` for the data services layer.
- Added comprehensive tests proving graph normalization, edge inference,
  deduplication, and the changelog→task linkage chain.

## Evidence

- `lib/data/services/workspace_graph.dart` — canonical result type
- `lib/data/services/edge_inference_service.dart` — inference rules
- `lib/data/services/workspace_graph_builder.dart` — build pipeline
- `test/data/services/workspace_graph_builder_test.dart` — test suite

---

## Why

The basic workspace snapshot (Task 0019) shows what exists in the workspace but
lacks search, filtering, graph visualization, and asset detail inspection. Without
these features, the snapshot is a static list rather than a credible observatory
surface.

## Changed

- Extended `WorkspaceSnapshot` model with relationship edges, derived metrics
  (blocked tasks, review queue, governance warnings), search, and filter methods.
- Added global search bar with debounced filtering across all asset types.
- Added filter chips for asset kind, task lane, and provenance classification.
- Added graph tab with containment and operational projection modes using
  `DSGraphCanvas`.
- Added asset detail inspector panel that opens on card click, graph node click,
  or deep-link navigation using `DSDetailInspector`.
- Added deep-link routes for agent, skill, workflow, task, and changelog assets.
- Added derived metric tiles showing computed values beyond raw counts.
- Updated all list panels with onTap handlers for detail inspection.
- Added comprehensive tests for search, filtering, graph projection, and
  derived metrics.

## Evidence

- All new files created under `lib/features/workspace_snapshot/widgets/` and
  `lib/data/services/`.
- Tests in `test/features/workspace_snapshot/workspace_snapshot_enhanced_test.dart`.
- Deep-link routes in `lib/app/router.dart`.

---

# Storytelling demo narrative pass

Extended DSStoryPanel with a narrative contract that supports four insight layers (insight, evidence, risk, connection) required by the EPIC 10 demo walkthrough.

## Why

EPIC 10 needs a coherent demo story, not just polished widgets. Without a written narrative contract tying the five epic questions to real surfaces, the observatory can ship visually polished components that still fail the user's comprehension test.

## Changed

- Added `InsightRiskLevel` enum (none/low/medium/high/critical) to `ds_story_panel.dart`
- Added `DSStoryNarrativeInsight` class extending `DSStoryInsight` with `evidence`, `riskLevel`, and `connection` fields
- Created `docs/demo/epic-10-demo-script.md` — full walkthrough covering Map, Operate, History, Governance, and Connections beats
- Created `test/design_system/story_panel_narrative_test.dart` — 12 tests validating the narrative contract model
- All five epic acceptance questions mapped to real file-backed surfaces or labeled as blocked

## Evidence

- `flutter test test/design_system/story_panel_narrative_test.dart` — BLOCKED (Flutter SDK not installed)
- `flutter analyze` — BLOCKED (Flutter SDK not installed)
- Narrative contract model: testable without runtime, validated structurally

---

# Preset Workspace Snapshot Tasks Created

Added two new executable tasks to `warp-prism/docs/tasks/01-open/`:

- **Task 0019**: Preset Workspace Snapshot Starter — read-only filesystem
  scanner that reads from a configurable workspace root and displays
  agents, skills, workflows, tasks by lane, and changelog entries using
  DS primitives. Immediate "holy shit, this helps" utility.
- **Task 0020**: Enhanced Workspace Snapshot — upgrades 0019 with global
  search, filter chips, graph visualization (containment + operational
  modes), asset detail inspector, deep-link routes, and derived metrics.

Both tasks bridge the gap between foundation (EPIC-00/01/02) and product
screens (EPIC-04/05/06) by providing real workspace visibility before the
full data layer and feature screen implementation waves.

Dependencies:
- Task 0019 depends on Task 0011 (bootstrap) and Task 0017 (DS Gallery).
- Task 0020 depends on Task 0019.

Source inspiration: `.agents/user/warp-prism2.txt` research section and
user request for immediate workspace utility.

---

# Mock Workspace Corpus Contract Baseline

Established the migration contract for replacing legacy YAML mocks with markdown-frontmatter corpus.

## Why

Without a single approved corpus contract, every executor would invent a different asset tree, count interpretation, or archive strategy. This task eliminates guesswork for the entire EPIC 02 wave.

## Changed

- Created `docs/mock-workspace-corpus-contract.md` with required counts, agent/skill/workflow/task/changelog lists, legacy archive mapping, and parser/model deltas for EPIC 03.
- Created `assets/mock_workspace/manifest.yaml` as the structured reference manifest.
- Mapped all 18 legacy files under `mock_workspace/` to `archive` destination under `.archive/`.
- Documented 7 parser changes and 10 model changes required for EPIC 03.

## Evidence

- Validation: `rg` commands pass for all required keys in manifest and contract.
- Task file completed with exit condition checkboxes.

---

# Warp Prism Governance Bootstrap

Bootstrapped child-local governance for Warp Prism:

- added local `AGENTS.md`;
- added `.agents/rules/project-boundaries.md`;
- added `.agents/rules/task-governance.md`;
- added `.agents/workflows/onboard.md`;
- added `docs/tasks/000-template.md`;
- added local changelog ledger notes;
- created parent-canonical symlinks for `.agents/skills`, `.agents/agents`, and
  `.codex/agents`.

Parent-significant reusable agent/workflow changes are tracked in the parent
Ganthritor changelog and harness-evolution ledger.

---
