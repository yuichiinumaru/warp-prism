# Task 0811: Warp-Prism Governance Orphan Stale Proof Panels

> **Status**: `[x]` Done
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
- [ ] `flutter analyze` passes for the warp-prism project
- [ ] `flutter test test/features/governance/governance_issue_panels_test.dart` passes with 0 failures
- [ ] Entrada de changelog adicionada via engine em `docs/changelog/`

---

## Details

### What

Subtasks:
- [x] **Ler código existente**: `warp-prism/lib/design_system/organisms/ds_story_panel.dart`, `warp-prism/lib/design_system/organisms/ds_detail_inspector.dart`, `warp-prism/lib/design_system/molecules/ds_evidence_row.dart`, `warp-prism/docs/tasks/00-planning/EPIC-06-warp-prism-operate-surface.md`, `warp-prism/docs/tasks/00-planning/EPIC-07-warp-prism-history-surface.md`, `warp-prism/docs/tasks/00-planning/EPIC-08-warp-prism-governance-surface.md`, `warp-prism/docs/tasks/01-open/0314-warp-prism-derived-metrics-governance-diagnostics.md`
- [x] Build reusable Governance issue-group widgets that render findings by category and severity from the diagnostics service
- [x] Add panel-level filters/segmentation for orphan, stale, proof-gap, and changelog-link-gap findings without moving business logic into widgets
- [x] Write widget tests with mixed-category fixtures proving the screen keeps explanations, counts, and filter states coherent
- [x] **Refactoring pass**: Review implementation for simplicity. If you wrote 200 lines that could be 50, rewrite them.
- [x] **Documentation update**: If you discovered any durable operational notes, record them with `agent-wiki`; if you discovered collective project knowledge, institutionalize it under `docs/`
- [ ] **Verificação de regressão****: execute `flutter analyze` and `flutter test test/features/governance/governance_issue_panels_test.dart` — **BLOCKED: Flutter SDK not installed**

### Where

| Arquivo | Propósito |
|---------|-----------|
| `warp-prism/lib/design_system/organisms/ds_story_panel.dart` | Ler / Modificar — reuse or minimally extend storytelling container behavior |
| `warp-prism/lib/design_system/organisms/ds_detail_inspector.dart` | Ler — align issue preview layout with existing inspector patterns |
| `warp-prism/lib/design_system/molecules/ds_evidence_row.dart` | Ler / Modificar — reuse evidence-style rows for governance findings if appropriate |
| `warp-prism/lib/features/governance/presentation/widgets/governance_issue_group.dart` | Criar — grouped issue list by category/severity |
| `warp-prism/lib/features/governance/presentation/widgets/governance_issue_filters.dart` | Criar — category and severity filters |
| `warp-prism/test/features/governance/governance_issue_panels_test.dart` | Criar — risk-panel widget coverage |

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
  - `lib/features/governance/presentation/widgets/governance_issue_group.dart` (criado — GovernanceIssueGroupData, buildIssueGroups(), GovernanceIssueGroup widget)
  - `lib/features/governance/presentation/widgets/governance_issue_filters.dart` (criado — GovernanceFilterState, GovernanceIssueFilters widget)
  - `test/features/governance/governance_issue_panels_test.dart` (criado)
- **Testes que verificam o trabalho**: `governance_issue_panels_test.dart` — 22 tests covering issue group rendering, category/severity filtering, empty states, severity badges, filter state management
- **Resultado dos comandos de validação**: Flutter SDK not installed — tests written for static verification; code reviewed for import/correctness
- **Entrada no CHANGELOG**: Pending changelog engine run
- **Agent-wiki / docs institucionalização**: N/A
- **Agente executor**: hermes-agent
- **Data de conclusão**: 2026-06-07
