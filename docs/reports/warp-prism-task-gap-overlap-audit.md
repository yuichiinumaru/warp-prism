# Warp Prism Task Gap / Overlap Audit

**Date**: 2026-06-06  
**Scope**: `warp-prism/docs/tasks/00-planning/` vs `warp-prism/docs/tasks/01-open/`  
**Product**: ASW Observatory / Warp Prism  
**Mode**: documentation and task-governance audit only; no Flutter application code changed.

## Executive Verdict

The Warp Prism planning-to-task wave is now broadly coherent and executable. The open lane contains **55 executable task specs** with unique task numbers after namespace remediation. Every roadmap epic from `EPIC-00` through `EPIC-10` has at least one promoted task wave, and the core prompt contract is covered by explicit tasks for:

- Atomic Design System before product screens.
- Markdown/frontmatter mock workspace under `assets/mock_workspace/`.
- One normalized graph/data backbone.
- Four top-level product workspaces: Map, Operate, History, Governance.
- Universal asset detail.
- Accessibility, responsiveness, glass-performance budget, and demo storytelling.

The audit found **no remaining namespace collision blocker**. It did find three scope-overlap hazards, and those were corrected surgically in the task specs:

1. `Task 0017` no longer recreates the app bootstrap owned by `Task 0011`; it now extends the existing bootstrap with a Design System Gallery route.
2. `Task 0410` no longer competes with `Task 0011`; it now extends the bootstrap into the product-shell route skeleton.
3. `Task 0710` no longer duplicates the base changelog corpus owned by `Task 0005`; it now enriches/verifies that corpus for History-specific story and impact coverage.

## Evidence Read

Primary planning sources:

- `warp-prism/docs/prompt.txt`
- `warp-prism/docs/research.md`
- `warp-prism/docs/draft.md`
- `warp-prism/docs/tasks/00-planning/ROADMAP-warp-prism-asw-observatory.md`
- `warp-prism/docs/tasks/00-planning/EPIC-00-warp-prism-foundation-compile-gate.md`
- `warp-prism/docs/tasks/00-planning/EPIC-01-warp-prism-atomic-design-system.md`
- `warp-prism/docs/tasks/00-planning/EPIC-02-warp-prism-mock-workspace-corpus.md`
- `warp-prism/docs/tasks/00-planning/EPIC-03-warp-prism-data-layer-graph-backbone.md`
- `warp-prism/docs/tasks/00-planning/EPIC-04-warp-prism-product-shell-overview.md`
- `warp-prism/docs/tasks/00-planning/EPIC-05-warp-prism-map-surface.md`
- `warp-prism/docs/tasks/00-planning/EPIC-06-warp-prism-operate-surface.md`
- `warp-prism/docs/tasks/00-planning/EPIC-07-warp-prism-history-surface.md`
- `warp-prism/docs/tasks/00-planning/EPIC-08-warp-prism-governance-surface.md`
- `warp-prism/docs/tasks/00-planning/EPIC-09-warp-prism-universal-asset-detail.md`
- `warp-prism/docs/tasks/00-planning/EPIC-10-warp-prism-polish-accessibility-demo-coherence.md`

Open-lane task inventory:

- `warp-prism/docs/tasks/01-open/` contains 55 files after remediation.
- Namespace remediation report: `warp-prism/docs/reports/warp-prism-task-namespace-renumbering-map.md`.
- Namespace verification task: `Task 1070` (`1070-warp-prism-task-namespace-integrity-verification`).

## Current Open Task Blocks

| Range | Planning source | Open tasks | Coverage status |
|---:|---|---|---|
| `0001`-`0006` | EPIC-02 mock workspace corpus | Contract, agents/workflows, skills, task lanes, changelog, validation/archive | Covered |
| `0010`-`0013` | EPIC-00 foundation compile gate | Analyzer audit, bootstrap, DS API normalization, README/validation baseline | Covered |
| `0014`-`0018` | EPIC-01 atomic design system | Token contract, atoms/molecules, organisms/templates, gallery, a11y focus | Covered |
| `0310`-`0315` | EPIC-03 data/graph backbone | Model audit, parser fixtures, repository, edge inference, metrics/diagnostics, providers | Covered |
| `0410`-`0413` | EPIC-04 shell/overview | Product routes, shell nav/responsive frame, overview metrics, shell states/deep links | Covered after overlap correction |
| `0510`-`0514` | EPIC-05 Map | Scaffold, catalog/filter, graph modes, selection/inspector, states/proof | Covered |
| `0610`-`0613` | EPIC-06 Operate | Task projection, lane board/filters, detail inspector, review/blocker storytelling | Covered |
| `0710`-`0713` | EPIC-07 History | History-specific corpus enrichment, parser/filter index, timeline route, story/impact views | Covered after overlap correction |
| `0810`-`0813` | EPIC-08 Governance | Canonicality boundaries, orphan/stale/proof panels, fan-in/review pressure, drilldown/story | Covered |
| `0901`-`0905` | EPIC-09 Universal Detail | Route contract, view model, skill/task variants, agent/workflow/changelog variants, responsive integration | Covered |
| `1000`-`1060` | EPIC-10 Polish/a11y/demo | Baseline audit, contrast/focus, responsive, states, glass perf, storytelling, final audit | Covered |
| `1070` | Task governance | Namespace integrity verification | Covered / gate retained |

## Prompt-to-Task Coverage Matrix

| Prompt / research requirement | Covering tasks | Audit verdict |
|---|---|---|
| Desktop-first read-only ASW Observatory | `0011`, `0410`-`0413`, `0510+`, `0610+`, `0710+`, `0810+`, `0901+` | Covered; read-only guardrails appear throughout feature tasks. |
| Atomic Design System before product screens | `0014`-`0018`, plus `1010` | Covered; `0017` corrected to avoid owning bootstrap while preserving gallery-first proof. |
| Ultradark obsidian glass with restrained accents | `0014`, `0015`, `0016`, `1010`, `1040` | Covered; performance budget explicitly separated in `1040`. |
| Readable contrast, keyboard navigation, visible focus states | `0018`, `1010`, `1020`, `1060` | Covered. |
| Mock `.agents/` agents, skills, workflows | `0001`, `0002`, `0003`, `0006`, parser tasks `0311`-`0313` | Covered. |
| Mock `docs/tasks` five-lane corpus | `0004`, `0006`, `0610` | Covered. |
| Mock `docs/changelog` corpus with 12+ entries | `0005`, `0710`, `0711` | Covered after `0710` changed to enrichment rather than duplicate creation. |
| Normalized graphable asset model | `0310`, `0313`, `0902` | Covered. |
| Asset kinds: agent, skill, subskill, workflow, task, changelog, script, reference, rule | `0310`, `0002`, `0003`, `0904` | Covered; implementation must verify all secondary kinds have fixtures/fallbacks. |
| Edge kinds: contains, routesTo, dependsOn, references, changedBy, proves, uses | `0310`, `0313`, `0314`, `0711`, `0902` | Covered. |
| Canonicality states: parentCanonical, childLocal, generated, appendOnly, archive, mock | `0310`, `0314`, `0810`, `0811` | Covered. |
| Map: Agents, Skills, Workflows, Graph tabs | `0510`, `0511`, `0512` | Covered. |
| Map graph modes: containment, operational, evidence | `0512`, backed by `0313` | Covered. |
| Operate: task lanes, proof state, blockers, review state | `0610`-`0613`, backed by `0004`, `0314` | Covered. |
| History: timeline, project story, impact story | `0710`-`0713`, backed by `0005`, `0313` | Covered. |
| Governance diagnostics: orphan/stale/proof/fan-in/review pressure | `0314`, `0810`-`0813` | Covered. |
| Universal asset detail for skills/tasks/agents/workflows/changelog | `0901`-`0905` | Covered. |
| Overview dashboard totals/story/warnings | `0412`, backed by `0314` and `0315` | Covered. |
| Empty/loading/error states | `0315`, `0413`, `0514`, `1030` | Covered. |
| Responsive shell/detail behavior | `0411`, `0413`, `0905`, `1020` | Covered. |
| Demo narrative / guided storytelling | `0412`, `0613`, `0713`, `0813`, `1050`, `1060` | Covered. |

## Overlaps Found and Disposition

### 1. App bootstrap overlap: `Task 0011`, `Task 0017`, `Task 0410`

**Problem**: Three tasks referenced creation of `lib/main.dart`, `lib/app/app.dart`, and `lib/app/router.dart`.

**Resolution applied**:

- `Task 0011` remains the owner of the minimum Flutter bootstrap.
- `Task 0017` now consumes `Task 0011` and only adds Design System Gallery route/page wiring.
- `Task 0410` now consumes `Task 0011` and expands product route skeletons for Overview/Map/Operate/History/Governance/Asset Detail.

**Residual risk**: Builders must execute `0011` before `0017` or `0410`; otherwise they may recreate bootstrap work from stale mental context.

### 2. Changelog corpus overlap: `Task 0005` and `Task 0710`

**Problem**: Both tasks attempted to create 12+ changelog markdown entries.

**Resolution applied**:

- `Task 0005` remains owner of the base EPIC-02 changelog corpus.
- `Task 0710` now enriches/verifies that base corpus for History-specific filters, story grouping, and multi-hop impact paths.

**Residual risk**: If `0710` runs before `0005`, it is blocked by missing base corpus; this is now explicit via `Depends on: Task 0005`.

### 3. Governance diagnostics overlap: `Task 0314` and `0810`-`0813`

**Problem**: Both the data-layer epic and Governance screen epic mention diagnostics.

**Disposition**: This is a healthy layer split, not a blocker.

- `Task 0314` owns computation/service contracts.
- `Task 0810`-`0813` own UI panels, analytics presentation, and drill-down storytelling.

Builders should treat `0314` as a strict dependency for Governance UI work.

### 4. Universal detail vs feature-specific inspectors

**Problem**: Map and Operate tasks include inspector/detail behavior, while EPIC-09 owns universal detail.

**Disposition**: Healthy phased split if constrained.

- `0513` and `0612` may provide feature-local summaries/inspectors.
- `0901`-`0905` own canonical universal detail route/view-model/responsive shell.
- Feature-specific inspector tasks must avoid inventing incompatible asset IDs or independent detail descriptor models.

## Gaps / Watch Items

No prompt-critical missing epic was found. Remaining gaps are sequencing or proof risks:

1. **No single builder execution sequence file exists yet.**  
   The task graph is inferable, but builders will benefit from a short execution-order guide. This report supplies the recommended sequence below; create a dedicated workflow/guide only if this becomes recurring.

2. **Task 1070 is still open despite evidence filled.**  
   It can remain open as a gate, but if the project treats filled evidence as completion, a reviewer should later move it through normal review lanes. Do not use it as a reason to renumber again unless new collisions appear.

3. **Dependencies sometimes reference whole epics instead of exact task IDs.**  
   Examples include `EPIC 03 provider contract evidence` or `EPIC 04 shell baseline`. This is acceptable for planning readability, but builders should resolve these to concrete prerequisite tasks before execution. High-value mappings:
   - EPIC-03 provider contracts → `Task 0315`.
   - EPIC-03 graph edges → `Task 0313`.
   - EPIC-03 diagnostics → `Task 0314`.
   - EPIC-04 shell baseline → `Task 0410`-`0413` depending on surface.
   - EPIC-02 mock corpus baseline → `Task 0006`.

4. **Secondary asset kinds need implementation proof.**  
   The model and detail tasks mention script/reference/rule/subskill support, but the actual fixture and parser tasks must verify those assets exist in the mock corpus. Watch `0003`, `0311`, `0313`, and `0904` during implementation.

5. **Widgetbook is recommended in research but not explicitly tasked.**  
   This is not a prompt blocker. The current DS Gallery path is sufficient for the prototype. Widgetbook can remain a future enhancement unless the user explicitly wants a widget sandbox dependency.

6. **Controlled execution hooks from research phase 3 are intentionally absent.**  
   This is correct for v1 because the prompt says read-only. Do not create tasks for mutation/execution hooks until a later product phase.

## Recommended Execution Sequence

This ordering reduces rework and respects the corrected ownership boundaries:

1. **Governance gate**: `Task 1070` if any new task wave will be added before implementation.
2. **Foundation**: `0010` → `0011` → `0012` → `0013`.
3. **Design system**: `0014` → `0015` → `0016` → `0017` → `0018`.
4. **Mock corpus**: `0001` → parallel `0002`/`0003` → `0004` → `0005` → `0006`.
5. **Data backbone**: `0310` → `0311` → `0312` → `0313` → `0314` → `0315`.
6. **Shell / overview**: `0410` → `0411` → `0412` → `0413`.
7. **Core workspaces**, parallel only after shared dependencies are in place:
   - Map: `0510` → parallel `0511`/`0512` → `0513` → `0514`.
   - Operate: `0610` → `0611` → `0612` → `0613`.
   - History: `0710` → `0711` → `0712` → `0713`.
8. **Universal detail**: `0901` → `0902` → parallel `0903`/`0904` → `0905`.
9. **Governance UI**: after `0314`, `0610+`, `0711+`, and `0901/0902` are stable: parallel `0810`/`0811`/`0812` → `0813`.
10. **Polish**: `1000` → parallel `1010`/`1020`/`1030`/`1040`/`1050` → `1060`.

## HOLD Candidates

No current open task should be moved to `HOLD-*` based on this audit. The only candidates for deferral are not current tasks:

- Widgetbook/visual-regression sandbox: useful but not required by the prompt.
- Controlled execution hooks: explicitly out of scope for read-only v1.
- Real Ganthritor ingestion: out of scope; mock workspace only.

## Files Updated by This Audit

- `warp-prism/docs/tasks/01-open/0017-warp-prism-design-system-gallery-route-bootstrap.md`
- `warp-prism/docs/tasks/01-open/0410-warp-prism-app-root-router-shell-skeleton.md`
- `warp-prism/docs/tasks/01-open/0710-warp-prism-history-fixture-ledger-corpus.md`
- `warp-prism/docs/reports/warp-prism-task-gap-overlap-audit.md`
