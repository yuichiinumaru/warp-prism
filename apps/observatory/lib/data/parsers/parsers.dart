/// Barrel export for the Warp-Prism parser layer.
///
/// The canonical parser is [WorkspaceMarkdownParser] which handles
/// `.md` files with YAML frontmatter — the contract required by the
/// mock workspace corpus. Frontmatter decoding uses `package:yaml`
/// via [FrontmatterParser] (nested maps, quoted lists, typed scalars).
///
/// The legacy YAML-only [WorkspaceParser] + freeform Asset models were
/// retired from the live package surface in path-to-100 closeout for
/// Task 0310 (2026-07-18). Historical sources live under
/// `.archive/legacy-yaml-parser-20260718/`. New code must use
/// [WorkspaceMarkdownParser] and normalized backbone types from
/// `data_models.dart`.
library;

export 'frontmatter_parser.dart';
export 'workspace_markdown_parser.dart';
export 'workspace_task_projection_parser.dart';
