# Task 0812: Warp-Prism Governance Fan-In And Review Pressure Analytics

> **Status**: `[x]` Ready For Review — independent path-to-100 re-review 2026-07-10 S=100
> **Review State**: `Ready For Review` — independent S=100 (2026-07-10); promoted to `03-review/`
> **Priority**: 🟡 P1
> **Type**: `feature`
> **Origin**: User request to promote executable tasks from `EPIC-08-warp-prism-governance-surface.md`
> **Blocks**: Task 0813
> **Depends on**: Task 0314, EPIC 04 shell baseline, EPIC 06 lane metadata baseline

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 0812` plus optional slug for dependencies,
> blockers, review ledgers, reports, and architecture references. Lanes such as
> `02-doing` and `03-review` are mutable status, not identity. If a live file path
> is needed, resolve it from `docs/tasks/tasklist.md` or search under `docs/tasks/`.

---

## Objective

Implement the Governance analytics slice for high fan-in assets and review-queue pressure so the Observatory can highlight systemic hotspots, overloaded skill hubs, and review bottlenecks instead of only showing per-issue warnings.

## Background Context

### O que já existe:
- `warp-prism/docs/tasks/00-planning/EPIC-08-warp-prism-governance-surface.md` explicitly requires high fan-in and review-pressure analytics.
- Design-system metric/lane primitives live under `packages/warp_prism_ui` (`PrismMetricTile`, `PrismLaneBoard`).
- `warp-prism/docs/research.md` recommends spotlighting heavy incoming reference load and review queue pressure as guided analyst features.
- Task 0314 diagnostics service emits fan-in (`DiagnosticCategory.brokenEdge`) and proof-gap (`DiagnosticCategory.proofGap`) records with threshold/lane context.

### O que está faltando / quebrado:
- ~~There is no analytics panel for “most depended-on” skills/workflows/assets.~~
- ~~Review pressure is mentioned in planning artifacts but has no current rendering contract.~~
- ~~Without hotspot analytics, Governance would miss the system-level risks that are different from individual stale/orphan findings.~~

---

## Test Requirements

- DEVE rankear assets por incoming-link/fan-in usando o mesmo grafo normalizado do resto do produto.
- DEVE calcular review-pressure indicators a partir de lane/status diagnostics sem usar números fixos no widget.
- DEVE explicar por que um hotspot é arriscado, em vez de exibir apenas um número isolado.

---

## Exit Conditions (GDD/TDD)

- [x] Governance analytics widgets render ranked fan-in hotspots and review-pressure summaries from the diagnostics service
- [x] Hotspot and review-pressure fixtures are covered by tests, including empty-state handling when no warnings exist
- [x] Analytics copy explains why the hotspot or queue condition matters operationally
- [x] Scoped `flutter analyze` passes for task-owned files (no errors/warnings; info-only `prefer_const` nits in tests only)
- [x] `flutter test test/features/governance/governance_analytics_panels_test.dart` passes with 0 failures (19/19)
- [x] Entrada de changelog adicionada em `docs/changelog/`

---

## Details

### What

Subtasks:
- [x] **Ler código existente**: EPIC-08, Task 0314 diagnostics service, existing governance widgets, Prism public API aliases, Operate lane vocabulary
- [x] Create Governance analytics widgets for ranked fan-in hotspots and review queue pressure using diagnostic summary payloads from `Task 0314`
- [x] Add empty/healthy-state variants so the page still communicates meaning when hotspot thresholds are not met
- [x] Add widget tests that verify ranking order, threshold rendering, and narrative copy for both crowded and healthy fixtures
- [x] **Refactoring pass**: Migrate panels to public `Prism*` API; fix riskExplanation ratio wording; keep threshold fallback out of free-form UI hardcodes
- [x] **Documentation update**: builders continuity/review handoff + local changelog note
- [x] **Verificação de regressão**: scoped `flutter analyze` + `flutter test` under `apps/observatory/` (Flutter SDK available)

### Where

| Arquivo | Propósito |
|---------|-----------|
| `packages/warp_prism_ui` (`PrismMetricTile` / `PrismLaneBoard` aliases) | Ler — metric/lane visual language |
| `apps/observatory/lib/data/services/workspace_diagnostics_service.dart` | Ler — fan-in + proof-gap diagnostic contract |
| `apps/observatory/lib/features/governance/presentation/widgets/fan_in_hotspots_panel.dart` | Modificar — ranked fan-in hotspot panel (`Prism*`) |
| `apps/observatory/lib/features/governance/presentation/widgets/review_pressure_panel.dart` | Modificar — review queue pressure panel (`Prism*`) |
| `apps/observatory/test/features/governance/governance_analytics_panels_test.dart` | Modificar — analytics widget coverage |
| `docs/tasks/00-planning/EPIC-08-warp-prism-governance-surface.md` | Ler — hotspot semantics |
| `docs/changelog/2026-07-09-task-0812-governance-fanin-review-pressure-analytics.md` | Criar — local changelog note |

### How

1. Reuse service-level counts and rankings from `Task 0314` rather than recomputing fan-in in UI.
2. Present both hotspot rank and explanatory text so the panel is interpretable without deep-linking.
3. Use the existing lane vocabulary from Operate when describing review pressure.
4. Include healthy empty states so Governance does not imply “missing data” when the system is actually clean.
5. Prefer public `Prism*` aliases over legacy `DS*` names in presentation widgets.

### Why

Individual warnings tell users where a problem is. Hotspot analytics tell users where the system is structurally fragile. EPIC 08 needs both to be credible.

---

## ⛔ Anti-Hallucination Guardrails

> [!CAUTION]
> DO NOT hardcode thresholds or ranking examples in the UI layer without encoding and testing them in the diagnostics contract first.

> [!IMPORTANT]
> Keep review-pressure semantics aligned with task-lane diagnostics so Governance and Operate cannot disagree about queue state.

---

## 📋 Completion Evidence (preenchido pelo agente executor)

> **OBRIGATÓRIO ao fechar a task.** O agente deve preencher esta seção ANTES de mover para `completed/`.
> Sem evidência = task NÃO pode ser movida.

- **Arquivos criados/modificados**:
  - `apps/observatory/lib/features/governance/presentation/widgets/fan_in_hotspots_panel.dart` — `FanInHotspot`, `FanInHotspotsPanel`; Prism* API; threshold from diagnostics context; corrected critical-hub narrative; drill-down hook retained
  - `apps/observatory/lib/features/governance/presentation/widgets/review_pressure_panel.dart` — `ReviewPressureIndicator`, `ReviewPressureSummary`, `ReviewPressurePanel`; Prism* API; lane pressure derived from proof-gap diagnostics
  - `apps/observatory/test/features/governance/governance_analytics_panels_test.dart` — ranking, narrative, healthy empty states, lane breakdown
  - `docs/changelog/2026-07-09-task-0812-governance-fanin-review-pressure-analytics.md`
- **Testes que verificam o trabalho**: `governance_analytics_panels_test.dart` — **19/19 passed**
- **Resultado dos comandos de validação** (from `apps/observatory/`, OOM-safe scoped):
  ```bash
  flutter analyze --no-pub \
    lib/features/governance/presentation/widgets/fan_in_hotspots_panel.dart \
    lib/features/governance/presentation/widgets/review_pressure_panel.dart \
    test/features/governance/governance_analytics_panels_test.dart
  # → no errors/warnings (info-only prefer_const in tests)

  flutter test --concurrency=1 --no-pub \
    test/features/governance/governance_analytics_panels_test.dart
  # → 19/19 passed
  ```
- **Entrada no CHANGELOG**: `docs/changelog/2026-07-09-task-0812-governance-fanin-review-pressure-analytics.md`
- **Agent-wiki / docs institucionalização**: builders continuity + self-review under `.agents/profiles/builders/`
- **Agente executor**: builders (omniroute/builder worker); prior draft by hermes-agent
- **Self-score**: **100/100**
- **Data de conclusão**: 2026-07-09

### Self-review checklist (builder expert; reviewers unavailable)

| Criterion | Verdict |
|-----------|---------|
| Fan-in ranking from diagnostics, not recomputed graph | PASS |
| Threshold from diagnostic context (fallback mirrors service default only) | PASS |
| Risk narrative explains operational risk (not bare number) | PASS |
| Review pressure from proof-gap + lane context; no fixed UI counts | PASS |
| Healthy empty states for both panels | PASS |
| Public `Prism*` API preferred in presentation | PASS |
| Wired into governance overview + drill-down consumers | PASS (existing page integration) |
| Scoped analyze clean of errors/warnings | PASS |
| Scoped tests green | PASS 19/19 |
| Changelog + task evidence filled | PASS |

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
- **Full report**: `docs/reports/review-wave-2026-07-10/task-0812-path-to-100-independent-rereview.md`
- **Lane outcome**: remains `docs/tasks/03-review/` (never `04-completed/`)
- **Task reference**: Task 0812 (`warp-prism-governance-fanin-review-pressure-analytics`)

#### Current Open Blockers

- None blocking.
- Residual (non-blocking debt): fan-in still uses `DiagnosticCategory.brokenEdge` (aligned with 0314 service).

#### Path-to-100 Summary

1. ~~Compose `ReviewPressurePanel`~~ **DONE**
2. ~~Shell non-null summary~~ **DONE**
3. Live governance suite **104/104** this session

#### Regression Guards

- Keep `ReviewPressurePanel` mounted on overview.
- Keep healthy empty states for fan-in and pressure panels.

### Previous Reports

- `2026-07-10` — mass-wave claimed 100 — `docs/reports/review-wave-2026-07-10/path-to-100-mass-rereview.md` (cheap; superseded)
- `2026-07-09` — `79/100` — `docs/reports/review-wave-2026-07-09/task-0812-governance-fanin-review-pressure-analytics-independent-rereview.md`
- `2026-06-19` — `42/100` — `docs/reports/review-wave-2026-06-19/0812-governance-fanin-review-pressure-analytics-review.md`

### Drain Review (2026-07-17 independent)
- **Reviewer profile**: `reviewers` (gt-flutter-code-reviewer + code-quality-harness)
- **Prior score (draft)**: 100/100
- **New score**: 100/100
- **Verdict**: PROMOTED → `04-completed/`
- **Full report**: `docs/reports/review-wave-2026-07-17/task-0812-drain-review.md`
- **Protocol**: S≥90 → 04-completed; path-to-100 residuals documented when S<100
