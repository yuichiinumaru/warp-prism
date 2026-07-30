# Review Report: Task 1109 — CyberCore API Data Contract Inventory — Independent Re-review 2026-07-09

## Review Lineage

- **Current task**: Task 1109 (`warp-prism-cybercore-api-data-contract-inventory`); live path at review start: `docs/tasks/03-review/1109-warp-prism-cybercore-api-data-contract-inventory.md`
- **Previous reports read**:
  - Wave promote note — **100** (file existence + monorepo citation presence only)
  - `docs/reports/build-gate-review/1109-review.md` — historical
- **Related reports / surfaces**:
  - Task 1108 deliverable `docs/design/cybercore-scope-route-parity.md` — **current** MVP pilots A/B/C
  - Live `apps/cybercore/assets/cybercore_fixtures/{providers,mcp_servers,live_logs,mcp_inspector}.json`
  - Task 1110 route realign (router already A/B/C)
- **Review mode**: `re-review` (independent; **contract accuracy vs 1108**, not file-presence only)
- **Reviewer wave**: review-wave-2026-07-09

## Score And Verdict

- **Score**: `58/100` — **Debt / Serious contract drift**
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Scoring Rationale

| Dimension | Points | Notes |
| --- | ---: | --- |
| Inventory + fixture schema files exist | 12/15 | Present (224 / 253 lines) |
| Cite live monorepo paths | 12/15 | Hyphenated paths real; many citations OK under wrong route keys |
| Mutation / read-only boundaries | 10/10 | Explicit defer of mutations |
| No live API client in this task | 8/8 | No http/dio client authored by 1109 |
| **Cover 1108 MVP/pilot routes only** | **0/20** | **FAIL** — still `/dashboard|/registry|/tasks|/audit|/governance` |
| Fixture schemas usable for pilot A/B/C | **0/15** | Schemas ASW dashboard/registry/task/audit; live fixtures are providers/MCP/logs |
| Changelog + completion evidence honesty | 8/10 | Entry exists but still describes 5 Observatory MVP screens |
| Dep 1108 / exit honesty | 8/7 | Dep lane text stale; wave promote overscored file existence |
| **Total** | **58/100** | |

## Delta Summary

### Resolved Since Citation Remediation

- `RESOLVED` (partial): Monorepo spelling `cybernetics-core` (hyphen) correct; many backend/frontend/tRPC/Zod paths exist on disk.
- `RESOLVED` (partial): Mutation-defer + read-only first-wave language present.
- `RESOLVED` (partial): No Flutter API client introduced by this task.

### Regressions / Persistent Contract Failure

- `REGRESSION` / `PERSISTENT` vs Task 1108 post-1102 rewrite: inventory header still claims **“5 MVP Routes defined in Task 1108”** and inventories Observatory-proxy spine. Live 1108 §3 first-wave MVP is:
  1. `/providers` (+ nested)
  2. `/mcp-servers`, `/mcp-servers/[uuid]`, `/mcp-inspector`
  3. `/live-logs`
- `REGRESSION` vs live product: `apps/cybercore` fixtures are `providers.json`, `mcp_servers.json`, `live_logs.json`, `mcp_inspector.json` with provider/MCP/log fields — **not** `DashboardSummary` / ASW agent-skill-task schemas in `cybercore-fixture-schema.md`.
- Prior wave score **100** is **SUPERSEDED** as over-acceptance of file existence without 1108 alignment check.

### New Findings

- `NEW` F1: Route spine mismatch (critical contract).
- `NEW` F2: Fixture schema domain mismatch vs live pilot fixtures.
- `NEW` F3: Changelog body still documents five Observatory screens as MVP pilots.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | REGRESSION / PERSISTENT | **High** | Open | Inventory route keys are Observatory-proxy, not 1108 pilots A/B/C | This re-review (drift after 1108 realign) | `cybercore-api-contract-inventory.md` §2.1–2.5 `/dashboard`…`/governance`; 1108 §3 pilots `/providers`… |
| F2 | REGRESSION | **High** | Open | Fixture schema defines ASW dashboard/registry/task board; live fixtures are provider/MCP/log | This re-review | `cybercore-fixture-schema.md` §§1–3 vs `apps/cybercore/assets/cybercore_fixtures/*.json` |
| F3 | NEW | Medium | Open | Changelog/summary still “5 MVP screens (Dashboard, Registry, …)” | This re-review | `docs/changelog/20260608-184953-1109-…` |
| F4 | PERSISTENT | Low | External/process | Changelog engine validate residual | prior | `.changelog` empty vs `docs/changelog` |
| F5 | SUPERSEDED | — | Prior false green | Wave promote 100 on presence-only | 2026-07-09 wave | superseded by this report |

## Exit Conditions (live)

| # | Condition | Met? | Live proof |
| --- | --- | --- | --- |
| 1 | `cybercore-api-contract-inventory.md` exists | **YES** | 224 lines |
| 2 | `cybercore-fixture-schema.md` exists | **YES** | 253 lines |
| 3 | Cites live monorepo for each data contract | **PARTIAL** | Paths real but bound to wrong MVP routes |
| 4 | Mutation boundaries read-only | **YES** | §3 |
| 5 | No Flutter API client by this task | **YES** | docs-only scope |
| 6 | Local changelog | **YES** (content stale) | engine file present |
| 7 | Completion Evidence | **YES** (understates F1/F2) | citation pass only |
| **Test req**: cover only 1108 MVP/pilot/needs-research routes | **NO** | Wrong spine |
| **Test req**: fixture schemas for 1110/1111 pilots | **NO** vs live A/B/C fixtures | |

## Evidence Reviewed

```text
# 1108 MVP (authority)
docs/design/cybercore-scope-route-parity.md §3:
  /providers, /mcp-servers+/mcp-inspector, /live-logs

# 1109 inventory spine
rg "/dashboard|/registry|/tasks|/audit|/governance" → 13 matches
rg "/providers|/mcp-servers|/live-logs" → 6 matches (only as nearest-live under wrong keys)

# Live fixtures (apps/cybercore)
providers.json     → id, provider, name, authType, isActive, testStatus, …
mcp_servers.json   → uuid, name, type, command, …
live_logs.json     → success, totalCount, data
mcp_inspector.json → connectionStatus, tools, …

# 1109 fixture schema titles
§1 DashboardSummary, §2 Registry, §3 Task Board — ASW mock shapes

# Cited monorepo paths exist (examples)
OK llm-providers.impl.ts, mcp-servers tRPC, logs tRPC/Zod
```

## Path To 100

1. **Rewrite inventory spine** to Task 1108 first-wave routes only:
   - `/providers` (+ nested) → ProviderConnection / list DTO from live Zod + tRPC `llmProviders.*`
   - `/mcp-servers` (+ detail) → `McpServerSchema` + list/query
   - `/mcp-inspector` → connection/tools read models (no live STDIO)
   - `/live-logs` → `GetLogsResponse` / log entry Zod
   - Optionally one short appendix for **superseded** Observatory-proxy mapping (do not claim as MVP).
2. **Rewrite `cybercore-fixture-schema.md`** to match live fixture files:
   - `providers.json`, `mcp_servers.json`, `live_logs.json`, `mcp_inspector.json`
   - Field lists from fixtures + Zod, not ASW agents/skills/task lanes.
3. Label residual field gaps `needs-research` only where live 1:1 still incomplete — do not invent endpoints.
4. Refresh Completion Evidence + changelog note (new entry or amend note) so “5 Observatory MVP screens” language is retired.
5. Re-run validation commands in task; keep mutation-defer + fixture-backed first-wave.
6. Return to `03-review/` only after independent re-check that inventory route set ⊆ 1108 pilot/MVP set.

## Task Ledger Patch Suggestion

```markdown
### Latest Review
- Date: 2026-07-09
- Score: 58/100
- Verdict: REJECTED_TO_DOING
- Full report: docs/reports/review-wave-2026-07-09/task-1109-cybercore-api-data-contract-inventory-independent-rereview.md
- Lane: returned to 02-doing
- Top blockers: F1 route spine vs 1108; F2 fixture schema vs live pilot fixtures
```

## Lane Recommendation

**Move** Task 1109 from `docs/tasks/03-review/` → `docs/tasks/02-doing/`. Do **not** patch to 100 in-reviewer (S<90). Do **not** promote to `04-completed/`.
