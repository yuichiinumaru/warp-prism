---
date: 20260709-155817
timestamp: 20260709-155817
agent: builders
task: "0710"
description: "Task 0710 — History Fixture Ledger Corpus Verification (2026-07-09)"
is_rebuild_safe: true
---

# Task 0710 — History Fixture Ledger Corpus Verification (2026-07-09)

> **Date**: 2026-07-09
> **Executor**: builders
> **Scope**: History-specific enrichment/verification of EPIC-02 mock changelog + task-lane corpus under `apps/observatory/assets/mock_workspace/`

## Summary

Closed the Task 0710 review blockers from the 78/100 NEEDS FIX verdict:

1. Parser validation now loads the **real** markdown corpus (not only synthetic fixtures).
2. `ChangelogMetadata` / History read-model now carry **workflows** for multi-hop impact paths.
3. Local changelog evidence recorded for this verification pass.
4. Corpus integrity re-proven with monorepo-aware validator + scoped Flutter tests.

This task remains a **fixture verification/enrichment** pass over the Task 0005 changelog corpus and Task 0004 lane fixtures — no second competing changelog tree was created.

## Corpus proof

| Check | Result |
| --- | --- |
| Changelog entries | 36 (`docs/changelog/*.md`) |
| Task fixtures by lane | 00-planning:3, 01-open:5, 02-doing:5, 03-review:4, 04-completed:5 (22 total) |
| Frontmatter coverage | `id`, `date`, `project`, `type`, `task`, `skills`, `impact` on 36/36; `workflows` on 18/36 |
| Broken task/skill/workflow refs | 0 |
| Multi-hop `changelog → task → skill/workflow` | ≥3 (54 resolvable paths in audit) |
| Filter facets | projects, types, tasks, skills, workflows, impact tags all non-empty |

## Code changes

| File | Change |
| --- | --- |
| `lib/data/models/changelog_contracts.dart` | Added `workflows`; map corpus `remediation` type → `fix` |
| `lib/data/parsers/workspace_markdown_parser.dart` | Parse `workflows` + `impact`/`impact_tags`; emit skill/workflow reference edges |
| `lib/data/repositories/history_repository.dart` | Propagate workflows into entries/facets; `hasMultiHopPath` |
| `test/data/parsers/workspace_markdown_parser_test.dart` | On-disk History corpus group (12+ entries, lanes, link integrity) |
| `test/data/history/history_repository_test.dart` | Workflow facet coverage |

## Validation

```text
$ python3 tool/validate_mock_workspace.py --project-root apps/observatory
VALIDATION PASSED: all checks OK

$ cd apps/observatory && dart analyze --format=machine \
    lib/data/models/changelog_contracts.dart \
    lib/data/parsers/workspace_markdown_parser.dart \
    lib/data/repositories/history_repository.dart \
    test/data/parsers/workspace_markdown_parser_test.dart \
    test/data/history/history_repository_test.dart
# no ERROR lines

$ flutter test --concurrency=1 --no-pub \
    test/data/parsers/workspace_markdown_parser_test.dart \
    test/data/history/history_repository_test.dart
# All tests passed (67)
```

### Exit-condition path note

Task text cites `test/data/parsers/workspace_parser_test.dart` (pre-monorepo name). The live monorepo surface is:

- `apps/observatory/test/data/parsers/workspace_markdown_parser_test.dart`

Full-package `flutter analyze` still reports pre-existing DS symbol errors in governance/UI packages outside this task's fixture/parser scope; scoped data-layer analyze is the authoritative gate for Task 0710.

## Why

History Timeline / Project Story / Impact Story cannot ship on sparse synthetic fixtures. The demo corpus must prove real markdown link integrity for filters and multi-hop causality without inventing in-memory-only demo objects.
