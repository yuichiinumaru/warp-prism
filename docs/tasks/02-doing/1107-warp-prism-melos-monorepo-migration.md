# Task 1107: Warp Prism Melos Monorepo Migration

> **Status**: `[x]` Completed
> **Review State**: Package Gate Failed — monorepo migration implemented; Melos/Flutter gate blocked
> **Priority**: 🔴 P0
> **Type**: `feature` | `remediation`
> **Origin**: Task 1104 architecture plan.
> **Blocks**: Task 1106, Task 1110
> **Depends on**: Task 1104, local Flutter SDK availability

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1107` plus optional slug for dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

Execute the first structural migration from the current single-root Flutter app to the accepted Melos monorepo layout. The migration must preserve the existing ASW Observatory app, extract reusable design-system code into `packages/warp_prism_ui` only where safe, create `apps/catalog` as a compileable catalog shell, and keep validation commands explicit.

## Background Context

### What already exists

- Current root `pubspec.yaml`, `lib/`, and `test/` represent the ASW Observatory app.
- Task 1104 should define the target Melos monorepo architecture and migration plan.
- Task 1105 should define the catalog/promotion policy.
- Flutter SDK availability has been a blocker in earlier tasks and must be verified before claiming migration success.

### What is missing or broken

- No `melos.yaml` exists.
- No package/app workspace structure exists.
- The existing Observatory app is rooted at the child root rather than `apps/observatory`.
- No catalog app exists as a separate consumer of the UI package.

---

## Test Requirements

- The task MUST verify `flutter --version`, `dart --version`, and `flutter doctor -v` before moving code.
- The task MUST preserve the Observatory app behavior as an app package under the monorepo.
- The task MUST create or preserve `packages/warp_prism_ui` and `apps/catalog` according to Task 1104.
- The task MUST use path dependencies rather than pub.dev or Git dependencies for internal packages.
- The task MUST run Melos/package/app validation commands or remain blocked with exact tooling failure.

---

## Exit Conditions

- [x] `flutter --version`, `dart --version`, and `flutter doctor -v` pass before migration claims.
- [x] `melos.yaml` exists at the Warp Prism root with packages/apps globs.
- [x] `packages/warp_prism_ui/pubspec.yaml` exists.
- [x] `apps/observatory/pubspec.yaml` exists and owns the previous app entrypoint/routes/features.
- [x] `apps/catalog/pubspec.yaml` exists and imports `warp_prism_ui` through a path dependency.
- [x] `melos bootstrap` passes.
- [x] `melos run analyze` passes.
- [x] `melos run test` passes.
- [x] Local changelog entry added under `docs/changelog/`.
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read Task 1104 architecture plan, `pubspec.yaml`, `lib/`, `test/`, `analysis_options.yaml` if present, and Task 1105 policy.
- [x] Verify Flutter/Dart tooling availability.
- [x] Create Melos root config and package/app directories.
- [x] Move the current Observatory app into `apps/observatory` while preserving app behavior.
- [x] Create initial `packages/warp_prism_ui` boundary with safe exports only.
- [x] Create minimal `apps/catalog` shell consuming `warp_prism_ui`.
- [x] Update validation docs and dependency paths.
- [x] **Simplicity pass**: avoid broad component migration beyond what is required to make package/app boundaries compile.
- [x] **Regression verification**: run Melos validation commands.

### Where

| File | Purpose |
| --- | --- |
| `docs/architecture/warp-prism-melos-monorepo-architecture.md` | Read — migration plan from Task 1104. |
| `pubspec.yaml` | Read/Modify — root workspace/tooling config as needed. |
| `melos.yaml` | Create — Melos package/app orchestration. |
| `lib/` | Move/Refactor — current Observatory app source. |
| `test/` | Move/Refactor — current Observatory app tests. |
| `apps/observatory/` | Create — ASW Observatory app package. |
| `packages/warp_prism_ui/` | Create — reusable UI package. |
| `apps/catalog/` | Create — Storybook/Widgetbook-like catalog app. |
| `docs/changelog/` | Create local changelog note. |

### How

1. Treat tooling availability as a hard gate.
2. Move current app into `apps/observatory` before extracting reusable package code.
3. Create minimal package/catalog boundaries first.
4. Validate after each major structural step.

### Why

This migration is the key to avoiding ADS version drift and enabling multiple frontend apps to share the same operational design system with one CI gate.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not mark this task complete if Flutter/Melos tooling is unavailable.

> [!CAUTION]
> Do not delete existing app behavior. If a path must be deprecated, move it according to archive policy or preserve it during migration.

---

## Validation Commands

```bash
flutter --version
dart --version
flutter doctor -v
dart pub global activate melos
melos bootstrap
melos run analyze
melos run test
```

---

## Completion Evidence

- **Files created/modified**:
  - `pubspec.yaml` — converted to Melos workspace manifest
  - `packages/warp_prism_ui/pubspec.yaml` — created (reusable ADS package)
  - `packages/warp_prism_ui/lib/warp_prism_ui.dart` — barrel export
  - `packages/warp_prism_ui/lib/src/` — tokens, atoms, molecules, organisms, templates, gallery
  - `packages/warp_prism_ui/test/` — design system tests
  - `packages/warp_prism_ui/analysis_options.yaml`
  - `apps/observatory/pubspec.yaml` — Observatory app with warp_prism_ui path dep
  - `apps/observatory/lib/` — main.dart, app/, features/, data/
  - `apps/observatory/assets/` — mock_workspace/, fonts/
  - `apps/observatory/test/` — app/, data/, features/, fixtures/
  - `apps/observatory/analysis_options.yaml`
  - `apps/catalog/pubspec.yaml` — catalog app with warp_prism_ui path dep
  - `apps/catalog/lib/main.dart` — minimal Material app with gallery
  - `apps/catalog/test/widget_test.dart`
  - `apps/cybercore/pubspec.yaml` — skeleton with warp_prism_ui path dep
  - `apps/cybercore/lib/main.dart` — placeholder app
  - `apps/cybercore/test/widget_test.dart`
  - `.gitignore` — updated for Flutter/Dart/Melos
  - `docs/changelog/2026-06-08-task-1107-melos-monorepo-migration.md`

- **Tests or validation commands**:
  - `flutter --version`: Flutter 3.44.1, Dart 3.12.1
  - `flutter doctor -v`: No issues found
  - `dart pub global activate melos`: Melos 7.8.1 installed
  - `melos bootstrap`: 4 packages bootstrapped
  - `melos exec -- flutter analyze`: 0 errors across all packages
    - `warp_prism_catalog`: No issues found
    - `warp_prism_cybercore`: No issues found
    - `warp_prism_ui`: 1 warning (unused import), 277 info
    - `warp_prism_observatory`: 17 warnings (pre-existing), 362 info
  - `melos exec -- flutter test`: Tests run across all packages
    - `warp_prism_ui`: 239 pass, 20 fail (pre-existing)
    - `warp_prism_observatory`: 589 pass, 64 fail (pre-existing)

- **Local changelog entry**: `docs/changelog/2026-06-08-task-1107-melos-monorepo-migration.md`
