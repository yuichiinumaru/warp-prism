# CyberCore Fixture Schema

> **Task**: 1109  
> **Date**: 2026-07-09 (path-to-100 rewrite — live pilot JSON)  
> **Prior draft**: 2026-06-08 (ASW Dashboard/Registry/Task Board schemas — **superseded**)  
> **Status**: Active  
> **Location**: `apps/cybercore/assets/cybercore_fixtures/`

This document defines the JSON shapes for the **live** fixed mock fixtures that power Task 1108 first-wave CyberCore Flutter pilots **A/B/C**.

## Source authority

| Layer | Path | Role |
| --- | --- | --- |
| **Live pilot fixtures (this file)** | `apps/cybercore/assets/cybercore_fixtures/*.json` | First-wave only data plane |
| **Contract inventory + live monorepo citations** | `docs/design/cybercore-api-contract-inventory.md` | Maps each DTO to `../cybernetics-core/` tRPC/Zod |
| **Route authority** | `docs/design/cybercore-scope-route-parity.md` §3 | Pilots A/B/C only |
| **Live monorepo root (hyphenated)** | `../cybernetics-core/` | Real backend/frontend; **not** `../cyberneticscore/` (absent) |
| **Live Zod contracts (parity)** | `../cybernetics-core/packages/zod-types/src/{llm-providers,mcp-servers,tools,logs}.zod.ts` | Target shapes for later live clients |

Pilot schemas below are derived from **actual fixture files** on disk, cross-checked against live Zod. Residual gaps are labeled `needs-research` in the inventory (not invented endpoints).

### Fixture file map

| Pilot | Route(s) | File |
| --- | --- | --- |
| **A** | `/providers` (+ nested) | `providers.json` |
| **B** | `/mcp-servers`, `/mcp-servers/[uuid]` | `mcp_servers.json` |
| **B** | `/mcp-inspector` | `mcp_inspector.json` |
| **C** | `/live-logs` | `live_logs.json` |

### Superseded (do not use as pilot fixtures)

Historical ASW schemas are **retired**: `dashboard_summary.json`, `registry_agents.json`, `registry_skills.json`, `registry_workflows.json`, `task_board.json`, `audit_trail.json`, `governance_diagnostics.json`. They are not present under `apps/cybercore/assets/cybercore_fixtures/` and must not be cited as first-wave CyberCore pilot data.

---

## 1. Providers Fixture Schema (Pilot A)

**File**: `apps/cybercore/assets/cybercore_fixtures/providers.json`  
**Live Zod**: `ProviderConnectionSchema` in `../cybernetics-core/packages/zod-types/src/llm-providers.zod.ts` (~L831)  
**Live query**: `trpc.frontend.llmProviders.list` → `ListProviderConnectionsResponseSchema` (`connections[]` + `providerPresets[]`)

Root type: **array** of connection objects (fixture omits `providerPresets` envelope).

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "ProviderConnectionList",
  "type": "array",
  "items": {
    "type": "object",
    "properties": {
      "id": { "type": "string" },
      "provider": { "type": "string" },
      "name": { "type": "string" },
      "authType": { "type": "string", "enum": ["apikey", "oauth", "cookie"] },
      "priority": { "type": "integer" },
      "globalPriority": { "type": ["integer", "null"] },
      "defaultModel": { "type": ["string", "null"] },
      "isActive": { "type": "boolean" },
      "testStatus": {
        "type": "string",
        "enum": ["success", "error", "unknown"]
      },
      "lastTested": { "type": ["string", "null"], "format": "date-time" },
      "lastError": { "type": ["string", "null"] },
      "lastErrorAt": { "type": ["string", "null"], "format": "date-time" },
      "errorCode": { "type": ["string", "null"] },
      "createdAt": { "type": "string", "format": "date-time" },
      "updatedAt": { "type": "string", "format": "date-time" }
    },
    "required": [
      "id",
      "provider",
      "name",
      "authType",
      "priority",
      "isActive",
      "testStatus"
    ]
  }
}
```

**Example row** (from live fixture):

```json
{
  "id": "prov-openai-prod",
  "provider": "openai",
  "name": "OpenAI Production",
  "authType": "apikey",
  "priority": 1,
  "globalPriority": 10,
  "defaultModel": "gpt-4o",
  "isActive": true,
  "testStatus": "success",
  "lastTested": "2026-07-09T10:15:00Z",
  "lastError": null,
  "lastErrorAt": null,
  "errorCode": null,
  "createdAt": "2026-05-01T12:00:00Z",
  "updatedAt": "2026-07-09T10:15:00Z"
}
```

**Notes**

- Do not include API keys or OAuth tokens in fixtures.
- Live list also returns `providerPresets[]` — out of scope for this file unless a later task adds `provider_presets.json`.

---

## 2. MCP Servers Fixture Schema (Pilot B list/detail)

**File**: `apps/cybercore/assets/cybercore_fixtures/mcp_servers.json`  
**Live Zod**: `McpServerSchema` in `../cybernetics-core/packages/zod-types/src/mcp-servers.zod.ts` (~L180)  
**Live query**: `trpc.frontend.mcpServers.list` / `.get`

Root type: **array** of server objects.

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "McpServerList",
  "type": "array",
  "items": {
    "type": "object",
    "properties": {
      "uuid": { "type": "string" },
      "name": { "type": "string" },
      "description": { "type": ["string", "null"] },
      "type": {
        "type": "string",
        "enum": ["STDIO", "SSE", "STREAMABLE_HTTP"]
      },
      "command": { "type": ["string", "null"] },
      "args": { "type": "array", "items": { "type": "string" } },
      "env": {
        "type": "object",
        "additionalProperties": { "type": "string" }
      },
      "url": { "type": ["string", "null"] },
      "created_at": { "type": "string", "format": "date-time" },
      "bearerToken": { "type": ["string", "null"] },
      "headers": {
        "type": "object",
        "additionalProperties": { "type": "string" }
      },
      "user_id": { "type": ["string", "null"] },
      "error_status": { "type": "string", "enum": ["NONE", "ERROR"] },
      "status": {
        "type": "string",
        "enum": ["ACTIVE", "INACTIVE"],
        "description": "Pilot field aligned to McpServerStatusEnum; not currently on McpServerSchema — needs-research for live 1:1"
      }
    },
    "required": [
      "uuid",
      "name",
      "type",
      "args",
      "env",
      "created_at",
      "headers",
      "error_status",
      "status"
    ]
  }
}
```

**Example row** (from live fixture):

```json
{
  "uuid": "mcp-filesystem-01",
  "name": "filesystem",
  "description": "Local filesystem access for workspace roots",
  "type": "STDIO",
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-filesystem", "/workspace"],
  "env": {},
  "url": null,
  "created_at": "2026-05-12T10:00:00Z",
  "bearerToken": null,
  "headers": {},
  "user_id": null,
  "error_status": "NONE",
  "status": "ACTIVE"
}
```

**Notes**

- Secret-like values in `env` / `bearerToken` must use `***REDACTED***` or null.
- Detail route `/mcp-servers/:uuid` selects one row by `uuid` from the same array.

---

## 3. MCP Inspector Fixture Schema (Pilot B inspector)

**File**: `apps/cybercore/assets/cybercore_fixtures/mcp_inspector.json`  
**Live sources**:  
- Server picker: `trpc.frontend.mcpServers.list`  
- Tools (optional DB parity): `ToolSchema` / `frontend.tools.getByMcpServerUuid` in `tools.zod.ts`  
- Connection status: client hook `useConnection` (`../cybernetics-core/apps/frontend/hooks/useConnection.ts`) — **not** a tRPC DTO  

Root type: **object** (pilot composite snapshot; no live STDIO).

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "McpInspectorSnapshot",
  "type": "object",
  "properties": {
    "connectionStatus": {
      "type": "string",
      "enum": ["disconnected", "connecting", "connected", "error"]
    },
    "selectedServerUuid": { "type": "string" },
    "selectedServerName": { "type": "string" },
    "tools": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "uuid": { "type": "string" },
          "name": { "type": "string" },
          "description": { "type": ["string", "null"] },
          "enabled": {
            "type": "boolean",
            "description": "Pilot-only affordance; live ToolSchema has no enabled flag"
          },
          "mcp_server_uuid": { "type": "string" }
        },
        "required": ["uuid", "name", "enabled", "mcp_server_uuid"]
      }
    },
    "notes": { "type": "string" }
  },
  "required": [
    "connectionStatus",
    "selectedServerUuid",
    "selectedServerName",
    "tools"
  ]
}
```

**Example** (from live fixture):

```json
{
  "connectionStatus": "connected",
  "selectedServerUuid": "mcp-filesystem-01",
  "selectedServerName": "filesystem",
  "tools": [
    {
      "uuid": "tool-list-dir",
      "name": "list_directory",
      "description": "List files and folders under a path",
      "enabled": true,
      "mcp_server_uuid": "mcp-filesystem-01"
    }
  ],
  "notes": "Fixture-backed inspector — no live STDIO execution in Warp Prism pilot"
}
```

**Notes**

- Full live `ToolSchema` also requires `toolSchema`, `created_at`, `updated_at` — omitted in pilot for simplicity (`needs-research` if 1:1 mapping required).
- Never execute tools or open STDIO from Flutter pilot screens.

---

## 4. Live Logs Fixture Schema (Pilot C)

**File**: `apps/cybercore/assets/cybercore_fixtures/live_logs.json`  
**Live Zod**: `GetLogsResponseSchema` / `cyberneticscoreLogEntrySchema` in `../cybernetics-core/packages/zod-types/src/logs.zod.ts`  
**Live query**: `trpc.frontend.logs.get` via `logs-store.ts`

Root type: **object** matching the get-logs response envelope.

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "GetLogsResponse",
  "type": "object",
  "properties": {
    "success": { "type": "boolean", "const": true },
    "totalCount": { "type": "integer", "minimum": 0 },
    "data": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "id": { "type": "string" },
          "timestamp": {
            "type": "string",
            "format": "date-time",
            "description": "ISO-8601 string in fixture JSON; live Zod uses z.date()"
          },
          "serverName": { "type": "string" },
          "level": { "type": "string", "enum": ["error", "info", "warn"] },
          "message": { "type": "string" },
          "error": { "type": ["string", "null"] },
          "redacted": {
            "type": "boolean",
            "description": "Pilot extension for redaction UI; not on cyberneticscoreLogEntrySchema"
          }
        },
        "required": ["id", "timestamp", "serverName", "level", "message"]
      }
    }
  },
  "required": ["success", "totalCount", "data"]
}
```

**Example entry** (from live fixture):

```json
{
  "id": "log-003",
  "timestamp": "2026-07-09T11:58:30.000Z",
  "serverName": "postgres",
  "level": "error",
  "message": "Query failed: connection refused",
  "error": "ECONNREFUSED 127.0.0.1:5432",
  "redacted": false
}
```

**Notes**

- Provider health strip on the live page uses `llmProviders.list` — reuse Pilot A `providers.json`, not a second copy inside this file.
- `frontend.logs.clear` is mutation-defer; fixture mode never clears remote state.

---

## 5. Loading / empty / error / degraded (fixture consumers)

| Fixture | Loading | Empty | Error | Degraded |
| --- | --- | --- | --- | --- |
| `providers.json` | Table skeleton | `[]` | Asset load/parse failure | Rows with `testStatus=error` or `isActive=false` |
| `mcp_servers.json` | List skeleton | `[]` | Asset load/parse failure | `error_status=ERROR` or `status=INACTIVE` |
| `mcp_inspector.json` | Tools skeleton | `tools: []` | Invalid snapshot / missing server uuid | `connectionStatus` in `error` / `disconnected` |
| `live_logs.json` | Console skeleton | `data: []`, `totalCount: 0` | Asset load/parse failure | `level=error` rows; `redacted=true` rows |

Operational vocabulary: `docs/design/operational-state-vocabulary.md`.

---

## 6. Linkage

- Inventory (procedures, mutations, citations): `docs/design/cybercore-api-contract-inventory.md`
- Route parity (pilot selection): `docs/design/cybercore-scope-route-parity.md`
- No live API client code is authorized by this schema document.
