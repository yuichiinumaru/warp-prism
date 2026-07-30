# Warp Prism — CyberCore Control Surface Inventory

> **Task**: 1102 — Warp Prism Control Surface Inventory  
> **Date**: 2026-07-09 (full rewrite; supersedes 2026-06-08 ADS/Observatory inventory; governance amend same day)  
> **Status**: Source-backed inventory complete (DoD); screenshot-backed evidence **OPTIONAL / ABSENT** (deferred)  
> **Review readiness**: **Ready for reviewer** under 2026-07-09 DoD — primary evidence = live monorepo + tables (§0.5)  
> **Evidence class**: `source-backed` (live, **primary**) · `screenshot-backed` (absent, **optional**) · `unavailable` (historical `/tmp` screenshots)

---

## 0. Evidence Boundary And Provenance

### 0.1 Authorized sources for this rebuild

| Source | Absolute / monorepo path | Class | Used for |
| --- | --- | --- | --- |
| Cybernetics Core frontend (sibling monorepo) | `/home/sephiroth/working/ganthritor/cybernetics-core/apps/frontend` · rel. `cybernetics-core/apps/frontend` | `source-backed` | Routes, admin components, page states/actions, data deps |
| CC UI patterns doc (in CC tree) | `.../apps/frontend/docs/ui-patterns.md` | `source-backed` | Admin component contracts + documented a11y risks |
| Control-plane domain tabs | `.../apps/frontend/components/admin/control-plane-domain-tabs.tsx` | `source-backed` | Full IA tab map beyond primary sidebar |
| Sidebar layout nav | `.../apps/frontend/app/[locale]/(sidebar)/layout.tsx` | `source-backed` | Primary sidebar routes + role filter |
| Auth middleware | `.../apps/frontend/middleware.ts` | `source-backed` | Admin-only / public / read-only route classes |
| Domain state enums | `.../apps/frontend/lib/{llm-diagnostics,llm-remote-exposure,combo-readiness}.ts`, `.../lib/constants.ts`, `.../types/search.ts`, `.../hooks/useConnection.ts`, `.../components/providers/provider-status-badge.tsx`, `.../components/admin/admin-data-state.tsx` | `source-backed` | Explicit operational/UI enums |
| Warp Prism CC mirror app | `warp-prism/apps/cybercore/` | `secondary` | Downstream Flutter mirror only — **not** treated as CC route authority |
| Backend feature catalog | `warp-prism/docs/reference/cybercore-backend-features/` | `secondary` | Domain vocabulary notes only |
| Task 1420 evidence packet | `warp-prism/docs/reference/cybercore-control-surfaces/` | source index + optional screenshot status | Live source inventory; screenshots optional/absent |
| Historical screenshots | `/tmp/opencode/cc-ui-screenshots-round2/*.md` | `unavailable` / optional | **Not present** — no visual state claims invented; not a hard gate |

### 0.2 Explicit non-sources

| Non-source | Why rejected |
| --- | --- |
| Prior `component-inventory.md` (2026-06-08) | Inventories Warp Prism ADS/Observatory (`lib/design_system/`, mock corpus), not CC admin routes |
| Observatory routes under `apps/observatory/` | ASW Observatory product surface, not CyberCore control plane |
| Backend-only feature IDs without a live `page.tsx` | Would invent UI routes that do not exist in the frontend |

### 0.3 Snapshot identity

| Field | Value |
| --- | --- |
| CC frontend root | `/home/sephiroth/working/ganthritor/cybernetics-core/apps/frontend` |
| Relative monorepo path | `cybernetics-core/apps/frontend` (sibling of `warp-prism/`) |
| Git HEAD observed | `ec87953` (working tree may include later uncommitted UI) |
| Sidebar product version string | `v2.4.22` (`layout.tsx` footer) |
| Inventory capture date | 2026-07-09 |
| Path re-verify date | 2026-07-09 (second architect/docs pass) |
| Screenshot packet | **ABSENT / OPTIONAL** (`ls /tmp/opencode/cc-ui-screenshots-round2` → No such file; deferred follow-up) |
| `page.tsx` count (app tree) | 28 routes (FS walk; see `docs/reference/cybercore-control-surfaces/route-inventory.md`) |

### 0.3.1 Path existence stamp (re-verified)

All of the following resolve under `/home/sephiroth/working/ganthritor/cybernetics-core/apps/frontend/` (OK on 2026-07-09 re-verify):

| Relative path | Role | Lines (approx) |
| --- | --- | --- |
| `app/[locale]/(sidebar)/layout.tsx` | Primary nav shell | — |
| `app/[locale]/(sidebar)/providers/page.tsx` | Pilot A | 1143 |
| `app/[locale]/(sidebar)/providers/new/page.tsx` | Provider create | — |
| `app/[locale]/(sidebar)/providers/[id]/page.tsx` | Provider edit | — |
| `app/[locale]/(sidebar)/mcp-servers/page.tsx` | Pilot B list | 497 |
| `app/[locale]/(sidebar)/mcp-servers/[uuid]/page.tsx` | MCP detail | — |
| `app/[locale]/(sidebar)/mcp-inspector/page.tsx` | Pilot B inspector | 384 |
| `app/[locale]/(sidebar)/live-logs/page.tsx` | Pilot C | 351 |
| `app/[locale]/(sidebar)/search/page.tsx` | Marketplace | 525 |
| `app/[locale]/(sidebar)/models/page.tsx` | Model catalog | 420 |
| `app/[locale]/(sidebar)/combos/page.tsx` | Combos | 737 |
| `app/[locale]/(sidebar)/usage/page.tsx` | Usage metrics | 231 |
| `app/[locale]/(sidebar)/costs/page.tsx` | Costs | 617 |
| `app/[locale]/(sidebar)/settings/page.tsx` | Settings | 799 |
| `app/[locale]/(sidebar)/api-keys/page.tsx` | API keys | 386 |
| `app/[locale]/(sidebar)/llm-endpoints/page.tsx` | Endpoint exposure | 610 |
| `app/[locale]/(sidebar)/media/page.tsx` | Media providers | 258 |
| `app/[locale]/(sidebar)/namespaces/page.tsx` | Namespaces | 335 |
| `app/[locale]/(sidebar)/endpoints/page.tsx` | MCP endpoints | 726 |
| `app/[locale]/(sidebar)/discovery/page.tsx` | Harness discovery | 174 |
| `app/[locale]/(sidebar)/harness/page.tsx` | Harness re-export | — |
| `app/[locale]/(sidebar)/settings/aliases/page.tsx` | Model aliases | 198 |
| `components/admin/control-plane-domain-tabs.tsx` | Domain IA | — |
| `components/admin/admin-page-shell.tsx` | Page template | — |
| `components/admin/admin-data-state.tsx` | loading/empty/error | — |
| `components/admin/admin-panel.tsx` | Panels | — |
| `components/admin/admin-table-shell.tsx` | Tables | — |
| `components/admin/admin-data-toolbar.tsx` | Toolbar | — |
| `components/admin/metric-grid.tsx` | Metrics | — |
| `components/providers/provider-status-badge.tsx` | Status badge | — |
| `components/providers/provider-connection-form.tsx` | Connection form | — |
| `hooks/useConnection.ts` | Inspector connection | — |
| `lib/constants.ts` | `ConnectionStatus` | — |
| `lib/llm-diagnostics.ts` | `ProviderHealthStatus` | — |
| `lib/llm-remote-exposure.ts` | `RemoteExposureState` | — |
| `lib/combo-readiness.ts` | `ComboReadinessStatus` | — |
| `types/search.ts` | Catalog status union | — |
| `middleware.ts` | Authz route classes | — |
| `docs/ui-patterns.md` | Component contracts / a11y | — |

### 0.4 Required column schema

Every surface/component row below uses:

| Column | Meaning |
| --- | --- |
| **Surface / Component** | Human name |
| **Route or path** | URL route and/or source file path under CC frontend |
| **Atomic layer** | atom / molecule / organism / template / page / shell |
| **Operational layer** | control-plane domain (Providers, MCP, Harness, Usage, Settings, Auth) |
| **States** | Explicit UI/data states observed in source |
| **Actions** | User-invokable operations observed in source |
| **Data dependencies** | tRPC/REST/query hooks or client libs |
| **Risk** | High / Medium / Low (operator impact if wrong) |
| **Accessibility** | Documented or source-visible a11y concerns |
| **Prism candidate** | Live Warp Prism ADS mapping under `packages/warp_prism_ui/lib/src/` |
| **Disposition** | `MVP` / `defer` / `discard` / `needs-research` |
| **Evidence** | `source-backed` only unless screenshots arrive |

Paths below are relative to `cybernetics-core/apps/frontend/` unless noted. Absolute root for every relative path:

`/home/sephiroth/working/ganthritor/cybernetics-core/apps/frontend/`

### 0.5 Governance amend — screenshot exit (2026-07-09 APPLIED)

> **Question**: Can Task 1102 become `ready_for_reviewer` on source-backed inventory alone when screenshots are unavailable?  
> **Answer**: **Yes** — after **explicit logged governance amend** (not silent waiver). Screenshots reclassified **optional / deferred**.

| Finding | Result |
| --- | --- |
| Screenshot round status | **Unavailable** — `/tmp/opencode/cc-ui-screenshots-round2` missing; no in-repo screenshot reports; will not arrive from that path |
| Primary evidence (DoD) | **Live monorepo paths + inventory tables** (`cybernetics-core/apps/frontend` + this inventory + Task 1420 packet) |
| Task exit condition language (amended) | Primary = live monorepo + tables; if screenshots unavailable, **do not invent** visual data; mark optional/deferred |
| Anti-hallucination guardrail (amended) | Never invent routes or screenshot reports; visual claims stay out of scope until real reports exist |
| Prior independent rejection (F2) | 2026-06-17 rejected **silent** codebase substitution for the screenshot gate — addressed by **explicit amend**, not greenwash |
| **Amend decision** | **APPLIED** — screenshot hard-gate reclassified optional; source-backed inventory is DoD |
| **ready_for_reviewer** | **yes** (formal independent reviewer still pending; task may remain in `02-doing/` for handoff) |

**What source-backed inventory satisfies (DoD):**

- Table-based control-surface inventory with required columns.
- Operational vocabulary with all 14 required state IDs (+ live Prism enums).
- Pilot matrix with 2–3 real CC routes.
- File presence of the three design docs.
- No invented routes; no Flutter packages; no invented screenshots.

**Optional deferred (not blocking `ready_for_reviewer`):**

1. Screenshot report corpus import + index (`screenshot-evidence-index.md` filled with real paths) — follow-up task if ever available.
2. Vendored in-repo CC frontend snapshot for offline reproducibility.

---

## 1. Information Architecture (Live Routes)

### 1.1 Primary sidebar (`app/[locale]/(sidebar)/layout.tsx` → `getMenuItems`)

| Surface | Route | Roles | Icon | Page source | Disposition |
| --- | --- | --- | --- | --- | --- |
| Marketplace (MCP catalog search) | `/search` | `client` | Search | `app/[locale]/(sidebar)/search/page.tsx` | MVP |
| Providers | `/providers` | `admin` | Plug | `app/[locale]/(sidebar)/providers/page.tsx` | MVP |
| MCP Servers (installed) | `/mcp-servers` | `admin` | Server | `app/[locale]/(sidebar)/mcp-servers/page.tsx` | MVP |
| Harness | `/harness` | `admin`, `client` | Wrench | re-exports discovery (`harness/page.tsx` → `discovery/page.tsx`) | MVP |
| Usage | `/usage` | `admin` | BarChart3 | `app/[locale]/(sidebar)/usage/page.tsx` | MVP |
| Settings | `/settings` | `admin` | Settings | `app/[locale]/(sidebar)/settings/page.tsx` | MVP |

### 1.2 Control-plane domain tabs (`components/admin/control-plane-domain-tabs.tsx`)

These routes exist as `page.tsx` files and appear as secondary tabs when the active path matches a domain group. **Not invented** — each `href` is declared in `DOMAIN_GROUPS`.

| Domain group | Tab label | Route | Page source (lines ~) | Disposition |
| --- | --- | --- | --- | --- |
| Providers | Connections | `/providers` | `providers/page.tsx` (1143) | MVP |
| Providers | Model Catalog | `/models` | `models/page.tsx` (420) | MVP |
| Providers | Model Aliases | `/settings/aliases` | `settings/aliases/page.tsx` (198) | defer |
| Providers | Media Providers | `/media` | `media/page.tsx` (258) | defer |
| Providers | Combos | `/combos` | `combos/page.tsx` (737) | MVP |
| Providers | Endpoint Modes | `/providers#endpoint-modes` | same providers page hash | needs-research |
| MCP Servers | Marketplace | `/search` | `search/page.tsx` (525) | MVP |
| MCP Servers | Installed Servers | `/mcp-servers` | `mcp-servers/page.tsx` (497) | MVP |
| MCP Servers | Inspector | `/mcp-inspector` | `mcp-inspector/page.tsx` (384) | MVP |
| MCP Servers | MCP Namespaces | `/namespaces` | `namespaces/page.tsx` (335) | defer |
| MCP Servers | MCP Endpoints | `/endpoints` | `endpoints/page.tsx` (726) | defer |
| Harness | Skills | `/harness?tab=skills` | `discovery/page.tsx` (174) via harness re-export | MVP |
| Harness | Workflows | `/harness?tab=workflows` (+ alias `/workflows` redirect) | discovery + `workflows/page.tsx` redirect | MVP |
| Harness | Hooks | `/harness?tab=hooks` | discovery | defer |
| Harness | Profiles | `/harness?tab=profiles` | discovery | defer |
| Usage | Metrics | `/usage` | `usage/page.tsx` (231) | MVP |
| Usage | Costs & Budgets | `/costs` | `costs/page.tsx` (617) | MVP |
| Usage | Live Logs | `/live-logs` | `live-logs/page.tsx` (351) | MVP |
| Settings | General | `/settings` | `settings/page.tsx` (799) | MVP |
| Settings | API Keys | `/api-keys` | `api-keys/page.tsx` (386) | MVP |
| Settings | Endpoint Exposure | `/llm-endpoints` | `llm-endpoints/page.tsx` (610) | MVP |

### 1.3 Nested / auxiliary routes (source-backed, not all in sidebar)

| Surface | Route | Source | Notes | Disposition |
| --- | --- | --- | --- | --- |
| Root redirect | `/` | `(sidebar)/page.tsx` | Redirect/loading into app | discard (no UI surface) |
| Provider create | `/providers/new` | `providers/new/page.tsx` | Connection form | MVP |
| Provider edit | `/providers/[id]` | `providers/[id]/page.tsx` | Connection detail/edit | MVP |
| MCP server detail | `/mcp-servers/[uuid]` | `mcp-servers/[uuid]/page.tsx` + tool components | Tool management | MVP |
| Namespace detail | `/namespaces/[uuid]` | `namespaces/[uuid]/page.tsx` | Servers + tools tables | defer |
| Login | `/login` | `app/[locale]/login/page.tsx` | Auth | MVP (shell gate) |
| Register | `/register` | `app/[locale]/register/page.tsx` | Auth | defer |
| CORS error | `/cors-error` | `app/[locale]/cors-error/page.tsx` | Error surface | defer |
| OAuth callback | `/fe-oauth/callback` | `app/fe-oauth/callback/page.tsx` | OAuth return | needs-research |

### 1.4 Middleware route classes (`middleware.ts`)

| Class | Routes (explicit in source) |
| --- | --- |
| Public | `/login`, `/register`, `/`, `/cors-error` |
| Read-only (no auth) | `/search`, `/discovery` |
| Admin-only (middleware list; incomplete vs full admin IA) | `/mcp-servers`, `/namespaces`, `/endpoints`, `/mcp-inspector`, `/live-logs`, `/settings`, `/costs` |

> **Note**: Sidebar + domain tabs expose additional admin pages (e.g. `/providers`, `/usage`, `/combos`, `/api-keys`, `/llm-endpoints`) that are **not** all listed in `adminOnlyRoutes`. Role filtering also happens client-side via `clientMode` + `getMenuItems().roles`. Disposition for middleware parity: **needs-research** (authz consistency risk).

---

## 2. Control Surface Inventory (Pages)

| Surface | Route / path | Atomic layer | Operational layer | States (source) | Actions (source) | Data dependencies | Risk | Accessibility | Prism candidate | Disposition | Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| App shell + sidebar | `(sidebar)/layout.tsx` + `components/ui/sidebar.tsx` | shell | all | clientMode on/off; session null/present; effectiveRole admin/client | toggle client/dev mode; sign out; language; theme; nav | `authClient.getSession` | High | No `aria-current` on active item (ui-patterns §5.2); focus ring issues when collapsed | `DSShell`, `DSSidebar`, `DSTopbar` | MVP | source-backed |
| Domain tabs | `components/admin/control-plane-domain-tabs.tsx` | molecule | all | active tab match / no group (hidden) | navigate tabs | pathname + searchParams | Medium | Has `aria-label="{group} sections"` | `DSTabBar` / `DSTabView` | MVP | source-backed |
| Providers list | `/providers` · `providers/page.tsx` | page | Providers | loading/empty/error (`AdminDataState`); preset `configured`/`unsupported`; connection `isActive` + test `success`/`error`/`unknown`; legacy import `importable`/`blocked`/`duplicate`/`unsupported`; redaction secret counts | filter; search; create; edit; delete; test connection; legacy preflight/import | `trpc.frontend.llmProviders.*` | High | Filter group lacks `role=group`; backup textarea a11y (ui-patterns) | `DSDataTable`, `DSSearchBar`, `DSFilterChipGroup`, `DSStateSurface`, `DSHealthCard`, `DSStatusDot` | MVP | source-backed |
| Provider new/edit | `/providers/new`, `/providers/[id]` | page | Providers | form validation; pending mutation; active/inactive | save; cancel; bind credentials | provider connection form + tRPC mutations | High | Form labels present via shadcn Form | `DSDetailInspector`, form atoms | MVP | source-backed |
| Model catalog | `/models` · `models/page.tsx` | page | Providers | loading/error/empty filters; stale discovered rows metric | filter provider/capability/search | model catalog tRPC queries | Medium | Table scroll region unlabeled | `DSDataTable`, `DSMetricTile`, `DSStateSurface` | MVP | source-backed |
| Combos | `/combos` · `combos/page.tsx` | page | Providers | combo readiness `ready` / `provider-warning` / `inactive-provider` / `missing-provider` / `empty`; entry `ready`/`warning`/`inactive`/`missing`/`reference` | create/edit/delete combo; set endpoint mode | `listCombos`, `createCombo`, `updateCombo`, `deleteCombo`, `setComboEndpointMode`, providers list | High | Status conveyed partly by badge color | `DSDataTable`, `DSBadge`, `DSStateSurface`, `DSHealthCard` | MVP | source-backed |
| Media providers | `/media` | page | Providers | active/inactive badges; TTS/image kind filters; mutation pending | enable/update media config | `llmProviders.list` + `update` | Medium | Kind toggles not grouped as radiogroup | `DSFilterChipGroup`, `DSBadge` | defer | source-backed |
| Model aliases | `/settings/aliases` | page | Providers | loading/error | alias CRUD (page-local) | config/alias APIs | Medium | — | `DSDataTable` | defer | source-backed |
| MCP marketplace | `/search` · `search/page.tsx` | page | MCP | catalog status `ready`/`needs_env`/`needs_review`/`unsupported`; loading skeleton; error banner; add-server errors | search; paginate; bulk add servers | React Query → catalog HTTP API | Medium | Loading not announced (ui-patterns §5.3) | `DSSearchBar`, `DSAssetCard`, `DSSkeletonCard`, `DSStateSurface` | MVP | source-backed |
| MCP servers list | `/mcp-servers` | page | MCP | list loading/error; create pending/error; empty list | create server dialog; open detail; export/import | `trpc.frontend.mcpServers.list/create` | High | Result count not `aria-live` (ui-patterns) | `DSDataTable`, `DSStateSurface`, `DSToast` | MVP | source-backed |
| MCP server detail | `/mcp-servers/[uuid]` | page | MCP | tools load states; enable/disable tool | tool management CRUD; refresh | server + tools tRPC | High | Nested tables a11y | `DSDetailInspector`, `DSDataTable`, `DSChip` | MVP | source-backed |
| MCP inspector | `/mcp-inspector` | page | MCP | connection `disconnected`/`connecting`/`connected`/`error`/`error-connecting-to-proxy`; server list error | select server; connect/disconnect; ping; list tools/resources/prompts | `mcpServers.list` + `useConnection` | High | Connection status color-only risk | `DSLogViewer`, `DSStatusDot`, `DSStateSurface`, `DSSplitPane` | MVP | source-backed |
| Namespaces | `/namespaces`, `/namespaces/[uuid]` | page | MCP | create form errors; servers loading; empty | create namespace; manage servers/tools | `namespaces.*`, `mcpServers.list` | Medium | — | `DSDataTable`, `DSDetailInspector` | defer | source-backed |
| MCP endpoints | `/endpoints` | page | MCP | form validation; submit pending; namespace loading | create endpoint; rate limits; auth flags | `endpoints.create`, `namespaces.list` | High | Complex form error association | form + `DSDetailInspector` | defer | source-backed |
| Harness / discovery | `/harness`, `/discovery` | page | Harness | tabs skills/workflows/hooks/profiles; loading/error; pagination | tab switch; search; paginate | `/api/discovery/*` + `/api/profiles` `/api/hooks` | Medium | Tab a11y depends on custom tabs | `DSTabView`, `DSSearchBar`, `DSAssetCard` | MVP | source-backed |
| Workflows alias | `/workflows` | page | Harness | redirect only | redirect → harness?tab=workflows | next redirect | Low | n/a | n/a | discard | source-backed |
| Usage metrics | `/usage` | page | Usage | loading/error/empty provider & model groups | period controls | `llmProviders.getUsageStats` | Medium | Metric icons may lack labels (ui-patterns) | `DSMetricTile`, `DSStateSurface`, `DSSparkline` | MVP | source-backed |
| Costs & budgets | `/costs` | page | Usage | loading/error/empty events; budget policies list states | period; view events; manage policies | cost/budget tRPC | High | — | `DSMetricTile`, `DSDataTable`, `DSStateSurface` | MVP | source-backed |
| Live logs | `/live-logs` | page | Usage | provider health `ready`/`failing`/`inactive`/`unknown`; auto-refresh on/off; empty logs; redacted log rows | toggle auto-refresh; refresh; clear; export support bundle | `llmProviders.list` + client log store + redaction helpers | High | Live updates need polite live region | `DSLogViewer`, `DSLogFilterBar`, `DSMetricTile`, `DSHealthCard` | MVP | source-backed |
| Settings general | `/settings` | page | Settings | many config booleans disabled/enabled; mutation error toasts; pending | toggle signup/SSO/basic auth; MCP timeouts; session lifetime | `trpc.frontend.config.*` | High | Switch labels association | `DSStateSurface`, settings form molecules | MVP | source-backed |
| API keys | `/api-keys` | page | Settings | list; create once-visible secret; delete pending | create; copy; delete | `apiKeys.list/create/delete` | High | Secret reveal timing; copy buttons need labels | `DSDataTable`, `DSToast`, redaction display | MVP | source-backed |
| Endpoint exposure | `/llm-endpoints` | page | Settings | remote state `disabled`/`configured`/`enabled`/`error`; redacted origin; audit empty/error/loading; API-key posture | copy URLs; inspect audit (no tunnel create) | remote exposure fetch + `apiKeys.list` | High | Redacted fields must announce redaction | `DSMetricTile`, `DSCodeBlock`, `DSLogViewer`, `DSStateSurface` | MVP | source-backed |
| Login / register | `/login`, `/register` | page | Auth | form error; submitting; redirect | sign in / sign up | `authClient` | High | Standard form a11y | form atoms | MVP | source-backed |

---

## 3. Admin Component Inventory (Shared Control Primitives)

Source: `components/admin/*` + contracts in `docs/ui-patterns.md`.

| Component | Path | Atomic layer | Operational layer | States | Actions | Data dependencies | Risk | Accessibility | Prism candidate | Disposition | Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| AdminPageShell | `components/admin/admin-page-shell.tsx` | template | all pages | title/desc/actions present or absent | host page actions slot | none | Low | h1 present; actions not named region | page header pattern / `DSTopbar` title mode | MVP | source-backed |
| AdminDataState | `components/admin/admin-data-state.tsx` | molecule | all data pages | `loading` / `empty` / `error` | optional action node | none | Medium | `role=alert` on error only; missing `aria-live` loading/empty | `DSStateSurface` (`DSStateType`) | MVP | source-backed |
| AdminPanel / ConfigPanel / DangerZone | `components/admin/admin-panel.tsx` | organism | settings/providers | `default` / `danger` | header actions | none | Medium | No `aria-labelledby`; danger lacks region label | `DSGlassPanel`, `DSStoryPanel` | MVP | source-backed |
| AdminTableShell | `components/admin/admin-table-shell.tsx` | organism | list pages | desktop/mobile split | host table actions | none | Medium | Desktop scroll region unlabeled; mobile cards lack h3 | `DSDataTable` + responsive shell | MVP | source-backed |
| AdminDataToolbar | `components/admin/admin-data-toolbar.tsx` | molecule | list pages | search/filter layout | host controls | none | Low | Not in `role=search` landmark | `DSSearchBar` + `DSFilterChipGroup` | MVP | source-backed |
| MetricGrid / MetricCard | `components/admin/metric-grid.tsx` | molecule | dashboards | value present | optional | none | Low | Icon may lack `aria-hidden` | `DSMetricTile` | MVP | source-backed |
| ControlPlaneDomainTabs | `components/admin/control-plane-domain-tabs.tsx` | molecule | IA | active/inactive | navigate | router | Medium | has section `aria-label` | `DSTabBar` | MVP | source-backed |
| LlmOpsPeriodControls | `components/admin/llm-ops-period-controls.tsx` | molecule | Usage/Costs | selected period | change period | parent | Low | — | filter chips / select | MVP | source-backed |
| ProviderStatusBadge | `components/providers/provider-status-badge.tsx` | atom | Providers | Inactive; Active; Error; Untested | display only | `isActive`, `testStatus` | Medium | Color+text (ok) | `DSBadge` + `DSOperationalState` mapping | MVP | source-backed |
| Provider connection form | `components/providers/provider-connection-form.tsx` | organism | Providers | validation; pending | submit credentials | form + provider metadata | High | Dropdown width a11y | form organisms | MVP | source-backed |
| Edit MCP server / endpoint / namespace | `components/edit-*.tsx` | organism | MCP | dialog open; pending; error | edit entity | tRPC mutations | High | Menu min-width patterns | detail editors | defer | source-backed |
| Skeletons | `components/skeletons/*` | atom | MCP/search | loading placeholder | none | none | Low | Decorative | `DSSkeletonCard`, `DSSkeletonTableRows`, `DSShimmer` | MVP | source-backed |
| Logs status indicator | `components/logs-status-indicator.tsx` | atom | Usage | indicator variants | none | log stream | Medium | — | `DSStatusDot` | MVP | source-backed |
| Domain warning banner | `components/domain-warning-banner.tsx` | molecule | shell | origin mismatch warn/hidden | none | app URL config | Medium | — | `DSToast` / banner | defer | source-backed |
| shadcn UI kit | `components/ui/*` | atoms/molecules | all | component-local | various | none | Low–Med | See ui-patterns §5 | Map selectively; do not port wholesale | needs-research | source-backed |

### 3.1 Proposed-but-not-implemented (ui-patterns only — not inventory as live)

| Proposal | Status | Disposition |
| --- | --- | --- |
| `McpChipPicker` | Documented only in `ui-patterns.md` §3 | needs-research |
| `GuidanceCard` | Documented only in `ui-patterns.md` §4 | needs-research |
| Declarative `NavItem` contract | Proposed; layout still imperative | needs-research |

---

## 4. Explicit Domain State Enums (Source)

Absolute root: `/home/sephiroth/working/ganthritor/cybernetics-core/apps/frontend/`.

| Domain enum | Values (source) | Absolute citation | Maps toward Prism ops states |
| --- | --- | --- | --- |
| `AdminDataStateVariant` | `"loading" \| "empty" \| "error"` | `.../components/admin/admin-data-state.tsx:5` | UI `DSStateType` (not operational) |
| `ProviderStatusBadge` labels | Inactive / Active / Error / Untested from `isActive` + `testStatus?: "success"\|"error"\|"unknown"` | `.../components/providers/provider-status-badge.tsx:4-24` | disabled; healthy; error; unverified |
| `ProviderHealthStatus` | `"ready" \| "failing" \| "inactive" \| "unknown"` | `.../lib/llm-diagnostics.ts:15` | healthy; error; disabled; unverified |
| `RemoteExposureState` | `z.enum(["disabled","configured","enabled","error"])` | `.../lib/llm-remote-exposure.ts:3-8` | disabled; pending; exposed (+promoted); error |
| Catalog search status | `"ready" \| "needs_env" \| "needs_review" \| "unsupported"` | `.../types/search.ts:13` | healthy; degraded; unverified; rejected |
| `ComboReadinessStatus` | ready, provider-warning, inactive-provider, missing-provider, empty | `.../lib/combo-readiness.ts:25-30` | healthy; degraded; disabled; error; empty UI |
| `ComboEntryReadinessStatus` | ready, warning, inactive, missing, reference | `.../lib/combo-readiness.ts:32-37` | healthy; degraded; disabled; error; derived ref |
| `ConnectionStatus` | connecting, disconnected, connected, error, error-connecting-to-proxy | `.../lib/constants.ts` (+ `hooks/useConnection.ts`) | running; disabled; healthy; error |
| Legacy import mapping status | importable, blocked, duplicate, unsupported | `.../app/[locale]/(sidebar)/providers/page.tsx` helpers | approved/pending; rejected; stale/rejected |
| Preset status | configured, unsupported (+ implied incomplete) | same providers page | promoted; rejected |
| Middleware route classes | public / readOnly / adminOnly (partial vs full IA) | `.../middleware.ts:97-110` | authz risk → needs-research |

---

## 5. Disposition Summary

| Disposition | Count (approx) | Examples |
| --- | --- | --- |
| **MVP** | Primary shell + Providers + MCP list/detail/inspector + Marketplace + Combos + Usage/Costs/Live logs + Settings/API keys/Exposure + Admin* primitives | First pilot proof set |
| **defer** | Media, aliases, namespaces, endpoints CRUD depth, register, cors-error | After pilots |
| **discard** | `/` redirect-only, `/workflows` pure redirect | No independent UI |
| **needs-research** | Middleware vs sidebar authz parity; `#endpoint-modes` hash UX; OAuth callback; full shadcn port; proposed McpChipPicker/GuidanceCard; screenshot visual defects | Requires screenshot packet or deeper security review |

---

## 6. Warp Prism ADS Crosswalk (Live Paths Only)

| CC need | Live Prism path (`packages/warp_prism_ui/lib/src/`) | Gap |
| --- | --- | --- |
| Page shell | `organisms/ds_shell.dart`, `ds_sidebar.dart`, `ds_topbar.dart` | Domain tabs need `ds_tab_bar.dart` wiring |
| Loading/empty/error | `molecules/ds_state_surface.dart` (`DSStateType` **7** values: empty, loading, error, disabled, stale, degraded, excluded) | CC `AdminDataState` only 3 — Prism already broader |
| Operational status | `tokens/ds_operational_state.dart` (**15** values) | Need explicit mappers from CC domain enums |
| Metrics | `molecules/ds_metric_tile.dart` | parity OK |
| Tables | `organisms/ds_data_table.dart` | mobile card split not identical to AdminTableShell |
| Logs | `organisms/ds_log_viewer.dart`, `ds_log_filter_bar.dart` | redaction semantics need product rules |
| Health | `molecules/ds_health_card.dart`, `ds_status_grid.dart`, `ds_uptime_bar.dart` | map ProviderHealthStatus |
| Search/filter | `ds_search_bar.dart`, `ds_filter_chip_group.dart` | OK |
| Toast | `ds_toast.dart` | OK |
| Code / secrets | `ds_code_block.dart` | redacted display contract |
| Graph topology | `ds_graph_canvas.dart` | **No live CC graph editor route found** in current frontend pages |

> Historical note: pre-Melos paths `lib/design_system/` no longer exist. Do not cite them.

---

## 7. Screenshot Evidence Status

| Claim type | Status |
| --- | --- |
| Route exists because `page.tsx` exists | **Allowed** (source-backed) |
| Component contract from TSX props / enums | **Allowed** (source-backed) |
| Visual defect, color contrast, spacing from screenshots | **Out of scope / optional** — `/tmp/opencode/cc-ui-screenshots-round2` absent; no in-repo screenshot index; do not invent |
| “22 screenshot routes” historical claim | **Not re-asserted** without files |
| Task 1102 screenshot exit / ready_for_reviewer | **Screenshot optional** — DoD source-backed; `ready_for_reviewer: yes` — see §0.5 |

---

## 8. Relationship To `apps/cybercore` (Warp Prism Mirror)

`apps/cybercore/` implements a **read-only Flutter mirror** with routes `/dashboard`, `/registry`, `/tasks`, `/audit`, `/governance`. That IA is a Warp Prism product choice (Task 1108+), **not** a copy of live Next.js CC routes. This inventory does **not** treat those five routes as CyberCore control surfaces.

---

## 9. Open Gaps (Non-Blocking / Follow-Up)

1. **Optional deferred**: Import screenshot reports and fill `screenshot-evidence-index.md` if ever available (follow-up task). Not required for Task 1102 DoD after 2026-07-09 amend (§0.5).
2. Optional: vendor a reviewed CC frontend snapshot under `docs/reference/cybercore-control-surfaces/` (sibling monorepo citation is currently authorized for source evidence).
3. Resolve middleware `adminOnlyRoutes` vs full admin IA mismatch (security review) — `middleware.ts` lists only `/mcp-servers`, `/namespaces`, `/endpoints`, `/mcp-inspector`, `/live-logs`, `/settings`, `/costs`.
4. Keep CC domain enum → `DSOperationalState` grades honest (`explicit` | `derived` | `speculative`) in `operational-state-vocabulary.md`.
5. Independent formal re-review of source-backed inventory package (task left in `02-doing/` for handoff).
