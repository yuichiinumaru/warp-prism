# Task 0016: Warp Prism DS Organisms and Templates Alignment

> **Status**: `[x]` Completed — independent path100 re-review 2026-07-18 S=100/100
> **Review State**: `ACCEPTED_100` — S=100/100 (2026-07-18); see `docs/reports/review-wave-2026-07-18/task-0016-path100-rereview.md`
> **Priority**: 🔴 P0
> **Type**: `feature`
> **Origin**: `EPIC-01-warp-prism-atomic-design-system.md` candidate story `Organism API alignment with templates`
> **Blocks**: Task 0017, Task 0018
> **Depends on**: Task 0012, Task 0015

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 0016` plus optional slug for dependencies,
> blockers, review ledgers, reports, and architecture references. Lanes such as
> `02-doing` and `03-review` are mutable status, not identity. If a live file path
> is needed, resolve it from `docs/tasks/tasklist.md` or search under `docs/tasks/`.

---

## Objective

Repair the compile-breaking API drift between Warp Prism organisms and templates so the design-system shell layer can be composed without inventing adapters inside future feature screens. This task must leave `DSShell`, `DSSidebar`, `DSTopbar`, `DsGraphCanvas`, `MasterDetailTemplate`, and any related organisms on one coherent constructor contract that is analyzable and testable.

## Background Context

### O que ja existe:
- `packages/warp_prism_ui/lib/src/organisms/` contains shell, sidebar, topbar, graph canvas, lane board, timeline, detail inspector, and story panel components.
- `packages/warp_prism_ui/lib/src/templates/master_detail_template.dart` already defines desktop-first page layouts (`MasterDetailTemplate`, `CanvasTemplate`, `TimelineTemplate`).
- Public package surface is Prism* aliases; DS* names remain the internal organism/template contract.

### O que esta faltando / quebrado:
- Historical mismatches (`DsShell` vs `DSShell`, `content` vs `body`, `selectedId` vs `selectedIndex`, broken color tokens) were already repaired in prior work.
- Remaining gap closed in this pass: `organisms_layout_test.dart` imported the public Prism-only barrel and could not compile DS* symbols.

---

## Test Requirements

- DEVE eliminar as divergencias concretas citadas em `docs/draft.md` entre templates e organisms.
- DEVE permitir que ao menos um template de master-detail e um template de canvas sejam instanciados em teste sem adapters locais de tela.
- DEVE garantir que shell, sidebar, topbar e graph canvas usem somente tokens e molecules canonicos definidos nas tasks anteriores.
- DEVE deixar a API pronta para paginas reais consumirem `sidebar`, `topbar`, `master content`, `detail content` e overlays de forma previsivel.

---

## Exit Conditions (GDD/TDD)

- [x] Organisms barrel e templates barrel exportam APIs coerentes e instanciaveis
- [x] `master_detail_template.dart` e `ds_graph_canvas.dart` nao referenciam classes ou propriedades inexistentes
- [x] Se necessario, um `canvas` template dedicado e exportado sem quebrar o barrel de templates
- [x] Widget tests provam instanciacao de shell/template desktop-first e graph canvas basico
- [x] Scoped `dart analyze` on core organism/template files: 0 errors/warnings (info-only deprecations/style)
- [x] `flutter test test/organisms/organisms_layout_test.dart test/templates/templates_contract_test.dart` passa com 0 falhas
- [x] Entrada de changelog adicionada via engine em `docs/changelog/`

---

## Details

### What

Subtasks:
- [x] **Ler codigo existente**: organisms/templates under `packages/warp_prism_ui/lib/src/`, tests, changelog, barrels
- [x] Alinhar naming e constructor contracts entre shell, sidebar, topbar, graph canvas e templates (verified live; already coherent)
- [x] Decidir explicitamente se o canvas template continua no mesmo arquivo ou vai para um arquivo dedicado exportado por `templates.dart` — **keeps co-located in `master_detail_template.dart`; barrel exports file**
- [x] Adicionar testes de widget para os fluxos de composicao minima de shell/master-detail/canvas
- [x] **Refactoring pass**: Fixed organisms layout test imports to internal `src/` barrels (public barrel is Prism-only)
- [x] **Documentation update**: Completion evidence + changelog note for live revalidation
- [x] **Verificacao de regressao**: live Flutter SDK validation executed successfully

### Where

| Arquivo | Proposito |
|---------|-----------|
| `packages/warp_prism_ui/lib/src/organisms/organisms.dart` | Ler - barrel de organisms |
| `packages/warp_prism_ui/lib/src/organisms/ds_shell.dart` | Ler - shell principal e responsivo |
| `packages/warp_prism_ui/lib/src/organisms/ds_sidebar.dart` | Ler - navegacao lateral canonica |
| `packages/warp_prism_ui/lib/src/organisms/ds_topbar.dart` | Ler - topbar com busca e acoes |
| `packages/warp_prism_ui/lib/src/organisms/ds_graph_canvas.dart` | Ler - canvas com tokens canonicos |
| `packages/warp_prism_ui/lib/src/templates/templates.dart` | Ler - barrel de templates |
| `packages/warp_prism_ui/lib/src/templates/master_detail_template.dart` | Ler - contrato master-detail, canvas, timeline |
| `packages/warp_prism_ui/test/organisms/organisms_layout_test.dart` | Modificar - fix imports to internal barrels |
| `packages/warp_prism_ui/test/templates/templates_contract_test.dart` | Ler - testes de composicao de templates |

### How

1. Verify shared constructor contracts: class names, parameter names, search/filter/sidebar surface.
2. Confirm templates consume real organisms without invented aliases.
3. Prove with widget tests that desktop-first shell/templates instantiate using only the DS.

### Why

O epic exige que telas futuras componham primitives do design system sem styling local e sem adapters improvisados. Enquanto templates e organisms divergirem, qualquer builder vai ser empurrado a resolver layout dentro da feature screen, quebrando exatamente a regra principal do prompt.

---

## ⛔ Anti-Hallucination Guardrails

> [!CAUTION]
> DO NOT fechar esta task deixando adaptadores temporarios em telas futuras ou comments do tipo TODO para contratos claramente quebrados entre template e organism.

> [!IMPORTANT]
> Read EVERY file in `Where` before writing, and prefer one final public API per component instead of adding compatibility wrappers for both the broken and the canonical constructor shapes.

---

## 📋 Completion Evidence (preenchido pelo agente executor)

- **Arquivos criados/modificados**:
  - `packages/warp_prism_ui/test/organisms/organisms_layout_test.dart` — fixed imports from public Prism-only barrel to internal `src/organisms` + `src/tokens` barrels so DS* symbols resolve
  - `docs/changelog/2026-07-09-task-0016-ds-organisms-templates-live-revalidation.md` — live revalidation note
  - Task evidence updated; lane move `02-doing` → `03-review`
- **Testes que verificam o trabalho** (all green live):
  - Organisms: DSShell layout/inspector, DSShellResponsive wide/narrow, DSSidebar select/tap, DSTopbar title/breadcrumbs, DSGraphCanvas empty/nodes, barrel export compile check
  - Templates: MasterDetailTemplate shell/detail/search/filters, CanvasTemplate canvas/overlay, TimelineTemplate entries, barrel export compile check
- **Resultado dos comandos de validacao**:
  - `flutter test test/organisms/organisms_layout_test.dart test/templates/templates_contract_test.dart` → **20/20 passed**
  - `dart analyze lib/src/organisms/ds_shell.dart lib/src/organisms/ds_sidebar.dart lib/src/organisms/ds_topbar.dart lib/src/organisms/ds_graph_canvas.dart lib/src/organisms/organisms.dart lib/src/templates/master_detail_template.dart lib/src/templates/templates.dart` → **0 errors, 0 warnings** (6 info-only: prefer_final_fields / deprecated withOpacity / prefer_const)
  - Flutter SDK: 3.44.1 / Dart 3.12.1
- **Entrada no CHANGELOG**: `docs/changelog/2026-07-09-task-0016-ds-organisms-templates-live-revalidation.md` (prior: `docs/changelog/20260607-213805-0016-...`)
- **Agent-wiki / docs institucionalizacao**: builders continuity handoff under `.agents/profiles/builders/`
- **Self-score**: **100/100** — contracts coherent, tests green live, analyze clean on scoped core files, evidence complete, ready for independent review
- **Agente executor**: builder (omniroute/builder) / parent agentID=builders
- **Data de conclusao**: 2026-07-09

### 🔄 Review Ledger
* **[2026-07-09] Independent re-review (reviewers — gt-flutter-code-reviewer + gt-code-quality-reviewer):**
  - Report: `docs/reports/review-wave-2026-07-09/task-0016-ds-organisms-templates-independent-rereview.md`
  - Score: **93/100** — `HELD_IN_REVIEW_PATH_TO_100`
  - Lane: remain `docs/tasks/03-review/` (never auto `04-completed/`)
  - Blockers: none High
  - Residual: 4 template style infos; Objective wording still mentions historical `DsGraphCanvas`
  - Commands: scoped analyze 4 info/0 err/0 warn; layout+template tests **20/20** PASS

### Review Ledger — 2026-07-17 drain (independent)

| Date | Reviewer | Score | Verdict | Notes |
| --- | --- | --- | --- | --- |
| 2026-07-17 | reviewers (drain batch 1) | 100/100 | APPROVED_COMPLETED | Live re-validation. Prior 93/100. Template style infos residual cleared via master_detail const/final cleanup. Report: `docs/reports/review-wave-2026-07-17/task-0016-drain-review.md` |


### Path-to-100 Closeout — 2026-07-18 (builders)

- **Residual fixed**: Organisms/templates composition residual re-checked (master_detail style clean).
- **Commands**:
  - `dart analyze packages/warp_prism_ui/lib/src/templates` → No issues found
- **Remaining**: None (prior drain 100/100 held).
- **Lane**: remain in `docs/tasks/03-review/` (reviewers promote)


### Review Ledger — 2026-07-18 path100 independent re-review (BATCH R1)

| Date | Reviewer | Score | Verdict | Notes |
| --- | --- | --- | --- | --- |
| 2026-07-18 | reviewers (BATCH R1 independent) | 100/100 | ACCEPTED_100 | Live re-validation + path-to-100 residuals closed. Report: `docs/reports/review-wave-2026-07-18/task-0016-path100-rereview.md` |

