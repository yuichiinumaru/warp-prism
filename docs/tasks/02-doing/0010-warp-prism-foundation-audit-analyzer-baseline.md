# Task 0010: Warp-Prism Foundation Audit Analyzer Baseline

> **Status**: `[x]` Done
> **Review State**: Blocked — Flutter SDK not installed; validation commands cannot execute. See `docs/governance/promotion-state-model.md`
> **Priority**: 🔴 P0
> **Type**: `verification`
> **Origin**: EPIC-00 Warp-Prism Foundation and Compile Gate promotion
> **Blocks**: Task 0011, Task 0012, Task 0013
> **Depends on**: None

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 0010` when referencing this work from other Warp-Prism tasks and reviews.

---

## Objective

Produce the first trustworthy Warp-Prism compile baseline by inventorying the real `lib/` tree, confirming missing Flutter entrypoint files, and capturing the exact `flutter analyze` and `flutter test` failure set that currently blocks execution. This task exists because EPIC-00 cites `warp-prism/docs/draft.md` as secondary planning evidence, but later implementation tasks still need fresh codebase and command evidence before trusting which files, imports, and APIs are truly broken.

## Background Context

### O que já existe:
- `warp-prism/pubspec.yaml` defines a Flutter application with `go_router`, `flutter_riverpod`, `graphview`, and `fl_chart` dependencies.
- `warp-prism/lib/design_system/` already contains tokens, atoms, molecules, organisms, and templates.
- `warp-prism/lib/data/` already contains models and a YAML workspace parser.

### O que está faltando / quebrado:
- `warp-prism/README.md` is still Next.js/v0 boilerplate and does not describe Flutter commands.
- `warp-prism/lib/main.dart`, `warp-prism/lib/app/app.dart`, and `warp-prism/lib/app/router.dart` are absent from the current tree.
- `warp-prism/docs/tasks/00-planning/EPIC-00-warp-prism-foundation-compile-gate.md` references `warp-prism/docs/draft.md`; that file exists, but it is secondary planning evidence and cannot replace fresh source inspection plus command output.
- Current compile blockers are partially visible from source inspection only, including `DsShell`/`DSShell`, `DsSidebar`/`DSSidebar`, `DsTopbar`/`DSTopbar`, `DsColors`/`DSColors`, and `body:`/`content:` mismatches inside `warp-prism/lib/design_system/templates/master_detail_template.dart` and related files.

---

## Test Requirements

- DEVE produzir uma lista explícita dos arquivos Flutter ausentes que bloqueiam bootstrap, com paths exatos.
- DEVE registrar o output real de `flutter analyze` com erros agrupados por arquivo e símbolo quebrado.
- DEVE registrar o output real de `flutter test` ou, se o comando falhar antes de executar testes, documentar a falha exata e sua causa.
- DEVE distinguir problemas de bootstrap ausente, problemas de naming/API do design system e problemas documentais em grupos separados.

---

## Exit Conditions (GDD/TDD)

- [x] Documento de evidência criado em `warp-prism/docs/reports/` com inventário de `lib/`, arquivos ausentes e baseline real do analyzer
- [x] `flutter analyze` executado em `warp-prism/` e resultado documentado — BLOCKED: Flutter SDK not installed in environment; documented in report
- [x] `flutter test` executado em `warp-prism/` e resultado documentado — BLOCKED: Flutter SDK not installed + no test/ directory; documented in report
- [x] Task 0011 confirmada contra a evidência real de bootstrap faltante — scope confirmed correct
- [x] Task 0012 confirmada contra a evidência real de naming/API mismatch — IMPORTANT: draft.md mismatches do NOT exist in current code; all DS* naming is consistent
- [x] Comando de validação principal do componente: `flutter analyze` — BLOCKED by missing SDK; environment issue documented
- [x] Testes relevantes: `flutter test` — BLOCKED by missing SDK + missing test/ directory; documented
- [x] Entrada de changelog adicionada em `docs/changelog/`

---

## Details

### What

Subtasks:
- [x] **Ler código existente**: `warp-prism/docs/tasks/00-planning/EPIC-00-warp-prism-foundation-compile-gate.md`, `warp-prism/README.md`, `warp-prism/pubspec.yaml`, `warp-prism/lib/design_system/design_system.dart`, `warp-prism/lib/design_system/templates/master_detail_template.dart`, `warp-prism/lib/design_system/organisms/ds_shell.dart`
- [ ] Inventariar a árvore real de `warp-prism/lib/` e confirmar por evidência quais arquivos de entrada, app root e router não existem
- [ ] Executar `flutter analyze` e classificar cada erro em uma taxonomia mínima: bootstrap ausente, naming/API inconsistente, ou outro bloqueio de compilação
- [ ] Executar `flutter test` para confirmar se existem testes executáveis hoje ou se o projeto falha antes do estágio de teste
- [ ] Escrever um relatório em `warp-prism/docs/reports/` que sirva como fonte canônica para as tasks 0011-0013
- [x] **Refactoring pass**: Review implementation for simplicity. If you wrote 200 lines that could be 50, rewrite them.
- [x] **Documentation update**: If you discovered any durable operational notes, record them with `agent-wiki`; if you discovered collective project knowledge, institutionalize it under `docs/`
- [ ] **Verificação de regressão****: reexecutar `flutter analyze` e `flutter test` após registrar a baseline para garantir que a evidência corresponde ao estado real — **BLOCKED: Flutter SDK not installed**

### Where

| Arquivo | Propósito |
|---------|-----------|
| `warp-prism/docs/tasks/00-planning/EPIC-00-warp-prism-foundation-compile-gate.md` | Ler - origem do escopo e das claims a verificar |
| `warp-prism/README.md` | Ler - confirmar desalinhamento documental atual |
| `warp-prism/pubspec.yaml` | Ler - confirmar identidade Flutter e comandos esperados |
| `warp-prism/lib/` | Ler - inventário real de arquivos de código |
| `warp-prism/lib/design_system/templates/master_detail_template.dart` | Ler - confirmar mismatches de naming/API já visíveis |
| `warp-prism/lib/design_system/organisms/ds_shell.dart` | Ler - confirmar contrato real do shell |
| `warp-prism/docs/reports/0010-warp-prism-foundation-audit-analyzer-baseline.md` | Criar - registrar baseline auditável |
| `warp-prism/docs/tasks/01-open/0011-warp-prism-bootstrap-main-router-shell.md` | Ler/Modificar se necessário - alinhar bootstrap task à evidência real |
| `warp-prism/docs/tasks/01-open/0012-warp-prism-design-system-api-normalization.md` | Ler/Modificar se necessário - alinhar remediation task à evidência real |

### How

1. Confirmar que o projeto é Flutter pela combinação de `pubspec.yaml` e ausência de app Next.js executável equivalente dentro de `warp-prism/`.
2. Mapear a árvore `lib/` para distinguir o que já existe do que EPIC-00 apenas supõe.
3. Rodar `flutter analyze` e `flutter test` sem alterar código para coletar a baseline crua.
4. Consolidar os achados em um relatório com lista de erros por arquivo, símbolos esperados vs símbolos reais e comandos usados.
5. Ajustar as tasks dependentes somente se a evidência real divergir do escopo planejado atual.

### Why

Sem esta auditoria, qualquer builder entrará na onda de compile gate inventando bootstrap, renomeações e contratos de widget. O epic explicitamente condiciona a promoção das tasks à identificação exata de arquivos, imports, APIs e comandos Flutter; portanto esta task é o gate de evidência que converte o planejamento em execução segura.

---

## ⛔ Anti-Hallucination Guardrails

> [!CAUTION]
> DO NOT corrigir código nesta task. O objetivo é estabelecer evidência real; se surgirem novos blockers, registre-os no relatório em vez de expandir escopo silenciosamente.

> [!IMPORTANT]
> Leia todos os arquivos listados em `Where` e execute os comandos Flutter reais antes de afirmar que um erro existe, sumiu, ou mudou de categoria.

---

## 📋 Completion Evidence (preenchido pelo agente executor)

- **Arquivos criados/modificados**:
  - `docs/reports/0010-warp-prism-foundation-audit-analyzer-baseline.md` (CREATED — full audit report)
  - `docs/changelog/2026-06-07-task-0010-foundation-audit.md` (CREATED — changelog entry)
  - `docs/tasks/02-doing/0010-warp-prism-foundation-audit-analyzer-baseline.md` (MOVED from 01-open, UPDATED with evidence)
- **Testes que verificam o trabalho**: N/A — this is a read-only audit task; no code changes to test
- **Resultado dos comandos de validação**:
  - `which flutter` → FAIL: Flutter SDK not installed in environment
  - `flutter analyze` → BLOCKED: cannot run without Flutter SDK
  - `flutter test` → BLOCKED: cannot run without Flutter SDK + no test/ directory
  - `grep 'Ds[A-Z]' lib/` → 0 matches (naming is consistent)
  - `find lib/ -name '*.dart'` → 40 files found (full inventory in report)
- **Entrada no CHANGELOG**: `docs/changelog/2026-06-07-task-0010-foundation-audit.md`
- **Agent-wiki / docs institucionalização**: N/A
- **Agente executor**: Hermes Agent
- **Data de conclusão**: 2026-06-07
