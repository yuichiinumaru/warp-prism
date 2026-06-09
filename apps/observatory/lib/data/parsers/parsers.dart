/// Barrel export for the Warp-Prism parser layer.
///
/// The canonical parser is [WorkspaceMarkdownParser] which handles
/// `.md` files with YAML frontmatter — the contract required by the
/// mock workspace corpus.
///
/// The legacy [WorkspaceParser] (YAML-only) is retained for backward
/// compatibility with existing `.yaml`-style mock files. New code
/// should use [WorkspaceMarkdownParser] and target the normalized
/// backbone types from `data_models.dart`.
library;

export 'frontmatter_parser.dart';
export 'workspace_markdown_parser.dart';
export 'workspace_task_projection_parser.dart';
export 'workspace_parser.dart';
