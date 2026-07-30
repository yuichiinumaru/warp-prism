# Task 1050: Warp-Prism Storytelling and Demo Narrative Pass

> **Status**: `[x]` Complete — independent path-to-100 re-review 2026-07-18 **S=100** ACCEPTED_100 → `04-completed/`
> **Review State**: 2026-07-18 path-to-100 independent re-review **100/100** `ACCEPTED_100`
> **Latest Review**: 2026-07-09 — **100/100** PASS — `docs/reports/review-wave-2026-07-09/task-1050-storytelling-demo-narrative-rereview.md` (prior same-day 52/100 NEEDS FIX closed)
> **Priority**: 🟡 P1
> **Type**: `feature`
> **Origin**: EPIC 10 candidate story "Data storytelling and demo narrative pass" plus `warp-prism/docs/research.md` storytelling guidance
> **Blocks**: Task 1060
> **Depends on**: Task 1000

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1050` plus optional slug for dependencies,
> blockers, review ledgers, reports, and architecture references. Lanes such as
> `02-doing` and `03-review` are mutable status, not identity. If a live file path
> is needed, resolve it from `docs/tasks/tasklist.md` or search under `docs/tasks/`.

---

## Objective

Turn the observatory from a pile of components into a coherent demo story by defining the copy, insight framing, and walkthrough path that answer the EPIC 10 questions: what exists, what matters now, why it changed, what is risky, and how assets connect.

## Background Context

### O que ja existe:
- `warp-prism/docs/research.md` recommends guided storytelling and one-screen answers for "what exists", "what matters now", and "why this changed".
- `warp-prism/packages/warp_prism_ui/lib/src/organisms/ds_story_panel.dart` provides the reusable narrative surface for insights.
- Live observatory app under `apps/observatory/` with shell routes `/overview`, `/map`, `/operate`, `/history`, `/governance`.
- Feature hosts already compose `PrismStoryPanel` (Overview Current Story, Operate risk, History story, Governance risk stories).

### O que esta faltando / quebrado:
- ~~Demo script contradicted live routes (claimed no pages/shell/SDK)~~ — repaired 2026-07-09.
- ~~Narrative fields model-only~~ — panel now renders evidence / risk / connection.
- ~~Missing `PrismInsightRiskLevel`~~ — public alias added.

---

## Test Requirements

- DEVE produzir um roteiro de demo que cubra `Map`, `Operate`, `History` e `Governance` em uma ordem unica e justificavel.
- DEVE mapear explicitamente cada pergunta do epic para um host surface, insight panel, ou lacuna bloqueadora documentada.
- DEVE ter pelo menos um teste automatizado para o componente ou contrato narrativo ajustado nesta task.

---

## Exit Conditions (GDD/TDD)

- [x] Documento `warp-prism/docs/demo/epic-10-demo-script.md` exists and maps beats to **live** routes/hosts (v2.0 rewrite 2026-07-09)
- [x] `DSStoryPanel` / `PrismStoryPanel` renders evidence, risk badge, and connection for `PrismStoryNarrativeInsight`
- [x] Epic→surface mapping in script matches monorepo hosts under `apps/observatory/`
- [x] Scoped analyze on task-owned sources: **No issues found**
- [x] `cd packages/warp_prism_ui && flutter test test/story_panel_narrative_test.dart` — **18/18 passed** (2026-07-09 repair)
- [~] Package-wide `flutter analyze` / `flutter test` in `packages/warp_prism_ui` — **pre-existing unrelated failures**; not owned by Task 1050
- [x] Entrada de changelog adicionada via engine em `docs/changelog/` (existing historical note); **no new changelog this pass** (assignment)

---

## Details

### What

Subtasks:
- [x] **Ler codigo existente**: baseline/prompt/research, monorepo paths under `packages/warp_prism_ui/` + `apps/observatory/`
- [x] Definir o roteiro de demo com inicio, meio e fim claros para as quatro workspaces principais
- [x] Ajustar o contrato narrativo do `DSStoryPanel` para renderizar insights, evidence, risk callouts e connection language
- [x] Criar/atualizar regressao do contrato narrativo (model + widget pump)
- [x] **Refactoring pass**: Prefer Prism public API in tests/docs; fix withOpacity deprecations on story panel
- [x] **Documentation update**: Demo script v2.0 at `docs/demo/epic-10-demo-script.md`
- [x] **Verificacao de regressao**: scoped narrative tests re-run (Flutter available)

### Where

| Arquivo | Proposito |
|---------|-----------|
| `warp-prism/docs/reports/epic-10-polish-baseline.md` | Ler - surfaces reais do demo |
| `warp-prism/docs/prompt.txt` | Ler - framing do produto e areas top-level |
| `warp-prism/docs/research.md` | Ler - guidance de storytelling |
| `packages/warp_prism_ui/lib/src/organisms/ds_story_panel.dart` | Ler / Modificar - componente narrativo principal (monorepo path) |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Modificar - `PrismInsightRiskLevel` public alias |
| `packages/warp_prism_ui/test/story_panel_narrative_test.dart` | Criar/Atualizar - regressao do contrato narrativo |
| `warp-prism/docs/demo/epic-10-demo-script.md` | Criar/Reescrever - roteiro e key messages da demo |
| `apps/observatory/lib/app/router.dart` | Ler - live routes (evidence only) |
| `apps/observatory/lib/main.dart` | Ler - app entry (evidence only) |

### How

1. Use the epic acceptance questions as the narrative spine instead of inventing marketing copy.
2. Tie each question to a real surface or explicitly note the blocker if the host is still absent.
3. Keep the story component contract compact: insights, evidence, risk, and relational context.
4. Version the walkthrough in docs so demo readiness can be audited rather than re-explained verbally every session.

### Why

EPIC 10 is not only about polish; it is about demo coherence. A written narrative contract ensures the final review can judge whether the observatory actually communicates the intended concept instead of merely looking on-brand.

---

## ⛔ Anti-Hallucination Guardrails

> [!CAUTION]
> Do not write a glossy demo script that references screens, routes, or live data flows that the repository does not currently host.

> [!IMPORTANT]
> Every claimed demo beat must point to a real file-backed surface or be labeled as blocked/missing in the script.

---

## 📋 Completion Evidence (preenchido pelo agente executor)

- **Arquivos criados/modificados (implementation — prior executor)**:
  - CREATED: `docs/demo/epic-10-demo-script.md` — walkthrough (later rewritten)
  - MODIFIED: `packages/warp_prism_ui/lib/src/organisms/ds_story_panel.dart` — `InsightRiskLevel`, `DSStoryNarrativeInsight`
  - CREATED: `packages/warp_prism_ui/test/story_panel_narrative_test.dart`
  - Changelog: `docs/changelog/20260607-212540-1050-2026-06-07-task-1050-storytelling-narrative-repair-bot.md`
- **Arquivos modificados (path-to-100 repair — 2026-07-09)**:
  - REWRITTEN: `docs/demo/epic-10-demo-script.md` — v2.0 against live monorepo routes/hosts; killed no-SDK / no-page / Next.js claims; fixture inventory labeled point-in-time; illustrative snippets marked
  - MODIFIED: `packages/warp_prism_ui/lib/src/organisms/ds_story_panel.dart` — render evidence / risk badge / connection; `withValues` alpha; const empty state
  - MODIFIED: `packages/warp_prism_ui/lib/src/prism_aliases.dart` — `typedef PrismInsightRiskLevel = InsightRiskLevel`
  - REWRITTEN: `packages/warp_prism_ui/test/story_panel_narrative_test.dart` — Prism public barrel, honest samples, 3 widget render tests
  - MODIFIED: this task file (evidence + exit conditions)
- **Review findings addressed**:
  - F1: demo script live routes/shell/SDK — **fixed**
  - F2: stale Next.js / root lib / missing main.dart claims — **fixed**; fixture counts re-sourced
  - F3: narrative fields rendered + widget proof — **fixed**
  - F4: `PrismInsightRiskLevel` public alias + public-barrel tests — **fixed**
  - F5: ready_for_reviewer inflation — **kept no until independent re-review**
  - F6: scoped analyze noise — **cleared (No issues found)**
- **Testes que verificam o trabalho**:
  - `packages/warp_prism_ui/test/story_panel_narrative_test.dart` — PrismInsightRiskLevel, PrismStoryInsight, PrismStoryNarrativeInsight 4-layer contract, PrismStoryPanel acceptance + render of evidence/risk/connection
- **Resultado dos comandos de validacao** (2026-07-09, Flutter available):
  - `cd packages/warp_prism_ui && flutter test test/story_panel_narrative_test.dart --reporter expanded` → **+18 All tests passed**
  - `flutter analyze lib/src/organisms/ds_story_panel.dart lib/src/prism_aliases.dart test/story_panel_narrative_test.dart` → **No issues found**
  - Package-wide suite: still out of Task 1050 ownership for pre-existing failures
- **Entrada no CHANGELOG**: existing engine note under `docs/changelog/*1050*`; **no new changelog publish this pass** (per assignment)
- **Agent-wiki / docs institucionalizacao**: Demo script at `docs/demo/epic-10-demo-script.md` v2.0
- **Agente executor (path-to-100 repair)**: gt-flutter-engineer / docs (builder-orchestrator)
- **Data de conclusao (repair)**: 2026-07-09
- **Lane**: promoted `02-doing` → `03-review` (independent re-review score 100)
- **ready_for_reviewer**: **yes** (independent re-review PASS)
- **Blockers**: none for Task 1050 scope
- **Independent review (gt-code-quality-reviewer, 2026-07-09 pre-repair)**:
  - Score: **52/100** — Verdict: **NEEDS FIX** / leave `02-doing`
  - Report: `docs/reports/review-wave-2026-07-09/task-1050-storytelling-demo-narrative-review.md`
- **Independent re-review (gt-code-quality-reviewer, 2026-07-09 path-to-100)**:
  - Score: **100/100** — Verdict: **PASS**
  - Report: `docs/reports/review-wave-2026-07-09/task-1050-storytelling-demo-narrative-rereview.md`
  - Re-ran: `story_panel_narrative_test.dart` → **+18 All tests passed**
  - Re-ran: scoped analyze → **No issues found**
  - Demo script residual-hallucination spot-check: **clean** (routes, hosts, fixture counts 9/13/11/22/36, EdgeKind, Canonicality)
  - Lane action: moved to `docs/tasks/03-review/` (not `04-completed/`)
  - Residual non-blocking: product hosts still emit base `PrismStoryInsight`; narrative layers available in DS for optional host upgrade
)

## Review Ledger


### 2026-07-17 — drain independent re-review (`reviewers` / gt-code-quality-reviewer)

- **Date**: 2026-07-17
- **Reviewer profile**: `reviewers`
- **Score**: `98/100`
- **Verdict**: `ACCEPTED_PATH_TO_100`
- **Full report**: `docs/reports/review-wave-2026-07-17/task-1050-drain-review.md`
- **Lane outcome**: `docs/tasks/04-completed/`
- **Residuals**: hosts may still pass base PrismStoryInsight; component narrative ready

### Independent path-to-100 re-review — 2026-07-18 (BATCH R3 / reviewers)

- **Score**: **100/100**
- **Verdict**: `ACCEPTED_100`
- **Full report**: `docs/reports/review-wave-2026-07-18/task-1050-path100-rereview.md`
- **Path-to-100 applied**: YES — builders batch3 residuals re-verified live; material residuals RESOLVED; optional polish SUPERSEDED/out-of-scope
- **Lane**: moved to `docs/tasks/04-completed/`
- **Regression guards**: keep suites/commands cited in the full report
- **No git / no tasklist**

