# Task 0012: Warp-Prism Design System API Normalization

> **Review State**: `ACCEPTED_100` — S=100/100 (2026-07-18); see `docs/reports/review-wave-2026-07-18/task-0012-path100-rereview.md`
> **Priority**: 🔴 P0
> **Type**: `remediation`
> **Origin**: EPIC-00 Warp-Prism Foundation and Compile Gate promotion
> **Blocks**: Task 0013 and later template/screen tasks
> **Depends on**: Task 0010
> **Builder Score**: 100/100 (task scope)

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 0012` when tracking compile-gate remediation and follow-up screen work.
>
> **Path note (post-monorepo)**: Deliverables live under `packages/warp_prism_ui/`, not the legacy `lib/design_system/` tree cited in the original Where table. Canonical locations are recorded in Completion Evidence.

---

## Objective

Normalize compile-breaking design-system API mismatches so Warp-Prism source files reference the symbols and parameters that actually exist. Completion means the codebase no longer mixes `DS*` and `Ds*` naming conventions arbitrarily, template files no longer call nonexistent shell parameters, and analyzer failures tied to design-system contract drift are either fixed or explicitly isolated.

## Background Context

### O que já existe:
- `packages/warp_prism_ui/lib/src/tokens/ds_colors.dart` defines `DSColors` rather than `DsColors`.
- `packages/warp_prism_ui/lib/src/organisms/ds_shell.dart` defines `DSShell`, `DSShellResponsive`, `sidebar`, `topbar`, `content`, `inspector`, and `showInspector`.
- `packages/warp_prism_ui/lib/src/organisms/ds_sidebar.dart` defines `DSSidebar` with `selectedId`, `onItemTap`, and `expanded` instead of the API assumed by templates.
- `packages/warp_prism_ui/lib/src/organisms/ds_topbar.dart` defines `DSTopbar` with `searchBar` and `showSearch` instead of the parameter set assumed by templates.

### O que está faltando / quebrado:
- ~~Legacy `master_detail_template.dart` / `ds_graph_canvas.dart` Ds* mismatches~~ — **resolved** (verified 2026-07-09 live).
- Public consumer surface is Prism* aliases via `prism_aliases.dart` / `warp_prism_ui.dart` (downstream of this normalization).

---

## Test Requirements

- DEVE eliminar referências a classes inexistentes derivadas apenas de casing inconsistente entre `DS*` e `Ds*`.
- DEVE alinhar chamadas de templates e organismos aos parâmetros reais expostos pelos widgets implementados.
- DEVE resolver ou isolar explicitamente as referências a tokens de cor inexistentes.
- DEVE reduzir o conjunto de erros do analyzer atribuídos a naming/API mismatch em relação ao baseline de Task 0010.

---

## Exit Conditions (GDD/TDD)

- [x] `master_detail_template.dart` usa símbolos e parâmetros reais do design system implementado
- [x] `ds_graph_canvas.dart` deixa de referenciar tokens de cor inexistentes ou documenta isolamento explícito de escopo se algum residual permanecer
- [x] Barrel exports e imports afetados permanecem coerentes após a normalização
- [x] Scoped `flutter analyze` on Task 0012 surfaces: 0 errors (info-only lints only)
- [x] Relevant tests pass with 0 failures (templates + token contract suites)
- [x] Entrada de changelog adicionada em `docs/changelog/`

---

## Details

### What

Subtasks:
- [x] **Ler código existente**: baseline Task 0010 + live monorepo paths under `packages/warp_prism_ui/`
- [x] Escolher a direção mínima de normalização por evidência atual: adaptar chamadas aos contratos existentes
- [x] Corrigir inconsistências de casing e nomes de símbolo que hoje impedem análise estática
- [x] Corrigir parâmetros inexistentes como `body:` onde o contrato real pede `content:` (DSShell uses `content:`; Scaffold narrow-mode `body:` is Flutter SDK, not DS drift)
- [x] Rerodar `flutter analyze` scoped to confirm naming/API drift is gone on deliverable surfaces
- [x] **Refactoring pass**: No code rewrite required this session — deliverables already normalized
- [x] **Documentation update**: Evidence refresh + changelog; continuity under builders profile
- [x] **Verificação de regressão**: live SDK analyze + scoped tests 2026-07-09

### Where

| Arquivo | Propósito |
|---------|-----------|
| `docs/reports/0010-warp-prism-foundation-audit-analyzer-baseline.md` | Ler - baseline de erros reais |
| `packages/warp_prism_ui/lib/src/tokens/ds_colors.dart` | Ler - fonte canônica dos tokens de cor |
| `packages/warp_prism_ui/lib/src/tokens/tokens.dart` | Ler - barrel dos tokens |
| `packages/warp_prism_ui/lib/src/organisms/ds_shell.dart` | Ler - contrato do shell |
| `packages/warp_prism_ui/lib/src/organisms/ds_sidebar.dart` | Ler - contrato da sidebar |
| `packages/warp_prism_ui/lib/src/organisms/ds_topbar.dart` | Ler - contrato da topbar |
| `packages/warp_prism_ui/lib/src/organisms/ds_graph_canvas.dart` | Ler - graph canvas (composable wrapper; no bad color tokens) |
| `packages/warp_prism_ui/lib/src/templates/master_detail_template.dart` | Ler - templates alinhados aos contratos reais |
| `packages/warp_prism_ui/lib/src/organisms/organisms.dart` | Ler - exports coerentes |
| `packages/warp_prism_ui/lib/src/templates/templates.dart` | Ler - exports coerentes |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Ler - Prism* public aliases for shell/sidebar/topbar/graph/colors |
| `packages/warp_prism_ui/lib/warp_prism_ui.dart` | Ler - public barrel exports Prism aliases only |

### How

1. Partir da baseline de Task 0010 e separar mismatches puramente nominais de mismatches estruturais de parâmetro.
2. Preferir a menor direção de convergência: atualizar poucos call sites para os contratos já implementados antes de renomear a design system inteira.
3. Tratar `master_detail_template.dart` e `ds_graph_canvas.dart` como hotspots principais.
4. Reexecutar analyze/tests no ambiente com Flutter SDK instalado.
5. Registrar residual fora de escopo (package-wide test import drift) sem misturar com esta remediação.

### Why

Enquanto a base alternar entre contratos `DS*` e `Ds*`, nenhuma tela ou bootstrap novo será estável. Esta task remove drift de API que impede compilação e evita que agentes futuros espalhem mais aliases e exceções pela árvore de design system.

---

## ⛔ Anti-Hallucination Guardrails

> [!CAUTION]
> DO NOT transformar esta task em redesign visual do design system. O objetivo é convergência de contrato para compile gate, não polish de UI.

> [!IMPORTANT]
> Antes de renomear qualquer símbolo exportado, confirme todos os call sites listados no baseline de Task 0010 e mantenha a mudança a menor possível para não criar churn desnecessário nas próximas epics.

---

## 📋 Completion Evidence (preenchido pelo agente executor)

### Original closeout (Hermes, 2026-06-07)

- **Arquivos criados/modificados**: Nenhum código modificado — normalização já estava completa. Task file atualizada.
- **Resultado dos comandos de validation**: BLOCKED — Flutter SDK não instalado (`which flutter` → not found). Verificação por inspeção de fonte.
- **Entrada no CHANGELOG**: N/A na época (sem mudança de código).
- **Agente executor**: Hermes Agent
- **Data de conclusão**: 2026-06-07

### Live evidence refresh (builders, 2026-07-09)

- **SDK**: Flutter 3.44.1 / Dart 3.12.1 at `/home/sephiroth/flutter/bin/flutter` — **installed and usable**. Prior Review State "Flutter SDK not installed" is **stale**.
- **Code changes this pass**: None (prefer evidence refresh over redesign). Deliverables already normalized under monorepo layout.
- **Arquivos verificados (exist + contract)**:
  - `packages/warp_prism_ui/lib/src/tokens/ds_colors.dart` — `DSColors` with asset/status/obsidian tokens
  - `packages/warp_prism_ui/lib/src/organisms/ds_shell.dart` — `DSShell(content:, sidebar:, topbar:, inspector:, showInspector:)`
  - `packages/warp_prism_ui/lib/src/organisms/ds_sidebar.dart` — `selectedId`, `onItemTap`, `expanded`
  - `packages/warp_prism_ui/lib/src/organisms/ds_topbar.dart` — `searchBar`, `showSearch`
  - `packages/warp_prism_ui/lib/src/organisms/ds_graph_canvas.dart` — no `DSColors.*` direct refs; composable graph wrapper
  - `packages/warp_prism_ui/lib/src/templates/master_detail_template.dart` — uses `DSShell`/`DSSidebar`/`DSTopbar` with real params; `content:` not DS `body:`
  - Barrels: `organisms.dart`, `templates.dart`, `tokens.dart` coherent
  - Public API: `prism_aliases.dart` exposes `PrismShell`, `PrismSidebar`, `PrismTopbar`, `PrismGraphCanvas`, `PrismColors`, etc.
- **Static naming checks**:
  - `rg '\bDs[A-Z]' packages/warp_prism_ui/lib` → **0 matches**
  - `rg 'DSColors\.(background|surface|border|accentGreen|accentAmber|accentMagenta|neutral500|neutral600)\b' packages/warp_prism_ui/lib` → **0 matches**
- **Scoped analyze** (Task 0012 surfaces only):

```text
flutter analyze \
  packages/warp_prism_ui/lib/src/tokens/ds_colors.dart \
  packages/warp_prism_ui/lib/src/tokens/tokens.dart \
  packages/warp_prism_ui/lib/src/organisms/ds_shell.dart \
  packages/warp_prism_ui/lib/src/organisms/ds_sidebar.dart \
  packages/warp_prism_ui/lib/src/organisms/ds_topbar.dart \
  packages/warp_prism_ui/lib/src/organisms/ds_graph_canvas.dart \
  packages/warp_prism_ui/lib/src/organisms/organisms.dart \
  packages/warp_prism_ui/lib/src/templates/master_detail_template.dart \
  packages/warp_prism_ui/lib/src/templates/templates.dart \
  packages/warp_prism_ui/lib/src/prism_aliases.dart \
  packages/warp_prism_ui/lib/warp_prism_ui.dart
# → 6 info lints only (prefer_final_fields / withOpacity / prefer_const_constructors)
# → 0 errors, 0 warnings
```

- **Scoped tests**:

```text
flutter test \
  packages/warp_prism_ui/test/templates/templates_contract_test.dart \
  packages/warp_prism_ui/test/tokens/ds_token_contract_test.dart \
  packages/warp_prism_ui/test/tokens/ds_operational_state_test.dart
# → All tests passed! (+128)
```

- **Entrada no CHANGELOG**: `docs/changelog/20260709-030544-0012-ds-api-normalization-evidence-refresh-builders.md`
- **Template→Organism API Alignment** (live source):

| Template | Organism Call | Actual API | Status |
|----------|--------------|------------|--------|
| MasterDetailTemplate | DSShell(content: ...) | content: Widget | ✅ MATCH |
| MasterDetailTemplate | DSSidebar(items:, selectedId:, onItemTap:, expanded:) | Same | ✅ MATCH |
| MasterDetailTemplate | DSTopbar(title:, breadcrumbs:, showSearch:, searchBar:, actions:) | Same | ✅ MATCH |
| CanvasTemplate | DSShell(content: ...) | Same | ✅ MATCH |
| TimelineTemplate | DSShell / DSTimeline params | Same | ✅ MATCH |

- **Note on `body:`**: sole hit is Flutter `Scaffold(body:)` in narrow detail mode — not a DSShell parameter mismatch.
- **Out of scope / external**: Full `flutter analyze packages/warp_prism_ui` still reports many package-test import/alias issues (e.g. tests importing public barrel without DS* symbols). That is **not** Task 0012 naming/API drift in production lib surfaces; track under broader package test-harness work (e.g. 120x lane), not this compile-gate normalization.
- **Agente revalidador**: builders (omniroute/builder)
- **Data de revalidação**: 2026-07-09
- **Builder self-score**: **100/100** for Task 0012 scope (evidence refresh + exit conditions green on live SDK)

### Detailed Findings

**Naming Convention**: `packages/warp_prism_ui/lib` uses `DS*` (uppercase) consistently. Zero `Ds*` (lowercase-s) instances.

**Residual (not blocking Task 0012)**: Package-wide analyzer noise from tests that import only the public Prism barrel while still constructing DS* types — separate from the original Ds*/token drift this task closed.

---

## Self-Score Rationale

| Criterion | Score | Notes |
|-----------|------:|-------|
| Exit conditions satisfied | 25/25 | All checkboxes green with live commands |
| Deliverables exist & aligned | 25/25 | Monorepo paths verified; APIs match |
| Live validation (analyze/tests) | 25/25 | Scoped surfaces 0 errors; +128 tests pass |
| Evidence/changelog/review state | 25/25 | Stale SDK blocker cleared; changelog added |
| **Total** | **100/100** | Promote to `03-review/` |

### 🔄 Review Ledger
* **[2026-07-09] Independent re-review (reviewers — gt-flutter-code-reviewer + gt-code-quality-reviewer):**
  - Report: `docs/reports/review-wave-2026-07-09/task-0012-ds-api-normalization-independent-rereview.md`
  - Score: **94/100** — `HELD_IN_REVIEW_PATH_TO_100`
  - Lane: remain `docs/tasks/03-review/` (never auto `04-completed/`)
  - Blockers: none High
  - Residual: 4 template style infos; evidence counts slightly stale (claimed 6 infos/+128 vs live 4 infos/+131)
  - Commands: `Ds*` 0; bad color tokens 0; scoped analyze 4 info/0 err; tests **131/131** PASS

(End of file)

### Review Ledger — 2026-07-17 drain (independent)

| Date | Reviewer | Score | Verdict | Notes |
| --- | --- | --- | --- | --- |
| 2026-07-17 | reviewers (drain batch 1) | 100/100 | APPROVED_COMPLETED | Live re-validation. Prior 94/100. Cleared 4 master_detail template style infos (path-to-100). Report: `docs/reports/review-wave-2026-07-17/task-0012-drain-review.md` |


### Path-to-100 Closeout — 2026-07-18 (builders)

- **Residual fixed**: Re-verified master_detail/templates analyze clean (style residual closed).
- **Commands**:
  - `dart analyze packages/warp_prism_ui/lib/src/templates` → No issues found
- **Remaining**: None (prior drain 100/100 held).
- **Lane**: remain in `docs/tasks/03-review/` (reviewers promote)


### Review Ledger — 2026-07-18 path100 independent re-review (BATCH R1)

| Date | Reviewer | Score | Verdict | Notes |
| --- | --- | --- | --- | --- |
| 2026-07-18 | reviewers (BATCH R1 independent) | 100/100 | ACCEPTED_100 | Live re-validation + path-to-100 residuals closed. Report: `docs/reports/review-wave-2026-07-18/task-0012-path100-rereview.md` |

