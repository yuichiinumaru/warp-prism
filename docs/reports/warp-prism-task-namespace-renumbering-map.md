# Warp Prism Task Namespace Renumbering Map

**Date**: 2026-06-06  
**Scope**: `warp-prism/docs/tasks/01-open/` executable task identity remediation  
**Related task**: Task 1070 (`1070-warp-prism-task-namespace-collision-remediation`)  

## Purpose

This report records the deterministic renumbering used to remove duplicate executable task IDs from Warp Prism open tasks. The remediation preserved EPIC-02 as the local foundational `0001`-`0006` corpus wave and moved later colliding waves into their EPIC-aligned numeric ranges.

## Renumbering Policy

- EPIC-02 mock-workspace corpus tasks remain `0001`-`0006` because they are the foundational corpus wave and their internal dependency chain was already coherent.
- EPIC-04 product shell / overview tasks move to `0410`-`0413`.
- EPIC-05 Map surface tasks move to `0510`-`0514`.
- EPIC-06 Operate surface tasks move to `0610`-`0613`.
- Existing non-colliding ranges (`0010+`, `0310+`, `0710+`, `0810+`, `0901+`, `1000+`, `1070`) are unchanged.

## Before / After Map

| Original ID | Original filename | New ID | New filename | Origin |
|---|---|---:|---|---|
| 0001 | `0001-warp-prism-app-root-router-shell-skeleton.md` | 0410 | `0410-warp-prism-app-root-router-shell-skeleton.md` | EPIC-04 |
| 0002 | `0002-warp-prism-shell-navigation-and-responsive-frame.md` | 0411 | `0411-warp-prism-shell-navigation-and-responsive-frame.md` | EPIC-04 |
| 0003 | `0003-warp-prism-overview-dashboard-derived-metrics.md` | 0412 | `0412-warp-prism-overview-dashboard-derived-metrics.md` | EPIC-04 |
| 0004 | `0004-warp-prism-shell-states-and-deep-link-fallbacks.md` | 0413 | `0413-warp-prism-shell-states-and-deep-link-fallbacks.md` | EPIC-04 |
| 0001 | `0001-warp-prism-map-workspace-scaffold.md` | 0510 | `0510-warp-prism-map-workspace-scaffold.md` | EPIC-05 |
| 0002 | `0002-warp-prism-map-catalog-tabs-and-filters.md` | 0511 | `0511-warp-prism-map-catalog-tabs-and-filters.md` | EPIC-05 |
| 0003 | `0003-warp-prism-map-graph-modes-and-adapters.md` | 0512 | `0512-warp-prism-map-graph-modes-and-adapters.md` | EPIC-05 |
| 0004 | `0004-warp-prism-map-selection-and-inspector.md` | 0513 | `0513-warp-prism-map-selection-and-inspector.md` | EPIC-05 |
| 0005 | `0005-warp-prism-map-states-and-proof-coverage.md` | 0514 | `0514-warp-prism-map-states-and-proof-coverage.md` | EPIC-05 |
| 0001 | `0001-warp-prism-operate-task-projection-contract.md` | 0610 | `0610-warp-prism-operate-task-projection-contract.md` | EPIC-06 |
| 0002 | `0002-warp-prism-operate-board-surface-filters.md` | 0611 | `0611-warp-prism-operate-board-surface-filters.md` | EPIC-06 |
| 0003 | `0003-warp-prism-operate-task-detail-inspector.md` | 0612 | `0612-warp-prism-operate-task-detail-inspector.md` | EPIC-06 |
| 0004 | `0004-warp-prism-operate-review-blocker-storytelling.md` | 0613 | `0613-warp-prism-operate-review-blocker-storytelling.md` | EPIC-06 |

## Reference Updates Applied

Changed-wave headers, filename prefixes, `Blocks`, `Depends on`, lane-neutral identity notes, and context-local internal references were updated where the old `Task 000x` references referred to the renamed EPIC-04, EPIC-05, or EPIC-06 wave.

Remaining `Task 0001`-`Task 0006` references under EPIC-02 corpus tasks are intentional and resolve to the retained EPIC-02 wave. Remaining examples inside Task 1070 describe the historical collision problem and should not be rewritten as live task dependencies.

## Verification

Duplicate-ID audit command executed from repository root:

```bash
python3 - <<'PY'
from pathlib import Path
import re
root = Path('/home/sephiroth/working/ganthritor/warp-prism/docs/tasks/01-open')
rows = []
errors = []
for path in sorted(root.glob('*.md')):
    text = path.read_text(encoding='utf-8')
    header = re.search(r'^# Task (\d{4})\b', text, re.M)
    file_id = path.name.split('-', 1)[0]
    header_id = header.group(1) if header else None
    rows.append((file_id, header_id, path.name))
    if not header_id:
        errors.append(f'MISSING_HEADER {path.name}')
    elif file_id != header_id:
        errors.append(f'MISMATCH file={file_id} header={header_id} {path.name}')
from collections import defaultdict
by_file = defaultdict(list)
by_header = defaultdict(list)
for file_id, header_id, name in rows:
    by_file[file_id].append(name)
    if header_id:
        by_header[header_id].append(name)
file_dupes = {k:v for k,v in by_file.items() if len(v)>1}
header_dupes = {k:v for k,v in by_header.items() if len(v)>1}
print(f'total_files={len(rows)}')
print(f'unique_file_ids={len(by_file)}')
print(f'unique_header_ids={len(by_header)}')
print(f'file_duplicate_ids={file_dupes}')
print(f'header_duplicate_ids={header_dupes}')
print(f'mismatch_or_missing={errors}')
if file_dupes or header_dupes or errors:
    raise SystemExit(1)
PY
```

Result:

```text
total_files=55
unique_file_ids=55
unique_header_ids=55
file_duplicate_ids={}
header_duplicate_ids={}
mismatch_or_missing=[]
```

## Notes

- No Flutter application source files were modified by this remediation.
- The remediation intentionally did not move tasks between lanes.
- The remediation corrected a false statement in Task 0010: `warp-prism/docs/draft.md` exists, but it is secondary planning evidence and must not replace fresh source and command evidence.
