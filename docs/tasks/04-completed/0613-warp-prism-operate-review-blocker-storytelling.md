# Task 0613: Warp-Prism Operate Review and Blocker Storytelling

> **Status**: `[x]` Promoted
> **Review State**: Promoted — independent review approved; focused analyzer/tests pass
> **Priority**: 🟡 P1
> **Type**: `feature`
> **Origin**: EPIC 06 promotion from `warp-prism/docs/tasks/00-planning/EPIC-06-warp-prism-operate-surface.md`
> **Blocks**: None
> **Depends on**: Task 0610, Task 0611, Task 0612

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 0613` in reports, changelog evidence, and follow-up polish work.

---

## Objective

Add the storytelling and risk-signaling layer that makes blocked work, review pressure, and proof-risk tasks obvious on the Operate surface. Completion means the board and task inspector no longer present all work with equal visual weight: review queues, blocker clusters, proof gaps, and lane/status mismatches must surface as visible summaries and callouts.

## Background Context

### O que já existe:
- `warp-prism/lib/design_system/organisms/ds_story_panel.dart` provides an observability-friendly storytelling surface for highlights and narrative insights.
- `warp-prism/lib/design_system/molecules/ds_task_card.dart` already shows proof state, dependency count, and review score but does not yet elevate cluster-level risk.
- EPIC 06 acceptance criteria explicitly say the UI must make blocked, review, and proof-risk work obvious.

### O que está faltando / quebrado:
- There is no derived diagnostics layer for review queue pressure, blocker clusters, proof-risk counts, or lane/state mismatch warnings.
- The current task card and lane board surfaces do not summarize lane-level risk or explain why a lane is hot.
- `warp-prism/docs/research.md` frames Operate as an evidence pipeline, but the current code has no storytelling pass over task data.

---

## Test Requirements

- DEVE destacar visualmente tasks blocked/review/proof-risk com regras derivadas do contrato de dados, não por hardcode manual em fixtures.
- DEVE resumir pelo menos review queue pressure, blocker clusters e proof-risk counts em um painel narrativo ou summaries equivalentes.
- DEVE sinalizar mismatch entre lane atual e estado declarado quando a projeção disponibilizar esse diagnóstico.
- DEVE cobrir pelo menos um widget or pure-Dart test para os cálculos de storytelling/diagnostics.

---

## Exit Conditions (GDD/TDD)

- [x] Existe uma camada derivada de diagnostics/storytelling para Operate com review pressure, blocker clusters, proof-risk counts, e lane mismatch detection.
- [x] O board and/or inspector renderiza summaries visíveis para risco operacional usando `DSStoryPanel` ou componentes equivalentes do design system.
- [x] `flutter test --concurrency=1 --no-pub apps/observatory/test/features/operate/operate_storytelling_test.dart` passa cobrindo diagnostics derivation e rendering principal.
- [x] `flutter analyze` passa sem erros para os arquivos alterados pelo storytelling layer.
- [x] Testes relevantes passam com 0 falhas.
- [x] Entrada de changelog adicionada via engine em `docs/changelog/`.

---

## Details

### What

Subtasks:
- [x] **Ler código existente**: Read ds_story_panel.dart, ds_task_card.dart, ds_lane_board.dart, operate_workspace_view_model.dart, task_projection.dart
- [x] Criar a camada de diagnostics/storytelling que deriva hotspots do conjunto de tasks filtrado e do conjunto completo.
- [x] Integrar os insights ao board e/ou inspector de forma que blocked/review/proof-risk work fique visível sem abrir cada task manualmente.
- [x] Adicionar testes para os cálculos de hotspot e para a rendering principal do painel de storytelling.
- [x] **Refactoring pass**: Implementation is ~170 lines for the derivation module; pure function pattern keeps it minimal.
- [x] **Documentation update**: N/A — self-documenting via typed interfaces and test coverage.
- [x] **Verificação de regressão**: Render tests proven valid via Widget tester in `operate_storytelling_test.dart` and Flutter SDK is now correctly validated.

### Where

| Arquivo | Propósito |
|---------|-----------|
| `warp-prism/lib/design_system/organisms/ds_story_panel.dart` | Ler/Modificar se o painel precisar de pequenas extensões para insights de risco operacional. |
| `warp-prism/lib/design_system/molecules/ds_task_card.dart` | Ler/Modificar se badges visuais extras forem necessários para proof-risk/blocker emphasis. |
| `warp-prism/lib/design_system/organisms/ds_lane_board.dart` | Ler/Modificar para summaries por lane ou hotspot accents mínimos. |
| `warp-prism/lib/features/operate/operate_workspace_view.dart` | Modificar para mostrar o painel/resumo de storytelling no contexto do Operate. |
| `warp-prism/lib/features/operate/operate_workspace_view_model.dart` | Modificar para expor diagnostics derivados. |
| `warp-prism/lib/features/operate/operate_storytelling.dart` | Criar para derivar review pressure, blocker clusters, proof-risk counts, e mismatch warnings. |
| `warp-prism/test/features/operate/operate_storytelling_test.dart` | Criar para testes puros/widget do storytelling layer. |

### How

1. Define deterministic rules for review pressure, blocker cluster detection, proof-risk counts, and lane/status mismatch using the task projection from `Task 0610`.
2. Keep the derivation logic in a small feature-level module so the board widgets stay dumb and the rules remain testable.
3. Render the results as a concise observability story panel and, where justified, as targeted visual emphasis on affected lane cards.
4. Ensure the signals respect current filters while still being able to summarize total workspace pressure when helpful.
5. Prefer a few strong insights over a wall of badges; the goal is to make risky work obvious, not noisier.

### Why

EPIC 06 is not complete when cards merely exist in columns. The product brief and research both expect a system that tells operators what matters right now. Without explicit storytelling, the highest-risk review backlog and blocked work remain hidden in the same visual density as low-risk tasks, which undermines the whole Execution Ledger concept.

---

## ⛔ Anti-Hallucination Guardrails

> [!CAUTION]
> DO NOT fabricate hotspot narratives from static prose. Every insight shown on the Operate surface must trace back to parsed task metadata or deterministic derived counts.

> [!IMPORTANT]
> Keep the storytelling layer scoped to execution visibility. Governance-wide drift, canonicality, and stale-path diagnostics belong to EPIC 08 unless they are directly needed for a task-lane mismatch warning here.

---

## 📋 Completion Evidence (preenchido pelo agente executor)

- **Arquivos criados/modificados**:
  - `warp-prism/lib/features/operate/operate_storytelling.dart` (criado) — Pure derivation: review pressure, blocker clusters, proof-risk counts, lane mismatches
  - `warp-prism/lib/features/operate/operate_workspace_view_model.dart` (modificado) — Exposes OperateStoryDiagnostics via state, derives on every emit
  - `warp-prism/lib/features/operate/operate_workspace_view.dart` (modificado) — Renders _OperateStoryPanel using DSStoryPanel when signals present
  - `warp-prism/test/features/operate/operate_storytelling_test.dart` (criado) — 14 test cases covering all derivation rules and Widget rendering of the story panel
- **Testes que verificam o trabalho**: `apps/observatory/test/features/operate/operate_storytelling_test.dart`
- **Resultado dos comandos de validação**: PASS. 14/14 tests green. `flutter analyze` passes.
- **Entrada no CHANGELOG**: Adicionado em `docs/changelog/2026-06-18-0613-operate-storytelling.md`
- **Agent-wiki / docs institucionalização**: N/A
- **Agente executor**: Antigravity (builders)
- **Data de conclusão**: 2026-06-30

## Review Ledger

- **[2026-06-18] F1 (Task 0612 rejection) Resolved**: Task 0612 has been successfully completed and approved into `04-completed`. Operate inspector and selection are now fully integrated and unblock 0613.
- **[2026-06-18] F2 (Not reachable) Resolved**: The proxy placeholder in `app/pages/operate_page.dart` has been unwired and `OperateWorkspaceView` is successfully serving as the principal route under `/operate`.
- **[2026-06-18] F3 (Rendering Proof) Resolved**: Added dedicated `OperateWorkspaceView Storytelling Widget Rendering` widget tests to successfully verify the conditionally-rendered `PrismStoryPanel` pops correctly when operational risks are derived. Fails safely into nothing when risk is zero.
- **[2026-06-18] F4 (Analyzer) Resolved**: Checked and isolated. `operate_workspace_view.dart`, `operate_storytelling_test.dart`, and counterparts scan cleanly with `No issues found!`.
- **[2026-06-30] 92/100 REVIEW_APPROVED_PROMOTED**: Independent reviewer reran the allowed scoped gates: `flutter test --concurrency=1 --no-pub apps/observatory/test/features/operate/operate_storytelling_test.dart` PASS (14/14) and `flutter analyze --no-pub apps/observatory/lib/features/operate apps/observatory/test/features/operate` PASS (0 issues). Previous blockers F1-F4 are resolved: Task 0612 is promoted, `/operate` reaches `OperateWorkspaceView`, widget rendering proof exists, and analyzer is clean. Report: `docs/reports/review-wave-3/0613-re-review-2026-06-30.md`. Non-blocking path-to-100 items: clear/search accessibility polish and dependency-blocker precision edge case.


### 2026-07-18 — Path-to-100 independent re-review (reviewers / BATCH R2)
- **Score**: 98/100 — ACCEPTED_COMPLETE
- **Report**: `docs/reports/review-wave-2026-07-18/task-0613-path100-rereview.md`
- **path100_applied**: yes; residual path-to-100 list empty
- **Lane**: promoted to `docs/tasks/04-completed/`
- **Top finding**: Unresolved-only blocker precision proven
