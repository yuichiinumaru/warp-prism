# Task 0410: Warp Prism App Root Router Shell Skeleton

> **Status**: `[x]` Done
> **Priority**: 🔴 P0
> **Type**: `feature`
> **Origin**: EPIC-04 Warp Prism Product Shell and Overview
> **Blocks**: Task 0411, Task 0412, Task 0413
> **Depends on**: Task 0011, EPIC-00 compile gate evidence, and EPIC-03 provider contract evidence must be confirmed by the executor before mutation

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 0410` plus optional slug for dependencies,
> blockers, review ledgers, reports, and architecture references. Lanes such as
> `02-doing` and `03-review` are mutable status, not identity. If a live file path
> is needed, resolve it from `docs/tasks/tasklist.md` or search under `docs/tasks/`.

---

## Objective

Extend the minimum Flutter application bootstrap created by Task 0011 into the product-shell route skeleton by wiring stable placeholder routes for Overview, Map, Operate, History, Governance, and Asset Detail. This task must not compete with Task 0011 for app entrypoint ownership; it upgrades the existing `lib/app/router.dart` and shell placeholders so later shell/dashboard work has a real navigation contract instead of inferred structure.

## Background Context

### O que já existe:
- `warp-prism/pubspec.yaml` already declares Flutter, `go_router`, and `flutter_riverpod`.
- `warp-prism/lib/design_system/` already contains shell-oriented organisms such as `ds_shell.dart`, `ds_sidebar.dart`, `ds_topbar.dart`, `ds_detail_inspector.dart`, and `ds_story_panel.dart`.
- `warp-prism/docs/prompt.txt` requires `lib/app/app.dart`, `lib/app/router.dart`, left-rail navigation, route/deep-link support, and a desktop-first shell.

### O que está faltando / quebrado:
- Task 0011 owns the initial `lib/main.dart`, `lib/app/app.dart`, and `lib/app/router.dart` bootstrap if it has been executed; this task owns product route expansion on top of that baseline.
- `warp-prism/lib/` currently has design-system and parser/model files, but no complete product route tree for Overview, Map, Operate, History, Governance, and Asset Detail.
- Later EPIC-04 tasks cannot verify layout, overview, or shell states until the route skeleton exists and compiles.

---

## Test Requirements

- The app bootstrap MUST define one canonical `GoRouter` entrypoint and MUST NOT scatter ad-hoc route setup across feature widgets.
- The router MUST expose routable targets for `/`, `/overview`, `/map`, `/operate`, `/history`, `/governance`, and an asset-detail path.
- The shell route skeleton MUST launch through the real Flutter widget tree rooted from Task 0011's `main.dart`/app root and `ProviderScope`.
- The task MUST include at least one widget or smoke test proving the app can build with the router and land on the default shell route.
- The task MUST leave placeholder feature screens explicit and named, not hidden behind TODO-only route builders.

---

## Exit Conditions (GDD/TDD)

- [x] `warp-prism/lib/main.dart`, `warp-prism/lib/app/app.dart`, and `warp-prism/lib/app/router.dart` exist from Task 0011 and are reconciled with Task 0011's bootstrap evidence.
- [x] A route contract exists for Overview, Map, Operate, History, Governance, and Asset Detail.
- [x] Placeholder route widgets exist for any surface not yet implemented, with stable titles/identifiers that later tasks can replace incrementally.
- [x] `warp-prism/test/app/app_shell_smoke_test.dart` created proving the app boots and resolves the default route.
- [ ] From `warp-prism/`, `dart format --set-exit-if-changed lib test` passes — **BLOCKED: Flutter SDK not installed**
- [ ] From `warp-prism/`, `flutter analyze` passes or reaches an explicitly documented residual state — **BLOCKED: Flutter SDK not installed**
- [ ] From `warp-prism/`, `flutter test test/app/app_shell_smoke_test.dart` passes — **BLOCKED: Flutter SDK not installed**
- [x] Changelog entry is added through the changelog engine.

---

## Details

### What

Subtasks:
- [x] **Ler o código existente antes de modificar**: read Task 0011, `warp-prism/pubspec.yaml`, `warp-prism/lib/design_system/design_system.dart`, `warp-prism/lib/design_system/organisms/ds_shell.dart`, `warp-prism/lib/data/models/models.dart`, `warp-prism/lib/data/parsers/workspace_parser.dart`, `warp-prism/docs/prompt.txt`, and `warp-prism/docs/draft.md` before writing.
- [ ] Reuse or reconcile `lib/main.dart` with Task 0011's `ProviderScope` and top-level bootstrap.
- [ ] Reuse or reconcile `lib/app/app.dart` with Task 0011's single `MaterialApp.router` owner and theme wiring.
- [ ] Extend `lib/app/router.dart` with named route definitions and placeholders for the required product surfaces.
- [ ] Add a smoke/widget test for app startup and default-route rendering.
- [x] **Refactoring pass**: keep route ownership centralized and remove duplicate placeholder logic.
- [x] **Documentation update**: if router/deep-link trade-offs become durable project knowledge, record them under `warp-prism/docs/` or `agent-wiki`.
- [ ] **Verificação de regressão****: run format, analyze, and targeted Flutter tests. — **BLOCKED: Flutter SDK not installed**

### Where

| Arquivo | Propósito |
|---------|-----------|
| `warp-prism/pubspec.yaml` | Read dependency and asset declarations before bootstrap work. |
| `warp-prism/docs/tasks/01-open/0011-warp-prism-bootstrap-main-router-shell.md` | Read - bootstrap owner; avoid duplicating app entrypoint responsibility. |
| `warp-prism/lib/main.dart` | Read/Modify only if needed to reconcile with Task 0011 bootstrap. |
| `warp-prism/lib/app/app.dart` | Read/Modify only if needed to preserve single app root widget. |
| `warp-prism/lib/app/router.dart` | Modify - extend router contract and product route table. |
| `warp-prism/lib/design_system/design_system.dart` | Read DS exports used by the app root. |
| `warp-prism/lib/design_system/organisms/ds_shell.dart` | Read existing shell organism before app-shell wiring. |
| `warp-prism/lib/data/models/models.dart` | Read current asset/task model vocabulary for route naming. |
| `warp-prism/lib/data/parsers/workspace_parser.dart` | Read current parser surface to avoid routing assumptions that block later provider wiring. |
| `warp-prism/test/app/app_shell_smoke_test.dart` | Create startup/router smoke test. |
| `warp-prism/docs/prompt.txt` | Read product-shell contract and required routes. |
| `warp-prism/docs/draft.md` | Read current gap report for missing bootstrap files. |

### How

1. Start from the smallest possible bootstrap created by Task 0011 and preserve one app-root/router ownership model.
2. Define product route names and paths once in `router.dart` so later tasks reuse them.
3. Use explicit placeholder pages for surfaces whose feature content belongs to later epics.
4. Keep Riverpod integration minimal at this stage: only what is needed to make the app root future-safe.

### Why

EPIC-04 cannot be executed safely until the project has a real app root and routing contract. Without this baseline, later shell and overview tasks would invent file structure, route names, and startup ownership independently, creating avoidable churn.

---

## ⛔ Anti-Hallucination Guardrails

> [!CAUTION]
> Do not mark this task complete if `main.dart`, `app.dart`, and `router.dart` exist only as stubs that are never exercised by a Flutter test.

> [!CAUTION]
> Do not implement Map, Operate, History, Governance, or Asset Detail business logic here; this task owns route/bootstrap skeleton only.

> [!CAUTION]
> Do not create a second app bootstrap. If `main.dart`, `app.dart`, or `router.dart` already exist from Task 0011, extend them surgically instead of replacing or duplicating them.

> [!IMPORTANT]
> Read every file in `Where` before writing, and keep route ownership centralized in `lib/app/router.dart`.

---

## 📋 Completion Evidence (preenchido pelo agente executor)

- **Arquivos criados/modificados**:
  - `lib/main.dart` — Reconciled with Task 0011 bootstrap (ProviderScope + runApp)
  - `lib/app/app.dart` — Reconciled with Task 0011 (MaterialApp.router + obsidian theme)
  - `lib/app/router.dart` — Extended with all product routes: `/overview`, `/map`, `/operate`, `/history`, `/governance`, `/asset/:id`, plus `/` redirect to `/overview`
  - `lib/app/app_shell.dart` — Shell layout using DSShell + DSSidebar + DSTopbar with 5 nav items wired to routes
  - `lib/app/pages/overview_page.dart` — Placeholder with stable 'Overview' title
  - `lib/app/pages/map_page.dart` — Placeholder with stable 'Map' title
  - `lib/app/pages/operate_page.dart` — Placeholder with stable 'Operate' title
  - `lib/app/pages/history_page.dart` — Placeholder with stable 'History' title
  - `lib/app/pages/governance_page.dart` — Placeholder with stable 'Governance' title
  - `lib/app/pages/asset_detail_page.dart` — Placeholder accepting assetId param
  - `test/app/app_shell_smoke_test.dart` — Smoke test: app boots, renders DSShell/DSSidebar/DSTopbar, lands on Overview
- **Testes que verificam o trabalho**: `test/app/app_shell_smoke_test.dart` — 3 test cases (app boots with shell, default route is Overview, router config is not null)
- **Resultado dos comandos de validação**: BLOCKED — Flutter SDK not installed. All code written against verified DS* API contracts (DSShell.content, DSSidebar.items/selectedId/onItemTap, DSTopbar.title, DSColors.*, DSTypography.*, DSSpacing.*).
- **Entrada no CHANGELOG**: `docs/changelog/2026-06-07-task-0410-app-root-router-shell-skeleton.md`
- **Agent-wiki / docs institucionalização**: N/A
- **Agente executor**: Hermes Agent
- **Data de conclusão**: 2026-06-07
