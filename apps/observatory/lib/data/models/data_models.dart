/// Barrel export for the Warp-Prism data model layer.
///
/// The canonical backbone contract is in [workspace_graph.dart].
/// Kind-specific metadata lives in [task_contracts.dart],
/// [changelog_contracts.dart], and [governance_diagnostics.dart].
///
/// Dual-surface residual closed (Task 0310 path-to-100, 2026-07-18):
/// the legacy freeform `models.dart` (`Asset`/`AssetType`/`AssetEdge`)
/// is no longer part of the live package. Historical sources were moved
/// to `.archive/legacy-yaml-parser-20260718/`. New code must import from
/// this barrel and target the normalized backbone types only.
library;

export 'workspace_graph.dart';
export 'workspace_snapshot.dart';
export 'task_contracts.dart';
export 'task_projection.dart';
export 'changelog_contracts.dart';
export 'governance_diagnostics.dart';
