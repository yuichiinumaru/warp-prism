# Warp Prism

![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white)
![Rust](https://img.shields.io/badge/Rust-000000?logo=rust&logoColor=white)
![Melos](https://img.shields.io/badge/Melos-7-FF6F00)
![Linux](https://img.shields.io/badge/Linux-FCC624?logo=linux&logoColor=black)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**Compositional design + integration system for Flutter applications** — a Melos
monorepo containing a reusable Flutter Atomic Design System (`warp_prism_ui`),
backend-agnostic runtime contracts, a Rust integration golden path
(`flutter_rust_bridge`), a read-only Agent System Workspace Observatory, an ADS
catalog/gallery, and a CyberCore pilot app.

> **AIDS** — *Atomic + Integration Design System*. Yes, really.
> [Lore at the bottom](#why-aids).

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
    warp_prism_runtime/                 # Backend-agnostic runtime contracts
    warp_prism_interaction/             # IDS candidate kernel
    warp_prism_bindings/                # Presentation/runtime projection layer
    warp_prism_adapter_frb/             # flutter_rust_bridge adapter
    warp_prism_testkit/                 # Contract testkit + fakes
    warp_prism_host_exercise/           # Real-host exercise harness
  apps/
    observatory/                        # ASW Observatory (warp_prism_observatory)
    catalog/                            # ADS gallery/storybook (warp_prism_catalog)
    cybercore/                          # CyberCore pilot (warp_prism_cybercore)
  rust/                                 # Cargo workspace (warp_bridge_core + warp_bridge_frb)
  skills/                               # Vendored agent skills (flutter, rust, flutter-rust-integration)
  docs/
    design/                             # Charter, naming policy, visual contract
    governance/                         # Governance records
    bridge/                             # Product bridge notes
  .project/
    tasks/                              # Task governance (5 lanes)
    reports/                            # Audit and analysis reports
    changelog/                          # Local changelog ledger
    memories/                           # Lane continuity
  .agents/                              # Parent-canonical harness (symlinked, do not fork)
```

### Packages

| Package | Directory | Role |
|---------|-----------|------|
| `warp_prism_ui` | `packages/warp_prism_ui/` | Reusable Flutter Atomic Design System for Ganthritor operational UIs. Only depends on `flutter` SDK. |
| `warp_prism_runtime` | `packages/warp_prism_runtime/` | Pure-Dart backend-agnostic runtime contracts (`EventStream`, `HealthSource`, `GraphSource`, `AsyncCommand`). |
| `warp_prism_interaction` | `packages/warp_prism_interaction/` | Interaction Design System (IDS) candidate kernel (Selection, Inspection, Query). |
| `warp_prism_bindings` | `packages/warp_prism_bindings/` | Thin projection layer connecting presentation, interaction semantics, and runtime contracts. |
| `warp_prism_adapter_frb` | `packages/warp_prism_adapter_frb/` | `flutter_rust_bridge` native adapter implementing the runtime contracts. |
| `warp_prism_testkit` | `packages/warp_prism_testkit/` | In-memory test doubles and reusable contract-compliance suites. |
| `warp_prism_host_exercise` | `packages/warp_prism_host_exercise/` | Real-host UI exercise harness (SMOKE/CRAWL/FUZZ over safe semantic actions with strict error oracle). |
| `warp_prism_observatory` | `apps/observatory/` | ASW Observatory app. Reads mock workspace data, renders Map/Operate/History/Governance surfaces. |
| `warp_prism_catalog` | `apps/catalog/` | ADS catalog/gallery app. Proof surface for the design system. |
| `warp_prism_cybercore` | `apps/cybercore/` | CyberCore pilot. Fixture-backed Flutter mirror of selected CyberCore admin surfaces. |

## Stack

| Layer | Where | Technology |
|-------|-------|-----------|
| Workspace | Root | Dart 3.12, Melos 7 |
| Design System | `packages/warp_prism_ui/` | Flutter (zero external dependencies) |
| Runtime Contracts | `packages/warp_prism_runtime/` | Pure Dart, backend-agnostic |
| IDS Kernel | `packages/warp_prism_interaction/` | Pure Dart interaction semantics |
| FRB Adapter | `packages/warp_prism_adapter_frb/` + `rust/` | `flutter_rust_bridge` + Cargo (`warp_bridge_core`, `warp_bridge_frb`) |
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
`.project/reports/`. Do **not** invent alternate bootstrap paths outside
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
| Full `dart run melos run test` / package-green | **Not claimed** | See `.project/reports/warp-prism-test-failure-baseline.md` and `.project/reports/0010-warp-prism-foundation-audit-analyzer-baseline.md` |

Canonical baseline report:
`.project/reports/0010-warp-prism-foundation-audit-analyzer-baseline.md`.

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

- `MISSION.md` — product destination + maturity gates (L1 Integration-Capable)
- `AGENTS.md` — operating constitution (how work may be conducted)
- `docs/design/charter.md` — project charter, scope, and non-goals
- `docs/design/naming.md` — naming policy (`Prism*` prefix, package names, Voidframe supersession)
- `docs/mock-workspace-corpus-contract.md` — mock workspace corpus migration contract
- `.project/tasks/` — task governance (5-lane board)
- `.project/reports/` — audit and analysis reports
- `.project/changelog/` — local changelog ledger

## Agent Skills

`skills/` is a vendored snapshot (2026-09-23) of the parent-canonical
`.agents/skills/` — `flutter` (incl. Flutter-adapted atomic design-system
governance), `rust`, and `flutter-rust-integration` — committed here so the
project carries its own agent praxis. Upstream remains `.agents/skills/`;
re-vendor on purpose, never drift by accident.

## License

Warp Prism is [MIT](./LICENSE)-licensed. Use it, fork it, learn from it, ship it
in commercial products — all I ask is that you keep the copyright notice and
give credit to the original author ([Yuichi Inumaru](https://github.com/yuichiinumaru)).

---

## Why AIDS?

Warp Prism started life as an **A**tomic design system in Flutter. Then the
`flutter_rust_bridge` golden path walked in: a Rust backend with a Flutter
frontend deserved first-class bridges, not an afterthought. So Warp Prism grew
an **I**ntegration **D**esign **S**ystem next to the atomic one.

**A**tomic + **I**ntegration **D**esign **S**ystem = **AIDS**.

(It was originally going to be the "AI" of AI agents. Then somebody read the
acronym out loud. We kept it anyway.)

[![Rick sez AIDS](https://media.giphy.com/media/ZA0AlXfgerJF7iiDTl/giphy.gif)](https://giphy.com/gifs/rickandmorty-season-2-adult-swim-rick-and-morty-ZA0AlXfgerJF7iiDTl)

*Gif: Rick and Morty, Season 2 — via GIPHY.*
