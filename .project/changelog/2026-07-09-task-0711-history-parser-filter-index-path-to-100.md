---
date: 20260709-160304
timestamp: 20260709-160304
agent: builders
task: "0711"
description: "Task 0711 — History Parser And Filter Index Path-to-100 (2026-07-09)"
is_rebuild_safe: true
---

# Task 0711 — History Parser And Filter Index Path-to-100 (2026-07-09)

> **Date**: 2026-07-09
> **Executor**: builders (flutter-engineer)
> **Scope**: History read model — malformed preservation, multi-hop impact edges, provider wiring, real-corpus tests

## Summary

Closed the Implacable Flutter Reviewer 78/100 rejection blockers for Task 0711:

1. **Malformed entries preserved** — invalid/missing dates no longer drop assets; entries carry `isMalformed` + `warnings`.
2. **Typed multi-hop impact edges** — `changelog -> task -> skill/workflow` and `changelog -> project` materialize as `HistoryImpactEdge`.
3. **Provider wiring** — `historyRepositoryProvider` + `historyTimelineAsyncProvider` compose `MockWorkspaceRepository` snapshot load path.
4. **Real-corpus integration tests** — parser + `MockWorkspaceRepository` load against `assets/mock_workspace/docs/changelog/*.md`.
5. **Package analyzer** — scoped data-layer gate clean; full-package DS* errors classified **pre-existing unrelated** (EXTERNAL_BLOCKER).

## Files touched

| File | Change |
| --- | --- |
| `apps/observatory/lib/data/repositories/history_repository.dart` | Nullable date, malformed flags, `HistoryImpactEdge` multi-hop, workflow facets |
| `apps/observatory/lib/data/providers/workspace_providers.dart` | Wire `historyRepositoryProvider` + `historyTimelineAsyncProvider` |
| `apps/observatory/lib/data/providers/providers.dart` | Barrel doc lists history provider |
| `apps/observatory/test/data/history/history_repository_test.dart` | Malformed preserve, multi-hop, real corpus, MockWorkspaceRepository path |
| `apps/observatory/test/data/providers/workspace_providers_test.dart` | History provider success/empty/error contracts |

## Validation

```text
$ cd apps/observatory && flutter analyze \
    lib/data/repositories/history_repository.dart \
    lib/data/providers/workspace_providers.dart \
    lib/data/providers/providers.dart \
    test/data/history/history_repository_test.dart \
    test/data/providers/workspace_providers_test.dart
No issues found!

$ cd apps/observatory && flutter test \
    test/data/history/history_repository_test.dart \
    test/data/providers/workspace_providers_test.dart
All tests passed! (44)

$ cd apps/observatory && flutter test \
    test/data/parsers/workspace_markdown_parser_test.dart \
    test/data/history/history_repository_test.dart
All tests passed! (72)
```

### Package analyzer classification (pre-existing failure policy)

| Gate | Result | Class |
| --- | --- | --- |
| Scoped History/data providers analyze | No issues found | Task gate PASS |
| `flutter analyze lib/data` | pre-existing infos/warnings only outside this task's new code | Unrelated / residual |
| Full package `flutter analyze` | 1068 issues / ~879 errors (DS* undefined in governance/UI presentation) | **Pre-existing (unrelated)** EXTERNAL_BLOCKER |

- **Touched files**: history repository, workspace providers, history/provider tests only.
- **Failing area**: presentation/UI DS symbol residue (`lib/features/governance/...`, UI organisms) — not History data layer.
- **Regression count**: NONE on scoped History gates.
- Baseline continuity: same class as Task 0710 / 1205 package-gate EXTERNAL_BLOCKER documentation.

## Why

History UI must consume a typed read model with filter facets and multi-hop impact edges, including graceful malformed entries, without re-parsing markdown in widgets.
