# Task de-dupe archive log — 2026-07-17

Older / lower-lane duplicates moved with `shutil.move` (**never deleted**).

## Keep rule

1. Prefer lane: `04-completed` > `03-review` > `02-doing` > `01-open` > `00-planning`
2. Then newer `mtime`
3. Then higher task id (when same slug)

## Moves this session

| From | To | Kept |
| --- | --- | --- |
| `docs/tasks/02-doing/1604-warp-prism-agent-transcript-organism.md` | `.archive/tasks/1604-warp-prism-agent-transcript-organism.md` | `docs/tasks/04-completed/1604-…` |
| `docs/tasks/02-doing/1605-warp-prism-tool-call-card-message-status-history.md` | `.archive/tasks/1605-warp-prism-tool-call-card-message-status-history.md` | `docs/tasks/04-completed/1605-…` |
| `docs/tasks/02-doing/1606-warp-prism-artifact-workbench-organism.md` | `.archive/tasks/1606-warp-prism-artifact-workbench-organism.md` | `docs/tasks/04-completed/1606-…` |
| `docs/tasks/02-doing/1607-warp-prism-provider-health-matrix-organism.md` | `.archive/tasks/1607-warp-prism-provider-health-matrix-organism.md` | `docs/tasks/04-completed/1607-…` |

## Second pass (slug / title / content-hash)

No additional duplicates found under `docs/tasks/{00-planning,01-open,02-doing,03-review,04-completed}/` (excluding EPIC/ROADMAP planning files).

## Post-state

- Multi-lane same task ID: **0**
- `02-doing/`: rejects + EPIC-15 organisms that were never in the 03-review drain set (1504–1515, etc.)

