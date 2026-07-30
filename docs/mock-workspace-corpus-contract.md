# Mock Workspace Corpus Contract

> **Task**: 0001 — Mock Workspace Contract Baseline
> **EPIC**: 02 — Warp Prism Mock Workspace Corpus
> **Status**: APPROVED
> **Date**: 2026-06-07

---

## 1. Objective

Define the migration contract for replacing the legacy `mock_workspace/` YAML corpus with a markdown-frontmatter corpus under `apps/observatory/assets/mock_workspace/`.

---

## 2. Required counts

| Asset kind    | Minimum count | Source in prompt.txt            |
|---------------|---------------|---------------------------------|
| Agents        | 9             | "Required mock agents" section  |
| Skills        | 13            | "Required mock skills" section  |
| Workflows     | 11            | "Required mock workflows" section |
| Tasks         | 20            | "Required mock tasks" section   |
| Changelog entries | 12        | "Required mock changelog entries" section |

---

## 3. Required agents (9)

```
architect-orchestrator.md
builder-orchestrator.md
reviewer-orchestrator.md
gt-harness-architect.md
gt-code-quality-reviewer.md
gt-security-reviewer.md
gt-external-intelligence-analyst.md
gt-task-architect.md
gt-wave-orchestrator.md
```

Location: `apps/observatory/assets/mock_workspace/.agents/agents/<name>.md`

Each agent `.md` file must have YAML frontmatter with at minimum:
- `name`, `model` (provider/name), `mode`, `description`, `skills` (list), `workflows` (list)

---

## 4. Required skills (13)

```
harness-architecture/
project-management/
development-methodologies/
code-quality-harness/
coding-execution-harness/
agent-wiki/
indexing-skills/
external-intelligence/
frontend-quality-harness/
design-system-harness/
browser-harness/
remediation-harness/
agent-cli-delegation/
```

Location: `apps/observatory/assets/mock_workspace/.agents/skills/<skill-name>/SKILL.md`

Each SKILL.md must have YAML frontmatter with at minimum:
- `name`, `description`, `triggers` (list), `sub_skills` (list), `canonicality`, `tags` (list)

Each super-skill directory should contain:
- `SKILL.md`, `sub-skills/`, `workflows/`, `references/`, `scripts/`

---

## 5. Required workflows (11)

```
gt-ganthritor-onboard.md
architect-orchestration.md
builder-orchestration.md
reviewer-orchestration.md
gt-create-tasks.md
plan-evidence-to-tasks.md
audit-tasks.md
gt-harness-architecture.md
gt-code-review.md
gt-verify-task-completion.md
gt-research-orchestration.md
```

Location: `apps/observatory/assets/mock_workspace/.agents/workflows/<name>.md`

Each workflow `.md` file must have YAML frontmatter with at minimum:
- `name`, `description`, `uses_skills` (list), `kind`

---

## 6. Required tasks (20+)

Distributed across 5 lanes:

```
docs/tasks/00-planning/   — planning tasks from RF8
docs/tasks/01-open/       — open/backlog tasks
docs/tasks/02-doing/      — active in-progress tasks
docs/tasks/03-review/     — review-stage tasks
docs/tasks/04-completed/  — done tasks with evidence
```

Location: `apps/observatory/assets/mock_workspace/docs/tasks/<lane>/<task-file>.md`

Each task `.md` must have YAML frontmatter with at minimum:
- `id`, `title`, `status`, `priority`, `owner`, `created`, `updated`, `skills` (list), `workflows` (list), `depends_on` (list), `proof_state`, `review_score`

Task categories must include:
- feature implementation, review returned task, completed task with evidence,
  planning task from RF8, changelog repair task, index regeneration task,
  governance audit task, frontend design-system task, graph visualization task,
  data parser task

---

## 7. Required changelog entries (12+)

Location: `apps/observatory/assets/mock_workspace/docs/changelog/<date>-<slug>.md`

Each changelog `.md` must have YAML frontmatter with at minimum:
- `id`, `date`, `project`, `task`, `type`, `impact` (list), `skills` (list)

Markdown body must include sections: `# Title`, `## Why`, `## Changed`, `## Evidence`

---

## 8. Legacy corpus mapping

The existing `mock_workspace/` tree is archived, never deleted.

| Legacy source | Action     | Target destination | Rationale |
|---------------|------------|-------------------|-----------|
| `.agents/orchestrator/agent.yaml` | archive | `.archive/mock_workspace/.agents/orchestrator/` | Name/format mismatch; prompt requires different agents in .md with frontmatter |
| `.agents/coder/agent.yaml` | archive | `.archive/mock_workspace/.agents/coder/` | Not in required agent list |
| `.agents/planner/agent.yaml` | archive | `.archive/mock_workspace/.agents/planner/` | Not in required agent list |
| `.agents/researcher/agent.yaml` | archive | `.archive/mock_workspace/.agents/researcher/` | Not in required agent list |
| `.agents/reviewer/agent.yaml` | archive | `.archive/mock_workspace/.agents/reviewer/` | Not in required agent list |
| `.agents/skills/code-review/skill.yaml` | archive | `.archive/mock_workspace/.agents/skills/code-review/` | Name/format mismatch; prompt requires different skills in SKILL.md with frontmatter |
| `.agents/skills/planning/skill.yaml` | archive | `.archive/mock_workspace/.agents/skills/planning/` | Not in required skill list |
| `.agents/skills/synthesis/skill.yaml` | archive | `.archive/mock_workspace/.agents/skills/synthesis/` | Not in required skill list |
| `.agents/skills/test-generation/skill.yaml` | archive | `.archive/mock_workspace/.agents/skills/test-generation/` | Not in required skill list |
| `.agents/workflows/code-implementation/workflow.yaml` | archive | `.archive/mock_workspace/.agents/workflows/code-implementation/` | Name/format mismatch; prompt requires different workflows in .md with frontmatter |
| `.agents/workflows/complex-task-pipeline/workflow.yaml` | archive | `.archive/mock_workspace/.agents/workflows/complex-task-pipeline/` | Not in required workflow list |
| `.agents/workflows/review-cycle/workflow.yaml` | archive | `.archive/mock_workspace/.agents/workflows/review-cycle/` | Not in required workflow list |
| `.agents/tasks/queue.md` | archive | `.archive/mock_workspace/.agents/tasks/queue.md` | Single queue file; prompt requires 20 tasks distributed across 5 lane directories |
| `docs/changelog/2025-04-10-planner-release.md` | archive | `.archive/mock_workspace/docs/changelog/` | No YAML frontmatter; prompt requires frontmatter schema |
| `docs/changelog/2025-05-15-researcher-update.md` | archive | `.archive/mock_workspace/docs/changelog/` | No YAML frontmatter |
| `docs/changelog/2025-05-20-security-audit.md` | archive | `.archive/mock_workspace/docs/changelog/` | No YAML frontmatter |
| `docs/changelog/2025-05-28-orchestrator-update.md` | archive | `.archive/mock_workspace/docs/changelog/` | No YAML frontmatter |
| `docs/changelog/2025-06-01-coder-update.md` | archive | `.archive/mock_workspace/docs/changelog/` | No YAML frontmatter |

**Policy**: All 18 legacy files move to `.archive/mock_workspace/` preserving directory structure. No destructive deletion.

---

## 9. Parser deltas and model deltas for EPIC 03

### 9.1 Current state (models.dart)

| Aspect | Current value |
|--------|--------------|
| Backbone enum | `AssetType { agent, skill, workflow, task, doc }` |
| Edge model | `AssetEdge { sourceId, targetId, edgeType: String }` — freeform string type |
| Canonicality | Not modeled |
| Base class | `Asset` with `id, name, description, version, createdAt, updatedAt, tags, metadata` |
| Agent model | Rich: status, model, systemPrompt, capabilities, tools, skillIds, workflowIds |
| Skill model | Has inputs/outputs/steps (pipeline-oriented), usedByAgentIds |
| Workflow model | Has trigger, stages, errorHandling, avgDurationMinutes, successRate |
| Task model | Has status, priority, assignedAgentId, workflowId, startedAt, completedAt, progress |
| Changelog model | Has summary, changes (ChangeSection), affectedAssets, evidence, author |
| Frontmatter | Not parsed; files are pure YAML or heading-based markdown |

### 9.2 Target state (prompt.txt contract)

| Aspect | Target value |
|--------|-------------|
| Backbone enum | `AssetKind { agent, skill, subskill, workflow, task, changelog, script, reference, rule }` |
| Edge enum | `EdgeKind { contains, routesTo, dependsOn, references, changedBy, proves, uses }` |
| Canonicality enum | `{ parentCanonical, childLocal, generated, appendOnly, archive, mock }` |
| Base class | `WorkspaceAsset { id, kind, name, path, description, canonicality, frontmatter, tags, triggers, edges }` |
| Edge class | `WorkspaceEdge` (graph-normalized) |
| Agent model | Flat frontmatter: name, model (string), mode, description, skills (list), workflows (list) |
| Skill model | Frontmatter: name, description, triggers, sub_skills, canonicality, tags; body is markdown |
| Workflow model | Frontmatter: name, description, uses_skills, kind; body is markdown |
| Task model | Frontmatter: id, title, status, priority, owner, created, updated, skills, workflows, depends_on, proof_state, review_score; body is markdown with Goal/Scope/Exit Conditions/Verification Commands/Completion Evidence |
| Changelog model | Frontmatter: id, date, project, task, type, impact, skills; body is markdown with Why/Changed/Evidence |
| Frontmatter | YAML frontmatter delimited by `---` at top of every `.md` file |

### 9.3 Required parser changes (EPIC 03)

1. **Frontmatter extraction**: New `parseFrontmatter(String content)` that splits on `---` delimiters and returns `(Map<String, dynamic> frontmatter, String body)`.

2. **Agent parser rewrite**: Replace `parseAgent(yamlContent)` — parse frontmatter from .md, extract `name`, `model` (string, not sub-object), `mode`, `description`, `skills`, `workflows`.

3. **Skill parser rewrite**: Replace `parseSkill(yamlContent)` — parse frontmatter from .md, extract `name`, `description`, `triggers`, `sub_skills`, `canonicality`, `tags`. Body is markdown, not structured YAML.

4. **Workflow parser rewrite**: Replace `parseWorkflow(yamlContent)` — parse frontmatter from .md, extract `name`, `description`, `uses_skills`, `kind`. Body is markdown.

5. **New task parser**: `parseTask(String content, String id)` — extract frontmatter fields. No task parser exists currently.

6. **Changelog parser rewrite**: Replace `parseChangelog()` heading-based parser with frontmatter extraction: `id`, `date`, `project`, `task`, `type`, `impact`, `skills`.

7. **Graph normalizer**: Build `WorkspaceEdge` list from cross-references in frontmatter (agent.skills -> skill, agent.workflows -> workflow, workflow.uses_skills -> skill, task.skills -> skill, task.workflows -> workflow, task.depends_on -> task, changelog.task -> task).

### 9.4 Required model changes (EPIC 03)

1. Add `AssetKind` enum (replace or supplement `AssetType`).
2. Add `EdgeKind` enum (replace freeform string `edgeType`).
3. Add `Canonicality` enum.
4. Add `WorkspaceAsset` class with `frontmatter: Map<String, dynamic>`, `canonicality`, `edges: List<WorkspaceEdge>`.
5. Add `WorkspaceEdge` class with typed `EdgeKind`.
6. Restructure `Agent` to match frontmatter schema (drop `AgentModel`, `AgentTool`, `ToolParameter`, `systemPrompt`, `capabilities`).
7. Restructure `Skill` to match frontmatter schema (drop `SkillInput`, `SkillOutput`, `SkillStep`; add `triggers`, `sub_skills`, `canonicality`).
8. Restructure `Workflow` to match frontmatter schema (drop `WorkflowTrigger`, `WorkflowStage`, `WorkflowErrorHandling`, `RetryPolicy`, `FallbackRule`; add `uses_skills`, `kind`).
9. Restructure `Task` to match frontmatter schema (add `owner`, `skills`, `workflows`, `depends_on`, `proof_state`, `review_score`).
10. Restructure `ChangelogEntry` to match frontmatter schema (add `project`, `task`, `type`, `impact`, `skills`; simplify body).

---

## 10. Target directory structure

```
apps/observatory/assets/mock_workspace/
  manifest.yaml              ← this file
  .agents/
    agents/
      architect-orchestrator.md
      builder-orchestrator.md
      reviewer-orchestrator.md
      gt-harness-architect.md
      gt-code-quality-reviewer.md
      gt-security-reviewer.md
      gt-external-intelligence-analyst.md
      gt-task-architect.md
      gt-wave-orchestrator.md
    skills/
      harness-architecture/
        SKILL.md
        sub-skills/
        workflows/
        references/
        scripts/
      project-management/
        SKILL.md
        ...
      (13 super-skill directories total)
    workflows/
      gt-ganthritor-onboard.md
      architect-orchestration.md
      (11 workflow .md files total)
  docs/
    tasks/
      00-planning/
      01-open/
      02-doing/
      03-review/
      04-completed/
    changelog/
      (12+ changelog .md files)
```
