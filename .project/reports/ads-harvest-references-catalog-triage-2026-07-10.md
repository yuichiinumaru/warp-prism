# External Intelligence: warp-prism/references catalog — ADS organism harvest triage

> **Date**: 2026-07-10  
> **Mission**: Mission C — scan `references/` for net-new ADS-worthy organism harvests  
> **Lens**: Warp Prism Observatory + CyberCore pilot + `packages/warp_prism_ui` Prism ADS  
> **Constraint**: read-only; patterns only (no code transplant); **do not re-propose EPIC-15 Map HUD / SB–Osiris organisms**  
> **Baseline organisms**: `packages/warp_prism_ui/lib/src/organisms/`  
> **EPIC-15 lock**: `docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md` + unified harvest `docs/reports/ads-organism-harvest-unified-2026-07-10.md`

---

## Executive Summary

- **Verdict**: The local `references/` catalog is rich in **ops-console, agent-chat, workflow-canvas, and provider-health** UI patterns that are **orthogonal** to EPIC-15’s map-first HUD harvest. Highest yield is **OmniRoute admin + traffic inspector**, **DeepChat / Open WebUI agent transcript organisms**, **Sim Studio workflow + execution terminal**, and **Cybernetics Core admin/MCP inspector shells**.
- **Best transferable items** (organism-level, net-new vs EPIC-15):
  1. Agent **message transcript** with typed blocks (tool-call, think, plan, status history)
  2. **Artifact workbench** (side panel / multi-type preview registry)
  3. **Provider health matrix** (provider → account → model grid)
  4. **Traffic / request inspector** (stream list + detail tabs + timing waterfall)
  5. **MCP capability inspector** (capability-gated tab strip)
  6. **Workflow DAG stage contract** (node/edge canvas for route graphs — not MapLibre)
  7. **Execution console** with grouped runs + structured output panel
  8. **Admin page shell pack** (title/actions + data-state + metric grid)
- **Primary risk**: Scope bleed into full chat products, live mutation, MITM/proxy product surface, or re-building EPIC-15 HUD organisms under new names. Treat chat/ops as **fixture-first CyberCore organisms**, not Observatory route rewrites.

---

## Evidence Map

| Claim | Evidence | Confidence |
| --- | --- | --- |
| EPIC-15 already owns Map HUD, layer panel, tool strip, intel, locate, time scrubber, ticker, OSINT, AI analyst, terminal/agent shell (O-01–O-28) | `docs/tasks/00-planning/EPIC-15-...md` L68–113; unified harvest L25–55 | High |
| Current WP organisms are shell/ops-board class, not agent-chat or workflow-canvas class | `packages/warp_prism_ui/lib/src/organisms/organisms.dart` L1–30 | High |
| Open WebUI is a full chat + admin SvelteKit app with rich message/status/artifact UI | `references/secondary-open-webui-open-webui/src/lib/components/chat/**` | High |
| DeepChat is Electron+Vue agent client with typed message blocks + artifact registry | `references/secondary-thinkinaixyz-deepchat/src/renderer/src/components/{message,artifacts,chat}/**` | High |
| Sim Studio has workflow canvas + resizable execution terminal + output panel | `references/secondary-simstudioai-sim/apps/sim/app/workspace/.../w/[workflowId]/**` | High |
| CyberCore frontend documents admin page contracts + MCP inspector tabs | `.../cybernetics-core/apps/frontend/docs/ui-patterns.md`; `.../mcp-inspector/components/inspector.tsx` | High |
| OmniRoute (diegosouzapw) has provider health matrix, playground studio, traffic inspector | `.../omniroute/src/app/(dashboard)/dashboard/{health,playground,tools/traffic-inspector}/**` | High |
| Prior ADS gap analysis (2026-06-08) is partially stale (tables/logs/palette now present) | `docs/reports/ads-gap-analysis-20260608.md` vs current organisms barrel | High |
| Flutter DS references (villa/judatop/ahmedm/homecredit) are atomic tutorials, not ops organisms | analysis md under `references/secondary-*-analysis.md`; package trees | High |
| Pre-written analysis exists for judatop + ahmedm ADS samples | `secondary-judatop-atomic_design_system-analysis.md`; `secondary-ahmedm-gh-...-analysis.md` | High |

---

## Catalog Inventory

### Directory + analysis-md inventory

| Entry | Kind | UI relevance | Analysis md? |
| --- | --- | --- | --- |
| `main-diegosouzapw-omniroute/` | Full Next.js ops product | **Very high** | tree dump only (`*.md`) |
| `main-yuichiinumaru-omniroute/` | OmniRoute fork/worktree | High but **duplicate** of above | tree dump |
| `main-yuichiinumaru-cybernetics-core/` | Next admin + backend monorepo | **Very high** (frontend) | none dedicated ADS harvest |
| `secondary-open-webui-open-webui/` | SvelteKit chat platform | **Very high** | none |
| `secondary-thinkinaixyz-deepchat/` | Electron agent desktop | **Very high** | none |
| `secondary-simstudioai-sim/` | Workflow / agent workspace | **Very high** | none |
| `secondary-nexu-io-nexu/` | Desktop + web agent hub | Medium–high | none |
| `secondary-acdgbrasil-app-acdg-system/` | Flutter Melos monorepo + DS | Medium (product DS, domain social-care) | none ADS |
| `secondary-jorgemvv01-villa_design/` | Flutter atomic DS demo | Low–medium (meta) | tree dump |
| `secondary-judatop-atomic_design_system/` | Flutter atomic DS | Low–medium (meta) | **yes** analysis + reasoning |
| `secondary-ahmedm-gh-flutter-design-system-atomic-design/` | Flutter ADS guide/sample | Low–medium (meta) | **yes** analysis + reasoning |
| `secondary-oss-homecredit-id-flutter-direct/` | Flutter fintech atoms | Low | none |
| `secondary-yuichiinumaru-ivisa-tamagui/` | React Native/Tamagui UI monorepo | Low for Flutter ADS | none |
| `tertiary-theo45530-saas-ai/` | Tiny React dashboard toy | Low | none |
| `tertiary-theo45530-commerceai-pro/` | Commerce AI scaffold | Low | (not deep-dived) |
| `cc-visual-id/` | Small Vite visual brand toy | Brand tokens only | README only |
| `cc-reference-images/` | Image fixtures | Visual ref only | — |
| `londonappbrewery-clima-flutter/` | Tutorial weather app | **Skip** | — |
| Scripts: `run-analysis.sh`, `run-gitingest.sh`, `repo-analysis-questions.md` | tooling | N/A | — |

### One-line triage (non deep-dive / lower priority)

| Source | One-liner |
| --- | --- |
| `main-yuichiinumaru-omniroute` | Prefer **diegosouzapw** clone as UI source; treat this as noisy worktree (data/node_modules). |
| `secondary-jorgemvv01-villa_design` | Teaching ADS (atoms→pages); no operational organisms. |
| `secondary-judatop-atomic_design_system` | Lightweight Flutter kit; analysis already concludes no data viz / no glass. |
| `secondary-ahmedm-gh-flutter-design-system-atomic-design` | README-driven ADS structure; ThemeExtension pattern already stronger in WP. |
| `secondary-oss-homecredit-id-flutter-direct` | Brand atoms/buttons; mobile fintech, not Observatory. |
| `secondary-yuichiinumaru-ivisa-tamagui` | Cross-platform Tamagui forms; stack mismatch (RN/web, not Flutter). |
| `tertiary-theo45530-saas-ai` | ~7 JSX files agent cards; toy only. |
| `tertiary-theo45530-commerceai-pro` | Tertiary commerce scaffold; skip unless empty catalog. |
| `cc-visual-id` | Gemini Studio brand experiment; harvest **token mood** only if CyberCore visual id incomplete. |
| `cc-reference-images` | Screenshots/fixtures, not components. |
| `londonappbrewery-clima-flutter` | Tutorial; **IRON**. |
| Analysis tooling md | Useful for future automated harvests; not UI sources. |

### Existing analysis-md high-signal conclusions

| File | Conclusion (compressed) | ADS impact |
| --- | --- | --- |
| `secondary-judatop-atomic_design_system-analysis.md` | Pure UI kit; tokens+foundations; dark theme static; **no graphs/tables/loading organisms**; zero tests; not glass/obsidian | **IRON** for organisms; **BRONZE** for “keep ADS layers strict” reminder |
| `secondary-ahmedm-gh-flutter-design-system-atomic-design-analysis.md` | Strong **ThemeExtension** per component family; pages own state; templates (`Auth/Main/Dashboard`) as skeletons | **BRONZE** meta; WP already has richer gallery/shell |
| Prior `docs/reports/ads-gap-analysis-20260608.md` | Many MISSING items (table, palette, logs, toast, tabs, split) | **Stale** — those organisms now exist in barrel |
| Prior `docs/reports/flutter-reference-repo-sweep-20260608.md` | Agent transcript patterns (`ToolCallCard`, `StreamingMessageView`, `PlanProgress`) still relevant | **Aligns** with DeepChat/OpenWebUI harvests below |
| Prior `docs/reports/cybercore-domain-ui-mapping-20260608.md` | Needs health matrix, DAG editor, circuit breaker grid, execution waterfall | **Aligns** with OmniRoute + Sim Studio harvests |

---

## Deep Dives (8)

### 1. Open WebUI — `secondary-open-webui-open-webui/`

| Field | Detail |
| --- | --- |
| **Stack** | SvelteKit + Tailwind + Python FastAPI backend |
| **UI surface** | Chat organism cluster (`src/lib/components/chat/`), admin analytics/settings, workspace, channels, playground, terminal (`XTerminal.svelte`) |
| **Organism candidates** | **Message thread** with user/response roles; **StatusHistory** collapsible step trail; **Citations** modals; **Artifacts** multi-content preview; **ModelSelector**; **MessageInput** with command suggestion corpus (skills/prompts/knowledge); **FileNav** (code/JSON/SQLite views); **Chat Overview flow** graph of conversation |
| **WP fit** | CyberCore **agent harness / AiAnalyst expansion**; Observatory only if History/story needs richer message chrome |
| **Novelty vs EPIC-15** | EPIC-15 O-15 is a generic AI panel; Open WebUI is a full **typed transcript + artifact + status-step** IA. O-22 is terminal transcript, not multi-block chat. **Net-new**. |
| **Score** | **GOLD**: StatusHistory, ArtifactWorkbench, CitationList; **SILVER**: ModelSelector, FileNav; **IRON**: full product clone, voice call overlay, pyodide |

### 2. DeepChat — `secondary-thinkinaixyz-deepchat/`

| Field | Detail |
| --- | --- |
| **Stack** | Electron + Vue 3 + shadcn-vue + Pinia; rich e2e/vitest |
| **UI surface** | `renderer/src/components/message/*` block system; artifacts registry; chat input toolbar (MCP/skills); side panels (workspace/browser); onboarding spotlight |
| **Organism candidates** | **MessageBlockToolCall** pill → expandable details + subagent task rows; **MessageBlockThink / Plan / ActivityGroup**; **ArtifactBlock** type registry (code/md/html/svg/mermaid); **ChatSidePanel** workspace tree + viewer; **AgentProgressFloat**; **TraceDialog**; **GuidedOnboardingOverlay** |
| **WP fit** | Best **agent message ADS contract** for fixture-first CyberCore; complements O-15 without duplicating map HUD |
| **Novelty vs EPIC-15** | Typed **block union** for assistant turns is absent from WP + EPIC-15. Artifact panel is not O-27 media overlay. **Net-new**. |
| **Score** | **GOLD**: ToolCallCard, MessageBlockStream, ArtifactWorkbench; **SILVER**: SidePanelWorkspace, TraceDialog; **BRONZE**: onboarding spotlight |

### 3. Sim Studio — `secondary-simstudioai-sim/`

| Field | Detail |
| --- | --- |
| **Stack** | Bun monorepo, Next.js app `apps/sim`, React Flow-style workflow editor, Zustand, realtime sockets |
| **UI surface** | Workspace chrome; **workflow canvas** (`w/[workflowId]`) with blocks/edges/subflows; **terminal** (virtualized, execution groups, filters, resizable **output panel**); knowledge/files/logs/tables; mothership chat; global commands |
| **Organism candidates** | **WorkflowCanvasStage** (node registry, edge kinds, selection bus) — *contract sibling* of O-17 map stage, not a duplicate; **ExecutionTerminal** (grouped runs + structured output); **BlockPropertyEditor** side panel; **WandPromptBar**; **Logs dashboard** with detail resize; **SkillTile** grid |
| **WP fit** | CyberCore **RouteGraph / WorkflowDefinition** visualization (see domain mapping report); Observatory **workflow map mode** later |
| **Novelty vs EPIC-15** | EPIC-15 canvas is **geo/map stage**; Sim is **DAG workflow stage**. Terminal is **execution console**, richer than O-21 Infnet-style multi-module shell. **Net-new** if named distinctly. |
| **Score** | **GOLD**: WorkflowCanvasStage contract, ExecutionTerminal+Output; **SILVER**: property editor panel, logs split; **IRON**: full connector marketplace, billing, collab cursors |

### 4. Cybernetics Core frontend — `main-yuichiinumaru-cybernetics-core/apps/frontend/`

| Field | Detail |
| --- | --- |
| **Stack** | Next.js 15, Tailwind, Radix/shadcn, tRPC, TanStack Table/Query, i18n locales |
| **UI surface** | Sidebar admin routes (providers, MCP, namespaces, discovery, live-logs, costs, workflows…); `components/admin/*`; MCP inspector |
| **Organism candidates** | **AdminPageShell** (title/description/actions); **AdminDataState** (loading/empty/error contract); **AdminTableShell** + toolbar; **MetricGrid/MetricCard**; **ControlPlaneDomainTabs**; **MCP Inspector** capability-gated tabs (tools/resources/prompts/ping/roots/sampling); **ProviderStatusBadge** + connection form patterns |
| **WP fit** | **Direct CyberCore pilot** — this *is* the product lineage. ADS should absorb shell contracts already documented in `docs/ui-patterns.md`. |
| **Novelty vs EPIC-15** | Admin page pack and MCP inspector are **not** in O-01–O-28. Overlaps DSShell only at “chrome” level; WP still lacks capability-gated multi-pane inspector. **Net-new**. |
| **Score** | **GOLD**: AdminDataState, AdminPageShell, McpCapabilityInspector; **SILVER**: MetricGrid (partially covered by story/metric tiles), domain tabs |

### 5. OmniRoute (upstream-ish) — `main-diegosouzapw-omniroute/`

| Field | Detail |
| --- | --- |
| **Stack** | Next.js App Router, large dashboard under `src/app/(dashboard)/dashboard/`, shared components, Electron shell |
| **UI surface** | Provider registry, **health matrix**, combo control center, **playground studio**, **traffic inspector**, search tools, memory, batch wizards, analytics (route explainability, compression), agent skills marketplace, webhooks, CLI tool cards |
| **Organism candidates** | **ProviderHealthMatrix** (provider/account/model hierarchy + circuit breaker); **TrafficInspector** (request stream + detail tabs + TimingWaterfall + secret mask); **PlaygroundStudio** multi-column compare; **RouteExplainability** panel; **SkillCard + SkillPreviewPane**; **BatchWizard**; **RequestLogger** / ConsoleLogViewer; **SystemMonitor** |
| **WP fit** | Highest **CyberCore ops density** in the catalog. Maps cleanly to provider/routing/execution domains in `cybercore-domain-ui-mapping-20260608.md`. |
| **Novelty vs EPIC-15** | Health matrix, traffic waterfall, route explainability, multi-column playground are **absent**. Do not confuse with map floating analytics O-09. **Net-new**. |
| **Score** | **GOLD**: HealthMatrix, TrafficInspector+Waterfall, RouteExplainability; **SILVER**: PlaygroundStudio, SkillInspector; **BRONZE**: gamification/leaderboard; **IRON**: MITM product, OAuth provider modals as organisms |

### 6. Nexu — `secondary-nexu-io-nexu/`

| Field | Detail |
| --- | --- |
| **Stack** | pnpm monorepo: Electron desktop, React web, controller service |
| **UI surface** | Workspace layout; channels/skills/models/sessions; **ActivityFeed** (status + channel badge + relative time); skill import modal; multi-channel onboarding wizards; budget banners |
| **Organism candidates** | **SessionActivityFeed** (compact recent activity); **SkillCatalogCard** + import modal; **ChannelStatusStrip**; **BudgetWarningBanner** (ops alert chrome) |
| **WP fit** | Medium — good **session/activity** chrome for CyberCore home; channel wizards are product-specific |
| **Novelty vs EPIC-15** | Activity feed is lighter than O-07 ticker and different from DSTimeline. Skill catalog differs from O-08 OSINT workbench. **Partial net-new**. |
| **Score** | **SILVER**: ActivityFeed, SkillCatalogCard; **BRONZE**: budget banner; **IRON**: WeChat/Feishu setup wizards as first-class ADS |

### 7. ACDG System — `secondary-acdgbrasil-app-acdg-system/`

| Field | Detail |
| --- | --- |
| **Stack** | Flutter Melos monorepo; `packages/design_system`; feature packages (`social_care`, `people_admin`); handbook-heavy |
| **UI surface** | DS atoms/molecules + domain organisms (member card/list/table row); social-care dense forms |
| **Organism candidates** | **Member/registry table row** patterns; **ActionRow**; form field molecules; **breakpoint/grid tokens** (`app_breakpoints`, `app_grid`) |
| **WP fit** | Process/handbook (agent review rituals, Melos) more valuable than widgets. Visual language is social-care, not obsidian glass. |
| **Novelty vs EPIC-15** | Low organism novelty vs existing DSDataTable/DSShell. **Handbook process** is SILVER for harness, not ADS organisms. |
| **Score** | **BRONZE** organisms; **SILVER** for Melos/handbook governance patterns (out of ADS organism scope) |

### 8. Flutter atomic DS cluster (villa + judatop + ahmedm)

| Field | Detail |
| --- | --- |
| **Stack** | Pure Flutter packages / README guides |
| **UI surface** | Buttons, fields, cards, login form, screen templates |
| **Organism candidates** | Essentially **none** at Observatory/CyberCore ops level |
| **WP fit** | Meta-validation of atomic layering only; WP already beyond this maturity |
| **Novelty vs EPIC-15** | None |
| **Score** | **IRON** for organism harvest; keep analysis files as negative evidence |

---

## Harvested Items (organism-level, net-new)

| Score | Item | Local Destination | Effort | Risk |
| --- | --- | --- | --- | --- |
| **GOLD** | `PrismAgentTranscript` — role-aware virtualized message list + block slots | `warp_prism_ui` organisms + CyberCore harness fixtures | L | Medium (scope → full chat product) |
| **GOLD** | `PrismToolCallCard` — pill + expandable args/result + status ring | molecule/organism under transcript; reuse `DSCodeBlock` | M | Low |
| **GOLD** | `PrismMessageStatusHistory` — collapsible step trail for agent runs | compose with `DSTimeline` or standalone | S–M | Low |
| **GOLD** | `PrismArtifactWorkbench` — type registry preview panel (md/code/mermaid/html) | organisms; compose markdown/code | L | Medium (iframe/html sandbox) |
| **GOLD** | `PrismProviderHealthMatrix` — hierarchical health grid | CyberCore providers/health screens | L | Medium (data model coupling) |
| **GOLD** | `PrismTrafficInspector` — request stream + detail tabs + secret mask | CyberCore logs/ops; compose `DSLogViewer`/`DSSplitPane` | XL | High (domain complexity) |
| **GOLD** | `PrismTimingWaterfall` — span/timing bars for execution envelope | CyberCore execution detail | M | Low |
| **GOLD** | `PrismMcpCapabilityInspector` — capability-gated tab workbench | CyberCore MCP detail | M | Low |
| **GOLD** | `PrismWorkflowCanvasStage` — DAG contract (nodes/edges/selection), not engine port | ADS contract + gallery; later RouteGraph | L | Medium (vs existing graph) |
| **GOLD** | `PrismExecutionConsole` — grouped runs + filters + structured output panel | CyberCore / compose log viewer | L | Medium (overlap O-21 naming) |
| **SILVER** | `PrismAdminPageShell` + `PrismAdminDataState` pack | CyberCore page templates | S | Low |
| **SILVER** | `PrismRouteExplainabilityPanel` — decision rationale list | CyberCore routing analytics | M | Low |
| **SILVER** | `PrismPlaygroundCompare` — multi-column model compare | CyberCore harness/playground | L | Medium |
| **SILVER** | `PrismSkillCatalogCard` + inspector pane | CyberCore skills registry | M | Low |
| **SILVER** | `PrismSessionActivityFeed` — compact recent sessions/events | CyberCore home | S | Low (overlap timeline) |
| **SILVER** | `PrismModelChooser` — searchable model/provider picker | shared ops molecule/organism | M | Low |
| **BRONZE** | DeepChat guided onboarding spotlight | catalog/gallery demos | S | Low |
| **BRONZE** | OmniRoute batch wizard multi-step | later batch domain | M | Medium |
| **IRON** | MapLibre / full chat product / MITM proxy UI / channel OAuth wizards / gamification | — | — | Product boundary |

### Explicit non-duplicates (already EPIC-15 or existing WP)

Do **not** re-task as new harvests:

- Map HUD workspace, tool strip, layer panel, entity intel, locate, time machine, status ticker, OSINT workbench (EPIC-15 O-01–O-08)
- Floating analytics HUD, watchlist, coord bar, legend, filter workbench, view presets, share card, connector panel chrome (O-09–O-20)
- Terminal workspace / agent shell **as defined from ShadowBroker** (O-21–O-22) — **rename** new console work as `PrismExecutionConsole` to avoid collision
- `DSShell`, `DSSidebar`, `DSTopbar`, `DSDetailInspector`, `DSGraphCanvas`, `DSTimeline`, `DSLaneBoard`, `DSLogViewer`, `DSCommandPalette`, `DSDataTable`, `DSTabBar`, `DSSplitPane`, `DSVirtualScroll`, `DSStatusGrid`, toast/error boundary

---

## What Was Not Found

| Search | Result |
| --- | --- |
| Dedicated ADS harvest reports for open-webui / deepchat / sim / omniroute / nexu under `references/` | **Not found** (only Flutter tutorial analyses) |
| Flutter-native agent chat or workflow canvas in `references/` | **Not found** (all high-value UIs are web/Electron) |
| Map HUD patterns beyond what Hyperion SB/Osiris already harvested | **Not found** in this catalog (correctly out of scope) |
| Production-ready glass/obsidian design tokens in Flutter DS samples | **Not found** (judatop/villa/ahmedm are flat Material) |
| Clean “organism only” packages without product backends | **Not found** for ops UI — must extract contracts from monorepos |
| Unique yuichiinumaru-omniroute UI vs diegosouzapw | **Not treated as separate source** (prefer diegosouzapw tree) |

---

## Recommended Next Tasks

### Follow-on epic proposal: **EPIC-16 (candidate)** — *CyberCore Ops + Agent Transcript Organisms*

Working title: **Warp Prism ADS — Agent Runtime & Control-Plane Organisms** (sources: Open WebUI, DeepChat, OmniRoute, Sim Studio, CyberCore frontend).

Suggested waves (do not start until EPIC-15 acceptance path is clear):

| Wave | Theme | Organisms |
| --- | --- | --- |
| **J** | Agent transcript foundation | `PrismAgentTranscript`, `PrismToolCallCard`, `PrismMessageStatusHistory` |
| **K** | Artifacts + model chrome | `PrismArtifactWorkbench`, `PrismModelChooser` |
| **L** | Admin page contracts | `PrismAdminPageShell`, `PrismAdminDataState`, `PrismMetricGrid` (if not already sufficient) |
| **M** | MCP + skill ops | `PrismMcpCapabilityInspector`, `PrismSkillCatalogCard` |
| **N** | Health + explainability | `PrismProviderHealthMatrix`, `PrismRouteExplainabilityPanel` |
| **O** | Traffic / execution | `PrismTrafficInspector` (or MVP: stream list + detail), `PrismTimingWaterfall`, `PrismExecutionConsole` |
| **P** | Workflow DAG contract | `PrismWorkflowCanvasStage` (contract + gallery; no React Flow port) |

### Immediate analyst/task-architect actions

1. **Freeze skip list**: no full chat app, no MITM, no MapLibre, no EPIC-15 renames.  
2. **Write one deep harvest report** per GOLD cluster (DeepChat+OpenWebUI combined; OmniRoute ops; Sim workflow/terminal) before task decomposition.  
3. **Align naming** with CyberCore domain mapping (`PrismCircuitBreakerGrid` may fold into HealthMatrix).  
4. **Defer** ACDG/villa/judatop/ahmedm to harness meta notes only.  
5. Optionally **promote** 2–3 GOLD items as **EPIC-15 Wave extension** only if product needs agent transcript before a full EPIC-16 (prefer separate epic to protect Map HUD delivery).

---

## Unified Priority Shortlist (Top 10)

Net-new ideas that could **extend EPIC-15 lightly** or **spawn EPIC-16**:

| # | Idea | Best source | Why now | Score |
| --: | --- | --- | --- | --- |
| 1 | **`PrismAgentTranscript` + typed block slots** | DeepChat + Open WebUI | Unlocks fixture-first CyberCore agent UX; EPIC-15 O-15 is too thin | GOLD |
| 2 | **`PrismToolCallCard`** | DeepChat `MessageBlockToolCall` | Small, high polish, composes into #1 and OSINT/AI panels | GOLD |
| 3 | **`PrismMessageStatusHistory`** | Open WebUI `StatusHistory` | Agent/run progress without inventing a second timeline system | GOLD |
| 4 | **`PrismArtifactWorkbench`** | DeepChat artifacts + OWUI Artifacts | Side panel registry for md/code/mermaid; distinct from O-27 media overlay | GOLD |
| 5 | **`PrismProviderHealthMatrix`** | OmniRoute `ProviderHealthMatrixCard` | Core CyberCore provider/ops surface; domain mapping already demands it | GOLD |
| 6 | **`PrismMcpCapabilityInspector`** | CyberCore `inspector.tsx` | Capability-gated tabs for tools/resources/prompts — native to product lineage | GOLD |
| 7 | **`PrismTimingWaterfall` + execution envelope detail** | OmniRoute traffic-inspector `TimingWaterfall` | Makes logs/execution *readable* beyond `DSLogViewer` rows | GOLD |
| 8 | **`PrismExecutionConsole`** (grouped runs + output panel) | Sim Studio terminal | Ops console class distinct from O-21; pairs with workflow runs | GOLD |
| 9 | **`PrismWorkflowCanvasStage` contract** | Sim Studio workflow canvas | RouteGraph/Workflow DAG for CyberCore; sibling to O-17 map stage, not a clone | GOLD |
| 10 | **`PrismTrafficInspector` MVP** (stream + detail tabs) | OmniRoute traffic-inspector | Highest ops leverage; start MVP then expand (XL full port is risk) | GOLD→SILVER if MVP-scoped |

**Honorable mentions (11–14)**: `PrismAdminPageShell`/`AdminDataState`, `PrismRouteExplainabilityPanel`, `PrismPlaygroundCompare`, `PrismSessionActivityFeed`.

---

## Scoring Rubric (recap)

| Score | Meaning |
| --- | --- |
| **GOLD** | High impact, clear WP destination, low–medium integration risk if scoped |
| **SILVER** | Valuable; needs design/compat work or partial overlap |
| **BRONZE** | Interesting; document for later |
| **IRON** | Unsuitable; domain/product/stack mismatch |

---

*Catalog scan complete. Sources under `references/` were not modified. EPIC-15 Map HUD organisms intentionally excluded from recommendations.*
