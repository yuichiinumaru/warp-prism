# Task Reference Policy

> **Status**: Active  
> **Scope**: Ganthritor task references in task files, review ledgers, reports,
> architecture documents, changelog summaries, and agent harness guidance.

## Core Rule

Task identity is lane-neutral.

- Canonical identity: `Task NNNN` plus optional slug, for example
  `Task 8270` or `Task 8270 (8270-khala-evidence-record-schema-lifecycle-contract)`.
- Lane/status is mutable workflow state: `00-planning`, `01-open`, `02-doing`,
  `03-review`, and `04-completed` are not task identity.
- Current task location is resolved from `docs/tasks/tasklist.md` or by searching
  under `docs/tasks/` for the task number/slug.

## Preferred Reference Forms

Use these forms for live dependencies, architecture references, reports, and
task handoffs:

```markdown
Task 8270
Task 8270 (`8270-khala-evidence-record-schema-lifecycle-contract`)
```

When a document needs to explain that the lane is intentionally variable, this
placeholder is allowed as explanatory text only:

```markdown
docs/tasks/<task-status>/8270-khala-evidence-record-schema-lifecycle-contract.md
```

Do not present the placeholder as a literal filesystem path to read.

## Lookup Mechanism

When an agent needs the live task file, resolve it through one of these surfaces:

```bash
fd 8270 docs/tasks
```

or inspect the generated tasklist:

```markdown
docs/tasks/tasklist.md
```

Do not edit `docs/tasks/tasklist.md` manually. Rebuild it only through the
approved tasklist sync workflow when a parent orchestrator owns generated
surface updates.

## Historical Evidence

Historical evidence may record status or lane-at-time without rewriting old
task lane paths after every move.

Preferred examples:

```markdown
Execution-time status: `02-doing`
Reviewed while task was in `03-review`.
Lane outcome: returned to doing.
Lane outcome: accepted/completed.
```

Historical references to `docs/tasks/<lane>/...` are not automatically stale
truth claims. They may describe the path observed during execution or review.

## Review Scoring Policy

Reviewers MUST NOT score down or block solely because a historical evidence
entry contains an old lane segment such as `docs/tasks/02-doing/...` when the
task identity is clear.

Lane-path drift is only a blocker when it causes at least one of these semantic
failures:

1. an incorrect current operational instruction;
2. broken dependency semantics;
3. inability to identify the intended task;
4. a false current-state/status claim that affects completion or review truth.

Phantom-completion checks remain mandatory. Incorrect status claims, missing
evidence, false completion, stale validation, broken dependencies, and invalid
lane/header/status consistency are still blockers even if task references use
lane-neutral wording.

## Migration Policy

Do not bulk rewrite historical changelogs, reports, or task evidence solely to
replace lane-specific task paths. Prefer targeted edits only when a lane-specific
path creates a current operational risk or confuses task identity.

Future task templates, review ledgers, reports, and architecture docs should use
lane-neutral task IDs and slugs by default.
