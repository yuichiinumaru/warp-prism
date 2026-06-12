# Warp Prism

**ASW Observatory + CyberCore Pilot** — a Melos monorepo containing a reusable
Flutter Atomic Design System (`warp_prism_ui`), a read-only Agent System
Workspace Observatory, an ADS catalog/gallery, and a CyberCore pilot app.

Warp Prism turns mock ASW data (agents, skills, workflows, tasks, changelog)
into a high-polish, desktop-first observability console with lane boards, graph
visualization, and detail inspectors. The reusable design system package
(`warp_prism_ui`) is consumed by all apps.

## Monorepo Structure

```
warp-prism/                             # Melos workspace root (Dart 3.12 + Melos 7)
  pubspec.yaml                          # Workspace manifest + Melos config
  packages/
    warp_prism_ui/                      # Reusable Flutter ADS (app-agnostic)
  apps/
    observatory/                        # ASW Observatory (warp_prism_observatory)
    catalog/                            # ADS gallery/storybook (warp_prism_catalog)
    cybercore/                          # CyberCore pilot (warp_prism_cybercore)
  docs/
    tasks/                              # Task governance (5 lanes)
    reports/                            # Audit and analysis reports
    changelog/                          # Local changelog
    architecture/                       # Architecture decision records
    design/                             # Charter, naming policy, planning
  .agents/
    profiles/                           # Agent continuity
    rules/                              # Governance rules
    skills/                             # Parent-canonical skills (symlinked)
    workflows/                          # Local + parent workflows
```

### Packages

| Package | Directory | Role |
|---------|-----------|------|
| `warp_prism_ui` | `packages/warp_prism_ui/` | Reusable Flutter ADS — tokens, atoms, molecules, organisms, templates. Only depends on `flutter` SDK. |
| `warp_prism_observatory` | `apps/observatory/` | ASW Observatory app. Reads mock workspace data, renders Map/Operate/History/Governance surfaces. |
| `warp_prism_catalog` | `apps/catalog/` | ADS catalog/gallery app. Proof surface for the design system. |
| `warp_prism_cybercore` | `apps/cybercore/` | CyberCore pilot. Fixture-backed Flutter mirror of selected CyberCore admin surfaces. |

## Stack

| Layer | Where | Technology |
|-------|-------|-----------|
| Workspace | Root | Dart 3.12, Melos 7 |
| Design System | `packages/warp_prism_ui/` | Flutter (zero external dependencies) |
| Observatory | `apps/observatory/` | Flutter, go_router, flutter_riverpod, graphview, fl_chart, yaml, intl, collection |
| Catalog | `apps/catalog/` | Flutter (imports `warp_prism_ui`) |
| CyberCore | `apps/cybercore/` | Flutter, go_router, intl, collection (imports `warp_prism_ui`) |

## Design System Naming

All public ADS components exported by `warp_prism_ui` use the **`Prism*`** prefix:

| Layer | Convention | Examples |
|-------|------------|----------|
| Tokens | `PrismTokens.*` | `PrismTokens.colors`, `PrismTokens.typography`, `PrismTokens.spacing` |
| Atoms | `Prism` + noun | `PrismText`, `PrismIcon`, `PrismBadge`, `PrismGlassPanel` |
| Molecules | `Prism` + compound noun | `PrismAssetCard`, `PrismMetricTile`, `PrismSearchBar` |
| Organisms | `Prism` + descriptive noun | `PrismShell`, `PrismSidebar`, `PrismGraphCanvas`, `PrismLaneBoard` |
| Templates | `Prism` + layout | `PrismMasterDetailTemplate` |

The existing codebase also has `DS*`/`Ds*`-prefixed classes from a prior
generation. These are treated as legacy aliases. `Prism*` is canonical for all
new work and re-exports from `warp_prism_ui`.

## Setup

```bash
# From the warp-prism/ directory:

# 1. Bootstrap the workspace (resolve all path dependencies)
dart pub get
melos bootstrap

# 2. Run the Observatory app
cd apps/observatory && flutter run
```

**Prerequisites**: Flutter SDK >=3.12 and `melos` installed globally:

```bash
dart pub global activate melos
```

## Validation

Run from the `warp-prism/` root:

```bash
# Static analysis across all packages and apps
melos run analyze

# Run tests across all packages and apps
melos run test

# Full CI gate (format + analyze + test)
melos run validate
```

Per-package test commands:

| Command | Scope |
|---------|-------|
| `melos run test-ui` | `warp_prism_ui` only |
| `melos run test-observatory` | Observatory app only |
| `melos run test-catalog` | Catalog app only |

## Mock Workspace Corpus

The Observatory app bundles a markdown-frontmatter corpus under
`assets/mock_workspace/` used to render workspace data:

- **9 agents** — orchestrator and reviewer roles
- **13 skills** — organized as super-skills with sub-skills, workflows, references, and scripts
- **11 workflows** — orchestration and governance pipelines
- **20+ tasks** — distributed across 5 lanes (planning, open, doing, review, completed)
- **12+ changelog entries** — with frontmatter metadata and evidence sections

See `docs/mock-workspace-corpus-contract.md` for the full corpus specification.

## Documentation

- `docs/design/charter.md` — project charter, scope, and non-goals
- `docs/design/naming.md` — naming policy (`Prism*` prefix, package names, Voidframe supersession)
- `docs/architecture/warp-prism-melos-monorepo-architecture.md` — monorepo architecture decision record
- `docs/mock-workspace-corpus-contract.md` — mock workspace corpus migration contract
- `docs/tasks/` — task governance (5-lane board)
- `docs/reports/` — audit and analysis reports
- `docs/changelog/` — local changelog
