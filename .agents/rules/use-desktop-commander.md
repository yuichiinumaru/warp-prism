---
id: desktop-commander-terminal-policy
title: Desktop Commander Terminal Policy
scope: agent-family-specific
applies_to: [antigravity, cascade, windsurf, cursor]
triggers: [terminal, desktop commander, run_command, shell]
priority: high
status: active
---

# Regras: Tools específicas

**Prioridade**: OBRIGATÓRIA
**Agents:**: Antigravity, Cascade, Windsurf, Cursor.
1. Neste projeto, o terminal integrado do IDE apresenta instabilidades.
Sempre que precisar executar comandos de terminal (shell, bash, etc.), use as ferramentas do **Desktop Commander MCP** (`start_process`,`interact_with_process`, etc.) em vez do `run_command` nativo.
2. Comandos de leitura simples como `grep` e `find` podem usar as ferramentas nativas de busca e leitura do IDE (geralmente mais rápidas). Se o ide não tiver "read_multiple_files", desktop commander tem.
3. MCP Serena está com instabilidades temporariamente. Evite usar por enquanto. Se precisar salvar memória operacional do agente, use `agent-wiki` em `.agents/profiles/<agent>/`; se for conhecimento coletivo, institucionalize em `docs/`.
