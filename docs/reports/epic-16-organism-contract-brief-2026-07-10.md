# EPIC-16 Organism Inventory + Catalog Showability Brief

> **Status**: Locked inventory for builders (Task 1600)  
> **Date**: 2026-07-10  
> **Epic**: `docs/tasks/00-planning/EPIC-16-warp-prism-ads-cybercore-ops-and-agent-transcript-organisms.md`  
> **Authority**: Freezes C-ID → Task 16NN → `Prism*` → wave; skip list; gallery/catalog showability; fixture-first CyberCore rules  
> **Scope**: Governance only — no widget implementation in Task 1600  
> **Non-overlap**: EPIC-15 (1500–1523) owns Map HUD / OSINT / stage chrome — **do not re-implement here**

---

## 1. Purpose

This brief is the **anti-drift lock** for Tasks 1601–1616. Builders implement against this map without re-litigating harvest scope, EPIC-15 overlap, Observatory teal rebrand, or engine ports (MapLibre / Recharts / Widgetbook).

| Audience | Use |
| --- | --- |
| Organism builders (1602–1611) | Public name, wave, false-gap, fixture rules |
| Visibility (1601) | Catalog showability expectations |
| Hygiene (1612) | Package purity checklist scope (not widget ports) |
| Cross-cut (1613–1615) | Gallery section IDs, golden families, acceptance gates |
| Optional (1616) | CyberCore-only teal skin — never Observatory default |

---

## 2. Sources (read-only inputs)

| Path | Role |
| --- | --- |
| `docs/tasks/00-planning/EPIC-16-warp-prism-ads-cybercore-ops-and-agent-transcript-organisms.md` | Canonical epic |
| `docs/reports/ads-harvest-session-synthesis-2026-07-10.md` | Session synthesis |
| `docs/reports/ads-harvest-omniroute-visual-reference-2026-07-10.md` | OmniRoute visual-ref (PageShell, Tree, ops) |
| `docs/reports/ads-harvest-references-catalog-triage-2026-07-10.md` | DeepChat / Open WebUI / Sim Studio / CyberCore triage |
| `docs/reports/ads-harvest-atomic-ds-references-2026-07-10.md` | judatop / ahmedm / villa hygiene (not widgets) |
| `docs/reports/epic-16-task-architect-review-2026-07-10.md` | Architect ACCEPT + visibility answer |
| `packages/warp_prism_ui/lib/src/organisms/organisms.dart` | Live organism barrel (pre-EPIC-16) |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Public `Prism*` typedef pattern |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_registry.dart` | Gallery section registry |
| `apps/catalog/lib/main.dart` | Thin catalog host |
| `README.md` | Catalog run command (protected) |
| `docs/design/token-theme-catalog-policy.md` | Naming + catalog policy (no Widgetbook) |

---

## 3. Baseline — already-covered organisms (do not re-task under EPIC-16)

These exist in `organisms.dart` / public aliases. EPIC-16 may **compose** them; it must **not** rename or re-implement them as new C-IDs.

| Internal | Public alias (if any) | Notes |
| --- | --- | --- |
| `DSShell` | `PrismShell` / `PrismShellResponsive` | App chrome — **≠** `PrismPageShell` (C-01) |
| `DSSidebar` | `PrismSidebar` | App nav |
| `DSTopbar` | `PrismTopbar` | App top chrome |
| `DSDetailInspector` | `PrismDetailInspector` | Selection inspector pattern |
| `DSGraphCanvas` + `graph/` | `PrismGraphCanvas` | Graph primitives — compose for C-11 MVP only |
| `DSTimeline` | `PrismTimeline` | Event list — not Map time-machine (EPIC-15 O-06) |
| `DSLaneBoard` | `PrismLaneBoard` | Task board |
| `DSLogViewer` | `PrismLogViewer` | Log stream — **≠** `PrismExecutionConsole` (C-12) |
| `DSCommandPalette` | `PrismCommandPalette` | Global command — **≠** entity locate (EPIC-15 O-05) |
| `DSDataTable` | `PrismDataTable` | Tables |
| `DSTabBar` / `DSTabView` | `PrismTabBar` / `PrismTabView` | Tabs |
| `DSSplitPane` | `PrismSplitPane` | Split layouts |
| `DSVirtualList` / grid | `PrismVirtualList` / `PrismVirtualGrid` | Virtualization |
| `DSStatusGrid` | `PrismStatusGrid` | Status cells — **≠** provider health matrix (C-07) |
| `DSErrorBoundary` / `DSFallbackView` | `PrismErrorBoundary` / `PrismFallbackView` | Error/empty |
| `DSCodeBlock` / `DSMarkdownRenderer` | `PrismCodeBlock` / `PrismMarkdownRenderer` | Content blocks for transcript/artifacts |
| `DSStoryPanel` | `PrismStoryPanel` | Narrative panel |
| Toast / health molecules | `PrismToast*`, `PrismHealthCard`, … | Compose into ops demos; not new C-IDs |

**EPIC-15 reserved names (O-01–O-22 / Tasks 1501–1523)** — **do not re-implement under EPIC-16 C-IDs**:

`PrismMapHudWorkspace`, `PrismToolStripSlideout`, `PrismLayerControlPanel`, `PrismFilterWorkbench`, `PrismEntityIntelPanel`, `PrismEntityLocateSearch`, `PrismTimeMachineScrubber`, `PrismStatusTicker`, `PrismStageChrome*` pack, `PrismOsintWorkbench`, `PrismAiAnalystPanel`, `PrismMapCanvasStage`, `PrismEntityRelationCard`, `PrismFloatingAnalyticsHud`, `PrismOpsControlCluster`, `PrismViewPresets` / share card, `PrismTerminalWorkspace`, `PrismAgentShellPanel`, plus EPIC-15 gallery/goldens/acceptance tasks.

---

## 4. Skip list (hard gate — do not re-open)

Builders **MUST NOT**:

| Skip | Rationale |
| --- | --- |
| OmniRoute / CyberCore **teal rebrand of Observatory** | Keep WP cyan `#00D4FF` Observatory default; teal skin only optional Task 1616 |
| Orbitron / Rajdhani / scanlines as Observatory default | Visual-ref chrome only; not product default type stack |
| **MapLibre** port | Map engines out of ADS organism scope; EPIC-15 owns map stage contract |
| **Recharts** / CSS fake-graph ports | Use pure Flutter layout/`CustomPaint` for timing bars |
| **Widgetbook** | Deferred by `token-theme-catalog-policy.md`; custom `apps/catalog` is Storybook-class MVP |
| Mesh crypto UIs | Not ADS harvest scope |
| Live API keys / live network gallery demos | Fixture-first only |
| Mutation **ALLOW/BLOCK** product panels | Read-only Observatory / mock ops semantics |
| EPIC-15 **O-01–O-22** duplicates under new names | Separate epic; composition ok, fork forbidden |
| Login / product admin pages from villa / judatop / villa_design | Pattern hygiene only (Task 1612) |
| Fibonacci spacing systems, bottom-sheet dropdown ports | Educational kits — not product organisms |
| Product route rewrites (Observatory/CyberCore app screens) as organism exit | **ADS-first**: organism + gallery case is enough for task exit |
| Full Sim Studio editor / React Flow / collab cursors | C-11 is stage **contract** + fixture graph MVP |
| PTY / xterm.js / real workflow execution in UI package | C-12 is fixture stream console |

---

## 5. Architect resolutions (frozen)

| Topic | Resolution |
| --- | --- |
| **Naming** | Public `Prism*`; internal `DS*` + `typedef` in `prism_aliases.dart` (ADS pattern). Consumers import only `package:warp_prism_ui/warp_prism_ui.dart`. |
| **Gallery strategy** | Each organism task registers a **minimal** gallery case. Task **1613** audits cross-section completeness. |
| **Product routes** | ADS-first. CyberCore/Observatory product route integration is **out of scope** for organism exit. |
| **Fixture-first** | All CyberCore-facing organisms (health, MCP, traffic, timing, transcript, artifacts, execution) use **local fixtures only** — no live backend, no secrets. |
| **Optional 1616** | CyberCore teal `ThemeExtension` skin — **not** Observatory default; may remain deferred; does **not** block 1613–1615. |
| **Hygiene 1612** | Governance/docs/checklist + optional small test helpers — **not** a judatop/ahmedm/villa widget port. |
| **Read-only product** | Preserve mock-observatory semantics; no mutation control surfaces. |

---

## 6. C-ID → Task → Prism* → wave mapping (complete)

### 6.1 Idea catalog (C-01–C-13)

| C-ID | Public `Prism*` | Internal `DS*` | Task | Wave | Priority | Origin harvest | Notes |
| --- | --- | --- | --- | ---: | --- | --- | --- |
| **C-01** | `PrismPageShell` | `DSPageShell` | **1602** | J | P1 | OmniRoute visual-ref page chrome | Content page header; **≠** `DSShell` |
| **C-02** | `PrismTree` | `DSTree` | **1603** | J | P1 | OmniRoute tree | Hierarchy + status/meta/selection |
| **C-03** | `PrismAgentTranscript` | `DSAgentTranscript` | **1604** | K | P1 | DeepChat / Open WebUI | Chat multi-role transcript; **≠** EPIC-15 `PrismAgentShellPanel` (1518) |
| **C-04** | `PrismToolCallCard` | `DSToolCallCard` | **1605** | K | P1 | DeepChat tool blocks | Pack with C-05 |
| **C-05** | `PrismMessageStatusHistory` | `DSMessageStatusHistory` | **1605** | K | P1 | Open WebUI status pipeline | Pack with C-04 |
| **C-06** | `PrismArtifactWorkbench` | `DSArtifactWorkbench` | **1606** | K | P1 | DeepChat artifacts | Side panel / multi-type preview registry |
| **C-07** | `PrismProviderHealthMatrix` | `DSProviderHealthMatrix` | **1607** | L | P1 | OmniRoute / CyberCore FE | Provider→account→model health grid; **≠** `DSStatusGrid` alone |
| **C-08** | `PrismMcpCapabilityInspector` | `DSMcpCapabilityInspector` | **1608** | L | P1 | CyberCore MCP inspect | Capability/tool list inspector; fixtures |
| **C-09** | `PrismTimingWaterfall` | `DSTimingWaterfall` | **1609** | L | P1 | OmniRoute timing views | Fixture span bars; **no Recharts** |
| **C-10** | `PrismTrafficInspector` | `DSTrafficInspector` | **1609** | L | P1 | OmniRoute traffic inspector | List + detail MVP pack with C-09 |
| **C-11** | `PrismWorkflowCanvasStage` | `DSWorkflowCanvasStage` | **1610** | M | P1 | Sim Studio workflow | Stage **contract** + fixture DAG; **≠** Map stage O-17 / 1512 |
| **C-12** | `PrismExecutionConsole` | `DSExecutionConsole` | **1611** | M | P1 | Sim Studio terminal | Run groups + output slot; **≠** TerminalWorkspace 1517 |
| **C-13** | *(no widget)* | n/a | **1612** | N | P1 | judatop / ahmedm | Package purity + interactive state matrix **hygiene** |

### 6.2 Cross-cutting + visibility tasks (no C-ID)

| Task | Name | Wave | Priority | Role |
| ---: | --- | --- | --- | --- |
| **1600** | Inventory + catalog showability brief | V | P0 | **This document** |
| **1601** | Catalog/gallery showability verify + polish | V | P0 | Smoke + optional TOC / demo one-pager |
| **1613** | EPIC-16 gallery/catalog registration | X | P1 | Hard: 1602–1609 delivered; soft: 1610–1612 |
| **1614** | EPIC-16 goldens + boundary alias audit | X | P1 | Hard: 1613; ≥3 golden families |
| **1615** | EPIC-16 acceptance audit | X | P0 | Hard: 1614 |
| **1616** | Optional CyberCore teal ThemeExtension skin | optional | P3 | **Deferred OK**; not Observatory default |

### 6.3 Pack tasks (one task, multiple C-IDs)

| Task | C-IDs | Deliverables |
| ---: | --- | --- |
| 1605 | C-04, C-05 | `PrismToolCallCard` + `PrismMessageStatusHistory` |
| 1609 | C-09, C-10 | `PrismTimingWaterfall` + `PrismTrafficInspector` MVP pack |

### 6.4 Task file inventory (numbering integrity)

| Task | Lane (as of brief lock) | File present |
| ---: | --- | --- |
| 1600 | `02-doing/` | yes |
| 1601 | `02-doing/` | yes |
| 1602–1616 | `01-open/` (except 1600/1601) | **1602–1616 all present** |

**Numbering gaps**: none in 1600–1616.  
**Regression note**: Task 1601 lives under `02-doing/` (parallel with 1600); open-set organism/audit tasks remain `01-open/1602`–`1616`.

---

## 7. Wave dependency graph

```text
Wave V  1600 (brief) ──soft──► 1601 (showability)
          │
          ├── hard soft-lock for 1602–1612 builders (prefer brief before code)
          │
Wave J  1602 PageShell  ∥  1603 Tree          (parallel; depend 1600 only)
          │
Wave K  1604 AgentTranscript
          │    soft ↓
          ├── 1605 ToolCall + StatusHistory   (soft on 1604; standalone gallery OK)
          └── 1606 ArtifactWorkbench          (soft on 1604 + 1601)
          │
Wave L  1607 HealthMatrix ∥ 1608 MCP Inspector ∥ 1609 Timing+Traffic
          │    (soft 1601; 1608 soft 1602/1603 for richer demos)
          │
Wave M  1610 WorkflowCanvasStage ∥ 1611 ExecutionConsole
          │
Wave N  1612 Package purity / state-matrix hygiene
          │
Wave X  1613 Gallery registration  ──hard──►  1614 Goldens+alias  ──hard──►  1615 Acceptance
          │         hard: 1602–1609
          │         soft: 1610–1612 if landed; else deferred matrix rows
          │
Optional 1616 Teal skin  (non-blocking for X)
```

### Soft vs hard edges (executor rules)

| Edge | Kind | Rule |
| --- | --- | --- |
| 1602, 1603 → 1600 | Soft | Brief preferred; may start if epic + this brief exist |
| 1604–1611 → 1600 | Soft | Same |
| 1605 → 1604 | Soft | Prefer composition gallery; standalone cases allowed |
| 1606 → 1604 / 1601 | Soft | Composition demos preferred |
| 1607–1609 → 1601 | Soft | Gallery polish enabler |
| 1608 → 1602 / 1603 | Soft | Richer demos only |
| 1613 → 1602–1609 | **Hard** | Core J+K+L must deliver before registration closeout |
| 1613 → 1610–1612 | Soft | Progressive matrix: `delivered` or `deferred` |
| 1614 → 1613 | **Hard** | |
| 1615 → 1614 | **Hard** | |
| 1616 | Optional | Never blocks 1613–1615 |

**Parallel start recommendation**: After 1600, run **1601 ∥ 1602 ∥ 1603**, then fan out K/L, then M, then X.

---

## 8. False-gap notes (EPIC-15 non-overlap — do not re-implement)

| EPIC-16 | Looks like | EPIC-15 / baseline owner | Distinction |
| --- | --- | --- | --- |
| C-01 `PrismPageShell` | App shell | `DSShell` / `PrismShell` | **In-content** page header (icon+title+subtitle+actions+toolbar), not app frame |
| C-03 `PrismAgentTranscript` | Agent panel | O-22 `PrismAgentShellPanel` (1518) | **Chat multi-role** typed blocks (user/assistant/tool); not terminal/session shell transcript |
| C-11 `PrismWorkflowCanvasStage` | Map stage | O-17 `PrismMapCanvasStage` (1512) | **Workflow DAG** node/edge contract; no geo, no MapLibre |
| C-12 `PrismExecutionConsole` | Terminal | O-21 `PrismTerminalWorkspace` (1517) | **Run-grouped execution log + output panel**; not multi-module terminal workspace |
| C-07 health matrix | Status grid | `DSStatusGrid` | Provider/account/model **ops matrix** semantics + fixtures |
| C-09 waterfall | Charts | n/a | Pure Flutter bars; no Recharts |
| C-13 hygiene | Component sprint | n/a | Docs/checklist only |

**Language for builders**: If a harvest screenshot looks like Map HUD / OSINT / stage chrome, stop — that is **EPIC-15**. Implement the C-ID in this brief only.

---

## 9. Public API contract checklist

Every organism task (1602–1611) and registration/audit task MUST satisfy:

| Gate | Expectation |
| --- | --- |
| Implementation path | `packages/warp_prism_ui/lib/src/organisms/<snake_name>/` (or coherent subfolder) |
| Internal class | `DS*` implementation |
| Barrel | Export from `packages/warp_prism_ui/lib/src/organisms/organisms.dart` |
| Public alias | `typedef PrismX = DSX;` in `prism_aliases.dart` (+ related model types) |
| Package barrel | Reachable via `package:warp_prism_ui/warp_prism_ui.dart` only for consumers |
| Gallery | Minimal case registered (organism task) → completeness audited in **1613** |
| Gallery section IDs | Use scheme in §10; unique across `dsGallerySections` |
| Unit/widget tests | `packages/warp_prism_ui/test/organisms/...` (or colocated family folder) |
| Goldens | Family baselines under `packages/warp_prism_ui/test/goldens/` in **1614** (min 3 families) |
| Boundaries | After barrel/alias changes: `melos run test-boundaries` → **6/6 PASS** |
| Changelog | Local note under `docs/changelog/` per task |
| No `src/` leaks | Catalog/apps must not import `package:warp_prism_ui/src/...` for new work |
| Fixtures | Local mock data in package tests/gallery; no live keys |

**Composition-not-fork**: Prefer composing existing atoms/molecules/organisms (`PrismCodeBlock`, `PrismSplitPane`, `PrismTabBar`, graph module) over forking new engines.

---

## 10. Gallery section ID scheme + registration expectations

### 10.1 Current registry (baseline — do not break)

Existing `dsGallerySections` IDs:  
`tokens`, `atoms`, `molecules`, `operational-states`, `organisms`, `virtual-scroll`, `health-dashboard`, `toasts`, `accessibility-focus`, `templates`.

### 10.2 EPIC-16 recommended section IDs

Prefer **family sections** (low nav explosion). Organism tasks may temporarily place a minimal case under the existing `organisms` section; **1613** normalizes to family sections if needed.

| Section ID | Title (suggested) | Organisms |
| --- | --- | --- |
| `epic16-content-chrome` | Content Chrome | `PrismPageShell`, `PrismTree` |
| `epic16-agent-transcript` | Agent Transcript | `PrismAgentTranscript`, `PrismToolCallCard`, `PrismMessageStatusHistory`, `PrismArtifactWorkbench` |
| `epic16-cybercore-ops` | CyberCore Ops | `PrismProviderHealthMatrix`, `PrismMcpCapabilityInspector`, `PrismTimingWaterfall`, `PrismTrafficInspector` |
| `epic16-workflow-execution` | Workflow & Execution | `PrismWorkflowCanvasStage`, `PrismExecutionConsole` |

**Rules**:

- IDs are stable kebab-case; unique across registry.
- Each organism task: **≥1** fixture-backed demo case.
- 1613: registration matrix (organism → section id → builder) in Completion Evidence or short `docs/reports/` note.
- Do **not** re-register EPIC-15 Map HUD organisms as EPIC-16 sections.
- No Widgetbook.

### 10.3 Golden families (Task 1614)

Minimum **3** default-state goldens (default WP theme — **not** teal skin):

| Family | Representative public widget | Suggested golden stem |
| --- | --- | --- |
| Content chrome | `PrismPageShell` (or Tree) | `prism_page_shell_golden_test.dart` |
| Agent transcript | `PrismAgentTranscript` | `prism_agent_transcript_golden_test.dart` |
| CyberCore ops | `PrismProviderHealthMatrix` (or Timing/Traffic pack) | `prism_provider_health_matrix_golden_test.dart` |

Path: `packages/warp_prism_ui/test/goldens/`. Wave M goldens optional same-pass if 1610/1611 landed; else follow-up. Optional 1616 skin goldens **out of scope** for 1614.

---

## 11. Catalog showability expectations (Task 1601)

### 11.1 Frozen show path

| Step | Detail |
| --- | --- |
| Host app | `apps/catalog/` — thin `MaterialApp` → `DesignSystemGalleryPage` |
| Command | `cd apps/catalog && flutter run` (desktop/web target as available) |
| README | Already documents catalog run (Setup step 4); **protected** — small additive polish only if needed |
| Alternate | Observatory route `/design-system` (demo script); not required for 1601 hard gate |
| Policy | **No Widgetbook** |

### 11.2 Task 1601 hard vs optional

| Gate | Kind |
| --- | --- |
| Catalog `dart analyze` clean (or pre-existing residuals listed) | **Hard** |
| Existing gallery tests under `packages/warp_prism_ui/test/gallery/` still pass (or pre-existing documented) | **Hard** |
| README catalog command still accurate | **Hard** |
| Section TOC / jump aids in gallery | Optional stretch |
| Demo one-pager under `docs/demo/` or `docs/reports/` | Optional if README + this brief + policy already quote the show path |

**Explicit non-goals for 1601**: organism registration completeness (**1613**); teal rebrand; Widgetbook; blocking organism waves on perfect TOC.

### 11.3 60-second demo script (expectation for handoff)

1. From repo root: `cd apps/catalog && flutter run`.  
2. Open gallery; scroll/jump to **Organisms** or EPIC-16 family sections as registered.  
3. Point stakeholders at fixture demos (no live keys).  
4. Optional: Observatory `/design-system` for in-product gallery route.

---

## 12. Fixture-first CyberCore rules

| Rule | Detail |
| --- | --- |
| Data | Static fixtures / in-memory controllers only |
| Network | Forbidden in organism package demos and goldens |
| Secrets | No API keys, tokens, or live credentials |
| Mutation | No ALLOW/BLOCK / write controls presented as product actions |
| Streaming | Simulate with list append / controllers (C-12, traffic, transcript) |
| MCP / providers | Fixture capability lists and health cells only |

---

## 13. Binary acceptance (epic + Task 1615 preview)

Epic is acceptable when:

- [ ] Catalog/gallery demos with documented README command (1601 evidence).  
- [ ] C-01–C-12 delivered **or** explicitly deferred with reason in 1615.  
- [ ] Skip list honored (no teal Observatory default, no MapLibre/Recharts/Widgetbook).  
- [ ] Public `Prism*` aliases + boundaries **6/6**.  
- [ ] Fixture-first for all CyberCore-facing organisms.  
- [ ] Gallery registration (1613) + goldens (1614) present for delivered core.  
- [ ] No unauthorized product route rewrites as organism exit criteria.

---

## 14. Suggested implementation path map (file conventions)

| Family | Suggested lib path under `organisms/` | Test path |
| --- | --- | --- |
| Page shell | `page_shell/ds_page_shell.dart` | `test/organisms/page_shell/` |
| Tree | `tree/ds_tree.dart` | `test/organisms/tree/` |
| Agent transcript | `agent_transcript/…` | `test/organisms/agent_transcript/` |
| Tool call / status | `agent_transcript/` or sibling folders | same family tests |
| Artifact workbench | `artifact_workbench/…` | `test/organisms/artifact_workbench/` |
| Provider health | `provider_health_matrix/…` | `test/organisms/provider_health_matrix/` |
| MCP inspector | `mcp_capability_inspector/…` | `test/organisms/mcp_capability_inspector/` |
| Timing + traffic | `timing_waterfall/…`, `traffic_inspector/…` | matching `test/organisms/` |
| Workflow stage | `workflow_canvas_stage/…` | `test/organisms/workflow_canvas_stage/` |
| Execution console | `execution_console/…` | `test/organisms/execution_console/` |

Builders may adjust folder names if coherent with existing style; public names in §6 are **frozen**.

---

## 15. Open-task reference index (1601–1616)

| Task | File |
| ---: | --- |
| 1601 | `docs/tasks/02-doing/1601-warp-prism-catalog-gallery-showability-verify-polish.md` |
| 1602 | `docs/tasks/01-open/1602-warp-prism-page-shell-organism.md` |
| 1603 | `docs/tasks/01-open/1603-warp-prism-tree-organism.md` |
| 1604 | `docs/tasks/01-open/1604-warp-prism-agent-transcript-organism.md` |
| 1605 | `docs/tasks/01-open/1605-warp-prism-tool-call-card-message-status-history.md` |
| 1606 | `docs/tasks/01-open/1606-warp-prism-artifact-workbench-organism.md` |
| 1607 | `docs/tasks/01-open/1607-warp-prism-provider-health-matrix-organism.md` |
| 1608 | `docs/tasks/01-open/1608-warp-prism-mcp-capability-inspector-organism.md` |
| 1609 | `docs/tasks/01-open/1609-warp-prism-timing-waterfall-traffic-inspector-pack.md` |
| 1610 | `docs/tasks/01-open/1610-warp-prism-workflow-canvas-stage-contract.md` |
| 1611 | `docs/tasks/01-open/1611-warp-prism-execution-console-organism.md` |
| 1612 | `docs/tasks/01-open/1612-warp-prism-package-purity-interactive-state-matrix-hygiene.md` |
| 1613 | `docs/tasks/01-open/1613-warp-prism-epic-16-gallery-catalog-registration.md` |
| 1614 | `docs/tasks/01-open/1614-warp-prism-epic-16-goldens-boundary-alias-audit.md` |
| 1615 | `docs/tasks/01-open/1615-warp-prism-epic-16-acceptance-audit.md` |
| 1616 | `docs/tasks/01-open/1616-warp-prism-optional-cybercore-teal-theme-extension-skin.md` |

All referenced. **No numbering gaps** 1600–1616.

---

## 16. What this brief deliberately does not do

- Does not implement Flutter widgets.  
- Does not edit EPIC-16 planning file (protected planning — user approval required).  
- Does not promote tasks across lanes.  
- Does not start EPIC-15 Map HUD work.  
- Does not change Observatory default tokens.

---

*Task 1600 lock — 2026-07-10. Builders: treat §4 skip list + §6 mapping + §8 false-gaps as non-negotiable.*
