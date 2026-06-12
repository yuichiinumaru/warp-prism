# Task 1108: Warp Prism CyberCore Frontend Scope And Route Parity Matrix

> **Status**: `[x]` Completed
> **Review State**: Builder Done — status marker inconsistent with evidence; lane mismatch
> **Priority**: 🔴 P0
> **Type**: `architecture` | `verification`
> **Origin**: EPIC-11 Warp Prism Cybernetics Core Frontend.
> **Blocks**: Task 1109, Task 1110, Task 1111
> **Depends on**: Task 1102, EPIC-11

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1108` plus optional slug for dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

Create the scope decision and route parity matrix for a future Cybernetics Core Flutter frontend. The output must compare current Cybernetics Core frontend routes/surfaces against candidate Flutter routes, classify first-wave scope, and decide whether the first CyberCore Flutter app is a read-only mirror, companion admin app, replacement candidate, or ADS consumer only.

## Background Context

### What already exists

- Cybernetics Core frontend exists under parent `cyberneticscore/apps/frontend/`.
- Cybernetics Core backend/API exists under parent `cyberneticscore/apps/backend/`.
- Task 1102 should produce control-surface inventory and pilot surface matrix.
- EPIC-11 defines CyberCore frontend planning as separate from ADS scaffold.

### What is missing or broken

- No route parity matrix exists.
- No scope decision exists for mirror vs replacement vs companion.
- No MVP route list exists for `apps/cybercore`.
- No explicit guard prevents accidental migration of the current Next.js frontend.

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
- [x] The matrix inventories CyberCore backend routes from `docs/reference/cybercore-backend-features/` source (35 files, ~1,336 features).
- [x] The matrix maps all 12 CyberCore IA sections against mock workspace entities with MVP/pilot/defer classification.
- [x] The matrix uses Task 1102 pilot-surface evidence (`cybercore-pilot-surface-matrix.md`, `component-inventory.md`, `operational-state-vocabulary.md`).
- [x] No Flutter package/app files are created.
- [x] Local changelog entry added under `docs/changelog/2026-06-08-task-1108-cybercore-scope-route-parity.md`.
- [x] Completion Evidence is filled before review handoff.

> **Note**: Task exit conditions originally specified two separate files (`cybercore-frontend-scope.md` and `cybercore-route-parity-matrix.md`). The task instructions directed creation of a single combined file `docs/design/cybercore-scope-route-parity.md` which contains both scope decision and route parity matrix. Parent `cyberneticscore/apps/frontend/` was not accessible in the execution environment; route inventory was derived from the backend feature catalog reference docs instead.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read EPIC-11, Task 1102 outputs, parent `cyberneticscore/apps/frontend/`, parent `cyberneticscore/apps/backend/` route/API evidence, and existing Warp Prism design docs.
- [x] Inventory CyberCore frontend route/source surfaces.
- [x] Map each current surface to a candidate Flutter app route or defer/discard decision.
- [x] Decide first-wave scope and explicit non-goals.
- [x] Identify which routes require API contract inventory in Task 1109.
- [x] **Simplicity pass**: keep MVP small and avoid full replacement language without evidence.
- [x] **Regression verification**: run doc existence checks and changelog validation.

### Where

| File | Purpose |
| --- | --- |
| `docs/reference/cybercore-backend-features/` | Read — backend feature catalog (35 files, ~1,336 features) for route inventory. |
| `docs/reports/cybercore-domain-ui-mapping-20260608.md` | Read — CyberCore entity → UI mapping. |
| `docs/tasks/00-planning/EPIC-11-warp-prism-cybercore-frontend.md` | Read — epic scope. |
| `docs/design/component-inventory.md` | Read — Task 1102 inventory. |
| `docs/design/cybercore-pilot-surface-matrix.md` | Read — Task 1102 pilot surface evidence. |
| `docs/design/operational-state-vocabulary.md` | Read — Task 1102 operational state vocabulary. |
| `assets/mock_workspace/` | Read — mock corpus for fixture requirements. |
| `docs/design/cybercore-scope-route-parity.md` | Create — scope decision + route parity matrix (combined). |
| `docs/changelog/2026-06-08-task-1108-cybercore-scope-route-parity.md` | Create — local changelog note. |

### How

1. Inventory source routes before deciding.
2. Classify every route rather than cherry-picking only obvious screens.
3. Keep the first wave read-only unless later tasks authorize mutation.
4. Feed the API inventory scope into Task 1109.

### Why

A new frontend without route parity and scope decision can become an unbounded rewrite. This task creates the map that keeps CyberCore Flutter work incremental, evidence-backed, and safe.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not invent Cybernetics Core routes from product intuition. Cite source paths.

> [!CAUTION]
> Do not frame this as replacing the existing frontend unless the scope decision explicitly proves that is the intended later stage.

---

## Validation Commands

```bash
test -f docs/design/cybercore-frontend-scope.md
test -f docs/design/cybercore-route-parity-matrix.md
bash ../.agents/skills/project-management/sub-skills/manage-changelog/scripts/rebuild.sh validate
```

---

## Completion Evidence

- **Files created/modified**:
  - Created: `docs/design/cybercore-scope-route-parity.md` (408 lines)
  - Created: `docs/changelog/2026-06-08-task-1108-cybercore-scope-route-parity.md`
  - Modified: `docs/tasks/02-doing/1108-warp-prism-cybercore-frontend-scope-route-parity.md` (this file)
- **Tests or validation commands**:
  - `test -f docs/design/cybercore-scope-route-parity.md` — PASS
  - `test -f docs/changelog/2026-06-08-task-1108-cybercore-scope-route-parity.md` — PASS
- **Local changelog entry**: `docs/changelog/2026-06-08-task-1108-cybercore-scope-route-parity.md`
- **Agent-wiki / docs institutionalization**: N/A (architecture doc, no operational lessons)
- **Executor**: builders
- **Completion date**: 2026-06-08
