# Review Backlog Snapshot — Warp Prism Task Lane Reconciliation

> **Generated**: 2026-06-11
> **Authority**: Task 1208 (Existing Task Lane Reconciliation)
> **Scope**: All current executable task files in `docs/tasks/02-doing/`
> **Total tasks classified**: 95
> **Live count command**: `ls docs/tasks/02-doing/*.md | wc -l` → `95`

This refresh reconciles the review backlog snapshot to the live `02-doing/`
lane. The reviewer note cited 98 tasks, but the live filesystem at refresh time
contains 95 markdown task files after Task 1205's own approved move to
`03-review/`. This snapshot uses the live filesystem as the source of truth and
does not move lanes.

---

## 1. Evidence Basis

| Source | Canonical path | Use in this snapshot |
| --- | --- | --- |
| Builder promotion state model | `.agents/rules/promotion-state-model.md` | State vocabulary and gate semantics |
| Canonical governance model | `docs/governance/promotion-state-model.md` | Governance reference and lane-state examples |
| Failure baseline | `docs/reports/warp-prism-test-failure-baseline.md` | Pre-existing UI and Observatory failure evidence |
| Test gate matrix | `docs/governance/test-gate-matrix.md` | Gate requirements by task type |
| Review report | `docs/reports/build-gate-review/1208-review.md` | Re-review findings and Path to 100 checklist |
| Snapshot report | `docs/reports/warp-prism-review-backlog-snapshot.md` | This refreshed report |

---

## 2. Category Mapping

Task-contracted category vocabulary is kept alongside promotion-state labels.

| Task-contracted category | Promotion states mapped here | Count | Meaning in this snapshot |
| --- | --- | ---: | --- |
| `DONE_READY_FOR_REVIEW` | `Ready For Review` | 0 | No current `02-doing/` task is classified as ready for independent review by this refresh. |
| `PARTIAL_BLOCKED` | `Blocked`, `Builder Done`, `Package Gate Failed`, `Doing` | 92 | Work is claimed or partially verified, but a gate, dependency, or evidence gap remains. |
| `NEEDS_REPAIR` | `Open` in `02-doing/` | 3 | Unstarted or clearly not-ready tasks are incorrectly sitting in the active lane. |
| `SUPERSEDED` | `Superseded` | 0 | No current `02-doing/` task was classified as superseded by this refresh. |
| **Total** | — | **95** | Matches the live `docs/tasks/02-doing/*.md` count. |

---

## 3. Summary by Promotion State

| Promotion State | Task-contracted category | Count | % of Total | Can Move to 03-review? |
| --- | --- | ---: | ---: | :---: |
| Blocked | PARTIAL_BLOCKED | 47 | 49.5% | No |
| Builder Done | PARTIAL_BLOCKED | 25 | 26.3% | No |
| Package Gate Failed | PARTIAL_BLOCKED | 18 | 18.9% | No |
| Doing | PARTIAL_BLOCKED | 2 | 2.1% | No |
| Open | NEEDS_REPAIR | 3 | 3.2% | No |
| Ready For Review | DONE_READY_FOR_REVIEW | 0 | 0.0% | N/A |
| **Total** | — | **95** | **100.0%** | — |

---

## 4. Task Index by Task-Contracted Category

### 4.1. DONE_READY_FOR_REVIEW (0)

No current `docs/tasks/02-doing/*.md` task is classified as
`DONE_READY_FOR_REVIEW` in this refresh.

### 4.2. PARTIAL_BLOCKED (92)

| Task | Title | Promotion State | Evidence / blocker |
| --- | --- | --- | --- |
| 0002 | Warp Prism Agent And Workflow Markdown Fixtures | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 0003 | Warp Prism Skill Hierarchy Markdown Fixtures | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 0005 | Warp Prism Changelog Markdown Corpus | Builder Done | Implementation evidence missing; needs verification. |
| 0006 | Warp Prism Mock Corpus Validation And Legacy Archive | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 0010 | Warp-Prism Foundation Audit Analyzer Baseline | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 0011 | Warp-Prism Bootstrap Main Router Shell | Builder Done | Prior annotation records Builder Done; gate verification not captured here. |
| 0012 | Warp-Prism Design System API Normalization | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 0013 | Warp-Prism Validation Baseline README Alignment | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 0014 | Warp Prism DS Token Contract and Inventory | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 0015 | Warp Prism DS Atoms and Molecules Normalization | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 0016 | Warp Prism DS Organisms and Templates Alignment | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 0017 | Warp Prism Design System Gallery Route Bootstrap | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 0018 | Warp Prism DS Accessibility and Focus Baseline | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 0019 | Warp Prism Preset Workspace Snapshot Starter | Builder Done | Completion evidence filled; no gate verification recorded. |
| 0020 | Warp Prism Enhanced Workspace Snapshot — Search, Detail, Graph | Builder Done | Completion evidence filled; no gate verification recorded. |
| 0310 | Warp-Prism Backbone Model Contract Audit | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 0311 | Warp-Prism Markdown Frontmatter Parser Fixtures | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 0312 | Warp-Prism Read-Only Mock Workspace Repository | Builder Done | Prior annotation records Builder Done; gate verification not captured here. |
| 0313 | Warp-Prism Graph Normalization And Edge Inference | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 0314 | Warp-Prism Derived Metrics Governance Diagnostics | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 0315 | Warp-Prism Provider Load State View Model Contracts | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 0410 | Warp Prism App Root Router Shell Skeleton | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 0411 | Warp Prism Shell Navigation And Responsive Frame | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 0412 | Warp Prism Overview Dashboard Derived Metrics | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 0413 | Warp Prism Shell States And Deep Link Fallbacks | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 0510 | Map workspace scaffold and route contract | Builder Done | Prior annotation records Builder Done; gate verification not captured here. |
| 0511 | Map catalog tabs, cards, and filter interactions | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 0512 | Map graph modes and projection adapters | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 0513 | Map selection state and inspector integration | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 0514 | Map empty/loading/error states and proof coverage | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 0610 | Warp-Prism Operate Task Projection Contract | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 0611 | Warp-Prism Operate Board Surface and Filters | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 0612 | Warp-Prism Operate Task Detail Inspector | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 0613 | Warp-Prism Operate Review and Blocker Storytelling | Builder Done | Implementation evidence missing; needs verification. |
| 0710 | Warp Prism History Fixture Ledger Corpus | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 0711 | Warp Prism History Parser And Filter Index | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 0712 | Warp Prism History Workspace Timeline Route | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 0713 | Warp Prism History Story And Impact Views | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 0810 | Warp-Prism Governance Canonicality Boundaries Overview | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 0811 | Warp-Prism Governance Orphan Stale Proof Panels | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 0812 | Warp-Prism Governance Fan-In And Review Pressure Analytics | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 0813 | Warp-Prism Governance Drill-Down And Storytelling | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 0901 | Warp-Prism Asset Detail Route Contract | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 0902 | Warp-Prism Universal Asset Detail View Model | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 0903 | Warp-Prism Skill And Task Detail Variants | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 0904 | Warp-Prism Agent Workflow Changelog Detail Variants | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 0905 | Warp-Prism Responsive Detail Shell Integration | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 1000 | Warp-Prism Polish Baseline Audit | Builder Done | Docs/governance deliverable complete; gate verification not applicable or not rerun here. |
| 1010 | Warp-Prism Accessibility Contrast and Focus Pass | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 1020 | Warp-Prism Responsive Shell and Detail Pass | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 1030 | Warp-Prism Empty, Loading, and Error State Coherence | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 1040 | Warp-Prism Glass Performance Budget Pass | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 1050 | Warp-Prism Storytelling and Demo Narrative Pass | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 1060 | Warp-Prism EPIC 10 Acceptance Audit | Builder Done | Docs/governance deliverable complete; gate verification not applicable or not rerun here. |
| 1070 | Warp-Prism Task Namespace Integrity Verification | Blocked | Flutter SDK/tooling blocker retained from prior task annotation; validation not rerun in this refresh. |
| 1102 | Warp Prism Control Surface Inventory | Builder Done | Docs/governance deliverable complete; gate verification not applicable or not rerun here. |
| 1105 | Warp Prism Token Theme Catalog Policy | Builder Done | Status marker inconsistent with evidence; lane mismatch. |
| 1106 | Warp Prism Operational Component MVP | Package Gate Failed | Pre-existing gallery compilation errors block full package gate. |
| 1107 | Warp Prism Melos Monorepo Migration | Package Gate Failed | Monorepo migration implemented; Melos/Flutter gate blocked. |
| 1108 | Warp Prism CyberCore Frontend Scope And Route Parity Matrix | Builder Done | Status marker inconsistent with evidence; lane mismatch. |
| 1109 | Warp Prism CyberCore API Data Contract Inventory | Builder Done | Status marker inconsistent with evidence; lane mismatch. |
| 1110 | Warp Prism CyberCore Fixture Backed App Shell MVP | Builder Done | Status marker inconsistent with evidence; lane mismatch. |
| 1111 | Warp Prism CyberCore Pilot Mirror And Expansion Gate | Builder Done | Status marker inconsistent with evidence; lane mismatch. |
| 1112 | Warp Prism Data Table Component | Package Gate Failed | Pre-existing gallery compilation errors block full package gate. |
| 1113 | Warp Prism Command Palette | Package Gate Failed | Pre-existing gallery compilation errors block full package gate. |
| 1114 | Warp Prism Log Viewer Component | Package Gate Failed | Pre-existing gallery compilation errors block full package gate. |
| 1115 | Warp Prism Loading Skeleton And Error Boundary | Package Gate Failed | Pre-existing gallery compilation errors block full package gate. |
| 1116 | Warp Prism Notification Toast System | Package Gate Failed | Pre-existing gallery compilation errors block full package gate. |
| 1117 | Warp Prism Graph Visualization Refactor — Model/Layout/Painter Split | Package Gate Failed | Pre-existing gallery compilation errors block full package gate. |
| 1119 | Warp Prism Health Dashboard Components | Package Gate Failed | Pre-existing gallery compilation errors block full package gate. |
| 1120 | Warp Prism Drag And Drop Task Board | Package Gate Failed | Pre-existing gallery compilation errors block full package gate. |
| 1121 | Warp Prism Code Block And Markdown Renderer | Package Gate Failed | Pre-existing gallery compilation errors block full package gate. |
| 1122 | Warp Prism Tab Bar And Split Pane | Package Gate Failed | Pre-existing gallery compilation errors block full package gate. |
| 1123 | Warp Prism Virtual Scroll Optimization | Package Gate Failed | Pre-existing gallery compilation errors block full package gate. |
| 1202 | Promotion State Model Definition | Builder Done | Prior annotation records Builder Done; gate verification not captured here. |
| 1204 | Melos Test Script Normalization | Builder Done | Completion evidence filled; gate verification pending. |
| 1206 | Pre-existing Failure Classification Policy | Builder Done | Governance validation gates pass; parent promotion check pending. |
| 1208 | Existing Task Lane Reconciliation and Review Backlog Snapshot | Builder Done | Completion evidence filled; gate verification pending. |
| 1301 | Prism Namespace Remediation | Builder Done | Completion evidence filled; gate verification pending. |
| 1302 | Public Barrel Audit | Builder Done | Public barrel audit evidence filled; gate verification pending. |
| 1303 | Component Contract Reconciliation | Builder Done | Component contract evidence filled; full package gate not rerun in this refresh. |
| 1304 | Gallery Compile Boundary Cleanup | Package Gate Failed | Gallery compile boundary blocker documented by failure baseline; full package gate not verified. |
| 1305 | Catalog Contract Expansion | Blocked | Depends on Task 1304 gallery compile boundary cleanup; package gate not verified. |
| 1306 | Golden Baseline MVP | Doing | Legacy In Progress marker; golden baseline work claimed but full gate verification pending. |
| 1307 | Accessibility and Semantics Reconciliation | Package Gate Failed | Accessibility/semantics failures documented by failure baseline; full package gate not verified. |
| 1309 | State Vocabulary Surface Reconciliation | Doing | EPIC-13 stabilization task with filled evidence; status marker is stale. |
| 1401 | Observatory Failure Baseline Inventory | Builder Done | Observatory failure inventory evidence filled; gate verification pending. |
| 1402 | Corpus and Frontmatter Contract Audit | Builder Done | Corpus/frontmatter audit evidence filled; gate verification pending. |
| 1403 | Parser and Task Projection Reconciliation | Builder Done | Parser reconciliation evidence filled; status marker is stale. |
| 1404 | View-model and Mapper Contract Reconciliation | Package Gate Failed | Observatory pre-existing failures remain; full package gate not green. |
| 1405 | Detail Variant and Responsive Shell Reconciliation | Package Gate Failed | Detail reconciliation evidence filled; observatory package gate not green. |
| 1408 | Observatory Package Imports Cleanup | Package Gate Failed | Observatory pre-existing failures remain; import cleanup evidence filled. |

### 4.3. NEEDS_REPAIR (3)

| Task | Title | Promotion State | Evidence / blocker |
| --- | --- | --- | --- |
| 1101 | Warp Prism Charter And Naming Convergence | Open | Unstarted task; lane mismatch (should be in 01-open/). |
| 1406 | History and Operate Feature Flow Reconciliation | Open | Unstarted task; lane mismatch (should be in 01-open/). |
| 1407 | Legacy Test Retirement or Rewrite Audit | Open | Unstarted task; lane mismatch (should be in 01-open/). |

### 4.4. SUPERSEDED (0)

No current `docs/tasks/02-doing/*.md` task was classified as `SUPERSEDED` in
this refresh.

---

## 5. Header Review State Coverage

| Check | Result |
| --- | --- |
| Live `02-doing/` task count | 95 |
| Current task files missing header-level `Review State` | 0 |
| Current task files with more than one header-level `Review State` | 0 |
| Validation method | Header-aware first-15-line scan for `> **Review State**:` |

Header-aware validation command:

```bash
python - <<'PY'
from pathlib import Path
import re, sys
files = sorted(Path('docs/tasks/02-doing').glob('*.md'))
failures = []
for path in files:
    lines = path.read_text(errors='replace').splitlines()[:15]
    count = sum(1 for line in lines if re.match(r'^>\s+\*\*Review State\*\*:', line))
    if count != 1:
        failures.append((str(path), count))
if failures:
    print('HEADER_REVIEW_STATE_CHECK: FAIL')
    for path, count in failures:
        print(f'{path}: header_review_state_count={count}')
    sys.exit(1)
print(f'HEADER_REVIEW_STATE_CHECK: OK total_files={len(files)} every_file_has_exactly_one_header_review_state=True')
PY
```

Expected output after this refresh:

```text
HEADER_REVIEW_STATE_CHECK: OK total_files=95 every_file_has_exactly_one_header_review_state=True
```

---

## 6. Anomalies and Remediation Notes

1. **Live count drift**: The reviewer note cited 98 tasks. The live lane command
   returns 95 after Task 1205's own approved lane movement to `03-review/`; this
   snapshot uses the live filesystem count and does not move lanes.
2. **Lane mismatches**: 3 tasks are `Open` while sitting in `02-doing/`; parent
   approval is required before moving any task to `01-open/`.
3. **Ready candidates**: No current `02-doing/` task is mapped to
   `DONE_READY_FOR_REVIEW` by this refresh.
4. **Package gate failures**: UI gallery, accessibility/semantics, and
   Observatory pre-existing failure evidence is now sourced from
   `docs/reports/warp-prism-test-failure-baseline.md` and
   `docs/governance/test-gate-matrix.md`.
5. **No superseded tasks**: No current `02-doing/` task was marked
   `SUPERSEDED` by this refresh.

---

## 7. References

- **Builder promotion state model**: `.agents/rules/promotion-state-model.md`
- **Canonical governance model**: `docs/governance/promotion-state-model.md`
- **Failure baseline**: `docs/reports/warp-prism-test-failure-baseline.md`
- **Test gate matrix**: `docs/governance/test-gate-matrix.md`
- **Task 1208 review report**: `docs/reports/build-gate-review/1208-review.md`
- **Task 1208 task file**: `docs/tasks/02-doing/1208-warp-prism-existing-task-lane-reconciliation.md`
- **Local changelog**: `docs/changelog/2026-06-09-task-1208-existing-task-lane-reconciliation.md`
