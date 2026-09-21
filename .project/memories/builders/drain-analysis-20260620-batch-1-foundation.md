# Drain Analysis 2026-06-20 — Batch 1 Foundation

> Source: `gt-mechanical-investigator` task `ses_11caac6d4ffeuosQpXAgISBTWk`.
> Scope: `01-open/1103` plus `02-doing/0001,0004,0006,0010-0020,0310-0315`.
> Status: PARTIAL — subagent reached step limit after reading all required files and task files, but before writing full per-task schema.

## Files Read

- `AGENTS.md`
- `.agents/rules/project-boundaries.md`
- `.agents/rules/task-governance.md`
- `.agents/workflows/gt-builder-orchestrator-drain.md`
- `docs/dependency-tree.md`
- All 20 scoped task files

## Key Findings

### Critical Blocker Pattern

The subagent reported these broad blockers across the batch:

1. Old task evidence frequently says **Flutter SDK not installed**. Treat this as stale unless reproduced; current project context says Flutter 3.44.1 / Dart 3.12.1 are available.
2. **Monorepo path drift**: several tasks still reference pre-migration `warp-prism/` root paths while live code is now split across `packages/warp_prism_ui/` and `apps/observatory/`.
3. **Dependency cascade**:
   - `0010 -> 0011 -> 0012 -> 0013`
   - `0014 -> 0015 -> 0016 -> 0017 -> 0018`
   - `0019 -> 0020`
   - `0310 -> 0311 -> 0312 -> 0313 -> 0314 -> 0315`

### Quick Wins Reported

| Task | Rationale |
| --- | --- |
| `0006` | Prior approval evidence; likely monorepo-aware validator fix plus archive reconciliation. |
| `0310`, `0311`, `0312`, `0313` | Previously approved in build-gate reports but rejected/blocked by upstream validation drift; need current analyzer/test proof. |
| `0016` | Prior approval evidence; blocked mainly by `0015` dependency. |

### Hard Blockers Reported

| Blocker | Affected Tasks |
| --- | --- |
| `0010` rejected / stale foundation audit | `0011`, `0012`, `0013` |
| `0015` rejected | `0016`, `0017`, `0018` |
| `0310` rejected | `0311`-`0315` |
| Changelog evidence gaps | multiple historical tasks |

### File / Domain Collision Risks

| Domain | Tasks | Decision |
| --- | --- | --- |
| Design System | `0012`, `0014`, `0015`, `0016`, `0017`, `0018` | Serialize or bundle under one Flutter builder. |
| Bootstrap/App shell | `0010`, `0011`, `0012`, `0013`, `0017` | Serialize due app shell/router overlap. |
| Mock corpus | `0001`, `0004`, `0006`, `0019`, `0020` | Serialize corpus edits. |
| Data layer | `0310`-`0315` | Sequential chain. |

## Suggested First-Wave Candidates From Batch

1. `0006` — `reviewer_only` or narrow `fixer_then_review` after validator path/current evidence refresh.
2. `0310` — `fixer_then_review`, because it roots the data-layer chain.
3. `0311` — after `0310`, use `fixer_then_review` for YAML/fixture realism.
4. `0016` — only after `0015` resolves.

## Caveat

This batch does not contain the full per-task triage schema because the subagent hit its step limit. Use it for high-level planning only; before dispatching implementation on any scoped task, read the current task file and prior review report directly.
