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

---

## Current-state re-audit (2026-07-09)

> Historical section above records the **2026-06-06** 55-file open-lane snapshot after renumbering.
> Most of those tasks have since moved into `02-doing` / `03-review` / `04-completed`.
> This section is the **live** namespace integrity proof for Task 1070 evidence refresh.
> Commands use repo-relative paths from `warp-prism/` (no absolute host paths).

### Scope decision

| Scope | Purpose |
| --- | --- |
| `docs/tasks/01-open/` | Exit-condition open-lane ID + structure gate (current population) |
| `docs/tasks/{01-open,02-doing,03-review,04-completed}/` | Cross-lane ID uniqueness (lane movement must not reintroduce collisions) |
| `Task 0001`–`Task 0006` refs under `docs/tasks/` | EPIC-02 wave legitimacy vs stale renumber candidates |

Flutter SDK is **not required** for this governance-only verification.

### Open-lane ID audit (live)

```bash
python3 - <<'PY'
from pathlib import Path
import re
from collections import defaultdict
root = Path('docs/tasks/01-open')
rows, errors = [], []
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
by_file = defaultdict(list)
by_header = defaultdict(list)
for file_id, header_id, name in rows:
    by_file[file_id].append(name)
    if header_id:
        by_header[header_id].append(name)
file_dupes = {k: v for k, v in by_file.items() if len(v) > 1}
header_dupes = {k: v for k, v in by_header.items() if len(v) > 1}
print(f'total_files={len(rows)}')
print(f'unique_file_ids={len(by_file)}')
print(f'unique_header_ids={len(by_header)}')
print(f'file_duplicate_ids={file_dupes}')
print(f'header_duplicate_ids={header_dupes}')
print(f'mismatch_or_missing={errors}')
PY
```

Result:

```text
total_files=1
unique_file_ids=1
unique_header_ids=1
file_duplicate_ids={}
header_duplicate_ids={}
mismatch_or_missing=[]
OPEN_LANE_ID_AUDIT: PASS
```

### Open-lane structure audit (live)

Anchored checks: header, filename/header match, lane-neutral identity block, Review State, placeholders, Where, Completion Evidence, read-before-modify signal.

```text
structure_errors=[
  '1103-warp-prism-flutter-tooling-and-scaffold.md: missing lane-neutral identity block',
  '1103-warp-prism-flutter-tooling-and-scaffold.md: missing Review State header field'
]
OPEN_STRUCTURE_AUDIT: FAIL
```

**Residual ownership**: Task 1103 is already marked **SUPERSEDED** in-file (Melos migration via Tasks 1104/1107). Structure residuals are owned by Task 1103 cancellation/narrowing, not by namespace renumbering. Filename/header for 1103 agree (`1103`/`1103`).

### All executable lanes — ID uniqueness (live)

Lane counts: `01-open=1`, `02-doing=33`, `03-review=60`, `04-completed=15` → **109** task files.

```text
all_lanes_total_files=109
unique_file_ids=108
unique_header_ids=108
file_duplicate_ids=[('1308', [
  '03-review/1308-warp-prism-toast-async-lifecycle-stabilization.md',
  '04-completed/1308-warp-prism-toast-async-lifecycle-stabilization.md'
])]
header_duplicate_ids=[same as above]
mismatch_or_missing=[]
```

**Residual**: Task 1308 appears in both `03-review` and `04-completed` (same identity, dual-lane copy). Not a multi-task ID collision from renumbering; lane hygiene residual owned by Task 1308 reviewers/completers. No filename/header mismatches anywhere.

### EPIC-02 `0001`–`0006` wave still unique

| ID | Live path |
| --- | --- |
| 0001 | `03-review/0001-warp-prism-mock-workspace-contract-baseline.md` |
| 0002 | `04-completed/0002-warp-prism-agent-and-workflow-markdown-fixtures.md` |
| 0003 | `04-completed/0003-warp-prism-skill-hierarchy-markdown-fixtures.md` |
| 0004 | `03-review/0004-warp-prism-task-lane-markdown-corpus.md` |
| 0005 | `04-completed/0005-warp-prism-changelog-markdown-corpus.md` |
| 0006 | `03-review/0006-warp-prism-mock-corpus-validation-and-legacy-archive.md` |

Renumbered waves present uniquely: `0410`–`0413`, `0510`–`0514`, `0610`–`0613`.

### `Task 0001`–`Task 0006` reference sample (2026-07-09, historical)

78 refs under `docs/tasks/`. Top hosts: EPIC-02 corpus tasks themselves, Task 1202 policy examples, Task 0710 History dependency on Task 0005, and Task 1070 explanatory text. Classification: **EPIC-02-local or explanatory** — no residual EPIC-04/05/06 collision references observed in the live sample.

### Flutter source

No `packages/` or `apps/` files modified by Task 1070 evidence refresh (governance-only).

---

## Current-state re-audit (2026-07-18)

> The **2026-07-09** section above is a **prior** live snapshot (open=1/1103;
> dual-lane 1308; 109 files / 108 unique). Drain review 2026-07-17 rejected on
> stale map currency (open 3; dual 1604–1607). This section is the **current**
> namespace integrity proof after residual collapse.

### Scope decision

| Scope | Purpose |
| --- | --- |
| `docs/tasks/01-open/` `NNNN-*.md` only | Open-lane ID + structure gate |
| `docs/tasks/{01-open,02-doing,03-review,04-completed}/` `NNNN-*.md` | Cross-lane ID uniqueness |
| Non-`NNNN-*.md` files in executable lanes | Documented hygiene (not ID collisions) |
| `Task 0001`–`Task 0006` refs | EPIC-02 wave legitimacy |

Executable tasks are files matching `^\d+-.*\.md`. EPIC planning docs do not
count toward uniqueness gates.

### Open-lane ID + structure audit (live 2026-07-18)

```text
total_files=0
unique_file_ids=0
unique_header_ids=0
file_duplicate_ids={}
header_duplicate_ids={}
mismatch_or_missing=[]
structure_errors=[]
OPEN_LANE_ID_AUDIT: PASS
OPEN_STRUCTURE_AUDIT: PASS
```

Open population is empty (drain-era optional open tasks 1522/1523/1616 are now
in `02-doing/`). SUPERSEDED 1103 structure residual is **closed as open-lane
item** — single copy lives in `04-completed/`.

### All executable lanes — ID uniqueness (live 2026-07-18)

Lane counts (**executable `NNNN-*.md` only**):
`01-open=0`, `02-doing=23`, `03-review=0`, `04-completed=126` → **149** files.

```text
all_lanes_total_files=149
unique_file_ids=149
unique_header_ids=149
file_duplicate_ids=[]
header_duplicate_ids=[]
mismatch_or_missing=[]
ALL_LANES_ID_AUDIT: PASS
```

### Prior dual-lane residuals — closed

| ID | Drain 2026-07-17 claim | Live 2026-07-18 |
| --- | --- | --- |
| 1103 | structure residual (was open) | `04-completed/` only |
| 1308 | dual review+completed (earlier) | `04-completed/` only |
| 1604 | dual doing+completed | `04-completed/` only |
| 1605 | dual doing+completed | `04-completed/` only |
| 1606 | dual doing+completed | `04-completed/` only |
| 1607 | dual doing+completed | `04-completed/` only |

**Zero dual-lane same-ID copies** among executable tasks.

### Non-executable MD in executable lanes (hygiene note)

`03-review/` currently holds **15** `EPIC-*.md` planning files (not `NNNN-`
executables). They are **not** task-ID collisions. Ownership: planning/lane
hygiene (outside Task 1070 renumbering). Executable review lane count = **0**.

### EPIC-02 `0001`–`0006` wave still unique

| ID | Live path |
| --- | --- |
| 0001 | `04-completed/0001-warp-prism-mock-workspace-contract-baseline.md` |
| 0002 | `04-completed/0002-warp-prism-agent-and-workflow-markdown-fixtures.md` |
| 0003 | `04-completed/0003-warp-prism-skill-hierarchy-markdown-fixtures.md` |
| 0004 | `04-completed/0004-warp-prism-task-lane-markdown-corpus.md` |
| 0005 | `04-completed/0005-warp-prism-changelog-markdown-corpus.md` |
| 0006 | `04-completed/0006-warp-prism-mock-corpus-validation-and-legacy-archive.md` |

Renumbered waves present uniquely: `0410`–`0413`, `0510`–`0514`, `0610`–`0613`
(0510/0511 currently `02-doing/`; rest `04-completed/`).

### `Task 0001`–`Task 0006` reference sample (2026-08-23, independent recheck — current)

**113** refs under `docs/tasks/` (`Task 0001`–`Task 0006` literal count, fresh 2026-08-23 after review-ledger refresh). Sample hosts:
EPIC-02 corpus task files, Task 1070 explanatory prose, Task 0710 / 1206
lineage. Classification: **EPIC-02-local or explanatory** — no live
EPIC-04/05/06 collision prose requiring edit under Task 1070 ownership.

> Expert re-stamp 2026-07-18 (gt-flutter-expert): open=0, dual=0, 149/149 unique,
> 0001–0006 unique under `04-completed/`, EPIC hygiene 15 non-exec in `03-review/`.
> Independent recheck 2026-08-23: executable population 167/167 unique; reference count 113.

### Flutter source

No `packages/` or `apps/` files modified by this 2026-07-18 evidence refresh
(governance-only).
