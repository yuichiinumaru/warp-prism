# CyberCore Frontend Scope & Route Parity Matrix

> **Task**: 1108 — CyberCore Frontend Scope and Route Parity Matrix  
> **Date**: 2026-07-09 (evidence refresh after Task 1102 rewrite)  
> **Prior draft**: 2026-06-08 (backend-catalog + Observatory-proxy MVP — **superseded for route authority**)  
> **Status**: Active — source-backed parity vs live CC frontend; screenshot-backed still blocked via Task 1102  
> **Evidence authority (route inventory)**: live `cybernetics-core/apps/frontend` `page.tsx` walk + Task 1102 outputs  
> **Secondary evidence**: `docs/reference/cybercore-control-surfaces/`, backend feature catalog (domain vocabulary only), EPIC-11

---

## 0. Evidence Boundary (2026-07-09)

| Class | Status | Use in this document |
| --- | --- | --- |
| Live CC frontend routes (`page.tsx`) | **Available** — sibling monorepo | **Primary** route inventory and parity rows |
| Task 1102 design outputs | **Source draft** (screenshot gate open) | Pilot selection, dispositions, state vocabulary |
| Control-surfaces packet | **PARTIAL** source-backed | `docs/reference/cybercore-control-surfaces/route-inventory.md` |
| Backend feature catalog | Available (35 files) | Domain entity notes only — **not** UI route authority |
| Observatory / ASW mock corpus | Available | **Not** CyberCore control-surface routes (explicit non-source for pilots) |
| Screenshot reports | **Absent** (`/tmp/opencode/cc-ui-screenshots-round2`) | No visual parity claims |
| `apps/cybercore` Flutter router | Present (Task 1110+) | **Downstream mirror only** — not CC route authority |

### Snapshot identity

| Field | Value |
| --- | --- |
| CC frontend root | `/home/sephiroth/working/ganthritor/cybernetics-core/apps/frontend` |
| Relative monorepo path | `cybernetics-core/apps/frontend` (sibling of `warp-prism/`) |
| Git HEAD observed (CC) | `ec87953` |
| `page.tsx` count (live walk) | **28** files under `app/` |
| Capture date | 2026-07-09 |
| No invented routes | Only FS-discovered `page.tsx` + domain-tab `href`s declared in source |

### Supersession note (why this refresh)

The 2026-06-08 draft:

1. Inventories CyberCore **backend feature series** and ASW mock entities as the primary matrix.
2. Selects Flutter MVP paths `/dashboard`, `/registry`, `/tasks`, `/audit`, `/governance` from **Observatory** feature reuse — not live Next.js admin routes.
3. Cites a pre-rewrite pilot matrix (Task Board / Registry) that Task 1102 **rejected** (F6).

Task 1102 (2026-07-09 rewrite) rebuilds inventory from live CC routes and selects pilots **A** `/providers`, **B** `/mcp-servers`+`/mcp-inspector`, **C** `/live-logs`. This document is realigned to that evidence. Historical Observatory-proxy paths remain documented as a **downstream drift** record, not as live CC routes.

---

## 1. Scope Decision

### Decision: Read-Only Mirror (First Wave)

The first CyberCore Flutter app (`apps/cybercore/`) remains a **read-only observatory mirror** of selected Cybernetics Core **admin/control-plane** surfaces — not a migration, not a companion admin app, and not an ADS-only consumer.

| Scope Option | Decision | Rationale |
|-------------|----------|-----------|
| **Read-Only Mirror** | **CHOSEN** | Matches EPIC-11 and Task 1102 non-goals. Fixture-backed, no live mutation, validates ADS against real CC IA. |
| Migration / Replacement | REJECTED | No evidence the Next.js frontend must be replaced. No Flutter auth/SDK gate closed. |
| Companion Admin App | REJECTED | Implies live API + mutation posture; out of first-wave product constraints. |
| ADS Consumer Only | REJECTED | Too thin; pilots require domain-shaped fixtures (providers, MCP, logs), not ADS gallery alone. |

### What "Read-Only Mirror" Means (post-1102)

1. **Source routes are live CC admin paths** (e.g. `/providers`), not ASW Map/Operate/History substitutes.
2. **Mock/fixture-backed**: first wave does not call live CyberCore APIs (Task 1109 inventories contracts; later tasks may wire clients).
3. **Mutations displayed as data**, not executed (import preflight, connection test badges, redacted secrets as fixture fields).
4. **Incremental**: expand one source-backed route at a time after pilots prove pattern (Task 1111 gate).

---

## 2. Live CyberCore Route Inventory

### 2.1 Primary sidebar (`layout.tsx` → `getMenuItems`)

Source: `cybernetics-core/apps/frontend/app/[locale]/(sidebar)/layout.tsx`.

| Surface | Live CC route | Roles (source) | Classification | Candidate Flutter path (first wave) |
| --- | --- | --- | --- | --- |
| Marketplace | `/search` | `client` | **defer** (pilot matrix score 6.8; secondary to admin control plane) | — (wave 2+) |
| Providers | `/providers` | `admin` | **pilot** (Pilot A / MVP #1) | `/providers` |
| MCP Servers | `/mcp-servers` | `admin` | **pilot** (Pilot B / MVP #2) | `/mcp-servers` |
| Harness | `/harness` | `admin`, `client` | **defer** (thin discovery UI vs providers/MCP) | — |
| Usage | `/usage` | `admin` | **defer** (after pilots; metrics polish) | — |
| Settings | `/settings` | `admin` | **defer** (many toggles, low narrative) | — |

### 2.2 Control-plane domain tabs (`control-plane-domain-tabs.tsx`)

Source: `components/admin/control-plane-domain-tabs.tsx` `DOMAIN_GROUPS` — every `href` is declared; none invented.

| Domain group | Tab | Live CC route | Classification | Notes |
| --- | --- | --- | --- | --- |
| Providers | Connections | `/providers` | **pilot** | Pilot A primary |
| Providers | Model Catalog | `/models` | **defer** | After providers model |
| Providers | Model Aliases | `/settings/aliases` | **defer** | |
| Providers | Media Providers | `/media` | **defer** | |
| Providers | Combos | `/combos` | **defer** | Depends on provider model (Pilot A) |
| Providers | Endpoint Modes | `/providers#endpoint-modes` | **needs-research** | Hash target on providers page |
| MCP Servers | Marketplace | `/search` | **defer** | |
| MCP Servers | Installed Servers | `/mcp-servers` | **pilot** | Pilot B |
| MCP Servers | Inspector | `/mcp-inspector` | **pilot** | Pilot B |
| MCP Servers | MCP Namespaces | `/namespaces` | **defer** | Heavy forms |
| MCP Servers | MCP Endpoints | `/endpoints` | **defer** | Heavy forms |
| Harness | Skills | `/harness?tab=skills` | **defer** | |
| Harness | Workflows | `/harness?tab=workflows` | **defer** | `/workflows` is redirect alias |
| Harness | Hooks | `/harness?tab=hooks` | **defer** | alias `/discovery` |
| Harness | Profiles | `/harness?tab=profiles` | **defer** | |
| Usage | Metrics | `/usage` | **defer** | |
| Usage | Costs & Budgets | `/costs` | **defer** | |
| Usage | Live Logs | `/live-logs` | **pilot** | Pilot C (optional third) |
| Settings | General | `/settings` | **defer** | |
| Settings | API Keys | `/api-keys` | **defer** | Secrets risk; after pilots |
| Settings | Endpoint Exposure | `/llm-endpoints` | **defer** | Strong story; schedule after pilots |

### 2.3 Full `page.tsx` parity matrix (live walk, 28 files)

Authority: FS walk of `cybernetics-core/apps/frontend/app/**/page.tsx` (2026-07-09) cross-checked with `docs/reference/cybercore-control-surfaces/route-inventory.md` and `docs/design/component-inventory.md` §1.

| Live CC route | Page source (rel. frontend) | Classification | Candidate Flutter mirror path | Wave / notes |
| --- | --- | --- | --- | --- |
| `/` | `app/[locale]/(sidebar)/page.tsx` | **discard** | n/a | Redirect/loading only |
| `/search` | `.../search/page.tsx` | **defer** | `/search` (later) | Marketplace |
| `/providers` | `.../providers/page.tsx` | **pilot** / **MVP** | `/providers` | Pilot A |
| `/providers/new` | `.../providers/new/page.tsx` | **pilot** / **MVP** | `/providers/new` | Nested under A; read-only form fixture |
| `/providers/[id]` | `.../providers/[id]/page.tsx` | **pilot** / **MVP** | `/providers/:id` | Nested under A |
| `/models` | `.../models/page.tsx` | **defer** | `/models` | |
| `/media` | `.../media/page.tsx` | **defer** | `/media` | |
| `/combos` | `.../combos/page.tsx` | **defer** | `/combos` | After Pilot A |
| `/settings/aliases` | `.../settings/aliases/page.tsx` | **defer** | `/settings/aliases` | |
| `/mcp-servers` | `.../mcp-servers/page.tsx` | **pilot** / **MVP** | `/mcp-servers` | Pilot B |
| `/mcp-servers/[uuid]` | `.../mcp-servers/[uuid]/page.tsx` | **pilot** / **MVP** | `/mcp-servers/:uuid` | Pilot B detail |
| `/mcp-inspector` | `.../mcp-inspector/page.tsx` | **pilot** / **MVP** | `/mcp-inspector` | Pilot B; no live STDIO in WP |
| `/namespaces` | `.../namespaces/page.tsx` | **defer** | `/namespaces` | |
| `/namespaces/[uuid]` | `.../namespaces/[uuid]/page.tsx` | **defer** | `/namespaces/:uuid` | |
| `/endpoints` | `.../endpoints/page.tsx` | **defer** | `/endpoints` | |
| `/harness` | `.../harness/page.tsx` → discovery | **defer** | `/harness` | |
| `/discovery` | `.../discovery/page.tsx` | **defer** | `/discovery` | Read-only public class in middleware |
| `/workflows` | `.../workflows/page.tsx` | **discard** | n/a | Redirect → harness workflows tab |
| `/usage` | `.../usage/page.tsx` | **defer** | `/usage` | |
| `/costs` | `.../costs/page.tsx` | **defer** | `/costs` | |
| `/live-logs` | `.../live-logs/page.tsx` | **pilot** / **MVP** | `/live-logs` | Pilot C |
| `/settings` | `.../settings/page.tsx` | **defer** | `/settings` | |
| `/api-keys` | `.../api-keys/page.tsx` | **defer** | `/api-keys` | High secret risk |
| `/llm-endpoints` | `.../llm-endpoints/page.tsx` | **defer** | `/llm-endpoints` | Post-pilot exposure story |
| `/login` | `app/[locale]/login/page.tsx` | **defer** / shell gate | `/login` | Auth; not first pilot surface |
| `/register` | `app/[locale]/register/page.tsx` | **defer** | `/register` | |
| `/cors-error` | `app/[locale]/cors-error/page.tsx` | **defer** | `/cors-error` | Error surface |
| `/fe-oauth/callback` | `app/fe-oauth/callback/page.tsx` | **needs-research** | TBD | OAuth return; live-only semantics |

**Classification vocabulary** (task-required): `MVP` · `pilot` · `defer` · `discard` · `needs-research`.  
Pilots are the first-wave MVP subset; inventory rows marked MVP without pilot selection still exist in Task 1102 component inventory for later waves.

### 2.4 Routes that do **not** exist in live CC frontend

The following paths appear in historical Task 1108 / Task 1110 Flutter work. They are **not** live CyberCore Next.js routes (no matching `page.tsx`). They must not be cited as CC source routes.

| Path | Origin | Parity status |
| --- | --- | --- |
| `/dashboard` | Observatory proxy / apps/cybercore | **Not a live CC route** |
| `/registry` | Observatory Map proxy | **Not a live CC route** |
| `/tasks` | Observatory Operate proxy | **Not a live CC route** |
| `/audit` | Observatory History proxy | **Not a live CC route** |
| `/governance` | Observatory Governance proxy | **Not a live CC route** |

Task 1102 pilot matrix explicitly **rejects** Observatory Operate board and Map graph as CyberCore pilots (candidates X/Y).

### 2.5 Backend catalog (secondary — not route authority)

`docs/reference/cybercore-backend-features/` (35 files, ~1,336 features) remains useful for entity/state-machine vocabulary and Task 1109 API inventory, but **does not define frontend routes**. Historical 12-section IA from backend series is **not** used as the live route parity spine after this refresh.

---

## 3. First-Wave MVP Route List (aligned to Task 1102 pilots)

### Selection authority

| Criterion | Source |
| --- | --- |
| Live `page.tsx` exists | Gate (this inventory) |
| Task 1102 pilot scores A/B/C | `docs/design/cybercore-pilot-surface-matrix.md` |
| Operational state density | 1102 vocabulary + inventory columns |
| Read-only fixture feasibility | EPIC-11 + product constraints |
| Screenshot confirmation | **Blocked** — does not invent visuals |

### Pilot / MVP routes

#### Route 1 — Providers Connections (Pilot A)

| Attribute | Value |
|-----------|-------|
| **Live CC path** | `/providers` (+ `/providers/new`, `/providers/[id]`) |
| **Classification** | **pilot** / **MVP** #1 |
| **Source** | `providers/page.tsx` (~1143 lines), `providers/new`, `providers/[id]`, `components/providers/*` |
| **Ops states (source)** | inactive/active/error/untested; importable/blocked/duplicate; loading/empty/error; redaction |
| **Candidate Flutter paths** | `/providers`, `/providers/new`, `/providers/:id` |
| **Prism candidates** | `DSShell`, `DSDataTable`, `DSSearchBar`, `DSFilterChipGroup`, `DSBadge`, `DSStatusDot`, `DSHealthCard`, `DSStateSurface`, `DSOperationalState` |
| **API inventory feed (1109)** | `trpc.frontend.llmProviders.*` (list, test, legacy preflight) — read models only in mirror |
| **Evidence** | source-backed; screenshot-backed **missing** |

#### Route 2 — MCP Servers + Inspector (Pilot B)

| Attribute | Value |
|-----------|-------|
| **Live CC paths** | `/mcp-servers`, `/mcp-servers/[uuid]`, `/mcp-inspector` |
| **Classification** | **pilot** / **MVP** #2 |
| **Source** | `mcp-servers/page.tsx`, `mcp-servers/[uuid]/*`, `mcp-inspector/page.tsx`, `hooks/useConnection.ts` |
| **Ops states (source)** | list loading/error; connection connecting/connected/error; tool enablement |
| **Candidate Flutter paths** | `/mcp-servers`, `/mcp-servers/:uuid`, `/mcp-inspector` |
| **Prism candidates** | `DSDataTable`, `DSDetailInspector`, `DSLogViewer`, `DSSplitPane`, `DSStateSurface`, `DSStatusDot` |
| **API inventory feed (1109)** | `trpc.frontend.mcpServers.*`, inspector proxy (no STDIO execution in WP) |
| **Evidence** | source-backed; screenshot-backed **missing** |

#### Route 3 — Live Logs + Health Strip (Pilot C)

| Attribute | Value |
|-----------|-------|
| **Live CC path** | `/live-logs` |
| **Classification** | **pilot** / **MVP** #3 (may slip to wave-2 if capacity forces two-only) |
| **Source** | `live-logs/page.tsx`, `lib/llm-diagnostics.ts` |
| **Ops states (source)** | provider health ready/failing/inactive/unknown; redacted logs; empty |
| **Candidate Flutter path** | `/live-logs` |
| **Prism candidates** | `DSLogViewer`, `DSLogFilterBar`, `DSMetricTile`, `DSHealthCard`, `DSStatusGrid` |
| **API inventory feed (1109)** | providers list + client log buffer + redaction helpers |
| **Evidence** | source-backed; screenshot-backed **missing** |

### First-wave summary

| # | Live CC route(s) | Flutter candidate | Classification | Task 1102 pilot |
|---|------------------|-------------------|---------------|-----------------|
| 1 | `/providers` (+ nested) | `/providers` (+ nested) | MVP pilot | A |
| 2 | `/mcp-servers`, `/mcp-servers/[uuid]`, `/mcp-inspector` | same path shapes | MVP pilot | B |
| 3 | `/live-logs` | `/live-logs` | MVP pilot | C |

All other live routes in §2.3 are **defer**, **discard**, or **needs-research** until Task 1111 expansion gate.

---

## 4. Downstream Flutter Mirror Drift (`apps/cybercore`)

`apps/cybercore/lib/app/router.dart` currently implements:

| Flutter path | Maps to live CC? | Assessment |
|--------------|------------------|------------|
| `/dashboard` | No | Observatory-style proxy; **parity gap** vs live CC |
| `/registry` | No | Not a live CC route |
| `/tasks` | No | Rejected as CC pilot (Observatory Operate) |
| `/audit` | No | Not a live CC route |
| `/governance` | No | Not a live CC route |

This document **does not** invent live CC routes to match those paths. Remediation of `apps/cybercore` route names is out of scope for Task 1108 docs refresh; it is a **known drift** for Tasks 1110/1111 consumers to reconcile against §3 candidate paths.

---

## 5. Non-Goals

The first CyberCore Flutter wave will **NOT**:

| # | Non-Goal | Rationale | When to Revisit |
|---|---------|-----------|-----------------|
| 1 | **Replace the existing Next.js frontend** | EPIC-11 + 1102 non-goals | Task 1111+ only with explicit decision |
| 2 | **Treat Observatory Map/Operate/History as CC routes** | F6 rejection; wrong product domain | Never as CC authority |
| 3 | **Connect to live CyberCore APIs in first wave** | Fixture-first; SDK/auth gates | After 1109 + authorized integration task |
| 4 | **Implement write operations** | Read-only mirror | Mutation safety + auth tasks |
| 5 | **Reimplement all live CC routes** | Unbounded; pilots only | Expansion gate 1111 |
| 6 | **Claim screenshot-backed visual parity** | Screenshot packet absent | When `/tmp` or in-repo screenshots land |
| 7 | **Introduce SQLite / durable client state** | AGENTS.md constraints | Parent governance only |
| 8 | **Put CyberCore-specific DTOs in `warp_prism_ui`** | ADS stays app-agnostic | Permanent boundary |
| 9 | **Invent routes without `page.tsx`** | Anti-hallucination | Never |
| 10 | **Modify `cybernetics-core/apps/frontend/`** | Read-only reference | Never from Warp Prism tasks |

---

## 6. Migration Guardrails

### 6.1 Hard boundaries

| # | Guardrail | Enforcement |
|---|----------|-------------|
| 1 | No edits to live CC Next.js frontend from Warp Prism work | Read-only monorepo citation only |
| 2 | Flutter CyberCore work lives under `warp-prism/apps/cybercore/` | Melos workspace |
| 3 | No invented CC routes | Must appear in live `page.tsx` walk or domain-tab `href` |
| 4 | No mutation endpoints in first wave | Fixture display of action outcomes only |
| 5 | ADS remains app-agnostic | Domain code in `apps/cybercore/` |
| 6 | Task 1102 screenshot gate does not authorize inventing visual states | Source-backed only until screenshots exist |

### 6.2 Incremental expansion rules

| # | Rule |
|---|------|
| 1 | One source-backed route at a time after pilots |
| 2 | Fixture contract before route implementation |
| 3 | ADS reuse required; gaps → Tasks 1112–1123 |
| 4 | Route contract: live path, fixture schema, ADS list, states, entity mapping |
| 5 | Promote only with mapping + fixture + widget test + a11y check (EPIC-11 eval) |

### 6.3 Escalation triggers

| Trigger | Action |
|---------|--------|
| Need live API | Task 1109 contracts → authorized integration task |
| Need auth flows | Auth infrastructure task (not 1108) |
| Need new ADS component | Gap analysis tasks 1112–1123 |
| Need writes | Mutation safety gate task |
| Scope beyond pilots A–C | Task 1111 expansion gate |

---

## 7. API Inventory Feed Into Task 1109

First-wave read models to inventory (from Task 1102 data deps — not full backend catalog):

| Pilot | Live routes | Data dependencies (source) | Priority |
|-------|-------------|----------------------------|----------|
| A | `/providers*` | `trpc.frontend.llmProviders.list`, testConnection, legacy preflight/import (read shapes) | P0 |
| B | `/mcp-servers*`, `/mcp-inspector` | `trpc.frontend.mcpServers.*`, inspector connection hooks | P0 |
| C | `/live-logs` | providers list + log buffer + redaction helpers | P0 / P1 |
| Deferred | remaining §2.3 | Per inventory rows when expanded | Later |

---

## 8. Implementation Sequencing

| Order | Item | Depends on |
|-------|------|------------|
| 1 | Task 1102 source inventory + pilots (done as draft; screenshot blocked) | Live CC frontend |
| 2 | **This document (1108)** — scope + parity | 1102 file-level outputs |
| 3 | Task 1109 — API/data contracts for pilot routes | This matrix §7 |
| 4 | Task 1110 — fixture-backed shell (reconcile route drift §4) | 1107, 1108, 1109 |
| 5 | Task 1111 — expansion gate beyond pilots | Pilots proven |

### Recommended pilot implementation order

| Step | Live route | Why |
|------|------------|-----|
| 1 | `/providers` | Richest single page; health + import story |
| 2 | `/mcp-servers` + detail | Core product control plane |
| 3 | `/mcp-inspector` | Connection state machine (read-only) |
| 4 | `/live-logs` | Incident narrative + redaction |

---

## 9. Risk Assessment

| Risk | Severity | Mitigation |
|------|----------|------------|
| Task 1102 still blocked on screenshots | High (promotion) | File-level source inventory usable; no visual claims; 1108 stays evidence-honest |
| `apps/cybercore` paths diverge from live CC | High (implementation drift) | §4 documents gap; expansion/remediation must follow §3 candidates |
| Treating backend features as routes | Medium | §0 / §2.5 forbid as route authority |
| Secret/credential fixtures | High | Redaction fixtures only; never real secrets |
| STDIO / MCP execution in mirror | High | Non-goal: no live inspector execution |
| Scope creep to full IA | Medium | Pilots only; 1111 gate |

---

## 10. Source Evidence

| Source | Path | Relevance |
|--------|------|-----------|
| Live CC frontend | `/home/sephiroth/working/ganthritor/cybernetics-core/apps/frontend` | Route authority (`page.tsx`) |
| Domain tabs | `.../components/admin/control-plane-domain-tabs.tsx` | Secondary IA tabs |
| Sidebar layout | `.../app/[locale]/(sidebar)/layout.tsx` | Primary nav |
| Route inventory packet | `docs/reference/cybercore-control-surfaces/route-inventory.md` | Indexed live routes |
| Component inventory | `docs/design/component-inventory.md` (2026-07-09 rewrite) | Full control-surface columns |
| Pilot surface matrix | `docs/design/cybercore-pilot-surface-matrix.md` (2026-07-09 rewrite) | Pilots A/B/C |
| Operational state vocabulary | `docs/design/operational-state-vocabulary.md` (2026-07-09 rewrite) | State IDs + maps |
| Task 1102 | `.project/tasks/02-doing/1102-warp-prism-control-surface-inventory.md` | Dependency; **Blocked** screenshots |
| EPIC-11 | `.project/tasks/00-planning/EPIC-11-warp-prism-cybercore-frontend.md` | Scope guardrails |
| Backend features (secondary) | `docs/reference/cybercore-backend-features/` | Entity vocabulary for 1109 |
| Flutter mirror (secondary) | `apps/cybercore/lib/app/router.dart` | Downstream drift only |
| AGENTS.md | `AGENTS.md` | Read-only / mock-first constraints |

---

## 11. Evidence Refresh Log

| Date | Agent | Change |
|------|-------|--------|
| 2026-06-08 | builders | Original combined scope + parity from backend catalog + Observatory proxies |
| 2026-07-09 | prior evidence refresh | File existence / changelog path fixes; content still Observatory-centric |
| 2026-07-09 | docs/evidence (this pass) | **Content realign** to Task 1102 live-route rewrite: pilots A/B/C, full live route matrix, discard invented CC claim for Observatory paths, document `apps/cybercore` drift |

### Validation (this pass)

```text
$ test -f docs/design/cybercore-scope-route-parity.md && echo PASS
PASS
$ test -f docs/design/component-inventory.md \
  && test -f docs/design/cybercore-pilot-surface-matrix.md \
  && test -f docs/design/operational-state-vocabulary.md && echo PASS
PASS
$ test -d /home/sephiroth/working/ganthritor/cybernetics-core/apps/frontend/app && echo CC_FRONTEND_OK
CC_FRONTEND_OK
$ find .../apps/frontend/app -name page.tsx | wc -l
28
$ ls /tmp/opencode/cc-ui-screenshots-round2
# absent → screenshot gate remains open (Task 1102)
```
