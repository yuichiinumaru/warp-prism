---
id: legacy-tool-catalog
title: Legacy Tool Catalog
scope: local
applies_to: [legacy-antigravity-sessions]
triggers: [tools, tool list, mcp tools, desktop commander]
priority: low
status: historical
---

> **⚠️ Atenção**: Essas são as ferramentas que você tem. Use-as com sabedoria!

---

# Ferramentas Disponíveis - Ganthritor Agent

> Lista completa de ferramentas (tools) disponíveis para o agente.
> Gerado em: 2026-04-03

---

## Ferramentas Nativas (Non-MCP)

### Navegação & Busca
| Ferramenta | Descrição |
|------------|-----------|
| `list_dir` | Lista arquivos e diretórios |
| `find_by_name` | Busca arquivos por nome (glob) |
| `grep_search` | Busca conteúdo em arquivos (ripgrep) |
| `code_search` | Busca semântica no codebase |
| `read_file` | Lê arquivo (formato cat -n) |

### Edição de Arquivos
| Ferramenta | Descrição |
|------------|-----------|
| `edit` | Edição cirúrgica (find/replace) |
| `multi_edit` | Múltiplas edições em um arquivo |
| `write_to_file` | Cria/overwrite arquivo |

### Terminal & Comandos
| Ferramenta | Descrição |
|------------|-----------|
| `run_command` | Executa comando (bash) - requer aprovação |
| `read_terminal` | Lê output de terminal |
| `command_status` | Verifica status de comando |

### Gerenciamento de Tarefas
| Ferramenta | Descrição |
|------------|-----------|
| `todo_list` | Cria/atualiza lista de TODOs |

### Skills & Workflows
| Ferramenta | Descrição |
|------------|-----------|
| `skill` | Invoca skill especializada |

---

## MCP Servers

### Desktop Commander (mcp2_*)
| Ferramenta | Descrição |
|------------|-----------|
| `mcp2_read_file` | Lê arquivos com paginação |
| `mcp2_write_file` | Escreve arquivos |
| `mcp2_edit_block` | Edição cirúrgica avançada |
| `mcp2_start_process` | Inicia processo interativo |
| `mcp2_read_process_output` | Lê output de processo |
| `mcp2_interact_with_process` | Interage com processo |
| `mcp2_list_directory` | Lista diretório (detalhado) |
| `mcp2_start_search` | Busca streaming |
| `mcp2_get_more_search_results` | Mais resultados de busca |
| `mcp2_create_directory` | Cria diretório |
| `mcp2_move_file` | Move/renomeia arquivo |
| `mcp2_get_file_info` | Metadata de arquivo |
| `mcp2_list_sessions` | Lista sessões ativas |
| `mcp2_list_processes` | Lista processos |
| `mcp2_force_terminate` | Força término de processo |
| `mcp2_kill_process` | Mata processo |
| `mcp2_write_pdf` | Cria/edita PDF |
| `mcp2_read_multiple_files` | Lê múltiplos arquivos |
| `mcp2_get_config` | Config do servidor |
| `mcp2_set_config_value` | Seta config |
| `mcp2_get_prompts` | Recupera prompts |
| `mcp2_get_recent_tool_calls` | Histórico de chamadas |
| `mcp2_get_usage_stats` | Estatísticas de uso |
| `mcp2_give_feedback_to_desktop_commander` | Envia feedback |

### Context7 (mcp0_*)
| Ferramenta | Descrição |
|------------|-----------|
| `mcp0_resolve-library-id` | Resolve ID de biblioteca |
| `mcp0_query-docs` | Consulta documentação |

### DeepWiki (mcp1_*)
| Ferramenta | Descrição |
|------------|-----------|
| `mcp1_ask_question` | Pergunta sobre repositório |
| `mcp1_read_wiki_structure` | Lê estrutura de wiki |
| `mcp1_read_wiki_contents` | Lê conteúdo de wiki |

### Sequential Thinking (mcp3_*)
| Ferramenta | Descrição |
|------------|-----------|
| `mcp3_sequentialthinking` | Pensamento sequencial estruturado |

---

## Ferramentas de Deploy & Web

| Ferramenta | Descrição |
|------------|-----------|
| `deploy_web_app` | Deploy para Netlify |
| `check_deploy_status` | Checa status de deploy |
| `read_deployment_config` | Lê config de deploy |
| `browser_preview` | Preview de browser |

---

## Ferramentas de Notebook

| Ferramenta | Descrição |
|------------|-----------|
| `read_notebook` | Lê notebook (.ipynb) |
| `edit_notebook` | Edita célula de notebook |

---

## Ferramentas de Memória

| Ferramenta | Descrição |
|------------|-----------|
| `create_memory` | Cria/atualiza/deleta memória |
| `trajectory_search` | Busca em trajetória |

---

## Ferramentas de Interação

| Ferramenta | Descrição |
|------------|-----------|
| `ask_user_question` | Pergunta ao usuário com opções |

---

## Resumo por Categoria

| Categoria | Quantidade |
|-----------|-----------|
| Nativas (non-MCP) | ~15 |
| Desktop Commander (mcp2) | 25+ |
| Context7 (mcp0) | 2 |
| DeepWiki (mcp1) | 3 |
| Sequential Thinking (mcp3) | 1 |
| Deploy/Web | 4 |
| Notebook | 2 |
| Memória | 2 |
| Interação | 1 |
| **TOTAL** | **~55+** |

---

## Observações Técnicas

- **Erro JSON parsing**: Ocorreu erro "invalid character '{' after top-level value" em chamadas consecutivas de ferramentas. Possível causa: estado corrompido do parser de tool calls.
- **Workaround**: Usar Desktop Commander (`mcp2_*`) como alternativa quando ferramentas nativas falham.
- **Ferramentas mais estáveis**: `grep_search`, `list_dir` (nativas); `mcp2_read_file`, `mcp2_write_file` (MCP)

---

*Arquivo gerado automaticamente pelo agente Artanis*
