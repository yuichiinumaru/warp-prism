# Task 1103: Warp Prism Flutter Tooling And Scaffold

> **Status**: `[ ]` Open — **SUPERSEDED**: see note below
> **Priority**: 🟡 P1
> **Type**: `feature`
> **Origin**: Task 1100 Warp Prism epic and Task 1101/1102 planning gates
> **Blocks**: ~~Task 1104, Task 1105, Task 1106~~ → see Task 1107
> **Depends on**: Task 1101, Task 1102
>
> **⚠️ SUPERSESSION NOTE (2026-06-08)**: This task was written when `warp-prism/`
> was assumed empty. The project now has an existing Flutter app with `pubspec.yaml`,
> `lib/`, `test/`, design-system implementation (`lib/design_system/`), and ASW
> Observatory planning. The scaffold work described here has been superseded by:
> - **Task 1104** — Melos monorepo architecture plan (design-only).
> - **Task 1107** — Melos monorepo migration (execution: creates `packages/warp_prism_ui/`,
>   `apps/observatory/`, `apps/catalog/`, and `melos.yaml`).
>
> The **Flutter tooling verification** portion of this task remains valid and is
> a prerequisite for Task 1107. An executor may either:
> 1. Execute only the tooling-check subtask, mark remaining scaffold subtasks as
>    superseded, and close; OR
> 2. Cancel this task entirely and let Task 1107 own the tooling gate.
>
> **Do not execute the old scaffold subtasks** — they conflict with the approved
> Melos monorepo layout.

---

## Objective

Verify local Flutter/Dart tooling and create the minimal Warp Prism child-project scaffold: a reusable `warp_prism_ui` package and a Storybook/Widgetbook-like `warp_prism_catalog` app, without implementing broad components beyond a compileable shell.

## Background Context

### O que já existe:
- `warp-prism/` contains an existing Flutter app: `pubspec.yaml`, `lib/`, `test/`, `lib/design_system/` (tokens/atoms/molecules/organisms/templates + gallery route).
- Task 1104 defines the approved Melos monorepo architecture.
- Task 1107 defines the migration execution to create the Melos monorepo layout.
- Task 8281 defined charter/naming (superseded by local Task 1101).
- Task 8282 defined component inventory (superseded by local Task 1102).

### O que está faltando / quebrado:
- Flutter SDK is **not installed**: `flutter --version` and `dart --version` return command not found.
- The scaffold described in this task (flat `packages/` + `apps/`) conflicts with the approved Melos monorepo layout.
- This task should either be narrowed to tooling-only or cancelled in favor of Task 1107.

---

## Test Requirements

- The task MUST check `flutter --version`, `flutter doctor -v`, and `dart --version` before scaffold creation.
- If Flutter or Dart is unavailable, the task MUST remain blocked/open and MUST NOT be marked complete.
- The package and catalog MUST pass `dart format --set-exit-if-changed .`, `flutter analyze`, and `flutter test` from their directories.
- The scaffold MUST include local README or docs explaining how to run package and catalog validation.
- The scaffold MUST not add heavy graph/map/editor/canvas dependencies.

---

## Exit Conditions (GDD/TDD)

- [ ] `flutter --version`, `flutter doctor -v`, and `dart --version` pass before scaffold creation.
- [ ] If Flutter/Dart tooling is unavailable, this task remains blocked/open and is not marked complete.
- [ ] `warp-prism/packages/warp_prism_ui/` exists with compileable package skeleton.
- [ ] `warp-prism/apps/warp_prism_catalog/` exists with compileable catalog app skeleton.
- [ ] From `warp-prism/packages/warp_prism_ui/`, `dart format --set-exit-if-changed .` passes.
- [ ] From `warp-prism/packages/warp_prism_ui/`, `flutter analyze` passes.
- [ ] From `warp-prism/packages/warp_prism_ui/`, `flutter test` passes.
- [ ] From `warp-prism/apps/warp_prism_catalog/`, `dart format --set-exit-if-changed .` passes.
- [ ] From `warp-prism/apps/warp_prism_catalog/`, `flutter analyze` passes.
- [ ] From `warp-prism/apps/warp_prism_catalog/`, `flutter test` passes.
- [ ] Widgetbook decision is documented as immediate, deferred, or not chosen for MVP.
- [ ] `bash .agents/skills/project-management/sub-skills/manage-changelog/scripts/rebuild.sh validate` passes.
- [ ] Changelog entry is added through the changelog engine.

---

## Details

### What

Subtasks:
- [ ] **Ler o código existente antes de modificar**: read `warp-prism/`, Task 1101 docs, Task 1102 inventory, and repository child-project rules before writing.
- [ ] Run tooling checks: `flutter --version`, `flutter doctor -v`, `dart --version`.
- [ ] Create `packages/warp_prism_ui` with `pubspec.yaml`, `analysis_options.yaml`, `lib/warp_prism_ui.dart`, minimal `src/`, and tests.
- [ ] Create `apps/warp_prism_catalog` with `pubspec.yaml`, `analysis_options.yaml`, `lib/main.dart`, minimal catalog shell, and tests.
- [ ] Add README or docs with package/catalog validation commands.
- [ ] **Refactoring pass**: keep scaffold minimal and remove unused generated code if templates produce noise.
- [ ] **Documentation update**: record Widgetbook/catalog decision.
- [ ] **Verificação de regressão**: run format/analyze/test commands.

### Where

| Arquivo | Propósito |
|---------|-----------|
| `warp-prism/` | Read and then modify child-project root. |
| `warp-prism/packages/warp_prism_ui/pubspec.yaml` | Create package manifest. |
| `warp-prism/packages/warp_prism_ui/analysis_options.yaml` | Create package analysis configuration. |
| `warp-prism/packages/warp_prism_ui/lib/warp_prism_ui.dart` | Create public package entrypoint. |
| `warp-prism/packages/warp_prism_ui/lib/src/` | Create minimal package source tree. |
| `warp-prism/packages/warp_prism_ui/test/` | Create initial package tests. |
| `warp-prism/apps/warp_prism_catalog/pubspec.yaml` | Create catalog app manifest. |
| `warp-prism/apps/warp_prism_catalog/analysis_options.yaml` | Create catalog analysis configuration. |
| `warp-prism/apps/warp_prism_catalog/lib/main.dart` | Create catalog app entrypoint. |
| `warp-prism/apps/warp_prism_catalog/test/` | Create initial catalog tests. |
| `warp-prism/docs/design/charter.md` | Read prerequisite charter. |
| `warp-prism/docs/design/component-inventory.md` | Read prerequisite inventory. |
| `warp-prism/docs/design/catalog-policy.md` | Create/update catalog decision if not already present. |
| `warp-prism/pubspec.yaml` | Read existing project manifest. |
| `warp-prism/lib/` | Read existing codebase structure. |

### How

1. Verify tools first; do not fake output.
2. Prefer a minimal manual catalog app unless Widgetbook can be added cleanly.
3. Keep package public API tiny.
4. Add tests before claiming scaffold is valid.

### Why

The child project needs a real, testable baseline before component work begins. Tooling truth prevents phantom scaffolds that cannot be built by future agents.

---

## ⛔ Anti-Hallucination Guardrails

> [!CAUTION]
> Do not mark complete if Flutter is absent and no successful validation commands ran.

> [!CAUTION]
> Do not add live Cybernetics Core backend calls to the catalog scaffold.

> [!IMPORTANT]
> This task creates scaffold only; token/component MVPs belong to later tasks.

---

## 📋 Completion Evidence (preenchido pelo agente executor)

- **Arquivos criados/modificados**: Pending
- **Testes que verificam o trabalho**: Pending
- **Resultado dos comandos de validação**: Pending
- **Entrada no CHANGELOG**: Pending
- **Agent-wiki / docs institucionalização**: Pending
- **Agente executor**: Pending
- **Data de conclusão**: Pending
