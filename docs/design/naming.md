# Warp Prism — Naming Policy

> **Status**: Active policy
> **Author**: Task 1101 — Warp Prism Charter And Naming Convergence
> **Date**: 2026-06-08

---

## 1. Overview

This document defines the naming policy for Warp Prism packages, public
components, and historical references. It exists to prevent naming drift,
duplicate packages, and false migrations — especially the accidental
resurrection of the superseded `Voidframe` codename.

---

## 2. Project and Product Names

| Name | Type | Usage |
|------|------|-------|
| **Warp Prism** | Project name | Used in task titles, docs, commits, and governance references. Always two words. |
| **ASW Observatory** | Product name | The Flutter observability console that Warp Prism produces. |
| **`warp-prism`** | Directory name | Top-level directory in the Ganthritor repo. |
| **`warp_prism`** | Dart/Flutter package prefix | All Dart packages use snake_case with this prefix. |

---

## 3. Package Names

These package names are **canonical** for the Warp Prism child project.
Task 1104 will formalize the Melos monorepo layout; this section defines the
names before the scaffold exists.

| Package | Role | Status |
|---------|------|--------|
| `warp_prism_ui` | Reusable Flutter Atomic Design System. Tokens, atoms, molecules, organisms, templates. App-agnostic. | Planned — Task 1104+ |
| `warp_prism_catalog` | Gallery/catalog app that validates `warp_prism_ui` with stories, golden tests, widget tests, and semantics coverage. | Planned — Task 1104+ |
| `warp_prism_observatory` | ASW Observatory Flutter app. Reads mock workspace data, renders Map/Operate/History/Governance surfaces. | Planned — Task 1107+ |
| `warp_prism_cybercore` | Cybernetics Core pilot app. Fixture-backed Flutter mirror of selected CyberCore admin surfaces. Not a migration. | Planned — Task 1110+ |

### Rules

1. **No other `warp_prism_*` package names** may be introduced without a task
   that explicitly adds them to this document.
2. **No `voidframe_*` package names** may be created. See §5 below.
3. All packages must use **snake_case** per Dart convention.

---

## 4. Public Component Names

### 4.1 Prefix: `Prism`

All public widgets, atoms, molecules, organisms, and templates exported by
`warp_prism_ui` use the `Prism` prefix.

| Layer | Naming Convention | Examples |
|-------|-------------------|----------|
| Tokens | `PrismTokens` namespace | `PrismTokens.colors`, `PrismTokens.typography`, `PrismTokens.spacing` |
| Atoms | `Prism` + noun | `PrismText`, `PrismIcon`, `PrismBadge`, `PrismChip`, `PrismStatusDot`, `PrismGlassPanel` |
| Molecules | `Prism` + compound noun | `PrismAssetCard`, `PrismMetricTile`, `PrismProvenancePill`, `PrismSearchBar` |
| Organisms | `Prism` + descriptive noun | `PrismShell`, `PrismSidebar`, `PrismGraphCanvas`, `PrismLaneBoard`, `PrismTimeline` |
| Templates | `Prism` + layout name | `PrismMasterDetailTemplate` |
| Theme extensions | `PrismTheme` + qualifier | `PrismThemeColors`, `PrismThemeTypography` |

### 4.2 Legacy DS-Prefixed Classes

The existing codebase uses `DS`/`Ds`-prefixed class names (e.g., `DSColors`,
`DsShell`, `DSSidebar`). These names were created by the v0 generation before
this naming policy existed.

**Policy**: When code is refactored or a component is re-exported from
`warp_prism_ui`, the `Prism` prefix is canonical. Existing `DS`/`Ds` names
may remain as compatibility aliases during transition but must not be
extended with new variants.

| Existing Class | Canonical Public Name |
|----------------|----------------------|
| `DSColors` / `DsColors` | `PrismTokens.colors` |
| `DSTypography` / `DsTypography` | `PrismTokens.typography` |
| `DSSpacing` / `DsSpacing` | `PrismTokens.spacing` |
| `DSShell` / `DsShell` | `PrismShell` |
| `DSSidebar` / `DsSidebar` | `PrismSidebar` |
| `DSTopbar` / `DsTopbar` | `PrismTopbar` |
| `DsGraphCanvas` | `PrismGraphCanvas` |
| `DsLaneBoard` | `PrismLaneBoard` |

> **Note**: Actual rename is deferred to task execution. This table defines
> the target naming, not a rename task. Do not rename classes in this task.

---

## 5. Voidframe — Historical Naming (Superseded)

### 5.1 Status

**Voidframe is historical naming only.** It was the original codename for the
Flutter ADS concept before the project became Warp Prism.

### 5.2 Evidence

| Historical Task | Contribution | Current Status |
|-----------------|--------------|----------------|
| Task 8210 | Control-surface inventory | Uses Voidframe naming; remains as provenance evidence |
| Task 8220 | Voidframe Flutter ADS kernel concept | Superseded by Warp Prism ADS planning |
| Task 8230 | CyberCore pilot concept under Voidframe | Superseded by EPIC-11 |

### 5.3 Rules

1. **Do not create** any new `voidframe_*` Dart packages, directories, or
   public API surfaces.
2. **Do not rename or delete** historical files that reference Voidframe
   (e.g., Task 8210, Task 8220, Task 8230). They are provenance.
3. **Do not use** `Voidframe` in new documentation, task titles, or commit
   messages. Use `Warp Prism` instead.
4. When citing historical Voidframe tasks, **always annotate** them as
   superseded (e.g., "Task 8220 — Voidframe ADS kernel concept (superseded)").

---

## 6. Feature Directory Names

Feature directories under `lib/features/` use snake_case and are named after
the observatory surface or domain concept they serve:

| Directory | Surface | Notes |
|-----------|---------|-------|
| `map/` | Harness Map | Agents, skills, workflows, graph views |
| `operate/` | Operate | Task lanes, blockers, proof state |
| `history/` | History | Changelog timeline, story mode |
| `governance/` | Governance | Diagnostics, drift, canonicality |
| `asset_detail/` | Asset Detail | Universal detail surface |
| `overview/` | Overview | Dashboard with derived metrics |
| `shell/` | Shell | App shell, navigation, layout |
| `workspace_snapshot/` | Workspace Snapshot | Legacy composite view (may be decomposed) |

Feature directories must not introduce package-level naming; they are
internal to the consuming app.

---

## 7. Mock Data Asset Names

Mock workspace files follow `docs/mock-workspace-corpus-contract.md`:

- **Agents**: `assets/mock_workspace/.agents/agents/<name>.md`
- **Skills**: `assets/mock_workspace/.agents/skills/<name>/SKILL.md`
- **Workflows**: `assets/mock_workspace/.agents/workflows/<name>.md`
- **Tasks**: `assets/mock_workspace/docs/tasks/<lane>/<file>.md`
- **Changelog**: `assets/mock_workspace/docs/changelog/<file>.md`

All mock files use `.md` extension with YAML frontmatter delimited by `---`.
Historical YAML-only mocks are archived under `archive/mock_workspace/`.

---

## 8. Enforcement

- **Task review**: Reviewers should reject tasks that introduce unregistered
  package names or use `voidframe_*` prefixes.
- **Lint rule (future)**: A project-level lint rule may enforce `Prism` prefix
  usage in `warp_prism_ui` exports. Not implemented in this task.
- **Naming doc updates**: When a new package is created, this document must
  be updated in the same task.

---

## 9. Source Evidence

| Source | Relevance |
|--------|-----------|
| `docs/tasks/00-planning/1100-...epic.md` | Defines `Prism*` naming and `warp_prism_*` package names |
| `docs/tasks/00-planning/EPIC-11-...cybercore-frontend.md` | Defines `warp_prism_cybercore` pilot |
| `docs/tasks/00-planning/ROADMAP-...md` | Local governance naming conventions |
| Task 8220 (historical, superseded) | Original Voidframe naming |
| Task 8230 (historical, superseded) | Voidframe-era CyberCore pilot |
| `docs/mock-workspace-corpus-contract.md` | Mock data file naming |
