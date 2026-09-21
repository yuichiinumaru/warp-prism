# Task 1103: Warp Prism Flutter Tooling And Scaffold

> **Review State**: 2026-07-18 path-to-100 independent re-review **100/100** `ACCEPTED_100`
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
> - **Task 1104** — Melos monorepo architecture plan (`03-review/`, 100/100).
> - **Task 1107** — Melos monorepo migration (`03-review/`, 100/100): creates
>   `packages/warp_prism_ui/`, `apps/observatory/`, `apps/catalog/`,
>   `apps/cybercore/`, and Melos 7 config in root `pubspec.yaml`.
>
> **CLOSEOUT (2026-07-15)**: Both superseding tasks are in `03-review/` with
> 100/100 internal review. All scaffold objectives from this task are fulfilled
> by Tasks 1104+1107. This task is now closed as **SUPERSEDED** — terminal state.
> No executor action required. The old scaffold subtasks are not executed because
> they conflict with the approved Melos monorepo layout.

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

> All exit conditions are **SUPERSEDED** by Tasks 1104 + 1107. Individual gates
> are not independently verified for this closeout; the superseding tasks carry
> their own exit conditions.

- [~] `flutter --version`, `flutter doctor -v`, and `dart --version` pass before scaffold creation. — **SUPERSEDED** by Task 1107 (tooling verified there).
- [~] If Flutter/Dart tooling is unavailable, this task remains blocked/open and is not marked complete. — **SUPERSEDED** (tooling is now present: Flutter 3.44.1, Dart 3.12.1).
- [~] `warp-prism/packages/warp_prism_ui/` exists with compileable package skeleton. — **SUPERSEDED** by Task 1107 (`packages/warp_prism_ui/pubspec.yaml` present).
- [~] `warp-prism/apps/warp_prism_catalog/` exists with compileable catalog app skeleton. — **SUPERSEDED** by Task 1107 (created as `apps/catalog/` per Melos layout).
- [~] From `warp-prism/packages/warp_prism_ui/`, `dart format --set-exit-if-changed .` passes. — **SUPERSEDED** by Task 1107.
- [~] From `warp-prism/packages/warp_prism_ui/`, `flutter analyze` passes. — **SUPERSEDED** by Task 1107 (0 errors, 0 warnings with `--no-fatal-infos`).
- [~] From `warp-prism/packages/warp_prism_ui/`, `flutter test` passes. — **SUPERSEDED** by Task 1107 (+892 UI tests pass).
- [~] From `warp-prism/apps/warp_prism_catalog/`, `dart format --set-exit-if-changed .` passes. — **SUPERSEDED** by Task 1107.
- [~] From `warp-prism/apps/warp_prism_catalog/`, `flutter analyze` passes. — **SUPERSEDED** by Task 1107 (no issues).
- [~] From `warp-prism/apps/warp_prism_catalog/`, `flutter test` passes. — **SUPERSEDED** by Task 1107 (9/9 pass).
- [~] Widgetbook decision is documented as immediate, deferred, or not chosen for MVP. — **SUPERSEDED** by Task 1104 architecture plan (§catalog section).
- [~] `bash .agents/skills/project-management/sub-skills/manage-changelog/scripts/rebuild.sh validate` passes. — **SUPERSEDED** (not applicable to superseded closeout; pre-existing unrelated failures exist per Task 1104 evidence).
- [~] Changelog entry is added through the changelog engine. — **SUPERSEDED** (superseded tasks do not require independent changelog entries).

---

## Details

### What

Subtasks:

- [x] **Ler o código existente antes de modificar**: read `warp-prism/`, Task 1101 docs, Task 1102 inventory, and repository child-project rules before writing. — **DONE** (task authoring read context; supersession note proves codebase awareness).
- [~] Run tooling checks: `flutter --version`, `flutter doctor -v`, `dart --version`. — **SUPERSEDED** by Task 1107 (tooling verified there; live check confirms Flutter 3.44.1, Dart 3.12.1).
- [~] Create `packages/warp_prism_ui` with `pubspec.yaml`, `analysis_options.yaml`, `lib/warp_prism_ui.dart`, minimal `src/`, and tests. — **SUPERSEDED** by Task 1107.
- [~] Create `apps/warp_prism_catalog` with `pubspec.yaml`, `analysis_options.yaml`, `lib/main.dart`, minimal catalog shell, and tests. — **SUPERSEDED** by Task 1107 (created as `apps/catalog/` per Melos layout).
- [~] Add README or docs with package/catalog validation commands. — **SUPERSEDED** by Task 1107 and Task 1104 architecture doc.
- [~] **Refactoring pass**: keep scaffold minimal and remove unused generated code if templates produce noise. — **SUPERSEDED** (no scaffold generated; Task 1107 migrated existing code).
- [~] **Documentation update**: record Widgetbook/catalog decision. — **SUPERSEDED** by Task 1104 architecture plan.
- [~] **Verificação de regressão**: run format/analyze/test commands. — **SUPERSEDED** by Task 1107 (full monorepo validation).

### Where

> **Historical intent only (superseded by Tasks 1104/1107).** Rows below describe the original flat-scaffold create targets. Live Melos layout is `packages/warp_prism_ui/`, `apps/catalog/` (**not** `apps/warp_prism_catalog/`), `apps/observatory/`, `apps/cybercore/`. Root `lib/` and root `test/` are **absent** post-migration.

| Arquivo | Propósito |
|---------|-----------|
| `warp-prism/` | Read and then modify child-project root. *(historical)* |
| `warp-prism/packages/warp_prism_ui/pubspec.yaml` | Create package manifest. *(live path still valid)* |
| `warp-prism/packages/warp_prism_ui/analysis_options.yaml` | Create package analysis configuration. *(live)* |
| `warp-prism/packages/warp_prism_ui/lib/warp_prism_ui.dart` | Create public package entrypoint. *(live)* |
| `warp-prism/packages/warp_prism_ui/lib/src/` | Create minimal package source tree. *(live)* |
| `warp-prism/packages/warp_prism_ui/test/` | Create initial package tests. *(live)* |
| `warp-prism/apps/warp_prism_catalog/pubspec.yaml` | **Superseded** → live `apps/catalog/pubspec.yaml` |
| `warp-prism/apps/warp_prism_catalog/analysis_options.yaml` | **Superseded** → live `apps/catalog/analysis_options.yaml` |
| `warp-prism/apps/warp_prism_catalog/lib/main.dart` | **Superseded** → live `apps/catalog/lib/main.dart` |
| `warp-prism/apps/warp_prism_catalog/test/` | **Superseded** → live `apps/catalog/test/` |
| `warp-prism/docs/design/charter.md` | Read prerequisite charter. |
| `warp-prism/docs/design/component-inventory.md` | Read prerequisite inventory. |
| `warp-prism/docs/design/catalog-policy.md` | Create/update catalog decision if not already present. |
| `warp-prism/pubspec.yaml` | Read existing project manifest. *(now Melos root)* |
| `warp-prism/lib/` | **Historical** pre-migration root app tree — **absent** live |

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

### Supersession Closeout — 2026-07-15 (builders, `gt-evidence-refresher`)

**Mode**: `worker-dry-run` evidence-only; superseded closeout; no git/tasklist/changelog-publish/agent-wiki.

**Why**: Task 1103's scaffold objectives are fully fulfilled by Tasks 1104 (architecture plan, 100/100) and 1107 (monorepo migration, 100/100). Executing the old flat scaffold subtasks would conflict with the approved Melos monorepo layout. This closeout is honest governance, not implementation.

#### Supersession evidence (live filesystem)

| Claim | Command | Result |
| --- | --- | --- |
| `packages/warp_prism_ui/pubspec.yaml` exists | `test -f packages/warp_prism_ui/pubspec.yaml && echo EXISTS` | `EXISTS` |
| `apps/observatory/pubspec.yaml` exists | `test -f apps/observatory/pubspec.yaml && echo EXISTS` | `EXISTS` |
| `apps/catalog/pubspec.yaml` exists (replaces `apps/warp_prism_catalog/`) | `test -f apps/catalog/pubspec.yaml && echo EXISTS` | `EXISTS` |
| `apps/cybercore/pubspec.yaml` exists | `test -f apps/cybercore/pubspec.yaml && echo EXISTS` | `EXISTS` |
| Melos 7 workspace in root `pubspec.yaml` | `grep 'workspace:' pubspec.yaml` | `workspace:` present |
| Standalone `melos.yaml` absent | `test -f melos.yaml && echo EXISTS \|\| echo ABSENT` | `ABSENT` (Melos 7 design: config in root pubspec) |
| Root `lib/` absent post-migration | `ls lib/ 2>&1` | `ls: cannot access 'lib/': No such file or directory` |
| Root `test/` absent post-migration | `ls test/ 2>&1` | `ls: cannot access 'test/': No such file or directory` |

#### Tooling verification (live)

| Command | Result |
| --- | --- |
| `flutter --version` | Flutter 3.44.1, Dart 3.12.1 |
| `dart --version` | Dart SDK 3.12.1 |

Note: Tooling was absent when Task 1103 was written (`flutter --version` returned command not found). It is now present and was verified as part of Task 1107's migration gate.

#### Superseding task status

| Task | Lane | Status | Review Score |
| --- | --- | --- | --- |
| Task 1104 (Melos architecture plan) | `03-review/` | `[x]` Ready For Review | 100/100 |
| Task 1107 (Melos monorepo migration) | `03-review/` | `[x]` Ready For Review | 100/100 |

#### Files touched

- `docs/tasks/03-review/1103-warp-prism-flutter-tooling-and-scaffold.md` — header, exit conditions, subtasks, completion evidence, and internal builder review note updated for superseded closeout after lane promotion.

#### Exit conditions: 0 independently satisfied; 13/13 superseded

All exit conditions are marked `[~]` superseded. The original scaffold paths (`packages/warp_prism_ui`, `apps/warp_prism_catalog`) have been replaced by the Melos layout (`apps/catalog`) created by Task 1107. Individual format/analyze/test gates are owned by Task 1107's evidence chain.

#### Changelog

No independent changelog entry for this superseded closeout. Superseded tasks do not require changelog entries per local governance. Task 1104 and Task 1107 each carry their own changelog entries.

#### Anti-hallucination compliance

- ✅ No scaffold code was executed that conflicts with the Melos monorepo.
- ✅ No files were created in the old flat `packages/` or `apps/` paths.
- ✅ No `git` or `jj` operations were performed; no lane move occurred during the evidence-only refresher. The final reviewer-owned lane move occurred only after 100/100 acceptance.
- ✅ No generated surfaces (tasklist, changelog engine, index) were modified.
- ✅ Substantive content of the task was not rewritten — only status markers, exit conditions, subtask checkboxes, and completion evidence were updated.

### Internal builder review — 2026-07-15 (`gt-code-quality-reviewer`)

**Score**: 100/100  
**Verdict**: ACCEPTED — superseded/tooling-only closeout is truthful and terminal. Move to `docs/tasks/03-review/`.

**Fresh evidence reviewed**:

- Full Task 1103 file read and checked for terminal supersession wording.
- Superseding evidence read: Task 1104 and Task 1107 are both in `docs/tasks/03-review/` with recorded 100/100 reviews.
- Live structure verification confirms Task 1107's approved Melos layout exists: `packages/warp_prism_ui/pubspec.yaml`, `apps/catalog/pubspec.yaml`, `apps/observatory/pubspec.yaml`, `apps/cybercore/pubspec.yaml`, root `pubspec.yaml` `workspace:`/`melos:` config.
- Obsolete scaffold path `apps/warp_prism_catalog/` is absent; root `lib/` and root `test/` are absent post-migration; standalone `melos.yaml` is absent by Melos 7 design.
- Tooling spot-check: `flutter --version` → Flutter 3.44.1 / Dart 3.12.1; `dart --version` → Dart SDK 3.12.1.

**Residual risks**: none for Task 1103. It intentionally performs no obsolete scaffold implementation and delegates package/app validation to superseding Task 1107.

> **STATUS**: Superseded closeout complete. Terminal state. No further action required.

## Review Ledger


### 2026-07-17 — drain independent re-review (`reviewers` / gt-code-quality-reviewer)

- **Date**: 2026-07-17
- **Reviewer profile**: `reviewers`
- **Score**: `96/100`
- **Verdict**: `ACCEPTED_PATH_TO_100`
- **Full report**: `docs/reports/review-wave-2026-07-17/task-1103-drain-review.md`
- **Lane outcome**: `docs/tasks/04-completed/`
- **Residuals**: superseded closeout; Where table historical path hygiene

### Independent path-to-100 re-review — 2026-07-18 (BATCH R3 / reviewers)

- **Score**: **100/100**
- **Verdict**: `ACCEPTED_100`
- **Full report**: `docs/reports/review-wave-2026-07-18/task-1103-path100-rereview.md`
- **Path-to-100 applied**: YES — builders batch3 residuals re-verified live; material residuals RESOLVED; optional polish SUPERSEDED/out-of-scope
- **Lane**: moved to `docs/tasks/04-completed/`
- **Regression guards**: keep suites/commands cited in the full report
- **No git / no tasklist**

