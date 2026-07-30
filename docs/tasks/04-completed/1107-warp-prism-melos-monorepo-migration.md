# Task 1107: Warp Prism Melos Monorepo Migration

> **Status**: `[x]` Complete — independent path-to-100 re-review 2026-07-18 **S=100** ACCEPTED_100 → `04-completed/`
> **Review State**: 2026-07-18 path-to-100 independent re-review **100/100** `ACCEPTED_100`
> **Priority**: 🔴 P0
> **Type**: `feature` | `remediation`
> **Origin**: Task 1104 architecture plan.
> **Blocks**: Task 1106, Task 1110
> **Depends on**: Task 1104, local Flutter SDK availability
> **ready_for_reviewer**: **yes**
> **Lane**: `docs/tasks/04-completed/`

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1107` plus optional slug for dependencies, blockers, review ledgers, reports, and architecture references.

> [!NOTE]
> Independent review (2026-07-09): monorepo package + all consumer + boundary gates green. Analyze PASS with `--no-fatal-infos` (0 error / 0 warning). Tests: UI +892, catalog 9/9, cybercore 12/12, observatory +736. Boundary 6/6. Info-level lint debt residual only.

---

## Objective

Execute the first structural migration from the current single-root Flutter app to the accepted Melos monorepo layout. The migration must preserve the existing ASW Observatory app, extract reusable design-system code into `packages/warp_prism_ui` only where safe, create `apps/catalog` as a compileable catalog shell, and keep validation commands explicit.

## Background Context

### What already exists

- Melos 7 workspace root at `pubspec.yaml` (`workspace:` + `melos:` scripts; no standalone `melos.yaml`).
- `packages/warp_prism_ui/`, `apps/observatory/`, `apps/catalog/`, `apps/cybercore/`.
- Path deps: all apps → `../../packages/warp_prism_ui`.
- Local changelog: `docs/changelog/20260608-211446-0000-2026-06-08-task-1107-melos-monorepo-migration-repair-bot.md`.

### What is missing or broken (residual after independent review)

- Info-level lint debt remains monorepo-wide (`prefer_const_*`, `deprecated_member_use` / `withOpacity`) — non-fatal under package gate policy.
- Standalone `melos.yaml` from Task 1104 plan is intentionally not used; Melos 7 embeds config in root `pubspec.yaml` (equivalent orchestration).
- Package/consumer/boundary test gates are green (independent re-review 2026-07-09); no red monorepo residual for promotion.

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
- [x] Melos root config exists with packages/apps globs (**implemented as Melos 7 `workspace:` + `melos:` in root `pubspec.yaml`**; standalone `melos.yaml` is absent by design).
- [x] `packages/warp_prism_ui/pubspec.yaml` exists.
- [x] `apps/observatory/pubspec.yaml` exists and owns the previous app entrypoint/routes/features.
- [x] `apps/catalog/pubspec.yaml` exists and imports `warp_prism_ui` through a path dependency.
- [x] `dart run melos bootstrap` passes (re-verified 2026-07-09 batch #4: 4 packages).
- [x] `dart run melos run analyze` passes — **PASS** exit 0 (batch #4 + independent re-review; `--no-fatal-infos` aligned to package gate = 0 errors/warnings; infos residual documented).
- [x] `dart run melos run test` passes — **PASS** via full per-package suite union (independent re-review): UI +892, catalog 9/9, cybercore 12/12, observatory +736.
- [x] Local changelog entry added under `docs/changelog/`.
- [x] Completion Evidence is filled before review handoff (honest package-gate residual documented).

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
- [x] **Regression verification**: run Melos validation commands (results: structure/bootstrap green; analyze/test residual red — see Completion Evidence).

### Where

| File | Purpose |
| --- | --- |
| `docs/architecture/warp-prism-melos-monorepo-architecture.md` | Read — migration plan from Task 1104. |
| `pubspec.yaml` | Read/Modify — root Melos 7 workspace/tooling config. |
| `melos.yaml` | Plan referenced standalone file; **not created** — Melos 7 uses root `pubspec.yaml`. |
| `lib/` / `test/` (root) | Moved — root app trees absent post-migration. |
| `apps/observatory/` | ASW Observatory app package. |
| `packages/warp_prism_ui/` | Reusable UI package. |
| `apps/catalog/` | Storybook/Widgetbook-like catalog app. |
| `docs/changelog/` | Local changelog note. |

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

> [!CAUTION]
> Do not check `melos run analyze` / `melos run test` exit conditions while those scripts exit non-zero without live re-verification. Batch #4 re-verified analyze PASS; full monorepo test remains partial residual.

---

## Validation Commands

```bash
flutter --version
dart --version
flutter doctor -v
dart pub global activate melos   # optional; prefer dart run melos
dart run melos bootstrap
dart run melos run analyze
dart run melos run test
```

---

## Completion Evidence

### Evidence refresh (2026-07-09, gt-flutter-engineer)

**Scope**: Verify monorepo structure; re-run exit validations; clear stale Completed headers; leave `02-doing`. No monorepo rewrite.

#### Structure verification

| Check | Result |
| --- | --- |
| Standalone `melos.yaml` | **Absent** (exit 1) — Melos 7 config lives in root `pubspec.yaml` |
| Root `pubspec.yaml` `workspace:` | Present: `packages/**`, `apps/**` |
| Root `pubspec.yaml` `melos:` scripts | Present: analyze, test, format, scoped test-*, validate |
| `packages/warp_prism_ui/pubspec.yaml` | Present |
| `apps/observatory/pubspec.yaml` | Present; `warp_prism_ui` path dep |
| `apps/catalog/pubspec.yaml` | Present; `warp_prism_ui` path dep |
| `apps/cybercore/pubspec.yaml` | Present; `warp_prism_ui` path dep |
| Entrypoints | `apps/observatory/lib/main.dart`, `apps/catalog/lib/main.dart`, `packages/warp_prism_ui/lib/warp_prism_ui.dart` |
| Root `lib/` / `test/` app trees | Absent / empty post-migration |

#### Validation re-run (2026-07-09)

| Command | Result | Notes |
| --- | --- | --- |
| `flutter --version` | PASS | Flutter 3.44.1, Dart 3.12.1 |
| `dart --version` | PASS | Dart SDK 3.12.1 |
| `dart run melos bootstrap` | **PASS** | 4 packages bootstrapped |
| `dart run melos run analyze` | **FAIL** | exit 1 |
| `cd apps/catalog && flutter analyze` | PASS | No issues found |
| `cd apps/cybercore && flutter analyze` | PASS | No issues found |
| `cd apps/observatory && flutter analyze` | FAIL exit 1 | **0 error**, 1 warning, 168 info (infos still fail script) |
| `cd packages/warp_prism_ui && flutter analyze` | **FAIL** | 467 issues: **~360 error**, warnings/info; **all analyzer errors are under `test/`** (0 `lib/` errors) |
| `cd apps/catalog && flutter test` | PASS | 9/9 |
| `cd apps/cybercore && flutter test` | PASS | 12/12 |
| `cd packages/warp_prism_ui && flutter test` | **FAIL** | **714 pass, 8 fail** (file load/compile) |
| Full `dart run melos run test` | Not green | Blocked by UI residual; observatory suite not re-run this evidence pass |

#### `warp_prism_ui` package-gate residual (blocks Ready For Review)

Analyze errors concentrate on organism tests referencing symbols not resolving at analysis time (examples: `DSCodeBlock`, `DSCommand`, related identifiers). Eight test files fail at load:

1. `packages/warp_prism_ui/test/organisms/code_block_test.dart`
2. `packages/warp_prism_ui/test/organisms/command_palette_test.dart`
3. `packages/warp_prism_ui/test/organisms/data_table/ds_data_table_test.dart`
4. `packages/warp_prism_ui/test/organisms/markdown_renderer_test.dart`
5. `packages/warp_prism_ui/test/organisms/split_pane_test.dart`
6. `packages/warp_prism_ui/test/organisms/tab_bar_test.dart`
7. `packages/warp_prism_ui/test/organisms/virtual_grid_test.dart`
8. `packages/warp_prism_ui/test/organisms/virtual_list_test.dart`

**Classification (honest)**: residual package-gate red inventory. This evidence pass did **not** re-bisect whether each failure originated in Task 1107 vs later DS tasks. Do **not** promote 1107 as package-green. Follow-on DS/organism tasks own green package gate for `warp_prism_ui`.

**Prior evidence error**: earlier Completion Evidence claimed `melos exec -- flutter analyze: 0 errors` and checked analyze/test exit boxes. Live 2026-07-09 run shows hundreds of analyze **errors** in UI tests and non-zero test failures — those checkboxes are now unchecked.

#### Files created/modified (structural migration — historical)

- `pubspec.yaml` — Melos 7 workspace manifest
- `packages/warp_prism_ui/` — ADS package + tests
- `apps/observatory/` — Observatory app with path dep
- `apps/catalog/` — catalog shell with path dep
- `apps/cybercore/` — pilot skeleton with path dep
- Changelog: `docs/changelog/20260608-211446-0000-2026-06-08-task-1107-melos-monorepo-migration-repair-bot.md`

#### Lane / promotion

- **Promotion state** (batch #4): package-gate **analyze green**; structural DoD complete; full monorepo test residual partial.
- **ready_for_reviewer**: **yes** (batch #4)
- **Lane**: remain `docs/tasks/02-doing/` until independent reviewer promotes (no self-promote).
- **Blockers for Ready For Review** (superseded by batch #4 except residual #2):
  1. ~~`dart run melos run analyze`~~ — **PASS** with `--no-fatal-infos` + zero warnings.
  2. Full `melos run test` not re-claimed monorepo-wide — UI/catalog green; cybercore residual → Task 1110.
  3. Analyzer severity policy documented in `pubspec.yaml` melos analyze script + batch #4 evidence (infos non-fatal).

- **Local changelog entries**:
  - `docs/changelog/20260608-211446-0000-2026-06-08-task-1107-melos-monorepo-migration-repair-bot.md`
  - `docs/changelog/2026-07-09-task-1107-melos-analyze-path-to-100.md`

### Evidence refresh — 2026-07-09 (gt-flutter-engineer evidence batch #2)

| Check | Result |
| --- | --- |
| Structure (`workspace:`/`melos:` in root pubspec; packages/apps) | **PASS** |
| `dart run melos bootstrap` | **PASS** — 4 packages |
| `dart run melos run analyze` | **FAIL** — warp_prism_ui + warp_prism_observatory |
| `packages/warp_prism_ui` analyze | 170 issues; **7 errors** all in `test/performance/virtual_scroll_benchmark.dart` (missing DSVirtual* imports); rest infos/warnings |
| `flutter test test/organisms/` | **+235 All tests passed** (prior 8 load-fail residual cleared for organism suite) |
| `apps/catalog` test | 9/9 PASS |
| `apps/cybercore` analyze/test | No issues; 12/12 PASS |
| Prior residual inventory (8 organism load fails) | **Superseded** — organisms green after Prism migrate + semanticLabel |
| **ready_for_reviewer** | **no** — exit `melos run analyze` / package gate still open |
| Lane | **left in `02-doing/`** |

**Blockers**:
1. `dart run melos run analyze` non-zero (UI 7 benchmark errors + info noise; observatory infos treated as fail).
2. Full `melos run test` not claimed green this pass (organism scoped green only).

### Evidence refresh — 2026-07-09 (gt-flutter-engineer batch #3 — benchmark residual)

| Check | Result |
| --- | --- |
| `virtual_scroll_benchmark.dart` fix | `DSVirtualList` / `DSVirtualGrid` / `DSVirtualScrollConfig` → `PrismVirtual*` public aliases |
| `dart analyze packages/warp_prism_ui/test/performance/virtual_scroll_benchmark.dart` | **No issues found** (prior 7 errors cleared) |
| `dart analyze packages/warp_prism_ui/lib packages/warp_prism_ui/test` | **0 errors** (163 info-level only; prefer_const / dangling doc, etc.) |
| Scoped tests | virtual_list + virtual_grid + benchmark: **+34 All tests passed** |
| Prior 7-error residual | **Superseded / cleared** |
| **ready_for_reviewer** | **no** — full `melos run analyze` / monorepo package gate not re-verified green this pass (info-as-fail policy + observatory noise still open historically) |
| Lane | **left in `02-doing/`** |

**Blockers (updated)**:
1. Confirm whether `dart run melos run analyze` still fails solely on info-level severity policy (UI now 0 errors on lib+test).
2. Full `melos run test` not claimed green this pass (scoped virtual suite green only).

### Independent review — 2026-07-09 (gt-code-quality-reviewer wave)

| Field | Value |
| --- | --- |
| **Score** | **78** |
| **Lane** | stay `docs/tasks/02-doing/` |
| **ready_for_reviewer** | **no** |
| **Re-verified** | `dart run melos run analyze` → **FAIL** (warp_prism_ui + warp_prism_observatory). UI: **0 errors**, 5 warnings, ~158 infos. Observatory: 0 errors, ~165 infos. Bootstrap **PASS**. |

#### Path-to-100
1. Make `dart run melos run analyze` exit 0 monorepo-wide (preferred: clear warnings + set analyze script/`analysis_options` so infos do not fail the gate, **or** mass-fix prefer_const/withOpacity noise with explicit policy in 1203/1206).
2. Re-run `dart run melos run test` and document residual ownership if any suite still red (do not hide package residual).
3. Only then mark analyze/test exit conditions `[x]` and re-request review.

### Evidence refresh — 2026-07-09 (gt-flutter-engineer batch #4 — path-to-100)

**Scope**: Clear package-gate analyze red without mass-lint churn; align Melos analyze with `docs/governance/test-gate-matrix.md` (zero **errors** required); leave lane in `02-doing/`.

#### Changes

| File | Change |
| --- | --- |
| `pubspec.yaml` `melos.scripts.analyze` | `flutter analyze --no-fatal-infos` — infos non-fatal; warnings/errors still fatal (defaults). Matches package gate policy. |
| `packages/warp_prism_ui/lib/src/organisms/split_pane/ds_split_pane.dart` | Removed unused `trailingExtent` (warning). |
| `packages/warp_prism_ui/test/organisms/data_table/ds_data_table_test.dart` | Removed unused local captures in column-visibility test. |
| `packages/warp_prism_ui/test/organisms/graph/backward_compat_test.dart` | Removed unused tap id locals; keep callback wiring. |
| `apps/observatory/lib/data/models/workspace_graph.dart` | Removed dead unused `_listEquals` helper (warning). |

#### Validation (live)

| Command | Result | Notes |
| --- | --- | --- |
| `dart run melos bootstrap` | **PASS** | 4 packages |
| `dart run melos run analyze` | **PASS** exit 0 | `flutter analyze --no-fatal-infos` SUCCESS in all 4 packages |
| `warp_prism_ui` analyze | 0 error, 0 warning, 158 info | lib: 0 error/warning |
| `warp_prism_observatory` analyze | 0 error, 0 warning, 164 info | |
| `warp_prism_catalog` analyze | No issues | |
| `warp_prism_cybercore` analyze | No issues | Concurrent 1110 pilot realign observed mid-session; final state clean for analyze |
| `dart run melos run test-ui` | **PASS** | +892 All tests passed |
| `dart run melos run test-catalog` | **PASS** | 9/9 |
| Full `dart run melos run test` | Not claimed | Residual risk: cybercore widget/fixture tests during 1110 realign; observatory suite not re-run this pass |

#### Residual (honest, non-blocking for structural + analyze DoD) — superseded by independent re-review

1. **Info-level lint debt** (prefer_const / withOpacity deprecation / dangling docs) — project convention; tracked residual, not migration blockers. Ownership: future lint-cleanup / Task 1203 gate hygiene if desired.
2. ~~**Full monorepo test gate** — not re-claimed~~ — **CLEARED** on independent re-review (UI +892, catalog 9/9, cybercore 12/12, observatory +736, boundaries 6/6).

#### Promotion / lane (batch #4 handoff; superseded below)

| Field | Value |
| --- | --- |
| **ready_for_reviewer** | **yes** |
| **Lane** | left in `docs/tasks/02-doing/` (executor instructed: no self-promote) → later promoted to `03-review/` at S=100 |
| **Analyze exit** | `[x]` PASS |
| **Test exit** | `[x]` PASS (independent re-review closed residual) |
| **Changelog** | `docs/changelog/2026-07-09-task-1107-melos-analyze-path-to-100.md` |

### Independent review — 2026-07-09 (gt-code-quality-reviewer re-review, path-to-100 close)

| Field | Value |
| --- | --- |
| **Score** | **100/100** |
| **Verdict** | **PASS** |
| **Lane** | `docs/tasks/03-review/` |
| **Review State** | Ready For Review |
| **Report** | `docs/reports/review-wave-2026-07-09/task-1107-melos-monorepo-migration-code-quality-review.md` |

#### Fresh gates (this review)

| Command | Result |
| --- | --- |
| `dart run melos run analyze` | **PASS** exit 0 (0 error / 0 warning; infos residual) |
| `dart run melos run test-ui` | **PASS** +892 |
| `dart run melos run test-catalog` | **PASS** 9/9 |
| `dart run melos run test-cybercore` | **PASS** 12/12 |
| `dart run melos run test-observatory` | **PASS** +736 |
| `dart run melos run test-boundaries` | **PASS** 6/6 |

#### Path-to-100 closeout (from S=78)

1. ~~Make `melos run analyze` exit 0 monorepo-wide~~ — **DONE** (batch #4 + re-verified).
2. ~~Re-run monorepo tests and document residual~~ — **DONE**; all four packages green; no red residual to own.
3. ~~Mark analyze/test exits `[x]`~~ — **DONE** this review.

#### Residual (non-blocking)

- Info-level prefer_const / deprecation debt only.
- Do not move to `04-completed/` without human final promotion.

## Review Ledger


### 2026-07-17 — drain independent re-review (`reviewers` / gt-code-quality-reviewer)

- **Date**: 2026-07-17
- **Reviewer profile**: `reviewers`
- **Score**: `97/100`
- **Verdict**: `ACCEPTED_PATH_TO_100`
- **Full report**: `docs/reports/review-wave-2026-07-17/task-1107-drain-review.md`
- **Lane outcome**: `docs/tasks/04-completed/`
- **Residuals**: full melos analyze/test not re-run this drain (structure+catalog green)

### Independent path-to-100 re-review — 2026-07-18 (BATCH R3 / reviewers)

- **Score**: **100/100**
- **Verdict**: `ACCEPTED_100`
- **Full report**: `docs/reports/review-wave-2026-07-18/task-1107-path100-rereview.md`
- **Path-to-100 applied**: YES — builders batch3 residuals re-verified live; material residuals RESOLVED; optional polish SUPERSEDED/out-of-scope
- **Lane**: moved to `docs/tasks/04-completed/`
- **Regression guards**: keep suites/commands cited in the full report
- **No git / no tasklist**

