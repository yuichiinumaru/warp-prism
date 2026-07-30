# Builder Wave Plan — 2026-07-18

**Role**: builder-orchestrator (`agentID=builders`)  
**Repo**: `warp-prism/`  
**Onboard**: parent `gt-ganthritor-onboard` (via `../../.agents/workflows/gt-ganthritor-onboard.md`) + local `onboard.md`  
**Harness maps consulted**: `builders` lane map; `index-agents.md`; `index-skills.md`

## Agent Onboarding Complete

- **Session**: 2026-07-18
- **Agent**: builder-orchestrator
- **Task**: Drain `01-open` + `02-doing` via specialized subagents
- **Key observations**:
  - Product: Flutter ASW Observatory, read-only, design-system-first (`warp_prism_ui` + apps).
  - Live lanes: 3 open (claimed → doing this wave) + 20 doing = **23 tasks**.
  - Most EPIC-15 organisms (1504–1517) are implemented but held/rejected under 100; path-to-100 is evidence + residual correctness.
  - Map tasks 0510/0511 rejected ~87–88 (independent drain).
  - Shared collision surfaces: `organisms.dart`, `prism_aliases.dart`, `design_system_gallery_*.dart`.
- **Ready to proceed**: yes

## Lane Snapshot (pre-wave)

| Lane | Count | Notes |
|------|------:|-------|
| 01-open | 0 after claim | 1522, 1523, 1616 claimed into doing |
| 02-doing | 23 | Mix of near-done + rejected + greenfield optional |
| 03-review | (not drained here) | Independent reviewer lane later |

## Domain Routing

| Domain | Engineer | Expert path-to-100 | Formal reviewer |
|--------|----------|--------------------|-----------------|
| Flutter/UI organisms & features | `gt-flutter-engineer` | `gt-flutter-expert` | `gt-flutter-code-reviewer` |
| Docs/governance integrity | `gt-archivist` | `gt-archivist` / expert | `gt-documentation-accuracy-reviewer` + flutter when code |
| Package barrel/imports | `gt-flutter-engineer` | `gt-flutter-expert` | `gt-flutter-code-reviewer` |

Core skills: `coding-execution-harness`, `flutter-harness`, `code-quality-harness`, `design-system-harness` (organisms), `project-management` (parent only).

## Dispatch Policy (host-constrained, 2026-07-18)

User override after OOM/TUI crash + parallel Go/Next load:

1. **4–5 tasks per subagent** (same area / shared surfaces), not 1–2.
2. **Max ~5–7 concurrent subagents** on this host (prefer ≤5 when Flutter + external builds).
3. **Defer heavy gates**: implement + evidence first; run `dart analyze` / `flutter test` / package gates **once at end of the agent's pack** (not per-task mid-loop). Prefer scoped package tests, not full monorepo thrash mid-wave.
4. Resume only when `task_id` still alive; after terminal death → redispatch from live disk.

## Wave A — Implementation

### Batch A1 (running/completed, legacy 1–2/task)

| Worker | Tasks | Agent | Status |
|--------|-------|-------|--------|
| A1 | 0510, 0511 | gt-flutter-engineer | running |
| A2 | 1070, 1401 | gt-archivist | running |
| A3 | 1302, 1408 | gt-flutter-engineer | running |
| A4 | 1106 | gt-flutter-engineer | running |
| A5 | 1504, 1505 | gt-flutter-engineer | **done** path-to-100 evidence |
| A6 | 1506, 1507 | gt-flutter-engineer | **done** path-to-100 evidence |
| A7 | 1508, 1509 | gt-flutter-engineer | running |

### Batch A2 (queued — 4–5 same-area packs, build/test last)

| Worker | Tasks (4–5) | Agent | Area |
|--------|-------------|-------|------|
| B1 | 1510, 1511, 1512, 1513, 1514 | gt-flutter-engineer | EPIC-15 organisms (workbench/map/hud) |
| B2 | 1515, 1517, 1522, 1523, 1616 | gt-flutter-engineer | ops/terminal + optional polish + teal skin |

Prompt rule for B*: implement all owned code first; single validation block at end of pack.

### Shared-file protocol (mandatory)

Agents may touch shared barrels only for **their** symbols:

- `packages/warp_prism_ui/lib/src/organisms/organisms.dart`
- `packages/warp_prism_ui/lib/src/prism_aliases.dart`
- `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_*.dart`

Rules: re-read before write; minimal append-only edits; never rewrite unrelated exports; if mid-air conflict, stop and report blocker to parent.

### Non-goals for workers

- Do **not** move tasks to `03-review/` or `04-completed/`.
- Do **not** run tasklist-sync, changelog publish, or agent-wiki durable writes.
- Do **not** use git.

## Wave B — Expert path-to-100 (after A)

Up to 10 `gt-flutter-expert` (or archivist for pure-doc) parallel batches over all `02-doing` tasks. Apply path-to-100 regardless of interim score; leave tasks in `02-doing`.

## Wave C — Formal parallel review (`gt-parallel-review-builder`)

`gt-flutter-code-reviewer` (+ doc reviewers where needed). Score gate:

- `S >= 90`: reviewer applies path-to-100 → 100, moves to `03-review`
- `S < 90`: leave in `02-doing` with path-to-100; dispatch fixers; re-review until 100

## Loop

Repeat fix/re-review until lane empty or real architectural blocker.
