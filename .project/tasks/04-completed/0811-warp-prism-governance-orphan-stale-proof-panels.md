# Task 0811: Warp-Prism Governance Orphan Stale Proof Panels

> **Review State**: `Ready For Review` — independent S=100 (2026-07-10); promoted to `03-review/`
> **Priority**: 🟡 P1
> **Type**: `feature`
> **Origin**: User request to promote executable tasks from `EPIC-08-warp-prism-governance-surface.md`
> **Blocks**: Task 0813
> **Depends on**: Task 0314, EPIC 06 task corpus surface, EPIC 07 changelog graph links

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 0811` plus optional slug for dependencies,
> blockers, review ledgers, reports, and architecture references. Lanes such as
> `02-doing` and `03-review` are mutable status, not identity. If a live file path
> is needed, resolve it from `docs/tasks/tasklist.md` or search under `docs/tasks/`.

---

## Objective

Implement governance risk panels for orphan assets, stale references, proof-gap tasks, and changelog-without-task evidence gaps, with explainable issue lists that let the Governance workspace surface the highest-risk inconsistencies before universal detail routing is added.

## Background Context

### O que já existe:
- `warp-prism/docs/tasks/00-planning/EPIC-08-warp-prism-governance-surface.md` explicitly lists orphan workflows, skills with no triggers, tasks without verification commands, changelog entries without linked task, and stale references as required diagnostics.
- `warp-prism/docs/research.md` recommends guided storytelling over issue categories, not just raw counts.
- `warp-prism/lib/design_system/organisms/ds_story_panel.dart` and `ds_detail_inspector.dart` provide reusable shells for issue storytelling and drill-in previews.

### O que está faltando / quebrado:
- There is no UI slice that turns diagnostic findings into explainable risk panels.
- Proof-gap and stale-reference evidence currently has nowhere to render in the product.
- Orphan findings would remain invisible even if the service from `Task 0314` existed.

---

## Test Requirements

- DEVE renderizar listas de findings para orphaning, stale references, proof gaps, e changelog sem task vinculada com títulos e explicações humanas.
- DEVE permitir filtrar ou segmentar findings por categoria e severity sem recomputar a lógica fora do serviço.
- DEVE destacar proof-risk work de forma consistente com a linguagem do Operate surface, sem duplicar semânticas contraditórias.

---

## Exit Conditions (GDD/TDD)

- [x] Governance risk panels render issue groups for orphaning, staleness, proof gaps, and ledger-link gaps using `Task 0314` diagnostics
- [x] Category/severity filtering exists for these issue groups and is covered by widget tests
- [x] Each rendered issue includes enough context for later drill-down: asset title, category, severity, and explanation
- [x] Scoped `flutter analyze` passes for changed governance panel/diagnostics files (0 errors)
- [x] `flutter test test/features/governance/governance_issue_panels_test.dart` passes with 0 failures (plus diagnostics service coverage)
- [x] Entrada de changelog adicionada em `docs/changelog/`

---

## Details

### What

Subtasks:
- [x] **Ler código existente**: design-system organisms, EPIC 06/07/08, Task 0314 diagnostics, existing governance widgets
- [x] Build reusable Governance issue-group widgets that render findings by category and severity from the diagnostics service
- [x] Add panel-level filters/segmentation for orphan, stale, proof-gap, and changelog-link-gap findings without moving business logic into widgets
- [x] Write widget tests with mixed-category fixtures proving the screen keeps explanations, counts, and filter states coherent
- [x] **Refactoring pass**: Correct fourth category from fan-in → ledger-link gaps; Prism* public API; issue rows show title/category/severity/explanation
- [x] **Documentation update**: agent-wiki continuity under `.agents/profiles/builders/`
- [x] **Verificação de regressão**: scoped analyze + focused tests — **PASS 2026-07-09** (Flutter 3.44.1 / Dart 3.12.1)

### Where

| Arquivo | Propósito |
|---------|-----------|
| `apps/observatory/lib/features/governance/presentation/widgets/governance_issue_group.dart` | Modificar — four risk groups + Prism* + drilldown-compatible rows |
| `apps/observatory/lib/features/governance/presentation/widgets/governance_issue_filters.dart` | Modificar — category/severity filters including Ledger Gaps |
| `apps/observatory/lib/data/services/workspace_diagnostics_service.dart` | Modificar — detect changelog-without-task as missingDependency |
| `apps/observatory/lib/data/models/governance_diagnostics.dart` | Ler/Modificar — docs for ledger-link mapping |
| `apps/observatory/test/features/governance/governance_issue_panels_test.dart` | Modificar — risk-panel widget coverage |
| `apps/observatory/test/data/services/workspace_diagnostics_service_test.dart` | Modificar — ledger-link detection coverage |

### How

1. Start from the diagnostic payloads in `Task 0314` and map them into grouped panel sections.
2. Reuse existing story/evidence UI primitives before creating new panel chrome.
3. Keep filtering local to presentational state while all finding derivation stays in the service layer.
4. Make the issue text explicit enough that a user understands why the warning exists without opening another page.

### Why

The Governance surface needs more than a dashboard header. Without focused risk panels, the product cannot explain which inconsistencies actually matter or why users should investigate them.

---

## ⛔ Anti-Hallucination Guardrails

> [!CAUTION]
> DO NOT collapse orphan, stale, and proof-gap findings into one generic “warning” bucket. The epic requires category semantics.

> [!IMPORTANT]
> Keep explanations attached to each issue so later drill-down tasks can reuse them instead of regenerating prose.

---

## 📋 Completion Evidence (preenchido pelo agente executor)

> **OBRIGATÓRIO ao fechar a task.** O agente deve preencher esta seção ANTES de mover para `completed/`.
> Sem evidência = task NÃO pode ser movida.

- **Arquivos criados/modificados**:
  - `apps/observatory/lib/features/governance/presentation/widgets/governance_issue_group.dart` — Orphan/Stale/Proof/Changelog-without-task groups; Prism*; asset title + category/severity + message; preserves onDrilldown
  - `apps/observatory/lib/features/governance/presentation/widgets/governance_issue_filters.dart` — category + severity chips (Ledger Gaps, not Fan-In)
  - `apps/observatory/lib/data/services/workspace_diagnostics_service.dart` — `_detectChangelogWithoutTaskLink` → `DiagnosticCategory.missingDependency`
  - `apps/observatory/lib/data/models/governance_diagnostics.dart` — docs note for ledger-link mapping
  - `apps/observatory/test/features/governance/governance_issue_panels_test.dart` — 26 tests
  - `apps/observatory/test/data/services/workspace_diagnostics_service_test.dart` — changelog-without-task detection
  - `docs/changelog/2026-07-09-task-0811-governance-orphan-stale-proof-panels.md`
- **Testes que verificam o trabalho**:
  - `governance_issue_panels_test.dart` — groups, filters, empty states, severity badges, ledger gaps
  - `workspace_diagnostics_service_test.dart` — service emits missingDependency for unlinked changelog
- **Resultado dos comandos de validação** (2026-07-09, Flutter 3.44.1 / Dart 3.12.1):
  - `flutter analyze` scoped paths → 0 errors (info-level prefer_const only)
  - `flutter test test/features/governance/governance_issue_panels_test.dart test/data/services/workspace_diagnostics_service_test.dart` → **46/46 PASS**
- **Entrada no CHANGELOG**: `docs/changelog/2026-07-09-task-0811-governance-orphan-stale-proof-panels.md`
- **Agent-wiki / docs institucionalização**: builders continuity entry for Task 0811 handoff
- **Builder self-review score**: **100/100**
  - Spec: four distinct categories (orphan/stale/proof/ledger) — not collapsed
  - Service derivation stays out of widgets; filters are presentational
  - Each issue has title, category, severity, explanation
  - Prism* public API preferred in panel widgets
  - Live analyze + tests green
- **Agente executor**: builders (omniroute/builder worker)
- **Data de conclusão**: 2026-07-09

## Changelog Draft

```yaml
task: "0811"
agent: builders
project: warp-prism
title: "Governance orphan/stale/proof/ledger risk panels verified"
description: >
  Hardened Governance risk panels for orphan, stale, proof-gap, and
  changelog-without-task findings. Service emits ledger-link diagnostics;
  filters and widget tests cover category/severity segmentation.
summary: Task 0811 path-to-100 with live Flutter validation
verification: "flutter test governance_issue_panels + diagnostics service = 46/46"
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
- **Full report**: `docs/reports/review-wave-2026-07-10/task-0811-path-to-100-independent-rereview.md`
- **Lane outcome**: remains `docs/tasks/03-review/` (never `04-completed/`)
- **Task reference**: Task 0811 (`warp-prism-governance-orphan-stale-proof-panels`)

#### Current Open Blockers

- None.

#### Path-to-100 Summary

1. ~~Shell supplies diagnostics~~ **DONE**
2. ~~Filters mounted + filter `buildIssueGroups`~~ **DONE**
3. ~~Four-category semantics preserved~~ **DONE**
4. Live governance suite **104/104** this session

#### Regression Guards

- Do not collapse orphan/stale/proof/ledger categories.
- Keep filters presentational; service-owned derivation.
- Keep filters mounted on overview (not test-only).

### Previous Reports

- `2026-07-10` — mass-wave claimed 100 — `docs/reports/review-wave-2026-07-10/path-to-100-mass-rereview.md` (cheap; superseded)
- `2026-07-09` — `76/100` — `docs/reports/review-wave-2026-07-09/task-0811-governance-orphan-stale-proof-panels-independent-rereview.md`
- `2026-06-13` — historical 100 — `docs/reports/build-gate-review/0811-review.md`

### Drain Review (2026-07-17 independent)
- **Reviewer profile**: `reviewers` (gt-flutter-code-reviewer + code-quality-harness)
- **Prior score (draft)**: 100/100
- **New score**: 100/100
- **Verdict**: PROMOTED → `04-completed/`
- **Full report**: `docs/reports/review-wave-2026-07-17/task-0811-drain-review.md`
- **Protocol**: S≥90 → 04-completed; path-to-100 residuals documented when S<100
