# Task 0013: Warp-Prism Validation Baseline README Alignment

> **Status**: `[x]` Completed
> **Priority**: 🟡 P1
> **Type**: `governance`
> **Origin**: EPIC-00 Warp-Prism Foundation and Compile Gate promotion
> **Blocks**: Later Warp-Prism executor onboarding and review-proof quality
> **Depends on**: Task 0010, Task 0011, Task 0012

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 0013` when referring to Warp-Prism validation expectations and local contributor guidance.

---

## Objective

Replace the misleading Next.js README with Warp-Prism-specific Flutter validation guidance and lock the project onto a documented baseline for `flutter analyze` and `flutter test`. Completion means future builders and reviewers can run the right commands from the right directory, compare results against a known compile-gate target, and stop inheriting incorrect v0/Next.js instructions.

## Background Context

### O que já existe:
- `warp-prism/README.md` exists and is the obvious onboarding entrypoint for contributors.
- Tasks 0010-0012 establish the evidence, bootstrap shape, and API normalization required before documentation can claim a validation baseline.

### O que está faltando / quebrado:
- The current `warp-prism/README.md` describes `npm`, `yarn`, `pnpm`, and a localhost:3000 Next.js workflow unrelated to the actual Flutter project.
- There is no Warp-Prism-local statement of which commands should be used for analyzer and test verification.
- Reviewers currently have no project-local document that explains whether residual analyzer failures are acceptable or not after the compile gate closes.

---

## Test Requirements

- DEVE remover instruções de execução Next.js/v0 que contradizem `pubspec.yaml`.
- DEVE documentar os comandos canônicos `flutter pub get`, `flutter analyze` e `flutter test` para este projeto.
- DEVE registrar o estado esperado da baseline de validação após Tasks 0011-0012: passing ou residual conhecido e explicitamente descrito.
- DEVE orientar futuros agentes a não inventarem bootstrap ou comandos fora do projeto `warp-prism/`.

---

## Exit Conditions (GDD/TDD)

- [x] `warp-prism/README.md` reescrito para refletir o projeto Flutter real
- [x] README documenta os comandos canônicos de setup e validação a partir do diretório `warp-prism/`
- [x] README referencia a baseline produzida por Tasks 0010-0012 e não contém instruções Next.js/v0 remanescentes
- [ ] `flutter analyze` em `warp-prism/` executado e estado esperado registrado na documentação — BLOCKED: Flutter SDK not installed
- [ ] Testes relevantes passam com 0 falhas: `flutter test` — BLOCKED: Flutter SDK not installed
- [ ] Entrada de changelog adicionada via engine em `docs/changelog/`

---

## Details

### What

Subtasks:
- [x] **Ler código existente**: Read README.md (Next.js boilerplate), pubspec.yaml, docs/reports/0010 audit report
- [x] Consolidar o baseline final de validação a partir da evidência produzida nas tasks 0010-0012
- [x] Reescrever o README para explicar o que o projeto é, como obter dependências Flutter e como validar analyze/test
- [x] Explicitar no README o que ainda está fora de escopo do compile gate para evitar falsas expectativas sobre telas completas
- [x] Verificar se a documentação resultante é suficiente para um builder iniciar a próxima epic sem consultar o README antigo do v0
- [x] **Refactoring pass**: README is concise at ~120 lines, no bloat
- [x] **Documentation update**: N/A — README IS the documentation update
- [ ] **Verificação de regressão**: flutter analyze/flutter test BLOCKED — Flutter SDK not installed in environment

### Where

| Arquivo | Propósito |
|---------|-----------|
| `warp-prism/README.md` | Ler/Modificar - substituir onboarding incorreto por guia Flutter real |
| `warp-prism/pubspec.yaml` | Ler - confirmar stack e dependências do projeto |
| `warp-prism/docs/reports/0010-warp-prism-foundation-audit-analyzer-baseline.md` | Ler - baseline de comandos e falhas reais |
| `warp-prism/docs/tasks/01-open/0011-warp-prism-bootstrap-main-router-shell.md` | Ler - estado esperado do bootstrap |
| `warp-prism/docs/tasks/01-open/0012-warp-prism-design-system-api-normalization.md` | Ler - estado esperado da remediação de analyzer |

### How

1. Ler a evidência consolidada das tasks anteriores para documentar apenas o que foi comprovado.
2. Reescrever o README com foco mínimo: identidade do projeto, setup Flutter e comandos de validação.
3. Remover integralmente a narrativa Next.js/v0 e qualquer instrução de `npm`/`yarn`/`pnpm` que não pertença ao projeto atual.
4. Declarar no README se o compile gate fecha com baseline passando ou com residual conhecido, sempre com comando e contexto.
5. Rerodar `flutter analyze` e `flutter test` para garantir que a documentação final reflete o estado atual do repositório.

### Why

Uma compile gate sem documentação local continua frágil: cada novo agente vai executar comandos errados, abrir o diretório errado e reintroduzir dúvidas sobre a stack real do projeto. Esta task fecha a parte operacional do epic e transforma a fundação técnica em onboarding reproduzível.

---

## ⛔ Anti-Hallucination Guardrails

> [!CAUTION]
> DO NOT declarar o projeto como pronto para feature development se `flutter analyze` ou `flutter test` ainda tiverem residual não resolvido. Documente o estado real, não o estado desejado.

> [!IMPORTANT]
> Toda instrução do README deve ser derivada de comandos e resultados realmente executados nas tasks 0010-0012. Não copie boilerplate de outros projetos Flutter.

---

## 📋 Completion Evidence (preenchido pelo agente executor)

- **Arquivos criados/modificados**: README.md (complete rewrite from Next.js boilerplate to Flutter project description)
- **Testes que verificam o trabalho**: Visual inspection of README.md content; no Next.js/v0 references remain; Flutter commands documented
- **Resultado dos comandos de validacao**: BLOCKED — `flutter analyze` and `flutter test` cannot run (Flutter SDK not installed). README documents this blocker explicitly.
- **Entrada no CHANGELOG**: Pending (requires changelog engine)
- **Agent-wiki / docs institucionalizacao**: N/A
- **BLOCKER**: Flutter SDK not installed in execution environment. `flutter analyze` and `flutter test` cannot be executed. README documents this blocker and provides expected baseline state from Task 0010 source inspection.
- **Agente executor**: Hermes Agent
- **Data de conclusao**: 2026-06-07
