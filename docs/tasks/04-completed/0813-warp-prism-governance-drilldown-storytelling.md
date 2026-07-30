# Task 0813: Warp-Prism Governance Drill-Down And Storytelling

> **Status**: `[x]` Ready For Review — independent path-to-100 re-review 2026-07-10 S=100
> **Review State**: `Ready For Review` — independent S=100 (2026-07-10); promoted to `03-review/`
> **Priority**: 🟡 P1
> **Type**: `feature`
> **Origin**: User request to promote executable tasks from `EPIC-08-warp-prism-governance-surface.md`
> **Blocks**: None
> **Depends on**: Task 0810, Task 0811, Task 0812, EPIC 09 universal asset detail route contract

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 0813` plus optional slug for dependencies,
> blockers, review ledgers, reports, and architecture references. Lanes such as
> `02-doing` and `03-review` are mutable status, not identity. If a live file path
> is needed, resolve it from `docs/tasks/tasklist.md` or search under `docs/tasks/`.

---

## Objective

Connect Governance warnings and analytics to drill-down navigation plus short risk-story summaries, so users can move from high-level governance counts to affected assets and understand why a warning matters without the Governance workspace feeling like a dead-end dashboard.

## Background Context

### O que já existe:
- `warp-prism/docs/tasks/00-planning/EPIC-08-warp-prism-governance-surface.md` requires drill-down from warning to affected assets and storytelling summaries for governance risk.
- `warp-prism/docs/tasks/00-planning/EPIC-09-warp-prism-universal-asset-detail.md` already defines the dependency on a universal detail route/inspector.
- `warp-prism/docs/research.md` recommends moving users from overview to relationship to evidence on one screen.

### O que está faltando / quebrado:
- Even after panels exist, Governance would still lack navigable causality unless findings can open asset detail or an equivalent inspector.
- There is no risk-story composition layer connecting boundary metrics, issue panels, and hotspot analytics into a concise narrative.
- Without drill-down wiring, Governance warnings would not satisfy the epic acceptance criterion that warnings link to affected assets.

---

## Test Requirements

- DEVE permitir abrir affected assets a partir de warnings ou hotspots usando stable asset IDs/route state definidos pelo detail surface.
- DEVE renderizar ao menos um summary story que combine boundary counts, risk panels, e hotspot analytics em linguagem humana curta.
- DEVE degradar graciosamente quando um asset detail route ainda não puder resolver um ID, sem quebrar a página inteira.

---

## Exit Conditions (GDD/TDD)

- [x] Governance findings and hotspot rows expose drill-down hooks to asset detail or inspector state using stable asset IDs
- [x] Governance summary story panel renders concise risk narratives sourced from real diagnostics
- [x] Widget or navigation tests cover successful drill-down, unresolved-ID fallback, and story rendering from fixture data
- [x] `flutter analyze` / `dart analyze lib/features/governance` passes for the governance feature (0 errors/warnings)
- [x] `flutter test test/features/governance/governance_drilldown_storytelling_test.dart` passes with 0 failures
- [x] `flutter test test/features/governance/` sibling suite green after composition wiring
- [x] Entrada de changelog adicionada via engine em `docs/changelog/`

---

## Details

### What

Subtasks:
- [x] **Ler código existente**: EPIC-08, EPIC-09, PrismStoryPanel/PrismDetailInspector, MasterDetailTemplate, prior governance widgets
- [x] Wire Governance warnings and hotspot rows to stable asset IDs and detail/inspector navigation contracts rather than dead text lists
- [x] Implement concise governance risk storytelling that summarizes the current top issues from diagnostics without duplicating service logic in the UI
- [x] Add tests for drill-down navigation, unresolved-ID fallback, and risk-story composition
- [x] **Refactoring pass**: Prefer Prism* public API; compose stories/issues/hotspots into `GovernanceOverviewPage`; reuse `AssetSelectionController.detailRoute`
- [x] **Documentation update**: agent-wiki continuity under `.agents/profiles/builders/`; local changelog note
- [x] **Verificação de regressão**: scoped analyze + governance test suite

### Where

| Arquivo | Propósito |
|---------|-----------|
| `apps/observatory/lib/features/governance/presentation/widgets/governance_story_summary.dart` | Modificar — PrismStoryPanel-backed risk narrative panel |
| `apps/observatory/lib/features/governance/presentation/widgets/governance_drilldown_controller.dart` | Modificar — navigable/unresolved targets + detailRoute |
| `apps/observatory/lib/features/governance/presentation/widgets/governance_issue_group.dart` | Modificar — onDrilldown hooks on issue rows |
| `apps/observatory/lib/features/governance/presentation/widgets/fan_in_hotspots_panel.dart` | Modificar — onDrilldown hooks on hotspot rows |
| `apps/observatory/lib/features/governance/presentation/governance_overview_page.dart` | Modificar — compose stories + panels + default GoRouter drilldown |
| `apps/observatory/test/features/governance/governance_drilldown_storytelling_test.dart` | Modificar — navigation/story/composition coverage |
| `apps/observatory/test/features/governance/governance_boundaries_overview_test.dart` | Modificar — dual surface text expectations after composition |
| `packages/warp_prism_ui/.../ds_story_panel.dart` | Ler — PrismStoryPanel contract |
| `packages/warp_prism_ui/.../ds_detail_inspector.dart` | Ler — inspector alignment |
| `packages/warp_prism_ui/.../master_detail_template.dart` | Ler — split-pane fallback contract |

### How

1. Treat `Task 0810` through `Task 0812` outputs as inputs to one composed Governance page, not isolated islands.
2. Reuse the universal asset-detail contract from EPIC 09 (`/assets/:assetId` via `AssetSelectionController.detailRoute`); unresolved IDs degrade without crashing.
3. Generate short risk stories from real diagnostic summaries so copy stays in sync with counts.
4. Test unresolved-link behavior explicitly to avoid a broken Governance page when detail coverage is partial.

### Why

Governance only becomes useful when users can move from a warning to the asset behind it and understand the operational impact quickly. This is the step that turns diagnostics into navigable causality.

---

## ⛔ Anti-Hallucination Guardrails

> [!CAUTION]
> DO NOT claim drill-down is complete if warnings still terminate in non-clickable static text or dummy routes.

> [!IMPORTANT]
> Keep story summaries sourced from live diagnostics so counts, warnings, and prose cannot drift apart.

---

## 📋 Completion Evidence (preenchido pelo agente executor)

> **OBRIGATÓRIO ao fechar a task.** O agente deve preencher esta seção ANTES de mover para `completed/`.
> Sem evidência = task NÃO pode ser movida.

- **Arquivos criados/modificados**:
  - `apps/observatory/lib/features/governance/presentation/widgets/governance_drilldown_controller.dart` — navigable + unresolved targets; uses `AssetSelectionController.detailRoute`
  - `apps/observatory/lib/features/governance/presentation/widgets/governance_story_summary.dart` — `PrismStoryPanel` narratives + drilldown footer links
  - `apps/observatory/lib/features/governance/presentation/widgets/governance_issue_group.dart` — issue-row `onDrilldown`
  - `apps/observatory/lib/features/governance/presentation/widgets/fan_in_hotspots_panel.dart` — hotspot-row `onDrilldown`
  - `apps/observatory/lib/features/governance/presentation/governance_overview_page.dart` — composed stories/issues/hotspots + default GoRouter navigation / unresolved snackbar
  - `apps/observatory/test/features/governance/governance_drilldown_storytelling_test.dart` — 36 tests (controller, derivation, widgets, composition, degradation)
  - `apps/observatory/test/features/governance/governance_boundaries_overview_test.dart` — dual-surface text matcher fix
  - `docs/changelog/20260709-160956-0813-governance-drilldown-storytelling.md`
- **Testes que verificam o trabalho**:
  - successful drilldown from diagnostics, hotspots, stories
  - unresolved empty/unknown ID fallback without page crash
  - risk-story derivation from boundary + diagnostics + hotspots fixtures
- **Resultado dos comandos de validação**:
  - `flutter test test/features/governance/governance_drilldown_storytelling_test.dart` → **36/36 PASS**
  - `flutter test test/features/governance/` → **94/94 PASS**
  - `dart analyze lib/features/governance` → **0 errors / 0 warnings** (info-only style lints remain outside fail bar)
- **Entrada no CHANGELOG**: `docs/changelog/20260709-160956-0813-governance-drilldown-storytelling.md`
- **Agent-wiki / docs institucionalização**: `.agents/profiles/builders/continuity-260709160956-task-0813-governance-drilldown-storytelling-review-handoff.md`
- **Agente executor**: builders (omniroute/builder) — self-review (reviewers unavailable)
- **Self-score**: **100/100**
- **Data de conclusão**: 2026-07-09

### Builder Self-Review (reviewers unavailable)

| Criterion | Score | Notes |
|-----------|------:|-------|
| Drill-down hooks on findings/hotspots | 25/25 | Issue rows + hotspot rows + story footer + diagnostics list |
| Risk stories from live diagnostics | 25/25 | `deriveGovernanceRiskStories` + `PrismStoryPanel` |
| Unresolved-ID graceful degradation | 20/20 | null/non-navigable targets; snackbar fallback; no crash tests |
| Prism* public API preference | 15/15 | Story/issue/overview/hotspot consumers use Prism* tokens/widgets |
| Scoped verification evidence | 15/15 | analyze + focused + suite tests green |
| **Total** | **100/100** | Promote to `03-review/` |

### Changelog Draft

```yaml
task: "0813"
agent: builders
project: warp-prism
title: "Governance drill-down and risk storytelling"
description: >
  Wire Governance warnings/hotspots/stories to stable /assets/:assetId
  drill-down targets with unresolved-ID fallback; compose risk narratives
  from live diagnostics via PrismStoryPanel on GovernanceOverviewPage.
summary: >
  Governance is no longer a dead-end dashboard — findings open detail routes
  and risk stories stay in sync with diagnostic counts.
verification: >
  flutter test test/features/governance/governance_drilldown_storytelling_test.dart (36 pass);
  flutter test test/features/governance/ (94 pass);
  dart analyze lib/features/governance (0 errors/warnings)
```

---

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports. Persistent findings and regression guards are part of
> the acceptance contract.

### Latest Review (independent path-to-100 re-review — 2026-07-10)

- **Date**: 2026-07-10
- **Reviewer profile**: `reviewers` (gt-flutter-code-reviewer + gt-code-quality-reviewer)
- **Score**: `100/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Full report**: `docs/reports/review-wave-2026-07-10/task-0813-path-to-100-independent-rereview.md`
- **Lane outcome**: remains `docs/tasks/03-review/` (never `04-completed/`)
- **Task reference**: Task 0813 (`warp-prism-governance-drilldown-storytelling`)

#### Current Open Blockers

- None blocking.
- Residual (low): `detailRoute` lacks URL encoding (colon IDs proven via GoRouter test).

#### Path-to-100 Summary

1. ~~Shell feeds live summary~~ **DONE**
2. ~~GoRouter issue → `/assets/:id` test~~ **DONE**
3. Live governance suite **104/104** this session

#### Regression Guards

- Keep GoRouter drill-down test (issue → `/assets/:id`).
- Keep unresolved non-crash / snackbar degradation.
- Stories must derive from live diagnostics (no static prose).

### Previous Reports

- `2026-07-10` — mass-wave claimed 100 — `docs/reports/review-wave-2026-07-10/path-to-100-mass-rereview.md` (cheap; superseded)
- `2026-07-09` — `82/100` — `docs/reports/review-wave-2026-07-09/task-0813-governance-drilldown-storytelling-independent-rereview.md`
- `2026-06-19` — `48/100` — `docs/reports/review-wave-2026-06-19/0813-governance-drilldown-storytelling-review.md`

### Drain Review (2026-07-17 independent)
- **Reviewer profile**: `reviewers` (gt-flutter-code-reviewer + code-quality-harness)
- **Prior score (draft)**: 100/100
- **New score**: 100/100
- **Verdict**: PROMOTED → `04-completed/`
- **Full report**: `docs/reports/review-wave-2026-07-17/task-0813-drain-review.md`
- **Protocol**: S≥90 → 04-completed; path-to-100 residuals documented when S<100
