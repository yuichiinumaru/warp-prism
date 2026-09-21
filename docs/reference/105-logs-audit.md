# Feature Catalog: Logs & Audit

> **Series**: 105
> **Source**: diegosouza-omniroute sidebar + cybernetics-core + OmniRoute analysis
> **Purpose**: Sidebar-discoverable features from reference repos
> **Total Features**: 14

## Logs

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 105-001 | Structured Logger | log/slog JSON/text | — | — | ✅ 849 |
| 105-002 | Log Rotation | 50MB max, 7-day retention, 20 backups | diegosouza-omniroute | `src/lib/logRotation.ts` | ❌ GAP |
| 105-003 | Proxy Logger | Request/response logging | diegosouza-omniroute | `src/lib/proxyLogger.ts` | ✅ 849 |
| 105-004 | Detailed Call Logs | Per-request pipeline capture + artifacts | diegosouza-omniroute | `src/lib/db/detailedLogs.ts` | ❌ GAP |

## Audit

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 105-005 | Audit Event Store | Append-only Postgres | — | — | ✅ 820-829 |
| 105-006 | Audit Retention Policy | Documented and enforced | — | — | ✅ 82A |
| 105-007 | Config Audit | Audit configuration changes | diegosouza-omniroute | `src/domain/configAudit.ts` | ❌ GAP |

## MCP Audit

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 105-008 | MCP Tool Audit | Every tool invocation logged | diegosouza-omniroute | `open-sse/mcp-server/audit.ts` | ✅ 956 |
| 105-009 | Tool Call Audit Middleware | Tool name, namespace, session, redacted input | cybernetics-core | `cyberneticscore-proxy.ts` | ✅ 956 |
| 105-010 | MCP Governance Audit | Risk classification, secret redaction, SHA-256 hashing | cybernetics-core | `mcp-governance.ts` | ❌ GAP (024-001) |

## A2A Audit

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 105-011 | A2A Audit | Audit trail for Agent-to-Agent interactions | diegosouza-omniroute | UI | ❌ GAP (022-010) |

## Compliance

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 105-012 | No-Log Keys | API keys that skip logging (GDPR) | diegosouza-omniroute | `src/lib/compliance/` | ❌ GAP (025-030) |
| 105-013 | Secret Redaction | Bearer, API keys, passwords redacted from logs/audit | — | — | ✅ 450-456 |
| 105-014 | Debug Exposure Gate | Controls debug info exposure | cybernetics-core | `debug-exposure-gate.ts` | ❌ GAP |
