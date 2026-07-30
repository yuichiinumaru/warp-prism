# Task 0713: Warp Prism History Story And Impact Views

> **Status**: `[x]` Done — independent drain accepted (path-to-100 residual)
> **Review State**: Independent drain **92/100** — `ACCEPTED_PATH_TO_100` → `04-completed/` (2026-07-17)
> **Priority**: 🟡 P1
> **Type**: `feature`
> **Origin**: EPIC 07 `warp-prism/docs/tasks/00-planning/EPIC-07-warp-prism-history-surface.md`
> **Blocks**: None
> **Depends on**: Task 0711, Task 0712

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 0713` in reviews and follow-up work.

---

## Objective

Add the two narrative modes that complete the History surface: Project Story grouping that explains why changes matter, and Impact Story navigation that shows `changelog -> task -> skill/workflow` causality inside the History inspector/detail experience.

## Background Context

### O que ja existe:
- `warp-prism/lib/design_system/organisms/ds_story_panel.dart` provides the narrative card primitive (consumed via `PrismStoryPanel`).
- `warp-prism/lib/design_system/organisms/ds_detail_inspector.dart` provides a structured side inspector for asset details (consumed via `PrismDetailInspector`).
- `warp-prism/docs/research.md` explicitly recommends Timeline, Project Story, and Impact Story as the three core changelog views.
- `apps/observatory/lib/data/repositories/history_repository.dart` (Task 0711) exposes `HistoryTimeline` and `HistoryEntry` with multi-hop `HistoryImpactEdge` resolution.

### O que esta faltando / quebrado:
- The previous implementation claimed "Project Story + Impact Story" but its tests never executed; it referenced the legacy `ChangelogMetadata` and used non-public `DS*` names, so it could not compile against the 0711 read model.
- The previous "BLOCKED — Flutter SDK not installed" status was a tooling gap, not a code gap: the Flutter SDK is in fact available in this checkout.
- The prior surface had no Project Story / Impact Story selection wiring, no workflow hop, and no impact-path section in the inspector.

---

## Test Requirements

- DEVE existir um modo `Project Story` com agrupamento por projeto e/ou milestone task-coherent.
- DEVE existir um modo `Impact Story` que mostre ao menos o caminho `changelog -> task -> skill/workflow` quando as referencias existirem.
- DEVE reaproveitar o mesmo read model do History, sem criar uma segunda fonte de verdade para agrupamentos.
- DEVE expor estados claros quando uma entry nao possui links suficientes para impact path completo.
- DEVE manter a selecao e o detalhe sincronizados com a timeline principal.

---

## Exit Conditions (GDD/TDD)

- [x] A pagina History oferece alternancia entre Timeline, Project Story e Impact Story.
- [x] Story groups sao derivados do read model e refletem projetos/milestones reais do corpus mock.
- [x] O inspector mostra links e metadados de impacto para tasks, skills e workflows relacionados.
- [x] `flutter analyze` passa sem erros (scoped: `lib/features/history/` + `test/features/history/`).
- [x] `flutter test test/features/history/history_story_modes_test.dart` cobre agrupamento narrativo e inspector de impacto com 0 falhas (31/31 pass).
- [x] Entrada de changelog adicionada em `docs/changelog/2026-07-09-task-0713-history-story-and-impact-views-path-to-100.md`.

---

## Details

### What

Subtasks:

- [x] **Ler codigo existente**: `warp-prism/lib/design_system/organisms/ds_story_panel.dart`, `warp-prism/lib/design_system/organisms/ds_detail_inspector.dart`, `warp-prism/lib/design_system/organisms/ds_timeline.dart`, `warp-prism/lib/features/history/presentation/history_page.dart`, `Task 0711` read model.
- [x] Implementar alternancia de modo dentro da feature History sem quebrar a timeline baseline.
- [x] Criar agrupamentos de Project Story e respectivas narrativas/insights a partir dos dados normalizados.
- [x] Implementar painel/inspector de Impact Story com links para task, skill e workflow relacionados.
- [x] Cobrir estados de links ausentes, grupos vazios e mudanca de modo em testes de widget.
- [x] **Refactoring pass**: simplificar a montagem de story panels e inspector para evitar logica narrativa duplicada.
- [x] **Documentation update**: registrar qualquer regra duravel de storytelling ou fallback de impact path em `warp-prism/docs/`.
- [x] **Verificacao de regressao**: executar `flutter analyze` e `flutter test test/features/history/history_story_modes_test.dart`. — **31/31 tests pass; scoped analyze: 0 errors / 0 warnings / 13 prefer_const hints.**

### Where

| Arquivo | Proposito |
|---------|-----------|
| `warp-prism/apps/observatory/lib/features/history/presentation/history_view_mode.dart` | Enum de modos (Timeline, Project Story, Impact Story) |
| `warp-prism/apps/observatory/lib/features/history/presentation/history_controller.dart` | `HistoryState` realinhado para `HistoryEntry`; `toProjectStoryGroups`, `toImpactPathNodes`, `selectedEntry` |
| `warp-prism/apps/observatory/lib/features/history/presentation/history_page.dart` | Alternancia de modo, `ResponsiveDetailShell` em todos os modos, secao Impact Path no inspector |
| `warp-prism/apps/observatory/lib/features/history/presentation/widgets/history_story_view.dart` | Project Story cards via `PrismStoryPanel`; chips de selecao |
| `warp-prism/apps/observatory/lib/features/history/presentation/widgets/history_impact_view.dart` | Impact path cards com hops + gap indicators |
| `warp-prism/apps/observatory/test/features/history/history_story_modes_test.dart` | 31 testes (modo switch, grupos, paths, gaps, sync) |
| `warp-prism/docs/changelog/2026-07-09-task-0713-history-story-and-impact-views-path-to-100.md` | Entrada de changelog (path-to-100) |

### How

1. Reusar a timeline e o read model como fonte de verdade, derivando story groups e impact paths sem duplicar parsing.
2. Converter agrupamentos em storytelling curto e verificavel com `PrismStoryPanel`, evitando texto livre impossivel de testar.
3. Exibir impacto como cadeia navegavel de referencias, com fallback explicito quando o corpus nao tiver todos os hops.
4. Garantir por testes que a troca de modo preserva selecao e detalhe quando fizer sentido.

### Why

EPIC 07 only delivers its product promise when History tells a story and shows causality, not when it merely lists entries. These modes are what connect the changelog ledger to the rest of the observatory graph and make the surface useful for explanation, not just audit.

---

## ⛔ Anti-Hallucination Guardrails

> [!CAUTION]
> DO NOT fabricate impact chains in the UI when the corpus does not support them. Missing references must render as explicit partial-state messaging.

> [!IMPORTANT]
> Keep narrative output grounded in parsed metadata and normalized edges. Story mode is a projection over evidence, not freeform copywriting.

---

## 📋 Completion Evidence (preenchido pelo agente executor)

- **Arquivos criados/modificados**:
  - `apps/observatory/lib/features/history/presentation/history_view_mode.dart` (ja existia, mantido)
  - `apps/observatory/lib/features/history/presentation/history_controller.dart` (modificado — realinhado para `HistoryEntry`; adicionado `selectedEntry` getter)
  - `apps/observatory/lib/features/history/presentation/history_page.dart` (modificado — migrado para `Prism*` API; adicionada secao Impact Path no inspector; `ResponsiveDetailShell` em todos os modos)
  - `apps/observatory/lib/features/history/presentation/widgets/history_story_view.dart` (reescrito — `Prism*` API, chips de selecao)
  - `apps/observatory/lib/features/history/presentation/widgets/history_impact_view.dart` (reescrito — `Prism*` API, gap nodes, workflow hop chips)
  - `apps/observatory/test/features/history/history_story_modes_test.dart` (reescrito — 31 testes, fixtures baseadas em `HistoryEntry`, surface 1400×2400)
  - `docs/changelog/2026-07-09-task-0713-history-story-and-impact-views-path-to-100.md` (criado)
- **Testes que verificam o trabalho**: `history_story_modes_test.dart` — 31 tests covering mode switching, project story groups, impact path nodes (skills, workflows, missing hops), gap indicators, selection sync across modes. Combinado com `history_page_test.dart` + `history_repository_test.dart` + `workspace_providers_test.dart`: 97/97 pass.
- **Resultado dos comandos de validacao**:
  - `flutter test test/features/history/ test/data/history/ test/data/providers/workspace_providers_test.dart` → **All tests passed! (+97)**
  - `flutter analyze lib/features/history/ test/features/history/` → **13 issues (info-level prefer_const hints only). 0 errors, 0 warnings.**
- **Entrada no CHANGELOG**: `docs/changelog/2026-07-09-task-0713-history-story-and-impact-views-path-to-100.md`
- **Agent-wiki / docs institucionalizacao**: agente-wiki em `.agents/profiles/builders/` (continuidade do builder worker)
- **Agente executor**: builders (flutter-engineer)
- **Data de conclusao**: 2026-07-09

---

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports.

### Latest Review

- **Date**: 2026-07-09
- **Reviewer profile**: `reviewers`
- **Score**: `95/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Full report**: `docs/reports/review-wave-2026-07-09/task-0713-history-story-and-impact-views-independent-rereview.md`
- **Lane outcome**: remains in review
- **Task reference**: Task 0713 (`warp-prism-history-story-and-impact-views`)

#### Current Open Blockers

- None blocking.
- `NEW` Low: shared mode-chip Semantics gap (with 0712).
- `NEW` Low: prefer_const on impact empty surface.

#### Path-to-100 Summary

- Mode-chip Semantics + const hygiene on story/impact surfaces.
- Keep gap-indicator + complete-path + selection-sync tests as guards.

### Previous Reports

- `2026-07-09` — builder completion evidence (31/31 claim) — independent live **53** history UI suite green; score **95**
- `2026-06-13` — `100/100` — `docs/reports/build-gate-review/0713-review.md` (SDK-blocked; unproven)
  - **Resolved since**: Prism* rewrite, live story modes tests, impact path inspector
  - **Regression guard**: never fabricate complete impact paths when hops missing

### 2026-07-17 — Independent drain re-review (reviewers / Batch 3)

- **Score**: `92/100`
- **Verdict**: `ACCEPTED_PATH_TO_100`
- **Lane**: `docs/tasks/04-completed/`
- **Report**: `docs/reports/review-wave-2026-07-17/task-0713-drain-review.md`
- **Note**: Story/impact modes solid. Residual: shared mode-chip a11y; prefer_const on impact empty.


### 2026-07-18 — Path-to-100 independent re-review (reviewers / BATCH R2)
- **Score**: 99/100 — ACCEPTED_COMPLETE
- **Report**: `docs/reports/review-wave-2026-07-18/task-0713-path100-rereview.md`
- **path100_applied**: yes; residual path-to-100 list empty
- **Lane**: promoted to `docs/tasks/04-completed/`
- **Top finding**: Story/impact modes + a11y entry point complete
