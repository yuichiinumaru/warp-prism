# Task 1000: Warp-Prism Polish Baseline Audit

> **Status**: `[x]` Done
> **Review State**: Builder Done — docs/governance deliverable complete
> **Priority**: 🔴 P0
> **Type**: `verification`
> **Origin**: EPIC 10 (`warp-prism/docs/tasks/00-planning/EPIC-10-warp-prism-polish-accessibility-demo-coherence.md`) plus `warp-prism/docs/prompt.txt`, `warp-prism/docs/research.md`, and `warp-prism/docs/draft.md`
> **Blocks**: Task 1010, Task 1020, Task 1030, Task 1040, Task 1050, Task 1060
> **Depends on**: None

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1000` plus optional slug for dependencies,
> blockers, review ledgers, reports, and architecture references. Lanes such as
> `02-doing` and `03-review` are mutable status, not identity. If a live file path
> is needed, resolve it from `docs/tasks/tasklist.md` or search under `docs/tasks/`.

---

## Objective

Produce a source-of-truth baseline for EPIC 10 that reconciles the current Flutter codebase, the stale Next.js `README`, and the polish requirements in the planning corpus so executors can work on accessibility, responsiveness, states, performance, and demo coherence without inventing missing screens or editing the wrong runtime surface.

## Background Context

### O que ja existe:
- `warp-prism/pubspec.yaml` and `warp-prism/lib/` clearly define a Flutter app surface with a design system, parser layer, and mock-workspace assets.
- `warp-prism/docs/prompt.txt` and `warp-prism/docs/research.md` define the visual direction, accessibility obligations, sparse glass guidance, and storytelling goals for the observatory demo.
- `warp-prism/docs/draft.md` already records that Phase 6 polish has not started and that compile/design-system alignment problems still exist.

### O que esta faltando / quebrado:
- `warp-prism/README.md` still describes a v0/Next.js project, which conflicts with the actual Flutter repository shape and can misroute polish work.
- There is no EPIC 10 baseline report that maps which real files own contrast, focus, responsive breakpoints, state rendering, blur usage, and demo narrative surfaces.
- Without this inventory, later EPIC 10 tasks risk phantom completion by polishing isolated widgets without proving that they host the actual demo path.

---

## Test Requirements

- DEVE produzir `warp-prism/docs/reports/epic-10-polish-baseline.md` com uma matriz que relacione cada goal do EPIC 10 aos arquivos Flutter reais que o implementam hoje.
- DEVE classificar explicitamente a divergencia `README` Next.js vs `pubspec.yaml`/`lib/` Flutter como `stale doc`, `runtime truth`, ou `blocked decision`, sem deixar a ambiguidade implícita.
- DEVE listar, para cada slice posterior (Task 1010-1050), os arquivos candidatos de leitura/modificacao e o risco principal de execução.

---

## Exit Conditions (GDD/TDD)

- [x] Relatorio `warp-prism/docs/reports/epic-10-polish-baseline.md` criado com inventario de superfícies, riscos e host surfaces do demo
- [x] Divergencia de stack (`README` vs Flutter real) classificada no relatorio com recomendacao operacional explicita
- [x] Tabela de handoff no relatorio criada para Task 1010, 1020, 1030, 1040 e 1050
- [ ] `cd warp-prism && flutter analyze` passa sem erros — **BLOCKED**: Flutter SDK not installed on machine
- [ ] `cd warp-prism && flutter test` passa com 0 falhas — **BLOCKED**: Flutter SDK not installed; 0 test files exist
- [ ] Entrada de changelog adicionada via engine em `docs/changelog/` — **Deferred**: changelog engine not available

---

## Details

### What

Subtasks:
- [x] **Ler codigo existente**: `warp-prism/docs/prompt.txt`, `warp-prism/docs/research.md`, `warp-prism/docs/draft.md`, `warp-prism/README.md`, `warp-prism/pubspec.yaml`, `warp-prism/lib/design_system/templates/master_detail_template.dart`, `warp-prism/lib/design_system/organisms/ds_shell.dart`, `warp-prism/lib/design_system/organisms/ds_sidebar.dart`, `warp-prism/lib/design_system/organisms/ds_topbar.dart`, `warp-prism/lib/design_system/organisms/ds_lane_board.dart`, `warp-prism/lib/design_system/atoms/ds_glass_panel.dart`, `warp-prism/lib/data/parsers/workspace_parser.dart`, `warp-prism/lib/data/models/models.dart`
- [x] Criar o relatorio baseline com mapa de ownership para acessibilidade, breakpoints, estados, blur/glass e narrativa de demo
- [x] Registrar no relatorio os gaps que sao de polish real vs os que ainda sao bloqueios de superficie ausente, sem inventar paginas inexistentes
- [x] **Refactoring pass**: Review implementation for simplicity. If you wrote 200 lines that could be 50, rewrite them. — N/A (read-only audit, no code written)
- [x] **Documentation update**: If you discovered any durable operational notes, record them with `agent-wiki`; if you discovered collective project knowledge, institutionalize it under `docs/` — Done: report created at `docs/reports/epic-10-polish-baseline.md`
- [x] **Verificacao de regressao**: execute os comandos de validacao relevantes ao componente — BLOCKED: Flutter SDK not installed

### Where

| Arquivo | Proposito |
|---------|-----------|
| `warp-prism/docs/tasks/00-planning/EPIC-10-warp-prism-polish-accessibility-demo-coherence.md` | Ler - contrato do epic |
| `warp-prism/docs/prompt.txt` | Ler - requisitos de acessibilidade, responsividade e demo coherence |
| `warp-prism/docs/research.md` | Ler - guidance de glass/performance e storytelling |
| `warp-prism/docs/draft.md` | Ler - gaps conhecidos e ordem de trabalho previa |
| `warp-prism/README.md` | Ler - documentacao divergente de stack |
| `warp-prism/pubspec.yaml` | Ler - runtime/dependencies Flutter e comandos de validacao |
| `warp-prism/lib/design_system/templates/master_detail_template.dart` | Ler - breakpoints atuais e host do layout principal |
| `warp-prism/lib/design_system/organisms/ds_shell.dart` | Ler - shell responsivo atual |
| `warp-prism/lib/design_system/organisms/ds_sidebar.dart` | Ler - navegacao/focus candidates |
| `warp-prism/lib/design_system/organisms/ds_topbar.dart` | Ler - search/actions/responsividade |
| `warp-prism/lib/design_system/organisms/ds_lane_board.dart` | Ler - estados e overflow horizontal |
| `warp-prism/lib/design_system/atoms/ds_glass_panel.dart` | Ler - custos de blur e fallback simples |
| `warp-prism/lib/data/parsers/workspace_parser.dart` | Ler - superficies de loading/error/backbone |
| `warp-prism/lib/data/models/models.dart` | Ler - contratos do modelo que sustentam views |
| `warp-prism/docs/reports/epic-10-polish-baseline.md` | Criar - baseline report do epic |

### How

1. Consolidate the planning corpus into one executable baseline instead of treating EPIC 10 as a generic polish bucket.
2. Use the current Flutter files as runtime truth, explicitly documenting why the `README` is stale unless fresh evidence says otherwise.
3. Split findings into two categories: real polish tasks that can proceed now, and blocked work that would require missing app surfaces.
4. Hand off exact file scopes and proof expectations to the follow-up tasks so they can execute without rediscovery.

### Why

EPIC 10 sits at the end of the roadmap, so mistakes here multiply across every polish slice. A baseline audit prevents wasted effort on stale docs, protects against phantom completion, and makes the rest of the open-task wave executable instead of aspirational.

---

## ⛔ Anti-Hallucination Guardrails

> [!CAUTION]
> Do not mark this task complete by saying "Flutter is probably the real stack" without a written evidence trail that references the actual files in `warp-prism/`.

> [!IMPORTANT]
> If a planned polish host surface is missing, record it as a blocker in the report and in dependent tasks; do not invent pages, routes, or feature modules that do not exist yet.

---

## 📋 Completion Evidence (preenchido pelo agente executor)

- **Arquivos criados/modificados**: `docs/reports/epic-10-polish-baseline.md` (criado), `docs/tasks/02-doing/1000-warp-prism-polish-baseline-audit.md` (movido de 01-open, status e exit conditions atualizados)
- **Testes que verificam o trabalho**: N/A — this is a read-only audit; no code was changed; Flutter SDK not available
- **Resultado dos comandos de validacao**: BLOCKED — `flutter analyze` and `flutter test` could not run (Flutter SDK not installed on machine; 0 test files exist)
- **Entrada no CHANGELOG**: Deferred — changelog engine not available
- **Agent-wiki / docs institucionalizacao**: Report created at `docs/reports/epic-10-polish-baseline.md` with full inventory, divergence classification, handoff table, and blocker list
- **Agente executor**: hermes-agent (Task 1000 subagent)
- **Data de conclusao**: 2026-06-07
