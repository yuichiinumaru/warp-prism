# Warp Prism — CyberCore Pilot Surface Matrix

> **Task**: 1102 — Warp Prism Control Surface Inventory  
> **Date**: 2026-07-09 (rewrite — pilots selected from **live CC routes**, not Observatory; §0.5 amend same day)  
> **Status**: Active pilot selection (source-backed DoD); screenshot confirmation **optional / absent** (deferred)  
> **Review readiness**: **Ready for reviewer** under 2026-07-09 DoD — screenshots **optional** (`component-inventory.md` §0.5 APPLIED)  
> **Evidence root**: `/home/sephiroth/working/ganthritor/cybernetics-core/apps/frontend` (+ inventory in `component-inventory.md`)

---

## 1. Objective

Select **two or three** first-proof CyberCore control surfaces so Warp Prism ADS work targets real operator IA:

1. Real Next.js admin/operator routes (not ASW Map/Operate/History substitutes).
2. Dense operational states from live enums.
3. Reuse of shared `components/admin/*` primitives.
4. Clear Prism ADS candidates already present under `packages/warp_prism_ui`.
5. Achievable as **read-only mirror** fixtures before live API (per product constraints).

---

## 2. Selection Criteria

| Criterion | Weight | Measurement |
| --- | --- | --- |
| Live route exists (`page.tsx`) | Gate | Must be source-backed |
| Operational state density | High | ≥5 distinct CC state values |
| Admin primitive coverage | High | Uses AdminPageShell + table/metrics/state |
| Risk / storytelling value | High | Secrets, health, exposure, or import risk |
| Prism ADS readiness | Medium | Existing organisms/molecules cover ≥70% |
| Screenshot confirmation | Medium | Preferred; **not available this pass** |
| Implementation complexity | Low (tie-break) | Prefer list+detail over multi-entity graph |

**Rejected selection method**: Observatory task board / skill topology as “CyberCore pilots” (2026-06-08 matrix — F6).

---

## 3. Candidate Evaluation (Live CC Only)

| ID | CC surface | Route | States exercised (source) | Admin primitives | Risk story | Prism readiness | Score |
| --- | --- | --- | --- | --- | --- | --- | --- |
| A | Providers connections | `/providers` (+ `/providers/new`, `/providers/[id]`) | inactive/active/error/untested; preset configured/unsupported; legacy importable/blocked/duplicate; loading/empty/error; redaction counts | AdminPageShell, AdminPanel, AdminTableShell, AdminDataState, AdminDataToolbar, ProviderStatusBadge | Credential + legacy backup import | High — table, badges, health, state surface | **9.2** |
| B | MCP servers + inspector | `/mcp-servers`, `/mcp-servers/[uuid]`, `/mcp-inspector` | list error/loading; connection connecting/connected/error; tool enablement | AdminDataState, tables, dialogs, inspector panels | STDIO command execution risk | High — log viewer, status, detail inspector | **8.7** |
| C | Live logs + provider health | `/live-logs` | ready/failing/inactive/unknown; redacted logs; auto-refresh | AdminPageShell, MetricGrid, AdminPanel, AdminDataState | Runtime incident narrative | High — DSLogViewer, metrics, health | **8.4** |
| D | Endpoint exposure | `/llm-endpoints` | remote disabled/configured/enabled/error; redacted origin; audit empty | AdminPageShell, MetricGrid, AdminPanel, AdminDataState | Public exposure boundary | High — metrics, code block, redaction | **8.1** |
| E | Usage + costs | `/usage`, `/costs` | period metrics; empty groups; budget policies | MetricGrid, AdminPanel, period controls | Spend governance | Medium — charts thinner than logs | **7.0** |
| F | Marketplace search | `/search` | catalog ready/needs_env/needs_review/unsupported | skeletons, cards, pagination | Supply-chain install risk | Medium | **6.8** |
| G | Combos readiness | `/combos` | ready/warning/inactive/missing/empty | AdminPageShell, tables, badges | Routing correctness | Medium-High | **7.5** |
| H | Settings toggles | `/settings` | many disabled/enabled config flags | forms, switches | Auth posture | Medium | **6.0** |
| X | Observatory Operate board | n/a (WP only) | mock lanes | WP lane board | — | — | **reject** (wrong domain) |
| Y | Observatory Map graph | n/a (WP only) | mock topology | WP graph | — | — | **reject** (no CC graph route) |

---

## 4. Selected Pilots

### Pilot 1 (A) — Providers Connections — **SELECTED**

| Field | Value |
| --- | --- |
| Route | `/providers` |
| Nested | `/providers/new`, `/providers/[id]` |
| Source (abs.) | `/home/sephiroth/working/ganthritor/cybernetics-core/apps/frontend/app/[locale]/(sidebar)/providers/page.tsx` (1143 lines); `.../providers/new/page.tsx`; `.../providers/[id]/page.tsx`; `.../components/providers/*` |
| Domain group | Providers → Connections |
| Why first | Richest single page: table + status badge matrix + danger import panel + test connection + filters |
| Ops states | `disabled`, `healthy`, `error`, `unverified`, `rejected`, `pending`, `redacted`, UI loading/empty/error |
| Actions to fixture (read-only mirror) | list, filter, open detail, show test result badges, show import preflight **as data** (no real import mutation in WP) |
| Data deps | `trpc.frontend.llmProviders.list`, delete, testConnection, legacy preflight/import |
| Prism candidates | `DSShell`, `DSDataTable`, `DSSearchBar`, `DSFilterChipGroup`, `DSBadge`, `DSStatusDot`, `DSHealthCard`, `DSStateSurface`, `DSOperationalState`, `DSToast`, `AdminPanel`→`DSGlassPanel` |
| Risks | Secret handling; destructive delete; false “healthy” if test status ignored |
| A11y risks | Filter group labeling; backup textarea describedby (ui-patterns) |
| Disposition | **MVP pilot #1** |
| Evidence | source-backed; screenshot-backed **missing** |

### Pilot 2 (B) — MCP Servers + Inspector — **SELECTED**

| Field | Value |
| --- | --- |
| Routes | `/mcp-servers`, `/mcp-servers/[uuid]`, `/mcp-inspector` |
| Source (abs.) | `.../app/[locale]/(sidebar)/mcp-servers/page.tsx` (497); `.../mcp-servers/[uuid]/page.tsx`; `.../mcp-inspector/page.tsx` (384); `.../hooks/useConnection.ts`; `.../lib/constants.ts` (`ConnectionStatus`) |
| Domain group | MCP Servers |
| Why second | Core CyberCore product (MCP control plane); connection lifecycle is pure operational state machine |
| Ops states | `running` (connecting), `healthy` (connected), `error`, `disabled` (disconnected), list error/loading |
| Actions to fixture | list servers; open detail tools; show connection status; **do not** execute live STDIO in WP mirror |
| Data deps | `trpc.frontend.mcpServers.*`, inspector proxy connection |
| Prism candidates | `DSDataTable`, `DSDetailInspector`, `DSLogViewer`, `DSSplitPane`, `DSStateSurface`, `DSStatusDot`, `DSChip` |
| Risks | Command execution semantics; overstating connection as healthy |
| A11y risks | Result count live region; status color-only |
| Disposition | **MVP pilot #2** |
| Evidence | source-backed; screenshot-backed **missing** |

### Pilot 3 (C) — Live Logs + Health Strip — **SELECTED (optional third)**

| Field | Value |
| --- | --- |
| Route | `/live-logs` |
| Source (abs.) | `.../app/[locale]/(sidebar)/live-logs/page.tsx` (351); `.../lib/llm-diagnostics.ts` (`ProviderHealthStatus`); `.../components/logs-status-indicator.tsx` |
| Domain group | Usage → Live Logs |
| Why third | Best storytelling surface: aggregate health metrics + streaming/redacted logs; pairs with Pilot 1 health model |
| Ops states | `healthy`/`error`/`disabled`/`unverified` via ProviderHealthStatus; `redacted` log lines; empty logs |
| Actions to fixture | refresh, filter severity, show redacted rows, metric tiles (auto-refresh simulated) |
| Data deps | providers list + client log buffer + redaction |
| Prism candidates | `DSLogViewer`, `DSLogFilterBar`, `DSMetricTile`, `DSHealthCard`, `DSStatusGrid` |
| Risks | Log PII; false confidence from stale auto-refresh |
| Disposition | **MVP pilot #3** (can slip to wave-2 if capacity forces two-only) |
| Evidence | source-backed; screenshot-backed **missing** |

---

## 5. Explicit Deferrals

| Surface | Route | Why deferred |
| --- | --- | --- |
| Endpoint exposure | `/llm-endpoints` | Strong exposure/redaction story but overlaps Pilot 3; schedule immediately after pilots |
| Combos | `/combos` | Valuable readiness matrix; depends on provider model from Pilot 1 |
| Costs & budgets | `/costs` | Needs period/metrics polish after Usage |
| Marketplace | `/search` | Public/client role surface; secondary to admin control plane |
| Namespaces / endpoints CRUD | `/namespaces`, `/endpoints` | Heavy forms; lower state density than health/import |
| Settings general | `/settings` | Many toggles, low narrative |
| Harness discovery tabs | `/harness` | Thin discovery UI vs providers/MCP |
| Observatory Map/Operate/History | WP-only | **Not CyberCore control surfaces** |

---

## 6. Pilot → Prism Implementation Order

| Step | Deliverable | Pilot |
| --- | --- | --- |
| 1 | Map CC provider + health enums → `DSOperationalState` chips | A, C |
| 2 | Fixture JSON for providers list + badges + empty/error | A |
| 3 | Read-only providers table + detail inspector | A |
| 4 | Fixture MCP servers + connection status enum | B |
| 5 | MCP list + detail tools table (read-only) | B |
| 6 | Live logs viewer with redaction fixtures | C |
| 7 | Shared AdminPageShell equivalent using `DSShell` + domain tabs | A–C |

No Flutter packages are created by Task 1102 itself.

---

## 7. Traceability

| Pilot | Inventory rows | Vocabulary states | Downstream tasks |
| --- | --- | --- | --- |
| A Providers | component-inventory §2 Providers* | disabled, healthy, error, unverified, rejected, pending, redacted | 1104+ ADS binding, 1108 route parity refresh |
| B MCP | MCP servers/inspector rows | running, healthy, error, disabled | 1104+, MCP fixture work |
| C Live logs | live-logs row | healthy, error, disabled, unverified, redacted | log viewer validation |

---

## 8. Non-Goals

- Replacing the Next.js CyberCore admin app.
- Claiming screenshot-backed visual parity.
- Treating `apps/cybercore` Flutter routes (`/dashboard`…) as upstream CC IA.
- Inventing routes (capabilities graph editor, plugins UI, etc.) that lack `page.tsx` in the live frontend.

---

## 9. Gate Status For Pilots

| Check | Status |
| --- | --- |
| Pilots are real CC routes (`page.tsx` re-verified 2026-07-09) | **PASS** |
| Each pilot cites absolute monorepo source paths | **PASS** |
| Two or three pilots selected | **PASS** (3 selected; 2 minimum met) |
| Screenshot confirmation | **ABSENT / OPTIONAL** (deferred; do not invent) |
| Screenshot hard-gate after 2026-07-09 amend? | **NO** — reclassified optional (`component-inventory.md` §0.5 APPLIED) |
| Formal in-repo CC source tarball | **Not imported** (sibling monorepo citation authorized for source rebuild only) |
| Task 1102 `ready_for_reviewer` | **yes** (source-backed DoD; formal independent reviewer pending; stay in `02-doing/`) |
