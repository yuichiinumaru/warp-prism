---
name: gt-builder-orchestrator-drain
description: |
  Builder-orchestrator macro workflow for draining docs/tasks/02-doing/ through
  evidence-first triage, wave planning, builder force-task execution, and handoff
  into the build review/fix loop. Designed for Warp Prism local task lanes.
triggers:
  - drain 02-doing
  - builder drain
  - drain builder lane
  - force task build drain
  - historical backlog revalidation
---

# Builder Orchestrator Drain — 02-doing Force Task Workflow

> **Purpose**: Drain `docs/tasks/02-doing/` through a disciplined builder force
> task: parallel triage, persisted analysis, collision-aware wave planning,
> specialized builder execution, then strict handoff into
> `.agents/workflows/gt-build-orchestrator-rfloop.md`.
>
> **Scope**: This workflow is for the parent builder-orchestrator operating as
> `agentID=builders`. It plans and delegates. It does not personally implement
> application code and it does not substitute its judgment for reviewer-owned
> score-based promotion.

---

## Absolute Rules

1. **No external directories.**
   - NEVER create, read, or write files outside the repository root.
   - NEVER use `/tmp/`, `/temp/`, `~/.cache/`, or any system temporary directory.
   - If temporary files are needed, create/use `tmp/` inside the repository root.
   - Every subagent dispatch MUST repeat this rule in the prompt.

2. **Use only indexed agents.**
   - Select subagents from `.agents/agents/INDEX.md`.
   - If `.agents/index-agents.md` exists, read it too.
   - Do not use generic/default task agents when a domain-specific agent exists.

3. **Builder workers do not promote.**
   - Builder/fixer subagents never move task files to `03-review/`.
   - Only reviewer subagents following `gt-build-review.md` may move tasks.

4. **Review score is official only in review.**
   - Triage analysts may produce `predicted_score` only.
   - Official score comes from reviewer-owned `gt-build-review.md` execution.

5. **No tasklist/changelog rebuild from subagents.**
   - Subagents do not rebuild generated tasklists or changelogs.
   - Parent orchestrator handles centralized generated surfaces at closeout if
     and only if real progress happened.

6. **Persist all planning output.**
   - Analysis, wave plans, execution notes, and closeout must be durable under
     `.agents/profiles/builders/`.
   - Prefer append-only notes or dated files so context compaction cannot erase
     decisions.

7. **Stop only for real blockers.**
   - Continue until `docs/tasks/02-doing/` is empty or a real architectural/user
     decision is required.

---

## Relationship To Other Workflows

This workflow owns the macro drain:

```text
gt-builder-orchestrator-drain.md
  -> triage 02-doing
  -> plan build waves
  -> dispatch builder/fixer force task
  -> hand off to review/fix loop
```

It delegates review/fix cycling to:

```text
.agents/workflows/gt-build-orchestrator-rfloop.md
```

Reviewers inside that loop must follow:

```text
.agents/workflows/gt-build-review.md
```

---

## Phase 0 — Required Preflight

Before dispatching any subagent:

1. Confirm operating identity:
   - `agentID=builders`
   - profile root: `.agents/profiles/builders/`
2. Read local governance:
   - `AGENTS.md`
   - `.agents/rules/project-boundaries.md`
   - `.agents/rules/task-governance.md`
   - `.agents/workflows/onboard.md`
3. Read agent/workflow indices:
   - `.agents/agents/INDEX.md`
   - `.agents/skills/INDEX.md` when present
   - `.agents/workflows/gt-build-orchestrator-rfloop.md`
   - `.agents/workflows/gt-build-review.md`
4. Read planning inputs when present:
   - `docs/dependency-tree.md`
   - `docs/reports/builders/harness-upgrades.md`
   - recent reports under `docs/reports/build-gate-review/`
5. Count live lanes:
   - `docs/tasks/01-open/`
   - `docs/tasks/02-doing/`
   - `docs/tasks/03-review/`
6. Create/append a session note under:
   - `.agents/profiles/builders/drain-02-doing-YYYYMMDD.md`

Preflight note template:

```markdown
# Drain 02-doing — YYYY-MM-DD

## Preflight
- 01-open count:
- 02-doing count:
- 03-review count:
- Dependency tree read: yes/no
- Harness upgrades read: yes/no
- Agent index read: yes/no
- No-external-dir rule propagated: yes
```

---

## Phase 1 — Parallel Triage Dispatch

### 1.1 Build task inventory

Inventory every file under `docs/tasks/02-doing/`.
For each task capture:

- task id
- filename
- status header
- review state header
- priority
- type
- `Blocks`
- `Depends on`
- Where table files
- Completion Evidence summary
- Review Ledger / prior rejection reports, if any

### 1.2 Split into analysis batches

Dispatch analysis subagents over bounded batches:

- 5-10 tasks per analyst for shallow/doc-heavy tasks.
- 3-5 tasks per analyst for code-heavy or ambiguous tasks.
- 1-2 tasks per analyst for high-risk architecture/runtime tasks.

Use read-only analysts where possible:

- `gt-mechanical-investigator` for mechanical task/file inventory.
- `gt-evidence-clerk` for evidence packets and report presence.
- `gt-architect` or `gt-task-architect` for dependency/blocker analysis.
- `gt-flutter-engineer` only when code-domain understanding is needed.

### 1.3 Analyst prompt contract

Every triage subagent prompt MUST include:

```text
Follow repository rules. NEVER use /tmp, /temp, ~/.cache, or any directory
outside the repository root. If temporary files are needed, use repo-local tmp/.

Read the assigned task files in docs/tasks/02-doing/. Do not modify code. Do not
move tasks. Do not rebuild tasklist/changelog.

Persist your analysis to:
.agents/profiles/builders/drain-analysis-YYYYMMDD-batch-N.md

For each task, report:
- task_id
- task_file
- status_header
- review_state_header
- task_type
- priority
- predicted_score (not official review score)
- confidence: high/medium/low
- quickwinness: high/medium/low
- impact: 1-5
- effort: 1-5
- risk: 1-5
- blockers: none/soft/hard + explanation
- depends_on
- blocks
- files_touched
- domains_touched
- suggested_builder_agent
- suggested_reviewer_agent
- parallel_safe_with
- conflicts_with
- recommended_action: reviewer_only | fixer_then_review | builder_wave | architecture_needed | blocked
- path_to_100_summary
```

### 1.4 Quickwinness rubric

Use this qualitative formula:

```text
quickwinness = impact / (effort + risk + blocker_penalty)
```

Classification:

| Quickwinness | Meaning |
| --- | --- |
| high | High impact, low effort/risk, no hard blocker |
| medium | Moderate impact or moderate effort/risk |
| low | Large effort, high risk, ambiguous evidence, or blocker |

Suggested scoring:

- `impact`: downstream unblock count, user-visible value, governance importance.
- `effort`: amount of code/docs work expected.
- `risk`: chance of regressions, shared files, runtime behavior changes.
- `blocker_penalty`: hard dependency, architecture ambiguity, failing baseline.

---

## Phase 2 — Orchestrator Synthesis

After all analysis reports are persisted:

1. Read every `.agents/profiles/builders/drain-analysis-YYYYMMDD-batch-*.md`.
2. Build a single synthesis report:
   - `.agents/profiles/builders/drain-plan-YYYYMMDD.md`
3. Create the following sections:

```markdown
# Drain Plan — YYYY-MM-DD

## Summary
- tasks analyzed:
- high quickwinness:
- medium quickwinness:
- low quickwinness:
- blocked:

## Dependency Order
| Task | Depends On | Blocks | Decision |

## File / Domain Collision Matrix
| File/Domain | Tasks | Collision Risk | Serialization Decision |

## Wave Plan
### Wave A — Quick Wins
| Bundle | Tasks | Builder Agent | Reason | Files/Domains |

### Wave B — Same-Domain Bundles
...

### Wave C — High-Risk Serialized
...

## Blockers Requiring User/Architecture
| Task | Blocker | Needed Decision |

## Review/Fix Handoff Plan
| Review Batch | Tasks | Reviewer Agent | Reason |
```

### 2.1 File/domain collision rules

- Two builders must not edit the same file concurrently.
- Tasks touching the same file should be bundled into one builder when safe.
- If tasks share a domain but not files, they may run in parallel if the domain
  contract is stable.
- Protected files require explicit task authorization and careful serialization.

### 2.2 Builder bundle sizing

A builder may receive up to 5 tasks only when:

- tasks are related by domain/files;
- combined changes are bounded;
- no conflicting implementation direction exists;
- expected effort is reasonable;
- same agent specialization applies.

Use smaller bundles when:

- task is high risk;
- task modifies app shell/router/provider/global barrel;
- task touches protected files;
- task has prior reviewer rejection with score < 70;
- task requires architecture decision.

---

## Phase 3 — Builder Force Task Dispatch

Dispatch specialized builders according to `.agents/agents/INDEX.md`.

Suggested mapping:

| Surface | Preferred Builder |
| --- | --- |
| Flutter/Dart UI, tests, Riverpod | `gt-flutter-engineer` |
| Go backend | `gt-go-engineer` |
| Rust | `gt-rust-engineer` |
| Python | `gt-python-engineer` |
| Docs/governance/evidence refresh | `gt-evidence-refresher`, `gt-archivist` |
| Architecture/spec contracts | `gt-architect`, `gt-task-architect` |
| Repo hygiene/GitOps | `gt-gitops-engineer` |
| DevOps/runtime | `gt-devops-engineer` |

### 3.1 Builder dispatch prompt contract

Every builder prompt MUST include:

```text
Follow `.agents/workflows/onboard.md` minimally with parent agentID=builders.
Write durable notes to `.agents/profiles/builders/`; do not create a new profile
folder.

NEVER use /tmp, /temp, ~/.cache, or any directory outside the repo. If temporary
files are needed, use repo-local tmp/ and ensure it is gitignored if it must
persist.

You are assigned these tasks: [task list].
Read each task file and every file in its Where table before editing.
Use the most specific existing project conventions.
Do not move tasks to 03-review.
Do not rebuild tasklist/changelog.
Do not modify unrelated files.
Return:
- tasks completed
- files changed
- commands run with exact output summary
- blockers
- notes saved path
```

### 3.2 Builder output requirements

Builders must update task files with fresh Completion Evidence when they perform
substantive fixes, but they must not promote the task.

Each builder must persist a note:

```text
.agents/profiles/builders/drain-builder-wave-<wave>-<agent-or-domain>.md
```

---

## Phase 4 — Handoff To Review/Fix Loop

After a builder wave finishes:

1. Parent reads builder outputs.
2. Parent verifies no obvious lane/file corruption.
3. Parent hands affected tasks to:

```text
.agents/workflows/gt-build-orchestrator-rfloop.md
```

The rfloop owns official build-gate review/fix cycles.

Do not skip rfloop because a builder claims completion.

---

## Phase 5 — Parent Closeout Per Wave

After rfloop returns tasks to `03-review/` or leaves them in `02-doing/` with
blockers:

1. Verify lane consistency:
   - no duplicate task file in multiple lanes;
   - status header matches lane;
   - Review State matches ledger.
2. Verify reports exist:
   - `docs/reports/build-gate-review/<task>-review*.md`
3. Verify no subagent rebuilt centralized surfaces.
4. Update centralized generated surfaces only if required and only from parent.
5. Append wave outcomes to:
   - `.agents/profiles/builders/drain-02-doing-YYYYMMDD.md`
6. Update recurring patterns in:
   - `docs/reports/builders/harness-upgrades.md`

Closeout template:

```markdown
## Wave <N> Closeout
- tasks dispatched:
- tasks moved to 03-review:
- tasks remaining in 02-doing:
- blockers:
- review/fix rounds:
- recurring failure patterns:
- harness upgrade candidates:
```

---

## Phase 6 — Repeat Until Empty

Loop:

```text
while docs/tasks/02-doing/ contains tasks:
  triage remaining tasks if needed
  update wave plan
  dispatch next builder wave
  run review/fix loop
  close out wave
```

Stop only when:

- `docs/tasks/02-doing/` is empty; or
- a real blocker requires user or architecture guidance.

Never move tasks directly to `04-completed/`.

---

## Minimal Parent Execution Checklist

- [ ] Preflight complete.
- [ ] No-external-dir rule propagated to all prompts.
- [ ] Analysis batches persisted.
- [ ] Drain plan persisted.
- [ ] File/domain collision matrix built.
- [ ] Builder waves dispatched with specific agents.
- [ ] Builders did not promote tasks.
- [ ] Review/fix loop executed.
- [ ] Reviewer-owned 100/100 promotions verified.
- [ ] Lane consistency verified.
- [ ] Harness upgrades updated.
- [ ] `02-doing/` empty or real blockers documented.
