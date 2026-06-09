---
id: task-numbering
title: Task Numbering Governance
scope: universal
applies_to: [all-governed-task-repos]
triggers: [task number, task id, epic block, task filename, docs/tasks]
priority: high
status: active
---

# Task Numbering Governance

> Status: Active
> Last Updated: 2026-06-06
> Scope: executable task files in `docs/tasks/01-open/` and later lanes.

## Purpose

Task numbers are operational navigation aids for executable tasks. They must
help agents find the right work lane without requiring the user to remember
every historical task.

The original chronological numbering remains valid, but large multi-project
waves may use epic-numbered blocks when chronological numbering becomes harder
to scan than domain grouping.

Planning artifacts in `00-planning/` are governed by
`.agents/rules/planning-artifact-naming.md` and MUST NOT use executable task
identity unless they are explicit historical imports.

## Accepted Numbering Modes

These modes apply to executable task files, not to roadmap, epic, story, plan,
hold, or candidate artifacts in `00-planning/`.

### 1. Legacy Sequential Mode

Use this for normal task flow and small batches.

- Format: `0xxx-projeto-descricao.md`, or the next available sequential block.
- Meaning: mostly chronological.
- Last digit guideline: `0` for a blocker/baseline task, `1-9` for
  parallelizable follow-ups when useful.

### 2. Epic Block Mode

Use this for broad waves where domain grouping is more important than strict
chronology.

- Format: `Exxx-projeto-descricao.md`, where `E` identifies the epic/domain.
- `E000` should be the baseline/gating task when a wave needs shared policy.
- `E001`-`E999` are ordered by dependency, risk, or execution priority inside
  that epic block.
- Every new epic block must have a planning/report artifact that explains:
  - block meaning;
  - execution order;
  - dependency gates;
  - review policy.

### 3. Architecture Decision / Architecture Documentation Mode

Use this for tasks whose primary output is an architecture decision record,
current architecture contract, architecture history extraction, or curated
architecture reference document rather than implementation code.

- Format: `AD-<slug>.md` or `AD-<domain>-<slug>.md`.
- The filename MUST still include the component/domain in the slug, for example
  `AD-ganthritor-storage-authority.md` or
  `AD-hyperion-ownership-boundary-extraction.md`.
- `AD-*` task files still belong in the normal task lanes and MUST satisfy the
  normal task template when promoted to `01-open/`.
- The expected output MUST be explicit in the task: ADR, architecture contract,
  history note, reference doc, or archive routing packet.
- Do not use `AD-*` for ordinary implementation tasks just because architecture
  context is involved.

### 4. Research / Reference Discovery Mode

Use this for research, reference-harvest, repository analysis, literature
review, taxonomy, benchmark-design, or evidence-acquisition tasks whose output
is not yet an implementation or accepted architecture decision.

- Format: `RD-<slug>.md` or `RD-<domain>-<slug>.md`.
- The filename MUST include the research domain or component in the slug, for
  example `RD-khala-cognitive-strategy-taxonomy.md`.
- `RD-*` task files still belong in the normal task lanes and MUST satisfy the
  normal task template when promoted to `01-open/`.
- `RD-*` outputs should route to reports, research docs, evidence matrices, or
  task-ready recommendations. Accepted decisions later become `AD-*` work or
  conventional implementation tasks.
- Do not use `RD-*` to bypass RF8, validation commands, or task evidence.

## Active Epic Blocks

| Block | Domain | Meaning |
|:--|:--|:--|
| `4xxx` | Repo stabilization and harness convergence | Pre-push hygiene, CI/CD, dirty-tree classification, publication mode, and parent/child harness convergence. |
| `5xxx` | Cybernetics Core control plane | MCP runtime/control-plane architecture and implementation slices. |
| `6xxx` | Khala memory/reasoning | Memory, retrieval, compaction, identity, and reasoning substrate. |
| `7xxx` | Ganthritor runtime | Runtime skills, tool execution, Ganthritor-py/rs boundaries, sandboxing. |
| `AD-*` | Architecture decisions and architecture documentation | ADR extraction, current architecture contracts, architecture history/reference curation. |
| `RD-*` | Research and reference discovery | Evidence acquisition, reference harvest, taxonomy, benchmark design, and research-to-task recommendations. |

## Rules

- Do not renumber an active task casually. Renumbering must leave a changelog
  entry and, when relevant, an ordering report.
- Do not assign `Task NNNN` identity to ordinary `00-planning/` artifacts.
  Use planning prefixes (`ROADMAP-*`, `EPIC-*`, `STORY-*`, `PLAN-*`, `HOLD-*`,
  `CANDIDATE-*`) until the work is promoted to `01-open/`.
- Do not create a new epic block for one-off work. Use normal sequential mode.
- Do not overload an existing epic block with unrelated work just because the
  number range is convenient.
- For child projects with their own local `docs/tasks/` tree, use a local task
  namespace starting at `0001` unless the child project roadmap explicitly
  defines another local scheme. Do not inherit parent task ranges solely because
  the project is nested in a parent checkout.
- Keep the component/project segment mandatory:
  `NNNN-projeto-descricao.md`.
- For `AD-*` and `RD-*`, keep the component/project/domain segment mandatory in
  the slug: `AD-projeto-descricao.md` or `RD-projeto-descricao.md`.
- Keep task files self-contained; numbering is navigation, not a substitute for
  explicit `Depends on` and `Blocks` metadata.
- If a report defines wave order, agents must follow that report unless a newer
  task/review explicitly supersedes it.

## Current Ordering Reference

- `docs/reports/actionable-task-wave-order-4000-7003.md`
