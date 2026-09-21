# Task 1108: Warp Prism CyberCore Frontend Scope And Route Parity Matrix

> **Review State**: 2026-07-18 path-to-100 independent re-review **100/100** `ACCEPTED_100`
> **Priority**: 🔴 P0
> **Type**: `architecture` | `verification`
> **Origin**: EPIC-11 Warp Prism Cybernetics Core Frontend.
> **Blocks**: Task 1109, Task 1110, Task 1111
> **Depends on**: Task 1102 (**Ready For Review**; inventory present; screenshots optional/deferred), EPIC-11
> **ready_for_reviewer**: **yes**
> **Lane**: `docs/tasks/04-completed/`

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1108` plus optional slug for dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

Create the scope decision and route parity matrix for a future Cybernetics Core Flutter frontend. The output must compare current Cybernetics Core frontend routes/surfaces against candidate Flutter routes, classify first-wave scope, and decide whether the first CyberCore Flutter app is a read-only mirror, companion admin app, replacement candidate, or ADS consumer only.

## Background Context

### What already exists

- Live Cybernetics Core frontend under sibling `cybernetics-core/apps/frontend/` (authorized for 1102/1108 evidence).
- Task 1102 design outputs rewritten 2026-07-09 from live CC routes (not Observatory): `component-inventory.md`, `cybercore-pilot-surface-matrix.md`, `operational-state-vocabulary.md`.
- Control-surfaces packet: `docs/reference/cybercore-control-surfaces/` (PARTIAL source-backed; screenshots blocked).
- EPIC-11 defines CyberCore frontend planning as separate from ADS scaffold.
- Downstream `apps/cybercore/` exists from later tasks — **not** CC route authority.

### What is missing or broken

- Task 1102 screenshot exit condition still open → 1102 remains Blocked / not promotion-ready.
- Pre-refresh 1108 deliverable still used Observatory-proxy MVP paths and backend-catalog IA as route spine (corrected this pass).
- `apps/cybercore` router still exposes `/dashboard|/registry|/tasks|/audit|/governance` (parity drift vs live CC; documented, not fixed in this docs task).

---

## Test Requirements

- The matrix MUST inventory current Cybernetics Core frontend/admin routes from source, not memory.
- The matrix MUST classify each route as MVP, pilot, defer, discard, or needs research.
- The scope decision MUST explicitly say whether first wave is read-only mirror, companion, replacement candidate, or ADS-only.
- The decision MUST include non-goals and migration guardrails.
- No Flutter code may be created in this task.

---

## Exit Conditions

- [x] `docs/design/cybercore-scope-route-parity.md` exists with scope decision, non-goals, and route parity matrix (combined per task instructions).
- [x] The matrix inventories **live** CyberCore frontend routes from source (`page.tsx` walk + control-surfaces packet + Task 1102 inventory) — **refreshed 2026-07-09** (28 `page.tsx` files). Backend feature catalog retained as secondary entity vocabulary only.
- [x] The matrix classifies each live route as MVP/pilot/defer/discard/needs-research.
- [x] The matrix uses Task 1102 pilot-surface evidence (pilots A/B/C: `/providers`, `/mcp-servers`+`/mcp-inspector`, `/live-logs`).
- [x] Scope decision = **Read-Only Mirror**; non-goals + migration guardrails present.
- [x] No Flutter package/app files are created **by this task** (docs-only deliverable).
- [x] Local changelog entry exists (engine path: `docs/changelog/20260608-210330-1108-2026-06-08-task-1108-cybercore-scope-route-parity-repair-bot.md`; indexed in `docs/changelog/index.md`). Historical entry covers original build; this pass is evidence/content refresh only (no new changelog publish ordered).
- [x] Completion Evidence is filled and live-revalidated (2026-07-09 post-1102-rewrite refresh).

> **Note**: Task exit conditions originally specified two separate files (`cybercore-frontend-scope.md` and `cybercore-route-parity-matrix.md`). Execution produced a single combined file `docs/design/cybercore-scope-route-parity.md`. Historical build-gate review (`docs/reports/build-gate-review/1108-review.md`) approved the combined approach; that review’s Observatory-proxy route spine and changelog path claims are stale relative to the 2026-07-09 live-route refresh.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read EPIC-11, Task 1102 outputs (post-rewrite), live `cybernetics-core/apps/frontend/`, control-surfaces packet, prior parity doc, `apps/cybercore` router (secondary).
- [x] Inventory CyberCore frontend route/source surfaces — live 28 `page.tsx` + domain tabs.
- [x] Map each current surface to a candidate Flutter app route or defer/discard/needs-research decision.
- [x] Decide first-wave scope and explicit non-goals — Read-Only Mirror retained.
- [x] Identify which routes require API contract inventory in Task 1109 — pilots A/B/C data deps.
- [x] **Simplicity pass**: MVP = Task 1102 pilots only; no full replacement language.
- [x] **Regression verification**: live route walk + dependency file checks (2026-07-09 post-1102).

### Where

| File | Purpose |
| --- | --- |
| `/home/sephiroth/working/ganthritor/cybernetics-core/apps/frontend/` | Read — live CC frontend route authority. |
| `docs/reference/cybercore-control-surfaces/` | Read — PARTIAL source-backed route packet. |
| `docs/reference/cybercore-backend-features/` | Read — secondary domain vocabulary only (not UI routes). |
| `docs/tasks/00-planning/EPIC-11-warp-prism-cybercore-frontend.md` | Read — epic scope. |
| `docs/design/component-inventory.md` | Read — Task 1102 inventory (2026-07-09 rewrite). |
| `docs/design/cybercore-pilot-surface-matrix.md` | Read — Task 1102 pilots A/B/C. |
| `docs/design/operational-state-vocabulary.md` | Read — Task 1102 vocabulary. |
| `apps/cybercore/lib/app/router.dart` | Read — downstream Flutter drift only. |
| `docs/design/cybercore-scope-route-parity.md` | Create/refresh — scope decision + route parity matrix. |
| `docs/changelog/20260608-210330-1108-2026-06-08-task-1108-cybercore-scope-route-parity-repair-bot.md` | Historical changelog (engine-named). |

### How

1. Inventory source routes before deciding (live `page.tsx`, not memory).
2. Classify every route rather than cherry-picking only obvious screens.
3. Keep the first wave read-only unless later tasks authorize mutation.
4. Feed the API inventory scope into Task 1109 (pilot data deps).
5. Do not invent CC routes; document Observatory-proxy paths as non-CC.

### Why

A new frontend without route parity and scope decision can become an unbounded rewrite. This task creates the map that keeps CyberCore Flutter work incremental, evidence-backed, and safe.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not invent Cybernetics Core routes from product intuition. Cite source paths.

> [!CAUTION]
> Do not frame this as replacing the existing frontend unless the scope decision explicitly proves that is the intended later stage.

> [!CAUTION]
> Do not treat Observatory Map/Operate/History or `apps/cybercore` `/dashboard|/registry|/tasks|/audit|/governance` as live CyberCore frontend routes.

---

## Validation Commands

```bash
# Canonical combined deliverable
test -f docs/design/cybercore-scope-route-parity.md
# Engine-generated changelog for Task 1108
test -f docs/changelog/20260608-210330-1108-2026-06-08-task-1108-cybercore-scope-route-parity-repair-bot.md
# Task 1102 dependency artifacts (file-level; 1102 not promoted)
test -f docs/design/component-inventory.md
test -f docs/design/cybercore-pilot-surface-matrix.md
test -f docs/design/operational-state-vocabulary.md
# Live CC frontend (authorized sibling monorepo)
test -d /home/sephiroth/working/ganthritor/cybernetics-core/apps/frontend/app
# Screenshot gate (expected fail while 1102 blocked)
# ls /tmp/opencode/cc-ui-screenshots-round2
```

---

## Completion Evidence

- **Files created/modified**:
  - Created (original 2026-06-08): `docs/design/cybercore-scope-route-parity.md`
  - Created (original/engine): `docs/changelog/20260608-210330-1108-2026-06-08-task-1108-cybercore-scope-route-parity-repair-bot.md`
  - Modified (2026-07-09 post-1102 rewrite evidence refresh): `docs/design/cybercore-scope-route-parity.md` — full content realign to live CC routes + pilots A/B/C; Observatory-proxy MVP spine superseded
  - Modified (same pass): `docs/tasks/02-doing/1108-warp-prism-cybercore-frontend-scope-route-parity.md` — header/status/evidence alignment; lane remains `02-doing/`
- **Live revalidation (2026-07-09, post-1102 rewrite)**:
  - `test -f docs/design/cybercore-scope-route-parity.md` → PASS
  - `test -f docs/changelog/20260608-210330-1108-2026-06-08-task-1108-cybercore-scope-route-parity-repair-bot.md` → PASS
  - Task 1102 deps: `component-inventory.md` (266), `cybercore-pilot-surface-matrix.md` (168), `operational-state-vocabulary.md` (209) → present; content is 2026-07-09 live-route rewrite
  - Live CC: `test -d .../cybernetics-core/apps/frontend/app` → PASS; `find ... -name page.tsx | wc -l` → **28**
  - Control-surfaces packet: `route-inventory.md` present; screenshots absent
  - Deliverable content checks after refresh:
    - §1 Scope Decision = **Read-Only Mirror**
    - §2 full live route matrix with MVP|pilot|defer|discard|needs-research
    - §3 MVP pilots = `/providers`, `/mcp-servers`+inspector, `/live-logs` (matches 1102 A/B/C)
    - §4 documents `apps/cybercore` Observatory-proxy drift (not claimed as CC routes)
    - §5 Non-Goals; §6 Migration Guardrails
  - Docs-only task type → Package/Consumer gates N/A per `docs/governance/test-gate-matrix.md`
- **Local changelog entry**: historical engine file retained; no new changelog publish this evidence pass
- **Dependency note (Task 1102)**:
  - File-level: pilots and inventory usable; cited as route authority companion
  - Promotion: **not closed** — Status **Blocked** (screenshots); Review State Not Ready For Review; remains in `02-doing/`
  - Prior 44/100 REJECTED_TO_DOING addressed in draft for F1/F6; screenshot gate still open
- **Known residual caveats**:
  1. Screenshot-backed visual parity still blocked (shared with 1102).
  2. `apps/cybercore` route names still drift from live CC (documented §4; fix is not 1108 scope).
  3. Middleware vs full admin IA parity remains **needs-research** (1102).
  4. Historical 1108-review packet (2026-06-13) is stale vs live-route spine.
- **ready_for_reviewer**: **no**
- **Executor (original)**: builders
- **Evidence refresher**: docs/evidence (gt-evidence-refresher / parent builders)
- **Completion date**: 2026-06-08
- **Evidence refresh dates**: 2026-07-09 (path/header); 2026-07-09 (post-1102 content realign)

---

## Evidence Refresh — 2026-07-09 (post-1102 rewrite)

- **Agent**: docs/evidence
- **Lane**: left in `docs/tasks/02-doing/` per orchestrator instruction
- **Trigger**: Task 1102 full rewrite of inventory/pilot matrix to live CC routes; prior 1108 parity doc still Observatory-proxy + backend-catalog spine
- **Deliverable changes**:
  - Route authority → live `cybernetics-core/apps/frontend` `page.tsx` (28) + domain tabs
  - First-wave MVP → 1102 pilots A/B/C only
  - Explicit non-sources: Observatory paths; backend series as UI routes
  - Classification labels: MVP / pilot / defer / discard / needs-research
  - Documented Flutter mirror drift without inventing CC routes
- **Header fix**: Status/Review State aligned to Builder Done content + Not Ready For Review (1102 blocker)
- **ready_for_reviewer**: **no** — remains in `02-doing/`; Task 1102 not promoted; screenshot gate open; no lane promotion this pass

### Evidence refresh — 2026-07-09 (gt-flutter-engineer evidence batch #2)

| Check | Result |
| --- | --- |
| `docs/design/cybercore-scope-route-parity.md` | Present (394 lines) |
| Task 1102 inventory docs | Present (component 352 / vocabulary 213 / pilot matrix 171) |
| Task 1102 status | **Ready For Review** (`ready_for_reviewer: yes`); screenshots optional/deferred — **hard gate satisfied at evidence level** |
| Live CC frontend | `cybernetics-core/apps/frontend` present (sibling monorepo) |
| Docs-only (no Flutter by this task) | PASS |
| Changelog historical | Present |
| **ready_for_reviewer** | **yes** |
| Lane | **left in `02-doing/`** (no self-promote) |
| Residual | `apps/cybercore` route names still drift from live CC (documented; not 1108 fix scope) |

### Independent review — 2026-07-09 (gt-code-quality-reviewer wave)

| Field | Value |
| --- | --- |
| **Score** | **100** |
| **Lane** | moved → `docs/tasks/03-review/` |
| **Policy** | Scoped re-verify green; package-wide melos residual not mass-failed |
| **Ledger** | `.agents/profiles/reviewers/review-260709230500-wave-1106-1123-promote.md` |

### Independent re-review — 2026-07-09 (`reviewers` wave 1102–1109)

| Field | Value |
| --- | --- |
| **Score** | **100/100** |
| **Verdict** | `HELD_IN_REVIEW_PATH_TO_100` — remain `03-review/` (never `04-completed/`) |
| **Full report** | `docs/reports/review-wave-2026-07-09/task-1108-cybercore-frontend-scope-route-parity-independent-rereview.md` |
| **Live proof** | 394-line deliverable; 28 CC `page.tsx`; Read-Only Mirror; pilots A/B/C = `/providers`, MCP, `/live-logs`; Observatory-proxy non-CC |
| **Blockers** | none |

## Review Ledger


### 2026-07-17 — drain independent re-review (`reviewers` / gt-code-quality-reviewer)

- **Date**: 2026-07-17
- **Reviewer profile**: `reviewers`
- **Score**: `98/100`
- **Verdict**: `ACCEPTED_PATH_TO_100`
- **Full report**: `docs/reports/review-wave-2026-07-17/task-1108-drain-review.md`
- **Lane outcome**: `docs/tasks/04-completed/`
- **Residuals**: none blocking; 28 page.tsx confirmed

### Independent path-to-100 re-review — 2026-07-18 (BATCH R3 / reviewers)

- **Score**: **100/100**
- **Verdict**: `ACCEPTED_100`
- **Full report**: `docs/reports/review-wave-2026-07-18/task-1108-path100-rereview.md`
- **Path-to-100 applied**: YES — builders batch3 residuals re-verified live; material residuals RESOLVED; optional polish SUPERSEDED/out-of-scope
- **Lane**: moved to `docs/tasks/04-completed/`
- **Regression guards**: keep suites/commands cited in the full report
- **No git / no tasklist**

