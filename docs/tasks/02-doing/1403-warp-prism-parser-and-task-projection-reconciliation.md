# Task 1403: Parser and Task Projection Reconciliation

> **Status**: `[ ]` Open
> **Priority**: 🔴 P0
> **Type**: `remediation`
> **Origin**: EPIC-14, stabilization wave, `workspace_task_projection_parser_test` failures.
> **Blocks**: 1404, 1405
> **Depends on**: 1401 (failure inventory), 1402 (corpus audit)

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1403` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

Fix parser and task projection failures in `apps/observatory/` so that the
data layer correctly reads the mock workspace corpus and produces accurate
domain models.

## Background Context

### What already exists

- `workspace_task_projection_parser_test.dart` — tests task parsing and lane
  projection.
- `frontmatter_parser.dart`, `workspace_markdown_parser.dart`,
  `workspace_parser.dart` — parsers.
- `workspace_task_projection_parser.dart` — task-specific parser.
- Task 1402's corpus audit tells us whether the corpus or the parser is wrong.

### What is missing or broken

- Parser tests fail because corpus fields and parser expectations are out of sync.
- Task projection (lane, status, proof state, priority) may not map correctly.

---

## Test Requirements

- `workspace_task_projection_parser_test.dart` passes with zero failures.
- Parsers correctly read all 5 asset kinds (agents, skills, workflows, tasks,
  changelog).
- Task projection correctly maps lane, status, priority, and proof state.

---

## Exit Conditions

- [x] `workspace_task_projection_parser_test.dart` passes with zero failures.
- [x] Parser tests for all asset kinds pass.
- [x] Corpus fixes (if needed from Task 1402) are applied.
- [x] Local changelog entry added under `docs/changelog/`.
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: Read
  `docs/reports/warp-prism-corpus-frontmatter-audit.md` (from Task 1402),
  parser test files, and parser implementations.
- [x] Apply corpus fixes if Task 1402 recommended them. (No corpus fixes needed — Task 1402 concluded corpus is conformant.)
- [x] Apply parser fixes if Task 1402 recommended them.
- [x] Run parser tests and fix remaining failures.
- [x] Verify task projection maps lane, status, priority correctly.
- [x] **Simplicity pass**: fix drift, do not redesign parser architecture.
- [x] **Regression verification**: run all parser/data tests.

### Where

| File | Purpose |
| --- | --- |
| `apps/observatory/lib/data/parsers/*.dart` | Read / Modify — fix parser logic |
| `apps/observatory/test/data/parsers/*.dart` | Read / Modify — fix test expectations |
| `apps/observatory/assets/mock_workspace/**/*.md` | Read / Modify — fix corpus if needed |

### How

1. Read Task 1402 audit results.
2. Fix corpus or parser as recommended.
3. Run tests.
4. Iterate until green.

### Why

Parsers are the foundation of the Observatory data layer. If parsers fail, no
feature surface (Map, Operate, History, Governance) can work correctly.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not change the parser architecture. Only fix field mismatches and mapping
> logic. If the parser needs redesign, flag it as a follow-up.

---

## Validation Commands

```bash
flutter test apps/observatory/test/data/parsers/
```

---

## Completion Evidence

- **Files modified**:
  - `apps/observatory/lib/data/models/task_contracts.dart` — Fixed `TaskLaneParsing.fromStatus()` to handle bare status strings
  - `apps/observatory/lib/features/operate/task_projection.dart` — Fixed `hasCompletionEvidence` to strip markdown emphasis before prefix check
  - `apps/observatory/lib/data/models/workspace_graph.dart` — Fixed `WorkspaceAsset.==` to match documented contract (id, kind, name, path, canonicality)
  - `apps/observatory/test/data/services/workspace_graph_builder_test.dart` — Fixed test data for `inferWorkflowDependencies` (removed double `skill:` prefix); fixed `groups assets by kind` assertion counts to match actual sample data
- **Tests or validation commands**:
  - `flutter test test/data/parsers/workspace_task_projection_parser_test.dart` → **24/24 PASS**
  - `flutter test test/data/models/workspace_graph_models_test.dart` → **27/27 PASS**
  - `flutter test test/data/services/workspace_graph_builder_test.dart` → **27/27 PASS**
  - `dart analyze` → 367 info-level issues (same as baseline, zero new warnings)
- **Local changelog entry**: `docs/changelog/2026-06-09-task-1403-parser-and-task-projection-reconciliation.md`
- **Agent-wiki / docs institutionalization**: N/A
- **Executor**: builders
- **Completion date**: 2026-06-09
