# Plano de Ondas de Execução — Warp Prism (57 Tasks)

> **Gerado em**: 2026-06-07
> **Fonte**: 57 arquivos em `warp-prism/docs/tasks/01-open/`
> **Observação**: Dependências em EPIC (ex: "EPIC 02 stable contract") são tratadas como
> gates suaves — a task pode ser iniciada na onda designada, mas pode precisar de pausa
> se o EPIC correspondente ainda não tiver sido promovido.

---

## RESUMO NUMÉRICO

| Onda | Qtd Tasks | Tema(s) |
|------|-----------|---------|
| 0    | 4         | Fundação + Auditoria Polish + Governança |
| 1    | 12        | Mock corpus início, Bootstrap, DS Tokens, EPIC 10 slices |
| 2    | 7         | Corpus progresso, DS Atoms, README, EPIC 10 finalize |
| 3    | 4         | Corpus validação, DS Organisms, Data models |
| 4    | 6         | Corpus completo, Graph backbone, Shell routes, Map scaffold |
| 5    | 3         | Shell overview, Operate foundation, Graph services |
| 6    | 5         | Shell hardening, Map catalog/graph, Diagnostics |
| 7    | 4         | Map selection, Operate board, History fixture, Providers |
| 8    | 5         | Map final, Operate inspector, History parser, Governance begin |
| 9    | 4         | Operate storytelling, History route, Governance panels, Asset detail begin |
| 10   | 4         | History modes, Governance analytics, Asset detail descriptor |
| 11   | 3         | Governance drilldown, Asset detail variants begin |
| 12   | 3         | Asset detail variants final, Responsive detail |
| **Total** | **57** | |

---

## LEGENDA DE SÍMBOLOS

- `→` indica dependência direta (hard)
- `~→` indica dependência em EPIC inteiro (soft gate)
- `[P]` = paralelizável (domínios de arquivo diferentes)
- `[S]` = sequencial (mesmo domínio de arquivo)
- Prioridades: 🔴 P0, 🟡 P1, 🟢 P2
- Tipos: feature, remediation, verification, governance

---

## ONDA 0 — Fundação Pura (Zero Dependências)

**4 tasks — Todas paralelas entre si [P]**

| ID | Nome | Prioridade | Tipo | Domínio |
|----|------|------------|------|---------|
| 0001 | Mock Workspace Contract Baseline | 🔴 P0 | governance | docs/, assets/ |
| 0010 | Foundation Audit Analyzer Baseline | 🔴 P0 | verification | docs/reports/, lib/ (leitura) |
| 1000 | Polish Baseline Audit | 🔴 P0 | verification | docs/reports/, lib/ (leitura) |
| 1070 | Task Namespace Integrity Verification | 🟡 P1 | governance | docs/tasks/ |

**Tema**: Fundação e auditorias iniciais

**Entregáveis**:
- 0001: Contrato do corpus mock (`docs/mock-workspace-corpus-contract.md`) + manifesto (`assets/mock_workspace/manifest.yaml`)
- 0010: Relatório de baseline do analyzer com inventário de `lib/` e erros reais do `flutter analyze`
- 1000: Relatório baseline EPIC 10 (`docs/reports/epic-10-polish-baseline.md`) mapeando hosts do demo
- 1070: Verificação de integridade do namespace de tasks

---

## ONDA 1 — Bootstrap, Tokens e Primeiras Fatias EPIC 10

**12 tasks — Paralelas por domínio [P]**

| ID | Nome | Prioridade | Tipo | Depende de | Domínio |
|----|------|------------|------|------------|---------|
| 0002 | Agent And Workflow Markdown Fixtures | 🔴 P0 | feature | 0001 | assets/mock_workspace/.agents/ |
| 0003 | Skill Hierarchy Markdown Fixtures | 🔴 P0 | feature | 0001 | assets/mock_workspace/.agents/skills/ |
| 0011 | Bootstrap Main Router Shell | 🔴 P0 | feature | 0010 | lib/main.dart, lib/app/ |
| 0012 | Design System API Normalization | 🔴 P0 | remediation | 0010 | lib/design_system/ |
| 0014 | DS Token Contract and Inventory | 🔴 P0 | feature | 0010, 0012 | lib/design_system/tokens/ |
| 0310 | Backbone Model Contract Audit | 🔴 P0 | feature | ~→ EPIC 02 | lib/data/models/ |
| 0410 | App Root Router Shell Skeleton | 🔴 P0 | feature | 0011, ~→ EPIC 03 | lib/app/router.dart |
| 1010 | Accessibility Contrast Focus Pass | 🔴 P0 | remediation | 1000 | lib/design_system/atoms/, organisms/ |
| 1020 | Responsive Shell Detail Pass | 🔴 P0 | feature | 1000 | lib/design_system/templates/, organisms/ |
| 1030 | Empty Loading Error State Coherence | 🟡 P1 | feature | 1000 | lib/design_system/molecules/, organisms/ |
| 1040 | Glass Performance Budget Pass | 🟡 P1 | remediation | 1000 | lib/design_system/atoms/ |
| 1050 | Storytelling Demo Narrative Pass | 🟡 P1 | feature | 1000 | lib/design_system/organisms/ |

**Tema**: Design system + Bootstrap + Data model + Polish EPIC 10

**Entregáveis**:
- 0002: 9 agentes + 11 workflows markdown com frontmatter
- 0003: 13 super-skills com SKILL.md e hierarquia
- 0011: `main.dart` + `app.dart` + `router.dart` compilando
- 0012: Nomes DS* normalizados, templates compilando contra organisms reais
- 0014: Contrato canônico de tokens + inventário DS + mismatch ledger
- 0310: Backbone normalizado (AssetKind, EdgeKind, Canonicality, WorkspaceAsset, WorkspaceEdge)
- 0410: Router com rotas para Overview, Map, Operate, History, Governance, Asset Detail
- 1010-1050: Slices de polish do EPIC 10

**NOTA sobre 0012 e 0014**: São sequenciais [S] no mesmo domínio — 0012 corrige APIs, 0014 formaliza o contrato. 0014 depende de 0012.

---

## ONDA 2 — Corpus Avança, Atoms/README, EPIC 10 Finaliza

**7 tasks**

| ID | Nome | Prioridade | Tipo | Depende de | Domínio |
|----|------|------------|------|------------|---------|
| 0004 | Task Lane Markdown Corpus | 🔴 P0 | feature | 0001, 0002, 0003 | assets/mock_workspace/docs/tasks/ |
| 0013 | Validation Baseline README Alignment | 🟡 P1 | governance | 0010, 0011, 0012 | README.md |
| 0015 | DS Atoms and Molecules Normalization | 🔴 P0 | feature | 0014 | lib/design_system/atoms/, molecules/ |
| 0311 | Markdown Frontmatter Parser Fixtures | 🔴 P0 | feature | 0310, ~→ EPIC 02 | lib/data/parsers/ |
| 0411 | Shell Navigation and Responsive Frame | 🔴 P0 | feature | 0410, ~→ EPIC 01 DS | lib/app/, lib/features/shell/ |
| 0710 | History Fixture Ledger Corpus | 🔴 P0 | feature | 0005(soft), ~→ EPIC 02 | assets/mock_workspace/docs/changelog/ |
| 1060 | EPIC 10 Acceptance Audit | 🔴 P0 | verification | 1010, 1020, 1030, 1040, 1050 | docs/reports/ |

**Paralelas [P]**: 0004, 0013, 0015, 0311, 0411, 0710, 1060 (domínios diferentes)
**Nota**: 0710 depende de 0005 (Onda 3) mas pode ser iniciada com dependência soft — enriquece o corpus de 0005

**Entregáveis**:
- 0004: 20+ tasks markdown em 5 lanes com frontmatter completo
- 0013: README reescrito para Flutter
- 0015: Atoms e molecules com APIs coerentes e widget tests
- 0311: Parser de frontmatter markdown + fixtures de teste
- 0411: Shell responsivo com navegação left-rail + fallback narrow
- 0710: Corpus de changelog enriquecido para History com 12+ entries
- 1060: Relatório final de aceitação EPIC 10

---

## ONDA 3 — Corpus Finaliza, Organisms/Models, Map Prepara

**4 tasks — Sequenciais no corpus [S], Paralelas entre domínios [P]**

| ID | Nome | Prioridade | Tipo | Depende de | Domínio |
|----|------|------------|------|------------|---------|
| 0005 | Changelog Markdown Corpus | 🔴 P0 | feature | 0001-0004 | assets/mock_workspace/docs/changelog/ |
| 0312 | Read-Only Mock Workspace Repository | 🟡 P1 | feature | 0310, 0311, ~→ EPIC 02 | lib/data/repositories/ |
| 0412 | Overview Dashboard Derived Metrics | 🔴 P0 | feature | 0410, 0411, ~→ EPIC 03 | lib/features/overview/ |
| 0510 | Map Workspace Scaffold | 🔴 P0 | feature | ~→ EPIC 03, 0410, 0411, 0413(soft) | lib/features/map/ |

**Paralelas entre si [P]**: 0005 e 0312 em domínios diferentes; 0412 e 0510 em features diferentes

**Entregáveis**:
- 0005: 12+ changelog entries com frontmatter e referências cruzadas
- 0312: Interface read-only de repositório + implementação mock + testes
- 0412: Página Overview com métricas derivadas e story panel
- 0510: Módulo `lib/features/map/` com route, estado e 4 tabs

---

## ONDA 4 — Validação do Corpus, Graph Backbone, Shell, Map Tabs

**6 tasks**

| ID | Nome | Prioridade | Tipo | Depende de | Domínio |
|----|------|------------|------|------------|---------|
| 0006 | Mock Corpus Validation and Legacy Archive | 🔴 P0 | verification | 0001-0005 | tool/, .archive/, pubspec.yaml |
| 0313 | Graph Normalization Edge Inference | 🟡 P1 | feature | 0310, 0311, 0312 | lib/data/services/ |
| 0511 | Map Catalog Tabs and Filters | 🟡 P1 | feature | 0510 | lib/features/map/ (catálogo) |
| 0512 | Map Graph Modes and Adapters | 🟡 P1 | feature | 0510, ~→ EPIC 03 | lib/features/map/ (graph) |
| 0610 | Operate Task Projection Contract | 🔴 P0 | feature | ~→ EPIC 02, ~→ EPIC 03 | lib/data/parsers/ (task) |
| 0901 | Asset Detail Route Contract | 🔴 P0 | feature | ~→ EPIC 03, ~→ EPIC 04 | lib/app/ (detail route) |

**Paralelas [P]**: 0006 (tool), 0313 (services), 0511 (map catalog), 0512 (map graph), 0610 (parsers), 0901 (routes) — todos domínios diferentes

**Entregáveis**:
- 0006: Validador automatizado do corpus + arquivamento do legado
- 0313: Serviço de grafo canônico com inferência de edges (contains, routesTo, dependsOn, etc.)
- 0511: Painel de catálogo com Agents, Skills, Workflows + search/filters
- 0512: Projeções de grafo: containment, operational, evidence
- 0610: Projeção de task para Operate (parser de task markdown com 5 lanes)
- 0901: Rota canônica `/assets/:assetId` com controller de seleção

---

## ONDA 5 — Shell Endurece, Operate Começa, Diagnósticos

**3 tasks**

| ID | Nome | Prioridade | Tipo | Depende de | Domínio |
|----|------|------------|------|------------|---------|
| 0314 | Derived Metrics Governance Diagnostics | 🟡 P1 | feature | 0310, 0312, 0313 | lib/data/services/ (metrics) |
| 0413 | Shell States and Deep Link Fallbacks | 🟡 P1 | feature | 0410, 0411, 0412 | lib/features/shell/, lib/app/ |
| 0611 | Operate Board Surface and Filters | 🟡 P1 | feature | 0610, ~→ EPIC 04 | lib/features/operate/ |

**Paralelas [P]**: 0314 (services), 0413 (shell), 0611 (operate) — domínios diferentes

**Entregáveis**:
- 0314: Métricas derivadas + diagnósticos de governança (órfãos, stale, proof gaps, fan-in)
- 0413: Shell states (loading/empty/error) + deep-link fallbacks testados
- 0611: Board Operate com 5 lanes + filtros por owner/skill/workflow/proof state

---

## ONDA 6 — Map Seleção/Inspector, Operate Detalhe, Providers, History Parser

**5 tasks**

| ID | Nome | Prioridade | Tipo | Depende de | Domínio |
|----|------|------------|------|------------|---------|
| 0315 | Provider Load State View Model Contracts | 🟡 P1 | feature | 0312, 0313, 0314 | lib/data/providers/ |
| 0513 | Map Selection and Inspector | 🟡 P1 | feature | 0511, 0512 | lib/features/map/ (inspector) |
| 0612 | Operate Task Detail Inspector | 🟡 P1 | feature | 0610, 0611 | lib/features/operate/ (inspector) |
| 0711 | History Parser and Filter Index | 🔴 P0 | feature | 0710, ~→ EPIC 03 | lib/data/parsers/ (changelog), lib/data/repositories/ |
| 0810 | Governance Canonicality Boundaries Overview | 🟡 P1 | feature | 0314, ~→ EPIC 04 | lib/features/governance/ |

**Paralelas [P]**: Todos em domínios diferentes

**Entregáveis**:
- 0315: Providers Riverpod com estados loading/error/empty/success para snapshot, grafo, métricas, diagnósticos
- 0513: Seleção compartilhada catalog↔graph + inspector Map
- 0612: Inspector de task com metadata, commands, evidence, dependências
- 0711: Parser de changelog frontmatter + read model History com facets e impact edges
- 0810: Página de overview de governança com contagens por canonicality class

---

## ONDA 7 — Map Finaliza, Operate Board Detalhado, History Fixture Pronto, Painéis Governança

**4 tasks**

| ID | Nome | Prioridade | Tipo | Depende de | Domínio |
|----|------|------------|------|------------|---------|
| 0514 | Map States and Proof Coverage | 🟢 P2 | feature | 0511, 0512, 0513 | lib/features/map/ (states) |
| 0613 | Operate Review and Blocker Storytelling | 🟡 P1 | feature | 0610, 0611, 0612 | lib/features/operate/ (storytelling) |
| 0712 | History Workspace Timeline Route | 🟡 P1 | feature | 0711, ~→ EPIC 04 | lib/features/history/ |
| 0811 | Governance Orphan Stale Proof Panels | 🟡 P1 | feature | 0314, ~→ EPIC 06, ~→ EPIC 07 | lib/features/governance/ (panels) |

**Paralelas [P]**: Todas em features diferentes

**Entregáveis**:
- 0514: Estados explícitos Map (loading, empty, no-results, error, no-selection) + testes
- 0613: Storytelling de risco Operate (review pressure, blocker clusters, proof-risk)
- 0712: Página History com timeline, filtros e seleção
- 0811: Painéis de governança para orphans, stale references, proof gaps

---

## ONDA 8 — History Completa, Governança Analytics

**2 tasks — Paralelas [P]**

| ID | Nome | Prioridade | Tipo | Depende de | Domínio |
|----|------|------------|------|------------|---------|
| 0713 | History Story and Impact Views | 🟡 P1 | feature | 0711, 0712 | lib/features/history/ (story modes) |
| 0812 | Governance Fanin Review Pressure Analytics | 🟡 P1 | feature | 0314, ~→ EPIC 04, ~→ EPIC 06 | lib/features/governance/ (analytics) |

**Entregáveis**:
- 0713: Project Story + Impact Story modes na página History
- 0812: Painéis de fan-in hotspots e review queue pressure

---

## ONDA 9 — Governança Drilldown, Asset Detail Começa

**2 tasks — Paralelas [P]**

| ID | Nome | Prioridade | Tipo | Depende de | Domínio |
|----|------|------------|------|------------|---------|
| 0813 | Governance Drilldown and Storytelling | 🟡 P1 | feature | 0810, 0811, 0812, ~→ EPIC 09 | lib/features/governance/ (drilldown) |
| 0902 | Universal Asset Detail View Model | 🟡 P1 | feature | 0901, ~→ EPIC 03 | lib/features/asset_detail/ |

**Entregáveis**:
- 0813: Drill-down de warnings para assets + risk-story summaries
- 0902: Descriptor universal de asset detail + mapper + controller

---

## ONDA 10 — Asset Detail Variantes Começam

**2 tasks — Paralelas [P]**

| ID | Nome | Prioridade | Tipo | Depende de | Domínio |
|----|------|------------|------|------------|---------|
| 0903 | Skill and Task Detail Variants | 🟡 P1 | feature | 0902 | lib/features/asset_detail/ (skill/task views) |
| 0904 | Agent Workflow Changelog Detail Variants | 🟡 P1 | feature | 0902 | lib/features/asset_detail/ (agent/workflow/changelog views) |

**Entregáveis**:
- 0903: Views de detalhe para skill (6 painéis) e task (forensic detail)
- 0904: Views de detalhe para agent, workflow, changelog + fallback genérico

---

## ONDA 11 — Asset Detail Responsivo Finaliza

**1 task**

| ID | Nome | Prioridade | Tipo | Depende de | Domínio |
|----|------|------------|------|------------|---------|
| 0905 | Responsive Detail Shell Integration | 🟡 P1 | feature | 0901, 0903, 0904 | lib/design_system/templates/, lib/features/ |

**Entregáveis**:
- 0905: Detail integrado ao shell com split-pane (wide), overlay (medium), full-screen (narrow)

---

## DEPENDÊNCIAS CRÍTICAS E CAMINHOS LONGOS

### Caminho Crítico Principal (12 ondas):
```
0001 → 0002/0003 → 0004 → 0005 → 0006 (EPIC 02 corpus)
                                    ↓
0010 → 0012 → 0014 → 0015 → 0016 → 0017 → 0019 → 0020
       ↓
       0011 → 0410 → 0411 → 0412 → 0413 → 0510 → 0511/0512 → 0513 → 0514
                              ↓
                              0610 → 0611 → 0612 → 0613
```

### Caminhos Paralelos Críticos:
1. **Mock Corpus** (Ondas 0→4): 0001→0002/0003→0004→0005→0006
2. **Design System** (Ondas 0→3): 0010→0012→0014→0015→0016→0017
3. **Bootstrap/Shell** (Ondas 0→5): 0010→0011→0410→0411→0412→0413
4. **Data Layer** (Ondas 1→5): 0310→0311→0312→0313→0314→0315
5. **Polish EPIC 10** (Ondas 0→2): 1000→1010/1020/1030/1040/1050→1060

### Gates de EPIC (Soft Dependencies):
- **EPIC 02** (mock corpus): Necessário para 0310, 0311, 0312, 0610, 0710
- **EPIC 03** (data layer): Necessário para 0410, 0412, 0510, 0512, 0610, 0711, 0901, 0902
- **EPIC 04** (shell): Necessário para 0411, 0611, 0712, 0810, 0812
- **EPIC 06** (operate): Necessário para 0811, 0812
- **EPIC 07** (history): Necessário para 0811
- **EPIC 09** (detail): Necessário para 0813

---

## GRUPEMENTO POR TEMA

### 🏗️ Fundação (Ondas 0-1)
- 0001, 0010, 0011, 0012, 0013, 0014, 0310, 0410

### 🎨 Design System (Ondas 1-3)
- 0012, 0014, 0015, 0016, 0017, 0018 (0018 na Onda 3, depende de 0017)

### 📦 Mock Corpus (Ondas 0-4)
- 0001, 0002, 0003, 0004, 0005, 0006

### 🔧 Data Layer / Graph Backbone (Ondas 1-6)
- 0310, 0311, 0312, 0313, 0314, 0315

### 🖥️ Shell / Overview (Ondas 1-5)
- 0410, 0411, 0412, 0413

### 🗺️ Map Surface (Ondas 3-7)
- 0510, 0511, 0512, 0513, 0514

### 📋 Operate Surface (Ondas 4-7)
- 0610, 0611, 0612, 0613

### 📜 History Surface (Ondas 2-8)
- 0710, 0711, 0712, 0713

### 🏛️ Governance Surface (Ondas 6-9)
- 0810, 0811, 0812, 0813

### 🔍 Universal Asset Detail (Ondas 4-11)
- 0901, 0902, 0903, 0904, 0905

### ✨ Workspace Snapshot Quick Win (Ondas 1-2)
- 0019, 0020

### 🎯 Polish / EPIC 10 (Ondas 0-2)
- 1000, 1010, 1020, 1030, 1040, 1050, 1060

### 📋 Governança de Tasks (Onda 0)
- 1070

---

## NOTAS DE EXECUÇÃO

1. **App deve compilar antes de UI**: Tasks 0010→0011→0012 devem completar antes de qualquer
   tela de produto. O `flutter analyze` deve passar (ou residual documentado) antes de 0017+.

2. **Design system antes de telas**: Tasks 0014→0015→0016→0017 devem preceder Map/Operate/
   History/Governance.

3. **Mock corpus antes de data layer**: Tasks 0001→0006 devem existir antes que 0311/0312
   possam funcionar com dados reais.

4. **Quick wins 0019/0020**: Podem ser executadas após 0011+0017, independentemente do
   EPIC 03 completo. São "workspace snapshot" que escaneiam diretório real.

5. **Tasks 0310-0315 são o backbone**: Sem elas, nenhuma tela de produto pode consumir
   dados normalizados. São a maior dependência transversal.

6. **EPIC 10 (1000-1060)**: Executável em paralelo com tudo porque depende apenas de 1000
   (Onda 0). Mas 1060 (audit final) precisa de 1010-1050 completos.

7. **Ordem dentro de cada onda**: Tasks marcadas [S] no mesmo domínio devem ser sequenciadas.
   Tasks [P] em domínios diferentes podem correr em paralelo por agentes independentes.
