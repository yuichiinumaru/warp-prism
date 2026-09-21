---
date: 20260709-240000
timestamp: 20260709-240000
project: warp-prism
agent: gt-flutter-engineer
task: "1110"
description: "CyberCore shell realign to Task 1108 pilots A/B/C"
is_rebuild_safe: true
---

# Changelog — Task 1110 path-to-100: Pilot route realignment

## Summary

Replaced Observatory-proxy primary nav (`/dashboard`, `/registry`, `/tasks`,
`/audit`, `/governance`) with Task 1108 pilots A/B/C live-CC route shapes.
Fixture plane now mirrors provider / MCP / live-log DTOs.

## Routes after

| Path | Pilot | Notes |
| --- | --- | --- |
| `/providers` | A | Connections list |
| `/providers/new` | A nested | Read-only create form (save disabled) |
| `/providers/:id` | A nested | Connection detail |
| `/mcp-servers` | B | Installed servers list |
| `/mcp-servers/:uuid` | B nested | Server detail |
| `/mcp-inspector` | B | Fixture connection + tools (no STDIO) |
| `/live-logs` | C | PrismLogViewer + redacted lines |

Root `/` redirects to `/providers`.

## What changed

- Archived Observatory-proxy features/fixtures/models under
  `.archive/task-1110-observatory-proxy-shell-20260709/`
- New fixtures: `providers.json`, `mcp_servers.json`, `mcp_inspector.json`,
  `live_logs.json` under `assets/cybercore_fixtures/`
- New DTOs + loader for pilot entities
- Shell nav: Providers · MCP Servers · MCP Inspector · Live Logs
- `createAppRouter()` factory (no shared router state across widget tests)
- Widget + model tests green; `flutter analyze` clean on `apps/cybercore`

## Validation

```bash
cd apps/cybercore && flutter analyze  # No issues found
cd apps/cybercore && flutter test    # 12/12 PASS
```

## Lane

Left in `docs/tasks/02-doing/`. `ready_for_reviewer: yes`.
