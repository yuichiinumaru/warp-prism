---
date: 20260710-011544
timestamp: 20260710-011544
project: "warp-prism"
agent: docs-fixer
task: "1109"
description: "Path-to-100 rewrite: inventory + fixture schema realigned to Task 1108 pilots A/B/C (providers, MCP, live-logs)."
is_rebuild_safe: true
---

# Task 1109: CyberCore API Contracts — Pilot A/B/C Path-to-100

## Summary

Retires Observatory-proxy MVP language (`/dashboard`, `/registry`, `/tasks`, `/audit`, `/governance`) from the Task 1109 deliverables. Inventory spine and fixture schemas now match Task 1108 first-wave pilots only:

1. **Pilot A** — `/providers` (+ nested) → `providers.json` / `ProviderConnectionSchema` + `frontend.llmProviders.list|get`
2. **Pilot B** — `/mcp-servers`, `/mcp-servers/[uuid]`, `/mcp-inspector` → `mcp_servers.json`, `mcp_inspector.json` / `McpServerSchema` + tools + `useConnection` (no STDIO)
3. **Pilot C** — `/live-logs` → `live_logs.json` / `GetLogsResponseSchema` + `frontend.logs.get`

## Changes

- Rewrote `docs/design/cybercore-api-contract-inventory.md` (pilots A/B/C + live tRPC/Zod citations; Observatory paths demoted to Appendix A).
- Rewrote `docs/design/cybercore-fixture-schema.md` to match live `apps/cybercore/assets/cybercore_fixtures/{providers,mcp_servers,mcp_inspector,live_logs}.json`.
- Historical engine entry `docs/changelog/20260608-184953-1109-cybercore-api-contracts-builders.md` body remains as historical record; **this entry supersedes** its “5 MVP pilot screens (Dashboard, Registry, …)” summary for product authority.

## Verification

- [x] Inventory route set ⊆ 1108 pilots A/B/C
- [x] Fixture schema files match live pilot JSON
- [x] Live monorepo path citations present for each pilot contract
- [x] Mutation boundaries remain read-only / deferred
- [x] No Flutter API client introduced by this pass
