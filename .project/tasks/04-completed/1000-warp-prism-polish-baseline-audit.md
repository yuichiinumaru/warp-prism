# Task 1000: Warp-Prism Polish Baseline Audit

> **Review State**: Independent re-review 100/100 — held in `03-review`
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

> [!NOTE]
> Historical audit paths under root `lib/` are **SUPERSEDED** by Melos monorepo hosts
> (`packages/warp_prism_ui/`, `apps/observatory/`). Live path map: report §0.

---

## Objective

Produce a source-of-truth baseline for EPIC 10 that reconciles the current Flutter codebase, the stale Next.js `README`, and the polish requirements in the planning corpus so executors can work on accessibility, responsiveness, states, performance, and demo coherence without inventing missing screens or editing the wrong runtime surface.

---

## Background Context

### O que ja existe:
- `warp-prism/pubspec.yaml` and `warp-prism/lib/` clearly define a Flutter app surface with a design system, parser layer, and mock-workspace assets.
- `warp-prism/docs/prompt.txt` and `warp-prism/docs/research.md` define the visual direction, accessibility obligations, sparse glass guidance, and storytelling goals for the observatory demo.
- `warp-prism/docs/draft.md` already records that Phase 6 polish has not started and that compile/design-system alignment problems still exist.

### O que esta faltando / quebrado:
- `warp-prism/README.md` still describes a v0/Next.js project, which conflicts with the actual Flutter repository shape and can misroute polish work.
- There is no EPIC 10 baseline report that maps which real files own contrast, focus, responsive breakpoints, state rendering, blur usage, and demo narrative surfaces.
- Without this inventory, later EPIC 10 tasks risk phantom completion by polishing isolated widgets without proving that they host the actual demo path.

> **Live note (2026-07-09)**: README is now Melos/Flutter-aligned; root `lib/` is absent; design system and apps live under `packages/` and `apps/`. Background bullets above remain the original task framing.

---

## Test Requirements

- DEVE produzir `warp-prism/docs/reports/epic-10-polish-baseline.md` com uma matriz que relacione cada goal do EPIC 10 aos arquivos Flutter reais que o implementam hoje.
- DEVE classificar explicitamente a divergencia `README` Next.js vs `pubspec.yaml`/`lib/` Flutter como `stale doc`, `runtime truth`, ou `blocked decision`, sem deixar a ambiguidade implícita.
- DEVE listar, para cada slice posterior (Task 1010-1050), os arquivos candidatos de leitura/modificacao e o risco principal de execução.
- DEVE (refresh) mapear hosts históricos root-`lib/` → monorepo paths e revalidar com Flutter SDK disponível.

---

## Exit Conditions (GDD/TDD)

- [x] Relatorio `warp-prism/docs/reports/epic-10-polish-baseline.md` criado com inventario de superfícies, riscos e host surfaces do demo
- [x] Divergencia de stack (`README` vs Flutter real) classificada no relatorio com recomendacao operacional explicita
- [x] Tabela de handoff no relatorio criada para Task 1010, 1020, 1030, 1040 e 1050
- [x] Live monorepo path remap + stack reclassification documented in report §0 — **Done 2026-07-09**
- [x] Scoped validation with Flutter SDK present — **Done 2026-07-09** (see Completion Evidence; monorepo-wide green not claimed)
- [x] Focused polish-related tests green (contrast + state surface) — **Done 2026-07-09** (+43)
- [x] Entrada de changelog em `docs/changelog/` — **Done 2026-07-09** (evidence-refresh note)

> Historical exit items that said “BLOCKED: Flutter SDK not installed” and “changelog engine not available” are **superseded** by the 2026-07-09 refresh.

---

## Details

### What

Subtasks:
- [x] **Ler codigo existente**: `warp-prism/docs/prompt.txt`, `warp-prism/docs/research.md`, `warp-prism/docs/draft.md`, `warp-prism/README.md`, `warp-prism/pubspec.yaml`, historical Where hosts (now remapped — see report §0.2)
- [x] Criar o relatorio baseline com mapa de ownership para acessibilidade, breakpoints, estados, blur/glass e narrativa de demo
- [x] Registrar no relatorio os gaps que sao de polish real vs os que ainda sao bloqueios de superficie ausente, sem inventar paginas inexistentes
- [x] **Refactoring pass**: Review implementation for simplicity. If you wrote 200 lines that could be 50, rewrite them. — N/A (read-only audit, no product code written)
- [x] **Documentation update**: Baseline report + live monorepo delta §0 + changelog note
- [x] **Verificacao de regressao**: scoped `dart analyze` on UI package + observatory demo hosts; focused polish tests — **Done 2026-07-09**

### Where

| Arquivo | Proposito |
|---------|-----------|
| `warp-prism/docs/tasks/00-planning/EPIC-10-warp-prism-polish-accessibility-demo-coherence.md` | Ler - contrato do epic |
| `warp-prism/docs/prompt.txt` | Ler - requisitos de acessibilidade, responsividade e demo coherence |
| `warp-prism/docs/research.md` | Ler - guidance de glass/performance e storytelling |
| `warp-prism/docs/draft.md` | Ler - gaps conhecidos e ordem de trabalho previa |
| `warp-prism/README.md` | Ler - documentacao de stack (live: Flutter/Melos) |
| `warp-prism/pubspec.yaml` | Ler - workspace Melos / validation scripts |
| `packages/warp_prism_ui/lib/src/templates/master_detail_template.dart` | Ler - breakpoints e host master-detail (live) |
| `packages/warp_prism_ui/lib/src/organisms/ds_shell.dart` | Ler - shell responsivo (live) |
| `packages/warp_prism_ui/lib/src/organisms/ds_sidebar.dart` | Ler - navegacao/focus candidates (live) |
| `packages/warp_prism_ui/lib/src/organisms/ds_topbar.dart` | Ler - search/actions/responsividade (live) |
| `packages/warp_prism_ui/lib/src/organisms/ds_lane_board.dart` | Ler - estados e overflow horizontal (live) |
| `packages/warp_prism_ui/lib/src/atoms/ds_glass_panel.dart` | Ler - blur e fallback simples (live) |
| `apps/observatory/lib/data/parsers/workspace_parser.dart` | Ler - superficies de loading/error/backbone (live) |
| `apps/observatory/lib/data/models/models.dart` | Ler - contratos do modelo (live; legacy file) |
| `warp-prism/docs/reports/epic-10-polish-baseline.md` | Criar/atualizar - baseline report + §0 live delta |
| `warp-prism/docs/demo/epic-10-demo-script.md` | Ler - demo narrative host (post-baseline) |

### How

1. Consolidate the planning corpus into one executable baseline instead of treating EPIC 10 as a generic polish bucket.
2. Use the current Flutter files as runtime truth, explicitly documenting why the `README` is stale unless fresh evidence says otherwise.
3. Split findings into two categories: real polish tasks that can proceed now, and blocked work that would require missing app surfaces.
4. Hand off exact file scopes and proof expectations to the follow-up tasks so they can execute without rediscovery.
5. On evidence refresh: remap hosts to monorepo paths, reclassify stack divergence, and record scoped analyze/test proof without greenwashing full monorepo gates.

### Why

EPIC 10 sits at the end of the roadmap, so mistakes here multiply across every polish slice. A baseline audit prevents wasted effort on stale docs, protects against phantom completion, and makes the rest of the open-task wave executable instead of aspirational.

---

## ⛔ Anti-Hallucination Guardrails

> [!CAUTION]
> Do not mark this task complete by saying "Flutter is probably the real stack" without a written evidence trail that references the actual files in `warp-prism/`.

> [!IMPORTANT]
> If a planned polish host surface is missing, record it as a blocker in the report and in dependent tasks; do not invent pages, routes, or feature modules that do not exist yet.

> [!CAUTION]
> Do not treat historical root-`lib/` paths as live edit targets after Melos migration. Do not claim monorepo-wide `flutter analyze` / `flutter test` green from scoped package runs.

---

## 📋 Completion Evidence (preenchido pelo agente executor)

### 2026-07-09 Evidence refresh (gt-evidence-refresher / builders)

- **Arquivos criados/modificados**:
  - `docs/reports/epic-10-polish-baseline.md` — added §0 live monorepo delta (path remap, stack reclassification, goal status delta, validation); marked §1–§2/§8–§9 historical where superseded
  - `docs/tasks/02-doing/1000-warp-prism-polish-baseline-audit.md` — headers, Where table, exit conditions, evidence (lane **left in `02-doing`**)
  - `docs/changelog/20260709-181650-1000-polish-baseline-audit-evidence-refresh-builders.md` — changelog draft note
- **Testes que verificam o trabalho**: N/A product code — docs audit. Focused host proof: UI contrast + state surface tests.
- **Resultado dos comandos de validacao** (cwd repo root unless noted; 2026-07-09):
  - `flutter --version` → Flutter **3.44.1** / Dart **3.12.1**
  - `test -d lib` → `ROOT_LIB:ABSENT`
  - Host files from remapped Where table → all **EXISTS**
  - `README.md` → Flutter/Melos monorepo (no Next.js/`npm run` stack claim)
  - Report sections Goal matrix + Stack Divergence + Handoff 1010–1050 → **present**
  - `dart analyze --format=machine packages/warp_prism_ui/lib` → **82 issues: ERROR 0, WARNING 1, INFO 81**
  - `dart analyze --format=machine` observatory demo-feature scope → **48 issues: ERROR 0, WARNING 0, INFO 48**
  - `cd packages/warp_prism_ui && flutter test test/accessibility_focus_contrast_test.dart test/state_surface_test.dart` → **+43 All tests passed!**
  - Test inventory: ui **40**, observatory **39** `*_test.dart` (full monorepo suite **not** claimed)
- **Entrada no CHANGELOG**: `docs/changelog/20260709-181650-1000-polish-baseline-audit-evidence-refresh-builders.md`
- **Agent-wiki**: skipped (parent instruction: no agent-wiki)
- **Agente**: gt-evidence-refresher (builders parent)
- **Data**: 2026-07-09
- **Self-score**: **100/100 as docs baseline + live path/evidence refresh** (not a claim that EPIC 10 polish slices 1010–1050 are all closed)

### Historical evidence (SUPERSEDED machine gates — 2026-06-07)

- **Arquivos criados/modificados**: `docs/reports/epic-10-polish-baseline.md` (created), task moved from 01-open
- **Testes**: N/A; Flutter SDK not available
- **Validacao**: BLOCKED — `flutter analyze` / `flutter test` (SDK missing; 0 tests)
- **Changelog**: Deferred (engine claim)
- **Agente executor**: hermes-agent (Task 1000 subagent)
- **Data de conclusao original**: 2026-06-07

---

## Review readiness

- Deliverable report exists with required matrix, divergence classification, and handoff table.
- Live monorepo path ownership documented; stale SDK/README blockers reclassified.
- Scoped validation recorded; builder internal review promoted lane to `03-review`.
- **ready_for_reviewer**: **yes**

---

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports. Persistent findings and regression guards are part of
> the acceptance contract.

### Latest Review

- **Date**: 2026-07-09
- **Reviewer profile**: `reviewers` (`gt-flutter-code-reviewer` + `gt-code-quality-reviewer`)
- **Score**: `100/100`
- **Verdict**: `ACCEPTED_100`
- **Full report**: `docs/reports/review-wave-2026-07-09/task-1000-polish-baseline-independent-rereview.md`
- **Lane outcome**: remains in `03-review` (never auto-promoted to `04-completed`)
- **Task reference**: Task 1000 (`warp-prism-polish-baseline-audit`)

#### Current Open Blockers

- None for Task 1000 docs baseline scope. EPIC 10 slice residual risks remain inventory-only under report §0.4/§0.6 (owned by Tasks 1010–1050).

#### Path-to-100 Summary

- At 100 for docs-baseline contract. Optional: refresh §0.5 analyze counts on next evidence touch.

### Previous Reports

- `2026-07-09` — `100/100` — internal builder path-to-100 (ledger-only; no separate packet)
  - **Carried forward**: none material
  - **Resolved since**: §0.6 live handoff; HISTORICAL labels on §3–§7/§10–§11
  - **Regression guard**: do not reintroduce root-`lib/` as live edit targets; do not greenwash monorepo-wide analyze/test
- `2026-06-17` — `42/100` — `docs/reports/review-wave-2026-06-17/task-1000-review.md`
  - **Carried forward**: none (Melos path/status drift fixed)
  - **Resolved since**: live §0 remap + SDK validation
  - **Regression guard**: baseline must map current monorepo hosts
- `2026-06-13` — `100/100` — `docs/reports/build-gate-review/1000-review.md` (pre-Melos; superseded)

### Drain Review (2026-07-17 independent)
- **Reviewer profile**: `reviewers` (gt-flutter-code-reviewer + code-quality-harness)
- **Prior score (draft)**: 100/100
- **New score**: 100/100
- **Verdict**: PROMOTED → `04-completed/`
- **Full report**: `docs/reports/review-wave-2026-07-17/task-1000-drain-review.md`
- **Protocol**: S≥90 → 04-completed; path-to-100 residuals documented when S<100
