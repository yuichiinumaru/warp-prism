# CyberCore Route Inventory Evidence Status

> **Status**: PARTIAL — source-backed route index populated from live frontend  
> **Evidence class**: `source-backed`  
> **Task**: Task 1420 packet refresh for Task 1102 (2026-07-09; re-verified same day)  
> **Authority detail**: `docs/design/component-inventory.md` (full columns)  
> **Absolute root**: `/home/sephiroth/working/ganthritor/cybernetics-core/apps/frontend/`

## Route / Component Evidence Table

Routes discovered under `cybernetics-core/apps/frontend/app/` (excluding `.next*` / `.archive`). **28** `page.tsx` files; all paths below re-verified present 2026-07-09.

| Route | Page source (rel. frontend) | Evidence class | Allowed for 1102 |
| --- | --- | --- | --- |
| `/` | `app/[locale]/(sidebar)/page.tsx` | source-backed | Yes (redirect) |
| `/search` | `app/[locale]/(sidebar)/search/page.tsx` | source-backed | Yes |
| `/providers` | `app/[locale]/(sidebar)/providers/page.tsx` | source-backed | Yes (Pilot A) |
| `/providers/new` | `app/[locale]/(sidebar)/providers/new/page.tsx` | source-backed | Yes |
| `/providers/[id]` | `app/[locale]/(sidebar)/providers/[id]/page.tsx` | source-backed | Yes |
| `/models` | `app/[locale]/(sidebar)/models/page.tsx` | source-backed | Yes |
| `/media` | `app/[locale]/(sidebar)/media/page.tsx` | source-backed | Yes |
| `/combos` | `app/[locale]/(sidebar)/combos/page.tsx` | source-backed | Yes |
| `/settings/aliases` | `app/[locale]/(sidebar)/settings/aliases/page.tsx` | source-backed | Yes |
| `/mcp-servers` | `app/[locale]/(sidebar)/mcp-servers/page.tsx` | source-backed | Yes (Pilot B) |
| `/mcp-servers/[uuid]` | `app/[locale]/(sidebar)/mcp-servers/[uuid]/page.tsx` | source-backed | Yes |
| `/mcp-inspector` | `app/[locale]/(sidebar)/mcp-inspector/page.tsx` | source-backed | Yes (Pilot B) |
| `/namespaces` | `app/[locale]/(sidebar)/namespaces/page.tsx` | source-backed | Yes |
| `/namespaces/[uuid]` | `app/[locale]/(sidebar)/namespaces/[uuid]/page.tsx` | source-backed | Yes |
| `/endpoints` | `app/[locale]/(sidebar)/endpoints/page.tsx` | source-backed | Yes |
| `/harness` | `app/[locale]/(sidebar)/harness/page.tsx` → discovery | source-backed | Yes |
| `/discovery` | `app/[locale]/(sidebar)/discovery/page.tsx` | source-backed | Yes |
| `/workflows` | `app/[locale]/(sidebar)/workflows/page.tsx` (redirect) | source-backed | Yes |
| `/usage` | `app/[locale]/(sidebar)/usage/page.tsx` | source-backed | Yes |
| `/costs` | `app/[locale]/(sidebar)/costs/page.tsx` | source-backed | Yes |
| `/live-logs` | `app/[locale]/(sidebar)/live-logs/page.tsx` | source-backed | Yes (Pilot C) |
| `/settings` | `app/[locale]/(sidebar)/settings/page.tsx` | source-backed | Yes |
| `/api-keys` | `app/[locale]/(sidebar)/api-keys/page.tsx` | source-backed | Yes |
| `/llm-endpoints` | `app/[locale]/(sidebar)/llm-endpoints/page.tsx` | source-backed | Yes |
| `/login` | `app/[locale]/login/page.tsx` | source-backed | Yes |
| `/register` | `app/[locale]/register/page.tsx` | source-backed | Yes |
| `/cors-error` | `app/[locale]/cors-error/page.tsx` | source-backed | Yes |
| `/fe-oauth/callback` | `app/fe-oauth/callback/page.tsx` | source-backed | Yes |

## Shared Components (source-backed)

| Component | Path (rel. frontend) |
| --- | --- |
| AdminPageShell | `components/admin/admin-page-shell.tsx` |
| AdminDataState | `components/admin/admin-data-state.tsx` |
| AdminPanel | `components/admin/admin-panel.tsx` |
| AdminTableShell | `components/admin/admin-table-shell.tsx` |
| AdminDataToolbar | `components/admin/admin-data-toolbar.tsx` |
| MetricGrid | `components/admin/metric-grid.tsx` |
| ControlPlaneDomainTabs | `components/admin/control-plane-domain-tabs.tsx` |
| LlmOpsPeriodControls | `components/admin/llm-ops-period-controls.tsx` |
| ProviderStatusBadge | `components/providers/provider-status-badge.tsx` |
| ProviderConnectionForm | `components/providers/provider-connection-form.tsx` |
| ConnectionStatus type | `lib/constants.ts` (+ `hooks/useConnection.ts`) |
| ProviderHealthStatus | `lib/llm-diagnostics.ts` |
| RemoteExposureState | `lib/llm-remote-exposure.ts` |
| ComboReadinessStatus | `lib/combo-readiness.ts` |

## What This Unblocks

Task 1102 **may** fill inventory columns that depend on route/component/source paths and source-visible states/actions.

## What This Does Not Unblock

- Screenshot-backed visual claims (screenshots remain **absent / optional** after 2026-07-09 amend — do not invent).
- Routes not present as `page.tsx` in the live frontend.

## Task 1102 readiness note

Source-backed route inventory supports Task 1102 `ready_for_reviewer: yes` under DoD (`component-inventory.md` §0.5 APPLIED). Screenshots are not required for that readiness.
