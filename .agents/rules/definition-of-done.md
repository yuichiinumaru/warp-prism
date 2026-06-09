---
id: definition-of-done
title: Definition of Done
scope: universal
applies_to: [all-governed-repos]
triggers: [done, completion, review, close task, 03-review, 04-completed]
priority: critical
status: active
---

# ✅ Definition of Done (DoD) — Checklist

> **Uso**: Copie esta checklist para dentro da seção "Completion Evidence" da task ANTES de movê-la para `completed/`.
> Se QUALQUER item estiver `[ ]`, a task NÃO está completa. Sem exceção.
> **Tempo estimado**: < 5 minutos para completar esta verificação.

---

## Checklist

### 1. Código
- [ ] O comando de validação principal do componente passa sem erros nem warnings novos
- [ ] Os testes relevantes para o trabalho passam com 0 falhas
- [ ] Nenhum `todo!()`, `unimplemented!()`, ou `panic!("not implemented")` no código novo/modificado
- [ ] Nenhuma função/método com corpo vazio (`{}` ou `{ Default::default() }`) no código novo
- [ ] Nenhuma interpolação de string em queries SQL (usar queries parametrizadas com %s / $1)

### 2. Integração
- [ ] Todos os novos módulos são exportados no `mod.rs` pai (verificar: `grep "pub mod" src/.../mod.rs`)
- [ ] Todos os novos services/workers estão wired em `main.rs` ou no router da API (se aplicável)
- [ ] Imports não utilizados foram removidos (se introduzidos por ESTE trabalho)

### 3. Testes
- [ ] Pelo menos 1 teste novo verifica a funcionalidade principal do trabalho
- [ ] Testes cobrem o happy path E pelo menos 1 edge case (input vazio, `None`, erro de rede, etc.)
- [ ] Testes são determinísticos (não dependem de tempo, rede, ou estado externo)

### 4. Documentação & Governança
- [ ] Entrada de changelog adicionada via engine em `docs/changelog/` e root `CHANGELOG.md` reconstruído quando aplicável
- [ ] Memória operacional registrada via `agent-wiki` ou conhecimento coletivo institucionalizado em `docs/` quando aplicável
- [ ] Seção "Completion Evidence" da task preenchida com:
  - Arquivos criados/modificados (lista com paths)
  - Nomes dos testes que verificam o trabalho
  - Resultado dos comandos de validação relevantes (PASS)
  - Referência ao CHANGELOG entry
- [ ] Todas as exit conditions da task estão `[x]`
- [ ] Todas as subtasks da task estão `[x]`

### 5. Task Spec Compliance
- [ ] A task tem ≥ 50 linhas
- [ ] A task segue o template `docs/tasks/000-template.md`
- [ ] A primeira subtask era "Ler código existente" (e foi feita)

---

## Decisão

- **TODOS os items acima estão `[x]`?** → ✅ Mover para `docs/tasks/04-completed/`
- **Algum item está `[ ]`?** → ❌ NÃO mover. Completar os items pendentes primeiro.

> [!CAUTION]
> **Mover uma task para `completed/` sem satisfazer esta checklist é uma violação de governança.**
> A auditoria de Março 2026 encontrou 31.6% de phantom completions. Esta checklist existe para chegar a 0%.
