# CyberCore Source Paths Evidence Status

> **Status**: PARTIAL — live monorepo paths authorized; no vendored snapshot in this directory  
> **Evidence class**: `source-backed` (live)  
> **Task**: Task 1420 packet refresh for Task 1102 (2026-07-09; path re-verify same day)

## Source Boundary

Task 1102 rebuild (2026-07-09) was authorized to read the parent CyberCore monorepo:

| Root | Path |
| --- | --- |
| Cybernetics Core monorepo | `/home/sephiroth/working/ganthritor/cybernetics-core` |
| Frontend app | `/home/sephiroth/working/ganthritor/cybernetics-core/apps/frontend` |
| UI patterns | `/home/sephiroth/working/ganthritor/cybernetics-core/apps/frontend/docs/ui-patterns.md` |
| Observed git HEAD | `ec87953` (working tree may be dirty / ahead for UI files) |
| Path re-verify | 2026-07-09 — all rows below `test -e` OK |

## Approved Source Paths (Live)

Paths relative to `cybernetics-core/apps/frontend/` (absolute prefix: `/home/sephiroth/working/ganthritor/cybernetics-core/apps/frontend/`):

| Source path | Evidence status | Allowed for Task 1102 rebuild? | Notes |
| --- | --- | --- | --- |
| `app/[locale]/(sidebar)/layout.tsx` | source-backed | Yes — primary nav | Sidebar menu + roles |
| `components/admin/control-plane-domain-tabs.tsx` | source-backed | Yes — full IA tabs | `DOMAIN_GROUPS` hrefs |
| `middleware.ts` | source-backed | Yes — authz classes | public / readOnly / adminOnly (partial) |
| `app/[locale]/(sidebar)/**/page.tsx` | source-backed | Yes — all page routes found by FS walk | 28 `page.tsx` under `app/` |
| `components/admin/*` | source-backed | Yes — admin primitives | shell, data-state, panel, table, toolbar, metric-grid, domain tabs, period controls |
| `components/providers/provider-status-badge.tsx` | source-backed | Yes | Inactive/Active/Error/Untested |
| `components/providers/provider-connection-form.tsx` | source-backed | Yes | Connection form organism |
| `components/edit-mcp-server.tsx`, `edit-endpoint.tsx`, `edit-namespace.tsx` | source-backed | Yes | MCP editors |
| `components/skeletons/*` | source-backed | Yes | Loading placeholders |
| `components/logs-status-indicator.tsx` | source-backed | Yes | Live logs indicator |
| `components/domain-warning-banner.tsx` | source-backed | Yes | Origin mismatch banner |
| `lib/llm-diagnostics.ts` | source-backed | Yes | `ProviderHealthStatus` |
| `lib/llm-remote-exposure.ts` | source-backed | Yes | `RemoteExposureState` |
| `lib/combo-readiness.ts` | source-backed | Yes | `ComboReadinessStatus` |
| `lib/constants.ts` | source-backed | Yes | `ConnectionStatus` |
| `hooks/useConnection.ts` | source-backed | Yes | Inspector connection state machine |
| `types/search.ts` | source-backed | Yes | Catalog status union |
| `docs/ui-patterns.md` | source-backed | Yes | Contracts + a11y notes |
| Pilot A pages | source-backed | Yes | `providers/page.tsx` (1143), `providers/new`, `providers/[id]` |
| Pilot B pages | source-backed | Yes | `mcp-servers/page.tsx` (497), `[uuid]`, `mcp-inspector/page.tsx` (384) |
| Pilot C page | source-backed | Yes | `live-logs/page.tsx` (351) |
| `docs/reference/cybercore-backend-features/*` (Warp Prism) | secondary | Domain notes only | Not route authority |
| `apps/cybercore/*` (Warp Prism) | secondary | Downstream mirror only | Not CC route authority |

## Explicit Non-Sources

| Non-source | Why not accepted as CC control surface authority |
| --- | --- |
| Historical `/tmp/opencode/cc-ui-screenshots-round2/*.md` | Unavailable; not in repository |
| Prior Task 1102 Observatory inventory (2026-06-08) | Wrong evidence domain (F1) |
| Invented backend feature screens without `page.tsx` | Would fabricate routes |

## Unblock Remaining

1. **Screenshot hard-gate**: **APPLIED optional** via 2026-07-09 governance amend (`docs/design/component-inventory.md` §0.5). Source-backed paths above satisfy primary DoD for `ready_for_reviewer: yes`. Screenshot import remains **optional deferred** (see `screenshot-evidence-index.md`) — do not invent.
2. Optional: vendor a reviewed frontend snapshot into this packet for offline reproducibility.
