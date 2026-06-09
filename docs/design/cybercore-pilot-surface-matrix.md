# Warp Prism — CyberCore Pilot Surface Matrix

> **Task**: 1102 — Warp Prism Control Surface Inventory
> **Date**: 2026-06-08
> **Status**: Active
> **Evidence**: Mock corpus in `assets/mock_workspace/`, CyberCore domain mapping in `docs/reports/cybercore-domain-ui-mapping-20260608.md`, ADS gap analysis in `docs/reports/ads-gap-analysis-20260608.md`, existing DS components in `lib/design_system/`

---

## 1. Objective

Select 2-3 mock workspace surfaces from the Warp Prism mock corpus that would be the best first proof targets for the CyberCore pilot. The pilot surfaces must:

1. Exercise the widest range of existing ADS components.
2. Cover the most operational states (from `operational-state-vocabulary.md`).
3. Demonstrate data storytelling (not just tables).
4. Be achievable with existing DS atoms/molecules/organisms/templates.
5. Map convincingly to real CyberCore admin surfaces.

---

## 2. Selection Criteria

| Criterion | Weight | Rationale |
|-----------|--------|-----------|
| ADS component coverage | High | Must exercise ≥5 existing DS components meaningfully |
| Operational state coverage | High | Must demonstrate ≥6 of the 15 operational states |
| Data dependency diversity | Medium | Must consume agents, skills, workflows, tasks, or changelog |
| CyberCore domain mapping | Medium | Must map to ≥1 real CyberCore entity/screen |
| Storytelling potential | Medium | Must generate narrative insights, not just data display |
| Implementation complexity | Low (tie-breaker) | Simpler is better for a first pilot |

---

## 3. Pilot Surface Candidates

### 3.1 Candidate A: Task Governance Board (Operate Surface)

**Source mock assets**: All 22 mock tasks across 5 lanes.

**What it demonstrates**:
- `DSLaneBoard` organism with 5 lanes populated from real task frontmatter
- `DSTaskCard` molecules showing priority (P0-P2), proof state (none/partial/complete), review score, owner, linked skills, dependency count
- `DSDetailInspector` organism for task detail drill-down with `DSEvidenceRow` for verification evidence
- `DSStoryPanel` with `DSStoryNarrativeInsight` for blocker clusters, review pressure, and governance warnings
- `DSFilterChipGroup` for lane/priority/owner/proof state filtering
- `DSSearchBar` for task search
- `MasterDetailTemplate` for responsive lane board + detail split

**Operational states demonstrated**:
| State | Mock Evidence |
|-------|---------------|
| pending | T001-T008 (planning/open lanes, proof_state: none) |
| running | T009-T013 (doing lane) |
| unverified | Tasks with proof_state: none (12 of 22) |
| exposed | High-priority tasks with proof_state: none (P0/P1 open tasks) |
| degraded | Tasks with proof_state: partial in doing lane (T009, T010, T012) |
| approved | T015 (review lane, proof_state: complete, review_score: 8.5) |
| rejected | T014 (title: "Review returned") |
| stale | Tasks with old updated dates in doing lane |
| promoted | T018-T022 (completed with proof_state: complete, high scores) |
| archived | Completed tasks (terminal state) |

**Total states**: 10 of 15 — **best coverage**.

**ADS components exercised**: DSLaneBoard, DSTaskCard, DSDetailInspector, DSPropertyRow, DSLinkRow, DSEvidenceRow, DSEvidenceIndicator, DSStoryPanel, DSStoryNarrativeInsight, DSStoryCardQuick, DSFilterChipGroup, DSSearchBar, DSStatusDot, DSBadge, DSChip, DSStateSurface (empty/loading/error), MasterDetailTemplate, DSText, DSIcon, DSGlassPanel, DSDivider.

**CyberCore domain mapping**:
| Mock Entity | CyberCore Equivalent |
|-------------|---------------------|
| Task (22 in 5 lanes) | WorkflowExecution, Task A2A (submitted→working→completed/failed) |
| Lane board | Task management screen |
| Proof state | Verification/compliance state |
| Review score | Quality assessment |
| Dependencies (depends_on) | Task dependency chain |
| Governance warnings | Audit findings |

**Storytelling potential**: High. Generates:
- "This review queue is dominated by code-quality and project-management tasks."
- "3 high-priority tasks have no proof — governance risk."
- "T009 blocks T010, T011, and T012 — critical path."

---

### 3.2 Candidate B: Harness Map — Skill Topology (Map Surface)

**Source mock assets**: 9 agents, 13 skills (with sub-skills, triggers, workflows, scripts, references), 11 workflows.

**What it demonstrates**:
- `DSGraphCanvas` organism in containment mode (agent→skill→subskill→workflow) and operational mode (agent→workflow→skill)
- `DSAssetCard` molecules for catalog view (agents/skills/workflows tabs)
- `DSDetailInspector` organism for asset detail with `DSPropertyRow`, `DSLinkRow` for incoming/outgoing links
- `DSProvenancePill` for canonicality visualization (parentCanonical/childLocal/generated/archive/mock)
- `DSFilterChipGroup` for kind/tag/canonicality filtering
- `CanvasTemplate` for graph+overlay layout
- `MasterDetailTemplate` for catalog+detail layout
- `DSSearchBar` for asset search

**Operational states demonstrated**:
| State | Mock Evidence |
|-------|---------------|
| healthy | Skills with triggers, workflows, and references (harness-architecture, project-management) |
| degraded | Skills with no triggers (governance diagnostic: `skillsWithNoTriggers`) |
| stale | Skills not referenced by any recent task or changelog |
| promoted | parentCanonical skills (highest trust) |
| unverified | Skills without recent changelog evidence |
| archived | Skills from archived mock corpus |
| excluded | Assets filtered out by kind/tag filter |

**Total states**: 7 of 15.

**ADS components exercised**: DSGraphCanvas, GraphNode, GraphEdge, DSAssetCard, DSDetailInspector, DSPropertyRow, DSLinkRow, DSProvenancePill, DSFilterChipGroup, DSSearchBar, DSBadge, DSChip, DSGlassPanel, CanvasTemplate, MasterDetailTemplate, DSText, DSIcon, DSStateSurface.

**CyberCore domain mapping**:
| Mock Entity | CyberCore Equivalent |
|-------------|---------------------|
| Agent (9) | AgentProfile, User (admin/operator/viewer roles) |
| Skill (13) | Capability, CapabilitySet |
| Workflow (11) | WorkflowDefinition, Hook |
| Sub-skill | Sub-capability |
| Skill triggers | Policy subject/resource bindings |
| Skill canonicality | Plugin lifecycle (registered→approved→enabled) |
| Graph edges | RouteGraph (DAG) |

**Storytelling potential**: High. Generates:
- "harness-architecture has 12 incoming references — it's the most governance-critical skill."
- "3 workflows are orphaned — not referenced by any agent or skill."
- "project-management skills dominate the task pipeline — every task depends on them."

---

### 3.3 Candidate C: Change History & Impact Story (History Surface)

**Source mock assets**: 28+ changelog entries with frontmatter (date, project, task, type, impact, skills).

**What it demonstrates**:
- `DSTimeline` and `DSTimelineGrouped` organisms for chronological and story-grouped views
- `DSTimelineMarker` molecules with type-colored badges (feature/fix/refactor/docs/chore)
- `DSFilterChipGroup` for project/type/skill/task filtering
- `DSStoryPanel` for impact story narration (changelog → task → skill/workflow)
- `TimelineTemplate` for responsive timeline+detail layout
- `DSDetailInspector` for changelog entry detail

**Operational states demonstrated**:
| State | Mock Evidence |
|-------|---------------|
| promoted | Feature entries that advanced the project (T018-T022 completions) |
| archived | Older changelog entries no longer actively impacting |
| stale | Changelog entries referencing tasks that have since been moved or closed |
| healthy | Entries with complete task linkage and impact evidence |
| unverified | Entries without linked task (governance diagnostic) |

**Total states**: 5 of 15 — **weakest coverage**.

**ADS components exercised**: DSTimeline, DSTimelineGrouped, DSTimelineMarker, DSFilterChipGroup, DSStoryPanel, DSDetailInspector, DSPropertyRow, DSLinkRow, DSBadge, DSChip, TimelineTemplate, DSText, DSIcon, DSStateSurface.

**CyberCore domain mapping**:
| Mock Entity | CyberCore Equivalent |
|-------------|---------------------|
| Changelog entry (28+) | AuditEvent (append-only, timestamped, subject/action/resource) |
| Impact paths | Audit trail: who did what to which resource |
| Type (feature/fix/refactor) | AuditEvent decision/action classification |
| Skills linkage | AuditEvent resource references |

**Storytelling potential**: Medium-high. Generates:
- "The last 5 changelog entries all relate to the parser pipeline — a sprint is happening."
- "Changelog T015 (governance audit) impacted 4 skills — high governance blast radius."

---

## 4. Recommendation: Pilot Surfaces A + B

### 4.1 Primary Pilot: Task Governance Board (Candidate A)

**Rationale**:
- **Highest operational state coverage** (10 of 15 states) — proves the vocabulary works.
- **Most ADS components exercised** (21 components) — proves the design system.
- **Strongest CyberCore mapping** — tasks, lanes, proof, review score map directly to CyberCore task/workflow management.
- **Best storytelling potential** — blocker clusters, review pressure, governance warnings generate real insights.
- **Uses MasterDetailTemplate** — proves the primary layout template.
- **Includes all proof/evidence components** — DSEvidenceRow, DSEvidenceIndicator, DSTaskCard proof indicators.

### 4.2 Secondary Pilot: Harness Map — Skill Topology (Candidate B)

**Rationale**:
- **Graph visualization** — exercises DSGraphCanvas which is unique to this surface.
- **Canonicality/provenance visualization** — DSProvenancePill with 6 canonicality states.
- **Maps to CyberCore capability/registry screens** — the most common admin surface pattern.
- **CanvasTemplate** — proves the canvas layout template.
- **Complementary to Candidate A** — exercises completely different organism set (graph vs. lane board).

### 4.3 Deferred: Change History (Candidate C)

**Rationale for deferral**:
- Fewer operational states demonstrated (5 vs. 10 and 7).
- DSTimeline is simpler than DSLaneBoard or DSGraphCanvas.
- Less CyberCore domain mapping value (AuditEvent is append-only — simpler lifecycle).
- Can be added as a third surface after Pilots A and B prove the ADS.

---

## 5. Pilot Surface A: Detailed Component-to-Mock Mapping

### 5.1 Screen Composition

```
MasterDetailTemplate
├── sidebar: DSSidebar (Overview, Map, Operate, History, Governance)
├── topbar: DSTopbar (title: "Operate", search: DSSearchBar)
├── content:
│   ├── filterBar: DSFilterChipGroup (lane, priority, owner, proof_state)
│   ├── storyPanel: DSStoryPanel (blocker clusters, review pressure)
│   └── laneBoard: DSLaneBoard
│       ├── lane "00-planning": [T001, T002, T003]
│       ├── lane "01-open": [T004, T005, T006, T007, T008]
│       ├── lane "02-doing": [T009, T010, T011, T012, T013]
│       ├── lane "03-review": [T014, T015, T016, T017]
│       └── lane "04-completed": [T018, T019, T020, T021, T022]
└── inspector (when task selected): DSDetailInspector
    ├── header: task ID, title, priority, lane
    ├── section "Metadata": DSPropertyRow (owner, created, updated, priority)
    ├── section "Dependencies": DSLinkRow per dependency
    ├── section "Skills & Workflows": DSChip per skill/workflow
    ├── section "Verification": DSEvidenceRow per exit condition
    ├── section "Proof": DSEvidenceIndicator for proof_state
    └── section "Related Changelog": DSLinkRow per changelog entry
```

### 5.2 Mock Data → Component Mapping

| Mock Task | Card Shows | States | Detail Shows |
|-----------|-----------|--------|--------------|
| T001 (planning, P0, none) | ID, title, lane=violet, P0=red dot, proof=neutral | pending, unverified | RF8 plan, no deps |
| T009 (doing, P0, partial, 7.5) | ID, title, lane=gold, P0=red, proof=yellow, score=7.5 | running, degraded, exposed | deps: T003,T006, skills: coding-execution, frontend-quality, design-system |
| T014 (review, P1, partial, 8.0) | ID, title, lane=pink, P1=yellow, proof=yellow, score=8.0 | running, degraded | "Review returned" — implies rejected cycle |
| T015 (review, P1, complete, 8.5) | ID, title, lane=pink, P1=yellow, proof=green, score=8.5 | running, approved | deps: T006,T007, governance audit |
| T018 (completed, P0, complete, 9.5) | ID, title, lane=green, P0=red, proof=green, score=9.5 | promoted, healthy, archived | agent corpus — evidence complete |

---

## 6. Pilot Surface B: Detailed Component-to-Mock Mapping

### 6.1 Screen Composition

```
CanvasTemplate
├── sidebar: DSSidebar (Overview, Map, Operate, History, Governance)
├── topbar: DSTopbar (title: "Map", search: DSSearchBar)
├── canvas: DSGraphCanvas
│   ├── mode toggle: containment / operational / evidence
│   ├── nodes: 9 agents (cyan) + 13 skills (violet) + 11 workflows (gold)
│   └── edges: agent→skill (uses), skill→workflow (contains), agent→workflow (uses)
└── overlayPanel: DSDetailInspector
    ├── header: asset name, kind icon, kind color
    ├── section "Identity": DSPropertyRow (name, description, model/mode)
    ├── section "Canonicality": DSProvenancePill
    ├── section "Triggers": DSChip per trigger
    ├── section "Sub-skills": DSLinkRow per subskill
    ├── section "Workflows": DSLinkRow per workflow
    ├── section "Incoming Links": DSLinkRow per referencing agent/skill
    └── section "Governance": DSChip.stale/degraded indicators
```

### 6.2 Mock Data → Component Mapping

| Mock Asset | Graph Node | Detail Shows | States |
|------------|-----------|--------------|--------|
| architect-orchestrator | Cyan node, label "architect..." | skills: [project-management, harness-architecture, development-methodologies], workflows: [gt-ganthritor-onboard, architect-orchestration, plan-evidence-to-tasks] | healthy |
| harness-architecture | Violet node, label "harness..." | triggers: [create agent, create skill, create workflow, harness governance], sub-skills: [create-agent, create-skill, create-workflow, harness-management], canonicality: parentCanonical | healthy, promoted |
| gt-code-review | Gold node, label "gt-code..." | uses_skills: [code-quality-harness, project-management, agent-wiki], kind: review | healthy |
| project-management | Violet node, label "project..." | 8 incoming references (highest fan-in), canonicality: parentCanonical | healthy, stale check |

---

## 7. Implementation Notes

### 7.1 Fixture-Backed Pilot

Per EPIC-11, the CyberCore pilot is **fixture-backed** — it consumes `warp_prism_ui` components with fixed mock data, not live API calls. The mock workspace corpus under `assets/mock_workspace/` provides all the data needed for both pilot surfaces.

### 7.2 No New DS Components Required

Both pilot surfaces can be built entirely with existing DS components. The only gap is the expanded `OperationalState` vocabulary (documented in `operational-state-vocabulary.md`), which enhances but is not required for the first proof.

### 7.3 Sequencing

1. **Pilot A (Task Governance Board)** — should be built first because it exercises the most components and states.
2. **Pilot B (Skill Topology)** — should be built second because it exercises the graph canvas and provenance, which are complementary.
3. **Pilot C (Change History)** — deferred until Pilots A and B are proven.

### 7.4 Test Contract

Each pilot must have:
- Widget test proving the screen renders from fixture data.
- Golden test for visual regression.
- Semantics test verifying screen reader labels.
- State coverage test verifying all expected operational states appear.

---

## 8. Risk Assessment

| Risk | Severity | Mitigation |
|------|----------|------------|
| DSGraphCanvas performance with 33 nodes | Medium | Force-directed layout is O(n²); 33 nodes is within budget. Monitor frame times. |
| MasterDetailTemplate responsive breakpoints | Low | Already tested in existing codebase; breakpoints are defined in DSBreakpoints. |
| Mock data does not cover all operational states | Low | 10 of 15 states covered by existing mock tasks. Remaining 5 (disabled, redacted, excluded, error, stale) can be demonstrated through governance diagnostics. |
| CyberCore pilot scope creep | Medium | Strictly limit to 2-3 surfaces. No new components. No live API. |

---

## 9. Source Evidence

| Source | Relevance |
|--------|-----------|
| `assets/mock_workspace/docs/tasks/` (22 tasks) | Mock task frontmatter for Pilot A |
| `assets/mock_workspace/.agents/agents/` (9 agents) | Mock agents for Pilot B |
| `assets/mock_workspace/.agents/skills/` (13 skills) | Mock skills for Pilot B |
| `assets/mock_workspace/.agents/workflows/` (11 workflows) | Mock workflows for Pilot B |
| `assets/mock_workspace/docs/changelog/` (28+ entries) | Mock changelog for deferred Pilot C |
| `docs/reports/cybercore-domain-ui-mapping-20260608.md` | CyberCore entity → UI mapping |
| `docs/reports/ads-gap-analysis-20260608.md` | ADS coverage gaps |
| `docs/design/operational-state-vocabulary.md` | 15-state vocabulary |
| `docs/design/component-inventory.md` | Full component inventory |
| `docs/design/charter.md` | Project scope and pilot mandate |
| `docs/tasks/00-planning/EPIC-11-warp-prism-cybercore-frontend.md` | CyberCore pilot epic |
| `lib/design_system/organisms/ds_lane_board.dart` | Lane board implementation |
| `lib/design_system/organisms/ds_graph_canvas.dart` | Graph canvas implementation |
| `lib/design_system/templates/master_detail_template.dart` | Layout template |
