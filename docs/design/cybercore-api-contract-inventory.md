# CyberCore API Data Contract Inventory

> **Task**: 1109  
> **Date**: 2026-07-09 (path-to-100 rewrite — pilots A/B/C only)  
> **Prior draft**: 2026-06-08 / citation pass 2026-07-09 (Observatory-proxy spine — **superseded**)  
> **Status**: Active  
> **Scope**: Task 1108 first-wave MVP pilots **A/B/C** only  
> **Authority**: `docs/design/cybercore-scope-route-parity.md` §3

## 0. Monorepo path spelling (evidence)

| Label | Path | Present in workspace? |
| --- | --- | --- |
| **Live monorepo (correct)** | `../cybernetics-core/` (relative to `warp-prism/`) | **Yes** — `apps/backend/`, `apps/frontend/`, `packages/trpc/`, `packages/zod-types/` |
| Historical task Where table | `../cyberneticscore/apps/{backend,frontend}/` (no hyphen) | **No** — directory does not exist |
| Brand string in code | `cyberneticscore` (no hyphen) | Package names, URL prefixes (`/cyberneticscore`), Zod type names — not the FS repo folder |
| Related Go control plane | `../cybernetics-go-backend/` | Present; **out of first-wave Flutter fixture scope** |

All source citations below use the **live hyphenated** monorepo root, relative to `warp-prism/`:

```text
../cybernetics-core/apps/backend/
../cybernetics-core/apps/frontend/
../cybernetics-core/packages/trpc/
../cybernetics-core/packages/zod-types/
```

Local pilot fixtures (first-wave data plane):

```text
apps/cybercore/assets/cybercore_fixtures/providers.json
apps/cybercore/assets/cybercore_fixtures/mcp_servers.json
apps/cybercore/assets/cybercore_fixtures/mcp_inspector.json
apps/cybercore/assets/cybercore_fixtures/live_logs.json
```

---

## 1. Overview and Assumptions

This inventory defines the **first-wave read-only** DTO/read-model contracts for the CyberCore Flutter pilot routes selected by **Task 1108** (aligned to Task 1102 pilots A/B/C):

| Pilot | Live CC route(s) | Flutter candidate | Fixture file(s) |
| --- | --- | --- | --- |
| **A** | `/providers` (+ `/providers/new`, `/providers/[id]`) | same path shapes | `providers.json` |
| **B** | `/mcp-servers`, `/mcp-servers/[uuid]`, `/mcp-inspector` | same path shapes | `mcp_servers.json`, `mcp_inspector.json` |
| **C** | `/live-logs` | `/live-logs` | `live_logs.json` |

First-wave screens are **fixture-backed**. Live monorepo tRPC/Zod contracts are cited as **parity targets** so later clients can swap fixtures without inventing endpoints.

### Supersession note (Observatory-proxy)

The 2026-06-08 inventory inventoried Observatory-proxy paths `/dashboard`, `/registry`, `/tasks`, `/audit`, `/governance`. Those are **not** live CyberCore Next.js routes and are **not** Task 1108 first-wave MVP (see 1108 §2.4). They appear only in **Appendix A** as a drift record — **not** as pilot contracts.

### Auth & Config Assumptions

| Concern | First-wave (Flutter pilot) | Live monorepo evidence |
| --- | --- | --- |
| **Auth** | No live auth. Fixture mode only. | Better-auth + session: `../cybernetics-core/apps/backend/src/auth.ts`, tRPC context `../cybernetics-core/apps/backend/src/trpc.ts`, frontend `../cybernetics-core/apps/frontend/lib/auth-client.ts`, login `../cybernetics-core/apps/frontend/app/[locale]/login/page.tsx` |
| **Config / Env** | No `baseUrl`, no live client. Fixed fixtures under `apps/cybercore/assets/cybercore_fixtures/`. | Frontend env `../cybernetics-core/apps/frontend/lib/env.ts`; tRPC client `../cybernetics-core/apps/frontend/lib/trpc.ts`; backend mounts `../cybernetics-core/apps/backend/src/index.ts` (`/trpc`, `/health`, …) |
| **API transport** | None in first wave. | Primary admin UI: **tRPC** at `/trpc` → `frontend.*` via `../cybernetics-core/apps/backend/src/routers/trpc.ts` + `../cybernetics-core/packages/trpc/src/router.ts` |
| **Mutation boundaries** | **Read-only.** UI may toast mock actions; no persist. | Live monorepo has many `.mutation` procedures. **All mutations deferred** for Flutter first wave. |

### Operational State Integration

Loading, error, empty, and degraded state behaviors map to `docs/design/operational-state-vocabulary.md` and Task 1102 pilot state columns.

### Classification legend

| Class | Meaning |
| --- | --- |
| `read-only` | First-wave Flutter consumes fixture only; live equivalent is a query/GET. |
| `mutation-defer` | Live monorepo has write path; Flutter must not call it in first wave. |
| `auth-sensitive` | Live procedure requires session/admin (`adminProcedure`). |
| `pilot-fixture` | Shape follows live pilot JSON under `apps/cybercore/assets/cybercore_fixtures/`. |
| `needs-research` | Material gap between pilot fixture and live Zod/DTO (document, do not invent). |

---

## 2. API Contract & DTO Inventory (pilots A/B/C)

### 2.1 Pilot A — Providers Connections (`/providers`)

Lists and inspects LLM provider connections (active/inactive, test status, auth type). Nested: `/providers/new`, `/providers/[id]`.

| Attribute | Value |
| --- | --- |
| **DTO / read models** | `ProviderConnectionDto` (row); list envelope `ListProviderConnectionsResponse` |
| **Classification** | `read-only`, `pilot-fixture`, live list/get `auth-sensitive`; create/update/delete/test `mutation-defer` |
| **Pilot fixture** | `apps/cybercore/assets/cybercore_fixtures/providers.json` (array of connections) |
| **Live frontend surfaces** | `../cybernetics-core/apps/frontend/app/[locale]/(sidebar)/providers/page.tsx` (`trpc.frontend.llmProviders.list.useQuery({})`); detail `.../providers/[id]/page.tsx`; create form `.../providers/new/page.tsx`; domain tab `../cybernetics-core/apps/frontend/components/admin/control-plane-domain-tabs.tsx` (Providers → Connections → `/providers`) |
| **Live tRPC** | Package router: `../cybernetics-core/packages/trpc/src/routers/frontend/llm-providers.ts` <br> Impl: `../cybernetics-core/apps/backend/src/trpc/llm-providers.impl.ts` <br> **Read (first-wave candidates)**: `frontend.llmProviders.list`, `frontend.llmProviders.get` <br> **Defer**: `create`, `update`, `delete`, `testConnection`, `preflightLegacyRouterBackupImport`, `importLegacyRouterBackup`, combo/alias/endpoint-mode mutations, `syncModelCatalog` |
| **Live Zod** | `../cybernetics-core/packages/zod-types/src/llm-providers.zod.ts` <br> • `ProviderConnectionSchema` (~L831): `id`, `provider`, `name`, `authType` (`apikey`\|`oauth`\|`cookie`), `priority`, `globalPriority?`, `defaultModel?`, `isActive`, `testStatus?` (`success`\|`error`\|`unknown`), `lastTested?`, `lastError?`, `lastErrorAt?`, `errorCode?`, `providerSpecificData?`, `createdAt?`, `updatedAt?` <br> • `ListProviderConnectionsResponseSchema`: `{ connections: ProviderConnection[], providerPresets: ProviderPreset[], message? }` <br> • `GetProviderConnectionResponseSchema`: `{ success, connection?, message? }` |
| **Pilot fixture fields** | Matches connection row: `id`, `provider`, `name`, `authType`, `priority`, `globalPriority`, `defaultModel`, `isActive`, `testStatus`, `lastTested`, `lastError`, `lastErrorAt`, `errorCode`, `createdAt`, `updatedAt` |
| **Live field parity** | **Strong** for connection row fields used in the list table. List envelope in live API also returns `providerPresets[]` — **not** in `providers.json` (optional Wave-2; or load as separate fixture later). Secrets / `providerSpecificData` credentials **must remain redacted or absent** in fixtures. |
| **State contracts** | **Loading**: table/skeleton. **Empty**: no connections. **Error**: list query failure. **Degraded**: row `testStatus=error` or `isActive=false` with lastError. Nested new/detail: form fixture read-only (no create/update). |
| **Mutations (defer)** | `llmProviders.create\|update\|delete\|testConnection\|importLegacyRouterBackup\|…` |

---

### 2.2 Pilot B — MCP Servers (`/mcp-servers`, `/mcp-servers/[uuid]`)

Installed MCP server catalog + detail.

| Attribute | Value |
| --- | --- |
| **DTO / read models** | `McpServerDto`; list/get envelopes `ListMcpServersResponse` / `GetMcpServerResponse` |
| **Classification** | `read-only`, `pilot-fixture`, live list/get `auth-sensitive`; create/update/delete/import `mutation-defer` |
| **Pilot fixture** | `apps/cybercore/assets/cybercore_fixtures/mcp_servers.json` (array) |
| **Live frontend surfaces** | `../cybernetics-core/apps/frontend/app/[locale]/(sidebar)/mcp-servers/page.tsx` (`trpc.frontend.mcpServers.list.useQuery()`); detail `.../mcp-servers/[uuid]/page.tsx`; list UI `.../mcp-servers/mcp-servers-list.tsx` |
| **Live tRPC** | Package router: `../cybernetics-core/packages/trpc/src/routers/frontend/mcp-servers.ts` <br> Impl: `../cybernetics-core/apps/backend/src/trpc/mcp-servers.impl.ts` <br> **Read**: `frontend.mcpServers.list`, `frontend.mcpServers.get`, `frontend.mcpServers.exportConfig` (export is read-ish but may surface secrets — treat carefully / redacted fixtures) <br> **Defer**: `create`, `update`, `delete`, `bulkImport`, `preflightImport` |
| **Live Zod** | `../cybernetics-core/packages/zod-types/src/mcp-servers.zod.ts` <br> • Enums: `McpServerTypeEnum` `STDIO`\|`SSE`\|`STREAMABLE_HTTP`; `McpServerStatusEnum` `ACTIVE`\|`INACTIVE`; `McpServerErrorStatusEnum` `NONE`\|`ERROR` <br> • `McpServerSchema` (~L180): `uuid`, `name`, `description`, `type`, `command`, `args`, `env`, `url`, `created_at`, `bearerToken`, `headers`, `user_id`, `error_status?` <br> • `ListMcpServersResponseSchema`: `{ success, data: McpServer[], message? }` <br> • `GetMcpServerResponseSchema`: `{ success, data?, message? }` |
| **Pilot fixture fields** | `uuid`, `name`, `description`, `type`, `command`, `args`, `env` (secrets redacted as `***REDACTED***`), `url`, `created_at`, `bearerToken` (redacted/null), `headers`, `user_id`, `error_status`, **`status`** (`ACTIVE`\|`INACTIVE`) |
| **Live field parity** | **Strong** on core `McpServerSchema` fields. Pilot fixture includes **`status`** matching `McpServerStatusEnum` — **not currently a property on `McpServerSchema`** (enum exists; schema exposes `error_status` only). Label **`needs-research`** for live 1:1 status field presence on list DTO. Secrets in `env`/`bearerToken` must stay redacted in fixtures. |
| **State contracts** | **Loading**: list skeleton. **Empty**: no servers. **Error**: list failure. **Degraded**: `error_status=ERROR` or fixture `status=INACTIVE`. Detail: same DTO by `uuid`. |
| **Mutations (defer)** | `mcpServers.create\|update\|delete\|bulkImport\|preflightImport` |

---

### 2.3 Pilot B — MCP Inspector (`/mcp-inspector`)

Inspector surface: select server, show connection status + tool list. **No live STDIO execution** in Warp Prism pilot.

| Attribute | Value |
| --- | --- |
| **DTO / read models** | `McpInspectorSnapshotDto` (pilot composite): connection status + selected server + tools[] |
| **Classification** | `read-only`, `pilot-fixture`; live server list `auth-sensitive`; live tool registry query `read-only`+`auth-sensitive`; live connect/execute **unsafe / defer** (no STDIO in WP) |
| **Pilot fixture** | `apps/cybercore/assets/cybercore_fixtures/mcp_inspector.json` |
| **Live frontend surfaces** | `../cybernetics-core/apps/frontend/app/[locale]/(sidebar)/mcp-inspector/page.tsx` — loads `trpc.frontend.mcpServers.list.useQuery()` then `useConnection({…})` from `../cybernetics-core/apps/frontend/hooks/useConnection.ts` for live MCP session (`connectionStatus`, `connect`/`disconnect`/`makeRequest`, `serverCapabilities`) |
| **Live tRPC (data plane)** | Server catalog: same as §2.2 (`frontend.mcpServers.list`) <br> Tools registry (DB-backed, not live protocol): `../cybernetics-core/packages/trpc/src/routers/frontend/tools.ts` + impl `../cybernetics-core/apps/backend/src/trpc/tools.impl.ts` → `frontend.tools.getByMcpServerUuid` <br> Zod: `../cybernetics-core/packages/zod-types/src/tools.zod.ts` — `ToolSchema` (`uuid`, `name`, `title?`, `description`, `toolSchema`, `created_at`, `updated_at`, `mcp_server_uuid`); response `GetToolsByMcpServerUuidResponseSchema` |
| **Live connection state (not tRPC)** | `useConnection` statuses include at least `disconnected` / `connecting` / `connected` (+ error UI paths). Protocol `makeRequest` is **live client-side MCP** — **forbidden** for first-wave Flutter (fixture snapshot only). |
| **Pilot fixture fields** | `connectionStatus` (e.g. `connected`), `selectedServerUuid`, `selectedServerName`, `tools[]` `{ uuid, name, description, enabled, mcp_server_uuid }`, `notes` |
| **Live field parity** | **Partial.** Tools in live Zod require `toolSchema` + timestamps; pilot tools are a **simplified** list with pilot-only `enabled` flag. Connection status is **client hook state**, not a Zod response type. Label tool-row simplification + `enabled` as **pilot-fixture** (acceptable for mirror); full `ToolSchema` parity **needs-research** if Wave-2 maps DB tools 1:1. |
| **State contracts** | **Loading**: server picker + tools skeleton. **Empty**: no tools for selection. **Error**: connection error status. **Degraded**: disconnected / connecting with partial tool list. |
| **Mutations / unsafe (defer)** | Live `connect`/`disconnect`/`makeRequest`; `tools.create`/`tools.sync`; any STDIO spawn. |

---

### 2.4 Pilot C — Live Logs (`/live-logs`)

Operational log console + optional provider health strip (live page also queries providers list).

| Attribute | Value |
| --- | --- |
| **DTO / read models** | `GetLogsResponse` / `cyberneticscoreLogEntry`; optional health strip reuses `ProviderConnectionDto` list |
| **Classification** | `read-only`, `pilot-fixture`, live get `auth-sensitive`; clear `mutation-defer` |
| **Pilot fixture** | `apps/cybercore/assets/cybercore_fixtures/live_logs.json` |
| **Live frontend surfaces** | `../cybernetics-core/apps/frontend/app/[locale]/(sidebar)/live-logs/page.tsx` — `useLogsStore` + `trpc.frontend.llmProviders.list.useQuery({})` for health strip; store `../cybernetics-core/apps/frontend/lib/stores/logs-store.ts` (`vanillaTrpcClient.frontend.logs.get.query({ limit: 500 })`) |
| **Live tRPC** | Package router: `../cybernetics-core/packages/trpc/src/routers/frontend/logs.ts` <br> Impl: `../cybernetics-core/apps/backend/src/trpc/logs.impl.ts` <br> Log store helper: `../cybernetics-core/apps/backend/src/lib/cyberneticscore/log-store.ts` <br> **Read**: `frontend.logs.get` <br> **Defer**: `frontend.logs.clear` |
| **Live Zod** | `../cybernetics-core/packages/zod-types/src/logs.zod.ts` <br> • `cyberneticscoreLogEntrySchema`: `id`, `timestamp` (`z.date()`), `serverName`, `level` (`error`\|`info`\|`warn`), `message`, `error?` <br> • `GetLogsRequestSchema`: `{ limit? }` (positive int, max 1000) <br> • `GetLogsResponseSchema`: `{ success: true, data: entry[], totalCount: number }` |
| **Pilot fixture fields** | Envelope `{ success, totalCount, data[] }`; entry: `id`, `timestamp` (ISO-8601 **string**), `serverName`, `level`, `message`, `error`, **`redacted`** (boolean) |
| **Live field parity** | **Strong** on envelope + core entry fields. Serialization: pilot uses ISO strings (JSON); live Zod uses `z.date()` (runtime Date). Pilot adds **`redacted`** for Pilot C redaction demo — **not** on `cyberneticscoreLogEntrySchema` → label pilot extension / **needs-research** if live API must carry redaction flags. Health strip providers come from Pilot A fixture/list, not `live_logs.json`. |
| **State contracts** | **Loading**: console skeleton. **Empty**: zero logs / totalCount 0. **Error**: fetch failure toast paths. **Degraded**: mixed error-level rows; redacted rows show scrubbed message content. |
| **Mutations (defer)** | `frontend.logs.clear` |

---

## 3. Mutation Boundary Declaration

All first-wave Flutter read models above are **read-only**.

| Boundary | Rule |
| --- | --- |
| **Allowed (Wave 1)** | Load fixed fixtures; render loading/empty/error/degraded UI; no network I/O. |
| **Mock-only UX** | POST/PUT/DELETE/PATCH *affordance* may show a toast; **must not** persist local or remote state. |
| **Deferred (Wave 2+)** | Any live tRPC `.mutation`, MCP connect/execute, logs clear, OAuth upsert, API key create/delete, MCP bulk import, config setters. Require auth + explicit safety/gateway task. |
| **Auth-sensitive reads** | Live admin queries (`adminProcedure`) require session; Flutter first wave must not depend on them. |
| **Unsafe** | Live MCP STDIO / `useConnection.makeRequest` — never in Warp Prism pilot. |

### Live tRPC frontend surface inventory (pilot-relevant + context)

Mounted under `/trpc` → `frontend.*` (`../cybernetics-core/apps/backend/src/routers/trpc.ts`):

| Router key | Package router path | Impl path | Pilot use |
| --- | --- | --- | --- |
| `llmProviders` | `packages/trpc/src/routers/frontend/llm-providers.ts` | `apps/backend/src/trpc/llm-providers.impl.ts` | **A** (+ C health strip) |
| `mcpServers` | `.../mcp-servers.ts` | `.../mcp-servers.impl.ts` | **B** |
| `tools` | `.../tools.ts` | `.../tools.impl.ts` | **B** inspector tools (optional parity) |
| `logs` | `.../logs.ts` | `.../logs.impl.ts` | **C** |
| `namespaces` / `endpoints` / `oauth` / `apiKeys` / `config` | respective routers | respective impls | **defer** (not first-wave pilots) |

Paths above are under `../cybernetics-core/`.

### Supplemental REST mounts (context only — not pilot spine)

From `apps/backend/src/index.ts`: `/trpc`, `/api/costs`, `/api/discovery`, `/api/workflows`, `/api/profiles`, `/api/hooks`, `/service`, `/health`, `/cyberneticscore`. First-wave pilots do **not** require these mounts.

---

## 4. Contract summary matrix

| Pilot | Route(s) | Pilot DTO / fixture | Live source paths cited? | Live 1:1 field match? | First-wave class |
| --- | --- | --- | --- | --- | --- |
| **A** | `/providers` (+ nested) | `ProviderConnectionDto` / `providers.json` | Yes — llmProviders tRPC + Zod + providers pages | Strong (presets envelope optional) | read-only + pilot-fixture; mutations defer |
| **B** | `/mcp-servers`, `/mcp-servers/[uuid]` | `McpServerDto` / `mcp_servers.json` | Yes — mcpServers tRPC + Zod + pages | Strong core; `status` field **needs-research** | read-only + pilot-fixture; mutations defer |
| **B** | `/mcp-inspector` | `McpInspectorSnapshotDto` / `mcp_inspector.json` | Yes — mcp-inspector page + useConnection + tools tRPC/Zod | Partial (simplified tools; no live STDIO) | read-only fixture; connect/execute defer |
| **C** | `/live-logs` | `GetLogsResponse` / `live_logs.json` | Yes — logs tRPC + Zod + live-logs page + logs-store | Strong core; `redacted` pilot extension | read-only + pilot-fixture; clear defer |

---

## 5. Fixture linkage

Fixed fixture JSON schemas for the pilot DTOs live in:

- `docs/design/cybercore-fixture-schema.md`

Live files:

- `apps/cybercore/assets/cybercore_fixtures/providers.json`
- `apps/cybercore/assets/cybercore_fixtures/mcp_servers.json`
- `apps/cybercore/assets/cybercore_fixtures/mcp_inspector.json`
- `apps/cybercore/assets/cybercore_fixtures/live_logs.json`

No live API client code is authorized by this inventory.

---

## Appendix A — Superseded Observatory-proxy paths (not MVP)

| Path | Origin | Status |
| --- | --- | --- |
| `/dashboard` | Observatory proxy / historical Flutter | **Not** live CC; **not** 1108 pilot |
| `/registry` | Observatory Map proxy | **Not** live CC; **not** 1108 pilot |
| `/tasks` | Observatory Operate proxy | **Rejected** as CC pilot (1102 F6 / 1108 §2.4) |
| `/audit` | Observatory History proxy | **Not** live CC; **not** 1108 pilot |
| `/governance` | Observatory Governance proxy | **Not** live CC; **not** 1108 pilot |

Do **not** treat these as Task 1109 inventory spine. ASW mock workspace aggregates (`DashboardSummary`, agent/skill/task board DTOs) are **retired** from this inventory.
