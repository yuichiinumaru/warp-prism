# Task 0411: Warp Prism Shell Navigation And Responsive Frame

> **Status**: `[x]` Done — held in review (path-to-100)
> **Review State**: Independent re-review **93/100** — `HELD_IN_REVIEW_PATH_TO_100` (2026-07-09)
> **Priority**: 🔴 P0
> **Type**: `feature`
> **Origin**: EPIC-04 Warp Prism Product Shell and Overview
> **Blocks**: Task 0412, Task 0413
> **Depends on**: Task 0410 and EPIC-01 design-system API coherence

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 0411` plus optional slug for dependencies,
> blockers, review ledgers, reports, and architecture references. Lanes such as
> `02-doing` and `03-review` are mutable status, not identity. If a live file path
> is needed, resolve it from `docs/tasks/tasklist.md` or search under `docs/tasks/`.

---

## Objective

Implement the actual product shell frame around the router by composing the existing design-system organisms into a desktop-first navigation experience with left rail, central content area, optional right inspector region, and a credible small-layout fallback that does not require later feature epics to redesign shell ownership.

## Background Context

### O que já existe:
- `warp-prism/lib/design_system/organisms/ds_shell.dart` already defines wide and responsive shell organisms.
- `warp-prism/lib/design_system/organisms/ds_sidebar.dart`, `ds_topbar.dart`, and `ds_detail_inspector.dart` provide intended shell building blocks.
- `warp-prism/docs/prompt.txt` defines desktop layout as left rail + central content + right inspector panel, with small-layout fallback via bottom navigation or collapsible nav.

### O que está faltando / quebrado:
- No routed app shell currently composes those organisms into a live navigation frame.
- `warp-prism/docs/draft.md` reports API mismatches across DS shell/template components, so the executor must verify current signatures before wiring.
- Without one authoritative shell container, later Overview and feature surfaces would each make incompatible layout choices.

---

## Test Requirements

- The shell MUST provide navigation affordances for Overview, Map, Operate, History, and Governance from a single shared frame.
- On wide layouts, the shell MUST render left navigation and preserve space for an inspector region without collapsing the central surface.
- On small layouts, the shell MUST switch to a credible fallback navigation mode and MUST NOT keep the desktop inspector permanently visible.
- The implementation MUST include widget tests that exercise at least one wide and one narrow layout.
- The shell MUST use existing design-system organisms where feasible instead of recreating ad-hoc scaffold widgets.

---

## Exit Conditions (GDD/TDD)

- [x] A shared routed shell widget exists and is used by the app router instead of duplicating navigation per page.
- [x] Left-rail navigation for the required top-level surfaces is implemented on desktop-width layouts.
- [x] A small-layout fallback is implemented with either collapsible navigation or bottom navigation, consistent with the prompt.
- [x] Inspector-region ownership is explicit: either a right pane on wide layouts or a deferred fullscreen/detail pattern on narrow layouts.
- [x] `warp-prism/test/app/shell_responsive_layout_test.dart` or equivalent verifies wide and narrow behavior.
- [x] From `warp-prism/apps/observatory/`, scoped `dart format --set-exit-if-changed` on shell sources/tests passes.
- [x] From `warp-prism/apps/observatory/`, scoped `flutter analyze` on shell sources/tests passes (no issues).
- [x] From `warp-prism/apps/observatory/`, `flutter test test/app/shell_responsive_layout_test.dart test/app/app_shell_smoke_test.dart` passes (14 tests).
- [x] Local Warp Prism changelog note added under `docs/changelog/` (parent `.changelog` engine path is not used for child-local ledger).
- [x] Changelog entry is added through the local changelog surface.

---

## Details

### What

Subtasks:
- [x] **Ler o código existente antes de modificar**: read Task 0410 outputs plus shell organisms, templates, prompt, and draft notes before writing.
- [x] Create or refine a shared shell widget that the router can wrap around routed feature content.
- [x] Wire navigation items and selected-state ownership so route changes and shell selection stay in sync.
- [x] Implement the small-layout fallback and explicitly suppress or transform the wide inspector pattern on narrow widths.
- [x] Add widget tests for responsive layout and route-driven navigation state.
- [x] **Refactoring pass**: remove shell duplication and keep navigation labels/keys centralized.
- [x] **Documentation update**: shell layout convention documented inline in `AppShell` class-level doc comments.
- [x] **Verificação de regressão**: scoped format, analyze, and targeted Flutter tests (live revalidation 2026-07-09).

### Where

| Arquivo | Propósito |
|---------|-----------|
| `apps/observatory/lib/app/router.dart` | Modify routed shell ownership and page wrapping. |
| `apps/observatory/lib/app/app.dart` | Read/adjust top-level shell composition if needed. |
| `packages/warp_prism_ui/lib/src/organisms/ds_shell.dart` | Read existing responsive shell APIs before wiring. |
| `packages/warp_prism_ui/lib/src/organisms/ds_sidebar.dart` | Read sidebar item APIs and selection behavior. |
| `packages/warp_prism_ui/lib/src/organisms/ds_topbar.dart` | Read topbar API for shell controls. |
| `packages/warp_prism_ui/lib/src/organisms/ds_detail_inspector.dart` | Read current inspector affordances. |
| `packages/warp_prism_ui/lib/src/templates/master_detail_template.dart` | Read template mismatch context before choosing reuse vs direct organism composition. |
| `apps/observatory/lib/features/shell/` | Create shell-local widgets or view helpers if needed. |
| `apps/observatory/test/app/shell_responsive_layout_test.dart` | Create/strengthen responsive shell test coverage. |
| `apps/observatory/lib/app/app_shell.dart` | Shared product shell (`AppShell`, `_CompactShell`). |
| monorepo layout note | Paths above reflect current Melos monorepo (not legacy flat `lib/`). |

### How

1. Reuse existing shell organisms first; introduce new shell helpers only if current templates are structurally mismatched.
2. Keep navigation state route-derived instead of maintaining a competing manual index.
3. Treat the inspector as a shell concern, not an Overview-only hack.
4. Verify narrow-width behavior with tests instead of assuming `LayoutBuilder` logic is correct.

### Why

The shell frame is the product’s navigation backbone. If it is not defined early and centrally, every screen epic will accrue layout debt, duplicate navigation logic, and conflicting responsive behavior.

---

## ⛔ Anti-Hallucination Guardrails

> [!CAUTION]
> Do not reimplement a second design system inside feature code just to get the shell working faster.

> [!CAUTION]
> Do not claim responsive support without a narrow-layout widget test.

> [!IMPORTANT]
> Use route-derived navigation state and verify current organism APIs before adding adapter code.

---

## 📋 Completion Evidence (preenchido pelo agente executor)

- **Arquivos criados/modificados**:
  - CREATED (prior): `apps/observatory/lib/app/app_shell.dart` — shared shell with `AppShell`, `PrismShellResponsive` (wide/medium), `_CompactShell` (narrow bottom nav), route-derived nav via `StatefulShellRoute`
  - MODIFIED (prior): `apps/observatory/lib/app/router.dart` — `AppShell` as `StatefulShellRoute.indexedStack` builder for five workspace branches
  - CREATED (prior): `apps/observatory/test/app/app_shell_smoke_test.dart` — shell smoke coverage
  - MODIFIED (2026-07-09): `apps/observatory/test/app/shell_responsive_layout_test.dart` — real `AppShell` harness (wide/narrow/medium/breakpoint/route-driven Map); Prism* only
  - CREATED (2026-07-09): `docs/changelog/2026-07-09-task-0411-shell-navigation-responsive-frame-live-validation.md`
- **Testes que verificam o trabalho**:
  - `test/app/shell_responsive_layout_test.dart` (11)
  - `test/app/app_shell_smoke_test.dart` (3)
- **Resultado dos comandos de validação** (from `apps/observatory/`, 2026-07-09):
  - `dart format --set-exit-if-changed lib/app/app_shell.dart lib/app/router.dart test/app/shell_responsive_layout_test.dart test/app/app_shell_smoke_test.dart` → pass (0 changed)
  - `flutter analyze` (same four paths) → No issues found
  - `flutter test test/app/shell_responsive_layout_test.dart test/app/app_shell_smoke_test.dart` → **14 passed**
- **Entrada no CHANGELOG**:
  - `docs/changelog/20260607-224047-0000-2026-06-07-task-0411-shell-navigation-responsive-frame-repair-bot.md` (original)
  - `docs/changelog/2026-07-09-task-0411-shell-navigation-responsive-frame-live-validation.md` (live validation)
- **Agent-wiki / docs institucionalização**: Shell layout convention in `AppShell` class-level docs; builders continuity handoff
- **Agente executor**: hermes-agent (impl) + builders (live validation / path-to-100)
- **Data de conclusao**: 2026-07-09
- **Self-score**: **100/100** (builder expert self-review; independent reviewer unavailable)
- **Blockers**: none remaining (Flutter SDK available; previous “SDK not installed” residual cleared)

### Builder expert self-review scorecard

| Criterion | Score | Notes |
|-----------|------:|-------|
| Shared routed shell ownership | 20/20 | `AppShell` wraps all five branches via `StatefulShellRoute` |
| Desktop left-rail + inspector ownership | 20/20 | `PrismShellResponsive` + explicit `showInspector: false` default |
| Compact fallback | 15/15 | Bottom nav < 600px; no permanent inspector |
| Prism* public API | 15/15 | No DS* in consumer shell/tests |
| Tests prove behavior | 15/15 | Production `AppShell` mounted; wide/narrow/medium + route |
| Validation evidence | 15/15 | format/analyze/tests green, scoped OOM-safe |
| **Total** | **100/100** | Builder self-score — superseded by independent ledger below |

---

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports. Persistent findings and regression guards are part of
> the acceptance contract.

### Latest Review

- **Date**: 2026-07-09
- **Reviewer profile**: `reviewers`
- **Score**: `93/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Full report**: `docs/reports/review-wave-2026-07-09/task-0411-shell-navigation-responsive-frame-independent-rereview.md`
- **Lane outcome**: remains in `03-review`
- **Task reference**: Task 0411 (`warp-prism-shell-navigation-and-responsive-frame`)

#### Current Open Blockers

- None for binary exits. Low: inspector always `showInspector: false`; compact nav is Material BottomNavigationBar.

#### Path-to-100 Summary

- Optional wide inspector injection API + test once features request inspector.
- Optional bottom-nav Semantics/touch-target proof.
- **Regression guard**: responsive tests must keep mounting production `AppShell` (not a layout reimplementation).

### Previous Reports

- `2026-06-19` — `72/100` — `docs/reports/review-wave-2026-06-19/0411-shell-navigation-responsive-frame-independent-review.md`
  - **Resolved since**: production AppShell harness; default route fixed; live 14/14 shell tests
  - **Regression guard**: no `_FakeNavigationShell` layout reimplementation
- `2026-06-14` — `100/100` — `docs/reports/build-gate-review/0411-review.md` (superseded; SDK blocked)


### 2026-07-18 — Path-to-100 independent re-review (reviewers / BATCH R2)
- **Score**: 97/100 — ACCEPTED_COMPLETE
- **Report**: `docs/reports/review-wave-2026-07-18/task-0411-path100-rereview.md`
- **path100_applied**: yes; residual path-to-100 list empty
- **Lane**: promoted to `docs/tasks/04-completed/`
- **Top finding**: Product residual only: inspector pane + compact Material bottom nav
