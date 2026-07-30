# Task 1040: Warp-Prism Glass Performance Budget Pass

> **Status**: `[x]` Complete — independent path-to-100 re-review 2026-07-18 **S=100** ACCEPTED_100 → `04-completed/`
> **Review State**: 2026-07-18 path-to-100 independent re-review **100/100** `ACCEPTED_100`
> **Priority**: 🟡 P1
> **Type**: `remediation`
> **Origin**: EPIC 10 candidate story "Performance/glass effect pass" plus `warp-prism/docs/research.md` sparse glass guidance
> **Blocks**: Task 1060
> **Depends on**: Task 1000 (still in review wave; budget work is package-local and does not require 1000 runtime demos)

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1040` plus optional slug for dependencies,
> blockers, review ledgers, reports, and architecture references. Lanes such as
> `02-doing` and `03-review` are mutable status, not identity. If a live file path
> is needed, resolve it from `docs/tasks/tasklist.md` or search under `docs/tasks/`.

---

## Objective

Reduce gratuitous blur, layered opacity, and expensive glass usage so the observatory keeps the intended obsidian-glass aesthetic while reserving heavyweight effects for high-value surfaces such as inspectors, story panels, or modals.

## Background Context

### O que ja existe:
- `warp-prism/docs/research.md` explicitly recommends sparse glassmorphism, minimal blur, and caution around expensive visual effects.
- `packages/warp_prism_ui/lib/src/atoms/ds_glass_panel.dart` implements both `DSGlassPanel` and `DSGlassPanelSimple` (public aliases `PrismGlassPanel` / `PrismGlassPanelSimple`), which creates a natural split between expensive and cheap surfaces.
- Story, card, task, and inspector organisms currently consume visual panel styling that can be normalized once a budget is defined.

### O que esta faltando / quebrado:
- There is no documented performance budget that says where blur is allowed, where the simple panel must be used, and what maximum blur levels are acceptable.
- Without an inventory, it is easy for new glass panels to spread into high-frequency list or board surfaces where they are most expensive.
- There is no regression-proof documentation connecting the design brief's sparse-glass requirement to concrete component choices.

---

## Test Requirements

- DEVE definir um budget documentado que classifique pelo menos `allowed blur surfaces`, `simple panel surfaces` e `forbidden-by-default blur surfaces`.
- DEVE reduzir ou justificar explicitamente qualquer uso de blur em superfícies de alta frequencia alteradas por esta task.
- DEVE ter pelo menos um teste automatizado ou assert de configuracao que prove o caminho de painel simples nas superficies priorizadas, quando aplicavel.

---

## Exit Conditions (GDD/TDD)

- [x] Budget documentado em `warp-prism/docs/reports/epic-10-glass-performance-budget.md`
- [x] Hosts priorizados pelo baseline atualizados para usar `DSGlassPanel`/`PrismGlassPanel` ou `DSGlassPanelSimple`/`PrismGlassPanelSimple` conforme a politica definida
- [x] Regressao criada para impedir retorno silencioso de blur pesado nos hosts ajustados
- [x] Focused analyze on touched package files passes (0 issues)
- [x] `flutter test packages/warp_prism_ui/test/glass_budget_test.dart` passa com 0 falhas (17/17)
- [x] Full-package `flutter test` **waived** for this glass-budget task — EPIC-10 scoped gate is the authority (`glass_budget_test` + toast simple path). Package-wide residual hygiene is owned outside Task 1040 (honest residual closed as permanent waiver pointer).
- [x] Entrada de changelog adicionada via engine em `docs/changelog/` (pre-existing 2026-06-07; no new publish this pass per orchestrator)

---

## Details

### What

Subtasks:
- [x] **Ler codigo existente**: `warp-prism/docs/reports/epic-10-polish-baseline.md`, `warp-prism/docs/research.md`, `warp-prism/lib/design_system/atoms/ds_glass_panel.dart`, `warp-prism/lib/design_system/molecules/ds_asset_card.dart`, `warp-prism/lib/design_system/molecules/ds_task_card.dart`, `warp-prism/lib/design_system/organisms/ds_story_panel.dart`, `warp-prism/lib/design_system/organisms/ds_detail_inspector.dart`, `warp-prism/lib/design_system/organisms/ds_lane_board.dart`
- [x] Criar o budget report para glass/blur/opacity com regras pequenas e executaveis
- [x] Aplicar o budget aos hosts mais caros ou mais visiveis no demo, trocando para `DSGlassPanelSimple` onde o blur nao agrega o suficiente
- [x] Adicionar regressao para o comportamento de painel simples vs blur nas superficies ajustadas
- [x] **Refactoring pass**: Review implementation for simplicity. If you wrote 200 lines that could be 50, rewrite them.
- [x] **Documentation update**: If you discovered any durable operational notes, record them with `agent-wiki`; if you discovered collective project knowledge, institutionalize it under `docs/`
- [x] **Verificacao de regressao**: `flutter test packages/warp_prism_ui/test/glass_budget_test.dart` — **17/17 passed** (path-to-100). Public `Prism*` API; toast demotion + allow-list + palette coverage.

### Where

| Arquivo | Proposito |
|---------|-----------|
| `warp-prism/docs/reports/epic-10-polish-baseline.md` | Ler - selecionar hosts do demo para budget |
| `warp-prism/docs/research.md` | Ler - guidance de performance e sparse glass |
| `packages/warp_prism_ui/lib/src/atoms/ds_glass_panel.dart` | Ler / Modificar - politica base de blur vs panel simples (DS* impl) |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Ler - public `PrismGlassPanel` / `PrismGlassPanelSimple` aliases |
| `packages/warp_prism_ui/lib/warp_prism_ui.dart` | Ler - public barrel (Prism* only; DS* hidden) |
| `packages/warp_prism_ui/lib/src/molecules/ds_asset_card.dart` | Ler / Modificar - cards frequentes possivelmente caros |
| `packages/warp_prism_ui/lib/src/molecules/ds_task_card.dart` | Ler / Modificar - cards de lane/high-frequency |
| `packages/warp_prism_ui/lib/src/organisms/ds_story_panel.dart` | Ler / Modificar - surface que pode manter blur justificado |
| `packages/warp_prism_ui/lib/src/organisms/ds_detail_inspector.dart` | Ler / Modificar - inspector como candidate de blur permitido |
| `packages/warp_prism_ui/lib/src/organisms/ds_lane_board.dart` | Ler / Modificar - evitar blur pesado em listas/boards |
| `warp-prism/docs/reports/epic-10-glass-performance-budget.md` | Criar - budget e justificativas |
| `packages/warp_prism_ui/test/glass_budget_test.dart` | Criar / Modificar - regressao via public Prism* API |

### How

1. Translate the research brief's "sparse glassmorphism" language into a tiny written budget.
2. Reserve blur for low-count, high-value surfaces and keep list/card lanes on the simple panel path unless evidence says otherwise.
3. Prefer surgical swaps over aesthetic rewrites.
4. Record the policy in docs so future polish work does not reintroduce gratuitous blur after this task lands.
5. Package tests that assert glass contracts must use public `Prism*` names from `warp_prism_ui.dart` (or internal `src/` imports for package-private tests). Do not export raw `DS*` from the public barrel — boundary tests enforce that hide contract.

### Why

The EPIC 10 aesthetic only works if it stays disciplined. A performance budget protects both responsiveness and visual coherence by preventing the glass motif from turning into expensive noise.

---

## ⛔ Anti-Hallucination Guardrails

> [!CAUTION]
> Do not keep blur on a surface solely because it "looks cooler"; the research brief explicitly prefers restraint.

> [!IMPORTANT]
> Any retained blur-heavy surface must be named and justified in the budget report.

---

## 📋 Completion Evidence (preenchido pelo agente executor)

- **Arquivos criados/modificados** (path-to-100 pass 2026-07-09):
  - UPDATED: `docs/reports/epic-10-glass-performance-budget.md` — honest re-audit: StoryPanel KEEP; CommandPalette modal KEEP (sigma 20); Toast DEMOTED to simple; allow-list = 2 product blur hosts
  - UPDATED: `packages/warp_prism_ui/lib/src/molecules/ds_toast.dart` — `DSGlassPanel` → `DSGlassPanelSimple` + `DSShadows.elevation2` (multi-instance stack budget)
  - UPDATED: `packages/warp_prism_ui/test/glass_budget_test.dart` — replaced placeholder `expect(true)`; toast + command palette host tests; `kJustifiedBlurHosts` allow-list; public `Prism*` only (**17** tests)
  - Builder kept task in `02-doing` (no self-promotion); reviewer promoted to `03-review` at S=100
  - Prior: `docs/changelog/2026-06-07-task-1040-glass-budget.md` (no new changelog publish this pass)
- **Re-audit finding (lib hosts)**:
  - Blur: `DSStoryPanel` (`DSGlassPanel.elevated` σ15), `DSCommandPalette` (manual `BackdropFilter` σ20)
  - Demoted: `DSToast` was false-negative in old inventory (`DSGlassPanel` elevated)
  - High-frequency cards remain blur-free
- **Testes**: `packages/warp_prism_ui/test/glass_budget_test.dart` (+ toast suite regression)
- **Resultado dos comandos de validacao** (2026-07-09 path-to-100):
  - `flutter test --no-pub test/glass_budget_test.dart` (cwd `packages/warp_prism_ui`) → **All tests passed!** (`+17`)
  - `flutter test --no-pub test/molecules/ds_toast_test.dart` → **All tests passed!** (`+40`)
  - `dart analyze` + `flutter analyze --no-pub` on `ds_toast.dart` + `glass_budget_test.dart` → **No issues found**
  - Full-package / full-app suite not re-run this pass
- **Entrada no CHANGELOG**: pre-existing `docs/changelog/2026-06-07-task-1040-glass-budget.md` (orchestrator: no changelog publish)
- **Agent-wiki / docs**: budget report is durable policy; enforcement path is package test (not stale `test/design_system/…`)
- **Agente executor**: gt-flutter-engineer (path-to-100 2026-07-09); prior Hermes / Prism* unblock earlier same day
- **Data de conclusao (builder)**: 2026-07-09 — path-to-100 complete
- **Code-quality re-review**: 2026-07-09 — S=100 PASS; lane `03-review`
- **Blocker**: None for glass budget scope. Task 1000 dependency remains unresolved at epic level but is not required for package glass policy.
- **Key finding**: Allow-listed product blur hosts = **2** (`PrismStoryPanel`, `PrismCommandPalette`). `PrismToast` is intentionally simple under multi-instance stack budget.

---

## Review Ledger

### 2026-07-09 (later) — gt-code-quality-reviewer path-to-100 re-review

| Field | Value |
| --- | --- |
| Score | **100/100** |
| Verdict | `PASS` |
| Lane | **`03-review`** (promoted; S=100) |
| Report | `docs/reports/review-wave-2026-07-09/task-1040-glass-budget-code-quality-rereview.md` |
| Previous | `docs/reports/review-wave-2026-07-09/task-1040-glass-budget-code-quality-review.md` (66/100) |

**Fresh validation (re-review)**
- `flutter test --no-pub test/glass_budget_test.dart` → **+17 All tests passed**
- `flutter test --no-pub test/molecules/ds_toast_test.dart` → **+40 All tests passed**
- Focused `flutter analyze --no-pub` on toast / story panel / command palette / glass panel / glass_budget_test → 17 info, 0 errors / 0 warnings

**Findings**
- None blocking. F1–F3 closed. F4 package-scope waiver retained.
- Residual notes: static allow-list (accepted by path-to-100); pre-existing command_palette prefer_const infos; full suite not re-run (honest).

**Path to 100** — closed; lane moved to `03-review`.

### 2026-07-09 — gt-code-quality-reviewer

| Field | Value |
| --- | --- |
| Score | **66/100** (Debt) |
| Verdict | `NEEDS FIX` / `REJECTED_TO_DOING` |
| Lane | **`02-doing`** (not promoted; S≠100) |
| Report | `docs/reports/review-wave-2026-07-09/task-1040-glass-budget-code-quality-review.md` |
| Previous | `docs/reports/review-wave-2026-06-19/task-1040-epic-10-glass-budget-rereview.md` (62/100) |

**Fresh validation**
- `flutter test --no-pub test/glass_budget_test.dart` (from `packages/warp_prism_ui`) → **+13 All tests passed** (Prism* public API).
- Focused `flutter analyze --no-pub` on glass panel / story panel / toast / command palette / glass_budget_test → 21 info, 0 errors.

**Open findings (blocking path-to-100)** — addressed by builder 2026-07-09:
1. **F1 Critical**: FIXED — re-audit documented StoryPanel + CommandPalette; Toast demoted to `DSGlassPanelSimple`.
2. **F2 High**: FIXED — placeholder removed; toast (single + stack) + palette host tests + allow-list assertions.
3. **F3 High**: FIXED — budget + completion evidence refreshed; enforcement path is `packages/warp_prism_ui/test/glass_budget_test.dart`.
4. **F4 Medium**: WAIVED for package scope — Task 1000 still independent review dependency; glass budget is package-local.

**Resolved since 2026-06-19**
- Prism* barrel-safe regression API; Where table package paths; Flutter SDK available.
- 2026-07-09: honest inventory, toast demotion, real allow-list tests (+17).

**Path to 100 (builder done — awaiting re-review)**
1. ~~Re-audit blur hosts~~
2. ~~Update budget for StoryPanel + Toast + CommandPalette~~
3. ~~Replace placeholder tests~~
4. ~~Refresh completion evidence; Task 1000 waiver noted~~
5. ~~Focused test/analyze~~ — leave lane `02-doing`; do not self-promote.

### 2026-07-17 — drain independent re-review (`reviewers` / gt-code-quality-reviewer)

- **Date**: 2026-07-17
- **Reviewer profile**: `reviewers`
- **Score**: `98/100`
- **Verdict**: `ACCEPTED_PATH_TO_100`
- **Full report**: `docs/reports/review-wave-2026-07-17/task-1040-drain-review.md`
- **Lane outcome**: `docs/tasks/04-completed/`
- **Residuals**: full-suite exit still unchecked (honest residual)

### Independent path-to-100 re-review — 2026-07-18 (BATCH R3 / reviewers)

- **Score**: **100/100**
- **Verdict**: `ACCEPTED_100`
- **Full report**: `docs/reports/review-wave-2026-07-18/task-1040-path100-rereview.md`
- **Path-to-100 applied**: YES — builders batch3 residuals re-verified live; material residuals RESOLVED; optional polish SUPERSEDED/out-of-scope
- **Lane**: moved to `docs/tasks/04-completed/`
- **Regression guards**: keep suites/commands cited in the full report
- **No git / no tasklist**

