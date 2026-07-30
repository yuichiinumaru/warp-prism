# CyberCore Pilot Evaluation

> **Task**: 1111 — CyberCore Pilot Mirror and Expansion Gate  
> **Date**: 2026-07-09 (post-1110 realign re-evaluation; supersedes same-day Observatory-proxy FAIL gate)  
> **Status**: Active gate evidence  
> **Author**: docs + light reviewer (Task 1111 OWN)  
> **Depends on**: Task 1108 (pilots A/B/C authority), Task 1109 (contracts), Task 1110 (shell realigned)

## 0. Evaluation authority (what this gate measures)

| Authority | Document / artifact | Role |
| --- | --- | --- |
| Pilot routes | `docs/design/cybercore-scope-route-parity.md` §3 + `docs/design/cybercore-pilot-surface-matrix.md` §4 | **Primary** — Task 1108 MVP pilots A/B/C |
| Live CC routes | `cybernetics-core/apps/frontend` `page.tsx` walk (via 1108) | Source of truth for path names |
| ADS boundary | `docs/design/token-theme-catalog-policy.md` §2.4 + `packages/warp_prism_ui` barrel | Prism* public API for consumers |
| Fixtures / API | `docs/design/cybercore-fixture-schema.md`, `docs/design/cybercore-api-contract-inventory.md` | Contract layer (docs still ASW-spine; **runtime** pilot JSON is A/B/C) |
| Pilot shell | `apps/cybercore/` (Task 1110 realign) | Implementation under test |

### Explicit non-authority for pilot success

Historical Observatory-proxy paths (`/dashboard`, `/registry`, `/tasks`, `/audit`, `/governance`) are **not** Task 1108 pilots. They are **not** registered in the current router (comment-only reference). They must not be scored as pilot success or failure.

### Supersession of earlier 2026-07-09 FAIL gate

An earlier same-day 1111 refresh scored pilots A/B/C **FAIL (absent)** against a pre-realign router. That snapshot is **stale**. Task 1110 path-to-100 realigned routes, pages, fixtures, and tests to pilots A/B/C. This document is the post-realign re-evaluation.

---

## 1. Route parity — Task 1108 pilots A / B / C

### Pilot A — Providers (`/providers` + nested)

| Criterion | Result | Evidence |
| --- | --- | --- |
| **Present** in `apps/cybercore` router | **PASS** | `apps/cybercore/lib/app/router.dart`: `/providers`, nested `new`, nested `:id`; initialLocation `/providers`; `/` redirects to `/providers` |
| **Feature page** | **PASS** | `lib/features/providers/providers_page.dart`, `provider_new_page.dart`, `provider_detail_page.dart` |
| **Fixture-correct** (provider connection DTOs) | **PASS** | `assets/cybercore_fixtures/providers.json` — connection list with `id`, `provider`, `authType`, `isActive`, `testStatus`, errors; models in `provider_connection.dart` |
| **Test-covered** for pilot A | **PASS** | Widget: shell, loading on providers, injected fixture success, error non-happy (`test/widget_test.dart`); unit: `ProviderConnection.fromJson` + operationalLabel cases |
| **ADS components for pilot A** | **PASS** | `PrismStateSurface`, `PrismStoryPanel`, `PrismErrorBoundary`, `PrismColors`/`PrismSpacing` via `warp_prism_ui` |

**Pilot A verdict: PASS.**

### Pilot B — MCP Servers + Inspector (`/mcp-servers`, `/mcp-servers/:uuid`, `/mcp-inspector`)

| Criterion | Result | Evidence |
| --- | --- | --- |
| **Present** | **PASS** | Router: `/mcp-servers`, nested `:uuid`, `/mcp-inspector` as shell branches |
| **Feature page** | **PASS** | `mcp_servers_page.dart`, `mcp_server_detail_page.dart`, `mcp_inspector_page.dart` |
| **Fixture-correct** (MCP server / tools DTOs) | **PASS** | `mcp_servers.json`, `mcp_inspector.json`; models `McpServer`, `McpInspectorState` with connection/tools, no live STDIO |
| **Test-covered** | **PASS (minimum)** | Unit: MCP server + inspector model parsing; shell nav proves MCP labels present; no dedicated MCP list widget test (gap, non-blocking vs §3.1 min) |
| **ADS components for pilot B** | **PASS** | Same ADS composition pattern; inspector is fixture snapshot only |

**Pilot B verdict: PASS.**

### Pilot C — Live Logs (`/live-logs`)

| Criterion | Result | Evidence |
| --- | --- | --- |
| **Present** | **PASS** | Router path `/live-logs`; shell nav index 3 |
| **Feature page** | **PASS** | `lib/features/live_logs/live_logs_page.dart` — `PrismLogViewer` + health/redaction summary |
| **Fixture-correct** (logs + redaction) | **PASS** | `live_logs.json` envelope with `success`, `totalCount`, `data[]` including `redacted` / `level` / `serverName` |
| **Test-covered** | **PASS** | Widget navigates to Live Logs branch (loading or Pilot C content); unit: `LiveLogEntry` + `LiveLogsFixture` parse |
| **ADS components for pilot C** | **PASS** | `PrismLogViewer` / `PrismLogEntry`, state surfaces, story panel |

**Pilot C verdict: PASS.**

### First-wave pilot scorecard

| Pilot | Live CC path(s) | Flutter path present? | Fixture domain match? | Tests? | Gate |
| --- | --- | --- | --- | --- | --- |
| A | `/providers` (+ nested) | Yes | Yes | Yes (widget + unit) | **PASS** |
| B | `/mcp-servers`, inspector | Yes | Yes | Yes (unit + shell; widget thin) | **PASS** |
| C | `/live-logs` | Yes | Yes | Yes (nav widget + unit) | **PASS** |

**Route parity overall: PASS (3/3 pilots).**

---

## 2. Downstream Observatory-proxy shell (historical only)

| Check | Result |
| --- | --- |
| Observatory paths registered as primary nav | **No** — intentionally absent |
| Residual ASW dashboard/registry fixtures on disk | **Removed** from `assets/cybercore_fixtures/` (only pilot JSON remains: 4 files) |
| Widget tests reject Observatory labels | **Yes** — expects Dashboard/Registry/Governance `findsNothing` |

---

## 3. ADS package health & component consumption

**Evaluation: PASS (Prism\* public API)**

Re-verification 2026-07-09 (post-realign):

| Check | Result |
| --- | --- |
| `import package:warp_prism_ui/warp_prism_ui.dart` | Present in shell + feature pages |
| `Prism*` symbols in `apps/cybercore/lib` | **183** matches (`rg`) |
| `DS*` type/widget symbols in `apps/cybercore/lib` | **0** |
| Copy-paste of ADS widgets into app | **None observed** |
| Path dependency | `apps/cybercore/pubspec.yaml` → `packages/warp_prism_ui` |
| Shell organisms | `PrismShellResponsive`, `PrismSidebar`, `PrismTopbar`, responsive compact bottom nav |

**Remaining ADS note (non-blocking):** Catalog promotion policy (Task 1105) is not re-audited organism-by-organism in this gate. Namespace + package consumption for the consumer app is **PASS**.

---

## 4. Fixture schemas vs API contracts vs pilot domain

| Layer | Result | Notes |
| --- | --- | --- |
| Runtime fixtures are pilot domain | **PASS** | `providers.json`, `mcp_servers.json`, `mcp_inspector.json`, `live_logs.json` only |
| Fixture models parse | **PASS** | `test/fixtures/fixture_models_test.dart` — 7 unit tests green |
| Operational labels (active/error/inactive/untested) | **PASS** | Covered in provider + MCP unit tests |
| Loading / error / empty in pilot pages | **PASS (code)** | All three pilots implement `PrismStateSurface.loading/error/empty`; widget tests cover loading + error on Pilot A |
| `cybercore-fixture-schema.md` still ASW-shaped | **PARTIAL / DOC DRIFT** | Design doc still describes dashboard/registry/task ASW schemas; **runtime** no longer uses them. Follow-on for Task 1109 docs, not a route FAIL |
| Task 1109 inventory still spines Observatory-proxy + mock-proxy | **PARTIAL / DOC DRIFT** | Live citations for providers/MCP/logs exist; first-wave inventory narrative still mixed ASW. Does **not** block pilot route PASS |
| Live 1:1 Zod parity | **PARTIAL** | Pilot DTOs are fixture-shaped for A/B/C; not claimed byte-identical to live Zod |

**Fixtures overall for pilot gate: PASS** (runtime domain + parse + page wiring). Design-doc refresh for 1109 remains residual.

---

## 5. Does the pilot prove the ADS works for CyberCore?

| Question | Honest answer |
| --- | --- |
| Does ADS compile into a CyberCore-named app? | **Yes** |
| Does the app use Prism\* without package drift? | **Yes** |
| Does the app mirror live CC control-plane pilots A/B/C? | **Yes** |
| Does the app validate ADS against provider/MCP/log operational states? | **Yes** (fixture-backed states + Prism surfaces) |
| Should expansion beyond pilot routes proceed (fixture-backed)? | **Yes — conditional** (one deferred route at a time; see expansion decision) |
| Should live API be authorized? | **No** |

**Overall pilot score: PASS (3/3 route parity + ADS + runtime fixtures). Live API: DENIED. 1109 design-doc spine: residual PARTIAL.**

The pilot **does** prove the ADS against real CyberCore admin IA under a fixture-backed read-only mirror.

---

## 6. Evidence snapshot (reproducible)

```bash
# From warp-prism/
test -f docs/design/cybercore-scope-route-parity.md
test -f docs/design/cybercore-pilot-surface-matrix.md
rg -n "path: '/" apps/cybercore/lib/app/router.dart
# Expected: /providers, /mcp-servers, /mcp-inspector, /live-logs, / → /providers
rg -n "Prism" apps/cybercore/lib --glob '*.dart' | wc -l   # 183
rg -n '\bDS[A-Z]' apps/cybercore/lib --glob '*.dart' || true  # empty
ls apps/cybercore/assets/cybercore_fixtures/
# providers.json mcp_servers.json mcp_inspector.json live_logs.json
cd apps/cybercore && flutter test   # 16/16 PASS (this pass)
```

### Dependency status (observed)

| Task | Lane (observed) | Gate-relevant state |
| --- | --- | --- |
| 1108 | `03-review` (score 100 authority) | Pilots A/B/C are authority |
| 1109 | design docs present | Live citations exist; ASW schema doc drift residual |
| 1110 | `03-review` (drain 2026-07-17; path-to-100 batch4) | Router/pages/fixtures/tests align A/B/C; 16/16 |
| 1111 | this gate | Docs-only re-evaluation post-realign |

### Read-only / no-network posture

| Check | Result |
| --- | --- |
| HTTP / tRPC / dio clients in `apps/cybercore/lib` | **None** |
| Data plane | `FixtureLoader` asset JSON only |
| Mutations | Display-only (e.g. New provider is read-only form route) |

---

## 7. Supersession log

| Date | Claim | Status after post-realign re-eval |
| --- | --- | --- |
| 2026-06-08 | Five Observatory routes are Task 1108 MVP | **Superseded** |
| 2026-06-08 | ADS FAIL due to `DS*` | **Superseded** — Prism* PASS |
| 2026-07-09 early | Pilots A/B/C FAIL (absent); pause for route parity | **Superseded** — 1110 realign landed A/B/C |
| 2026-07-09 late | This document | **Active** — pilot gate **PASS**; live API still denied |
