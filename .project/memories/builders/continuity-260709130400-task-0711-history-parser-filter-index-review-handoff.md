---
type: continuity
title: "task-0711-history-parser-filter-index-review-handoff"
agent: builders
created: 2026-07-09T13:04:00
date: 2026-07-09
---

# task-0711-history-parser-filter-index-review-handoff

# Task 0711 History Parser/Filter Index — Ready For Review

## Current focus
Closed Task 0711 rejection (78→100 self-score). Moved to `docs/tasks/03-review/`.

## What changed
- `HistoryRepository`: preserve malformed entries (`isMalformed`/`warnings`/nullable `date`); typed `HistoryImpactEdge` multi-hop `changelog→task→skill/workflow` + project; workflow facets
- Providers: `historyRepositoryProvider` + `historyTimelineAsyncProvider` wired to `MockWorkspaceRepository` snapshot
- Tests: real corpus + multi-hop + provider contracts

## Validation
- Scoped analyze: No issues found
- history+providers tests: 44 passed
- parser+history tests: 72 passed
- Package analyze: pre-existing unrelated DS* EXTERNAL_BLOCKER (~879 errors) — classified

## Files
- `apps/observatory/lib/data/repositories/history_repository.dart`
- `apps/observatory/lib/data/providers/workspace_providers.dart`
- `apps/observatory/test/data/history/history_repository_test.dart`
- `apps/observatory/test/data/providers/workspace_providers_test.dart`
- `docs/changelog/2026-07-09-task-0711-history-parser-filter-index-path-to-100.md`
- `docs/tasks/03-review/0711-warp-prism-history-parser-and-filter-index.md`

## Blockers
None for task-scoped promotion. Package-wide analyzer remains red outside touch set.
