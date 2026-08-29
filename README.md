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

All public ADS components exported by `warp_prism_ui` use the **`Prism*`** prefix.
Import `package:warp_prism_ui/warp_prism_ui.dart` and use the live public aliases
from `packages/warp_prism_ui/lib/src/prism_aliases.dart`:

| Layer | Convention | Live public examples |
|-------|------------|----------------------|
| Tokens | `Prism*` token classes | `PrismColors`, `PrismTypography`, `PrismSpacing` |
| Atoms | `Prism` + noun | `PrismText`, `PrismIcon`, `PrismBadge`, `PrismGlassPanel` |
| Molecules | `Prism` + compound noun | `PrismAssetCard`, `PrismMetricTile`, `PrismSearchBar` |
| Organisms | `Prism` + descriptive noun | `PrismShell`, `PrismSidebar`, `PrismGraphCanvas`, `PrismLaneBoard` |

Live template widget `MasterDetailTemplate` exists under
`packages/warp_prism_ui/lib/src/templates/` but is **not** yet exported as a
`Prism*` alias in `prism_aliases.dart`. Prefer the organisms above for consumer
layout until a `Prism*` template alias is added.

There is no `PrismTokens` namespace in the live package. Token access is through
the discrete classes above (for example `PrismColors.obsidianDeep`,
`PrismSpacing.md`, `PrismTypography.displayLarge`).

The existing codebase also has `DS*`/`Ds*`-prefixed classes from a prior
generation. These are internal implementation details. `Prism*` is the public
barrel surface for consumer apps.

## Setup

```bash
# From the warp-prism/ directory:

# 1. Resolve workspace packages (Melos is a root dev_dependency)
dart pub get

# 2. Bootstrap path packages via repository-local Melos
#    (do not require a global `melos` binary)
dart run melos bootstrap

# 3. Run the Observatory app (from its own directory)
cd apps/observatory && flutter run -d linux

# 4. Run the ADS catalog / gallery (Storybook-class proof surface)
#    Thin shell over DesignSystemGalleryPage in warp_prism_ui.
#    Includes the Theme Editor (PrismThemeEditor) for visual convergence.
cd apps/catalog && flutter run -d linux
```

> **Common pitfall:** `flutter run` must be executed **inside** an app directory
> (`apps/catalog/`, `apps/observatory/`, `apps/cybercore/`), not from the monorepo
> root `warp-prism/`. Running from the root yields `Target file "lib/main.dart" not found`
> because the root has no `lib/main.dart` — each app owns its own entry point.
> From the root you can alternatively run `flutter run -d linux -t apps/catalog/lib/main.dart`.

**ADS visibility**: There is **no Widgetbook** in MVP (deferred by design policy).
The custom catalog app (`apps/catalog`) and Observatory route `/design-system`
are the surfaces for showing components to stakeholders. See
`docs/design/token-theme-catalog-policy.md` and EPIC-15/16 planning notes.

**Prerequisites**: Flutter SDK with Dart `^3.12.0`. Melos `^7.0.0` is declared
in the root `pubspec.yaml` `dev_dependencies`; invoke it with `dart run melos`
so no global activation is required.

## Validation

Run from the `warp-prism/` root using repository-local Melos:

```bash
# Static analysis across all packages and apps
dart run melos run analyze

# Run tests across all packages and apps
dart run melos run test

# Full CI gate (format + analyze + test)
dart run melos run validate
```

Per-package test commands:

| Command | Scope |
|---------|-------|
| `dart run melos run test-ui` | `warp_prism_ui` only |
| `dart run melos run test-observatory` | Observatory app only |
| `dart run melos run test-catalog` | Catalog app only |
| `dart run melos run test-cybercore` | CyberCore app only |
| `dart run melos run test-boundaries` | Pure-Dart boundary harness |

### Validation baseline (expected residual)

These commands are the **documented gate**, not a claim that every package is
currently green. Live inventory is owned by Task 0010 and related reports under
`docs/reports/`. Do **not** invent alternate bootstrap paths outside
`warp-prism/`.

| Surface | Live expectation (2026-07-10) | Notes |
|---------|--------------------------------|-------|
| Flutter/Dart SDK | Installed (`Flutter 3.44.1` / `Dart 3.12.1`) | Historical "SDK missing" blockers are superseded |
| Workspace bootstrap | `dart pub get` + `dart run melos bootstrap` | Repository-local Melos; no global `melos` binary required |
| `apps/catalog` analyze | Clean (0 issues) | Green scoped surface |
| `apps/cybercore` analyze | Clean (0 issues) | Green scoped surface |
| `packages/warp_prism_ui` analyze | **INFO lint residual** on `lib/` (**0 ERROR**, 0 WARNING; **8 INFO** as of 2026-07-18) | Lint debt only; not a compile-blocker. Exact INFO counts drift — severity class is the contract. |
| `apps/observatory` analyze | **INFO lint residual** on `lib/` (**0 ERROR**, 0 WARNING; **36 INFO** as of 2026-07-18) | Live EXIT 0; prefer_const_* style debt. Historical ERROR inventory (Task 0010) is superseded. Strict “0 issues” policies that treat INFO as failures may still flag this — **not** a RED ERROR package gate |
| Boundary harness | `dart run melos run test-boundaries` → **7/7 PASS** | Architectural enforcement only |
| Full `dart run melos run test` / package-green | **Not claimed** | See `docs/reports/warp-prism-test-failure-baseline.md` and `docs/reports/0010-warp-prism-foundation-audit-analyzer-baseline.md` |

Canonical baseline report:
`docs/reports/0010-warp-prism-foundation-audit-analyzer-baseline.md`.

## Mock Workspace Corpus

The Observatory app bundles a markdown-frontmatter corpus under
`apps/observatory/assets/mock_workspace/` (declared in
`apps/observatory/pubspec.yaml`). There is no root-level `assets/mock_workspace/`.

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
