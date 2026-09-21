# Warp Prism — Melos Monorepo Architecture Plan

> **Status**: Active architecture decision record
> **Author**: Task 1104 — Warp Prism Melos Monorepo Architecture Plan
> **Date**: 2026-06-08
> **Depends on**: Task 1101 (charter/naming), Task 1102 (control-surface inventory)
> **Blocks**: Task 1105 (token/theme/catalog policy), Task 1107 (Melos migration), Task 1110 (CyberCore app shell)

---

## 1. Problem Statement

Warp Prism currently exists as a single Flutter app at the `warp-prism/` child-project root. The `pubspec.yaml` declares `asw_observatory` as its package name, and all code — design system tokens, atoms, molecules, organisms, templates, gallery, data layer, features, app shell, and routing — lives under one `lib/` tree with one `test/` tree.

The charter (Task 1101) and epic (Task 1100) call for:

1. A **reusable Flutter ADS package** (`warp_prism_ui`) that is app-agnostic and usable by multiple frontend consumers.
2. A **catalog/gallery app** (`warp_prism_catalog` or `apps/catalog`) that validates ADS components with stories, golden tests, and semantics coverage.
3. The **ASW Observatory app** (`apps/observatory`) as the first consumer.
4. A future **CyberCore pilot app** (`apps/cybercore`) as a second consumer.

Without a documented architecture and migration plan, builders risk one of two failure modes:

- **Premature coupling**: ADS components stay inside the Observatory app and become impossible to reuse without circular imports.
- **Premature fragmentation**: ADS is extracted into a separate GitHub repository before the monorepo governance is ready, creating version drift, CI blind spots, and update friction.

This document evaluates three options, selects one, and defines the target monorepo structure, package boundaries, dependency policy, CI/test strategy, migration sequence, and risk analysis.

---

## 2. Options Evaluated

### Option A: Single App Root (Status Quo)

**Description**: Keep the current single `pubspec.yaml` at `warp-prism/` root. Design system, data layer, features, and app shell remain in one `lib/` tree.

| Criterion | Assessment |
|-----------|------------|
| ADS reuse | ❌ Cannot be imported by other apps without importing the entire Observatory app. |
| Cross-app CI | ❌ No mechanism to test ADS changes against multiple consumers. |
| Versioning | N/A — single package. No version drift, but no reuse either. |
| Frontend specialization | ❌ CyberCore pilot must either duplicate ADS code or couple to the Observatory app. |
| Future extraction | ❌ Extracting later means a large, risky migration with no prior boundary validation. |
| Migration cost | ✅ Zero — nothing changes. |

**Verdict**: Rejected. Fails the core requirement of reusable ADS.

### Option B: Separate GitHub Repositories

**Description**: Create three or four separate Git repositories (e.g., `warp-prism-ui`, `warp-prism-observatory`, `warp-prism-catalog`, `warp-prism-cybercore`) with published or Git-based dependencies between them.

| Criterion | Assessment |
|-----------|------------|
| ADS reuse | ✅ Clean import boundaries. Each repo has its own pubspec. |
| Cross-app CI | ⚠️ Requires separate CI pipelines. ADS changes need a publish-then-update cycle for consumers. Cross-repo CI is possible but complex. |
| Versioning | ⚠️ ADS must be published to pub.dev or referenced via Git URLs. Version bump friction for rapid iteration. |
| Frontend specialization | ✅ Each consumer is independent. |
| Future extraction | ✅ Already extracted. |
| Migration cost | ❌ High — requires setting up multiple repos, CI pipelines, pub.dev or Git publishing, and coordinating version updates across all consumers. |
| Simplicity | ❌ Violates the simplicity pass requirement. Overhead too high for early-stage ADS that is still being defined. |

**Verdict**: Rejected for MVP. Too much infrastructure overhead for an ADS that has not yet been validated against its first two consumers. Revisit after Task 1111 (expansion gate) if ADS is proven and consumers are stable.

### Option C: Melos Monorepo with Path Dependencies ✅

**Description**: Introduce [Melos](https://melos.invertase.dev/) at the `warp-prism/` root. Create `packages/warp_prism_ui` as a reusable Flutter package, `apps/observatory` as the current app relocated, `apps/catalog` as the ADS gallery/story app, and `apps/cybercore` as a future pilot. All inter-package dependencies use `path:` references in `pubspec.yaml`.

| Criterion | Assessment |
|-----------|------------|
| ADS reuse | ✅ Clean package import: `import 'package:warp_prism_ui/warp_prism_ui.dart'`. |
| Cross-app CI | ✅ `melos run test` runs all package/app tests in one command. ADS changes immediately validated against all consumers. |
| Versioning | ⚠️ Not needed for MVP — path dependencies give instant update visibility. Melos supports versioning if pub.dev publishing is ever desired. |
| Frontend specialization | ✅ Each app has its own `pubspec.yaml`, routes, features, and data layer. |
| Future extraction | ✅ Clean extraction path: move `packages/warp_prism_ui` to its own repo and replace `path:` with a pub.dev or Git dependency. |
| Migration cost | ⚠️ Moderate — requires moving existing code into the monorepo structure. But this is a one-time structural migration. |
| Simplicity | ✅ One `melos bootstrap` command. No pub.dev, no Git URLs, no CI pipeline duplication. |

**Verdict**: **Selected.** Best balance of reuse, CI, simplicity, and future extraction. Matches the charter (§5.3) and Task 1107 exit conditions.

---

## 3. Decision

**Use Melos monorepo with path dependencies.** No pub.dev publishing. No Git dependencies for internal packages. All internal packages reference each other via `path:` in `pubspec.yaml`.

---

## 4. Target Monorepo Structure

```
warp-prism/                          # Monorepo root (current child-project root)
├── melos.yaml                       # Melos configuration
├── AGENTS.md                        # Child-project governance (protected)
├── README.md                        # Project README (protected)
├── .agents/                         # Skills, agents, rules, workflows, profiles (symlinked or local)
├── docs/                            # Project docs, tasks, changelog, reports, architecture, design
│   ├── architecture/
│   ├── changelog/
│   ├── design/
│   ├── reports/
│   ├── tasks/
│   └── ...
├── mock_workspace/                  # Legacy YAML mock data (reference only, archived)
│
├── packages/
│   └── warp_prism_ui/               # Reusable Flutter ADS (app-agnostic)
│       ├── pubspec.yaml
│       ├── analysis_options.yaml
│       ├── lib/
│       │   ├── warp_prism_ui.dart   # Public barrel export
│       │   └── src/
│       │       ├── tokens/          # ← from lib/design_system/tokens/
│       │       ├── atoms/           # ← from lib/design_system/atoms/
│       │       ├── molecules/       # ← from lib/design_system/molecules/
│       │       ├── organisms/       # ← from lib/design_system/organisms/
│       │       ├── templates/       # ← from lib/design_system/templates/
│       │       └── gallery/         # ← from lib/design_system/gallery/
│       └── test/
│           ├── tokens/              # ← from test/design_system/tokens/
│           ├── atoms/               # ← from test/design_system/atoms/
│           ├── molecules/           # ← from test/design_system/molecules/
│           ├── organisms/           # ← from test/design_system/organisms/
│           ├── templates/           # ← from test/design_system/templates/
│           ├── gallery/             # ← from test/design_system/gallery/
│           ├── accessibility/       # ← from test/design_system/accessibility/
│           └── ...                  # Other DS-specific tests
│
├── apps/
│   ├── observatory/                 # ASW Observatory app (current app, relocated)
│   │   ├── pubspec.yaml
│   │   ├── analysis_options.yaml
│   │   ├── lib/
│   │   │   ├── main.dart            # ← from lib/main.dart
│   │   │   ├── app/                 # ← from lib/app/
│   │   │   ├── features/            # ← from lib/features/
│   │   │   └── data/                # ← from lib/data/
│   │   ├── test/
│   │   │   ├── app/                 # ← from test/app/
│   │   │   ├── features/            # ← from test/features/
│   │   │   ├── data/                # ← from test/data/
│   │   │   └── fixtures/            # ← from test/fixtures/
│   │   └── assets/
│   │       ├── mock_workspace/      # ← from assets/mock_workspace/
│   │       └── fonts/               # ← from assets/fonts/
│   │
│   ├── catalog/                     # ADS catalog/gallery app (first proof surface)
│   │   ├── pubspec.yaml
│   │   ├── analysis_options.yaml
│   │   ├── lib/
│   │   │   └── main.dart
│   │   └── test/
│   │
│   └── cybercore/                   # CyberCore pilot app (shell: 1107; content: 1110+)
│       ├── pubspec.yaml
│       ├── analysis_options.yaml
│       ├── lib/
│       │   └── main.dart
│       └── test/
```

### 4.1 Package Name Registry

| Package (Dart) | Directory | Role | Status |
|----------------|-----------|------|--------|
| `warp_prism_ui` | `packages/warp_prism_ui/` | Reusable Flutter ADS — tokens, atoms, molecules, organisms, templates, gallery. App-agnostic. | Created in Task 1107 |
| `warp_prism_observatory` | `apps/observatory/` | ASW Observatory Flutter app. First ADS consumer. | Relocated in Task 1107 |
| `warp_prism_catalog` | `apps/catalog/` | ADS catalog/gallery app. ADS proof surface. | Created in Task 1107 |
| `warp_prism_cybercore` | `apps/cybercore/` | CyberCore pilot app. Second ADS consumer. | App shell/skeleton created in Task 1107; pilot content populated in Task 1110 |

These names are already registered in `docs/design/naming.md` (Task 1101).

---

## 5. Package Boundary Decisions

### 5.1 What Goes into `packages/warp_prism_ui/`

**Principle**: Everything that is reusable across multiple apps and carries zero app-specific domain logic.

| Source (`lib/`) | Target (`packages/warp_prism_ui/lib/src/`) | Rationale |
|-----------------|---------------------------------------------|-----------|
| `lib/design_system/tokens/` | `src/tokens/` | Tokens (colors, typography, spacing, radii, shadows, motion, breakpoints, semantics) are pure Flutter `const` values with no dependencies. Universal. |
| `lib/design_system/atoms/` | `src/atoms/` | Atoms (PrismText, PrismIcon, PrismBadge, PrismChip, PrismStatusDot, PrismDivider, PrismGlowBorder, PrismGlassPanel) depend only on tokens. No data layer. |
| `lib/design_system/molecules/` | `src/molecules/` | Molecules (PrismAssetCard, PrismMetricTile, PrismProvenancePill, PrismSearchBar, PrismFilterChipGroup, PrismStateSurface, PrismEvidenceRow, PrismTaskCard, PrismTimelineMarker) depend on atoms and tokens. No data layer. |
| `lib/design_system/organisms/` | `src/organisms/` | Organisms (PrismShell, PrismSidebar, PrismTopbar, PrismGraphCanvas, PrismLaneBoard, PrismTimeline, PrismDetailInspector, PrismStoryPanel) depend on molecules/atoms/tokens. No data layer. |
| `lib/design_system/templates/` | `src/templates/` | Templates (PrismMasterDetailTemplate) depend on organisms. No data layer. |
| `lib/design_system/gallery/` | `src/gallery/` | Gallery pages depend only on the design system itself. They are the ADS proof surface and must live with the package. |
| `lib/design_system/design_system.dart` | `lib/warp_prism_ui.dart` | Barrel export — renamed to match package name per Dart convention. |

**Verified dependency isolation** (evidence from `rg` analysis):

- `lib/design_system/` has **zero imports** from `lib/data/` — fully decoupled from the data layer.
- `lib/data/` has **zero imports** from `lib/design_system/` — data layer does not depend on ADS.
- `lib/features/` imports `design_system` in ~47 places — features are app-specific consumers, not part of ADS.
- `lib/app/` imports `design_system` in ~7 places — app shell is app-specific.

### 5.2 What Stays in `apps/observatory/`

**Principle**: Everything that is specific to the ASW Observatory product.

| Source | Target | Rationale |
|--------|--------|-----------|
| `lib/main.dart` | `apps/observatory/lib/main.dart` | App entrypoint. |
| `lib/app/` | `apps/observatory/lib/app/` | App shell (AppShell), router (GoRouter config), pages (Overview, Map, Operate, AssetDetail). Uses `warp_prism_ui` for visual components. |
| `lib/features/` | `apps/observatory/lib/features/` | All product features: map, operate, history, governance, asset_detail, overview, shell, workspace_snapshot. Domain-specific. |
| `lib/data/` | `apps/observatory/lib/data/` | All data layer: models, parsers, providers (Riverpod), repositories, services, sources. Observatory-specific mock workspace loading and graph building. |
| `assets/mock_workspace/` | `apps/observatory/assets/mock_workspace/` | Mock workspace corpus. Observatory-specific data bundle. |
| `assets/fonts/` | `apps/observatory/assets/fonts/` | JetBrainsMono font files. Could be moved to `warp_prism_ui` later if other apps need them, but for now the Observatory is the only consumer with custom fonts declared in `pubspec.yaml` flutter assets. |

### 5.3 What Goes into `apps/catalog/`

**Principle**: A minimal Flutter app that imports `warp_prism_ui` and renders the gallery as a standalone app. Initially a thin shell that delegates to the gallery pages already inside `warp_prism_ui`.

- `pubspec.yaml` depends on `warp_prism_ui` via `path: ../../packages/warp_prism_ui`.
- `lib/main.dart` imports and renders `DesignSystemGalleryPage` from `warp_prism_ui`.
- No data layer. No Riverpod. No go_router. Just a `MaterialApp` with the gallery page.
- Tests: smoke test that verifies the catalog app builds and the gallery page renders.

### 5.4 What Goes into `apps/cybercore/` (Future)

**Principle**: A fixture-backed Flutter app that consumes `warp_prism_ui` and mirrors selected CyberCore admin surfaces. Created empty in Task 1107, populated in Task 1110+.

- `pubspec.yaml` depends on `warp_prism_ui` via `path: ../../packages/warp_prism_ui`.
- Will eventually depend on Riverpod, go_router, and CyberCore-specific data/fixtures.
- CyberCore-specific models, fixtures, routes, and features belong here — never in `warp_prism_ui`.

### 5.5 Boundary Invariant

**`warp_prism_ui` must never import from any app, from Riverpod, from go_router, from the data layer, or from any app-specific domain.** Its only Flutter dependency is `flutter` itself (Material, foundation, etc.). This invariant ensures the ADS package remains truly app-agnostic.

---

## 6. Path Dependency Policy

### 6.1 Rules

1. **No pub.dev publishing** for any internal Warp Prism package in the initial monorepo. All `publish_to: 'none'` in every `pubspec.yaml`.
2. **No Git dependencies** for internal packages. All inter-package references use `path:`.
3. **External dependencies** (go_router, flutter_riverpod, yaml, graphview, fl_chart, intl, collection, cupertino_icons) are declared in the consuming app's `pubspec.yaml`, not in `warp_prism_ui` unless the component genuinely requires them.
4. **`warp_prism_ui` external dependencies**: only `flutter` SDK. No third-party packages. If a future organism (e.g., PrismGraphCanvas) needs `graphview`, that dependency must be either:
   - Accepted in `warp_prism_ui` (if the organism is core to the ADS), or
   - Moved to a separate `warp_prism_graph` extension package (if it's too heavy for the core ADS).
   - **Current decision**: Defer `graphview` inclusion. PrismGraphCanvas currently has a placeholder implementation; if it needs graphview later, that decision will be made in the task that completes it.
5. **Font assets**: JetBrainsMono fonts are declared in the Observatory app's `pubspec.yaml` flutter assets section. If `warp_prism_ui` needs to reference them (e.g., in DSTypography), it does so via `fontFamily` string constants only — it does not bundle the font files. The actual font files live in the app that declares them.

### 6.2 Example `pubspec.yaml` Snippets

**`packages/warp_prism_ui/pubspec.yaml`**:
```yaml
name: warp_prism_ui
description: Reusable Flutter Atomic Design System for Ganthritor operational UIs.
publish_to: 'none'
version: 0.1.0

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
```

**`apps/observatory/pubspec.yaml`**:
```yaml
name: warp_prism_observatory
description: ASW Observatory - Agent System Workspace visibility console.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  warp_prism_ui:
    path: ../../packages/warp_prism_ui
  cupertino_icons: ^1.0.6
  go_router: ^14.0.0
  flutter_riverpod: ^2.5.0
  yaml: ^3.1.2
  graphview: ^1.2.0
  fl_chart: ^0.68.0
  collection: ^1.18.0
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/mock_workspace/
    # ... (existing asset declarations)
  fonts:
    - family: JetBrainsMono
      # ... (existing font declarations)
```

**`apps/catalog/pubspec.yaml`**:
```yaml
name: warp_prism_catalog
description: ADS Catalog — story and gallery app for warp_prism_ui validation.
publish_to: 'none'
version: 0.1.0

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  warp_prism_ui:
    path: ../../packages/warp_prism_ui

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
```

---

## 7. Melos Configuration

### 7.1 `melos.yaml` (Root)

```yaml
name: warp_prism
repository: https://github.com/user/warp-prism  # adjust when repo URL is known

packages:
  - packages/**
  - apps/**

command:
  bootstrap:
    usePubspecOverrides: true

scripts:
  analyze:
    description: Run flutter analyze across all packages and apps.
    run: melos exec -- flutter analyze
    packageFilters:
      dirExists: lib

  format:
    description: Check Dart formatting across all packages and apps.
    run: melos exec -- dart format --set-exit-if-changed .
    packageFilters:
      dirExists: lib

  test:
    description: Run flutter test across all packages and apps.
    run: melos exec -- flutter test
    packageFilters:
      dirExists: test

  test-ui:
    description: Run tests for warp_prism_ui only.
    run: flutter test
    packageFilters:
      scope: warp_prism_ui

  test-observatory:
    description: Run tests for the Observatory app only.
    run: flutter test
    packageFilters:
      scope: warp_prism_observatory

  test-catalog:
    description: Run tests for the Catalog app only.
    run: flutter test
    packageFilters:
      scope: warp_prism_catalog

  validate:
    description: Full CI gate — format, analyze, and test all packages.
    run: melos run format && melos run analyze && melos run test
```

### 7.2 Key Melos Commands

| Command | Purpose |
|---------|---------|
| `melos bootstrap` | Resolve all path dependencies and link packages. |
| `melos run analyze` | `flutter analyze` in every package/app. |
| `melos run format` | `dart format --set-exit-if-changed .` in every package/app. |
| `melos run test` | `flutter test` in every package/app that has a `test/` directory. |
| `melos run validate` | Full gate: format → analyze → test. |
| `melos run test-ui` | Run only `warp_prism_ui` tests (fast ADS-only validation). |
| `melos run test-observatory` | Run only Observatory tests. |
| `melos run test-catalog` | Run only Catalog tests. |

---

## 8. CI / Test Strategy Per Package / App

### 8.1 `packages/warp_prism_ui/`

| Gate | Command | Notes |
|------|---------|-------|
| Format | `dart format --set-exit-if-changed .` | Standard Dart formatting. |
| Analyze | `flutter analyze` | Static analysis with `flutter_lints`. |
| Unit tests | `flutter test` | Token contract tests, atom/molecule/organism/widget contract tests, template contract tests. |
| Accessibility | `flutter test test/accessibility/` | Focus traversal, contrast, semantics coverage. |
| Gallery smoke | `flutter test test/gallery/` | Gallery page renders without crash. |

**No Riverpod, no go_router, no data layer dependencies.** Tests must compile and pass with only `flutter` SDK as a dependency.

### 8.2 `apps/observatory/`

| Gate | Command | Notes |
|------|---------|-------|
| Format | `dart format --set-exit-if-changed .` | |
| Analyze | `flutter analyze` | |
| Unit tests | `flutter test` | All existing tests relocated from `test/`. |
| Integration | `flutter test test/app/` | App bootstrap, shell, routing, deep-link tests. |
| Data layer | `flutter test test/data/` | Parser, provider, repository, service tests. |
| Feature tests | `flutter test test/features/` | Feature-specific widget and unit tests. |

### 8.3 `apps/catalog/`

| Gate | Command | Notes |
|------|---------|-------|
| Format | `dart format --set-exit-if-changed .` | |
| Analyze | `flutter analyze` | |
| Smoke test | `flutter test` | Catalog app builds and gallery page renders. |

### 8.4 `apps/cybercore/` (Future)

| Gate | Command | Notes |
|------|---------|-------|
| Format | `dart format --set-exit-if-changed .` | |
| Analyze | `flutter analyze` | |
| Smoke test | `flutter test` | CyberCore app builds and pilot screens render with fixtures. |

### 8.5 Cross-Package Gate

The full `melos run validate` command (format → analyze → test) must pass before any PR merges. This ensures ADS changes are immediately validated against all consumers.

**ADS change validation flow**:
1. Builder modifies `packages/warp_prism_ui/`.
2. `melos run test-ui` runs ADS-only tests.
3. `melos run test-observatory` runs Observatory tests against the updated ADS.
4. `melos run test-catalog` runs Catalog tests against the updated ADS.
5. If any consumer breaks, the change is blocked.

---

## 9. Migration Sequence

The migration is executed by Task 1107. This section defines the exact step-by-step sequence that Task 1107 must follow.

### Phase 0: Prerequisites

| Step | Action | Validation |
|------|--------|------------|
| 0.1 | Verify Flutter/Dart SDK availability. | `flutter --version && dart --version` pass. |
| 0.2 | Read Task 1104 (this document), Task 1105 (catalog policy if available), and current `pubspec.yaml`. | Document read confirmed. |
| 0.3 | Run existing tests to establish baseline. | `flutter test` passes in the current root app. |

### Phase 1: Create Monorepo Skeleton

| Step | Action | Validation |
|------|--------|------------|
| 1.1 | Create `melos.yaml` at the `warp-prism/` root with the configuration from §7.1. | File exists. |
| 1.2 | Create `packages/warp_prism_ui/pubspec.yaml` with minimal dependencies (flutter SDK only, `publish_to: 'none'`). | File exists. |
| 1.3 | Create `packages/warp_prism_ui/analysis_options.yaml`. | File exists. |
| 1.4 | Create `packages/warp_prism_ui/lib/warp_prism_ui.dart` as the public barrel export. | File exists. |
| 1.5 | Create `apps/observatory/` directory structure. | Directories exist. |
| 1.6 | Create `apps/catalog/pubspec.yaml` with path dependency on `warp_prism_ui`. | File exists. |
| 1.7 | Create `apps/catalog/lib/main.dart` with a minimal Material app that renders `DesignSystemGalleryPage`. | File exists. |
| 1.8 | Create `apps/cybercore/pubspec.yaml` (empty shell, path dependency on `warp_prism_ui`). | File exists. |
| 1.9 | Create `apps/cybercore/lib/main.dart` (placeholder Material app). | File exists. |
| 1.10 | Run `melos bootstrap` to verify all path dependencies resolve. | `melos bootstrap` exits 0. |

### Phase 2: Move Design System to `warp_prism_ui`

| Step | Action | Validation |
|------|--------|------------|
| 2.1 | Copy `lib/design_system/tokens/` → `packages/warp_prism_ui/lib/src/tokens/`. | Files exist. |
| 2.2 | Copy `lib/design_system/atoms/` → `packages/warp_prism_ui/lib/src/atoms/`. | Files exist. |
| 2.3 | Copy `lib/design_system/molecules/` → `packages/warp_prism_ui/lib/src/molecules/`. | Files exist. |
| 2.4 | Copy `lib/design_system/organisms/` → `packages/warp_prism_ui/lib/src/organisms/`. | Files exist. |
| 2.5 | Copy `lib/design_system/templates/` → `packages/warp_prism_ui/lib/src/templates/`. | Files exist. |
| 2.6 | Copy `lib/design_system/gallery/` → `packages/warp_prism_ui/lib/src/gallery/`. | Files exist. |
| 2.7 | Write `packages/warp_prism_ui/lib/warp_prism_ui.dart` barrel export that re-exports all layers. | File exists. |
| 2.8 | Copy DS-related tests from `test/design_system/` → `packages/warp_prism_ui/test/`. | Files exist. |
| 2.9 | Fix any relative import paths in the moved files (e.g., `../tokens/tokens.dart` → `../tokens/tokens.dart` within `src/`). | `flutter analyze` passes in `packages/warp_prism_ui/`. |
| 2.10 | Run `flutter test` in `packages/warp_prism_ui/`. | Tests pass. |

### Phase 3: Move Observatory App

| Step | Action | Validation |
|------|--------|------------|
| 3.1 | Move `pubspec.yaml` → `apps/observatory/pubspec.yaml` (rename package to `warp_prism_observatory`, add `warp_prism_ui` path dependency). | File exists. |
| 3.2 | Move `lib/main.dart` → `apps/observatory/lib/main.dart`. | File exists. |
| 3.3 | Move `lib/app/` → `apps/observatory/lib/app/`. | Directory exists. |
| 3.4 | Move `lib/features/` → `apps/observatory/lib/features/`. | Directory exists. |
| 3.5 | Move `lib/data/` → `apps/observatory/lib/data/`. | Directory exists. |
| 3.6 | Move `assets/` → `apps/observatory/assets/`. | Directory exists. |
| 3.7 | Move `test/app/`, `test/features/`, `test/data/`, `test/fixtures/` → `apps/observatory/test/`. | Directories exist. |
| 3.8 | Update all `import '...design_system/design_system.dart'` in the Observatory app to `import 'package:warp_prism_ui/warp_prism_ui.dart'`. | `flutter analyze` passes in `apps/observatory/`. |
| 3.9 | Update `apps/observatory/pubspec.yaml` asset paths from `assets/...` to correct relative paths. | Asset paths resolve. |
| 3.10 | Remove the old root `lib/`, `test/`, and `assets/` directories (after confirming everything moved correctly). | Old directories are gone. |
| 3.11 | Remove the old root `pubspec.yaml` (replaced by `melos.yaml` at root). | Old pubspec is gone. |
| 3.12 | Run `flutter test` in `apps/observatory/`. | Tests pass. |

### Phase 4: Verify Catalog

| Step | Action | Validation |
|------|--------|------------|
| 4.1 | Run `flutter test` in `apps/catalog/`. | Catalog smoke test passes. |
| 4.2 | Run `melos run validate`. | Full gate passes across all packages. |

### Phase 5: Cleanup

| Step | Action | Validation |
|------|--------|------------|
| 5.1 | Remove any stale root-level files that were not moved (e.g., old `analysis_options.yaml` if it existed). | Root contains only `melos.yaml`, `AGENTS.md`, `README.md`, `.agents/`, `docs/`, `mock_workspace/`, `packages/`, `apps/`. |
| 5.2 | Update `.gitignore` if needed for Melos cache directories. | `.gitignore` is correct. |
| 5.3 | Add changelog entry. | Changelog entry exists. |

---

## 10. Risk Analysis

### 10.1 High-Risk Items

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| **Relative import breakage** when moving design system files. | High | High | Step 2.9 explicitly requires fixing imports. Use `flutter analyze` as the gate. The design system uses relative imports internally (e.g., `../tokens/tokens.dart`); these must be updated to match the new `src/` structure. |
| **Observatory app fails to find design system after move.** | High | High | Step 3.8 replaces all relative `design_system` imports with `package:warp_prism_ui/warp_prism_ui.dart`. Use `rg` to find and replace all occurrences. |
| **Asset path breakage** (fonts, mock workspace). | Medium | High | Step 3.9 updates `pubspec.yaml` asset declarations. Font files and mock workspace assets move to `apps/observatory/assets/`. Test by running the Observatory app after migration. |
| **Flutter SDK not available.** | Known blocker | Critical | Step 0.1 checks before any migration begins. If Flutter is unavailable, migration remains blocked. Task 1103 already documents this as a known blocker. |

### 10.2 Medium-Risk Items

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| **`graphview` dependency needed by `warp_prism_ui`.** | Medium | Medium | Current evidence: `graphview` is declared in `pubspec.yaml` but `rg` shows **zero imports** in `lib/`. It is not currently used. If PrismGraphCanvas needs it later, the dependency can be added to `warp_prism_ui` or split into a separate extension package. |
| **`fl_chart` needed by `warp_prism_ui`.** | Low | Medium | Current evidence: `fl_chart` is declared in `pubspec.yaml`. It is likely used only by feature-level chart widgets (governance, history), not by the design system. Keep it in Observatory only. |
| **`yaml` package needed by `warp_prism_ui`.** | Low | Low | `yaml` is used only by `lib/data/parsers/` (Observatory-specific). Not needed by ADS. |
| **Test fixtures location ambiguity.** | Low | Low | `test/fixtures/` contains test data. Move to `apps/observatory/test/fixtures/`. If `warp_prism_ui` tests later need fixtures, create `packages/warp_prism_ui/test/fixtures/` separately. |

### 10.3 Low-Risk Items

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| **Melos version incompatibility.** | Low | Low | Use latest stable Melos. Document required version in `melos.yaml` or project README. |
| **CI runner does not have Melos installed.** | Low | Medium | Document `dart pub global activate melos` in README. CI scripts should include this step. |
| **Naming conflicts between old `DSColors` and new `PrismTokens.colors`.** | None | None | Per naming.md, rename is deferred. Old `DS*` names are kept as compatibility aliases. The migration moves files without renaming classes. |

---

## 11. Widgetbook vs Custom Catalog Decision

### 11.1 Options

| Option | Pros | Cons |
|--------|------|------|
| **Widgetbook** | Professional story format, built-in device frames, knobs for interactive testing, addon system, community adoption. | External dependency (adds `widgetbook` and `widgetbook_annotation` to `warp_prism_ui` dev dependencies). Requires code generation or manual story registration. Learning curve. Potential version compatibility issues with Flutter SDK. |
| **Custom Catalog App** | Zero external dependencies. Full control. The existing `DesignSystemGalleryPage` already demonstrates all ADS layers. Simple `MaterialApp` shell in `apps/catalog/`. No code generation. | Less interactive than Widgetbook. No built-in device frames or knobs. Must build any story-management features manually. |

### 11.2 Decision: Custom Catalog App for MVP

**Rationale**:

1. The existing `DesignSystemGalleryPage` already showcases all atomic design layers (tokens, atoms, molecules, organisms, templates, accessibility) in a scrollable layout. It is the ADS proof surface and is already functional.
2. `warp_prism_ui` must remain dependency-free (only `flutter` SDK). Adding Widgetbook introduces external dependencies that may conflict with the zero-dependency invariant.
3. Task 1105 (token/theme/catalog policy) will define catalog case, golden-test, and semantics-test gates. These can be implemented with `flutter_test` and custom gallery sections without Widgetbook.
4. Widgetbook can be introduced later (Task 1106+ or post-expansion gate) if the custom catalog proves insufficient. The Melos monorepo structure supports adding Widgetbook to `apps/catalog` without restructuring.

**Future Widgetbook path**: If Widgetbook is adopted later:
- Add `widgetbook` to `apps/catalog/pubspec.yaml` only (not to `warp_prism_ui`).
- Create Widgetbook stories in `apps/catalog/lib/stories/` that import from `warp_prism_ui`.
- The custom gallery page inside `warp_prism_ui` remains as a dependency-free fallback.

---

## 12. Task 1103 Reconciliation

Task 1103 (Warp Prism Flutter Tooling And Scaffold) was written when `warp-prism/` was assumed empty. Its **supersession note** (added 2026-06-08) already acknowledges this:

> "This task was written when `warp-prism/` was assumed empty. The project now has an existing Flutter app... The scaffold work described here has been superseded by Task 1104 (Melos monorepo architecture plan) and Task 1107 (Melos monorepo migration)."

**Action**: Task 1103's supersession note is already accurate. No additional updates are needed. The Flutter tooling verification subtask remains valid as a prerequisite for Task 1107 — Task 1107 should verify `flutter --version` and `dart --version` as its first step (Phase 0, Step 0.1).

---

## 13. ADS Upgrade Flow to Consumers

When a developer modifies `packages/warp_prism_ui/`:

1. **Immediate local visibility**: Because all apps use `path:` dependencies, `melos bootstrap` (or simply running an app) picks up the ADS change immediately. No version bump, no publish, no Git push required.

2. **Cross-app validation gate**: `melos run validate` runs format, analyze, and test across ALL packages and apps. If an ADS change breaks the Observatory or Catalog, the test suite catches it in the same CI run.

3. **Per-app validation**: `melos run test-ui` validates ADS in isolation. `melos run test-observatory` validates Observatory against the updated ADS. `melos run test-catalog` validates Catalog against the updated ADS.

4. **Future versioning path**: If `warp_prism_ui` is ever published to pub.dev or moved to its own repo, Melos supports `melos version` to manage version bumps. Replace `path:` dependencies with versioned pub.dev or Git dependencies at that point. This is not needed for MVP.

---

## 14. Source Evidence

| Source | Relevance |
|--------|-----------|
| `AGENTS.md` (Task 1101) | Child-project governance, protected files, product constraints. |
| `docs/design/charter.md` (Task 1101) | Scope, non-goals, monorepo architecture direction (§5.3). |
| `docs/design/naming.md` (Task 1101) | Canonical package names, `Prism*` prefix policy, Voidframe supersession. |
| `docs/tasks/00-planning/1100-...epic.md` | ADS epic, story breakdown (WP-S3 = Melos monorepo). |
| `docs/tasks/00-planning/EPIC-11-...cybercore-frontend.md` | CyberCore pilot scope, fixture-backed app requirement. |
| `docs/tasks/01-open/1103-...tooling-and-scaffold.md` | Stale scaffold assumptions — already superseded (§12 above). |
| `docs/tasks/01-open/1107-...melos-monorepo-migration.md` | Migration task that consumes this architecture plan. |
| `docs/tasks/01-open/1105-...token-theme-catalog-policy.md` | Catalog policy task that references this architecture plan. |
| Current `pubspec.yaml` | Dependency baseline: go_router, flutter_riverpod, yaml, graphview, fl_chart, intl, collection. |
| `lib/design_system/` file tree | 47 Dart files across tokens/atoms/molecules/organisms/templates/gallery. Zero data-layer imports. |
| `lib/features/` file tree | 8 feature directories, ~47 design_system imports. App-specific. |
| `lib/data/` file tree | 6 subdirectories (models/parsers/providers/repositories/services/sources). Zero design_system imports. |
| `rg` analysis | Confirmed: design_system has no data imports, data has no design_system imports, features import both. |
| `test/` file tree | 48 test files mirroring lib structure. |

---

## 15. Appendix: File Ownership After Migration

| Current Path | Target Path | Package Owner |
|-------------|-------------|---------------|
| `lib/design_system/tokens/*.dart` | `packages/warp_prism_ui/lib/src/tokens/` | `warp_prism_ui` |
| `lib/design_system/atoms/*.dart` | `packages/warp_prism_ui/lib/src/atoms/` | `warp_prism_ui` |
| `lib/design_system/molecules/*.dart` | `packages/warp_prism_ui/lib/src/molecules/` | `warp_prism_ui` |
| `lib/design_system/organisms/*.dart` | `packages/warp_prism_ui/lib/src/organisms/` | `warp_prism_ui` |
| `lib/design_system/templates/*.dart` | `packages/warp_prism_ui/lib/src/templates/` | `warp_prism_ui` |
| `lib/design_system/gallery/*.dart` | `packages/warp_prism_ui/lib/src/gallery/` | `warp_prism_ui` |
| `lib/design_system/design_system.dart` | `packages/warp_prism_ui/lib/warp_prism_ui.dart` | `warp_prism_ui` |
| `test/design_system/**/*.dart` | `packages/warp_prism_ui/test/` | `warp_prism_ui` |
| `lib/main.dart` | `apps/observatory/lib/main.dart` | `warp_prism_observatory` |
| `lib/app/**` | `apps/observatory/lib/app/` | `warp_prism_observatory` |
| `lib/features/**` | `apps/observatory/lib/features/` | `warp_prism_observatory` |
| `lib/data/**` | `apps/observatory/lib/data/` | `warp_prism_observatory` |
| `test/app/**` | `apps/observatory/test/app/` | `warp_prism_observatory` |
| `test/features/**` | `apps/observatory/test/features/` | `warp_prism_observatory` |
| `test/data/**` | `apps/observatory/test/data/` | `warp_prism_observatory` |
| `test/fixtures/**` | `apps/observatory/test/fixtures/` | `warp_prism_observatory` |
| `assets/mock_workspace/**` | `apps/observatory/assets/mock_workspace/` | `warp_prism_observatory` |
| `assets/fonts/**` | `apps/observatory/assets/fonts/` | `warp_prism_observatory` |
| (new) | `apps/catalog/lib/main.dart` | `warp_prism_catalog` |
| (new) | `apps/catalog/test/` | `warp_prism_catalog` |
| (new) | `apps/cybercore/lib/main.dart` | `warp_prism_cybercore` |
| (new) | `apps/cybercore/test/` | `warp_prism_cybercore` |
| `pubspec.yaml` (root) | Removed; replaced by `melos.yaml` | Monorepo root |
| `mock_workspace/` (root) | Stays at root (reference/archive) | Monorepo root |
