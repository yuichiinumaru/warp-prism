# Legacy YAML parser dual-surface (archived 2026-07-18)

Task **0310** path-to-100 closeout retired the freeform `Asset` / `AssetType` /
`AssetEdge` dual surface from the live package.

| Archived file | Former live path |
| --- | --- |
| `models.dart` | `apps/observatory/lib/data/models/models.dart` |
| `workspace_parser.dart` | `apps/observatory/lib/data/parsers/workspace_parser.dart` |

## Why archived

- Production load path uses `WorkspaceMarkdownParser` + backbone types only
  (`MockWorkspaceRepository` → `WorkspaceMarkdownParser` → `WorkspaceAsset`).
- No remaining live imports of `models.dart` / `WorkspaceParser`.
- Dual-surface residual blocked independent re-review from scoring 100/100.

## Canonical replacements

- Graph backbone: `lib/data/models/workspace_graph.dart` (via `data_models.dart`)
- Markdown parser: `lib/data/parsers/workspace_markdown_parser.dart` (via `parsers.dart`)
