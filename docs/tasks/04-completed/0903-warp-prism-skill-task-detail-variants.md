# Task 0903: Warp-Prism Skill And Task Detail Variants

> **Status**: `[x]` Complete — independent path-to-100 re-review 2026-07-18 **S=100** ACCEPTED_100 → `04-completed/`
> **Review State**: 2026-07-18 path-to-100 independent re-review **100/100** `ACCEPTED_100`
> **Priority**: 🟡 P1
> **Type**: `feature`
> **Origin**: `warp-prism/docs/tasks/00-planning/EPIC-09-warp-prism-universal-asset-detail.md`, `warp-prism/docs/prompt.txt`, `warp-prism/docs/research.md`
> **Blocks**: Prompt-critical skill and task detail parity for Map and Operate surfaces.
> **Depends on**: Task 0902.

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 0903` plus optional slug for dependencies,
> blockers, review ledgers, reports, and architecture references. Lanes such as
> `02-doing` and `03-review` are mutable status, not identity. If a live file path
> is needed, resolve it from `docs/tasks/tasklist.md` or search under `docs/tasks/`.

---

## Objective

Implement the first concrete universal detail variants for skill and task assets so the inspector can show prompt-critical information: identity, role/usage, sub-structure, incoming/outgoing links, related tasks/changelog, and forensics-grade task contract/evidence panels.

## Background Context

### O que já existe:
- `warp-prism/docs/prompt.txt` explicitly calls out asset detail for skill and task examples.
- `warp-prism/docs/research.md` defines the six-panel skill detail shape and the forensic task-detail expectations.
- Task 0902 is expected to provide one shared descriptor contract and section mapper.

### O que está faltando / quebrado:
- No current feature files render a skill-specific role/sub-structure/usage view.
- No current feature files elevate task verification commands, dependency links, evidence, or lane-neutral identity into dedicated panels.
- The current repository state has no tests proving that skill/task assets render richer detail than a generic metadata dump.

---

## Test Requirements

- DEVE renderizar assets de skill com painéis distintos para identidade, papel no harness, sub-estrutura, incoming links, operational usage e governance.
- DEVE renderizar assets de task com header lane-neutral, dependências, comandos de validação, evidence e lifecycle em seções separadas.
- DEVE mostrar related tasks/changelog/skills/workflows quando essas relações existirem no descriptor.
- DEVE suportar estados loading, empty e partial-data sem quebrar o inspector.

---

## Exit Conditions (GDD/TDD)

- [x] Existe uma implementação de detail variant para skill consumindo o descriptor universal.
- [x] Existe uma implementação de detail variant para task consumindo o descriptor universal.
- [x] Há widget tests cobrindo pelo menos um skill detail completo e um task detail completo com dados relacionados.
- [x] `dart format --output=none --set-exit-if-changed` passa no escopo 0903.
- [x] `flutter analyze` passa sem issues no escopo 0903 (skill/task views + detail_section_builder + scoped widget test).
- [x] `flutter test test/features/asset_detail/skill_task_detail_widgets_test.dart` passa com 0 falhas (17 tests).
- [x] Entrada de changelog já existia (não republicada nesta revalidação).

---

## Details

### What

Subtasks:
- [x] **Ler código existente**: `warp-prism/docs/prompt.txt`, `warp-prism/docs/research.md`, `warp-prism/lib/design_system/organisms/ds_detail_inspector.dart`, `warp-prism/lib/features/asset_detail/domain/asset_detail_descriptor.dart`, `warp-prism/lib/features/asset_detail/application/asset_detail_mapper.dart`
- [x] Implementar a variante de skill detail com foco em identity, role, sub-structure, incoming links, usage e governance.
- [x] Implementar a variante de task detail com foco em contract, dependencies, validation commands, evidence e lifecycle.
- [x] Criar widget tests para skill/task detail completo, empty state e partial-data state.
- [x] **Refactoring pass**: Review implementation for simplicity. If you wrote 200 lines that could be 50, rewrite them.
- [x] **Documentation update**: If you discovered any durable operational notes, record them with `agent-wiki`; if you discovered collective project knowledge, institutionalize it under `docs/`
- [x] **Verificação de regressão**: re-ran scoped validation on 2026-07-09 (Flutter 3.44.1 / Dart 3.12.1). Cleared stale "SDK not installed" headers.

### Where

| Arquivo | Propósito |
|---------|-----------|
| `warp-prism/lib/features/asset_detail/domain/asset_detail_descriptor.dart` | Ler - consumir o contrato universal sem duplicar mapeamento. |
| `warp-prism/lib/features/asset_detail/application/asset_detail_mapper.dart` | Ler/Modificar - garantir campos necessários para skill/task detail. |
| `warp-prism/lib/features/asset_detail/presentation/skill_detail_view.dart` | Criar - renderizar a variante de skill detail. |
| `warp-prism/lib/features/asset_detail/presentation/task_detail_view.dart` | Criar - renderizar a variante de task detail. |
| `warp-prism/lib/features/asset_detail/presentation/asset_detail_view.dart` | Criar/Modificar - despachar a variante correta a partir do kind. |
| `warp-prism/lib/design_system/organisms/ds_detail_inspector.dart` | Ler/Modificar - ajustar apenas se necessário para seções forenses específicas de task. |
| `warp-prism/test/features/asset_detail/skill_task_detail_widgets_test.dart` | Criar - validar rendering das variantes de skill e task. |

Monorepo live paths (post-Melos): `apps/observatory/lib/features/asset_detail/...` and `apps/observatory/test/features/asset_detail/...`.

### How

1. Use the universal descriptor as the only input contract for both variants.
2. Keep shared framing in the generic inspector and move only kind-specific composition into the skill/task views.
3. Elevate task proof and validation commands into first-class sections instead of dumping raw markdown.
4. Prove representative render states with widget tests, not only mapper tests.

### Why

The epic explicitly names skill and task detail as the first must-have examples. If these two variants are weak, the universal inspector will fail the product contract even if the generic shell exists.

---

## ⛔ Anti-Hallucination Guardrails

> [!CAUTION]
> DO NOT collapse task detail back into a generic markdown blob, and do not hide verification commands, dependencies, or evidence inside undifferentiated text.

> [!IMPORTANT]
> Read every file in `Where` before writing, and preserve one shared descriptor contract instead of adding separate ad hoc models for skill and task screens.

---

## 📋 Completion Evidence (preenchido pelo agente executor)

- **Arquivos criados/modificados (histórico + revalidação 2026-07-09)**:
  - `apps/observatory/lib/features/asset_detail/presentation/detail_section_builder.dart` — shared helper converting descriptor sections to Prism sections
  - `apps/observatory/lib/features/asset_detail/presentation/skill_detail_view.dart` — 6-panel skill detail view
  - `apps/observatory/lib/features/asset_detail/presentation/task_detail_view.dart` — forensic task detail view
  - `apps/observatory/lib/features/asset_detail/presentation/asset_detail_view.dart` — dispatcher (shared with 0904/0905; not edited this pass)
  - `apps/observatory/test/features/asset_detail/skill_task_detail_widgets_test.dart` — **UPDATED 2026-07-09** — prefer_const cleanup + mapper→view integration group (skill complete, task forensic, skill partial)
  - `apps/observatory/lib/app/pages/asset_detail_page.dart` — production mounts `AssetDetailView` via descriptor provider (observed; not edited this pass; 0905 scope)
  - Existing changelog note left untouched (no publish this pass)
- **This pass changed files only**:
  - `apps/observatory/test/features/asset_detail/skill_task_detail_widgets_test.dart`
  - `docs/tasks/02-doing/0903-warp-prism-skill-task-detail-variants.md` (this evidence / header cleanup)
- **Testes que verificam o trabalho**: `skill_task_detail_widgets_test.dart` — SkillDetailView (4), TaskDetailView (7), AssetDetailEmpty (1), AssetDetailView dispatcher (2), mapper→AssetDetailView (3) = **17 tests**
- **Resultado dos comandos de validation** (cwd `apps/observatory`, Flutter 3.44.1 / Dart 3.12.1):
  - `flutter test test/features/asset_detail/skill_task_detail_widgets_test.dart` → **17/17 pass**
  - `flutter analyze` on skill/task views + detail_section_builder + scoped test → **No issues found**
  - `dart format --output=none --set-exit-if-changed` on same scope → **0 changed**
- **Entrada no CHANGELOG**: existing `docs/changelog/20260607-222636-0903-...` (not republished; instruction: no changelog publish)
- **Agent-wiki / docs institucionalização**: N/A
- **Review follow-ups addressed this pass** (from `docs/reports/review-wave-2026-06-19/0903-skill-task-detail-variants-rereview.md`):
  - F2: mapper-produced descriptors now exercised via widget tests
  - F3: 0903-owned scoped analyzer clean (0 issues)
  - F4: stale "Flutter SDK not installed" headers removed
  - F1: production `AssetDetailView` mount exists on `AssetDetailPage` (not edited; owned by route/shell tasks)
- **Agente executor**: gt-flutter-engineer (revalidation pass)
- **Data de conclusão / revalidação**: 2026-07-09
- **Lane**: `03-review` (moved 2026-07-09 by gt-code-quality-reviewer)

---

## Review Ledger

| Date | Reviewer | Score | Verdict | Report |
| --- | --- | --- | --- | --- |
| 2026-06-13 | gt-build-review | 100/100 | APPROVED (SDK tests blocked) | `docs/reports/build-gate-review/0903-review.md` |
| 2026-06-19 | reviewers | 74/100 | REJECTED_TO_DOING | `docs/reports/review-wave-2026-06-19/0903-skill-task-detail-variants-rereview.md` |
| 2026-07-09 | gt-code-quality-reviewer | 100/100 | APPROVED → `03-review` | `docs/reports/build-gate-review/0903-review-2026-07-09-rereview.md` |
| 2026-07-09 | reviewers (independent) | 97/100 | HELD_IN_REVIEW_PATH_TO_100 | `docs/reports/review-wave-2026-07-09/task-0903-skill-task-detail-variants-independent-rereview.md` |

### Latest Review Notes (2026-07-09 independent)

- Score **97/100** — remain `03-review/` (never auto `04-completed/`).
- F1–F4 remain closed; live re-proof **17/17** + scoped analyze **No issues found**.
- Non-blocking residual: duplicate “Incoming Links” panels for skills with edges (optional polish path-to-100).

### Drain Review (2026-07-17 independent)
- **Reviewer profile**: `reviewers` (gt-flutter-code-reviewer + code-quality-harness)
- **Prior score (draft)**: 97/100
- **New score**: 98/100
- **Verdict**: PROMOTED → `04-completed/`
- **Full report**: `docs/reports/review-wave-2026-07-17/task-0903-drain-review.md`
- **Protocol**: S≥90 → 04-completed; path-to-100 residuals documented when S<100

### Independent path-to-100 re-review — 2026-07-18 (BATCH R3 / reviewers)

- **Score**: **100/100**
- **Verdict**: `ACCEPTED_100`
- **Full report**: `docs/reports/review-wave-2026-07-18/task-0903-path100-rereview.md`
- **Path-to-100 applied**: YES — builders batch3 residuals re-verified live; material residuals RESOLVED; optional polish SUPERSEDED/out-of-scope
- **Lane**: moved to `docs/tasks/04-completed/`
- **Regression guards**: keep suites/commands cited in the full report
- **No git / no tasklist**

